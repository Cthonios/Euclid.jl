"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct CurveLoop{
  T, 
  A <: AbstractArray{<:AbstractPrimitive{T, 1}, 1}
} <: AbstractGeometricPrimitive{T, 2}
  curves::A
end

function boundingbox(g::CurveLoop)
  bb = boundingbox(first(g.curves))
  bb_min, bb_max = bb.min, bb.max
  for curve in g.curves[2:end]
    bb = boundingbox(curve)
    bb_min = min(bb_min, bb.min)
    bb_max = max(bb_max, bb.max)
  end
  return BoundingBox(bb_min, bb_max)
end

function sdf(g::CurveLoop, v)
  distances = sdf.(g.curves, (v,))
  winding_number = 0
  for line in g.curves
    a, b = line.a, line.b
    if (a[2] <= v[2]) && 
       (b[2] > v[2]) && 
       ((b[1] - a[1]) * (v[2] - a[2]) > (v[1] - a[1]) * (b[2] - a[2]))
      winding_number += 1
    elseif (a[2] > v[2]) && 
           (b[2] <= v[2]) && 
           ((b[1] - a[1]) * (v[2] - a[2]) < (v[1] - a[1]) * (b[2] - a[2]))
      winding_number -= 1
    end
  end

  if winding_number != 0
    return -minimum(distances)
  else
    return minimum(distances)
  end
end
