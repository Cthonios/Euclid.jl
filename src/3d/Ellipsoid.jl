struct Ellipsoid{T} <: AbstractGeometricPrimitive{T, 3}
  a::T
  b::T
  c::T
end

function bounding_box(p::Ellipsoid)
  HyperRectangle{3, eltype(p)}(
    SVector{3, eltype(p)}(-p.a, -p.b, -p.c),
    SVector{3, eltype(p)}(2 * p.a, 2 * p.b, 2 * p.c)
  )
end

function frep(p::Ellipsoid, v)
  sqrt((v[1] / p.a)^2 + (v[2] / p.b)^2 + (v[3] / p.c)^2) - one(eltype(p))
end
