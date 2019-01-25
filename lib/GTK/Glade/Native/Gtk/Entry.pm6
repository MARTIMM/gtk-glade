use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkentry.h
unit module GTK::Glade::Native::Gtk::Entry:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_entry_new ( )
    returns GtkWidget
    is native(&gtk-lib)
    is export
    { * }

sub gtk_entry_get_text ( GtkWidget $entry )
    returns Str
    is native(&gtk-lib)
    is export
    { * }

sub gtk_entry_set_text ( GtkWidget $entry, Str $text )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_entry_set_visibility ( GtkWidget $entry, Bool $visible)
    is native(&gtk-lib)
    is export
    { * }
