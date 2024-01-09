globals [ PequenoPorte  GrandePorte kills-lions kills-hienas]

; Definindo as raças de agentes para leões e hienas
breed [lions lion] ; Cria a raça "lions" para representar leões
breed [hyenas hyena] ; Cria a raça "hyenas" para representar hienas

turtles-own [energia espera Flag nivel-agrupamento] ;energia dos leoes e hienas

to setup

    clear-all  ; Limpa o ambiente, removendo todos os agentes e patches
    setup-patches  ; Chama o procedimento para configurar os patches (células do ambiente)
    setup-turtles  ; Chama o procedimento para configurar os agentes
    fucEnergia  ; Chama o procedimento para configurar a energia dos agentes
    reset-ticks   ; Reinicia o contador de ticks para 0
end

to setup-patches

    clear-all ; Limpa o ambiente, removendo todos os patches.
    set-patch-size 15 ; Define o tamanho dos patches para 15 unidades.

end

to go
  change-hyena-color ; Chama o procedimento para mudar a cor das hienas
  ; Movimenta os leões
  MoveLions
  ; Movimenta as hienas
  MoveHyenas

  ; Loop através dos leões
  ask lions [
    ; Reduz a energia dos leões se não estiverem em uma área azul; em 1 unidade a cada iteração (tick)
    if pcolor != blue [ set energia energia - 1 ]


    combate-lions


  ]

  ; Loop através das hienas
  ask hyenas [
    ; Reduz a energia das hienas em 1 unidade a cada iteração (tick)
    set energia energia - 1


    if (nivel-agrupamento > 1)[  combate-hyenas]


  ]

  ; Gera novas células de pequeno porte com 40% de probabilidade
  if random-float 100 < 40 [
    NewPequenoPorte
  ]

  fucEnergia
  ; Todos os agentes com energia 0, morrem
  check-death

  ; Verifica as condições de término da simulação
  if ticks = 600 or (count hyenas = 0) or (count lions = 0) [
    ; Encerra a simulação
    stop
  ]
  ; Incrementa o contador de ticks
  tick
end



to setup-turtles
  clear-all;
  ; Configuração de células de grande porte (vermelhas)
  ask patches with [pcolor = black] [
    ; Verifica se as células de grande porte devem ser criadas com base na probabilidade nCelulasGrandePorte
    if random-float 100 < nCelulasGrandePorte [
      set pcolor red
    ]
  ]



  ; Configuração de células de pequeno porte (castanhas)
  ask patches with [pcolor = black] [
    ; Verifica se as células de pequeno porte devem ser criadas com base na probabilidade nCelulasPequenoPorte
    if random-float 100 < nCelulasPequenoPorte [
      set pcolor brown
    ]
  ]

  ; Configuração de células azuis
  if nAzul > 0 [
    repeat nAzul [
      ; Cria células azuis em patches pretos
       ask one-of patches with [pcolor = black] [
        set pcolor blue
      ]
    ]
  ]

    if veneno?[

      ask patches with [pcolor = black] [
    ; Verifica se as células de pequeno porte devem ser criadas com base na probabilidade nCelulasPequenoPorte
    if random-float 100 < nCelulasVeneno [
      set pcolor pink
    ]
  ]


  ]


  ; Criação de leões
  create-lions nlions [
    set size 1.5
    set shape "wolf 4"
    set color yellow
    set espera 0
    set Flag 0
    set energia nEnergiaInicio ; Define a energia inicial
    ; Define a posição inicial, evitando células vermelhas, azuis ou castanhas
    setxy random-xcor random-ycor
    while [[pcolor] of patch-here = red or [pcolor] of patch-here = blue or [pcolor] of patch-here = brown] [
      setxy random-xcor random-ycor
    ]
  ]

  ; Criação de hienas
create-hyenas nhyenas [
    set size 1.25
    set shape "wolf 3"
    set color white
    set espera 0
    set energia nEnergiaInicio ; Define a energia inicial
    setxy random-xcor random-ycor
     ; Define o nível de agrupamento como 1
    set nivel-agrupamento 1
    while [[pcolor] of patch-here = red or [pcolor] of patch-here = blue or [pcolor] of patch-here = brown] [
        setxy random-xcor random-ycor
    ]
]
  ; Função para exibir as energias dos turtles
  fucEnergia
end


to comida


  if veneno?[
   if pcolor = pink [
    set energia energia / perdaVeneno
   ]
  ]

  ; Verifica se a opção MaxEnergia? está ativada
  ifelse MaxEnergia? [

        ; Se a cor do patch for castanho e o ganho de energia não exceder o limite máximo
    if pcolor = brown and (nMaxEnergia >= (energia + GanhoPequeno)) [
      ; Aumenta a energia e muda a cor para preto
      set pcolor black
      set energia energia + GanhoPequeno
    ]
    ; Se a cor do patch for vermelha e o ganho de energia não exceder o limite máximo
    if pcolor = red and (nMaxEnergia >= (energia + GanhoGrande)) [
      ; Aumenta a energia e muda a cor para marrom
      set energia energia + GanhoGrande
      set pcolor brown
    ]
  ]
  [
    ; Se a opção MaxEnergia? não está ativada, o ganho de energia não é verificado
    ifelse pcolor = red [
      ; Aumenta a energia e muda a cor para marrom
      set energia energia + GanhoGrande
      set pcolor brown
    ][
    ; Se a cor do patch for castanho
    if pcolor = brown [
      ; Aumenta a energia e muda a cor para preto
      set pcolor black
      set energia energia + GanhoPequeno
    ]
  ]
]
end

to MoveLions

  ask lions [

   ifelse espera = 0 [ ; so anda quando o tempo de espera acabar


    ifelse pcolor = blue and Flag = 0 [; nao entra no if caso o tempo de espera ja tenha acabado, fazendo com que nao fique preso
      set Flag 1
      set espera segDescanso
    ][

        ifelse Flag = 1 [
          set Flag 0
          if(move-especial-l = false)[fd 1]

        ]; faz com que a operacao a seguir seja obrigatoriamente andar para a frende

        [
     ifelse (move-especial-l = false)[
     reproduzir
    ; Verifica a energia do leão
    if energia < num_def_utilizador [
      ; Verifica o patch à frente
        ifelse patch-ahead 1 = red [ fd 1  comida]
      [
        ifelse patch-ahead 1 = brown [fd 1  comida]

        [ ; Se não houver patches à frente para comer, verifica nas laterais e roda realizado apenas 1 iteracao por tick
          ifelse [pcolor] of patch-right-and-ahead 90 1 = red [ rt 90 ]

          [
             ifelse [pcolor] of patch-left-and-ahead 90 1 = red [lt 90]
            [
              ifelse [pcolor] of patch-right-and-ahead 90 1 = brown [ rt 90 ]
              [
                 ifelse [pcolor] of patch-left-and-ahead 90 1 = brown [lt 90]
                [
                ]
              ]
            ]
          ]
        ]
      ]
    ]

    ; Comportamento alimentar e movimentação aleatória
    ifelse random 101 <= 90 [
      fd 1
      comida
    ]
    [
      ifelse random 101 <= 20 [
        rt 90  ; 20% das vezes vira à direita
      ]
      [
        lt 90  ; 20% das vezes vira à esquerda
      ]
    ]
   ][]
   ]
  ]
 ]

    [ set espera espera - 1]; decrementa enquanto os ticks avancao
]

end

to MoveHyenas

  ask hyenas [
    ; Função de reprodução das hienas
    if (nivel-agrupamento > 1)[ reproduzir]
    if [pcolor] of patch-ahead 1 != blue [
        ; Se a energia está abaixo de um limite, verifique a cor do patch à frente
        ifelse [pcolor] of patch-ahead 1 = red or [pcolor] of patch-ahead 1 = brown [
          ; Se a cor à frente é vermelha ou castanha, mova-se para frente e realize ação de alimentação
          fd 1   ; Move-se para frente
         comida

        ]
        [
          ; Senão, verifique as laterais
          ifelse ([pcolor] of patch-left-and-ahead 90 1 = red or [pcolor] of patch-left-and-ahead 90 1 = brown) [
            lt 90;
            ; Se a cor à esquerda é vermelha ou castanha, mova-se para frente

          ]
          [
            ifelse ([pcolor] of patch-right-and-ahead 90 1 = red or [pcolor] of patch-right-and-ahead 90 1 = brown) [
              rt 90;
              ; Se a cor à esquerda é vermelha ou castanha, mova-se para frente
            ]
            [
              ; Comportamento aleatório (90% de chance de mover-se para frente e comer)
              ifelse random 101 <= 90 [
                fd 1
               comida

              ]
              [
                ; 10% de chance de virar à esquerda ou à direita
                ifelse random 101 <= 50 [
                  lt 90
                ]
                [
                  rt 90
                ]

              ]
            ]
          ]
        ]
    ]
     ask hyenas in-radius max-pxcor [ set heading [heading] of myself ]
  ]

end

; Todos os agentes com energia 0, morrem
to check-death
  ask turtles
  [
    if energia <= 0
    [
      die
    ]
  ]
end

to reproduzir ; Função de reprodução

  if Reproducao? [
    ; Verifica se o animal tem energia suficiente para reprodução
    if energia >= num_def_utilizador [
      ; Verifica se a reprodução ocorre com base na probabilidade
      if random-float 100 < probRepr [
        ; Reduz a energia pela metade para reprodução e cria um descendente
        set energia (energia / 2)
        hatch 1 [ rt random-float 360 fd 1 ]
      ]
    ]
  ]
end

to fucEnergia
  ; Limpa os rótulos de todos os agentes
  ask turtles [ set label "" ]

  ; Verifica se a opção de mostrar energia está ativada
  if MostrarEnergia? [
    ; Mostra o valor arredondado da energia dos leões
    ask lions [ set label round energia ]
    ; Mostra o valor arredondado da energia das hienas
    ask hyenas [ set label round energia ]
  ]
end

to NewPequenoPorte ; Cria novas células de pequeno porte
  ; Seleciona aleatoriamente um patch que atenda a condições específicas
  ask one-of patches with [not any? turtles-here and pcolor != blue and pcolor != red and pcolor != brown]
  ; Define a cor do patch como marrom
  [ set pcolor brown ]
end

to change-hyena-color
  ask hyenas [
    set nivel-agrupamento 1 ; Define o nível de agrupamento como 1
    let nearby-hyenas other hyenas with [distance myself <= 1] ; Verifica a proximidade
    ifelse any? nearby-hyenas [
      ask nearby-hyenas [
        set color green ; Todas as hienas próximas mudam para a cor verde
        set nivel-agrupamento nivel-agrupamento + 1 ; Aumenta o nível de agrupamento
      ]
      set color green ; A hiena atual também muda de cor
      set nivel-agrupamento nivel-agrupamento + 1 ; Aumenta o nível de agrupamento
    ] [
      set color white ; Se não houver outras hienas próximas, volta à cor branca
      set nivel-agrupamento 1 ; Define o nível de agrupamento como 1
    ]
  ]
end


to combate-lions  ; combte dos leoes

     let hiena-frente one-of hyenas-on patch-ahead 1
     let hiena-esquerda one-of hyenas-on  patch-left-and-ahead 90 1
     let hiena-direita one-of hyenas-on  patch-right-and-ahead 90 1


  ifelse (any? hyenas-on patch-ahead 1) and ([color] of hiena-frente != green) and  (energia > [energia] of hiena-frente) [    ;


     set energia energia - (([energia] of hiena-frente) * (percPerda / 100))   ; faz o leao perder a energia com base na percentagem da energia da hiena
     ask hiena-frente [die]
     set pcolor brown
     show "hiena morto frente"
     set kills-lions kills-lions + 1

  ][ifelse(any? hyenas-on patch-right-and-ahead 90 1) and ([color] of hiena-direita != green) and (energia > [energia] of hiena-direita)[


     set energia energia - (([energia] of hiena-direita) * (percPerda / 100)); faz o leao perder a energia com base na percentagem da energia da hiena
    ask hiena-direita [die];mata a hiena
       set pcolor brown
       show "hiena morto direita"
      set kills-lions kills-lions + 1

    ][if(any? hyenas-on patch-left-and-ahead 90 1) and ([color] of hiena-esquerda != green) and (energia > [energia] of hiena-esquerda) [

    set energia energia - (([energia] of hiena-esquerda) * (percPerda / 100)); faz o leao perder a energia com base na percentagem da energia da hiena
    ask hiena-esquerda [die];mata a hiena
         set pcolor brown
         show "hiena morto esquerda"
        set kills-lions kills-lions + 1

    ]
   ]
  ]
end


to-report move-especial-l

     let hiena-frente one-of hyenas-on patch-ahead 1
     let hiena-esquerda one-of hyenas-on  patch-left-and-ahead 90 1
     let hiena-direita one-of hyenas-on  patch-right-and-ahead 90 1

  ifelse(any? hyenas-on patch-right-and-ahead 90 1) and ([color] of hiena-direita = green) and ( ((any? hyenas-on patch-left-and-ahead 90 1) = false) and ((any? hyenas-on patch-ahead 1) = false)) [

    lt 90
    fd 1
    set energia energia - 2
     show "Fugio para a esquerda"
    report true

    ][ifelse(any? hyenas-on patch-left-and-ahead 90 1) and ([color] of hiena-esquerda = green) and ( ((any? hyenas-on patch-right-and-ahead 90 1) = false) and ((any? hyenas-on patch-ahead 1) = false)) [

      rt 90
      fd 1
      set energia energia - 2
       show "Fugio para a dierita"
      report true

    ][ ifelse ((any? hyenas-on patch-ahead 1) and ([color] of hiena-frente = green) and ( ((any? hyenas-on patch-left-and-ahead 90 1) = false) and ((any? hyenas-on patch-ahead 1) = false))) or ((any? hyenas-on patch-left-and-ahead 90 1) and (any? hyenas-on patch-right-and-ahead 90 1) and ([color] of hiena-esquerda = green) and ([color] of hiena-direita = green) ) [

      rt 180
      fd 1
      set energia energia - 3
      show "Fugio para tras"
      report true


      ][ ifelse ((any? hyenas-on patch-ahead 1) and ([color] of hiena-frente = green) and (any? hyenas-on patch-left-and-ahead 90 1) and ([color] of hiena-esquerda = green) ) and ((any? hyenas-on patch-right-and-ahead 90 1) = false) [

      rt 135
      fd 1
      set energia energia - 5
      show "======= Fugio diagonal de tras direita ========"
      report true

        ][ ifelse ((any? hyenas-on patch-ahead 1) and ([color] of hiena-frente = green) and (any? hyenas-on patch-right-and-ahead 90 1) and ([color] of hiena-direita = green) ) and ((any? hyenas-on patch-left-and-ahead 90 1) = false) [

      lt 135
      fd 1
      set energia energia - 5
      show "======= Fugio diagonal de tras esquerda ========"
      report true

          ][ifelse (any? hyenas-on patch-ahead 1) and ([color] of hiena-frente = green) and (any? hyenas-on patch-right-and-ahead 90 1) and ([color] of hiena-direita = green) and (any? hyenas-on patch-left-and-ahead 90 1) and ([color] of hiena-esquerda = green)[

      rt 180
      fd 1
      set energia energia - 4
      show "=== Fugio para tras ===="
      report true

     ][report false]
    ]
   ]
  ]
 ]
]

end

to combate-hyenas

    let leo-frente one-of lions-on patch-ahead 1
    let leo-esquerda one-of lions-on patch-left-and-ahead 90 1
    let leo-direita one-of lions-on patch-right-and-ahead 90 1

   let total-leoes (count lions-on patch-ahead 1) + (count lions-on patch-left-and-ahead 90 1) + (count lions-on patch-right-and-ahead 90 1)

  if (total-leoes = 1)[

       ifelse (any? lions-on patch-ahead 1) and (energia > [energia] of leo-frente) [

       set energia energia - (([energia] of leo-frente) * (percPerda / 100))
       ask leo-frente [die]
       set pcolor brown
      show "leao morto frente"
      set kills-hienas kills-hienas + 1

    ][ifelse (any? lions-on patch-left-and-ahead 90 1) and (energia > [energia] of leo-esquerda) [

      set energia energia - (([energia] of leo-esquerda) * (percPerda / 100))
      ask leo-esquerda [die]
      set pcolor brown
      show "leao morto esquerda"
        set kills-hienas kills-hienas + 1

      ][ifelse (any? lions-on patch-right-and-ahead 90 1) and (energia > [energia] of leo-direita) [

       set energia energia - (([energia] of leo-direita) * (percPerda / 100))
      ask leo-direita [die]
      set pcolor brown
      show "leao morto direita"
       set kills-hienas kills-hienas + 1

        ][]
     ]
   ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
716
10
1489
784
-1
-1
15.0
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
50
0
50
0
0
1
ticks
30.0

BUTTON
6
10
70
43
Setup
Setup
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
77
10
140
43
Go
GO
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
8
76
180
109
nlions
nlions
1
50
50.0
1
1
leoes
HORIZONTAL

SLIDER
198
76
370
109
nhyenas
nhyenas
1
50
50.0
1
1
hienas
HORIZONTAL

SLIDER
9
121
178
154
nEnergiaInicio
nEnergiaInicio
10
100
15.0
1
1
energia
HORIZONTAL

SLIDER
5
167
177
200
nCelulasGrandePorte
nCelulasGrandePorte
0
10
5.0
1
1
%
HORIZONTAL

SLIDER
198
167
362
200
nCelulasPequenoPorte
nCelulasPequenoPorte
0
20
10.0
1
1
%
HORIZONTAL

SWITCH
148
10
287
43
MostrarEnergia?
MostrarEnergia?
1
1
-1000

SLIDER
0
216
179
249
num_def_utilizador
num_def_utilizador
1
90
60.0
1
1
energia
HORIZONTAL

SLIDER
389
117
561
150
GanhoGrande
GanhoGrande
1
50
30.0
1
1
energia
HORIZONTAL

SLIDER
195
118
367
151
GanhoPequeno
GanhoPequeno
0
50
15.0
1
1
NIL
HORIZONTAL

SLIDER
198
214
369
247
nMaxEnergia
nMaxEnergia
75
250
150.0
5
1
energia
HORIZONTAL

PLOT
5
482
339
743
Gráfico de n agentes
Tiicks
Nº Agentes
0.0
50.0
0.0
50.0
true
true
"" ""
PENS
"leoes" 1.0 0 -1184463 true "" "plot count lions"
"hienas" 1.0 0 -16710651 true "" "plot count hyenas"

MONITOR
184
429
251
474
Nº Hienas
Count hyenas
17
1
11

MONITOR
8
427
71
472
Nº Leões
count lions
17
1
11

SLIDER
389
167
561
200
nAzul
nAzul
0
5
3.0
1
1
azuis
HORIZONTAL

SWITCH
292
10
418
43
MaxEnergia?
MaxEnergia?
1
1
-1000

SWITCH
423
10
551
43
Reproducao?
Reproducao?
1
1
-1000

SLIDER
0
267
172
300
probRepr
probRepr
10
50
10.0
5
1
%
HORIZONTAL

INPUTBOX
210
259
299
319
segDescanso
3.0
1
0
Number

SLIDER
391
215
563
248
percPerda
percPerda
5
90
45.0
5
1
%
HORIZONTAL

MONITOR
81
428
173
473
Kills dos Leões
kills-lions
17
1
11

MONITOR
262
429
358
474
Kills das Hienas
kills-hienas
17
1
11

SWITCH
559
10
662
43
veneno?
veneno?
1
1
-1000

SLIDER
186
332
358
365
perdaVeneno
perdaVeneno
5
60
50.0
5
1
%
HORIZONTAL

SLIDER
6
326
178
359
nCelulasVeneno
nCelulasVeneno
1
10
5.0
1
1
NIL
HORIZONTAL

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

wolf 3
false
0
Polygon -7500403 true true 105 180 75 180 45 75 45 0 105 45 195 45 255 0 255 75 225 180 195 180 165 300 135 300 105 180 75 180
Polygon -16777216 true false 225 90 210 135 150 90
Polygon -16777216 true false 75 90 90 135 150 90

wolf 4
false
0
Polygon -7500403 true true 105 75 105 45 45 0 30 45 45 60 60 90
Polygon -7500403 true true 45 165 30 135 45 120 15 105 60 75 105 60 180 60 240 75 285 105 255 120 270 135 255 165 270 180 255 195 255 210 240 195 195 225 210 255 180 300 120 300 90 255 105 225 60 195 45 210 45 195 30 180
Polygon -16777216 true false 120 300 135 285 120 270 120 255 180 255 180 270 165 285 180 300
Polygon -16777216 true false 240 135 180 165 180 135
Polygon -16777216 true false 60 135 120 165 120 135
Polygon -7500403 true true 195 75 195 45 255 0 270 45 255 60 240 90
Polygon -16777216 true false 225 75 210 60 210 45 255 15 255 45 225 60
Polygon -16777216 true false 75 75 90 60 90 45 45 15 45 45 75 60

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
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
