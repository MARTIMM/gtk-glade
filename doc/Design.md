```plantuml
'title Design and use of code
hide empty description

skinparam state {
  BackgroundColor<<file>> #ff8800
  BorderColor<<file>> #555555
}


state "xyz.ui" as gladeFile <<file>>
state "xyz.pm6" as perlModule <<file>>
state "GTK::Glade.pm6" as perlLibModule <<file>>


'[*] --> Prepare
state "Preparation of\ncode and data" as Prepare {

  Design: Design user interface\nusing glade and\nsave ui description
  Design --> gladeFile: save

  Design -> P6Code: user\naction
  P6Code --> perlModule: save
  P6Code: Perl6 Engine class\nwith methods for all\ndefined signals

  'P6Code -> [*]
}

[*] --> Design: user\naction


state "Perl6 program" as P6CodeFlow {
  state "GTK::Glade::Engine" as Engine

  '[*] -> Engine
  perlLibModule --> GTK::Glade: "use GTK::Glade;"
  gladeFile --> GTK::Glade: ":file('xyz.ui')"
  perlModule --> Engine: "use xyz;"
  Engine -> GTK::Glade: ":engine($obj)"
  'GTK::Glade -> [*]: Exit main\nloop
}

Prepare --> P6CodeFlow: Start\nprogram
'P6CodeFlow --> [*]
GTK::Glade --> [*]: Exit main\nloop
```
