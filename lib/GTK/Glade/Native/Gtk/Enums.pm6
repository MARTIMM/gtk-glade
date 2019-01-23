use v6;
use NativeCall;

#use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gdk;
#use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk/gtkenums.h
unit module GTK::Glade::Native::Gtk::Enums;

#-------------------------------------------------------------------------------
enum GtkOrientation is export (
  GTK_ORIENTATION_HORIZONTAL    => 0,
  GTK_ORIENTATION_VERTICAL      => 1,
);
