turtles-own
  [ susceptible?
    exposed?             ;; if true -> person exposed
    infected?            ;; if true -> person infected
    immunity?            ;; if true -> person immune (removed)
    tested?              ;; if true -> person has been tested
    confirmed?           ;; if true -> person has been confirmed about his infection
    isolated?            ;; if true -> person has been isolated
    exposed-time         ;; how long, in days, the person has been exposed
    infected-time        ;; how long, in days, the person has been infected
    immunity-time        ;; how long, in days, the person has been immune
    tested-time          ;; how long, in days, the person has been tested
    confirmed-time       ;; how long, in days, the person has been confirmed about his infection
    isolated-time        ;; how long, in days, the person has been isolated
    secondary-cases-live ;; how many people has infected an agent while it is infected and live
    ]

globals
  [ %susceptible
    %exposed             ;; what % of the population is exposed
    %infected            ;; what % of the population is infected
    %immune              ;; what % of the population is immune (recovered)
    %tested              ;; what % of the population has been tested
    sec-cases            ;; auxiliar to set secondary cases
    ;;%test_app
    exposed-constant     ;; disease parameters in days
    infected-constant    ;; disease parameters in days
    infection-rate       ;; live to susceptible infection rate
    testing-iteration    ;; current iteration of the testing strategy
    testing-day          ;; current day of the testing iteration
    max-agents ]         ;; the number of persons that can be in the world at the same time

to setup
  clear-all
  setup-constants
  setup-agents
  update-global-variables
  update-display
  reset-ticks
end

;; We create a variable number of turtles of which 10 are infectious,
;; and distribute them randomly
to setup-agents
  create-turtles total-agents
    [ setxy random-xcor random-ycor
      set exposed-time 0
      set infected-time 0
      set immunity-time 0
      set size 1.5  ;; easier to see
      set susceptible? true
      set exposed?   false
      set infected?  false
      set immunity?  false
      set tested?    false
      set confirmed? false
      set isolated?  false
      set secondary-cases-live 0
  ]
  ask n-of init-infected turtles
    [ get-infected  ]
end

;;Here the persons changes its states
to get-exposed
  set susceptible? false
  set exposed? true
  set exposed-time 0
  ;;set awareness 0
end

to get-infected
  set susceptible? false
  set infected?    true
  set exposed?     false
  ;;set tested?    false ;; In this way a tested person that get infected after the test, doesn't get isolated.
  set infected-time 0
end

to get-immunity
  set infected? false
  set immunity? true
  set immunity-time 0
end

to testing
  set tested? True
  set tested-time 0
end

to reset-testing
  set tested? False
  set tested-time 0
end

to get-confirmed
  set confirmed? True
  set confirmed-time 0
end

to get-isolated
  set isolated? True
  set isolated-time 0
end
;;End change of states

;; This sets up basic constants of the model.
to setup-constants
  set max-agents 10000
  set exposed-constant 5
  set infected-constant 14
  set infection-rate 0.15
  ;;set testing-day 1
end

to go
    if (ticks) mod testing-length = 0 [  ;; do not use testing-lenght 0
    ask turtles [reset-testing]
    ;;set testing-length 1
  ]

  ask turtles [
    get-older
    if not isolated? [move]
    if exposed? and exposed-time >= exposed-constant [get-infected]
    if infected? and not isolated? [infect]
    if infected? and infected-time >= infected-constant [get-immunity]
    if infected? and tested? and infected-time >= tested-time and (random-float 100 < 100 * test-efficacy) and random-float 100 <= qua-adoption [get-confirmed];[get-isolated]
    if confirmed? and (confirmed-time >= qua-adoption-time) [get-isolated]
  ]

  ;; This "if" avoid a problem when there are too many tested agent
  ifelse count turtles with [not tested?] > 0 and (max-agents * %test_app) < count turtles with [not tested?][
  ask n-of (max-agents * %test_app) turtles with [not tested?] ;; These actions applies to every non-tested agent. Percentage.
               [;;print "if one"
                ;;print turtles with [not tested?]
                    testing]
  ]
  [ask turtles with [not tested?] ;; These actions applies to every non-tested agent. Percentage.
               [print "if two"
                ;;print turtles with [not tested?]
                testing]
  ]

  update-global-variables
  update-display
  tick
  ;;export-view (word ticks ".png")
end

;; Turtle counting variables are advanced.
to get-older ;; turtle procedure
  if exposed?  [ set exposed-time exposed-time + 1 ]
  if infected? [ set infected-time infected-time + 1 ]
  if immunity? [ set immunity-time immunity-time + 1 ]
  if tested?   [ set tested-time tested-time + 1 ]
  if confirmed?[ set confirmed-time confirmed-time + 1 ]
  if isolated? [ set isolated-time isolated-time + 1 ]
end

;; Turtles moves random.
to move ;; turtle procedure
  fd 1
end

;; If a turtle is infected, it infects other turtles on the same patch.
;; Immune turtles don't get sick.
to infect ;; turtle procedure
  set sec-cases 0
  ask other turtles-here with [ not exposed? and not infected? and not immunity?]
    [ if random-float 100 < 100 * infection-rate ;;infectiousness
      [ get-exposed
        set sec-cases (sec-cases + 1)
      ]
  ]
  set secondary-cases-live (secondary-cases-live + sec-cases)

end

to update-global-variables
 set %susceptible (count turtles with [ susceptible? ] / count turtles) * 100
 set %exposed (count turtles with [ exposed? ] / count turtles) * 100
 set %infected (count turtles with [ infected? ] / count turtles) * 100
 set %immune (count turtles with [ immunity? ] / count turtles) * 100
 set %tested (count turtles with [ tested? ] / count turtles) * 100

end

to update-display
  ask turtles
    [ if shape != turtle-shape [ set shape turtle-shape ]
      if susceptible? [set color green]
      if exposed? [set color orange]
      if infected? [set color red]
      if immunity? [set color grey]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
0
10
325
336
-1
-1
3.08
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
102
0
102
0
0
1
ticks
30.0

BUTTON
1051
13
1141
46
Setup
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

SLIDER
1241
55
1413
88
total-agents
total-agents
10
max-agents
0.0
1
1
NIL
HORIZONTAL

BUTTON
1049
60
1112
93
go
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

CHOOSER
1642
737
1780
782
turtle-shape
turtle-shape
"person" "circle" "turtle"
0

PLOT
649
465
1025
728
States
time
persons
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"susceptible" 1.0 0 -10899396 true "" "plot count turtles with [susceptible?]"
"exposed" 1.0 0 -955883 true "" "plot count turtles with [exposed?]"
"infected" 1.0 0 -2674135 true "" "plot count turtles with [infected?]"
"removed" 1.0 0 -7500403 true "" "plot count turtles with [immunity?]"

SLIDER
1244
10
1416
43
init-infected
init-infected
1
total-agents
6561.0
1
1
NIL
HORIZONTAL

SLIDER
1444
11
1616
44
%test_app
%test_app
0
0.5
0.5
0.01
1
NIL
HORIZONTAL

PLOT
1062
465
1399
731
Tested
days
tested
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [tested?]"

PLOT
1428
465
1775
727
Quarantined
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Isolated" 1.0 0 -16777216 true "" "plot count turtles with [isolated?]"
"iso tested" 1.0 0 -7500403 true "" "plot count turtles with [isolated? and tested?]"

SLIDER
1444
59
1616
92
testing-length
testing-length
1
30
30.0
1
1
NIL
HORIZONTAL

MONITOR
1061
405
1118
450
tested
count turtles with [tested?]
17
1
11

MONITOR
1135
406
1192
451
day
ticks
17
1
11

MONITOR
649
407
738
452
Susceptible
%susceptible
17
1
11

MONITOR
758
408
831
453
Removed
%immune
17
1
11

BUTTON
1125
60
1188
93
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
1445
107
1617
140
test-efficacy
test-efficacy
0
1
0.9
0.01
1
NIL
HORIZONTAL

MONITOR
1428
401
1522
446
Quarantined
count turtles with [isolated?]
17
1
11

SLIDER
1448
156
1620
189
qua-adoption
qua-adoption
0
100
90.0
1
1
NIL
HORIZONTAL

SLIDER
1450
207
1639
240
qua-adoption-time
qua-adoption-time
0
7
0.0
1
1
NIL
HORIZONTAL

PLOT
654
50
984
265
Secondary cases
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"histogram" 1.0 1 -16777216 true "" "histogram  [secondary-cases-live] of turtles with [not susceptible? and not exposed?]"

MONITOR
862
408
947
453
prevalence
count turtles with [infected?] / count turtles * 100
17
1
11

MONITOR
655
285
712
330
R0
mean [secondary-cases-live] of turtles with [not susceptible? and not exposed?]
17
1
11

PLOT
345
49
625
265
Re
NIL
NIL
0.0
10.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [secondary-cases-live] of turtles with [not susceptible? and not exposed?]"

MONITOR
759
288
892
333
sum sec cases
sum [secondary-cases-live] of turtles with [not susceptible? and not exposed?]
17
1
11

@#$#@#$#@
## WHAT IS IT?

The SEIRTQ agent-based simulation model tests different testing strategies for a population. The model considers factors such as the percentage of people tested, the length of the testing cycle, the efficacy of the tests, the percentage of people who adopt quarantine measures, and the time it takes for people to adopt quarantine measures.

The model simulates the spread of an infectious disease through a population and assesses the effectiveness of different testing strategies in controlling the spread of the disease. The model uses agents to represent individuals in the population, and each agent has a set of attributes that determine how it will behave in response to the disease.

Overall, the SEIRTQ agent-based simulation model is a useful tool for analyzing the effectiveness of different testing strategies in controlling the spread of infectious diseases. It allows users to experiment with different scenarios and assess the potential impact of different testing strategies on the spread of the disease.

## HOW IT WORKS

The agents in the simulation move one patch per time-step and are able to infect any other agents in the same patch. At the same time, all agents are susceptible to be tested, regarding the set rules. The testing strategy is periodic, with a cycle that lasts from one to thirty days. At the end of each cycle, all agents can be tested again. Once an agent has been tested within a cycle, they cannot be tested again until the next cycle begins.

## HOW TO USE IT

- init-infected: number of initial infected agents.
- total-agents: number of total initial agents.
- %test_app: percentage of people tested in one time-step.
- testing-length: length of a strategy cycle.
- test-efficacy: percentage of tests that are applied that detect an infected agent.
- qua-adoption: percentage of tested infected agent that adopt the quarantine.
- qua-adoption-time: days that elapse until tested infected agent adopt quarantine.

## CREDITS AND REFERENCES

If you use this ABMs, please cite: COVID-19 SUPPRESSION USING A TESTING/QUARANTINE STRATEGY: A multi-paradigm simulation approach based on a SEIRTQ compartmental model, Ropert, Bernardin, Perez-Acle 2022, WSC.
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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="init-infected">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-agents">
      <value value="10000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
  </experiment>
  <experiment name="015per-beta012" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-015per-beta012.csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
  </experiment>
  <experiment name="var_beta" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta.csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <steppedValueSet variable="infection-rate" first="0.1" step="0.01" last="0.2"/>
  </experiment>
  <experiment name="var_beta2" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta2.csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <steppedValueSet variable="infection-rate" first="1" step="0.1" last="2"/>
  </experiment>
  <experiment name="015per-beta015" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-015per-beta015.csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
  </experiment>
  <experiment name="0per-beta015" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-0per-beta015.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
  </experiment>
  <experiment name="15per-beta015" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-15per-beta015.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
  </experiment>
  <experiment name="5per-beta015" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-5per-beta015.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
  </experiment>
  <experiment name="10per-beta015" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-10per-beta015.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
  </experiment>
  <experiment name="20per-beta015" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-20per-beta015.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
  </experiment>
  <experiment name="25per-beta015" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-25per-beta015.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
  </experiment>
  <experiment name="var_beta-var_per_test" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test.csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
  </experiment>
  <experiment name="var_beta-var_per_test-1delay" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test-1delay.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
    <enumeratedValueSet variable="qua-adoption-time">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="var_beta-var_per_test-2delay" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test-2delay.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
    <enumeratedValueSet variable="qua-adoption-time">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="var_beta-var_per_test-3delay" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test-3delay.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
    <enumeratedValueSet variable="qua-adoption-time">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="var_beta-var_per_test-4delay" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test-4delay.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
    <enumeratedValueSet variable="qua-adoption-time">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="var_beta-var_per_test-5delay" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test-5delay.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
    <enumeratedValueSet variable="qua-adoption-time">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="var_beta-var_per_test-6delay" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test-6delay.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
    <enumeratedValueSet variable="qua-adoption-time">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="var_beta-var_per_test-7delay" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-var_beta-var_per_test-7delay.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ isolated? ]</metric>
    <metric>[secondary-cases-live] of turtles with [not susceptible? and not exposed?]</metric>
    <steppedValueSet variable="infection-rate" first="0.11" step="0.01" last="0.2"/>
    <steppedValueSet variable="%test_app" first="0" step="0.01" last="0.2"/>
    <enumeratedValueSet variable="qua-adoption-time">
      <value value="7"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
