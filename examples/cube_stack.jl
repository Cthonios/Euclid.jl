using Euclid
using FileIO

c1 = Cube(1.)
c2 = Euclid.translate(c1, 1., 0., 0.)
c3 = Euclid.translate(c1, 0., 1., 0.)
c4 = Euclid.translate(c1, 0., 0., 1.)

# this example does not merge cubes
# ms = Euclid.mesh.(gs)
# m1 = merge(ms)
# FileIO.save("cube_stack_unmerged.stl", m1)

# below it's merged
g1 = c1 ∪ c2 ∪ c3 ∪ c4
m1 = Euclid.mesh(g1)
FileIO.save("cube_stack_merged.stl", m1)
