use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::GtkWidget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk on Fedora-28
unit module GTK::Glade::Native::Gtk:auth<github:MARTIMM>;

#TODO dunno where to place it yet
class GError is repr('CStruct') is export {
  #has GQuark $.domain;
  has uint32 $.domain;
  has int32 $.code;
  has CArray[int8] $.message;
}

class GObject is repr('CPointer') is export { }

#`{{
#==[ GDK ]======================================================================
class GdkScreen is repr('CPointer') is export { }
class GdkWindow is repr('CPointer') is export { }

#--[ Gdk screen ]---------------------------------------------------------------
sub gdk_screen_get_default ( )
    returns GdkScreen
    is native(&gdk-lib)
    is export
    { * }

#--[ gdk display ]--------------------------------------------------------------
class GdkDisplay is repr('CPointer') is export { }

sub gdk_display_warp_pointer (
    GdkDisplay $display, GdkScreen $screen, int32 $x, int32 $y
  ) is native(&gdk-lib)
    is export
    { * }

#--[ gdk window ]---------------------------------------------------------------
sub gdk_window_get_origin (
    GdkWindow $window, int32 $x is rw, int32 $y is rw
    ) returns int32
      is native(&gdk-lib)
      is export
      { * }
}}

#==[ GTK ]======================================================================
#`{{
#--[ gtk widget ]---------------------------------------------------------------
class GtkWidget is repr('CPointer') is export { }

sub gtk_widget_get_display ( GtkWidget $widget )
    returns GdkDisplay
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_show(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_hide(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_show_all(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_no_show_all(GtkWidget $widgetw, int32 $no_show_all)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_no_show_all(GtkWidget $widgetw)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_destroy(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_sensitive(GtkWidget $widget, int32 $sensitive)
    is native(&gtk-lib)
    is export

    { * }
sub gtk_widget_get_sensitive(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_size_request(GtkWidget $widget, int32 $w, int32 $h)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_allocated_height(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_allocated_width(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_queue_draw(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_tooltip_text(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns Str
    { * }

sub gtk_widget_set_tooltip_text(GtkWidget $widget, Str $text)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_widget_set_name ( GtkWidget *widget, const gchar *name );
sub gtk_widget_set_name ( GtkWidget $widget, Str $name )
    is native(&gtk-lib)
    is export
    { * }

# const gchar *gtk_widget_get_name ( GtkWidget *widget );
sub gtk_widget_get_name ( GtkWidget $widget )
    returns Str
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_window ( GtkWidget $widget )
    returns GdkWindow
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_visible ( GtkWidget $widget, Bool $visible)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_has_window ( GtkWidget $window )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }
}}

#`{{
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
}}
