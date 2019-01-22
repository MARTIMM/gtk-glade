use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::GtkWidget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk on Fedora-28
unit module GTK::Glade::Native::Gdk:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
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
