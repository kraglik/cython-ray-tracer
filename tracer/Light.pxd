from Types cimport Vector, Ray
from Shading cimport Intersection
from cpython cimport bool



cdef class LightSource:

    cpdef Vector L(LightSource self, Intersection hit)

    cpdef Vector get_direction(LightSource self, Intersection hit)

    cpdef bool shadowed(LightSource self, Intersection hit)


cdef class PointLight(LightSource):
    cdef:
        Vector Position
        Vector Color
        float Force
        float LastDistance

    cpdef Vector get_direction(PointLight self, Intersection hit)

    cpdef Vector L(PointLight self, Intersection hit)


cdef class AmbientLight(LightSource):
    cdef:
        Vector Color
        float Force

    cpdef Vector L(AmbientLight self, Intersection hit)

    cpdef Vector get_direction(AmbientLight self, Intersection hit)

    cpdef bool shadowed(AmbientLight self, Intersection hit)


cdef class DirectedLight(LightSource):
    cdef:
        Vector Color
        float Force
        Vector Direction

    cpdef Vector L(DirectedLight self, Intersection hit)

    cpdef Vector get_direction(DirectedLight self, Intersection hit)

    cpdef bool shadowed(DirectedLight self, Intersection hit)

