use v6;
use XML::Actions;

use nqp;
use NativeCall;
use GTK::Glade::NativeLib;
use GTK::Glade::NativeGtk;

#-------------------------------------------------------------------------------
# Export all symbols and functions from GTK::Simple::Raw
sub EXPORT {
  my %export;
  for GTK::Glade::NativeGtk::EXPORT::ALL::.kv -> $k,$v {
    %export{$k} = $v;
  }

  %export;
}

#-------------------------------------------------------------------------------
class X::GTK::Glade:auth<github:MARTIMM> is Exception {
  has Str $.message;            # Error text and error code are data mostly
#  has Str $.method;             # Method or routine name
#  has Int $.line;               # Line number where Message is called
#  has Str $.file;               # File in which that happened
}

#-------------------------------------------------------------------------------
class GTK::Glade::Engine:auth<github:MARTIMM> {

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
class GTK::Glade::Work:auth<github:MARTIMM> is XML::Actions::Work {

  has $!builder;
  has Hash $!gobjects;
  has GTK::Glade::Engine $!engine;

  #-----------------------------------------------------------------------------
  submethod BUILD ( ) {

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

#`{{
    if $ui-file.IO ~~ :r {
      $!builder = gtk_builder_new_from_file($ui-file);
    }

    else {
      $!builder = gtk_builder_new();
    }
}}
  }

  #-----------------------------------------------------------------------------
  # Prefix all methods with 'glade-' to distinguish them from callback methods
  # for glade gui xml elements when that file is processed by XML::Actions
  #-----------------------------------------------------------------------------
  multi method glade-add-gui ( Str:D :$ui-file! ) {

    if ?$!builder {
      my $error-code = gtk_builder_add_from_file( $!builder, $ui-file, Any);
      die X::GTK::Glade.new(:message("error adding ui")) if $error-code == 0;
    }

    else {
      $!builder = gtk_builder_new_from_file($ui-file);
    }
  }

  #-----------------------------------------------------------------------------
  multi method glade-add-gui ( Str:D :$ui-string! ) {

    if ?$!builder {
      my $error-code = gtk_builder_add_from_string(
        $!builder, $ui-string, -1, Any
      );

      die X::GTK::Glade.new(:message("error adding ui")) if $error-code == 0;
    }

    else {
      $!builder = gtk_builder_new_from_string( $ui-string, -1);
    }
  }

  #-----------------------------------------------------------------------------
  method glade-run ( GTK::Glade::Engine :$!engine ) {
    gtk_main();
  }

  #-----------------------------------------------------------------------------
  method !glade-get-object( Str:D $id --> GObject ) {
    $!gobjects{$id} // GObject;
  }

  #-----------------------------------------------------------------------------
  method !glade-set-object( Str:D $id ) {
    $!gobjects{$id} = gtk_builder_get_object( $!builder, $id)
      unless ?$!gobjects{$id};
  }

  #-----------------------------------------------------------------------------
  # Callback methods called from XML::Actions
  #-----------------------------------------------------------------------------
  method object ( Array:D $parent-path, Str :$id is copy, Str :$class) {

    #die X::GTK::Glade.new(:message("\nId must be defined, go back to glade and set id for this $class widget"));

    note "Object $class, id '$id'";
    self!glade-set-object($id);

#`{{
    given $class {
      when "GtkWindow" {
        g_signal_connect_object(
          self!glade-get-object($id), "delete-event",
          -> $widget, $data { self!exit-program; },
          OpaquePointer, 0
        );
      }

      when "GtkButton" {
        if self.^can($id) {
          g_signal_connect_object(
            self!glade-get-object($id), "clicked",
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
note "Attr of el {$parent-path[*-2].name}: ",
      self!glade-get-object($id), ", ", %object.perl;

    my Int $connect-flags = 0;
    $connect-flags +|= G_CONNECT_SWAPPED if ($swapped//'') eq 'yes';
    $connect-flags +|= G_CONNECT_AFTER if ($after//'') eq 'yes';

    #self!glade-set-object($id);

    g_signal_connect_wd(
      self!glade-get-object($id), $signal-name,
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
}

#-------------------------------------------------------------------------------
# Preprocessing class to get ids on all objects
class GTK::Glade::PreProcess:auth<github:MARTIMM> is XML::Actions::Work {

  has Str $default-id = "gtk-glade-id-0001";

  method object ( Array:D $parent-path, Str :$id is copy, Str :$class) {

    # if no id is defined, modify the xml element
    if !? $id {
      $id = $default-id;
      $parent-path[*-1].set( 'id', $default-id);
      $default-id .= succ;
    }
  }
}

#-------------------------------------------------------------------------------
class GTK::Glade:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str:D :$ui-file, GTK::Glade::Engine :$engine ) {

    # Prepare XML document for processing
    my XML::Actions $actions .= new(:file($ui-file));

    # Prepare Gtk Glade work for processing
    my GTK::Glade::PreProcess $pp .= new;
    $actions.process(:actions($pp));
    my Str $modified-ui = $actions.result;

    # Prepare Gtk Glade work for processing
    my GTK::Glade::Work $work .= new;
    $work.glade-add-gui(:ui-string($modified-ui));

    # Process the XML document creating the API to the UI
    $actions.process(:actions($work));

    $work.glade-run(:$engine);

    #note $work.state-engine-data;
  }
}
