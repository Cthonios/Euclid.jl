module GUIExt

using GeometryBasics
using Euclid
using Makie

function Makie.mesh(g::Euclid.AbstractPrimitive)
  m = Euclid.mesh(g)
  s = Scene(; camera = cam3d!)
  Makie.mesh!(s, coordinates(m), faces(m))
  center!(s)
  s
end

end # module
