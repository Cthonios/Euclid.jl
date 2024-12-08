"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct Circle{T} <: AbstractGeometricPrimitive{T, 2}
  radius::T
  function Circle(radius::T) where T
    @assert radius > zero(T)
    new{T}(radius)
  end
end

function boundingbox(g::Circle)
  r = g.radius
  return BoundingBox(
    Point(-r, -r, 0.), 
    Point(r, r, 0.)
  )
end

function sdf(g::Circle, v)
  return norm(v[1:2]) - g.radius
end
