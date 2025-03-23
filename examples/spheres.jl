using Euclid

s1 = Sphere(1.)
s2 = translate(s1, 2., 0., 0.)
s3 = translate(s1, 0., 2., 0.)
s4 = translate(s1, 0., 0., 2.)
ms = mesh.([s1, s2, s3, s4])
m1 = merge(ms)
save("spheres.stl", m1)
