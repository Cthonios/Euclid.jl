struct Vertex{T} <: AbstractGeometricPrimitive{T, 0}
  p::Point{T}
end

function boundingbox(g::Vertex)
  return BoundingBox(g.p, g.p)
end

function sdf(g::Vertex, v)
  return norm(g.p - v)
end
