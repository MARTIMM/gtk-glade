use v6;

use NativeCall;
use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Engine;
#use GTK::Glade::Gdkkeysyms;

#-------------------------------------------------------------------------------
unit role GTK::Glade::Engine::Test:auth<github:MARTIMM> is GTK::Glade::Engine;

# Must be set before by GTK::Glade::Engine::Work.glade-run().
has $.builder is rw;


has GtkWidget $!widget;
has Str $!text;


#-----------------------------------------------------------------------------
method run-tests (
  GTK::Glade::Engine::Test:D $test-setup, Str:D $toplevel-id,
  Supplier $supplier
  --> Str
) {
  my Int $executed-tests = 0;

  if ?$test-setup and ?$test-setup.steps and $test-setup.steps ~~ Array {
    $!widget = GtkWidget;
    $!text = Str;

    # show all widgets before continuing
    gtk_widget_show_all(gtk_builder_get_object( $!builder, $toplevel-id));

    for $test-setup.steps -> Array:D $step {
      for @$step -> Pair $substep {
        $supplier.emit($substep);
      }
    }
  }
#`{{
  my Int $executed-tests = 0;

  if ?$test-setup and ?$test-setup.steps and $test-setup.steps ~~ Array {
    $!widget = GtkWidget;
    $!text = Str;

    # show all widgets before continuing
    gtk_widget_show_all(gtk_builder_get_object( $!builder, $toplevel-id));

    for $test-setup.steps -> Array:D $step {
      for @$step -> Pair $substep {
        note "Substep: $substep.key() => ",
              $substep.value() ~~ Block ?? 'Code block' !! $substep.value();

        given $substep.key {

          when 'set-widget' {
            $!widget = gtk_builder_get_object( $!builder, $substep.value);
          }

          when 'emit-signal' {
            next unless ?$!widget;

            my $result;
            g_signal_emit_by_name(
              $!widget, $substep.value, $!widget, "x", $result
            );
          }

          when 'get-text' {
            next unless ?$!widget and gtk_widget_get_has_window($!widget);

            my $buffer = gtk_text_view_get_buffer($!widget);
            $!text = gtk_text_buffer_get_text(
              $buffer, self.glade-start-iter($buffer),
              self.glade-end-iter($buffer), 1
            )
          }

          when 'set-text' {
            next unless ?$!widget and gtk_widget_get_has_window($!widget);

            my $buffer = gtk_text_view_get_buffer($!widget);
            gtk_text_buffer_set_text( $buffer, $substep.value, -1);
          }

          when 'do-test' {
            next unless $substep.value ~~ Block;

            $substep.value()();
            $executed-tests++;
          }

          when 'wait' {
            sleep $substep.value();
          }
        }
      }

      # Stop when loop is exited
      last unless gtk_main_level();
    }
  }

  ~(+($test-setup.steps) // 0)
}}
}

#-----------------------------------------------------------------------------
method execute-test ( Pair $substep ) {

note "Substep: $substep";
#`{{
  my Int $executed-tests = 0;

  if ?$test-setup and ?$test-setup.steps and $test-setup.steps ~~ Array {
    $!widget = GtkWidget;
    $!text = Str;

    # show all widgets before continuing
    gtk_widget_show_all(gtk_builder_get_object( $!builder, $toplevel-id));

    for $test-setup.steps -> Array:D $step {
      for @$step -> Pair $substep {
        note "Substep: $substep.key() => ",
              $substep.value() ~~ Block ?? 'Code block' !! $substep.value();

        given $substep.key {

          when 'set-widget' {
            $!widget = gtk_builder_get_object( $!builder, $substep.value);
          }

          when 'emit-signal' {
            next unless ?$!widget;

            my $result;
            g_signal_emit_by_name(
              $!widget, $substep.value, $!widget, "x", $result
            );
          }

          when 'get-text' {
            next unless ?$!widget and gtk_widget_get_has_window($!widget);

            my $buffer = gtk_text_view_get_buffer($!widget);
            $!text = gtk_text_buffer_get_text(
              $buffer, self.glade-start-iter($buffer),
              self.glade-end-iter($buffer), 1
            )
          }

          when 'set-text' {
            next unless ?$!widget and gtk_widget_get_has_window($!widget);

            my $buffer = gtk_text_view_get_buffer($!widget);
            gtk_text_buffer_set_text( $buffer, $substep.value, -1);
          }

          when 'do-test' {
            next unless $substep.value ~~ Block;

            $substep.value()();
            $executed-tests++;
          }

          when 'wait' {
            sleep $substep.value();
          }
        }
      }

      # Stop when loop is exited
      last unless gtk_main_level();
    }
  }

  ~(+($test-setup.steps) // 0)
}}
}
