struct Ellipsoid{T} <: AbstractGeometricPrimitive{T, 3}
  a::T
  b::T
  c::T
  function Ellipsoid(a::T, b::T, c::T) where T
    @assert a > zero(T) && 
            b > zero(T) && 
            c > zero(T)
    new{T}(a, b, c)
  end
end

function boundingbox(g::Ellipsoid)
  a, b, c = g.a, g.b, g.c
  return BoundingBox(
    Point(-a, -b, -c),
    Point(a, b, c)
  )
end

function sdf(g::Ellipsoid, v)
  a, b, c = g.a, g.b, g.c
  return sqrt((v[1] / a)^2 + (v[2] / b)^2 + (v[3] / c)^2) - one(eltype(g))
end
