"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct StaticDifference{
  T, N,
  A <: AbstractPrimitive{T, N},
  B <: AbstractPrimitive{T, N}
} <: AbstractStaticBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::StaticDifference)
  return boundingbox(left(g))
end

function sdf(g::StaticDifference, v)
  return max(sdf(left(g), v), -sdf(right(g), v))
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct DynamicDifference{
  T, N,
  A <: AbstractPrimitive{T, N},
  B <: AbstractArray{<:AbstractPrimitive{T, N}, 1}
} <: AbstractDynamicBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::DynamicDifference)
  bb_left = boundingbox(left(g))
  bb_min, bb_max = bb_left.min, bb_left.max
  for other in right(g)
    bb_min = min(bb_min, min(boundingbox(other)))
    bb_max = max(bb_max, max(boundingbox(other)))
  end
  return BoundingBox(bb_min, bb_max)
end

function sdf(g::DynamicDifference, v)
  d_left = sdf(left(g), v)
  d_right = typemin(Float64)
  for other in right(g)
    d_right = max(d_right, sdf(other, v))
  end
  return max(d_left, -d_right)
end

# front end methods
"""
$(TYPEDSIGNATURES)
"""
function difference(g1::AbstractPrimitive, g2::AbstractPrimitive)
  return StaticDifference(g1, g2)
end

"""
$(TYPEDSIGNATURES)
"""
function difference(g1::AbstractPrimitive, g2::AbstractArray{<:AbstractPrimitive, 1})
  return DynamicDifference(g1, g2)
end
