module Euclid

using CoordinateTransformations
using ForwardDiff
using GeometryBasics
using LinearAlgebra
using Meshing
using MeshIO
using Rotations
using StaticArrays

# import GeometryBasics: HyperRectangle, mesh

include("Primitives.jl")
include("Meshes.jl")

end # module Euclid
