from Types cimport Vector, Ray, dot, cross
from Shading cimport BRDF, Material, Intersection
from Shading import BRDF, Intersection
from cpython cimport bool
from Samplers cimport Regular, Jittered
from Light cimport AmbientLight

DEF Upsilon = 1e-3
DEF MaxDistance = 10e8
DEF PI = 3.14159265358979
DEF INV_PI = 1.0 / PI


cdef class ViewPlane:

    def __init__(ViewPlane self, int width, int height, float pixel_size, samples_count, sets_count):
        self.Width = width
        self.Height = height
        self.PixelSize = pixel_size
        self.Sampler = Regular(samples_count, sets_count)
        # if samples_count > 1:
        #     self.Sampler = Jittered(samples_count, sets_count)
        # else:
        #     self.Sampler = Regular(1, sets_count)


cdef class Camera:

    def __init__(Camera self,
                 Vector pos,
                 Vector target,
                 Vector up,
                 float viewplane_distance,
                 ViewPlane view_plane,
                 Tracer tracer):
        self.Position = pos
        self.Target = target
        self.Up = up
        self.ViewPlaneDistance = viewplane_distance
        self.ViewPlane = view_plane
        self.Tracer = tracer

    cpdef compute_uvw(Camera self):
        self.w = self.Position - self.Target
        self.w = self.w.normalized()
        self.u = cross(self.Up, self.w)
        self.u = self.u.normalized()
        self.v = cross(self.w, self.u)

    cdef Ray init_ray(Camera self, float x, float y):
        cdef Vector direction

        direction = self.u * x + self.v * y - self.w * self.ViewPlaneDistance
        direction = direction.normalize()

        return Ray(self.Position, direction)

    cpdef list render_scene(Camera self):
        return []

    # cdef Ray init_ray(Camera self, int x, int y):
    #     return Ray(self.Position, Vector(1, 1, 1))


cdef class ThinLensCamera(Camera):
    pass


cdef class PinholeCamera(Camera):

    def __init__(PinholeCamera self,
                 Vector pos,
                 Vector target,
                 Vector up,
                 float viewplane_distance,
                 ViewPlane view_plane,
                 Tracer tracer):
        Camera.__init__(self, pos, target, up, viewplane_distance, view_plane, tracer)

    cdef Ray init_ray(PinholeCamera self, float x, float y):
        cdef Vector direction

        direction = (self.u * x) + (self.v * y) - (self.w * self.ViewPlaneDistance)
        direction = direction.normalize()

        return Ray(self.Position, direction)

    cpdef list render_scene(PinholeCamera self):
        cdef:
            int width = self.ViewPlane.Width
            int height = self.ViewPlane.Height
            list pixels = [] # list
            int count
            Vector origin = self.Position
            Vector L
        for row in range(height):
            for column in range(width):
                L = Vector(0, 0, 0)
                count = 0
                for j in range(self.ViewPlane.Sampler.SamplesCount):
                    sp = self.ViewPlane.Sampler.sample_unit_square()
                    px = self.ViewPlane.PixelSize * (column - 0.5 * width + sp.X) / float(width)
                    py = self.ViewPlane.PixelSize * (row - 0.5 * height + sp.Y) / float(height)
                    ray = self.init_ray(px, py)
                    ray_depth = 0
                    L = L + self.Tracer.trace_ray(ray, ray_depth)
                    count += 1

                pixels.append(L / float(count))

        del origin, L

        return pixels


cdef class Tracer:

    def __init__(Tracer self, Scene scene, int max_depth = 5):
        self.Scene = scene
        self.MaxDepth = max_depth

    cdef Vector trace_ray(Tracer self, Ray ray, int depth):
        return Vector(0, 0, 0)


cdef class WhittedTracer(Tracer):

    def __init__(Tracer self, Scene scene, Vector background, int max_depth = 5):
        Tracer.__init__(self, scene, max_depth)
        self.Background = background
        self.AmbientLight = AmbientLight(Vector(1.0, 1.0, 1.0), 0.1)

    cdef Vector trace_ray(WhittedTracer self, Ray ray, int depth):

        if depth > self.MaxDepth:
            return Vector(0, 0, 0)

        cdef Intersection hit = self.Scene.intersect(ray, self)

        if hit is None:
            return self.Background

        hit.Ray = ray
        hit.Depth = depth

        return hit.Material.colorize(hit)


cdef class ModernTracer(Tracer):
    pass


cdef class Scene:

    def __init__(Scene self, list figures = None, list lights = None):
        if figures is None:
            self.Figures = []
        else:
            self.Figures = figures
        if lights is None:
            self.Lights = lights
        else:
            self.Lights = lights

    def __cinit__(Scene self, list figures = None, list lights = None):
        if figures is None:
            self.Figures = []
        else:
            self.Figures = figures
        if lights is None:
            self.Lights = lights
        else:
            self.Lights = lights

    cpdef add_light(Scene self, light):
        pass

    cdef Intersection intersect(Scene self, Ray ray, Tracer tracer):
        cdef Figure figure
        cdef Intersection hit
        cdef Intersection best_hit = Intersection(tracer)
        best_hit.Distance = 10e8

        for i in range(len(self.Figures)):
            figure = self.Figures[i]
            hit = figure.hit(ray, tracer)
            if hit is not None:
                if hit.Distance < best_hit.Distance:
                    best_hit.set(hit)
        if best_hit.Distance < 10e8:
            return best_hit
        return None


