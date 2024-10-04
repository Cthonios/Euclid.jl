struct UnionOperation{
  A, B <: AbstractArray{<:AbstractPrimitive, 1}
} <: AbstractBooleanPrimitive{A, B}
  left::A
  right::B
end

function UnionOperation(left, right...)
  right = [x for x in right]
  return UnionOperation{typeof(left), typeof(right)}(left, right)
end

function bounding_box(p::UnionOperation)
  h = bounding_box(left(p))
  for r in right(p)
    h = Base.union(h, bounding_box(r))
  end
  return h
end

function frep(p::UnionOperation, v)
  f = frep(left(p), v)
  for r in right(p)
    f = min(f, frep(r, v))
  end
  return f
end

function Base.union(h1::HyperRectangle, h2::HyperRectangle)
  m = min.(minimum(h1), minimum(h2))
  mm = max.(maximum(h1), maximum(h2))
  return HyperRectangle(m, mm - m)
end

function Base.union(p1::P1, p2::P2) where {
  P1 <: AbstractPrimitive, 
  P2 <: Union{AbstractPrimitive, AbstractArray{<:AbstractPrimitive, 1}}
}
  return UnionOperation(p1, p2)
end 
