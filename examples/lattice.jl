using Euclid
using FileIO
using Serde

diameter = 0.5
spacing = 1.0
layer_height = 0.4

cylinders = Euclid.AbstractPrimitive{Float64, 3}[]
function geometry()
  g = nothing
  for layer in 1:25
    if layer % 2 == 0
      for n in 1:25
        c = Cylinder(diameter / 2., 25.)
        c = translate(c, diameter, layer * layer_height, diameter)
        c = translate(c, n * spacing, 0., 0.)
        # c = translate(c, n * spacing, layer * layer_height, 0.)
        push!(cylinders, c)
        g = union(g, c)
      end
    else
      for n in 1:25
        c = Cylinder(diameter / 2., 25.)
        c = rotate(c, :y, π / 2.)
        c = translate(c, diameter, layer * layer_height, diameter)
        c = translate(c, 0., 0., n * spacing)
        push!(cylinders, c)
        g = union(g, c)
      end
    end
  end
  # g = union(cylinders[1], cylinders[2:end])
  return g
end

@time g = geometry()
# @time g = union(cylinders...)
# g = Euclid.scale(g, 2., 1., 1.)
# g = Euclid.shear(g, 0.25)

# @time m = Euclid.voxel_mesh("test.spn", g, 128)
# @time m = Euclid.mesh(g)
# @time save("test.stl", m)

json = Serde.to_json(g)
write("test.json", json)

g_new = Euclid.load_json("test.json")
@time m = Euclid.mesh(g)
@time save("test.stl", m)