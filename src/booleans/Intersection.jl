struct StaticIntersection{
  T, N,
  A <: AbstractPrimitive{T, N},
  B <: AbstractPrimitive{T, N}
} <: AbstractStaticBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::StaticIntersection)
  return intersect(boundingbox(left(g)), boundingbox(right(g)))
end

function sdf(g::StaticIntersection, v)
  return max(sdf(left(g), v), sdf(right(g), v))
end

function Base.intersect(g1::AbstractPrimitive, g2::AbstractPrimitive)
  return StaticIntersection(g1, g2)
end

struct DynamicIntersection{
  T, N,
  A <: AbstractPrimitive{T, N},
  B <: AbstractArray{<:AbstractPrimitive{T, N}, 1}
} <: AbstractDynamicBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::DynamicIntersection)
  bb_left = boundingbox(left(g))
  bb_min, bb_max = bb_left.min, bb_left.max
  for other in right(g)
    bb_min = min(bb_min, min(boundingbox(other)))
    bb_max = max(bb_max, max(boundingbox(other)))
  end
  return BoundingBox(bb_min, bb_max)
end

function sdf(g::DynamicIntersection, v)
  d = sdf(left(g), v)
  for other in right(g)
    d = max(d, sdf(other, v))
  end
  return d
end

function Base.intersect(g1::AbstractPrimitive, g2::AbstractArray{<:AbstractPrimitive, 1})
  return DynamicIntersection(g1, g2)
end
