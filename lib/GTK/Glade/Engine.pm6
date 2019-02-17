use v6;
use NativeCall;

use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkBuilder;
use GTK::V3::Gtk::GtkTextBuffer;
use GTK::V3::Gtk::GtkTextView;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine:auth<github:MARTIMM>;

has GTK::V3::Gtk::GtkMain $!main;
has GTK::V3::Gtk::GtkTextBuffer $!text-buffer;
has GTK::V3::Gtk::GtkTextView $!text-view;

# Must be set before by GTK::Glade.
has GTK::V3::Gtk::GtkBuilder $.builder is rw;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  # initialize GTK
  $!main .= new(:check);

#  $!text-buffer .= new(:empty);
#  $!text-view .= new(:empty);
}

#-------------------------------------------------------------------------------
method glade-start-iter ( $text-buffer --> CArray[int32] ) {

  my $iter_mem = CArray[int32].new;
  $iter_mem[31] = 0; # Just need a blob of memory.
  $text-buffer.get-start-iter($iter_mem);
  $iter_mem
}

#-------------------------------------------------------------------------------
method glade-end-iter ( $text-buffer --> CArray[int32] ) {

  my $iter_mem = CArray[int32].new;
  $iter_mem[16] = 0;
  $text-buffer.get-end-iter($iter_mem);
  $iter_mem
}

#-------------------------------------------------------------------------------
method glade-get-text ( Str:D $id --> Str ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));
  $!text-buffer.get-text(
    self.glade-start-iter($!text-buffer), self.glade-end-iter($!text-buffer), 1)
}

#-------------------------------------------------------------------------------
method glade-set-text ( Str:D $id, Str:D $text ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));
  $!text-buffer.set-text( $text, $text.chars);
}

#-------------------------------------------------------------------------------
method glade-add-text ( Str:D $id, Str:D $text is copy ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));

  $text = $!text-buffer.get-text(
    self.glade-start-iter($!text-buffer), self.glade-end-iter($!text-buffer), 1
  ) ~ $text;

  $!text-buffer.set-text( $text, $text.chars);
}

#-------------------------------------------------------------------------------
# Get the text and clear text field. Returns the original text
method glade-clear-text ( Str:D $id --> Str ) {

  $!text-view .= new(:build-id($id));
  $!text-buffer .= new(:widget($!text-view.get-buffer));
  my Str $text = $!text-buffer.get-text(
    self.glade-start-iter($!text-buffer), self.glade-end-iter($!text-buffer), 1
  );

  $!text-buffer.set-text( "", 0);

  $text
}

#-------------------------------------------------------------------------------
method glade-get-widget ( Str:D $id --> Any ) {
  $!builder.get-object($id)
}

#-------------------------------------------------------------------------------
method glade-main-level ( ) {
  $!main.gtk-main-level;
}

#-------------------------------------------------------------------------------
method glade-main-quit ( ) {
  $!main.gtk-main-quit;
}
