struct MapContainer{M, P <: AbstractPrimitive} <: AbstractPrimitive
  map::M
  inv::M
  p::P
end

function bounding_box(m::MapContainer)
  transform(m.map, bounding_box(m.p))
end

# special case where we need to compose transformatations
function bounding_box(m::MapContainer{M, P}) where {M, P <: MapContainer}
  transform(compose(m.map, m.p.map), bounding_box(m.p.p))
end

function frep(p::MapContainer, v)
  frep(p.p, p.inv(v))
end 

function rotate(p::AbstractPrimitive, ang, axis::Vector)
  if !iszero(axis[1])
    r = LinearMap(RotX(ang))
  elseif !iszero(axis[2])
    r = LinearMap(RotY(ang))
  elseif !iszero(axis[3])
    r = LinearMap(RotZ(ang))
  else
    r = LinearMap(RotX(ang)) # default to X? TODO: What does OpenSCAD use?
  end

  return MapContainer(r, inv(r), p)
end

function translate(p::AbstractGeometricPrimitive{T, 2}, x, y) where T
  t = Translation(x, y)
  return MapContainer(t, inv(t), p)
end

function translate(p::AbstractPrimitive, x, y, z)
  t = Translation(x, y, z)
  return MapContainer(t, inv(t), p)
end

# backend for general transformation
function transform(t::AbstractAffineMap, h::HyperRectangle{3,T}) where {T}
  p_1 = t(h.origin)
  p_2 = t(h.widths)
  p_3 = t(SVector(h.origin[1]+h.widths[1],h.origin[2],h.origin[3]))
  p_4 = t(SVector(h.origin[1],h.origin[2]+h.widths[2],h.origin[3]))
  p_5 = t(SVector(h.origin[1],h.origin[2],h.origin[3]+h.widths[3]))
  p_6 = t(SVector(h.origin[1]+h.widths[1],h.origin[2],h.origin[3]+h.widths[3]))
  p_7 = t(SVector(h.origin[1],h.origin[2]+h.widths[2],h.origin[3]+h.widths[3]))
  p_8 = t(SVector(h.origin[1]+h.widths[1],h.origin[2]+h.widths[2],h.origin[3]))
  x_o = min(p_1[1],p_2[1],p_3[1],p_4[1],p_5[1],p_6[1],p_7[1],p_8[1])
  y_o = min(p_1[2],p_2[2],p_3[2],p_4[2],p_5[2],p_6[2],p_7[2],p_8[2])
  z_o = min(p_1[3],p_2[3],p_3[3],p_4[3],p_5[3],p_6[3],p_7[3],p_8[3])
  x_w = max(p_1[1],p_2[1],p_3[1],p_4[1],p_5[1],p_6[1],p_7[1],p_8[1])
  y_w = max(p_1[2],p_2[2],p_3[2],p_4[2],p_5[2],p_6[2],p_7[2],p_8[2])
  z_w = max(p_1[3],p_2[3],p_3[3],p_4[3],p_5[3],p_6[3],p_7[3],p_8[3])
  HyperRectangle(x_o, y_o, z_o, x_w-x_o, y_w-y_o, z_w-z_o)
end

function transform(t::AbstractAffineMap, h::HyperRectangle{2,T}) where {T}
  p_1 = t(h.origin)
  p_2 = t(h.widths)
  p_3 = t(SVector(h.origin[1]+h.widths[1],h.origin[2]))
  p_4 = t(SVector(h.origin[1],h.origin[2]+h.widths[2]))
  x_o = min(p_1[1],p_2[1],p_3[1],p_4[1])
  y_o = min(p_1[2],p_2[2],p_3[2],p_4[2])
  x_w = max(p_1[1],p_2[1],p_3[1],p_4[1])
  y_w = max(p_1[2],p_2[2],p_3[2],p_4[2])
  HyperRectangle(x_o, y_o, x_w-x_o, y_w-y_o)
end
