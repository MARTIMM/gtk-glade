use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
unit package GTK::Glade::Native::Gtk::Label:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_label_new ( Str $text )
  returns GtkWidget
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_get_text ( GtkWidget $label )
  returns Str
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_set_text ( GtkWidget $label, Str $text )
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_set_markup( GtkWidget $label, Str $text )
  is native(&gtk-lib)
  is export
  { * }



#`{{
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# See /usr/include/gtk-3.0/gtk/gtklabel.h
#class GTK::Glade::Native::Gtk::Label does Callable {

#-------------------------------------------------------------------------------
# GTK::Simple has an interesting way to get/set text so only one call is needed
# to get or set text. Here I like it to keep it the way as the calls are in GTK
# where gtk_label is stripped from the method name.
#-------------------------------------------------------------------------------
has GtkWidget $!gtk-label;

#-------------------------------------------------------------------------------
method CALL-ME ( --> GtkWidget ) {

note "return: ", $!gtk-label;
  $!gtk-label
}

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$text, Bool :$visible = True ) {

note "text: $text, $visible";
  $!gtk-label = gtk_label_new($text);
note "label: ", $!gtk-label;
  gtk_widget_set_visible( $!gtk-label, $visible);
note "v";
}

#-------------------------------------------------------------------------------
method get-text ( --> Str ) {
  gtk_label_get_text($!gtk-label);
}

#-------------------------------------------------------------------------------
method set-text ( Str:D $text ) {
  gtk_label_set_text( $!gtk-label, $text);
}

#-------------------------------------------------------------------------------
method set-markup ( Str $text ) {
  gtk_label_set_markup( $!gtk-label, $text);
}
}}
