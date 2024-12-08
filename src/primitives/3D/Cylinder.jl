struct Cylinder{T} <: AbstractGeometricPrimitive{T, 3}
  bottom::T
  radius::T
  height::T
  function Cylinder(radius::T, height::T) where T
    bottom = zero(T)
    @assert radius > zero(T) &&
            height > zero(T)
    new{T}(bottom, radius, height)
  end

  # need this method for IO, but also useful to define
  # positioing apriori
  function Cylinder(bottom::T, radius::T, height::T) where T
    @assert radius > zero(T) &&
            height > zero(T)
    new{T}(bottom, radius, height)
  end
end

function boundingbox(g::Cylinder)
  radius, height = g.radius, g.height
  return BoundingBox(
    Point(-radius, -radius, 0.),
    Point(radius, radius, height)
  )
end

function sdf(g::Cylinder, v)
  bottom, radius, height = g.bottom, g.radius, g.height
  x, y, z = v
  return max(
    -z + bottom, z - height - bottom, 
    sqrt(x * x + y * y) - radius
  )
end
