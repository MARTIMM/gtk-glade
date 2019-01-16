## Release notes

* 2019-01-16 0.4.0
  * Added the use of css stylesheets. It will by default get the `GTK_STYLE_PROVIDER_PRIORITY_USER` priority to override everything. There are however classes on widgets which prevent settings of e.g. background-color. That is only possible when the `flat` class is set on the widget. Each widget has its own set of classes which must be looked up from the documents. The `GtkButton`, for example, recognizes `circular` and `flat` amongst others.
* 2019-01-15 0.3.3
  * The hash of objects is not provided anymore to the callback methods. A convenience method `get-widget( Str $id --> GtkWidget )` is provided in the `GTK::Glade::Engine` class.
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
