const MAXPARAMS = 10
const Parameters = SVector{MAXPARAMS, T} where T
const PrimitiveID = Int64

function parameters(params_in::Vararg{T, N}) where {T, N}
  N > MAXPARAMS && @assert false "Too  many parameters"
  params = (params_in..., -Inf * ones(SVector{MAXPARAMS - N, T})...)
  return params
end

struct Geometry{T}
  affine::AffineTransformation{T}
  affine_inv::AffineTransformation{T}
  dimension::Int
  primitive_id::PrimitiveID
  parameters::Parameters{T}
end

function Geometry{T}() where T
  A = one(SMatrix{3, 3, T, 9})
  c = zeros(SVector{3, T})
  affine = AffineTransformation(A, c)
  affine_inv = invert(affine)
  params = -Inf * ones(Parameters)
  return Geometry{T}(affine, affine_inv, -1, 0, params)
end

function Geometry(dim, id, params)
  T = eltype(params[1])
  A = one(SMatrix{3, 3, T, 9})
  c = zeros(SVector{3, T})
  affine = AffineTransformation(A, c)
  affine_inv = invert(affine)
  return Geometry{T}(affine, affine_inv, dim, id, params)
end

Base.eltype(::Geometry{T}) where T = T

function rotate(g::Geometry{T}, axis, angle) where T
  if axis == :x
    A = SMatrix{3, 3, eltype(g), 9}(
      1., 0., 0., 0., 
      cos(angle), sin(angle), 0., 
      -sin(angle), cos(angle)
    )
  elseif axis == :y
    A = SMatrix{3, 3, eltype(g), 9}(
      cos(angle), 0., -sin(angle),
      0., 1., 0.,
      sin(angle), 0., cos(angle)
    )
  elseif axis == :z
    A = SMatrix{3, 3, eltype(g), 9}(
      cos(angle), sin(angle), 0.,
      -sin(angle), cos(angle), 0.,
      0., 0., 1.
    )
  else
    @assert false
  end
  affine = AffineTransformation(A, zeros(SVector{3, eltype(g)}))
  affine_inv = invert(affine)
  g = Geometry{T}(affine, affine_inv, g.dimension, g.primitive_id, g.parameters)
end

function translate(g::Geometry{T}, x, y, z) where T
  A = one(SMatrix{3, 3, T, 9})
  c = SVector{3, T}(x, y, z)
  affine = AffineTransformation(A, c)
  affine_inv = invert(affine)
  return Geometry{T}(affine, affine_inv, g.dimension, g.primitive_id, g.parameters)
end

# dummy
const NOTHING = 0

# 0D primitives

# 1D primitives

# 2D primitives

# 3D primitives
const SPHERE = 1

# Booleans
const DIFFERENCE   = 2
const INTERSECTION = 3
const UNION        = 4

function boundingbox(g::Geometry)
  if g.primitive_id == SPHERE
    bb = _boundingbox_sphere(g)
  else
    throw(ErrorException("Unsupported primitive"))
  end
  cs = corners(bb)
  cs = map(x -> g.affine(x), cs)
  xs = map(x -> x[1], cs)
  ys = map(x -> x[2], cs)
  zs = map(x -> x[3], cs)
  return BoundingBox(
    Point(minimum(xs), minimum(ys), minimum(zs)),
    Point(maximum(xs), maximum(ys), maximum(zs))
  )
end

function sdf(g::Geometry, v::Point)
  v = g.affine_inv(v)
  if g.primitive_id == SPHERE
    return _sdf_sphere(g, v)
  else
    throw(ErrorException("Unsupported primitive"))
  end
end

# csg tree stuff
# const CSGNode = Union{Nothing, Geometry{T}} where T
const CSGNode = Geometry{T} where T

struct CSGTree{T}
  geometry::CSGNode{T}
  left::Union{Nothing, CSGTree{T}}
  # right::Union{Nothing, CSGTree{T}}
  right::Union{Nothing, <:AbstractArray{<:CSGTree{T}, 1}}
end

function CSGTree(g::CSGNode{T}) where T
  return CSGTree{T}(g, nothing, nothing)
end

function CSGTree(g::CSGNode{T}, left, right) where T
  return CSGTree{T}(g, left, right)
end

left(t::CSGTree{T}) where T = t.left
right(t::CSGTree{T}) where T = t.right

function boundingbox(t::CSGTree)
  if t.geometry.primitive_id == UNION
    # return union(boundingbox(left(t)), boundingbox(right(t)))
    return _boundingbox_union(t)
  else
    return boundingbox(t.geometry)
  end
end

function sdf(t::CSGTree, v)
  if t.geometry.primitive_id == UNION
    return _sdf_union(t, v)
  else
    return sdf(t.geometry, v)
  end
end

# # function CSGTree(g::CSGNode{T}) where T
# #   lef
# #   return CSGTree{T}(g, nothing, nothing)
# # end
# const Children = Tuple{
#   Union{Nothing, CSGTree{T}}, 
#   Union{Nothing, CSGTree{T}}
# } where T

# AbstractTrees.children(tree::CSGTree) = (tree.left, tree.right)

