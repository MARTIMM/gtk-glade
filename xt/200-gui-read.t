use v6;

use GTK::Glade;
use Test;

#use nqp;
#use NativeCall;

diag "\n";

#-------------------------------------------------------------------------------
my $dir = 'xt/x';
mkdir $dir unless $dir.IO ~~ :e;

my Str $file = "$dir/a.xml";
$file.IO.spurt(Q:q:to/EOXML/);
  <?xml version="1.0" encoding="UTF-8"?>
  <!-- Generated with glade 3.22.1 -->
  <interface>
    <requires lib="gtk+" version="3.10"/>
    <object class="GtkWindow" id="window">
      <property name="visible">True</property>
      <property name="can_focus">False</property>
      <property name="border_width">10</property>
      <property name="title">Grid</property>
      <child>
        <placeholder/>
      </child>
      <child>
        <object class="GtkGrid" id="grid">
          <property name="visible">True</property>
          <property name="can_focus">False</property>
          <property name="row_spacing">6</property>
          <property name="column_spacing">6</property>
          <child>
            <object class="GtkLabel" id="inputTxtLbl">
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="label" translatable="yes">Text to copy</property>
              <property name="justify">right</property>
              <property name="single_line_mode">True</property>
              <attributes>
                <attribute name="foreground" value="#c1c17d7d1111"/>
              </attributes>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">1</property>
            </packing>
          </child>
          <child>
            <object class="GtkTextView" id="inputTxt">
              <property name="visible">True</property>
              <property name="can_focus">True</property>
              <signal name="insert-at-cursor" handler="insert-char" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">1</property>
              <property name="top_attach">1</property>
              <property name="width">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="clearBttn">
              <property name="label" translatable="yes">Clear Text</property>
              <property name="visible">True</property>
              <property name="can_focus">True</property>
              <property name="receives_default">True</property>
              <signal name="clicked" handler="clear-text" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="copyBttn">
              <property name="label">Copy Text</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="copy-text" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">1</property>
              <property name="top_attach">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="quitBttn">
              <property name="label">Quit</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="exit-program" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">2</property>
              <property name="top_attach">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkScrolledWindow" id="ScrolledOutputTxt">
              <property name="width_request">200</property>
              <property name="height_request">300</property>
              <property name="visible">True</property>
              <property name="can_focus">True</property>
              <property name="shadow_type">in</property>
              <property name="max_content_width">200</property>
              <property name="max_content_height">300</property>
              <child>
                <object class="GtkTextView" id="outputTxt">
                  <property name="width_request">200</property>
                  <property name="height_request">300</property>
                  <property name="visible">True</property>
                  <property name="can_focus">True</property>
                  <property name="wrap_mode">word</property>
                </object>
              </child>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">0</property>
              <property name="width">3</property>
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
  method exit-program ( Hash $o, :$widget, :$data, :$object ) {

    gtk_main_quit();
  }

  #-----------------------------------------------------------------------------
  method copy-text ( Hash $o, :$widget, :$data, :$object ) {

    # Get the input text and clear input field
    my $input-text = $o<inputTxt>;
    my $buffer = gtk_text_view_get_buffer($input-text);
    my $text = gtk_text_buffer_get_text(
                 $buffer, self.start-iter($buffer), self.end-iter($buffer), 1
               );
    gtk_text_buffer_set_text( $buffer, "", -1);
note "Text: ", $text//'-';

    my $output-text = $o<outputTxt>;
    $buffer = gtk_text_view_get_buffer($output-text);
    $text = gtk_text_buffer_get_text(
              $buffer, self.start-iter($buffer), self.end-iter($buffer), 1
            ) ~ "\n$text";
    gtk_text_buffer_set_text( $buffer, $text, -1);
# Keep getting double free crashes
#    gtk_text_buffer_insert(
#      $buffer, self.end-iter($buffer), $text, -1 #$text.chars
#    );
  }

  #-----------------------------------------------------------------------------
  method clear-text ( Hash $o, :$widget, :$data, :$object ) {

    # Get the output text and clear output field
    my GtkWidget $output-text = $o<outputTxt>;
#note "outputTxt object: ", $output-text;
    my $buffer = gtk_text_view_get_buffer($output-text);
    note gtk_text_buffer_get_text(
           $buffer, self.start-iter($buffer), self.end-iter($buffer), 1
         );
    gtk_text_buffer_set_text( $buffer, "", -1);
  }

  #-----------------------------------------------------------------------------
  method insert-char ( Hash $o, :$widget, :$data, :$object ) {
    note "Text inserted";
  }

#`{{
  #-----------------------------------------------------------------------------
  # From Gtk::Simple
  method !start-iter ( $buffer ) {
    my $iter_mem = CArray[int32].new;
    $iter_mem[31] = 0; # Just need a blob of memory.
    gtk_text_buffer_get_start_iter( $buffer, $iter_mem);
    $iter_mem
  }

  #-----------------------------------------------------------------------------
  method !end-iter ( $buffer ) {
    my $iter_mem = CArray[int32].new;
    $iter_mem[16] = 0;
    gtk_text_buffer_get_end_iter( $buffer, $iter_mem);
    $iter_mem
  }
}}
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

#unlink $file;
#rmdir $dir;