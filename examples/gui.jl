# using CairoMakie
using Euclid
using GLMakie

t1 = Torus(1., 2.5)
t2 = translate(t1, 2.5, 0., 0.)
t3 = translate(t1, 0., 2.5, 0.)
g1 = union(difference(t1, t2), t3)
# m = Euclid.mesh(t)
# CairoMakie.mesh(t)
GLMakie.mesh(g1)