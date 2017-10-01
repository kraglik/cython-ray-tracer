from Types cimport Ray, Vector, cross, dot
from Scene cimport Scene, Tracer
from Light cimport LightSource
from Textures cimport Texture
from Samplers cimport Sampler


cdef class BRDF:
    cdef Sampler Sampler

    cdef Vector f(BRDF self, Intersection hit)

    cdef Vector sample_f(BRDF self, Intersection hit)

    cdef Vector rho(BRDF self, Intersection hit)


cdef class Lambert(BRDF):
    cdef:
        float Kd
        Texture Texture

    cdef Vector f(Lambert self, Intersection hit)

    cdef Vector sample_f(Lambert self, Intersection hit)

    cdef Vector rho(Lambert self, Intersection hit)



cdef class Phong(BRDF):

    cdef Vector f(Phong self, Intersection hit)

    cdef Vector sample_f(Phong self, Intersection hit)

    cdef Vector rho(Phong self, Intersection hit)


cdef class Specular(BRDF):
    cdef:
        float Ks, Exp
        Texture Texture
        Vector Wo, Wi

    cdef Vector f(Specular self, Intersection hit)

    cdef Vector sample_f(Specular self, Intersection hit)

    cdef Vector rho(Specular self, Intersection hit)


cdef class PerfectSpecular(BRDF):
    cdef:
        float Kr
        Texture Texture
        Vector Wo
        float Pdf,
        Vector Wi

    cdef Vector sample_f(PerfectSpecular self, Intersection hit)


cdef class Material:

    cdef Vector colorize(Material self, Intersection hit)


cdef class PurePhong(Material):
    cdef:
        Lambert AmbientBRDF, DiffuseBRDF
        Specular  SpecularBRDF
        Vector Wo, Wi

    cdef Vector colorize(PurePhong self, Intersection hit)


cdef class Matte(Material):
    cdef Lambert AmbientBRDF, DiffuseBRDF

    cdef Vector colorize(Matte self, Intersection hit)


cdef class Reflective(PurePhong):

    cdef PerfectSpecular ReflectiveBRDF

    cdef Vector colorize(Reflective self, Intersection hit)


cdef class Intersection:
    cdef:
        Vector Normal
        Vector HitPoint
        Vector LocalHitPoint
        Ray Ray
        public float Distance
        Scene Scene
        Tracer Tracer
        Material Material
        Vector UV
        int Depth

    cdef Intersection copy(Intersection self)

    cdef void set(Intersection self, Intersection other)




