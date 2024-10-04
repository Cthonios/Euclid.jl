struct Rectangle{T} <: AbstractGeometricPrimitive{T, 2}
  lower_corner::Point{2, T}
  length::T
  height::T
end

function Rectangle(length, height)
  return Rectangle(Point(0., 0.), length, height)
end

function bounding_box(p::Rectangle)
  HyperRectangle{2, eltype(p)}(
    SVector{2, eltype(p)}(p.lower_corner),
    SVector{2, eltype(p)}(p.length, p.height)
  )
end

function frep(p::Rectangle, v)
  x, y = v[1], v[2]
  dx, dy = p.length, p.height
  lbx, lby = p.lower_corner
  max(-x + lbx, x - dx - lbx, -y + lby, y - dy - lby)
end
