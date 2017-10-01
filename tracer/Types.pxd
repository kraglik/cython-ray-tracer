DEF Upsilon = 1e-4
DEF MaxDistance = 10e8
DEF PI = 3.14159265358979
DEF INV_PI = 1.0 / PI

cdef class Vector:
    cdef public float X, Y, Z

    cpdef Vector copy(Vector self)

    cpdef float len(Vector self)

    cpdef float len_squared(Vector self)

    cpdef Vector clip(Vector self, float _min, float _max)

    cdef Vector normalize(Vector self)

    cpdef Vector normalized(Vector self)


cdef class Ray:
    cdef:
        Vector Origin
        Vector Direction

    cpdef Vector distanced(Ray self, float distance)


cpdef Vector cross(Vector a, Vector b)

cpdef float dot(Vector a, Vector b)
