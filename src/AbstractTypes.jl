abstract type AbstractPrimitive{T, N} end
Base.eltype(::AbstractPrimitive{T, N}) where {T, N} = T
Base.ndims(::AbstractPrimitive{T, N}) where {T, N} = N

function boundingbox(::AbstractPrimitive)
  throw(ErrorException("boundingbox must be implemented"))
end

abstract type AbstractGeometricPrimitive{T, N} <: AbstractPrimitive{T, N} end
abstract type AbstractAffinePrimitive{
  T, N,
  M, MInv,
  P <: AbstractPrimitive{T, N}
} <: AbstractPrimitive{T, N} end
abstract type AbstractBooleanPrimitive{
  T, N, 
  A <: AbstractPrimitive{T, N}, 
  B <: AbstractPrimitive{T, N}
} <: AbstractPrimitive{T, N} end
left(g::AbstractBooleanPrimitive) = g.left
right(g::AbstractBooleanPrimitive) = g.right

const Point{T} = SVector{3, T} where T

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
      "transform" => Serde.parse_json(Serde.to_json(g.transform))
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
    @show primitive
    @show type
    transform = Serde.deser(CoordinateTransformations.LinearMap, dict["parameters"]["transform"])
    @show transform
    return type(transform, inv(transform), primitive)
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
