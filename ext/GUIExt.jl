module GUIExt

import Euclid
using GeometryBasics
using GLMakie
using FileIO
using Gtk4
using Gtk4Makie

# TODO need some datastructures
# 1. need to hold onto loaded files and stl meshes, etc.
# 2. need a dictionary/list of geometries

# Function to load STL files
function load_stl(file_path)
  try
    return FileIO.load(file_path)
  catch e
    println("Error loading STL file: $file_path")
    println(e)
    return nothing
  end
end

# GUI stuff

# GUI main stuff below

if isinteractive()
  stop_main_loop()  # g_application_run will run the loop
end

function activate(app)
  screen = Gtk4Makie.GTKScreen(
    resolution=(800, 800),
    title="10 random numbers",
    app=app
  )
  # display(screen, lines(rand(10)))
  s = Scene(; camera = cam3d!)
  display(screen, s)
  ax = current_axis()
  f = current_figure()
  g = grid(screen)
  set_gtk_property!(g, :column_homogeneous, true)

  # example to move from default 1,1 position
  # button = GtkButton("Generate new random plot")
  # insert!(g, glarea(screen), :left)
  # g[1, 1] = button
  
  # function gen_cb(b)
  #   empty!(ax)
  #   lines!(ax, rand(10))
  # end
  
  # signal_connect(gen_cb, g[1, 1], "clicked")
  layout = GtkBox(:h)

  file_layout = GtkBox(:v)
  file_load_button = GtkButton("Load STL File")
  push!(file_layout, file_load_button)
  push!(file_layout, GtkLabel("Files"))

  function add_file(b)
    open_dialog("Select a file to open") do filename
      @async println("selection was ", filename)
      new_label = GtkLabel(filename)
      on_click = GtkGestureClick(new_label)
      function re_render(controller, n_press, x, y)
        @show "here"
        
      end
      signal_connect(re_render, on_click, "pressed")
      push!(file_layout, new_label)

      mesh = load_stl(filename)
      # display(mesh)
      GLMakie.mesh!(s, coordinates(mesh), faces(mesh))
      center!(s)
    end
  end

  # pallet stuff
  pallet_layout = GtkBox(:v)
  sphere_button = GtkButton("Sphere")
  push!(pallet_layout, sphere_button)
  push!(pallet_layout, GtkLabel("Geometries"))

  function add_sphere(b)
    radius = 1. # TODO
    g = Euclid.Sphere(radius)
    push!(pallet_layout, GtkLabel("$(typeof(g))"))
    GLMakie.mesh!(s, g)
  end


  parameters = GtkBox(:v)

  push!(layout, file_layout)
  push!(layout, pallet_layout)
  # push!(layout, parameters)
  # layout
  insert!(g, glarea(screen), :left)
  g[1, 1] = layout
  # g[1, 1] = file_layout
  # insert!(g, glarea(screen), :right)
  # g[2, 1] = pallet_layout
  # @show /size(g)

  # connections
  signal_connect(add_file, file_load_button, "clicked")

  signal_connect(add_sphere, sphere_button, "clicked")
end

function main()
  global app = GtkApplication("julia.gtkmakie.example")

  Gtk4.signal_connect(activate, app, :activate)

  if isinteractive()
    loop()=Gtk4.run(app)
    t = schedule(Task(loop))
  else
    Gtk4.run(app)
  end
end

Euclid.main() = main()

end # module