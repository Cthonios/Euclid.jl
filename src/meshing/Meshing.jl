struct Mesh{T, N, A <: AbstractArray{T, 3}} <: AbstractPrimitive{T, N}
  n::Int
  sdf_arr::A
end

function Mesh(N)
  samples = (N, N, N)
  # ranges = 
  sdf_arr = Array{Float64, 3}(undef, samples)
  return Mesh{Float64, 3, typeof(sdf_arr)}(N, sdf_arr)
end

function updatesdf!(mesh::Mesh, g::AbstractPrimitive)
  samples = (mesh.n, mesh.n, mesh.n)
  bb = boundingbox(g)
  # ranges = range.(minimum(bb), maximum(bb))
  ranges = range.(bb.min, bb.max)
  # ranges = range.(bb.min - 0.5 * bb.min, bb.max + 0.5 * bb.max)
  xp = LinRange(first(ranges[1]), last(ranges[1]), samples[1])
  yp = LinRange(first(ranges[2]), last(ranges[2]), samples[2])
  zp = LinRange(first(ranges[3]), last(ranges[3]), samples[3])
  Threads.@threads for x in eachindex(xp)
    # @info "$x / $(length(xp))"
    for y in eachindex(yp)
      for z in eachindex(zp)
        mesh.sdf_arr[x, y, z] = sdf(g, Point(xp[x], yp[y], zp[z]))
      end
    end
  end
  return nothing
end

function updatesdf_maybe!(mesh::Mesh, gs)
  samples = (mesh.n, mesh.n, mesh.n)
  bbs = boundingbox.(gs)
  # ranges = range.(minimum(bb), maximum(bb))
  bb_min = minimum(map(x -> x.min, bbs))
  bb_max = maximum(map(x -> x.max, bbs))
  ranges = range.(bb_min, bb_max)
  # ranges = range.(bb.min - 0.5 * bb.min, bb.max + 0.5 * bb.max)
  xp = LinRange(first(ranges[1]), last(ranges[1]), samples[1])
  yp = LinRange(first(ranges[2]), last(ranges[2]), samples[2])
  zp = LinRange(first(ranges[3]), last(ranges[3]), samples[3])
  for g in gs
    if g === nothing
      continue
    end
    Threads.@threads for x in eachindex(xp)
      # @info "$x / $(length(xp))"
      for y in eachindex(yp)
        for z in eachindex(zp)
          mesh.sdf_arr[x, y, z] = sdf(g, Point(xp[x], yp[y], zp[z]))
        end
      end
    end
  end
  return nothing
end

function mesh(mesh::Mesh, g::AbstractPrimitive)
  updatesdf!(mesh, g)
  bb = boundingbox(g)
  samples = (mesh.n, mesh.n, mesh.n)
  # ranges = range.(minimum(bb), maximum(bb))
  # ranges = range.(bb.min .- 0.5, bb.max .+ 0.5)
  ranges = range.(bb.min, bb.max)

# function mesh(mesh::Mesh, gs)
#   updatesdf!(mesh, gs)
#   bbs = boundingbox.(gs)
#   samples = (mesh.n, mesh.n, mesh.n)
#   bb_min = minimum(map(x -> x.min, bbs))
#   bb_max = maximum(map(x -> x.max, bbs))
#   ranges = range.(bb_min .- 0.5, bb_max .+ 0.5)

  xp = LinRange(first(ranges[1]), last(ranges[1]), samples[1])
  yp = LinRange(first(ranges[2]), last(ranges[2]), samples[2])
  zp = LinRange(first(ranges[3]), last(ranges[3]), samples[3])
  vts, fcs = isosurface(mesh.sdf_arr, MarchingCubes(), xp, yp, zp)
  mc = GeometryBasics.Mesh(GeometryBasics.Point3f.(vts), GeometryBasics.TriangleFace.(fcs))
  return mc
end

mesh(g::AbstractPrimitive) = mesh(Mesh(128), g)
# mesh(gs::Vector{<:AbstractPrimitive}) = mesh(Mesh(128), gs)


function getcoordinatesize(mesh::Mesh, g::AbstractPrimitive)
  updatesdf!(mesh, g)
  T = Float64
  method = MarchingCubes()
  nx, ny, nz = size(mesh.sdf_arr)
  bb = boundingbox(g)
  samples = (mesh.n, mesh.n, mesh.n)
  ranges = range.(minimum(bb), maximum(bb))
  xp = X = LinRange(first(ranges[1]), last(ranges[1]), samples[1])
  yp = Y = LinRange(first(ranges[2]), last(ranges[2]), samples[2])
  zp = Z = LinRange(first(ranges[3]), last(ranges[3]), samples[3])

  n_vertices = 0

  @inbounds for xi = 1:nx-1, yi = 1:ny-1, zi = 1:nz-1

    iso_vals = (
      mesh.sdf_arr[xi, yi, zi],
      mesh.sdf_arr[xi+1, yi, zi],
      mesh.sdf_arr[xi+1, yi+1, zi],
      mesh.sdf_arr[xi, yi+1, zi],
      mesh.sdf_arr[xi, yi, zi+1],
      mesh.sdf_arr[xi+1, yi, zi+1],
      mesh.sdf_arr[xi+1, yi+1, zi+1],
      mesh.sdf_arr[xi, yi+1, zi+1]
    )

    #Determine the index into the edge table which
    #tells us which vertices are inside of the surface
    cubeindex = _get_cubeindex(iso_vals, method.iso)

    # Cube is entirely in/out of the surface
    _no_triangles(cubeindex) && continue

    # points = mc_vert_points(xi, yi, zi, xp, yp, zp)

    # process the voxel
    # process_mc_voxel!(vts, fcs, cubeindex, points, method.iso, iso_vals)
    # @show "here"
    vert_to_add = _mc_verts[cubeindex]
    for i = 1:12
      vt = vert_to_add[i]
      iszero(vt) && break
      n_vertices = n_vertices + 1
    end
  end
  return 3, n_vertices
end

struct ADMesh{M, A}
  mesh::M
  coords::A
end

function ADMesh(g::AbstractPrimitive)
  mesh = Mesh(128)
  coords = zeros(Float64, getcoordinatesize(mesh, g))
  return ADMesh(mesh, coords)
end

function mesh!(mesh::ADMesh, g::AbstractPrimitive)
  T = Float64
  method = MarchingCubes()
  updatesdf!(mesh.mesh, g)
  bb = boundingbox(g)
  samples = (mesh.mesh.n, mesh.mesh.n, mesh.mesh.n)
  ranges = range.(minimum(bb), maximum(bb))
  X = xp = LinRange(first(ranges[1]), last(ranges[1]), samples[1])
  Y = yp = LinRange(first(ranges[2]), last(ranges[2]), samples[2])
  Z = zp = LinRange(first(ranges[3]), last(ranges[3]), samples[3])

  # stuff from isosurface in Meshing.jl
  nx, ny, nz = size(mesh.mesh.sdf_arr)

  # find widest type

  n = 1
  for xi = 1:nx-1, yi = 1:ny-1, zi = 1:nz-1

    iso_vals = (
      mesh.mesh.sdf_arr[xi, yi, zi],
      mesh.mesh.sdf_arr[xi+1, yi, zi],
      mesh.mesh.sdf_arr[xi+1, yi+1, zi],
      mesh.mesh.sdf_arr[xi, yi+1, zi],
      mesh.mesh.sdf_arr[xi, yi, zi+1],
      mesh.mesh.sdf_arr[xi+1, yi, zi+1],
      mesh.mesh.sdf_arr[xi+1, yi+1, zi+1],
      mesh.mesh.sdf_arr[xi, yi+1, zi+1]
    )

    #Determine the index into the edge table which
    #tells us which vertices are inside of the surface
    cubeindex = _get_cubeindex(iso_vals, method.iso)

    # Cube is entirely in/out of the surface
    _no_triangles(cubeindex) && continue

    points = mc_vert_points(xi, yi, zi, xp, yp, zp)

    # from process_mc_voxel but adapted
    vert_to_add = _mc_verts[cubeindex]
    for i = 1:12
      vt = vert_to_add[i]
      iszero(vt) && break
      ed = _mc_edge_list[vt]
      temp = vertex_interp(method.iso, points[ed[1]], points[ed[2]], iso_vals[ed[1]], iso_vals[ed[2]])
      mesh.coords[:, n] .= temp
      n = n + 1
    end
  end
end

include("Common.jl")
include("MarchingCubes.jl")
