from Shading cimport Intersection
from Types cimport Vector


cdef class Texture:

    cdef Vector color_at(Texture self, Intersection hit)


cdef class ConstColor(Texture):
    cdef Vector Color

    cdef Vector color_at(ConstColor self, Intersection hit)


cdef class PerlinNoise(Texture):

    cdef Vector color_at(PerlinNoise self, Intersection hit)


cdef class ImageTexture(Texture):

    cdef Vector color_at(ImageTexture self, Intersection hit)

