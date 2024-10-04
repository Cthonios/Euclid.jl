struct Ellipse{T} <: AbstractGeometricPrimitive{T, 2}
  a::T
  b::T
end 

function bounding_box(p::Ellipse)
  HyperRectangle{2, eltype(p)}(
    SVector{2, eltype(p)}(-p.a, -p.b),
    SVector{2, eltype(p)}(2 * p.a, 2 * p.b)
  )
end

function frep(p::Ellipse, v)
  sqrt((v[1] / p.a)^2 + (v[2] / p.b)^2) - one(eltype(p))
end
