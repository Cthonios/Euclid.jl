struct DifferenceOperation{
  A, B <: AbstractArray{<:AbstractPrimitive, 1}
} <: AbstractBooleanPrimitive{A, B}
  left::A
  right::B
end

function DifferenceOperation(left, right...)
  right = [x for x in right]
  return DifferenceOperation{typeof(left), typeof(right)}(left, right)
end

function bounding_box(p::DifferenceOperation)
  h = bounding_box(left(p))
end

function frep(p::DifferenceOperation, v)
  f = frep(left(p), v)
  for r in right(p)
    f = max(f, -frep(r, v))
  end
  return f
end

function difference(h1::HyperRectangle, h2::HyperRectangle)
  # m = max.(minimum(h1), minimum(h2))
  # mm = min.(maximum(h1), maximum(h2))
  # HyperRectangle(m, mm - m)
  h1
end

function difference(p1::P1, p2::P2) where {
  P1 <: AbstractPrimitive, 
  P2 <: Union{AbstractPrimitive, AbstractArray{<:AbstractPrimitive, 1}}
}
  return DifferenceOperation(p1, p2)
end 
