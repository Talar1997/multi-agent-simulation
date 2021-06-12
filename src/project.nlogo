breed [spiders spider]
spiders-own [ sex dc energy nest health last-molt]

breed [bugs bug]
bugs-own [ energy-value energy ]

breed [cocoons cocoon]
cocoons-own [ tick-created ]

globals [ maxsize-female maxsize-male ]

;;setup
to setup
  clear-all
  reset-ticks
  set-default-shape spiders "spider"
  set-default-shape bugs "bug"
  set-default-shape cocoons "egg"
  set maxsize-female 1.1
  set maxsize-male 0.95
  set-background
  spawn-spiders
end

to set-background
  ask patches [
    if random-float 1000 < 500 [ set pcolor 31 ]
    ifelse random-float 1000 > 500 [ set pcolor 32 ]
    [ set pcolor 33 ]
  ]
end

to spawn-spiders
  create-spiders ilosc_samic [
    set color pink
    setxy random-xcor random-ycor
    set energy 100
    set health 100
    set sex 1
    set nest false
    set dc max_dc
    set last-molt ticks
    set size maxsize-female
  ]
  create-spiders ilosc_samcow [
    set color blue
    setxy random-xcor random-ycor
    set energy 100
    set health 100
    set sex 0
    set nest false
    set dc max_dc
    set last-molt ticks
    set size maxsize-male
  ]
end


;;Tarantulas behavior
to go
  if not any? spiders [ stop ]
  spawn-food
  ask spiders
  [ move
    eat
    will-fight
    reproduce
    make-nest
    molting
    male-wait-to-grow-up
    random-disaster
    death ]

  ask bugs
  [ move-food
    death-food ]

  ask cocoons
  [ hatch-cocoon ]
  tick
end

to move
  ifelse nest [
    set energy energy - 0.1
  ][
    rt random 50
    lt random 50
    fd 1
    set energy energy - 0.5
  ]
end

;walka zależna od parametru agresywnosc
;mają za mało DC do kopulacji - walczą
;mają odpowiednio DC i są tej samej płci - walczą
;są różnej płci ale samica jest głodna - walczą
to will-fight
  let candidate one-of spiders-at 1 0
  if candidate != nobody [
    if random 100 < agresywnosc [
      ifelse([dc] of candidate) <= dc_kopulacja and dc <= dc_kopulacja[
        fight
      ][
        if([sex] of candidate) = sex [ fight ]
      ]
    ]
  ]
end

to fight
  let candidate one-of spiders-at 1 0
  if candidate != nobody [
    ifelse([dc] of candidate) > dc [
      set health 0
    ]
    [
      ask candidate [ set health 0 ]
    ]
  ]
end

to eat
  let candidate one-of bugs-at 1 0
  if candidate != nobody [
    if(energy < 100) [set energy energy + ([energy-value] of candidate)]
  ]
end

to reproduce
  let candidate one-of spiders-at 1 0
  if candidate != nobody [
    if (([sex] of candidate) = 1 and sex = 0 and
      ([nest] of candidate) = true) [
      if ([energy] of candidate < 50)[
        set health 0
        ask candidate [ set energy 100 ]
      ]
      if([dc] of candidate) >= dc_kopulacja and dc >= dc_kopulacja and health != 0[
        create-cocoon
      ]
    ]
  ]
end

to create-cocoon
  let candidate one-of spiders-at 1 0
  hatch-cocoons 1 [
    set color 6
    set size 1
    set tick-created ticks
    setxy [pxcor] of candidate [pycor] of candidate
  ]
  ask candidate [ set energy energy / 1.5]
end

to hatch-cocoon
  ask cocoons [
    if ticks > tick-created + inkubacja_ticki [
      ifelse( temperatura > 20 and wilgotnosc > 50) [
        hatch-spiders kokon [
          setxy random-xcor random-ycor
          set energy 30
          set health 100
          set sex random 2
          ifelse sex = 1 [set color pink][set color blue]
          set nest false
          set dc 1
          set size 0.5
          set last-molt ticks
        ]
      ][die]

      die
    ]
  ]
end

to molting
  ask spiders [
    if ticks > last-molt + wylinka_ticki [
      set last-molt ticks

      ifelse(sex = 0)[
        ;male
        ifelse(dc < max_dc) [set dc dc * 1.07][die]
        if(size < maxsize-male) [set size size * 1.07]
      ][
        ;female
        if(dc < max_dc) [set dc dc * 1.1]
        if(size < maxsize-female) [set size size * 1.1]
      ]
      if( random 10000 > 9980 ) [die]

    ]
  ]
  ;dc++ - depends on energy
  ;take some ticks?
end

to death
  if energy < 0 [ die ]
  if health <= 0 [ die ]
  ;male and old?
  ;random disease?
end

to make-nest
  if (pcolor = 32 and sex = 1 and random 1000 > 900) [
    set nest true
  ]
end

to random-disaster
  let candidate one-of cocoons-at 0 0
  if (random 1000 > 995 and sex = 1 and candidate = nobody) [set nest false]
  if (random 1000 > 995 and sex = 0) [set nest false]
end


to male-wait-to-grow-up
  if (sex = 0) [
    ifelse dc < dc_kopulacja [
      set nest true
    ][
      set nest false
    ]
  ]
end

;;Food behavior
;; need to be optimized
to spawn-food
  if random-float 10 < food_rate [
    if count bugs < max_food [
      create-bugs 1 [
        set color 3
        set size 0.5
        set energy-value random 20
        set energy random 50
        setxy random-xcor random-ycor
      ]
    ]
  ]
end

to move-food
  rt random 50
  lt random 50
  fd 1
  set energy energy - 0.1
end

to death-food
  if energy < 0 [ die ]
end

;;Statistics
to-report count-males
  let counter 0
  ask spiders [
    if sex = 0 [set counter counter + 1]
  ]
  report counter
end

to-report count-females
  let counter 0
  ask spiders [
    if sex = 1 [set counter counter + 1]
  ]
  report counter
end

to-report count-can-copulate
  let counter 0
  ask spiders [
    if (dc >= dc_kopulacja) [set counter counter + 1]
  ]
  report counter
end

to-report count-cannot-copulate
  let counter 0
  ask spiders [
    if (dc < dc_kopulacja) [set counter counter + 1]
  ]
  report counter
end

to-report count-spiders-without-nest
  let counter 0
  ask spiders [
    if (nest = false) [set counter counter + 1]
  ]
  report counter
end
@#$#@#$#@
GRAPHICS-WINDOW
274
21
732
480
-1
-1
13.64
1
10
1
1
1
0
1
1
1
0
32
0
32
0
0
1
ticks
30.0

TEXTBOX
8
15
224
34
Parametry startowe
11
0.0
1

SLIDER
9
31
119
64
ilosc_samic
ilosc_samic
0
20
16.0
1
1
NIL
HORIZONTAL

SLIDER
123
31
233
64
ilosc_samcow
ilosc_samcow
0
20
16.0
1
1
NIL
HORIZONTAL

TEXTBOX
9
70
228
89
Parametry rasy
11
0.0
1

SLIDER
8
86
232
119
agresywnosc
agresywnosc
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
9
122
232
155
kokon
kokon
1
500
35.0
1
1
NIL
HORIZONTAL

TEXTBOX
7
158
230
177
Ilość nimf wyklutych z kokonu
11
0.0
1

TEXTBOX
9
325
229
344
Parametry środowiskowe
11
0.0
1

SLIDER
10
340
236
373
temperatura
temperatura
-30
60
28.0
1
1
C
HORIZONTAL

SLIDER
10
378
238
411
wilgotnosc
wilgotnosc
0
100
84.0
1
1
%
HORIZONTAL

BUTTON
386
487
465
520
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
470
487
611
520
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
736
30
834
75
Ptaszniki
count spiders
17
1
11

SLIDER
8
282
118
315
max_dc
max_dc
0
10
10.0
1
1
cm
HORIZONTAL

SLIDER
123
282
234
315
dc_kopulacja
dc_kopulacja
0
10
7.0
1
1
cm
HORIZONTAL

SLIDER
10
416
236
449
food_rate
food_rate
0.0
10.0
7.5
0.5
1
NIL
HORIZONTAL

TEXTBOX
738
12
888
30
Monitor
11
0.0
1

MONITOR
837
30
933
75
Pożywienie
count bugs
17
1
11

SLIDER
10
454
238
487
max_food
max_food
0
1000
193.0
1
1
NIL
HORIZONTAL

TEXTBOX
13
490
233
518
Zbyt duża ilość obiektów moze powodować spowolnienia
11
0.0
1

SLIDER
9
172
231
205
inkubacja_ticki
inkubacja_ticki
0
5000
600.0
50
1
NIL
HORIZONTAL

TEXTBOX
11
212
244
255
Ilość ticków potrzebnych do wyklucia kokonu
11
0.0
1

MONITOR
838
80
933
125
Samce
count-males
17
1
11

MONITOR
736
80
834
125
Samice
count-females
17
1
11

MONITOR
736
128
834
173
Ptaszniki zdolne do kopulacji
count-can-copulate
17
1
11

MONITOR
838
128
934
173
Ptaszniki nie zdolne do kopulacji
count-cannot-copulate
17
1
11

SLIDER
10
230
234
263
wylinka_ticki
wylinka_ticki
0
2000
200.0
50
1
NIL
HORIZONTAL

TEXTBOX
11
265
254
294
Ilość ticków potrzebnych do wylinki\n
11
0.0
1

MONITOR
936
80
1033
125
Aktywne kokony
count cocoons
17
1
11

MONITOR
936
30
1033
75
Ptaszniki bez gniazda
count-spiders-without-nest
17
1
11

PLOT
736
176
1034
296
Populacja ptaszników
Czas
Ptaszniki
0.0
100.0
0.0
200.0
true
true
"" ""
PENS
"males" 1.0 0 -13345367 true "" "plot count-males"
"females" 1.0 0 -2064490 true "" "plot count-females"

PLOT
736
298
1036
418
Inkubowane kokony
Czas
Kokony
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" "plot count cocoons"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

egg
false
0
Circle -7500403 true true 96 76 108
Circle -7500403 true true 72 104 156
Polygon -7500403 true true 221 149 195 101 106 99 80 148

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

spider
true
0
Polygon -7500403 true true 134 255 104 240 96 210 98 196 114 171 134 150 119 135 119 120 134 105 164 105 179 120 179 135 164 150 185 173 199 195 203 210 194 240 164 255
Line -7500403 true 167 109 170 90
Line -7500403 true 170 91 156 88
Line -7500403 true 130 91 144 88
Line -7500403 true 133 109 130 90
Polygon -7500403 true true 167 117 207 102 216 71 227 27 227 72 212 117 167 132
Polygon -7500403 true true 164 210 158 194 195 195 225 210 195 285 240 210 210 180 164 180
Polygon -7500403 true true 136 210 142 194 105 195 75 210 105 285 60 210 90 180 136 180
Polygon -7500403 true true 133 117 93 102 84 71 73 27 73 72 88 117 133 132
Polygon -7500403 true true 163 140 214 129 234 114 255 74 242 126 216 143 164 152
Polygon -7500403 true true 161 183 203 167 239 180 268 239 249 171 202 153 163 162
Polygon -7500403 true true 137 140 86 129 66 114 45 74 58 126 84 143 136 152
Polygon -7500403 true true 139 183 97 167 61 180 32 239 51 171 98 153 137 162

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
