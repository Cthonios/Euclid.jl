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

# in development stuff
function _boundingbox_sphere(g)
  # function boundingbox(g, ::Int)
  r = g.parameters[1]
  return BoundingBox(Point(-r, -r, -r), Point(r, r, r))
end

function _sdf_sphere(g, v)
  r = g.parameters[1]
  return norm(v) - r
end

function sphere(radius)
  return Geometry(3, SPHERE, parameters(radius))
end
