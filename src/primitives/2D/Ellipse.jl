"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct Ellipse{T} <: AbstractGeometricPrimitive{T, 2}
  a::T
  b::T
  function Ellipse(a::T, b::T) where T
    @assert a > zero(T) && 
            b > zero(T)
    new{T}(a, b)
  end
end

function boundingbox(g::Ellipse)
  a, b = g.a, g.b
  return BoundingBox(
    Point(-a, -b, 0.),
    Point(a, b, 0.)
  )
end

function sdf(g::Ellipse, v)
  a, b = g.a, g.b
  return sqrt((v[1] / a)^2 + (v[2] / b)^2) - one(eltype(g))
end
