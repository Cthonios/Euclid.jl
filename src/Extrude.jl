struct Extrude{P <: AbstractPrimitive, T} <: AbstractPrimitive
  p::P
  distance::T
end

function bounding_box(p::Extrude)
  h = bounding_box(p.p)
  origin = SVector{3, eltype(p.p)}(h.origin[1], h.origin[2], 0)
  widths = SVector{3, eltype(p.p)}(h.widths[1], h.widths[2], p.distance)
  return HyperRectangle{3, eltype(h.origin)}(origin, widths)
end

function frep(p::Extrude, v)
  x, y, z = v[1], v[2], v[3]
  r = frep(p.p, SVector(x, y))
  max(max(-z, z - p.distance), r)
end
