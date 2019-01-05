use v6;
use XML::Actions;

use nqp;
use NativeCall;
use GTK::Simple::NativeLib;
use GTK::Simple::Raw :ALL;

# Export all symbols and functions from GTK::Simple::Raw
sub EXPORT {
  my %export;
  for GTK::Simple::Raw::EXPORT::ALL::.kv -> $k,$v {
    %export{$k} = $v;
  }

  %export;
}

#-------------------------------------------------------------------------------
# Gtk class definitions
class GtkBuilder is repr('CPointer') { }
#class GError is repr('CPointer') { }
class GObject is repr('CPointer') { }

#-------------------------------------------------------------------------------
# Gtk function definitions not found in GTK::Simple::Raw

# void gtk_init ( int *argc, char ***argv);
#sub gtk_init ( CArray[int32] $argc, CArray[CArray[Str]] $argv )
#    is native(&gtk-lib)
#    { * }

# GtkBuilder *gtk_builder_new (void);
sub gtk_builder_new ()
    returns GtkBuilder
    is native(&gtk-lib)
    { * }

# guint gtk_builder_add_from_file(
#      GtkBuilder builder, const gchar *filename, GError **error);
sub gtk_builder_add_from_file (
    GtkBuilder $builder, Str $glade-ui  #, GError $error
    ) returns int32
      is native(&gtk-lib)
      { * }

# GObject *gtk_builder_get_object (
#      GtkBuilder *builder, const gchar *name);
sub gtk_builder_get_object (
    GtkBuilder $builder, Str $object-id
    ) returns GObject
      is native(&gtk-lib)
      { * }

# void gtk_main (void);
#sub gtk_main ( )
#  is native(&gtk-lib)
#  { * }

# void gtk_main_quit (void);
#sub gtk_main_quit ( )
#  is native(&gtk-lib)
#  { * }

# gulong g_signal_connect_object (
#      gpointer instance, const gchar *detailed_signal,
#      GCallback c_handler, gpointer gobject,
#      GConnectFlags connect_flags);
#sub g_signal_connect_object( GObject $widget, Str $signal,
#    &Handler ( GObject $h_widget, OpaquePointer $h_data),
#    OpaquePointer $data, int32 $connect_flags
#    ) returns int32
#      is native(&gobject-lib)
#      #is symbol('g_signal_connect_object')
#      { * }

# void g_signal_handler_disconnect (
#     gpointer instance, gulong handler_id);
#sub g_signal_handler_disconnect( GObject $widget, int32 $handler_id )
#    is native(&gobject-lib)
#    { * }

#-------------------------------------------------------------------------------
# Gtk constant definitions not found in GTK::Simple::Raw
constant G_CONNECT_AFTER = 1;
constant G_CONNECT_SWAPPED = 2;

#-------------------------------------------------------------------------------
# Gtk function definitions not found in GTK::Simple::Raw and possibly needed
# by the child classes of GladePerl6Api::Engine

# void gtk_widget_set_name ( GtkWidget *widget, const gchar *name );
sub gtk_widget_set_name ( GObject $widget, Str $name )
    is native(&gtk-lib)
    is export
    { * }

# const gchar *gtk_widget_get_name ( GtkWidget *widget );
sub gtk_widget_get_name ( GObject $widget )
    returns Str
    is native(&gtk-lib)
    is export
    { * }

# void gtk_text_buffer_insert (
#      GtkTextBuffer *buffer, GtkTextIter *iter, const gchar *text, gint len);
sub gtk_text_buffer_insert( OpaquePointer $buffer, CArray[int32] $start,
    Str $text, int32 $len
    ) is native(&gtk-lib)
      is export
      { * }

# from /usr/include/glib-2.0/gobject/gsignal.h
# #define g_signal_connect( instance, detailed_signal, c_handler, data)
# as g_signal_connect_data (
#      (instance), (detailed_signal),
#      (c_handler), (data), NULL, (GConnectFlags) 0
#    )
# So;
# gulong g_signal_connect_data ( gpointer instance,
#          const gchar *detailed_signal,
#          GCallback c_handler,
#          gpointer data,
#          GClosureNotify destroy_data,
#          GConnectFlags connect_flags );
sub g_signal_connect_data( GObject $widget, Str $signal,
    &Handler ( GObject $h_widget, OpaquePointer $h_data),
    OpaquePointer $data, OpaquePointer $destroy_data, int32 $connect_flags
    ) returns int32
      is native(&gobject-lib)
      #is symbol('g_signal_connect_object')
      #is export
      { * }

#-------------------------------------------------------------------------------
class X::GladePerl6Api:auth<github:MARTIMM> is Exception {
  has Str $.message;            # Error text and error code are data mostly
#  has Str $.method;             # Method or routine name
#  has Int $.line;               # Line number where Message is called
#  has Str $.file;               # File in which that happened
}

#-------------------------------------------------------------------------------
class GladePerl6Api::Engine {

#`{{
  #-----------------------------------------------------------------------------
  method g_signal_connect (
    GtkWidget $widget, Str $signal, Routine $handler, OpaquePointer $data,
    #Bool $swapped = False, Bool $after = False
  ) {
    g_signal_connect_data( $widget, $signal, $handler, $data, OpaquePointer, 0);
  }
}}

#`{{
  #-----------------------------------------------------------------------------
  method exit-program ( :$widget, :$data, :$object ) {
    note "Exit program...";
    gtk_main_quit();
  }
}}

  #-----------------------------------------------------------------------------
  # From Gtk::Simple
#`{{
  method int2blob ( Int $i --> CArray[int32] ) {
    my $blob = CArray[int32].new;
    $blob[31] = $i;
    $blob
  }
}}

  #-----------------------------------------------------------------------------
  method start-iter ( $buffer ) {
    my $iter_mem = CArray[int32].new;
    $iter_mem[31] = 0; # Just need a blob of memory.
    gtk_text_buffer_get_start_iter( $buffer, $iter_mem);
    $iter_mem
  }

  #-----------------------------------------------------------------------------
  method end-iter ( $buffer ) {
    my $iter_mem = CArray[int32].new;
    $iter_mem[16] = 0;
    gtk_text_buffer_get_end_iter( $buffer, $iter_mem);
    $iter_mem
  }
}

#-------------------------------------------------------------------------------
class GladePerl6Api::Work:auth<github:MARTIMM> is XML::Actions::Work {

  has $!builder;
  has Hash $!gobjects;
  has GladePerl6Api::Engine $!engine;

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str:D :$ui-file ) {

    $!gobjects = {};
    $!engine .= new();

    # Setup gtk using commandline arguments
    my $arg_arr = CArray[Str].new;
    $arg_arr[0] = $*PROGRAM.Str;
    my $argc = CArray[int32].new;
    $argc[0] = 1;
    my $argv = CArray[CArray[Str]].new;
    $argv[0] = $arg_arr;
    gtk_init( $argc, $argv);

    $!builder = gtk_builder_new();
    gtk_builder_add_from_file( $!builder, $ui-file);
  }

  #-----------------------------------------------------------------------------
  method RUN ( GladePerl6Api::Engine :$!engine ) {
    gtk_main();
  }

  #-----------------------------------------------------------------------------
  method object ( Array:D $parent-path, Str:D :$id, Str:D :$class) {
    note "Object $class, name '$id'";
    self!set-object($id);

#`{{
    given $class {
      when "GtkWindow" {
        g_signal_connect_object(
          self!get-object($id), "delete-event",
          -> $widget, $data { self!exit-program; },
          OpaquePointer, 0
        );
      }

      when "GtkButton" {
        if self.^can($id) {
          g_signal_connect_object(
            self!get-object($id), "clicked",
            sub ( $widget, $data ) {
              note "in handler of ", self.perl;
              note "can do PLACEHOLDER: ", self.^can("PLACEHOLDER");
              #self.PLACEHOLDER( $id, $class);
              note "Object $class '$id' signalled";
            },
            OpaquePointer, 0
          );
        }

        else {
          g_signal_connect_object(
            $!gobjects{$id}, "clicked",
            -> $widget, $data { self."$id"(); },
            OpaquePointer, 0
          );
        }
      }
    }
}}
  }

  #-----------------------------------------------------------------------------
  method signal (
    Array:D $parent-path, Str:D :name($signal-name),
    Str:D :handler($handler-name),
    Str :$object, Str :$after, Str :$swapped
  ) {
    #TODO bring into XML::Actions
    my %object = $parent-path[*-2].attribs;
    my $id = %object<id>;

    my Int $connect-flags = 0;
    $connect-flags +|= G_CONNECT_SWAPPED if ($swapped//'') eq 'yes';
    $connect-flags +|= G_CONNECT_AFTER if ($after//'') eq 'yes';

    self!set-object($id);
    g_signal_connect_wd(
      self!get-object($id), $signal-name,
      -> $widget, $data {
        if $!engine.^can($handler-name) {
          my Hash $o = $!gobjects.clone();
          $!engine."$handler-name"( $o, :$widget, :$data, :$object);
        }
        else {
          note "Handler $handler-name on $id object using $signal-name event not defined";
        }
      },
      OpaquePointer, $connect-flags
    );
  }

  #-----------------------------------------------------------------------------
  method !get-object( Str:D $id --> GObject ) {
    $!gobjects{$id} // GObject;
  }

  #-----------------------------------------------------------------------------
  method !set-object( Str:D $id ) {
    $!gobjects{$id} = gtk_builder_get_object( $!builder, $id)
      unless ?$!gobjects{$id};
  }
#`{{
  #-----------------------------------------------------------------------------
  method !exit-program ( ) {
    note "Exit program...";
    gtk_main_quit();
  }
}}
}

#-------------------------------------------------------------------------------
class GladePerl6Api:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str:D :$ui-file, GladePerl6Api::Engine :$engine ) {

    # Prepare XML document for processing
    my XML::Actions $actions .= new(:file($ui-file));

    # Prepare Gtk Glade work for processing
    my GladePerl6Api::Work $work .= new(:$ui-file);

    # Process the XML document creating the API to the UI
    $actions.process(:actions($work));

    $work.RUN(:$engine);

    #note $work.state-engine-data;
  }
}
