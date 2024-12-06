struct UnionOperation{
  T, N, 
  A <: AbstractPrimitive{T, N}, 
  B <: AbstractPrimitive{T, N}
} <: AbstractBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::UnionOperation)
  return union(boundingbox(left(g)), boundingbox(right(g)))
end

function sdf(g::UnionOperation, v)
  return min(sdf(left(g), v), sdf(right(g), v))
end

# function Base.union(g1::AbstractPrimitive, g2::AbstractPrimitive)
#   return UnionOperation(g1, g2)
# end

# function Base.union(g1::AbstractPrimitive{T, N}, g2::AbstractPrimitive{T, N})::UnionOperation{T, N, <:AbstractPrimitive, <:AbstractPrimitive} where {T, N}
#   return UnionOperation(g1, g2)
# end

Base.union(::Nothing, g::AbstractPattern) = g
Base.union(g::AbstractPrimitive, ::Nothing) = g

function Base.union(g1::AbstractPrimitive, g2::AbstractPrimitive)
  g = UnionOperation(g1, g2)
  return g
end

# type instability below so try and use the annoying two input one above
function Base.union(g::AbstractPrimitive, others...)
  for other in others
    g = union(g, other)
  end
  return g
end
