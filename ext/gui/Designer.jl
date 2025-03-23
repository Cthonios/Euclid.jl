function activate_designer(app)

end

function designer_main()
  global app = GtkApplication("julia.gtkmakie.designer")
  Gtk4.signal_connect(activate_designer, app, :activate)

  if isinteractive()
    loop()=Gtk4.run(app)
    t = schedule(Task(loop))
  else
    Gtk4.run(app)
  end
end
