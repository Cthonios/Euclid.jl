struct Circle{T} <: AbstractGeometricPrimitive{T, 2}
  radius::T
end

function bounding_box(p::Circle)
  HyperRectangle{2, eltype(p)}(
    SVector{2, eltype(p)}(fill(-p.radius, 2)),
    SVector{2, eltype(p)}(fill(2 * p.radius, 2))
  )
end

function frep(p::Circle, v)
  norm(v) - p.radius
end
