"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct Line{T} <: AbstractGeometricPrimitive{T, 1}
  a::Point{T}
  b::Point{T}
end

function boundingbox(g::Line)
  return BoundingBox(min(g.a, g.b), max(g.a, g.b))
end

function sdf(g::Line, v)
  a, b = g.a, g.b
  ba = b - a
  va = v - a
  h = clamp(dot(va, ba) / dot(ba, ba), 0., 1.)
  temp = va - ba * h
  return norm(temp)
end
