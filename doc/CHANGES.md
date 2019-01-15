## Release notes

* 2019-01-15 0.3.3
  * The hash of objects is not provided anymore to the callback methods. A convenience method `get-widget( Str $id --> GtkWidget )` is provided in the `GTK::Glade::Engine` class.
  * Search for glade interface file from other locations when filename is not provided.
* 2019-01-12 0.3.2
  * Bugfixes
* 2019-01-07 0.3.1
  * Bugfixes
  * Added GError structure to get error messages
* 0.3.0
  * Use native call interface to display glade designed ui using GtkBuilder.
  * Get GTK widget objects from GtkBuilder using their id found from the glade description.
  * Find signal descriptions and activate them.
* 0.2.0 Read ui description and find objects and signals
* 0.1.0 Make tests written in C to study how to show a glade saved ui interface description.
* 0.0.1 Start of project
