use v6;

#use GTK::Glade;
#use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gtk::Label;

use Test;

diag "\n";

#-------------------------------------------------------------------------------
subtest 'Action object', {

  my GTK::Glade::Native::Gtk::Label $label .= new(:text('abc def'));
  isa-ok $label, GTK::Glade::Native::Gtk::Label;

  is $label.get-text, 'abc def', 'text ok';
}

#-------------------------------------------------------------------------------
done-testing;
