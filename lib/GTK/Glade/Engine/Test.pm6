use v6;

use NativeCall;
use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Engine;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine::Test:auth<github:MARTIMM> is GTK::Glade::Engine;

# Must be set before by GTK::Glade.
#has $.builder is rw;

#-----------------------------------------------------------------------------
submethod BUILD ( GTK::Glade::Engine::Test :$test-setup ) {

  if ?$test-setup {
    for $test-setup.steps -> Hash $step {
      note $step;
    }
  }
}
