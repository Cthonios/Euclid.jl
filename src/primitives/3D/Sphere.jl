struct Sphere{T} <: AbstractGeometricPrimitive{T, 3}
  radius::T
  function Sphere(radius::T) where T
    @assert radius > zero(T)
    new{T}(radius)
  end
end

function boundingbox(g::Sphere)
  r = g.radius
  return BoundingBox(
    Point(-r, -r, -r), 
    Point(r, r, r)
  )
end

function sdf(g::Sphere, v)
  return norm(v) - g.radius
end
