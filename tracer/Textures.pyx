from Types cimport Vector, Ray
from Shading cimport Intersection

cdef class Texture:

    cdef Vector color_at(Texture self, Intersection hit):
        return Vector(0, 0, 0)


cdef class ConstColor(Texture):

    def __init__(ConstColor self, Vector color):
        self.Color = color

    cdef Vector color_at(ConstColor self, Intersection hit):
        return self.Color


cdef class PerlinNoise(Texture):

    cdef Vector color_at(PerlinNoise self, Intersection hit):
        return Vector(0, 0, 0) # not implemented yet


cdef class ImageTexture(Texture):

    cdef Vector color_at(ImageTexture self, Intersection hit):
        return Vector(0, 0, 0) # not implemented yet

