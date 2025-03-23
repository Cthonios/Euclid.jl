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

function file_io_layout(s)
  file_layout = GtkBox(:v)
  file_load_button = GtkButton("Load File")
  push!(file_layout, file_load_button)
  push!(file_layout, GtkLabel("Loaded Files:"))

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

  # connections
  signal_connect(add_file, file_load_button, "clicked")

  return file_layout
end