use v6;
use NativeCall;

use GTK::Glade::NativeLib;
use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::GtkWidget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkwindow.h on Fedora 28 (2019-01)
unit module GTK::Glade::Native::GtkWindow:auth<github:MARTIMM>;

#--[ gtk_window_ ]--------------------------------------------------------------
class GtkWindow is repr('CPointer') is export { }

sub gtk_window_new ( int32 $window_type )
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_window_set_title ( GtkWidget $w, Str $title )
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_window_set_position(GtkWidget $window, int32 $position)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_window_set_default_size(GtkWidget $window, int32 $width, int32 $height)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_window_set_modal (GtkWindow *window, gboolean modal);
# can be set in glade
sub gtk_window_set_modal ( GtkWidget $window, Bool $modal)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_window_set_transient_for ( GtkWindow *window, GtkWindow *parent);
sub gtk_window_set_transient_for( GtkWindow $window, GtkWindow $parent)
    is native(&gtk-lib)
    is export
    { * }
