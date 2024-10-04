struct Torus{T} <: AbstractGeometricPrimitive{T, 3}
  a::T
  c::T
end

function bounding_box(p::Torus)
  HyperRectangle{3, eltype(p)}(
    SVector{3, eltype(p)}(-p.c - p.a, -p.c - p.a, -p.a),
    SVector{3, eltype(p)}(2 * (p.c + p.a), 2 * (p.c + p.a), 2 * p.a)
  )
end

function frep(p::Torus, v)
  sqrt((p.c - sqrt(v[1]^2 + v[2]^2))^2 + v[3]^2) - p.a^2
end
