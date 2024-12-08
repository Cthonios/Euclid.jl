struct Torus{T} <: AbstractGeometricPrimitive{T, 3}
  a::T
  c::T
  function Torus(a::T, c::T) where T
    @assert a > zero(T) && c > zero(T)
    new{T}(a, c)
  end
end

function boundingbox(g::Torus)
  a, c = g.a, g.c
  return BoundingBox(
    Point(-c - a, -c - a, -a),
    Point(c + a, c + a, a)
  )
end

function sdf(g::Torus, v)
  a, c = g.a, g.c
  return sqrt((c - sqrt(v[1]^2 + v[2]^2))^2 + v[3]^2) - a^2
end
