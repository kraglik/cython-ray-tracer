from libc.math cimport sin, cos, sqrt
import random
from Types cimport Vector, Ray

cdef float PI = 3.14159265358979

cdef class Sampler:
    cdef:
        int SamplesCount
        int SetsCount
        int Count
        int Jump
        list Samples
        list HemisphereSamples

    cdef void map_hemisphere(Sampler self, float exp)

    cdef Vector sample_unit_square(Sampler self)

    cdef Vector sample_hemisphere(Sampler self)

    cdef void generate_samples(Sampler self)


cdef class Regular(Sampler):

    cdef void generate_samples(Regular self)


cdef class Jittered(Sampler):

    cdef void map_hemisphere(Jittered self, float exp)

    cdef Vector sample_unit_square(Jittered self)

    cdef Vector sample_hemisphere(Jittered self)

    cdef void generate_samples(Jittered self)