struct IntersectionOperation{
  A, B <: AbstractArray{<:AbstractPrimitive, 1}
} <: AbstractBooleanPrimitive{A, B}
  left::A
  right::B
end

function IntersectionOperation(left, right...)
  right = [x for x in right]
  return IntersectionOperation{typeof(left), typeof(right)}(left, right)
end

function bounding_box(p::IntersectionOperation)
  h = bounding_box(left(p))
  for r in right(p)
    h = Base.intersect(h, bounding_box(r))
  end
  return h
end

function frep(p::IntersectionOperation, v)
  f = frep(left(p), v)
  for r in right(p)
    f = max(f, frep(r, v))
  end
  return f
end

function Base.intersect(h1::HyperRectangle, h2::HyperRectangle)
  m = max.(minimum(h1), minimum(h2))
  mm = min.(maximum(h1), maximum(h2))
  HyperRectangle(m, mm - m)
end

function Base.intersect(p1::P1, p2::P2) where {
  P1 <: AbstractPrimitive, 
  P2 <: Union{AbstractPrimitive, AbstractArray{<:AbstractPrimitive, 1}}
}
  return IntersectionOperation(p1, p2)
end 
