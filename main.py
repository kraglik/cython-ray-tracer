from tracer import *
from PIL import Image

texture1 = ConstColor(Vector(1, 0, 0))
texture2 = ConstColor(Vector(0, 1, 0))
material = Matte(texture1, 0.5, 0.5)
material2 = Matte(texture2, 0.5, 0.5)
material3 = Reflective(0.1, 0.2, 0.2, texture2, 1, 0.5, texture1)

mirror = Reflective(0, 0, 0.2, texture1, 15, 0.8, texture1)

sphere = Sphere(Vector(5, 0, 1.5), 1, mirror)
sphere2 = Sphere(Vector(5, 0, -1.5), 1, mirror)
sphere3 = Sphere(Vector(7, 0, 0), 1, material)
plane = Plane(Vector(0, -1, 0), Vector(0, 1, 0), material3)
lamp = PointLight(Vector(3, 3, 1), Vector(0.7, 0.7, 0.7), 3)
sun = DirectedLight(Vector(0.7, 0.7, 0.7), Vector(0.1, -1, 0.1).normalized(), 0.5)

scene = Scene([sphere, plane, sphere2, sphere3], [lamp, sun])

width = 2000
height = 2000

view_plane = ViewPlane(width, height, 1.0, 4, 4)
tracer = WhittedTracer(scene, Vector(0.6, 0.6, 0.6))
camera = PinholeCamera(Vector(2, 2, 0), Vector(5, 0, 0), Vector(0, 1, 0), 1, view_plane, tracer)
camera.compute_uvw()

result = camera.render_scene()

img = Image.new('RGB', (width, width), "black")
pixels = img.load()

for i in range(img.size[0]):
    for j in range(img.size[1]):
        color = result[i + width * j]
        pixels[i, img.size[1] - 1 - j] = (int(255 * color.X), int(255 * color.Y), int(255 * color.Z))

img.show()

