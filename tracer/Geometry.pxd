from Types cimport Vector, Ray
from Types import Vector, Ray
from Shading cimport Material, Intersection
from Shading import Material, Intersection
from cpython cimport bool
from Scene cimport Tracer


cdef class Figure:
    cdef Material Material

    cdef Intersection hit(Figure self, Ray ray, Tracer tracer)

    cdef bool in_shadow(Figure self, Ray ray)


cdef class CompositeFigure(Figure):

    cpdef void add_figure(CompositeFigure self, Figure other)


cdef class Sphere(Figure):
    cdef:
        Vector center
        float radius

    cdef Intersection hit(Sphere self, Ray ray, Tracer tracer)

    cdef bool in_shadow(Sphere self, Ray ray)


cdef class Plane(Figure):
    cdef:
        Vector point
        Vector normal
        Material material

    cdef Intersection hit(Plane self, Ray ray, Tracer tracer)

    cdef bool in_shadow(Plane self, Ray ray)


# cdef class Rectangle(Figure):
#     cdef:
#         Vector


cdef class Triangle(Figure):
    cdef:
        Vector a, b, c
        Vector UV_a, UV_b, UB_c

    cdef Intersection hit(Triangle self, Ray ray, Tracer tracer)


cdef class AABB:
    cdef:
        Vector Min, Max
        list Leaves

    cdef bool has_point(AABB self, Vector point)

    cdef bool intersects(AABB self, Ray ray)


