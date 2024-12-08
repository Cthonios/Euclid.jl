# This type is really just sticky tack
# to allow for loading from step files
# not sure what to do with it yet.
struct EdgeCurve{T, A} <: AbstractGeometricPrimitive{T, 1}
  a::Point{T}
  b::Point{T}
  curve::A
  same_sense::Bool
end

function boundingbox(g::EdgeCurve)
  return boundingbox(g.curve)
end

function sdf(g::EdgeCurve, v)
  return sdf(g.curve, v)
end

struct OrientedEdge{T, A <: EdgeCurve{T}} <: AbstractGeometricPrimitive{T, 1}
  edge::A
  orientation::Bool
end

function boundingbox(g::OrientedEdge)
  return boundingbox(g.edge)
end

function sdf(g::OrientedEdge, v)
  return sdf(g.edge, v)
end
