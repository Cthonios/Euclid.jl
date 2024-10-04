struct Square{T} <: AbstractGeometricPrimitive{T, 2}
  lower_corner::Point{2, T}
  length::T
end

function Square(length)
  return Square(Point(0., 0.), length)
end

function bounding_box(p::Square)
  HyperRectangle{2, eltype(p)}(
    SVector{2, eltype(p)}(p.lower_corner),
    SVector{2, eltype(p)}(fill(p.length, 2))
  )
end

function frep(p::Square, v)
  x, y = v[1], v[2]
  dx, dy = p.length, p.length
  lbx, lby = p.lower_corner
  max(-x + lbx, x - dx - lbx, -y + lby, y - dy - lby)
end
