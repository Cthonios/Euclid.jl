using Enzyme
using Euclid
using LinearAlgebra
using Statistics

function geometry(params)
  # unpack params
  radius = params[1]
  s1 = Sphere(radius)
  return s1
end

function mesh!(mesh, params)
  g = geometry(params)
  Euclid.mesh!(mesh, g)
  return nothing
end

function example_func!(dist, mesh, params)
  mesh!(mesh, params)
  dist[1] = mean(norm.(eachcol(mesh.coords)))
  return nothing
end

params = [
  6.
]
g = geometry(params)

mesh = Euclid.ADMesh(g)
mesh!(mesh, params)

vals = zeros(1)

# AD stuff
dvals = make_zero(vals)
dmesh = make_zero(mesh)
dparams = make_zero(params)

# seeding
dvals[1] = 1.
# dparams[1] = 1.
# dmesh.coords .= 1.

# autodiff(
#   Reverse, mesh!,
#   Duplicated(mesh, dmesh),
#   Duplicated(params, dparams)
# )

autodiff(
  Reverse, example_func!,
  Duplicated(vals, dvals),
  Duplicated(mesh, dmesh),
  Duplicated(params, dparams)
)

dparams
dmesh