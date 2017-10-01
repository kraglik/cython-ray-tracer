from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize

modules = [
    Extension("Types", sources=["Types.pyx"]),
    Extension("Samplers", sources=["Samplers.pyx"]),
    Extension("Geometry", sources=["Geometry.pyx"]),
    Extension("Light", sources=["Light.pyx"]),
    Extension("Shading", sources=["Shading.pyx"]),
    Extension("Textures", sources=["Textures.pyx"]),
    Extension("Scene", sources=["Scene.pyx"])
]

setup(
    cmdclass={'build_ext': build_ext},
    ext_modules=cythonize(modules)
)
