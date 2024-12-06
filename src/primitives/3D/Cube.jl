struct Cube{T} <: AbstractGeometricPrimitive{T, 3}
  lower_corner::Point{T}
  length::T
end

function Cube(length)
  @assert length > 0.
  return Cube(Point(0., 0., 0.), length)
end

function boundingbox(g::Cube)
  return BoundingBox(
    g.lower_corner,
    g.lower_corner .+ g.length
  )
end

function sdf(g::Cube, v)
  x, y, z = v[1], v[2], v[3]
  dx, dy, dz = g.length, g.length, g.length
  lbx, lby, lbz = g.lower_corner
  max(
    -x + lbx, x - dx - lbx, 
    -y + lby, y - dy - lby,
    -z + lbz, z - dz - lbz,
  )
end
