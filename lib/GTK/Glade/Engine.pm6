use v6;
use NativeCall;

#use GTK::Glade::NativeGtk :ALL;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gtk::Widget;
#use GTK::Glade::Native::Gtk::Builder;

use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkBuilder;
use GTK::V3::Gtk::GtkTextBuffer;
use GTK::V3::Gtk::GtkTextView;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine:auth<github:MARTIMM>;

# Must be set before by GTK::Glade.
has GTK::V3::Gtk::GtkBuilder $.builder is rw;
has GTK::V3::Gtk::GtkTextBuffer $!text-buffer;
has GTK::V3::Gtk::GtkTextView $!text-view;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!text-buffer .= new;
#  $!text-buffer($buffer);
  $!text-view .= new;
}

#-------------------------------------------------------------------------------
method glade-start-iter ( --> CArray[int32] ) {
  my $iter_mem = CArray[int32].new;
  $iter_mem[31] = 0; # Just need a blob of memory.
  $!text-buffer.gtk_text_buffer_get_start_iter($iter_mem);
  $iter_mem
}

#-------------------------------------------------------------------------------
method glade-end-iter ( --> CArray[int32] ) {
  my $iter_mem = CArray[int32].new;
  $iter_mem[16] = 0;
  $!text-buffer.gtk_text_buffer_get_end_iter($iter_mem);
  $iter_mem
}

#-------------------------------------------------------------------------------
method glade-get-text ( Str:D $id --> Str ) {

  $!text-view($!builder.gtk_builder_get_object($id));
  $!text-buffer($!text-view.gtk_text_view_get_buffer);

  $!text-buffer.gtk_text_buffer_get_text(
    self.glade-start-iter, self.glade-end-iter, 1
  )
}

#-------------------------------------------------------------------------------
method glade-set-text ( Str:D $id, Str:D $text ) {

  $!text-view($!builder.gtk_builder_get_object($id));
  $!text-buffer($!text-view.gtk_text_view_get_buffer);
  $!text-buffer.gtk_text_buffer_set_text( $text, $text.chars);
}

#-------------------------------------------------------------------------------
method glade-add-text ( Str:D $id, Str:D $text is copy ) {

  $!text-view($!builder.gtk_builder_get_object($id));
  $!text-buffer($!text-view.gtk_text_view_get_buffer);

  $text = $!text-buffer.gtk_text_buffer_get_text(
    self.glade-start-iter, self.glade-end-iter, 1
  ) ~ $text;

  $!text-buffer.gtk_text_buffer_set_text( $text, $text.chars);
}

#-------------------------------------------------------------------------------
# Get the text and clear text field. Returns the original text
method glade-clear-text ( Str:D $id --> Str ) {

  $!text-view($!builder.gtk_builder_get_object($id));
  $!text-buffer($!text-view.gtk_text_view_get_buffer);
  my Str $text = $!text-buffer.gtk_text_buffer_get_text(
    self.glade-start-iter, self.glade-end-iter, 1
  );

  $!text-buffer.gtk_text_buffer_set_text( "", 0);

  $text
}

#-------------------------------------------------------------------------------
method glade-get-widget ( Str:D $id --> Any ) {
  $!builder.gtk_builder_get_object($id)
}

#-------------------------------------------------------------------------------
method glade-main-quit ( ) {
  my GTK::V3::Gtk::GtkMain $main .= new(:check);
  $main.gtk-main-quit;
}
