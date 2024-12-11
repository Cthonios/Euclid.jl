module MakieExt

using GeometryBasics
using Euclid
using Makie

function Makie.mesh!(s, g::Euclid.AbstractPrimitive)
  m = Euclid.mesh(g)
  Makie.mesh!(s, coordinates(m), faces(m))
  center!(s)
end

function Makie.mesh(g::Euclid.AbstractPrimitive)
  # m = Euclid.mesh(g)
  s = Scene(; camera = cam3d!)
  # Makie.mesh!(s, coordinates(m), faces(m))
  # center!(s)
  Makie.mesh!(s, g)
  s
end

end # module
