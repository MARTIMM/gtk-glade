use v6;
use NativeCall;

use GtkWidget;
use N::NativeLib;

#-------------------------------------------------------------------------------
unit class GtkLabel does GtkWidget;

#-------------------------------------------------------------------------------
sub gtk_label_new ( Str $text )
  returns N-GtkWidget
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_get_text ( N-GtkWidget $label )
  returns Str
  is native(&gtk-lib)
  is export
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( Str:D :$text, Bool :$visible = True ) {

  $!gtk-widget = gtk_label_new($text);
  gtk_widget_set_visible( $!gtk-widget, $visible);
}

#-------------------------------------------------------------------------------
method get-text ( --> Str ) {
  gtk_label_get_text($!gtk-widget)
}
