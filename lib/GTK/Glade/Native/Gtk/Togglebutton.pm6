use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtktogglbutton.h
unit module GTK::Glade::Native::Gtk::Togglebutton:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_toggle_button_new_with_label(Str $label)
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_toggle_button_get_active(GtkWidget $w)
    is native(&gtk-lib)
    is export
    returns int32
    { * }

sub gtk_toggle_button_set_active(GtkWidget $w, int32 $active)
    is native(&gtk-lib)
    is export
    returns int32
    { * }
