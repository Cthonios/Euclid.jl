struct Triangle{T} <: AbstractGeometricPrimitive{T, 2}
  a::T
  b::T
  function Triangle(a::T, b::T) where T
    @assert a > 0. &&
            b > 0.
    new{T}(a, b)
  end
end

function boundingbox(g::Triangle)
  return BoundingBox(
    Point(0., 0., 0.),
    Point(g.a, g.b, 0.)
  )
end

function sdf(g::Triangle, v)
  p1 = Point(0, 0., 0.)
  p2 = Point(g.a, 0., 0.)
  p3 = Point(0., g.b, 0.)

  e1 = p2 - p1
  e2 = p3 - p2
  e3 = p1 - p3

  v1 = v - p1
  v2 = v - p2
  v3 = v - p3

  pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0);
	pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0);
	pq3 = v3 - e3 * clamp(dot(v3, e3) / dot(e3, e3), 0.0, 1.0);
    
  s = e1[1] * e3[2] - e1[2] * e3[1]
  d = min( 
    # min(
      Point(dot(pq1, pq1), s * (v1[1] * e1[2] - v1[2] * e1[1]), 0.),
      Point(dot(pq2, pq2), s * (v2[1] * e2[2] - v2[2] * e2[1]), 0.),
      Point(dot(pq3, pq3), s * (v3[1] * e3[2] - v3[2] * e3[1]), 0.) 
    # )
  )

	return -sqrt(d[1]) * sign(d[2]);
end 
