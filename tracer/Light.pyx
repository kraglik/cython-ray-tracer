from Types cimport Vector, Ray
from Shading cimport Intersection
from cpython cimport bool


DEF Upsilon = 1e-4
DEF MaxDistance = 10e8
DEF PI = 3.14159265358979
DEF INV_PI = 1.0 / PI


cdef class LightSource:

    cpdef Vector L(LightSource self, Intersection hit):
        return Vector(0, 0, 0)

    cpdef Vector get_direction(LightSource self, Intersection hit):
        return Vector(0, 0, 0)

    cpdef bool shadowed(LightSource self, Intersection hit):
        return True


cdef class PointLight(LightSource):

    def __init__(PointLight self, Vector pos, Vector color, float power):
        self.Position = pos
        self.Color = color
        self.Force = power

    def __cinit__(PointLight self, Vector pos, Vector color, float power):
        self.Position = pos
        self.Color = color
        self.Force = power

    cpdef Vector get_direction(PointLight self, Intersection hit):
        cdef Vector direction = (hit.HitPoint - self.Position).normalized()
        self.LastDistance = direction.len()
        return direction

    cpdef Vector L(PointLight self, Intersection hit):
        return self.Color * self.Force  / (self.LastDistance * self.LastDistance)

    cpdef bool shadowed(PointLight self, Intersection hit):
        cdef:
            Vector direction = (hit.HitPoint - self.Position)
            float distance = direction.len()
            Ray shadow_ray = Ray(self.Position, direction.normalize())
            Intersection shadow_hit = Intersection(hit.Tracer)

            bool result = True

        shadow_hit = hit.Scene.intersect(shadow_ray, hit.Tracer)
        if shadow_hit is not None:
            if distance - Upsilon <= shadow_hit.Distance <= distance + Upsilon:
                result = False

        del direction, shadow_ray, shadow_hit
        return result


cdef class AmbientLight(LightSource):

    def __cinit__(AmbientLight self, Vector color, float force):
        self.Color = color
        self.Force = force

    cpdef Vector L(AmbientLight self, Intersection hit):
        return self.Color * self.Force

    cpdef Vector get_direction(AmbientLight self, Intersection hit):
        return Vector(0, 0, 0)

    cpdef bool shadowed(AmbientLight self, Intersection hit):
        return False


cdef class DirectedLight(LightSource):

    def __init__(DirectedLight self, Vector color, Vector direction, float force):
        self.Direction = direction
        self.Color = color
        self.Force = force

    cpdef Vector get_direction(self, Intersection hit):
        return self.Direction

    cpdef Vector L(self, Intersection hit):
        return self.Color * self.Force

    cpdef bool shadowed(DirectedLight self, Intersection hit):
        cdef Ray ray = Ray(hit.HitPoint, -self.Direction)
        for shape in hit.Scene.Figures:
            shadow_hit = hit.Scene.intersect(ray, hit.Tracer)
            if shadow_hit:
                return True
        return False

# cdef class AmbientOcclusion(LightSource):
#
#     def __init__(AmbientOcclusion self):
#         pass
#
#     def __cinit__(AmbientOcclusion self):
#         pass
#
#     cdef Vector L(AmbientOcclusion self, Intersection hit):
#         return self.Color * self.Force
#
#     cdef Vector get_direction(AmbientOcclusion self, Intersection hit):
#         return Vector(0, 0, 0)
#
#     cdef bool shadowed(AmbientOcclusion self, Ray ray, Intersection hit):
#         return False

