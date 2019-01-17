use v6;
use XML::Actions;

#use nqp;
use NativeCall;
#use GTK::Glade::NativeLib;
use GTK::Glade::NativeGtk :ALL;

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
  method glade-start-iter ( $buffer ) {
    my $iter_mem = CArray[int32].new;
    $iter_mem[31] = 0; # Just need a blob of memory.
    gtk_text_buffer_get_start_iter( $buffer, $iter_mem);
    $iter_mem
  }

  #-----------------------------------------------------------------------------
  method glade-end-iter ( $buffer ) {
    my $iter_mem = CArray[int32].new;
    $iter_mem[16] = 0;
    gtk_text_buffer_get_end_iter( $buffer, $iter_mem);
    $iter_mem
  }

  #-----------------------------------------------------------------------------
  method glade-get-widget ( Str:D $id --> GtkWidget ) {
    gtk_builder_get_object( $!builder, $id)
  }

  #-----------------------------------------------------------------------------
  method glade-get-text ( Str:D $id --> Str ) {

    my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
    my $buffer = gtk_text_view_get_buffer($widget);

    gtk_text_buffer_get_text(
      $buffer, self.glade-start-iter($buffer), self.glade-end-iter($buffer), 1
    )
  }

  #-----------------------------------------------------------------------------
  method glade-set-text ( Str:D $id, Str:D $text ) {

    my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
    my $buffer = gtk_text_view_get_buffer($widget);

    gtk_text_buffer_set_text( $buffer, $text, -1);
  }

  #-----------------------------------------------------------------------------
  method glade-add-text ( Str:D $id, Str:D $text is copy ) {

    my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
    my $buffer = gtk_text_view_get_buffer($widget);

    $text = gtk_text_buffer_get_text(
      $buffer, self.glade-start-iter($buffer), self.glade-end-iter($buffer), 1
    ) ~ $text;

    gtk_text_buffer_set_text( $buffer, $text, -1);
  }

  #-----------------------------------------------------------------------------
  # Get the text and clear text field. Returns the original text
  method glade-clear-text ( Str:D $id --> Str ) {

    my GtkWidget $widget = gtk_builder_get_object( $!builder, $id);
    my $buffer = gtk_text_view_get_buffer($widget);
    my Str $text = gtk_text_buffer_get_text(
      $buffer, self.glade-start-iter($buffer), self.glade-end-iter($buffer), 1
    );

    gtk_text_buffer_set_text( $buffer, "", -1);

    $text
  }
}

#-------------------------------------------------------------------------------
class GTK::Glade::Work:auth<github:MARTIMM> is XML::Actions::Work {

  has $.builder;
#  has Hash $!gobjects;
  has GTK::Glade::Engine $!engine;
#  has Str $!top-level-object-id;

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
      die X::GTK::Glade.new(:message("error adding ui")) if $error-code == 0;
    }

    else {
      $!builder = gtk_builder_new_from_string( $ui-string, $ui-string.chars);
    }
  }

  #-----------------------------------------------------------------------------
  method glade-add-css ( Str :$css-file ) {

    return unless ?$css-file and $css-file.IO ~~ :r;
note $css-file.IO.slurp;

    #my GtkWidget $widget = gtk_builder_get_object(
    #  $!builder, $!top-level-object-id
    #);

    my GdkScreen $default-screen = gdk_screen_get_default();
    my GtkCssProvider $css-provider = gtk_css_provider_new();
    g_signal_connect_wd(
      $css-provider, 'parsing-error',
      -> GtkCssProvider $p, GtkCssSection $s, GError $e, $ptr {
note "handler called";
        self!glade-parsing-error( $p, $s, $e, $ptr);
      },
      OpaquePointer, 0
    );

    my GError $error .= new;
    gtk_css_provider_load_from_path( $css-provider, $css-file, Any);
#note "Error: $error.code(), ", $error.message()//'-' if ?$error;

    gtk_style_context_add_provider_for_screen(
      $default-screen, $css-provider, GTK_STYLE_PROVIDER_PRIORITY_USER
    );

    #my GtkCssProvider $css-provider = gtk_css_provider_get_named(
    #  'Kate', Any
    #);

#`{{
    g_signal_connect_wd(
    $css-provider, 'parsing-error',
    -> $provider, $section, $error, $pointer {
      self!glade-parsing-error( $provider, $section, $error, $pointer);
    },
    OpaquePointer, 0
    );

    my GError $error .= new;
    gtk_css_provider_load_from_path( $css-provider, $css-file, $error);
  note "Error: $error.code(), ", $error.message()//'-' if ?$error;
}}
  }

  #-----------------------------------------------------------------------------
  method glade-run ( GTK::Glade::Engine :$!engine ) {
    gtk_main();
  }

  #-----------------------------------------------------------------------------
  method !glade-parsing-error( $provider, $section, $error, $pointer ) {
note "Error";
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
  #-----------------------------------------------------------------------------
#`{{
  method object ( Array:D $parent-path, Str :$id is copy, Str :$class) {

    note "Object $class, id '$id'";

    return unless $class eq "GtkWindow";
    $!top-level-object-id = $id unless ?$!top-level-object-id;

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
    Str :$ui-file, Str :$css-file, GTK::Glade::Engine:D :$engine
  ) {

    die X::GTK::Glade.new(
      :message("No suitable glade XML file: '$ui-file'")
    ) unless ?$ui-file and $ui-file.IO ~~ :r;

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

    # deallocate string
    $modified-ui = Str;

    # Process the XML document creating the API to the UI
    $actions.process(:actions($work));

    # Css can be added only after processing is done. There is a toplevel
    # widget needed which is known afterwards.
    $work.glade-add-css(:$css-file);

    # Copy the builder object
    $engine.builder = $work.builder;
    $work.glade-run(:$engine);

    #note $work.state-engine-data;
  }

#`{{
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
}}
}
