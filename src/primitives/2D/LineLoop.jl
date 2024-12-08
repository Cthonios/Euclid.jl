struct LineLoop{T, A <: NTuple} <: AbstractGeometricPrimitive{T, 2}
  lines::A
  # function LineLoop(lines::NTuple{NL, Line{T}}) where {NL, T}
  #   @assert length(unique(lines)) == NL "Lines not unique"
  #   checks = map(x -> cross(first(lines).b - first(lines.a), x.b - x.a), Base.tail(lines)...)
  #   @assert all(x ≈ checks[1], checks)
  #   return LineLoop(lines)
  # end
end

function boundingbox(g::LineLoop)
  bb = boundingbox(first(g.lines))
  bb_min, bb_max = bb.min, bb.max
  for line in Base.tail(g.lines)
    bb = boundingbox(line)
    bb_min = min(bb_min, bb.min)
    bb_max = max(bb_max, bb.max)
  end
  return BoundingBox(bb_min, bb_max)
end

# TODO likely only works in 2D right now
function sdf(g::LineLoop, v)
  distances = sdf.(g.lines, (v,))

  winding_number = 0
  for line in g.lines
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
