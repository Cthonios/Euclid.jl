struct FaceOuterBound{T, A <: CurveLoop{T}} <: AbstractPrimitive{T, 2}
  curve_loop::A
  orientation::Bool
end

boundingbox(g::FaceOuterBound) = boundingbox(g.curve_loop)
sdf(g::FaceOuterBound, v) = sdf(g.curve_loop, v)

# TODO tweak types below
struct AdvancedFace{T, A, B} <: AbstractPrimitive{T, 2}
  face::A
  plane::B
  same_sense::Bool

  function AdvancedFace(face, plane, same_sense)
    new{eltype(face), typeof(face), typeof(plane)}(face, plane, same_sense)
  end
end

# TODO need bb and sdf methods

struct CylindricalSurface{T} <: AbstractPrimitive{T, 2}
  plane::Axis{T}
  radius::T
end
