"""
$(TYPEDFIELDS)
"""
struct AffineMapContainer{
  T, N, 
  M <: AffineTransformation{T}, MInv <: AffineTransformation{T}, 
  P <: AbstractPrimitive{T, N}
} <: AbstractAffinePrimitive{T, N, M, MInv, P}
  transform::M
  transform_inv::MInv
  primitive::P
end

"""
$(TYPEDSIGNATURES)
"""
function AffineMapContainer(transform, primitive::T) where T <: AbstractPrimitive
  return AffineMapContainer(transform, invert(transform), primitive)
end

function boundingbox(g::AffineMapContainer)
  cs = corners(boundingbox(g.primitive))
  cs = map(x -> g.transform(x), cs)
  xs = map(x -> x[1], cs)
  ys = map(x -> x[2], cs)
  zs = map(x -> x[3], cs)
  return BoundingBox(
    Point(minimum(xs), minimum(ys), minimum(zs)),
    Point(maximum(xs), maximum(ys), maximum(zs))
  )
end

function sdf(g::AffineMapContainer, v)
  return sdf(g.primitive, g.transform_inv(v))
end

# front end method
"""
$(TYPEDSIGNATURES)
"""
function rotate(g::AbstractPrimitive, axis, angle)
  if axis == :x
    A = SMatrix{3, 3, eltype(g), 9}(
      1., 0., 0., 0., 
      cos(angle), sin(angle), 0., 
      -sin(angle), cos(angle)
    )
  elseif axis == :y
    A = SMatrix{3, 3, eltype(g), 9}(
      cos(angle), 0., -sin(angle),
      0., 1., 0.,
      sin(angle), 0., cos(angle)
    )
  elseif axis == :z
    A = SMatrix{3, 3, eltype(g), 9}(
      cos(angle), sin(angle), 0.,
      -sin(angle), cos(angle), 0.,
      0., 0., 1.
    )
  else
    @assert false
  end
  transform = AffineTransformation(A, zeros(SVector{3, eltype(g)}))
  return AffineMapContainer(transform, invert(transform), g)
end

"""
$(TYPEDSIGNATURES)
"""
function scale(g::AbstractPrimitive, x, y, z)
  A = SMatrix{3, 3, eltype(g), 9}(
    x, 0., 0.,
    0., y, 0.,
    0., 0., z
  )
  c = zero(SVector{3, eltype(g)})
  transform = AffineTransformation(A, c)
  return AffineMapContainer(transform, invert(transform), g)
end

"""
$(TYPEDSIGNATURES)
"""
function shear(g::AbstractPrimitive, gamma)
  A = SMatrix{3, 3, eltype(g), 9}(
    1., 0., 0.,
    gamma, 1., 0.,
    0., 0., 1.
  )
  c = zero(SVector{3, eltype(g)})
  transform = AffineTransformation(A, c)
  return AffineMapContainer(transform, invert(transform), g)
end

"""
$(TYPEDSIGNATURES)
"""
function translate(g::AbstractPrimitive, x, y, z)
  A = one(SMatrix{3, 3, eltype(g), 9})
  c = SVector{3, eltype(g)}(x, y, z)
  transform = AffineTransformation(A, c)
  return AffineMapContainer(transform, invert(transform), g)
end
