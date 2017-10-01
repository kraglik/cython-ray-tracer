from libc.math cimport sin, cos, sqrt
import random
from Types cimport Vector, Ray

DEF Upsilon = 1e-3
DEF MaxDistance = 10e8
DEF PI = 3.14159265358979
DEF INV_PI = 1.0 / PI

cdef class Sampler:

    def __init__(Sampler self, int samples_count, int sets_count):
        self.SamplesCount = samples_count
        self.SetsCount = sets_count
        self.Samples = []
        self.HemisphereSamples = []
        self.generate_samples()

    def __cinit__(Sampler self, int samples_count, int sets_count):
        self.SamplesCount = samples_count
        self.SetsCount = sets_count
        self.Samples = []
        self.HemisphereSamples = []
        self.generate_samples()

    cdef void map_hemisphere(Sampler self, float exp):
        cdef:
            float cos_phi, sin_phi, cos_theta, sin_theta
            float pu, pv, pw

        for sample in self.Samples:
            cos_phi = cos(2.0 * PI * sample.x)
            sin_phi = sin(2.0 * PI * sample.x)
            cos_theta = pow((1.0 - sample.y), 1.0 / (exp + 1.0))
            sin_theta = sqrt(1.0 - cos_theta * cos_theta)
            pu = sin_theta * cos_phi
            pv = sin_theta * sin_phi
            pw = cos_theta
            self.HemisphereSamples.append(Vector(pu, pv, pw))

    cdef Vector sample_unit_square(Sampler self):
        cdef:
            int index
            Vector sample

        if self.Count % self.SamplesCount == 0:
            self.Jump = (random.randint(1, self.SetsCount) % self.SetsCount) * self.SamplesCount
        index = self.Jump + self.Count % self.SamplesCount
        if index >= len(self.Samples):
            index = len(self.Samples) - 1
        sample = self.Samples[index]
        self.Count += 1
        return sample

    cdef Vector sample_hemisphere(Sampler self):
        cdef:
            int index
            Vector sample

        if self.Count % self.SamplesCount == 0:
            self.jump = (random.randint(1, self.SetsCount) % self.SetsCount) * self.SamplesCount
        index = self.jump + self.Count % self.SamplesCount
        sample = self.HemisphereSamples[index]
        self.Count += 1
        return sample

    cdef void generate_samples(Sampler self):
        pass


cdef class Regular(Sampler):

    def __init__(Regular self, int samples_count, int sets_count):
        Sampler.__init__(self, samples_count, sets_count)
        self.generate_samples()

    cdef void generate_samples(Regular self):
        cdef int n = int(sqrt(self.SamplesCount))

        for i in range(self.SetsCount):
            for j in range(n):
                for k in range(n):
                    self.Samples.append(Vector((k + 0.5) / n, (j + 0.5) / n, 0.0))


cdef class Jittered(Sampler):

    def __init__(Jittered self, int samples_count, int sets_count):
        Sampler.__init__(self, samples_count, sets_count)
        self.generate_samples()

    cdef void generate_samples(Jittered self):
        cdef:
            int n = int(sqrt(self.SamplesCount))
            float subcell_width = 1.0 / self.SamplesCount

        # fill the samples array
        for k in range(n * n * self.SetsCount):
            self.Samples.append(Vector(0.0, 0.0, 0.0))

        # initial patterns
        for p in range(self.SetsCount):
            for i in range(n):
                for j in range(n):
                    self.Samples[i * n + j + p * self.SamplesCount].X = (i * n + j) * subcell_width + random.uniform(0, subcell_width)
                    self.Samples[i * n + j + p * self.SamplesCount].Y = (j * n + i) * subcell_width + random.uniform(0, subcell_width)

        # shuffle x coordinates
        for p in range(self.SetsCount):
            for i in range(n):
                for j in range(n):
                    k = random.randint(j, n - 1)
                    t = self.Samples[i * n + j + p * self.SamplesCount].X
                    self.Samples[i * n + j + p * self.SamplesCount].X = self.Samples[i * n + k + p * self.SamplesCount].X
                    self.Samples[i * n + k + p * self.SamplesCount].X = t

        # shuffle y coordinates
        for p in range(self.SetsCount):
            for i in range(n):
                for j in range(n):
                    k = random.randint(j, n - 1)
                    t = self.Samples[i * n + j + p * self.SamplesCount].Y
                    self.Samples[i * n + j + p * self.SamplesCount].Y = self.Samples[i * n + k + p * self.SamplesCount].Y
                    self.Samples[i * n + k + p * self.SamplesCount].Y = t