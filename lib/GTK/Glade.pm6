use v6;
use NativeCall;

use XML::Actions;

use GTK::Glade::X;
use GTK::Glade::Engine;
use GTK::Glade::Engine::Test;
use GTK::Glade::Engine::Work;
use GTK::Glade::Engine::PreProcess;

#-------------------------------------------------------------------------------
class GTK::Glade:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  submethod BUILD (
    Str :$ui-file, Str :$css-file, GTK::Glade::Engine:D :$engine,
    GTK::Glade::Engine::Test :$test-setup
  ) {

    die X::GTK::Glade.new(
      :message("No suitable glade XML file: '$ui-file'")
    ) unless ?$ui-file and $ui-file.IO ~~ :r;

    # Prepare XML document for processing
    my XML::Actions $actions .= new(:file($ui-file));

    # Prepare Gtk Glade work for preprocessing. In this phase all missing
    # ids on objects are generated and written back in the xml elements.
    my GTK::Glade::Engine::PreProcess $pp .= new;
    $actions.process(:actions($pp));
    my Str $modified-ui = $actions.result;
    my Str $toplevel-id = $pp.toplevel-id;
    # cleanup preprocess object
    $pp = GTK::Glade::Engine::PreProcess;

    "modified-ui.glade".IO.spurt($modified-ui); # test dump for result

    # Prepare Gtk Glade work for processing the glade XML
    my GTK::Glade::Engine::Work $work .= new( :$engine, :test(?$test-setup));
    $work.glade-add-gui(:ui-string($modified-ui));
#    $work.glade-add-gui(:ui-string("hoeperdepoep")); # test for failure
    # cleanup the glade XML string
    $modified-ui = Str;

    # Process the XML document creating the API to the UI
    $actions.process(:actions($work));

    # Css can be added only after processing is done. There is a toplevel
    # widget needed which is known afterwards.
    $work.glade-add-css(:$css-file);

    # Copy the builder object
    #$engine.builder = $work.builder;
    $work.glade-run( :$test-setup, :$toplevel-id);

    #note $work.state-engine-data;
  }
}
