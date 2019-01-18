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
  --> Str
) {

  my Int $executed-tests = 0;

  if ?$test-setup and ?$test-setup.steps and $test-setup.steps ~~ Array {

    # show all widgets before continuing
    gtk_widget_show_all(gtk_builder_get_object( $!builder, $toplevel-id));
    sleep(2.0);

    for $test-setup.steps -> Hash:D $step {
      next unless ?$step<widget-id>;

#note "\n$step";
      my $widget = gtk_builder_get_object( $!builder, $step<widget-id>);
note "Widget: $widget";

      if ?$widget and ?$step<signal-detail> {
note "Signal: $step<signal-detail>";
        my $result;
        g_signal_emit_by_name(
          $widget, $step<signal-detail>, $widget, "x", $result
        );
        sleep(2.0);
      }

      if ?$widget and ?$step<select> {
note "select";

        my GdkWindow $window = gtk_widget_get_window($widget);
        my Int $x;
        my Int $y;
        #gdk_window_get_origin( $window, $x, $y);
note "W: $window, $x, $y";
        $x += gtk_widget_get_allocated_width($widget) / 2;
        $y += gtk_widget_get_allocated_height($widget) / 2;
note "Select: $x, $y";
        my GdkDisplay $display = gtk_widget_get_display($widget);
        my GdkScreen $screen = gdk_screen_get_default();
        gdk_display_warp_pointer( $display, $screen, $x, $y);
      }

      if ?$step<test> {
        $step<test>();
        $executed-tests++;
      }


    }
  }

  ~(+($test-setup.steps) // 0)
}
