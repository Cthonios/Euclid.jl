function GeometryBasics.mesh(
  primitives::AbstractPrimitive...;
  samples=(128,128,128),
  algorithm=MarchingCubes(),
  T = Float64
)

  meshes = Vector{GeometryBasics.Mesh}(undef, length(primitives))
  sdf_arr = Array{T}(undef, samples)
  # sdf_arr = Array{eltype(primitives)}(undef, samples)

  for i in eachindex(primitives)
    b = bounding_box(primitives[i])
    rng = range.(b.origin, b.origin.+ b.widths)

    # @info "Sampling SDF"
    xp = LinRange(first(rng[1]), last(rng[1]), samples[1])
    yp = LinRange(first(rng[2]), last(rng[2]), samples[2])
    zp = LinRange(first(rng[3]), last(rng[3]), samples[3])        
    sdf(v) = frep(primitives[i], SVector(v...))
    sdf_normal(v) = ForwardDiff.gradient(sdf, SVector(v...))

    # Threads.@threads for x in eachindex(xp)
    for x in eachindex(xp)
      for y in eachindex(yp), z in eachindex(zp)
        sdf_arr[x,y,z] = sdf((xp[x],yp[y],zp[z]))
      end
    end

    # @info "generating mesh"
    vts, fcs = isosurface(sdf_arr, algorithm, rng[1], rng[2], rng[3])
    # @info "remapping data types"
    _points = map(GeometryBasics.Point, vts)
    _faces = map(v -> GeometryBasics.TriangleFace{GeometryBasics.OneIndex}(v), fcs)
    # @info "evaluating normals"
    # normals = map(v -> GeometryBasics.Vec3(sdf_normal(v)), vts) 
    normals = map(v -> sdf_normal(v), vts)
    # @info "remapping mesh"
    meshes[i] = GeometryBasics.Mesh(GeometryBasics.meta(_points; normals=normals), _faces)
  end
  return merge(meshes)
end

# function piped_mesh(m::AbstractMesh,r)
#   c = nothing
#   for f in m.faces
#   v1 = m.vertices[f[1]-O]
#   v2 = m.vertices[f[2]-O]
#   v3 = m.vertices[f[3]-O]
#   c = CSGUnion(c, Piping(r, Point{3,Float64}[v1, v2, v3]))
#   end
#   c
# end