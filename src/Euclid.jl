module Euclid

# import CoordinateTransformations
import GeometryBasics

# using CoordinateTransformations
# using Enzyme
# using ForwardDiff
# using Gtk4
# using Gtk4Makie
using LinearAlgebra
using MeshIO
# using Rotations
using Serde
using StaticArrays

include("AbstractTypes.jl")
include("BoundingBox.jl")

# affine
include("affine/Affine.jl")
# include("affine/Rotation.jl")
# include("affine/Translation.jl")

# booleans
include("booleans/Difference.jl")
include("booleans/Intersection.jl")
include("booleans/Union.jl")

# # primitives
# include("primitives/0D/Vertex.jl")

# 1D
include("primitives/1D/Arc.jl")
include("primitives/1D/Line.jl")

# 2D
include("primitives/2D/Circle.jl")
include("primitives/2D/CurveLoop.jl")
include("primitives/2D/Ellipse.jl")
include("primitives/2D/LineLoop.jl")
include("primitives/2D/Rectangle.jl")
include("primitives/2D/Triangle.jl")

# 3D
include("primitives/3D/Cube.jl")
include("primitives/3D/Cylinder.jl")
include("primitives/3D/Ellipsoid.jl")
# include("primitives/3D/Gyroid.jl")
include("primitives/3D/Sphere.jl")
include("primitives/3D/Torus.jl")

# # others
# include("Warps.jl")

# complex operations
include("LinearExtrude.jl")

# meshing
include("meshing/Meshing.jl")
include("meshing/VoxelMesh.jl")

# io stuff
include("io/Step.jl")

# primitive exports
export Point
export Line
export Circle,
       Ellipse,
       LineLoop,
       Rectangle,
       Triangle
export Cube,
       Cylinder,
       Ellipsoid,
       Sphere,
       Torus
# others
export LinearExtrude

# methods
export boundingbox
export difference
export mesh
export rotate
export sdf
export translate

end # module
