struct AffineTransformation{T}
  A::SMatrix{3, 3, T, 9}
  c::SVector{3, T}
end

function (transform::AffineTransformation)(x::Point)
  return transform.A * x + transform.c
end

function invert(transform::AffineTransformation)
  # correct just trying other things
  # return inv(transform.A) * (x - transform.c)
  inv_A = inv(transform.A)
  inv_c = -inv_A * transform.c
  return AffineTransformation(inv_A, inv_c)
end

# container
struct AffineMapContainer{
  T, N, 
  M, MInv, 
  P <: AbstractPrimitive{T, N}
} <: AbstractAffinePrimitive{T, N, M, MInv, P}
  transform::M
  transform_inv::MInv
  primitive::P
end

function AffineMapContainer(transform, primitive::T) where T <: AbstractPrimitive
  # return AffineMapContainer(transform, inv(transform), primitive)
  return AffineMapContainer(transform, invert(transform), primitive)
end

# function AffineMapContainer(transform, primitive::T) where T <: AbstractAffinePrimitive
#   # transform = CoordinateTransformations.compose(primitive.transform, transform)
#   transform = CoordinateTransformations.compose(transform, primitive.transform)
#   return AffineMapContainer(transform, inv(transform), primitive.primitive)
# end

function boundingbox(g::AffineMapContainer)
  cs = corners(boundingbox(g.primitive))
  cs = map(x -> g.transform(x), cs)
  # @show cs
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

# rotation
function rotate(g, axis, angle)
  if axis == :x
    A = SMatrix{3, 3, eltype(g), 9}(
      1., 0., 0., 0., 
      cos(angle), sin(angle), 0., 
      -sin(angle), cos(angle)
    )
  elseif axis == :y
    A = SMatrix{3, 3, eltype(g), 9}(
      cos(angle), 0., sin(angle),
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

function translate(g, x, y, z)
  A = one(SMatrix{3, 3, eltype(g), 9})
  c = SVector{3, eltype(g)}(x, y, z)
  transform = AffineTransformation(A, c)
  return AffineMapContainer(transform, invert(transform), g)
end
