function viz_screen(app)
  screen = Gtk4Makie.GTKScreen(
    resolution=(800, 800),
    title="Geometry",
    app=app
  )
  return screen
  # display(screen, lines(rand(10)))
  # s = Scene(; camera = cam3d!)
  # display(screen, s)
  # ax = current_axis()
  # f = current_figure()
  # g = grid(screen)
  # set_gtk_property!(g, :column_homogeneous, true)
end
