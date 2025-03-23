"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct StaticUnion{
  T, N, 
  A <: AbstractPrimitive{T, N}, 
  B <: AbstractPrimitive{T, N}
} <: AbstractStaticBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::StaticUnion)
  return union(boundingbox(left(g)), boundingbox(right(g)))
end

function sdf(g::StaticUnion, v)
  return min(sdf(left(g), v), sdf(right(g), v))
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct DynamicUnion{
  T, N, 
  A <: AbstractPrimitive{T, N}, 
  B <: AbstractArray{<:AbstractPrimitive{T, N}, 1}
} <: AbstractDynamicBooleanPrimitive{T, N, A, B}
  left::A
  right::B
end

function boundingbox(g::DynamicUnion)
  bb_left = boundingbox(left(g))
  bb_min, bb_max = bb_left.min, bb_left.max
  for other in right(g)
    bb_min = min(bb_min, min(boundingbox(other)))
    bb_max = max(bb_max, max(boundingbox(other)))
  end
  return BoundingBox(bb_min, bb_max)
end

function sdf(g::DynamicUnion, v)
  d = sdf(left(g), v)
  for other in right(g)
    d = min(d, sdf(other, v))
  end
  return d
end

# front end methods
"""
$(TYPEDSIGNATURES)
"""
Base.union(::Nothing, g::AbstractPrimitive) = g
"""
$(TYPEDSIGNATURES)
"""
Base.union(g::AbstractPrimitive, ::Nothing) = g

"""
$(TYPEDSIGNATURES)
"""
function Base.union(g1::AbstractPrimitive, g2::AbstractPrimitive)
  g = StaticUnion(g1, g2)
  return g
end

"""
$(TYPEDSIGNATURES)
"""
function Base.union(g1::AbstractPrimitive, g2::AbstractArray{<:AbstractPrimitive, 1})
  g = DynamicUnion{eltype(g1), ndims(g1), typeof(g1), typeof(g2)}(g1, g2)
  return g
end

# in development stuff
function _boundingbox_union(t::CSGTree{T})::BoundingBox{T} where T
  # return union(boundingbox(left(g)), boundingbox(right(g)))
  bb = boundingbox(left(t))
  if right(t) !== nothing
    for g in right(t)
      bb = union(bb, boundingbox(g))
    end
  end
  return bb
end

function _sdf_union(t::CSGTree, v)
  return min(
    sdf(left(t), v), 
    minimum(sdf.(right(t), (v,)))
  )
end

Base.union(g::Geometry, ::Nothing) = g
Base.union(::Nothing, g::Geometry) = g

function Base.union(left::CSGTree{T}, right::CSGTree{T}) where T
  @assert left.geometry.dimension == right.geometry.dimension
  params = -Inf * ones(Parameters)
  g = Geometry(left.geometry.dimension, UNION, params)
  return CSGTree{T}(g, left, [right])
end

Base.union(left::Geometry{T}, right::Geometry{T}) where T = union(CSGTree(left), CSGTree(right))
Base.union(left::CSGTree{T}, right::Geometry{T}) where T = union(left, CSGTree(right))
Base.union(left::Geometry{T}, right::CSGTree{T}) where T = union(CSGTree(left), right)
