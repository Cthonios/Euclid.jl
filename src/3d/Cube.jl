struct Cube{T} <: AbstractGeometricPrimitive{T, 3}
  lower_corner::Point{3, T}
  length::T
end

function Cube(length)
  return Cube(Point(0., 0., 0.), length)
end

function bounding_box(p::Cube)
  HyperRectangle{3, eltype(p)}(
    SVector{3, eltype(p)}(p.lower_corner),
    SVector{3, eltype(p)}(fill(p.length, 3))
  )
end

function frep(p::Cube, v)
  x, y, z = v[1], v[2], v[3]
  dx, dy, dz = p.length, p.length, p.length
  lbx, lby, lbz = p.lower_corner
  max(
    -x + lbx, x - dx - lbx, 
    -y + lby, y - dy - lby,
    -z + lbz, z - dz - lbz,
  )
end
