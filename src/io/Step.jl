struct STEPFileDescription
  description::String
  version::String
  schema::String
end

struct STEPHeader
  description::STEPFileDescription
  name::String
  schema::String
end

struct STEPFileData{H, D}
  header::H
  data::D
end

# TODO need a method to strip number, name, and parameters
function parse_section(lines, sec_name, index)
  sec_lines = String[]
  line = lines[index]
  while !contains(line, sec_name)
    index = index + 1
    line = lines[index]
  end

  while !contains(line, "ENDSEC")
    index = index + 1
    line = lines[index]
    if !contains(line, "ENDSEC")
      push!(sec_lines, line)
    end
  end
  return sec_lines, index
end

function parse_step_header_entity(line, key)
  line = strip(split(line, key)[2], ['(', ')', ';'])
  return line
end

function parse_step_data_entity(line, key)
  words = split(line, key)
  words = strip.(words, ['(', ';'])[2]
  words = split(words, ",")
  words = strip.(words, ['('])
  words = strip.(words, [')'])
  name = words[1]
  params = words[2:end]
  return name, params, key
end

function parse_data_lines(lines; verbose=false)
  geometry_names = Dict{Int, String}()
  geometries = Dict{Int, Any}()

  for line in lines
    words = split(line, "=")
    g_num = parse(Int, strip(words[1], '#'))
    geometry_names[g_num] = ""
    geometries[g_num] = nothing
  end

  # need to do 3 passes since things aren't
  # guaranteed to be in order
  num_warnings = 0
  for n in 1:9
    for line in lines
      words = split(line, "=")
      g_num = parse(Int, strip(words[1], '#'))
      entity = words[2]
      if contains(line, "ADVANCED_FACE")
        name, params, key = parse_step_data_entity(entity, "ADVANCED_FACE")
        bounds_ids = strip(params[1], ['(', ')'])
        bounds_ids = parse.(Int, strip.(bounds_ids, '#'))
        face = parse(Int, strip(params[2], '#'))
        b = strip(params[3], '.')
        bounds = [geometries[x] for x in bounds_ids]
        face = geometries[face]
        if b == "T"
          b = true
        else
          b = false
        end
        if n > 8
          g = AdvancedFace(bounds, face, b)
        else
          g = nothing
        end
      elseif contains(line, "APPLICATION_CONTEXT")
        name, params, key = parse_step_data_entity(entity, "APPLICATION_CONTEXT")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "APPLICATION_PROTOCOL_DEFINITION")
        name, params, key = parse_step_data_entity(entity, "APPLICATION_PROTOCOL_DEFINITION")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "AXIS2_PLACEMENT_3D")
        name, params, key = parse_step_data_entity(entity, "AXIS2_PLACEMENT_3D")
        ids = parse.(Int, strip.(params, '#'))
        if n > 2
          g = Axis(geometries[ids[1]], geometries[ids[2]], geometries[ids[3]])
        else
          g = nothing
        end
      elseif contains(line, "CARTESIAN_POINT")
        name, params, key = parse_step_data_entity(entity, "CARTESIAN_POINT")
        g = Point(parse.(Float64, params))
      elseif contains(line, "CIRCLE")
        name, params, key = parse_step_data_entity(entity, "CIRCLE")
        id = parse(Int, strip(params[1], '#'))
        n == 1 && @warn "Currently not using axis id. If this circle lies outside of the xz plane then errors will occur"
        radius = parse(Float64, params[2])
        g = Circle(radius)
      elseif contains(line, "CYLINDRICAL_SURFACE")
        name, params, key = parse_step_data_entity(entity, "CYLINDRICAL_SURFACE")
        id = parse(Int, strip(params[1], '#'))
        radius = parse(Float64, params[2])
        if n > 4
          g = CylindricalSurface(geometries[id], radius)
        else
          g = nothing
        end
      elseif contains(line, "DIMENSIONAL_EXPONENTS")
        name, params, key = parse_step_data_entity(entity, "CYLINDRICAL_SURFACE")
        exponents = parse.(Float64, params)
        # TODO what to do here?
        g = params
      elseif contains(line, "DIRECTION")
        name, params, key = parse_step_data_entity(entity, "DIRECTION")
        g = Direction(parse.(Float64, params))
      elseif contains(line, "EDGE_CURVE")
        name, params, key = parse_step_data_entity(entity, "EDGE_CURVE")
        v1 = parse(Int, strip(params[1], '#'))
        v2 = parse(Int, strip(params[2], '#'))
        c = parse(Int, strip(params[3], '#'))
        b = strip(params[4], '.')
        if b == "T"
          b = true
        else
          b = false
        end

        if n > 4
          g = EdgeCurve(geometries[v1], geometries[v2], geometries[c], b)
        else
          g = nothing
        end 
      elseif contains(line, "EDGE_LOOP")
        name, params, key = parse_step_data_entity(entity, "EDGE_LOOP")
        ids = parse.(Int, strip.(params, '#'))
        edges = [geometries[x] for x in ids]
        if n > 6
          g = CurveLoop(edges)
        else
          g = nothing
        end
      elseif contains(line, "FACE_OUTER_BOUND")
        name, params, key = parse_step_data_entity(entity, "FACE_OUTER_BOUND")
        id = parse(Int, strip(params[1], '#'))
        b = strip(params[2], '.')
        if b == "T"
          b = true
        else
          b = false
        end
        if n > 7
          g = FaceOuterBound(geometries[id], b)
        else
          g = nothing
        end
      elseif contains(line, "LENGTH_MEASURE_WITH_UNIT")
        name, params, key = parse_step_data_entity(entity, "LENGTH_MEASURE_WITH_UNIT")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "LINE")
        name, params, key = parse_step_data_entity(entity, "LINE")
        p1 = parse(Int, strip(params[1], '#'))
        p2 = parse(Int, strip(params[2], '#'))
        if n > 3
          g = Line(geometries[p1], geometries[p2])
        else
          g = nothing
        end
      elseif contains(line, "ORIENTED_EDGE")
        name, params, key = parse_step_data_entity(entity, "ORIENTED_EDGE")
        e = parse(Int, strip(params[3], '#'))
        b = strip(params[4], '.')
        if b == "T"
          b = true
        else
          b = false
        end

        if n > 5
          g = OrientedEdge(geometries[e], b)
        else
          g = nothing
        end
      elseif contains(line, "PLANE") && !contains(line, "_ANGLE_UNIT")
        name, params, key = parse_step_data_entity(entity, "PLANE")
        id = parse(Int, strip(params[1], '#'))
        if n > 3
          g = Plane(geometries[id])
        else
          g = nothing
        end
      elseif contains(line, "PRODUCT_CATEGORY")
        name, params, key = parse_step_data_entity(entity, "PRODUCT_CATEGORY")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "PRODUCT_CONTEXT")
        name, params, key = parse_step_data_entity(entity, "PRODUCT_CONTEXT")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "PRODUCT_DEFINITION_CONTEXT")
        name, params, key = parse_step_data_entity(entity, "PRODUCT_DEFINITION_CONTEXT")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "PRODUCT_DEFINITION_FORMATION_WITH_SPECIFIED_SOURCE")
        name, params, key = parse_step_data_entity(entity, "PRODUCT_DEFINITION_FORMATION_WITH_SPECIFIED_SOURCE")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "PRODUCT_DEFINITION_SHAPE")
        name, params, key = parse_step_data_entity(entity, "PRODUCT_DEFINITION_CONTEXT")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "PRODUCT_DEFINITION")
        name, params, key = parse_step_data_entity(entity, "PRODUCT_DEFINITION")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "PRODUCT")
        name, params, key = parse_step_data_entity(entity, "PRODUCT")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "SHAPE_DEFINITION_REPRESENTATION")
        name, params, key = parse_step_data_entity(entity, "SHAPE_DEFINITION_REPRESENTATION")
        ids = parse.(Int, strip.(params, '#'))
        # TODO figure out what to do here
        g = ids
      elseif contains(line, "UNCERTAINTY_MEASURE_WITH_UNIT")
        name, params, key = parse_step_data_entity(entity, "UNCERTAINTY_MEASURE_WITH_UNIT")
        # TODO figure out what to do here
        g = params
      elseif contains(line, "VECTOR")
        name, params, key = parse_step_data_entity(entity, "VECTOR")
        scale = parse(Float64, params[2])
        if n > 2
          g = scale * geometries[parse(Int, strip(params[1], '#'))]
        else
          g = nothing
        end
      elseif contains(line, "VERTEX_POINT")
        name, params, key = parse_step_data_entity(entity, "VERTEX_POINT")
        @assert length(params) == 1
        g = geometries[parse(Int, strip(params[1], '#'))]
      else
        name = ""
        g = nothing
        params = []
        if n == 1
          @warn line
          num_warnings = num_warnings + 1
        end
      end
    

      params_str = map(x -> "$x ,", params)

      if g !== nothing && verbose
        @info "Parsed $key with name $name and parameters $(params_str...) on pass $n"
      end

      geometry_names[g_num] = name
      geometries[g_num] = g
    end
  end

  if num_warnings > 0
    @warn "Encountered $(num_warnings) warnings"
  else
    @info "Encountered $(num_warnings) warnings"
  end
  return geometry_names, geometries
end

function parse_header_line(line)
  if contains(line, "FILE_DESCRIPTION")
    words = parse_step_header_entity(line, "FILE_DESCRIPTION")
  elseif contains(line, "FILE_NAME")
    words = parse_step_header_entity(line, "FILE_NAME")
  elseif contains(line, "FILE_SCHEMA")
    words = parse_step_header_entity(line, "FILE_SCHEMA")
  else
    @assert false "Shouldn't happen"
  end
  return words
end

function load_step_file(file_name)
  open(file_name, "r") do f
    lines = readlines(f)
    @assert contains(lines[1], "ISO")

    index = 2
    header_lines, index = parse_section(lines, "HEADER", index)
    data_lines, index = parse_section(lines, "DATA", index)
    header = String[]
    for line in header_lines
      words = parse_header_line(line)
      # TODO fix this up
      push!(header, mapreduce(x -> x, *, words))
    end

    geometry_names, geometries = parse_data_lines(data_lines)
  end
end

function create_geometry_from_step(file_name)
  step = load_step_file(file_name)

  geometries = Dict{Int, Any}()

  g = nothing
  for line in step.data
    words = split(line, "=")
    g_num = parse(Int, split(words[1], "#")[2])
    g_def = split(words[2], ";")[1]

    if contains(g_def, "CARTESIAN_POINT")
      params = split(g_def, "CARTESIAN_POINT(")[2]
      params = strip(params, ['\'', ',', '(', ')'])
      params = parse.(Float64, split(params, ","))
      g = Point(params...)
    elseif contains(g_def, "EDGE_CURVE")
      params = parse.(Int, strip.(split(strip(split(g_def, "EDGE_CURVE(")[2], ['\'', ')', ',']), ","), '#'))
      lines = get.((geometries,), params, -1)
      lines = NTuple{length(lines)}(lines)
      @assert all(x -> x != -1, lines)
      g = LineLoop(lines)
    elseif contains(g_def, "FACE_PLANAR")
      @show "here"
      @show g_def
      params = parse(Int, strip(split(g_def, "FACE_PLANAR")[2], ['(', '\'', ',', ')', '#']))
      g = geometries[params]
    elseif contains(g_def, "LINE")
      params = strip(split(g_def, "LINE(")[2], ['\'', ',', ')'])
      params = parse.(Int, strip.(split(params, ","), '#'))
      g = Line(geometries[params[1]], geometries[params[2]])
    else
      @assert false "unsupport op with line $line"
    end

    geometries[g_num] = g
    # if contains(line, "CARTESIAN_POINT")
    #   @show "point"
    #   @show line
    #   words = split(line, "CARTESIAN_POINT(")
    #   @show words

    #   # g_num = split(split(words[2], "#")[1], "=")
    #   # @show g_num
    # end
  end
  geometries[maximum(keys(geometries))]
end
