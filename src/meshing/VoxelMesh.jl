function voxel_mesh(file_name::String, g::AbstractPrimitive, n_samples = 64)
  spns = Array{Bool, 3}(undef, n_samples, n_samples, n_samples)

  bb = boundingbox(g)
  xs = LinRange(bb.min[1], bb.max[1], n_samples)
  ys = LinRange(bb.min[2], bb.max[2], n_samples)
  zs = LinRange(bb.min[3], bb.max[3], n_samples)
  Threads.@threads for i in 1:n_samples
    for j in 1:n_samples
      for k in 1:n_samples
        v = Point(xs[i], ys[j], zs[k])
        if sdf(g, v) <= 0.
          spns[i, j, k] = true
        else
          spns[i, j, k] = false
        end
      end
    end
  end
  spns = vec(spns)
  spns = convert(Vector{Int8}, spns)
  # display(spns)
  # write(file_name, spns)
  open("test.spn", "w") do f
    for i in axes(spns, 1)
      write(f, "$(spns[i])\n")
    end
  end

  bb = boundingbox(g)

  run(
    `automesh mesh
    --input test.spn
    --output test.inp
    --nelx $n_samples
    --nely $n_samples
    --nelz $n_samples
    --xscale $(bb.max[1] - bb.min[1])
    --yscale $(bb.max[2] - bb.min[2])
    --zscale $(bb.max[3] - bb.min[3])
  `)
  run(
    `automesh convert
    --input test.inp
    --output test.exo
    `
  )
end