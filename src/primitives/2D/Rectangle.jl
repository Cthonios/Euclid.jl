"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct Rectangle{T} <: AbstractGeometricPrimitive{T, 2}
  lower_corner::Point{T}
  width::T
  height::T
  function Rectangle(width::T, height::T) where T
    @assert width > 0. && height > 0.
    new{T}(Point(0., 0., 0.), width, height)
  end
end

function boundingbox(g::Rectangle)
  return BoundingBox(
    g.lower_corner,
    Point(g.lower_corner[1] + g.width, g.lower_corner[2] + g.height, 0.)
  )
end

function sdf(g::Rectangle, v)
  x, y = v[1], v[2]
  dx, dy = g.width, g.height
  lbx, lby, lbz = g.lower_corner
  max(
    -x + lbx, x - dx - lbx, 
    -y + lby, y - dy - lby
  )
end
