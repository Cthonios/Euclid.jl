struct BoundingBox{T}
  min::Point{T}
  max::Point{T}
  function BoundingBox(min::Point{T}, max::Point{T}) where T
    @assert min <= max "min = $(min), max = $(max)"
    new{T}(min, max)
  end
end

function Base.show(io::IO, bb::BoundingBox)
  println(io, "BoundingBox:")
  println(io, "  Minimum point = $(bb.min)")
  println(io, "  Maximum point = $(bb.max)")
end

# TODO do we need a difference operation on this or no?

function Base.intersect(bb1::BoundingBox, bb2::BoundingBox)
  # return BoundingBox(max(bb1.min, bb2.min), min(bb1.max, bb2.max))
  return BoundingBox(
    Point(
      max(bb1.min[1], bb2.min[1]),
      max(bb1.min[2], bb2.min[2]),
      max(bb1.min[3], bb2.min[3])
    ),
    Point(
      min(bb1.max[1], bb2.max[1]),
      min(bb1.max[2], bb2.max[2]),
      min(bb1.max[3], bb2.max[3])
    ),
  )
end

Base.max(bb::BoundingBox) = bb.max
Base.min(bb::BoundingBox) = bb.min

function Base.union(bb1::BoundingBox, bb2::BoundingBox)
  # return BoundingBox(min(bb1.min, bb2.min), max(bb1.max, bb2.max))
  return BoundingBox(
    Point(
      min(bb1.min[1], bb2.min[1]),
      min(bb1.min[2], bb2.min[2]),
      min(bb1.min[3], bb2.min[3])
    ),
    Point(
      max(bb1.max[1], bb2.max[1]),
      max(bb1.max[2], bb2.max[2]),
      max(bb1.max[3], bb2.max[3])
    ),
  )
end

function corners(bb::BoundingBox)
  return (
    Point(bb.min[1], bb.min[2], bb.min[3]),
    Point(bb.max[1], bb.min[2], bb.min[3]),
    Point(bb.max[1], bb.max[2], bb.min[3]),
    Point(bb.min[1], bb.max[2], bb.min[3]),
    #
    Point(bb.min[1], bb.min[2], bb.max[3]),
    Point(bb.max[1], bb.min[2], bb.max[3]),
    Point(bb.max[1], bb.max[2], bb.max[3]),
    Point(bb.min[1], bb.max[2], bb.max[3])
  )
end

# struct BoundingBox{T, N}
#   origin::Point{T}
#   widths::Widths{T, N}
# end

# function Base.show(io::IO, bb::BoundingBox)
#   println(io, "BoundingBox:")
#   println(io, "  Origin = $(bb.origin)")
#   println(io, "  Widths = $(bb.widths)")
# end

# function Base.intersect(bb1::BoundingBox, bb2::BoundingBox)
#   m = max.(minimum(bb1), minimum(bb2))
#   mm = min.(maximum(bb1), maximum(bb2))
#   return BoundingBox(m, mm - m)
# end

# function Base.union(bb1::BoundingBox, bb2::BoundingBox)
#   m = min.(minimum(bb1), minimum(bb2))
#   mm = max.(maximum(bb1), maximum(bb2))
#   return BoundingBox(m, mm - m)
# end

# Base.maximum(bb::BoundingBox) = bb.origin + bb.widths
# Base.minimum(bb::BoundingBox) = bb.origin
