module GUIExt

import Euclid
import Euclid: difference, rotate, translate
using FileIO
using GeometryBasics
using GLMakie
using Gtk4
using Gtk4Makie
using InteractiveUtils
using StaticArrays

# TODO need some datastructures
# 1. need to hold onto loaded files and stl meshes, etc.
# 2. need a dictionary/list of geometries

# trying something like grasshopper/simulink
include("gui/Designer.jl")
include("gui/IO.jl")
include("gui/Pallet.jl")
include("gui/Viz.jl")

# GUI main stuff below
if isinteractive()
  stop_main_loop()  # g_application_run will run the loop
end

function activate(app)
  # setup viz screen
  screen = viz_screen(app)
  theme = Theme(grid = true)
  s = Scene(; camera = cam3d!, theme = theme)
  display(screen, s)
  g = grid(screen)
  set_gtk_property!(g, :column_homogeneous, true)
  
  # general layout
  layout = GtkBox(:h)

  # file load layout stuff
  file_layout = file_io_layout(s)

  # pallet stuff
  primitive_layout = primitive_pallet(s)

  # add stuff
  push!(layout, file_layout)
  push!(layout, primitive_layout)
  insert!(g, glarea(screen), :left)
  g[1, 1] = layout
end

function main()
  global app = GtkApplication("julia.gtkmakie.example")

  Gtk4.signal_connect(activate, app, :activate)

  if isinteractive()
    loop() = Gtk4.run(app)
    t = schedule(Task(loop))
  else
    Gtk4.run(app)
  end
end

Euclid.main() = main()

Euclid.designer_main() = designer_main()

end # module
