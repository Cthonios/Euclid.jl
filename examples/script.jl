using Euclid
using FileIO

# loop example
p1 = Point(0., 0., 0.)
p2 = Point(1., 0., 0.)
p3 = Point(1., 1., 0.)
# p4 = Point(0., 1., 0.)

l1 = Line(p1, p2)
l2 = Line(p2, p3)
l3 = Line(p3, p1)
# l4 = Line(p4, p1)
a1 = Euclid.Arc(1., 0., 2π)

# loop = Euclid.CurveLoop([l1, l2, l3])
loop = Euclid.CurveLoop([a1])
# boundingbox(loop)
# sdf(loop, Point(0.5, 0.5, 0.))
g = LinearExtrude(loop, 10.)
# @show boundingbox(g)

# hole cut example
c1 = Cube(1.)
c2 = Cylinder(0.25, 1.)
t1 = translate(c2, 0.5, 0.5, 0.)
# g = difference(c1, t1)

# torus
t1 = Torus(0.5, 2.5)
t2 = rotate(t1, :x, π / 2.)
t3 = rotate(t1, :y, π / 2.)
t4 = rotate(t1, :z, π / 2.)
# g = union(t1, union(t2, union(t3, t4)))
g = union(t1, [t2, t3, t4])
# g = union(t1, t2, t3, t4)

# complicated extrude
r1 = Rectangle(1., 1.)
e1 = translate(Ellipse(0.1, 0.15), 0.25, 0.25, 0.)
e2 = translate(Ellipse(0.1, 0.15), 0.75, 0.25, 0.)
e3 = translate(Ellipse(0.1, 0.15), 0.75, 0.75, 0.)
e4 = translate(Ellipse(0.1, 0.15), 0.25, 0.75, 0.)

# d1 = difference(r1, union(e1, e2, e3, e4))
# l1 = translate(LinearExtrude(d1, 10.), -0.5, -0.5, -5.)
# @show boundingbox(l1)
# l1 = translate(l1, -5., 0., 0.)
# @show boundingbox(l1)
# l2 = rotate(l1, :x, π / 2.)
# l3 = rotate(l1, :y, π / 2.)
# l2 = rotate(l1, :y, π / 2.)
# # l3 = translate(l2, -5., 0., 5.)
# g = union(l1, l2, l3)
# # @show boundingbox(l3)
# @show boundingbox(g)

# c1 = Cylinder(2.5, 10.)
# c1 = rotate(c1, :y, π / 2.)
# d1 = difference(c, h)
# c2 = Cylinder(5., 1.)
# c2 = rotate(c2, :y, π / 2.)
# c2 = translate(c2, 10., 0., 0.)
# g = union(c2, d1)
# c = g
# g = c

# @time m = Euclid.voxel_mesh("test.spn", g, 128)
@time m = Euclid.mesh(g)
save("test.stl", m)
