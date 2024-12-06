struct IntersectionOperation{
  T, N,
  A <: AbstractPrimitive{T, N},
  B <: AbstractPrimitive{T, N}
} <: AbstractBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::IntersectionOperation)
  return intersect(boundingbox(left(g)), boundingbox(right(g)))
end

function sdf(g::IntersectionOperation, v)
  return max(sdf(left(g), v), sdf(right(g), v))
end

# function Base.intersect(g1::AbstractPrimitive, g2::AbstractPrimitive)
#   return IntersectionOperation(g1, g2)
# end

function Base.intersect(g1::AbstractPrimitive, others::Vararg{T, N}) where {T <: AbstractPrimitive, N}
  g = IntersectionOperation(g1, first(others))
  for other in Base.tail(others)
    g = IntersectionOperation(g, other)
  end
  return g
end
