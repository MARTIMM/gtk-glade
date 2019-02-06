use v6;

#-------------------------------------------------------------------------------
class X::Glade is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}
