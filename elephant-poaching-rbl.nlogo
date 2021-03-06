globals [ max-age circle-size female-maturation-age elephant-dead ]

breed [ elephant elephants ]
breed [ poacher poachers ]

elephant-own [ age gender class ]
poacher-own [ energy max-energy ]

;; ========== setup button ==========
to setup
  clear-all

  ;; declare global variables
  set max-age 50  ;; elephants live up to 50 years old
  set circle-size 25  ;; bigger means smaller circles
  set female-maturation-age 16

  ;; environment
  ask patches [ set pcolor green + 2 ]  ;; create background with color 69

  setup-elephant
  setup-poacher

  reset-ticks
end

to setup-elephant
  create-elephant initial-number-elephants [

    ;; initial value for every agent
    set gender "male"
    set color blue
    set shape "mammoth"
    set xcor random-xcor set ycor random-ycor
    set age (random-float max-age)
    set size age / circle-size  ;; circle size grows with age

    ;; initial gender distribution is 50%
    if random 2 = 1 [
      set gender "female"
      set color pink
    ]

  ]

  display-labels
end

to setup-poacher
  create-poacher initial-number-poacher [
    set color red
    set shape "person"
    set xcor random-xcor set ycor random-ycor

    set energy 80 + ( random 200 )
    set max-energy 200
  ]
end

;; ///// end setup button




;; ========== go button ==========
to go
  ;; increase age and adjust size

  age-class  ;; divide elephant by age to 4 classes

  ask elephant [
    set age age + 0.25  ;; each step represent 3 months/a quarter of a year
    set size age / circle-size
  ]

  ;; die naturally from old age
  ask elephant [
    if age > max-age [ die ]
  ]

  ;; reproduce elephant
  ask elephant [
    give-birth
  ]

  ;; elephant random moves
  ask elephant [
    let suspected-poacher nobody
    let target-heading 0

    right (random-float 45 - random-float 45)
    forward 0.3


    ;; elephant will flee if they see poacher within 90 degree radius
    let poachers-in-view poacher in-cone 6 360
    ifelse any? poachers-in-view [
      set suspected-poacher one-of poachers-in-view
      set target-heading 180 + towards suspected-poacher
      set heading target-heading
      set label "!"
    ]
    [ set label "" ]
  ]

  ask poacher [
    move  ;; poacher can move with random direction
    hunt  ;; whenever poacher meets elephant, the elephant die
    if energy > max-energy [ die ]

    display-energy
  ]

  tick

  display-labels

  ;; stop simulation
  ;; stop case: end of period / extinction case (elephant = 0)
  if count elephant = 0 or period = ticks / 4 [ stop ]

end

to give-birth
  ;; female elephant giving birth
  if gender = "female" and age >= female-maturation-age and random-float 1 < 0.17 and round age mod 11 = 0[
    ;; default values
    let offspring-gender "male"
    let offspring-color blue

    if random 2 = 1
    [
      set offspring-gender "female"
      set offspring-color pink
    ]

    ;; hello world from baby elephant
    hatch 1 [
      set age 1
      set gender offspring-gender
      set size age / circle-size
      set color offspring-color
      set xcor random-xcor set ycor random-ycor
    ]
  ]
end

to move
  left random 90
  right random 90
  forward 1
  set energy energy - 4
end

to hunt
  ask poacher [
    if any? elephant-here [
      ask elephant-here [
        ;; elephant survival rate based on age class
        if class = "calf" [
          if random-float 1 < 0.15 [ die ]
        ]
        if class = "juvenile" [
          if random-float 1 < 0.04 [ die ]
        ]
         if class = "subadult" [
          if random-float 1 < 0.02 [ die ]
        ]
        if class = "adult" [
          if random-float 1 < 0.15 [ die ]
        ]
      ]
      set elephant-dead elephant-dead + 1
    ]

    set energy energy - 8
  ]
end

to age-class
  ask elephant [
    set class (ifelse-value
      age <= 1 [ "calf" ]
      age > 1 and age <= 5 [ "juvenile" ]
      age > 5 and age <= 15 [ "subadult" ]
      age > 15 [ "adult" ]
    )
  ]
end

;; ///// end go button




;; global ??????smthng
to display-labels
  ask elephant [ set label "" ]
  if show-age? [
    ask elephant [ set label precision age 2 ]
  ]
end

to display-energy
  ask poacher [ set label "" ]
  if show-energy? [
    ask poacher [ set label precision (energy) 0 ]
  ]
end




;; ========== for plotting ==========

; count number of male elephant
to-report count-males
  ifelse count elephant with [ gender = "male" ] > 0 [
    report count elephant with [ gender = "male" ]
  ]
  [ report 0 ]
end

; count number of female elephant
to-report count-females
  ifelse count elephant with [ gender = "female" ] > 0 [
    report count elephant with [ gender = "female" ]
  ]
  [ report 0 ]
end

; mean age of living male elephants
to-report mean-age-males
  ifelse count elephant with [ gender = "male" ] > 0 [
    report mean [ age ] of elephant with [ gender = "male" ]
  ]
  [ report 0 ]
end

; mean age of living female elephants
to-report mean-age-females
  ifelse count elephant with [ gender = "female" ] > 0 [
    report mean [ age ] of elephant with [ gender = "female" ]
  ]
  [ report 0 ]
end

; number of elephants based on age class
; use straight in plot interface

;; / end plotting
@#$#@#$#@
GRAPHICS-WINDOW
313
35
1162
499
-1
-1
13.8
1
10
1
1
1
0
1
1
1
-30
30
-16
16
0
0
1
ticks
30.0

TEXTBOX
15
10
648
39
Simulation of Illegal Poaching of Sumateran Elephant using Agent-Based Modeling
15
0.0
1

BUTTON
14
52
77
85
NIL
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
91
53
154
86
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
167
53
230
86
NIL
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

SLIDER
14
98
196
131
initial-number-elephants
initial-number-elephants
1
1000
37.0
1
1
NIL
HORIZONTAL

SLIDER
14
137
187
170
initial-number-poacher
initial-number-poacher
0
50
1.0
1
1
NIL
HORIZONTAL

INPUTBOX
13
186
96
246
period
500.0
1
0
Number

MONITOR
400
509
457
554
year
ticks / 4
2
1
11

PLOT
1180
35
1557
218
number of elephant
year
number elephant
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"male" 1.0 0 -13345367 true "" "plot count-males"
"female" 1.0 0 -2064490 true "" "plot count-females"

PLOT
1180
224
1380
374
Mean Age
year
mean age
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"females" 1.0 0 -2064490 true "" "plot mean-age-females"
"males" 1.0 0 -13345367 true "" "plot mean-age-males"

MONITOR
467
508
557
553
total elephant
count elephant
0
1
11

BUTTON
243
54
306
87
go 10
repeat 10 [ go ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
564
509
680
554
NIL
mean-age-females
2
1
11

SWITCH
13
253
129
286
show-age?
show-age?
1
1
-1000

MONITOR
687
509
791
554
elephant hunted
elephant-dead
17
1
11

PLOT
1179
379
1520
529
number of elephant based on age class
year
number of elephant
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"calf" 1.0 0 -2382653 true "" "plot count elephant with [ class = \"calf\" ]"
"juvenile" 1.0 0 -11033397 true "" "plot count elephant with [ class = \"juvenile\" ]"
"subadult" 1.0 0 -955883 true "" "plot count elephant with [ class = \"subadult\" ]"
"adult" 1.0 0 -15040220 true "" "plot count elephant with [ class = \"adult\" ]"

SWITCH
133
253
267
286
show-energy?
show-energy?
1
1
-1000

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

mammoth
false
0
Polygon -7500403 true true 195 181 180 196 165 196 166 178 151 148 151 163 136 178 61 178 45 196 30 196 16 178 16 163 1 133 16 103 46 88 106 73 166 58 196 28 226 28 255 78 271 193 256 193 241 118 226 118 211 133
Rectangle -7500403 true true 165 195 180 225
Rectangle -7500403 true true 30 195 45 225
Rectangle -16777216 true false 165 225 180 240
Rectangle -16777216 true false 30 225 45 240
Line -16777216 false 255 90 240 90
Polygon -7500403 true true 0 165 0 135 15 135 0 165
Polygon -1 true false 224 122 234 129 242 135 260 138 272 135 287 123 289 108 283 89 276 80 267 73 276 96 277 109 269 122 254 127 240 119 229 111 225 100 214 112
Polygon -16777216 true false 225 60 195 45 195 105 225 90 225 60

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
