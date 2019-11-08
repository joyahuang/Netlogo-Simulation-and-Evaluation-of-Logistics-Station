extensions [gis nw]
breed [mailboxes mailbox]
breed[mailmans mailman]
breed[bases base]
breed[nodes node]
undirected-link-breed [roads road]
mailboxes-own [ num ;邮箱里面邮件的数量
  maxnum ;邮箱最大承载力
  explode? ;是否爆仓
  NO.
  chosen?
  t
]
 mailmans-own [ goal
  goal?
  start
  carryingnum
full?;快递员是否满载
  manmaxnum
  alongpoints
  start-time
  step
  father
]
 bases-own [
  capicity

carriednum]
roads-own [weight]
patches-own [landuse]
turtles-own [point-type  people]

globals[

  DS_Road
  DS_Point
  DS_Block
  wot
  a1
  b1
  alongpoints-now
  total-walking-distance
  av-walking-distance
  total-carried-num
]

to setup
   ca
  reset-ticks
  set-current-directory "D:\\导入文件"
  ask patches [set pcolor white]
  set DS_Road gis:load-dataset "Export_Road.shp"
  set DS_Point gis:load-dataset "Export_Point.shp"
  set DS_Block gis:load-dataset "Export_Block.shp"
let enve_gis ( gis:envelope-union-of ( gis:envelope-of DS_Road)( gis:envelope-of DS_Point)( gis:envelope-of DS_Block))
   let enve_world (list (min-pxcor + 1) (max-pxcor - 1) (min-pycor  + 1) (max-pycor - 1))
  gis:set-transformation enve_gis enve_world
  build-road

  gis:draw DS_Block 0.3
  set-mailboxes  ;设置每个小小区的寄件箱的属性
set total-carried-num 0
  set total-walking-distance 0
end

to build-road
  let node_prev nobody
  let location []
  let existed_node nobody
  let node_now nobody
  let distance_now 0
  foreach gis:feature-list-of DS_Road [[ft] ->
    foreach gis:vertex-lists-of ft [[vtl] ->
      set node_prev nobody
      foreach vtl [[vt] ->
        set location gis:location-of vt
        set existed_node one-of nodes with [(xcor = item 0 location and ycor = item 1 location) ]
        ifelse existed_node != nobody
          [set node_now existed_node]
          [create-nodes 1 [
              set shape "circle"
              set size 0.1
              set xcor item 0 location
              set ycor item 1 location
              set color black
              set node_now self]
          ]
        if node_prev != nobody [
          ask node_now [
            create-road-with node_prev [
              set color black
              set weight link-length
            ]
          ]
        ]
        set node_prev node_now
      ]
    ]
  ]

end


to set-mailboxes
  let location []
  let a 0
  let b 0
  let j 1

  foreach gis:feature-list-of DS_Point [[ft] ->
    foreach gis:vertex-lists-of ft [[vtl] ->
      foreach vtl [[vt] ->
        set location gis:location-of vt
        set a (item 0 location)
        set b (item 1 location)
        ask turtles with [distancexy (a)(b) < 0.1 ][
          set point-type gis:property-value ft "POINTTYPE"
          if point-type = 1 [
            set people gis:property-value ft "PEOPLE"] ;house里居民人口总数
        ]
      ]
    ]
  ]

  ask turtles with [point-type = 1] [;每个地块中央的点即mailbox所在地
    set breed mailboxes
   ; set NO. j
    set shape "circle"
    set color yellow
    set size 10
    set t 0
    set num 0
    set chosen? false
    set explode? false ;每个mailbox爆仓设为false
    set maxnum people * 0.5 ;寄件箱的容量和人口成正比
   ; set j j + 1
   ]
   end
to set-bases
   if mouse-inside? and mouse-down?[
    create-bases 1 [
      setxy mouse-xcor mouse-ycor
      set shape "flag"
      set color red
      set size 20
      set a1 [xcor] of self
      set b1 [ycor] of self
      set carriednum 0
      set capicity read-from-string (user-input "快递小哥的容量?")      ;;输入框输入

      set wot [who] of self
       hatch-mailmans 1
       set-mailmans]
       create-nodes 1  [ setxy a1   b1
       create-road-with min-one-of other nodes [distance myself] [set color black set weight link-length]]
       ask mailboxes [set t 0]]
end

to set-mailmans ;基本属性，
  ask mailmans with [xcor = a1 and ycor = b1]
  [set alongpoints []
  set goal nobody
  set full? false
  set goal? false
  set color blue
  set size 30
  set shape "person"
  set carryingnum 0

  set alongpoints []
  set father one-of bases with [who = wot]
    set manmaxnum [capicity] of father
 ]
end


to go
  tick
  create-mails
  find-goal
  move-to-goal
  if total-carried-num != 0
  [set av-walking-distance total-walking-distance / total-carried-num]
    ask max-n-of 4 mailboxes [t] [
    if t != 0[
      set shape "face sad" set size 20] ]
    ask min-n-of 6 mailboxes[t] [set size 10 set  shape "circle"]
end


to create-mails

 ask mailboxes[
    if explode? = true [set t t + 1]
  if ticks mod create-mail-interval = 0
    [if explode? = false
     [set num num + people * 0.1  ]]
    if num >= maxnum [ set explode? true  set color red]]
end



to find-goal
 ask mailmans with [full? = false and goal? = false][
    let a [xcor] of self
    let b [ycor] of self
    let c one-of turtles with [breed != mailmans and breed != bases and distancexy (a)(b) < 0.1 ]
    ifelse any? mailboxes with[explode? = true and  chosen? = false][
      set goal min-one-of mailboxes with[explode? = true and chosen? = false and distancexy (a)(b) > 1][nw:weighted-distance-to c weight]
      ask goal [set chosen? true]
      set goal? true
     ask c[
      set alongpoints-now nw:turtles-on-weighted-path-to [goal] of myself weight]
      set alongpoints  alongpoints-now
      set step 1]
  [
    set goal min-one-of mailboxes with  [chosen? = false and distancexy (a)(b) > 1 ][nw:weighted-distance-to c weight]
      ask goal [set chosen? true]
      set goal? true]

    ask c[
      set alongpoints-now nw:turtles-on-weighted-path-to [goal] of myself weight]

      set alongpoints  alongpoints-now
      set step 1]


   ask mailmans with [full? = true and goal? = false][
    let a [xcor] of self
    let b [ycor] of self
    let c one-of turtles with [breed != mailmans and distancexy (a)(b) < 0.1 ]
    set goal min-one-of nodes[ distance [father] of myself]
    set goal? true
    ask c[
      set alongpoints-now nw:turtles-on-weighted-path-to [goal] of myself weight]

      set alongpoints  alongpoints-now
      set step 1]
end

to move-to-goal
  ask mailmans [
    face item step alongpoints
    ifelse distance item step alongpoints <= speed
    [let part_speed distance item step alongpoints
     forward part_speed
      set total-walking-distance total-walking-distance + part_speed
      ifelse step = length alongpoints - 1
      [pick]
      [set step step + 1
        face item step alongpoints
        forward (speed - part_speed)
    set total-walking-distance total-walking-distance + speed - part_speed]]
    [forward speed
      set total-walking-distance total-walking-distance + speed ]]
end


to pick
  ifelse distance father < 0.1 [
    ask one-of bases with [ xcor = [xcor] of [father] of myself and ycor = [ycor] of [father] of myself][
      set carriednum carriednum + capicity
   ]
      set carryingnum 0
      set full? false
      set color blue ]
 [
  ifelse [num] of goal <= manmaxnum - carryingnum
  [set carryingnum  [num] of goal + carryingnum
   set total-carried-num total-carried-num + [num] of goal
    ask goal
    [ set num 0
      set chosen? false
      set explode? false
      set color yellow]]
  [  ask goal
    [ set num num - [manmaxnum] of myself + [carryingnum] of myself
        set total-carried-num total-carried-num + [manmaxnum] of myself - [carryingnum] of myself
      set explode? false
      set color yellow
      set chosen? false]
      set carryingnum manmaxnum
      set full? true
      set color red]]
  set goal? false
  set goal nobody

end

to base-output
  ask mailboxes
  [ set label  who
  set label-color black]
 ask bases [
    output-type  "base\tcarriednum\n"
    output-type  who output-type "\t\t"
  output-type  precision carriednum 2 output-type "\t\t\t\t"
  ]

end

to output
   output-type "\ntotal-walking-distance\t" output-type precision total-walking-distance 2
  output-type "\nav-walking-distance\t" output-type precision av-walking-distance 2
end
@#$#@#$#@
GRAPHICS-WINDOW
230
10
739
520
-1
-1
1.0
1
10
1
1
1
0
0
0
1
-250
250
-250
250
0
0
1
ticks
30.0

BUTTON
34
35
101
68
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
36
93
131
126
NIL
set-bases
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
20
287
215
320
create-mail-interval
create-mail-interval
0
100
26.0
1
1
h
HORIZONTAL

BUTTON
33
139
96
172
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

PLOT
993
240
1193
390
total-walking-distance
time
distance
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks (total-walking-distance)"

PLOT
776
239
976
389
av-walking-distance
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
"default" 1.0 0 -16777216 true "" "plotxy ticks (av-walking-distance)"

SLIDER
34
195
206
228
speed
speed
0
100
23.0
1
1
NIL
HORIZONTAL

OUTPUT
775
13
1485
202
13

BUTTON
34
240
142
273
base_output
base-output
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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
NetLogo 6.0.4
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
