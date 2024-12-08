module Euclid

# mainly for the STL mesh type
import GeometryBasics

using AbstractTrees
using DocStringExtensions
using LinearAlgebra
using MeshIO
using Serde
using StaticArrays

# @template DEFAULT =
#   """
#   $(TYPEDFIELDS)
#   $(DOCSTRING)
#   """
# @template DEFAULT =
#   """
#   $(TYPEDFIELDS)
#   $(SIGNATURES)
#   $(DOCSTRING)
#   $(METHODLIST)
#   """

include("AbstractTypes.jl")
include("BoundingBox.jl")

# affine
include("affine/Affine.jl")

# booleans
include("booleans/Difference.jl")
include("booleans/Intersection.jl")
include("booleans/Union.jl")

# primitives
# 0D
include("primitives/0D/Vertex.jl")

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
include("primitives/3D/Helix.jl")
include("primitives/3D/Sphere.jl")
include("primitives/3D/Torus.jl")

# TODO
# brep stuff that needs to be worked out better
include("primitives/1D/Brep.jl")
include("primitives/2D/Brep.jl")

# complex operations
include("LinearExtrude.jl")

# meshing
include("meshing/Meshing.jl")
include("meshing/VoxelMesh.jl")

# io stuff
include("io/Step.jl")

# geometries
export Point
# topologies
export Vertex
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
