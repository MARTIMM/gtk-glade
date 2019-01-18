use v6;

use NativeCall;
use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Engine;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine::Test:auth<github:MARTIMM> is GTK::Glade::Engine;

# Must be set before by GTK::Glade::Engine::Work.glade-run().
has $.builder is rw;

#-----------------------------------------------------------------------------
method run-tests (
  GTK::Glade::Engine::Test:D $test-setup, Str:D $toplevel-id
) {

  if ?$test-setup and ?$test-setup.steps and $test-setup.steps ~~ Array {

    gtk_widget_show_all(gtk_builder_get_object( $!builder, $toplevel-id));
    sleep(2);
    note "Current loop level: ", gtk_main_level();

    for $test-setup.steps -> Hash:D $step {
note "\n$step";
      my $result = '';
      my $widget = gtk_builder_get_object( $!builder, $step<widget-id>);
note "Widget: $widget, $step<signal-detail>";

      g_signal_emit_by_name(
        $widget, $step<signal-detail>, $widget, "", $result
      );
sleep(2);
      $step<test>() if ?$step<test>;

      #gtk_main_iteration_do(False);
      note "Current loop level: ", gtk_main_level();
    }
  }
}
