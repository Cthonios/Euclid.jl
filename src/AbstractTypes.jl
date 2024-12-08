"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
abstract type AbstractPrimitive{T, N} end
"""
"""
Base.eltype(::AbstractPrimitive{T, N}) where {T, N} = T
"""
"""
Base.ndims(::AbstractPrimitive{T, N}) where {T, N} = N

function boundingbox(::AbstractPrimitive)
  throw(ErrorException("boundingbox must be implemented"))
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
abstract type AbstractGeometricPrimitive{T, N} <: AbstractPrimitive{T, N} end
AbstractTrees.children(::AbstractGeometricPrimitive) = ()

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
abstract type AbstractAffinePrimitive{
  T, N,
  M, MInv,
  P <: AbstractPrimitive{T, N}
} <: AbstractPrimitive{T, N} end
AbstractTrees.children(g::AbstractAffinePrimitive) = (g.primitive,)

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
abstract type AbstractBooleanPrimitive{T, N, A, B} <: AbstractPrimitive{T, N} end
left(g::AbstractBooleanPrimitive) = g.left
right(g::AbstractBooleanPrimitive) = g.right
AbstractTrees.children(g::AbstractBooleanPrimitive) = (g.left, g.right)

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
abstract type AbstractStaticBooleanPrimitive{
  T, N, 
  A <: AbstractPrimitive{T, N}, 
  B <: AbstractPrimitive{T, N}
} <: AbstractBooleanPrimitive{T, N, A, B} end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
abstract type AbstractDynamicBooleanPrimitive{
  T, N, 
  A <: AbstractPrimitive{T, N}, 
  B <: AbstractArray{<:AbstractPrimitive{T, N}, 1}
} <: AbstractBooleanPrimitive{T, N, A, B} end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
const Direction{T} = SVector{3, T} where T

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
const Point{T} = SVector{3, T} where T

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct AffineTransformation{T}
  A::SMatrix{3, 3, T, 9}
  c::SVector{3, T}
end

function (transform::AffineTransformation)(x::Point)
  return transform.A * x + transform.c
end

function invert(transform::AffineTransformation)
  # correct just trying other things
  # return inv(transform.A) * (x - transform.c)
  inv_A = inv(transform.A)
  inv_c = -inv_A * transform.c
  return AffineTransformation(inv_A, inv_c)
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct Axis{T}
  location::Point{T}
  axis::SVector{3, T}
  ref_direction::Direction{T}
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct Plane{T}
  axis::Axis{T}
end

# Serde stuff
function struct_to_dict(g::AbstractPrimitive)
  G = typeof(g)
  parameters = Dict(fieldnames(G) .=> getfield.(Ref(g), fieldnames(G)))
  return Dict{String, Any}(
    "type" => G.name.name,
    "parameters" => parameters
  )
end

# TODO need to modify this to hold names of rotations maybe
function struct_to_dict(g::AbstractAffinePrimitive)
  d_ret = Dict{String, Any}(
    "type" => String(typeof(g).name.name),
    "parameters" => Dict{String, Any}(
      "primitive" => struct_to_dict(g.primitive),
      # "transform" => Serde.parse_json(Serde.to_json(g.transform))
      "transform" => Dict{String, Any}(
        "A" => vec(g.transform.A),
        "c" => vec(g.transform.c)
      )
    )
  )
  return d_ret
end

function struct_to_dict(g::AbstractBooleanPrimitive)
  d_ret = Dict{String, Any}(
    "type" => String(typeof(g).name.name),
    "parameters" => Dict{String, Any}(
      "left" => struct_to_dict(left(g)),
      "right" => struct_to_dict(right(g))
    )
  )
  return d_ret
end

function Serde.to_json(g::AbstractPrimitive)
  Serde.to_json(struct_to_dict(g))
end

function Serde.to_pretty_json(g::AbstractPrimitive)
  Serde.to_pretty_json(struct_to_dict(g))
end

# TODO make work with serde
function dict_to_struct(dict)
  @assert "type" in keys(dict)
  @assert "parameters" in keys(dict)

  type = eval(Symbol(dict["type"]))

  if type <: AbstractAffinePrimitive
    primitive = dict_to_struct(dict["parameters"]["primitive"])
    A = SMatrix{3, 3, Float64, 9}(dict["parameters"]["transform"]["A"])
    c = SVector{3, Float64}(dict["parameters"]["transform"]["c"])
    transform = AffineTransformation(A, c)
    return type(transform, invert(transform), primitive)
  elseif type <: AbstractBooleanPrimitive
    l = dict_to_struct(dict["parameters"]["left"])
    r = dict_to_struct(dict["parameters"]["right"])
    return type(l, r)
  elseif type <: AbstractGeometricPrimitive
    return Serde.deser(type, dict["parameters"])
  else
    throw(ErrorException("Unsupported type encounted in loading file"))
  end
end

function load_json(file::String)
  dict = Serde.parse_json(read(file))
  dict_to_struct(dict)
end
