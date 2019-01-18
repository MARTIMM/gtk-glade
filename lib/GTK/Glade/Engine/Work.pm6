use v6;

use NativeCall;
use XML::Actions;
use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Engine;
#use GTK::Glade::Engine::Test;
#use GTK::Glade::Engine::PreProcess;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine::Work:auth<github:MARTIMM> is XML::Actions::Work;

has $.builder;
#  has Hash $!gobjects;
has GTK::Glade::Engine $!engine;
#  has Str $!top-level-object-id;

#-----------------------------------------------------------------------------
submethod BUILD ( Bool :$test = False ) {

#    $!gobjects = {};
  $!engine .= new();

  # Setup gtk using commandline arguments
  my $arg_arr = CArray[Str].new;
  $arg_arr[0] = $*PROGRAM.Str;
  my $argc = CArray[int32].new;
  $argc[0] = 1;
  my $argv = CArray[CArray[Str]].new;
  $argv[0] = $arg_arr;

  if $test {
    gtk_test_init( $argc, $argv);
  }

  else {
    gtk_init( $argc, $argv);
  }

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

#-----------------------------------------------------------------------------
# Private methods
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