function default_input(type)
  if type <: Number
    return "1."
  elseif type <: SArray
    return "0. 0. 0."
  else
    @assert false
  end
end

function parse_input(type, input)
  if type <: Number
    return parse(type, input)
  elseif type <: SArray
    words = split(input, " ")
    ret = SVector{3, Float64}(parse.(Float64, words)...)
    return ret
  else  
    @assert false "Failed on type $type"
  end
end

function primitive_pallet(s)
  pallet_layout = GtkBox(:h)
  primitives_0d = GtkBox(:v)
  primitives_1d = GtkBox(:v)
  primitives_2d = GtkBox(:v)
  primitives_3d = GtkBox(:v)
  affines = GtkBox(:v)
  booleans = GtkBox(:v)

  geometry_names = GtkBox(:v)
  geometries = []

  push!(primitives_0d, GtkLabel("0D Shapes"))
  push!(primitives_1d, GtkLabel("1D Shapes"))
  push!(primitives_2d, GtkLabel("2D Shapes"))
  push!(primitives_3d, GtkLabel("3D Shapes"))
  push!(affines, GtkLabel("Affines"))
  push!(booleans, GtkLabel("Booleans"))
  push!(geometry_names, GtkLabel("Geometries"))
  
  for type in subtypes(Euclid.AbstractGeometricPrimitive{Float64, 3})
    if type <: Euclid.LinearExtrude
      continue
    end
    button = GtkButton(String(type.name.name))
    push!(primitives_3d, button)

    function add_shape(b)
      params = Vector{Any}(undef, length(fieldnames(type)))

      n_count = 0
      for (n, (param, param_type)) in enumerate(zip(fieldnames(type), fieldtypes(type)))
        default = default_input(param_type)
        input_dialog("$(String(param)) of type $(String(param_type.name.name))", default) do input
          params[n] = parse_input(param_type, input)

          n_count = n_count + 1
          if n_count == length(params)
            params_tup = tuple(params...)
            constructor = Euclid.eval(type.name.name)
            g = constructor(params_tup...)
            push!(geometry_names, GtkLabel("$(typeof(g).name.name)"))
            GLMakie.mesh!(s, g)
            push!(geometries, g)
          end
        end
      end
    end

    signal_connect(add_shape, button, "clicked")
  end

  # affines
  # for op in [:rotate, :translate]
  #   button = GtkButton(String(op))
  #   push!(affines, button)
    
  #   function add_affine(b)
  #     input_dialog("$op: Input a volume id")
  #   end
  # end
  rotate_button = GtkButton("rotate")
  translate_button = GtkButton("translate")
  push!(affines, rotate_button)
  push!(affines, translate_button)
  
  function add_rotate(b)
    input_dialog("Input a volume id to rotate followed by axes that is x, y, or z and an angle", "1") do input
      words = split(input, " ")
      vol_id = parse(Int, words[1])
      # x, y, z = parse.(Float64, words[2:end])
      # axes = parse(Char, words[2])
      axis = words[2]
      angle = π / 180. * parse(Float64, words[3])
      @show vol_id axis angle
      g = rotate(geometries[vol_id], axis, angle)
      push!(geometry_names, GtkLabel("$(typeof(g).name.name)"))
      GLMakie.mesh!(s, g)
      push!(geometries, g)
    end
  end

  function add_translate(b)
    input_dialog("Input a volume id to translate followed by x, y, z", "1") do input
      words = split(input, " ")
      vol_id = parse(Int, words[1])
      x, y, z = parse.(Float64, words[2:end])
      g = translate(geometries[vol_id], x, y, z)
      push!(geometry_names, GtkLabel("$(typeof(g).name.name)"))
      GLMakie.mesh!(s, g)
      push!(geometries, g)
    end
  end

  signal_connect(add_rotate, rotate_button, "clicked")
  signal_connect(add_translate, translate_button, "clicked")

  # booleans
  for op in [:difference, :intersect, :union]
    button = GtkButton(String(op))
    push!(booleans, button)

    function add_boolean(b)
      input_dialog("$op: Input two volume ids seperated by a space", "1 2") do input
        words = parse.(Int, split(input, " "))
        g = eval(op)(geometries[words[1]], geometries[words[2]])
        push!(geometry_names, GtkLabel("$(typeof(g).name.name)"))
        GLMakie.mesh!(s, g)
        push!(geometries, g)
      end
    end

    signal_connect(add_boolean, button, "clicked")
  end

  push!(pallet_layout, primitives_0d)
  push!(pallet_layout, primitives_1d)
  push!(pallet_layout, primitives_2d)
  push!(pallet_layout, primitives_3d)
  push!(pallet_layout, affines)
  push!(pallet_layout, booleans)
  push!(pallet_layout, geometry_names)

  return pallet_layout
end
