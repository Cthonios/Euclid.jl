struct Gyroid{T} <: AbstractGeometricPrimitive{T, 3}
  width::T
end

function boundingbox(g::Gyroid)
  w = g.width
  return BoundingBox(
    Point(-w, -w, -w),
    Widths(2 * w, 2 * w, 2 * w)
  )
end

name(::Gyroid) = "Gyroid"

_gyroid(v) = cos(v[1]) * sin(v[2]) + 
             cos(v[2]) * sin(v[3]) + 
             cos(v[3]) * sin(v[1])

function sdf(g::Gyroid, v)
  w = g.width
  max(_gyroid(v) - w, - _gyroid(v) - w)
end