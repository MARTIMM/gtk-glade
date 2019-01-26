use v6;
use NativeCall;

use N::NativeLib;

#-------------------------------------------------------------------------------
class N-GtkWidget
  is repr('CPointer')
  is export
  { }


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
role GtkWidget {

  #-----------------------------------------------------------------------------
  sub gtk_widget_set_visible ( N-GtkWidget $widget, Bool $visible)
    is native(&gtk-lib)
    is export
    { * }

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  has N-GtkWidget $!gtk-widget;

  #-----------------------------------------------------------------------------
  method CALL-ME ( --> N-GtkWidget ) {
    $!gtk-widget
  }
}
