from Types cimport Vector, Ray, cross, dot
from Types import Vector, Ray
from Shading cimport Intersection
from libc.math cimport sqrt
from cpython cimport bool
from Scene cimport Tracer

DEF Upsilon = 1e-3
DEF MaxDistance = 10e8
DEF PI = 3.14159265358979
DEF INV_PI = 1.0 / PI

cdef class Figure:

    def __init__(Figure self, Material material):
        self.Material = material

    cdef Intersection hit(Figure self, Ray ray, Tracer tracer):
        return None

    cdef bool in_shadow(Figure self, Ray ray):
        return False


cdef class CompositeFigure(Figure):

    cpdef void add_figure(CompositeFigure self, Figure other):
        pass


cdef class Sphere(Figure):

    def __init__(Sphere self, Vector pos, float radius, Material material):
        Figure.__init__(self, material)
        self.center = pos
        self.radius = radius

    cdef Intersection hit(Sphere self, Ray ray, Tracer tracer):
        cdef:
            Vector temp = ray.Origin - self.center
            float a = dot(ray.Direction, ray.Direction)
            float b = dot(temp * 2.0, ray.Direction)
            float c = dot(temp, temp) - self.radius * self.radius
            float d = b * b - 4.0 * a * c
            Intersection hit = Intersection(tracer)

        if d < 0:
            return None

        cdef:
            float e = sqrt(d)
            float t = (-b - e) / (2.0 * a)

        if t > Upsilon:
            hit.Distance = t
            hit.HitPoint = ray.Origin + ray.Direction * t
            hit.Normal = (hit.HitPoint - self.center).normalized()
            hit.Material = self.Material
            hit.LocalHitPoint = hit.Normal.copy()
            return hit
        return None

    cdef bool in_shadow(Sphere self, Ray ray):
        cdef:
            Vector temp = ray.Origin - self.center
            float a = dot(ray.Direction, ray.Direction)
            float b = dot(temp * 2.0, ray.Direction)
            float c = temp * temp - self.radius * self.radius
            float d = b * b - 4.0 * a * c

        if d < 0:
            return False

        cdef:
            float e = sqrt(d)
            float t = (-b - e) / (2.0 * a)

        if t > Upsilon:
            return True
        return False


cdef class Plane(Figure):

    def __init__(Plane self, Vector point, Vector normal, Material material):
        self.point = point
        self.normal = normal
        Figure.__init__(self, material)

    cdef Intersection hit(Plane self, Ray ray, Tracer tracer):

        cdef float temp = dot(ray.Direction, self.normal)
        cdef Intersection hit
        if temp != 0.0:
            t = dot((self.point -ray.Origin), self.normal) / temp
        else:
            t = 0.0

        if t > Upsilon:
            hit = Intersection(tracer)
            hit.Distance = t
            hit.HitPoint = ray.Origin + (ray.Direction * t)
            hit.Normal = self.normal
            hit.LocalHitPoint = hit.HitPoint
            hit.Material = self.Material
            return hit

        return None

    cdef bool in_shadow(Plane self, Ray ray):
        cdef float temp = dot(ray.Direction, self.normal)
        if temp != 0.0:
            t = dot((self.point -ray.Origin), self.normal) / temp
        else:
            t = 0.0

        if t > Upsilon:
            return True

        return False


# cdef class Rectangle(Figure):
#
#     cdef bool hit(Rectangle self, Ray ray, Intersection hit):
#         return False
#
#     cdef bool in_shadow(Rectangle self, Ray ray):
#         return False


cdef class Triangle(Figure):

    cdef Intersection hit(Triangle self, Ray ray, Tracer tracer):
        cdef:
            Vector e1 = self.b - self.a
            Vector e2 = self.c - self.a
            Vector pvec = cross(ray.Direction, e2)
            float det = dot(e1, pvec)
            cdef Intersection hit = Intersection(tracer)

        if det < 1e-8 and det > -1e-8:
            return None

        cdef:
            float inv_det = 1.0 / det
            Vector tvec = Ray.Origin - self.a
            float u = dot(tvec, pvec) * inv_det

        if u < 0 or u > 1:
            return None

        cdef:
            Vector qvec = cross(tvec, e1)
            float v = dot(ray.Direction, qvec) * inv_det

        if v < 0 or (u + v) > 1:
            return None

        cdef float t = dot(e2, qvec) * inv_det
        if Upsilon < t < hit.Distance:
            hit.Material = self.Material
            hit.Distance = t
            hit.HitPoint = ray.Direction * t + ray.Origin
            return hit
        return None

    cdef bool in_shadow(Triangle self, Ray ray):
        cdef:
            Vector e1 = self.b - self.a
            Vector e2 = self.c - self.a
            Vector pvec = cross(ray.Direction, e2)
            float det = dot(e1, pvec)

        if abs(det) < 1e-8:
            return False

        cdef:
            float inv_det = 1.0 / det
            Vector tvec = Ray.Origin - self.a
            float u = dot(tvec, pvec) * inv_det

        if u < 0 or u > 1:
            return False

        cdef:
            Vector qvec = cross(tvec, e1)
            float v = dot(ray.Direction, qvec) * inv_det

        if v < 0 or (u + v) > 1:
            return False

        return True


cdef class AABB:

    cdef bool has_point(AABB self, Vector point):
        return False

    cdef bool intersects(AABB self, Ray ray):
        return False


