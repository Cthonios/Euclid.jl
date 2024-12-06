struct DifferenceOperation{
  T, N,
  A <: AbstractPrimitive{T, N},
  B <: AbstractPrimitive{T, N}
} <: AbstractBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::DifferenceOperation)
  return boundingbox(left(g))
end

function sdf(g::DifferenceOperation, v)
  return max(sdf(left(g), v), -sdf(right(g), v))
end

function difference(g1::AbstractPrimitive, g2::AbstractPrimitive)
  return DifferenceOperation(g1, g2)
end
