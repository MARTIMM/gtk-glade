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

  # Must be set before by GTK::Glade.
  has $.builder is rw;

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

  #-----------------------------------------------------------------------------
  method get-widget( Str:D $id --> GtkWidget ) {
    gtk_builder_get_object( $!builder, $id)
  }
}

#-------------------------------------------------------------------------------
class GTK::Glade::Work:auth<github:MARTIMM> is XML::Actions::Work {

  has $.builder;
#  has Hash $!gobjects;
  has GTK::Glade::Engine $!engine;

  #-----------------------------------------------------------------------------
  submethod BUILD ( ) {

#    $!gobjects = {};
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

    my GError $err;
    if ?$!builder {
      my $error-code = gtk_builder_add_from_string(
        $!builder, $ui-string, $ui-string.chars, $err
      );
note "Error message: $err.message()" if $error-code == 0;
      die X::GTK::Glade.new(:message("error adding ui")) if $error-code == 0;
    }

    else {
      $!builder = gtk_builder_new_from_string( $ui-string, $ui-string.chars);
    }
  }

  #-----------------------------------------------------------------------------
  method glade-run ( GTK::Glade::Engine :$!engine ) {
    gtk_main();
  }

#`{{
  #-----------------------------------------------------------------------------
  method !glade-get-object( Str:D $id --> GtkWidget ) {
    $!gobjects{$id} // GtkWidget;
  }

  #-----------------------------------------------------------------------------
  method !glade-set-object( Str:D $id ) {
    $!gobjects{$id} = gtk_builder_get_object( $!builder, $id)
      unless ?$!gobjects{$id};
  }
}}

  #-----------------------------------------------------------------------------
  # Callback methods called from XML::Actions
#`{{
  #-----------------------------------------------------------------------------
  method object ( Array:D $parent-path, Str :$id is copy, Str :$class) {

    note "Object $class, id '$id'";
    self!glade-set-object($id);
  }
}}

  #-----------------------------------------------------------------------------
  method signal (
    Array:D $parent-path, Str:D :name($signal-name),
    Str:D :handler($handler-name),
    Str :$object, Str :$after, Str :$swapped
  ) {
    #TODO bring following code into XML::Actions
    my %object = $parent-path[*-2].attribs;
    my $id = %object<id>;

    my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);

note "Signal Attr of {$parent-path[*-2].name}: ", $widget, ", ", %object.perl;

    my Int $connect-flags = 0;
    $connect-flags +|= G_CONNECT_SWAPPED if ($swapped//'') eq 'yes';
    $connect-flags +|= G_CONNECT_AFTER if ($after//'') eq 'yes';

    #self!glade-set-object($id);

    g_signal_connect_wd(
      $widget, $signal-name,
      -> $widget, $data {
        if $!engine.^can($handler-name) {
#          my Hash $o = $!gobjects.clone();
#          $!engine."$handler-name"( $o, :$widget, :$data, :$object);
          $!engine."$handler-name"( :$widget, :$data, :$object);
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

  has Str $!default-id = "gtk-glade-id-0001";

  method object ( Array:D $parent-path, Str :$id is copy, Str :$class) {

    # if no id is defined, modify the xml element
    if !? $id {
      $id = $!default-id;
      $parent-path[*-1].set( 'id', $!default-id);
      $!default-id .= succ;
    }
  }
}

#-------------------------------------------------------------------------------
class GTK::Glade:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  submethod BUILD (
    Str :$ui-file is copy = '', GTK::Glade::Engine:D :$engine
  ) {


    $ui-file = self!find-glade-file($ui-file);

note "New ui file $ui-file";



    # Prepare XML document for processing
    my XML::Actions $actions .= new(:file($ui-file));

    # Prepare Gtk Glade work for preprocessing. In this phase all missing
    # ids on objects are generated and written back in the xml elements.
    my GTK::Glade::PreProcess $pp .= new;
    $actions.process(:actions($pp));
    my Str $modified-ui = $actions.result;
#    "modified-ui.glade".IO.spurt($modified-ui); # test dump for result

    # Prepare Gtk Glade work for processing
    my GTK::Glade::Work $work .= new;
    $work.glade-add-gui(:ui-string($modified-ui));
#    $work.glade-add-gui(:ui-string("hoeperdepoep")); # test for failure
    $modified-ui = Str;

    # Process the XML document creating the API to the UI
    $actions.process(:actions($work));

    # Copy the builder object
    $engine.builder = $work.builder;
    $work.glade-run(:$engine);

    #note $work.state-engine-data;
  }

  #-----------------------------------------------------------------------------
  method !find-glade-file ( Str $ui-file is copy --> Str ) {

    # return if readable
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;

    my @tried-list = $ui-file,;

note "Ui file '$ui-file' not found, $*PROGRAM-NAME";

    my Str $program = $*PROGRAM-NAME.IO.basename;
    $program ~~ s/\. <-[\.]>* $/.glade/;
    $ui-file = %?RESOURCES{$program}.Str;
note "Try '$program' from resources";
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
    @tried-list.push("Resources: $program");

    $program ~~ s/\. glade $/.ui/;
    $ui-file = %?RESOURCES{$program}.Str;
note "Try '$program' from resources";
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
    @tried-list.push($program);

    $ui-file = %?RESOURCES{"graphical-interface.glade"}.Str;
note "Try 'graphical-interface.glade' from resources";
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
    @tried-list.push("graphical-interface.glade");


    $program = $*PROGRAM-NAME.IO.basename;
    $program ~~ s/\. <-[\.]>* $//;
    note "Try 'graphical-interface.glade' from config directories $*HOME/.$program or $*HOME/.config/$program";

    if "$*HOME/.$program".IO ~~ :d {
      $ui-file = "$*HOME/.$program/graphical-interface.glade";
note "Try '$ui-file'";
      return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
      @tried-list.push("Config: $ui-file");
    }

    elsif "$*HOME/.config/$program".IO ~~ :d {
      $ui-file = "$*HOME/.config/$program/graphical-interface.glade";
note "Try '$ui-file'";
      return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
      @tried-list.push($ui-file);
    }

    die X::GTK::Glade.new(
      :message(
        "No suitable glade XML file found. Tried " ~ @tried-list.join(', ')
      )
    );
  }
}
