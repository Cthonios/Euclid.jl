struct Helix{T} <: AbstractGeometricPrimitive{T, 3}
  a::T
  c::T
  height::T
  pitch::T
  bottom::T
  function Helix(a::T, c::T, height::T, pitch::T) where T
    new{T}(a, c, height, pitch, zero(T))
  end
end

function boundingbox(g::Helix)
  a, c, height = g.a, g.c, g.height
  return BoundingBox(
    # Point(-a - c, -a - c, 0.),
    # Point(a + c, a + c, height)
    Point(0., -a - 1.5 * c, -a - 1.5 * c),
    Point(height, a + 1.5 * c, a + 1.5 * c)
  )
end

function sdf(g::Helix, v)
  # parameters
  a, c, height, pitch, bottom = g.a, g.c, g.height, g.pitch, g.bottom
  x, y, z = v

  nline = Point(pitch, 2π * c, 0.)
  pline = Point(nline[2], -nline[1], 0.)
  repeat = nline[1] * nline[2]

  pc = Point(v[1], c * atan(v[2], v[3]), 0.)
  pp = Point(dot(pc, pline), dot(pc, nline), 0.)

  pp = Point(round(pp[1] / repeat) * repeat, pp[2], pp[3])

  # qc = Point(nline * pp, y + pline * pp[1])
  qc = (nline * pp[2] + pline * pp[1]) / dot(nline, nline)
  qc = Point(qc[1], qc[2] / c, qc[3])
  q = Point(qc[1], sin(qc[2]) * c, cos(qc[2]) * c)
  d = norm(v - q) - a

  return max(
    -x + bottom, x - height - bottom,
    d
  )
end

function sdf_attempt_at_z(g::Helix, v)
  a, c, height, pitch, bottom = g.a, g.c, g.height, g.pitch, g.bottom
  x, y, z = v

  nline = Point(0., 2π * c, pitch)
  pline = Point(0., -nline[3], nline[2])
  repeat = nline[3] * nline[2]

  pc = Point(0., c * atan(v[2], v[3]), v[1])
  pp = Point(0., dot(pc, pline), dot(pc, nline))

  pp = Point(pp[1], pp[2], round(pp[3] / repeat) * repeat)

  qc = (nline * pp[2] + pline * pp[3]) / dot(nline, nline)
  qc = Point(qc[1], qc[2] / c, qc[3])
  q = Point(cos(qc[2]) * c, sin(qc[2]) * c, qc[3])
  d = norm(v - q) - a
  return max(
    -z + bottom, z - height - bottom,
    d
  )
end