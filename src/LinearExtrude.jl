struct LinearExtrude{
  T, 
  G <: AbstractPrimitive{T, 2}
} <: AbstractGeometricPrimitive{T, 3}
  primitive::G
  distance::T
  function LinearExtrude(primitive::G, distance::T) where {G, T}
    @assert distance > 0.
    new{T, G}(primitive, distance)
  end
end

function boundingbox(g::LinearExtrude)
  bb = boundingbox(g.primitive)
  return BoundingBox(
    Point(bb.min[1], bb.min[2], 0.),
    Point(bb.max[1], bb.max[2], g.distance)
  )
end

function sdf(g::LinearExtrude, v)
  z = v[3]
  return max(
    sdf(g.primitive, v),
    max(-z, z - g.distance)
  )
end
