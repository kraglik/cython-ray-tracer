from libc.math cimport sqrt


cpdef float dot(Vector a, Vector b):
    return a.X * b.X + a.Y * b.Y + a.Z * b.Z

cpdef Vector cross(Vector a, Vector b):
    return Vector(
        a.Y * b.Z - a.Z * b.Y,
        a.Z * b.X - a.X * b.Z,
        a.X * b.Y - a.Y * b.X
    )


cdef class Vector:

    def __init__(Vector self, float x, float y, float z):
        self.X = x
        self.Y = y
        self.Z = z

    def __cinit__(Vector self, float x, float y, float z):
        self.X = x
        self.Y = y
        self.Z = z

    def __str__(Vector self):
        return "Vector <{0}, {1}, {2}>".format(self.X, self.Y, self.Z)

    cpdef Vector copy(Vector self):
        return Vector(self.X, self.Y, self.Z)

    def __neg__(Vector self):
        return Vector(-self.X, -self.Y, -self.Z)

    def __abs__(Vector self):
        return Vector(abs(self.X), abs(self.Y), abs(self.Z))

    def __add__(Vector self, Vector other):
        return Vector(self.X + other.X, self.Y + other.Y, self.Z + other.Z)

    def __mul__(Vector self, float other):
        return Vector(self.X * other, self.Y * other, self.Z * other)

    def __matmul__(Vector self, Vector other):
        return Vector(self.X * other.X, self.Y * other.Y, self.Z * other.Z)

    def __iadd__(Vector self, Vector other):
        self.X += other.X; self.Y += other.Y; self.Z +=other.Z
        return self

    def __sub__(Vector self, Vector other):
        return Vector(self.X - other.X, self.Y - other.Y, self.Z - other.Z)

    def __isub__(Vector self, Vector other):
        self.X -= other.X; self.Y -= other.Y; self.Z -= other.Z
        return self

    cpdef float len(Vector self):
        return sqrt(self.X * self.X + self.Y * self.Y + self.Z * self.Z)

    cpdef float len_squared(Vector self):
        return self.X * self.X + self.Y * self.Y + self.Z * self.Z

    def __truediv__(Vector self, float other):
        return Vector(self.X / other, self.Y / other, self.Z / other)

    def __itruediv__(Vector self, float other):
        self.X /= other; self.Y /= other; self.Z /= other
        return self

    cpdef Vector clip(Vector self, float _min, float _max):

        if _min > self.X: self.X = _min
        elif _max < self.X: self.X = _max

        if _min > self.Y: self.Y = _min
        elif _max < self.Y: self.Y = _max

        if _min > self.Z: self.Z = _min
        elif _max < self.Z: self.Z = _max

        return self

    cdef Vector normalize(Vector self):
        cdef float len = self.len()
        self.X /= len; self.Y /= len; self.Z /= len
        return self

    cpdef Vector normalized(Vector self):
        return self.copy().normalize()


cdef class Ray:

    def __init__(Ray self, Vector origin, Vector direction):
        self.Origin = origin
        self.Direction = direction

    def __cinit_(Ray self, Vector origin, Vector direction):
        self.Origin = Vector(origin.X, origin.Y, origin.Z)
        self.Direction = Vector(direction.X, direction.Y, direction.Z)
        self.Direction.normalize()

    def __str__(Ray self):
        return "Ray: {" + "Origin: " + str(self.Origin) + ", Direction: " + str(self.Direction) + "}"

    cpdef Vector distanced(Ray self, float distance):
        return self.Origin + self.Direction * distance


