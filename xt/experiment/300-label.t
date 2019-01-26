use v6;
use NativeCall;
use N::GtkMain;
use GtkWidget;
use GtkLabel;
use Test;

diag "\n";

# Must setup gtk otherwise perl6 will crash
my $argc = CArray[int32].new;
$argc[0] = 1;

my $argv = CArray[CArray[Str]].new;
my $arg_arr = CArray[Str].new;
$arg_arr[0] = $*PROGRAM.Str;
$argv[0] = $arg_arr;

is gtk_init_check( $argc, $argv), 1, "gtk initalized";

#-------------------------------------------------------------------------------
subtest 'Label create', {

  my GtkLabel $label .= new(:text('abc def'));
  isa-ok $label, GtkLabel;
  isa-ok $label(), N-GtkWidget;

  is $label.get-text, 'abc def', 'text ok';
}

#-------------------------------------------------------------------------------
done-testing;
