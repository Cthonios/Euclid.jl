struct Sphere{T} <: AbstractGeometricPrimitive{T, 3}
  radius::T
end

function bounding_box(p::Sphere)
  HyperRectangle{3, eltype(p)}(
    SVector{3, eltype(p)}(fill(-p.radius, 3)),
    SVector{3, eltype(p)}(fill(2 * p.radius, 3))
  )
end

function frep(p::Sphere, v)
  norm(v) - p.radius
end
