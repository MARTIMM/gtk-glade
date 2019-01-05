```plantuml
'title Design and use of code
hide empty description

skinparam state {
  BackgroundColor<<file>> #ff8800
  BorderColor<<file>> #555555
}


state "xyz.ui" as gladeFile <<file>>
state "xyz.pm6" as perlModule <<file>>
state "GladePerl6Api.pm6" as perlLibModule <<file>>


[*] --> Prepare
state "Preparation of\ncode and data" as Prepare {

  [*] -> Design: user\naction
  Design: Design user interface\nusing glade and\nsave ui description
  Design --> gladeFile: save

  Design -> P6Code: user\naction
  P6Code --> perlModule: save
  P6Code: Perl6 Engine class\nwith methods for all\ndefined signals

  P6Code -> [*]
}


state "Perl6 program" as P6CodeFlow {
  state "GladePerl6Api::Engine" as Engine

  [*] -> Engine
  perlLibModule --> GladePerl6Api: "use GladePerl6Api;"
  gladeFile --> GladePerl6Api: ":file('xyz.ui')"
  perlModule --> Engine: "use xyz;"
  Engine -> GladePerl6Api: ":engine($obj)"
  GladePerl6Api -> [*]: Exit main\nloop
}

Prepare --> P6CodeFlow
P6CodeFlow --> [*]

```
