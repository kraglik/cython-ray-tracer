from Types cimport Ray, Vector, dot, cross
from Scene cimport Scene
from Light cimport LightSource
from Samplers cimport Sampler
from Textures cimport Texture

DEF Upsilon = 1e-3
DEF MaxDistance = 10e8
DEF PI = 3.14159265358979
DEF INV_PI = 1.0 / PI


cdef class BRDF:
    def __init__(BRDF self, Sampler sampler):
        self.Sampler = sampler

    cdef Vector f(BRDF self, Intersection hit):
        return Vector(0, 0, 0)

    cdef Vector sample_f(BRDF self, Intersection hit):
        return Vector(0, 0, 0)

    cdef Vector rho(BRDF self, Intersection hit):
        return Vector(0, 0, 0)


cdef class Lambert(BRDF):

    def __init__(Lambert self, float kd, Texture texture, Sampler sampler = None):
        BRDF.__init__(self, sampler)
        self.Kd = kd
        self.Texture = texture
        if sampler is not None:
            self.Sampler.map_hemisphere(1)

    cdef Vector f(Lambert self, Intersection hit):
        color = self.Texture.color_at(hit)
        return (color * self.Kd) * INV_PI

    cdef Vector rho(Lambert self, Intersection hit):
        return self.Texture.color_at(hit) * self.Kd



cdef class Phong(BRDF):
    pass


cdef class Specular(BRDF):

    def __init__(Specular self, float ks, float exp, Texture texture, Sampler sampler = None):
        self.Ks  = ks
        self.Exp = exp
        self.Texture = texture
        BRDF.__init__(self, sampler)

    cdef Vector f(Specular self, Intersection hit):
        cdef:
            float ndotwi = dot(hit.Normal, self.Wi)
            Vector r = -self.Wi + hit.Normal * (2.0 * ndotwi)
            float rdotwo = dot(r, self.Wo)

        if rdotwo > 0.0:
            color = self.Texture.color_at(hit)
            return (color * self.Ks) * pow(rdotwo, self.Exp)
        else:
            return Vector(0.0, 0.0, 0.0)


cdef class PerfectSpecular(BRDF):

    def __init__(PerfectSpecular self, float kr, Texture texture, Sampler sampler = None):
        self.Kr      = kr
        self.Texture = texture
        BRDF.__init__(self, sampler)

    cdef Vector sample_f(PerfectSpecular self, Intersection hit):
        cdef:
            float ndotwo = dot(hit.Normal, self.Wo)
        self.Wi = -self.Wo + hit.Normal * (2.0 * ndotwo)
        self.Pdf = dot(hit.Normal, self.Wi)
        color = self.Texture.color_at(hit)
        return color * self.Kr


cdef class Material:

    cdef Vector colorize(Material self, Intersection hit):
        return Vector(0.0, 0.0, 0.0)


cdef class PurePhong(Material):

    def __init__(self, float ka, float kd, float ks, Texture cd, float exp):
        self.AmbientBRDF = Lambert(ka, cd)
        self.DiffuseBRDF = Lambert(kd, cd)
        self.SpecularBRDF = Specular(ks, exp, cd)

    cdef Vector colorize(PurePhong self, Intersection hit):
        cdef:
            Vector wo =  (-hit.Ray.Direction).normalized()
            Vector L = self.AmbientBRDF.rho(hit) @ hit.Tracer.AmbientLight.L(hit)

        for light in hit.Scene.Lights:
            wi = light.get_direction(hit) * -1.0
            wi = wi.normalized()
            ndotwi = dot(hit.Normal, wi)
            if ndotwi > 0.0:
                in_shadow = False

                shadow_ray = Ray(hit.HitPoint, wi)
                in_shadow = light.shadowed(hit)
                if not in_shadow:
                    self.SpecularBRDF.Wo = wo
                    self.SpecularBRDF.Wi = wi
                    L = L + (self.DiffuseBRDF.f(hit) + self.SpecularBRDF.f(hit)) @ light.L(hit)  * ndotwi

        return L



cdef class Matte(Material):

    def __init__(Matte self, Texture texture, float ka, float kd, Sampler sampler = None):
        self.AmbientBRDF = Lambert(ka, texture)
        self.DiffuseBRDF = Lambert(kd, texture, sampler)

    cdef Vector colorize(Matte self, Intersection hit):
        cdef:
            Vector L, wi
            float ndotwi
        L = self.AmbientBRDF.rho(hit) @ hit.Tracer.AmbientLight.L(hit)
        for light in hit.Scene.Lights:
            wi = -(light.get_direction(hit).normalized())
            ndotwi = dot(hit.Normal, wi)
            if ndotwi > 0.0:
                in_shadow = False
                #if light.cast_shadow():
                in_shadow = light.shadowed(hit)
                if not in_shadow:
                    L = L + self.DiffuseBRDF.f(hit) @ light.L(hit) * ndotwi
        del wi
        return L



cdef class Reflective(PurePhong):

    def __init__(Reflective self, float ka, float kd, float ks, Texture cd, float exp, float kr, Texture cr):
        PurePhong.__init__(self, ka, kd, ks, cd, exp)
        self.ReflectiveBRDF = PerfectSpecular(kr, cr)

    cdef Vector colorize(Reflective self, Intersection hit):
        L = PurePhong.colorize(self, hit)

        wo = -hit.Ray.Direction
        self.ReflectiveBRDF.Wo = wo
        fr = self.ReflectiveBRDF.sample_f(hit)
        wi = self.ReflectiveBRDF.Wi
        origin = hit.HitPoint
        direction = wi
        ndotwi = dot(hit.Normal, wi)
        L = L + hit.Tracer.trace_ray(Ray(origin, direction), hit.Depth + 1) @ (fr * ndotwi)


        return L




cdef class Intersection:

    def __cinit__(Intersection self, Tracer tracer):
        self.Tracer = tracer
        self.Distance = MaxDistance
        self.Scene = tracer.Scene
        self.Depth = 0

    cdef Intersection copy(Intersection self):
        cdef Intersection result = Intersection(self.Tracer)

        result.Distance = self.Distance
        result.Normal = self.Normal
        result.HitPoint = self.HitPoint
        result.Ray = self.Ray
        result.Material = self.Material
        result.LocalHitPoint = self.LocalHitPoint
        result.UV = self.UV
        result.Tracer = self.Tracer
        result.Depth = self.Depth

        return result

    cdef void set(Intersection self, Intersection other):
        self.Distance = other.Distance
        self.Normal = other.Normal
        self.HitPoint = other.HitPoint
        self.LocalHitPoint = other.LocalHitPoint
        self.Ray = other.Ray
        self.Scene = other.Scene
        self.UV = other.UV
        self.Tracer = other.Tracer
        self.Material = other.Material
        self.Depth = other.Depth
