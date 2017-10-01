from Types cimport Vector, Ray
from Geometry cimport Figure, CompositeFigure
from Samplers cimport Sampler
from Shading cimport BRDF, Material, Intersection
from cpython cimport bool
from Light cimport AmbientLight
from cpython cimport bool


cdef class ViewPlane:
    cdef:
        int Height, Width
        float PixelSize
        Sampler Sampler
        Vector Position


cdef class Camera:
    cdef:
        Vector Position
        Vector Target
        Vector Up
        Tracer Tracer
        Vector u, v, w
        float ViewPlaneDistance
        ViewPlane ViewPlane

    cpdef list render_scene(Camera self)

    cdef Ray init_ray(Camera self, float x, float y)

    cpdef compute_uvw(Camera self)


cdef class ThinLensCamera(Camera):
    pass


cdef class PinholeCamera(Camera):

    cdef Ray init_ray(PinholeCamera self, float x, float y)

    cpdef list render_scene(PinholeCamera self)


cdef class Tracer:
    cdef:
        Scene Scene
        Vector Background
        AmbientLight AmbientLight
        int MaxDepth

    cdef Vector trace_ray(Tracer self, Ray ray, int depth)


cdef class WhittedTracer(Tracer):
    pass


cdef class RayCaster(Tracer):
    pass


cdef class ModernTracer(Tracer):
    pass


cdef class Scene:
    cdef:
        list Figures
        list Lights

    cpdef add_light(Scene self, light)

    cdef Intersection intersect(Scene self, Ray ray, Tracer tracer)

