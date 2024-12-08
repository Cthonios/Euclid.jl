struct Arc{T} <: AbstractGeometricPrimitive{T, 1}
  center::Point{T}
  radius::T
  angle_start::T
  angle_end::T
  function Arc(radius::T, angle_start::T, angle_end::T) where T
    new{T}(Point(0., 0., 0.), radius, angle_start, angle_end)
  end
end

# TODO this could be made more accurate
# this is a large upper bound for a lot of cases
function boundingbox(g::Arc)
  r = g.radius
  return BoundingBox(
    Point(-r, -r, 0.),
    Point(r, r, 0.)
  )
end

function sdf(g::Arc, p)
  center, radius = g.center, g.radius
  start_angle, end_angle = g.angle_start, g.angle_end

  v = p - g.center
  dist_to_center = norm(v)

  angle = atan(v[2], v[1])

  # Ensure angles are in [0, 2π)
  start_angle = mod(start_angle, 2π)
  end_angle = mod(end_angle, 2π)
  angle = mod(angle, 2π)
  
  # Check if angle is within the arc range
  in_arc = start_angle <= angle <= end_angle || 
           (end_angle < start_angle && (angle >= start_angle || angle <= end_angle))

  # Closest point on the arc
  if in_arc
    closest_point = center + radius * normalize(v)
  else
    # Snap to the closest endpoint of the arc
    start_point = center + radius * [cos(start_angle), sin(start_angle), 0.]
    end_point = center + radius * [cos(end_angle), sin(end_angle), 0.]
    if norm(p - start_point) < norm(p - end_point)
      closest_point = start_point
    else
      closest_point = end_point
    end
  end

  # Compute signed distance
  unsigned_distance = norm(p - closest_point)
  sign = dist_to_center < radius ? -1.0 : 1.0
  return sign * unsigned_distance
end
