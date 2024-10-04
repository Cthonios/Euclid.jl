abstract type AbstractPrimitive end

abstract type AbstractGeometricPrimitive{T, N} <: AbstractPrimitive end
Base.eltype(::AbstractGeometricPrimitive{T, N}) where {T, N} = T
Base.ndims(::AbstractGeometricPrimitive{T, N}) where {T, N} = N

abstract type AbstractBooleanPrimitive{A, B} <: AbstractPrimitive end
Base.ndims(p::AbstractBooleanPrimitive) = ndims(left(p))
left(p::AbstractBooleanPrimitive) = p.left
right(p::AbstractBooleanPrimitive) = p.right

include("Affine.jl")

include("boolean/Difference.jl")
include("boolean/Intersection.jl")
include("boolean/Union.jl")

include("2d/Circle.jl")
include("2d/Ellipse.jl")
include("2d/Rectangle.jl")
include("2d/Square.jl")

include("3d/Cube.jl")
include("3d/Ellipsoid.jl")
include("3d/Helix.jl")
include("3d/Sphere.jl")
include("3d/Torus.jl")

include("Extrude.jl")
