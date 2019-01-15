use v6;

use GTK::Glade;
use Test;

diag "\n";

#-------------------------------------------------------------------------------
my $dir = 'xt/x';
mkdir $dir unless $dir.IO ~~ :e;

my Str $file = "$dir/a.xml";
$file.IO.spurt(Q:q:to/EOXML/);
  <?xml version="1.0" encoding="UTF-8"?>
  <!-- Generated with glade 3.20.0 -->
  <interface>
    <requires lib="gtk+" version="3.0"/>
    <object class="GtkWindow" id="window">
      <property name="visible">True</property>
      <property name="can_focus">False</property>
      <property name="border_width">10</property>
      <property name="title">Glade Gui Read Test</property>
      <signal name="delete-event" handler="exit-program" swapped="no"/>
      <child>
        <object class="GtkGrid" id="grid">
          <property name="visible">True</property>
          <property name="can_focus">False</property>
          <child>
            <object class="GtkButton" id="button1">
              <property name="label">Button 1</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="hello-world1" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">0</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="button2">
              <property name="label">Button 2</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="hello-world2" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">1</property>
              <property name="top_attach">0</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="quit">
              <property name="label">Quit</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="quit-program" swapped="no"
                      object="button2" after="yes"/>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">1</property>
              <property name="width">2</property>
            </packing>
          </child>
        </object>
      </child>
    </object>
  </interface>
  EOXML


class E is GTK::Glade::Engine {
  #has Str $!t;
  #submethod BUILD ( Str:D :$!t ) { note "T: $!t"; }

  #-----------------------------------------------------------------------------
  method quit-program ( :$widget, :$data, :$object ) {
    diag "quit-program called";
    diag "Widget: " ~ $widget.perl if ?$widget;
    diag "Data: " ~ $data.perl if ?$data;
    diag "Object: " ~ $object.perl if ?$object;
    is gtk_button_get_label($widget), "Quit", "Label of quit button ok";

    my Str $bn = gtk_widget_get_name($widget);
    is $bn, 'GtkButton', "name of button is same as class name 'GtkButton'";

    gtk_main_quit();
  }

  #-----------------------------------------------------------------------------
  method hello-world1 ( :$widget, :$data, :$object ) {
    is gtk_button_get_label($widget), "Button 1", "Label of button 1 ok";

    my Str $bn = gtk_widget_get_name($widget);
    is $bn, 'GtkButton', "name of button is class name 'GtkButton'";

    gtk_widget_set_name( $widget, "HelloWorld1Button");
    $bn = gtk_widget_get_name($widget);
    is $bn, 'HelloWorld1Button', "name changed into 'HelloWorld1Button'";

    # Change back to keep test ok for next press
    gtk_widget_set_name( $widget, "GtkButton");
  }

  #-----------------------------------------------------------------------------
  method hello-world2 ( :$widget, :$data, :$object ) {
    is gtk_button_get_label($widget), "Button 2", "Label of button 2 ok";
    is gtk_button_get_label(self.get-widget('button1')),
       "Button 1", "Label of button 1 look up";
  }
}

#-------------------------------------------------------------------------------
subtest 'Action object', {
  my E $engine .= new();
  my GTK::Glade $a .= new( :ui-file($file), :$engine);
  isa-ok $a, GTK::Glade, 'type ok';

  #my A $w .= new();
  #$a.process(:actions($w));
  #ok $w.log-done, 'logging done';
}

#-------------------------------------------------------------------------------
done-testing;

unlink $file;
rmdir $dir;
