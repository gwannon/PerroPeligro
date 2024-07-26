game
.L00 ;  rem DiscDog

.
 ; 

.L01 ;  playfield:

  ifconst pfres
	  ldx #(11>pfres)*(pfres*pfwidth-1)+(11<=pfres)*43
  else
	  ldx #((11*pfwidth-1)*((11*pfwidth-1)<47))+(47*((11*pfwidth-1)>=47))
  endif
	jmp pflabel0
PF_data0
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %01010100, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
	.byte %00000000, %00000000
	if (pfwidth>2)
	.byte %00000000, %00000000
 endif
pflabel0
	lda PF_data0,x
	sta playfield,x
	dex
	bpl pflabel0
.
 ; 

.L02 ;  player0:

	LDX #<playerL02_0
	STX player0pointerlo
	LDA #>playerL02_0
	STA player0pointerhi
	LDA #7
	STA player0height
.
 ; 

.L03 ;  COLUPF  =  176

	LDA #176
	STA COLUPF
.L04 ;  scorecolor  =  52

	LDA #52
	STA scorecolor
.L05 ;  score  =  0

	LDA #$00
	STA score+2
	LDA #$00
	STA score+1
	LDA #$00
	STA score
.
 ; 

.L06 ;  player0x  =  52

	LDA #52
	STA player0x
.L07 ;  player0y  =   - 16

	LDA #240
	STA player0y
.
 ; 

.L08 ;  missile0x  =  52

	LDA #52
	STA missile0x
.L09 ;  missile0y  =  0

	LDA #0
	STA missile0y
.L010 ;  missile0height  =  16

	LDA #16
	STA missile0height
.
 ; 

.L011 ;  missile1x  =  92

	LDA #92
	STA missile1x
.L012 ;  missile1y  =  0

	LDA #0
	STA missile1y
.L013 ;  missile1height  =  16

	LDA #16
	STA missile1height
.
 ; 

.L014 ;  ballx  =  80

	LDA #80
	STA ballx
.L015 ;  bally  =  50

	LDA #50
	STA bally
.L016 ;  ballheight  =  4

	LDA #4
	STA ballheight
.L017 ;  CTRLPF  =  $21

	LDA #$21
	STA CTRLPF
.
 ; 

.
 ; 

.L018 ;  dim perrosalto  =  a

.L019 ;  dim missile0vel  =  b

.L020 ;  dim missile1vel  =  c

.L021 ;  dim puntos  =  d

.L022 ;  dim perrodireccion  =  e

.L023 ;  dim perrovidas  =  f

.L024 ;  dim counter1  =  g

.L025 ;  dim counter2  =  h

.L026 ;  dim ballstatus  =  i

.
 ; 

.
 ; 

.L027 ;  puntos  =  0

	LDA #0
	STA puntos
.L028 ;  perrodireccion  =  1

	LDA #1
	STA perrodireccion
.L029 ;  perrovidas  =  3

	LDA #3
	STA perrovidas
.L030 ;  missile0vel  =  5

	LDA #5
	STA missile0vel
.L031 ;  missile1vel  =  3

	LDA #3
	STA missile1vel
.L032 ;  counter1  =  0

	LDA #0
	STA counter1
.L033 ;  counter2  =  0

	LDA #0
	STA counter2
.L034 ;  ballstatus  =  0

	LDA #0
	STA ballstatus
.
 ; 

.
 ; 

.mainloop
 ; mainloop

.
 ; 

.L035 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L036 ;  COLUP0  =  4

	LDA #4
	STA COLUP0
.L037 ;  COLUP1  =  132

	LDA #132
	STA COLUP1
.
 ; 

.L038 ;  counter1  =  counter1  +  1

	INC counter1
.L039 ;  if perrovidas  >  0 then gosub caidauno

	LDA #0
	CMP perrovidas
     BCS .skipL039
.condpart0
 jsr .caidauno

.skipL039
.
 ; 

.L040 ;  counter2  =  counter2  +  1

	INC counter2
.L041 ;  if perrovidas  >  0 then gosub caidados

	LDA #0
	CMP perrovidas
     BCS .skipL041
.condpart1
 jsr .caidados

.skipL041
.
 ; 

.L042 ;  if player0y  =  104 then player0y  =  0  :  perrovidas  =  perrovidas  -  1

	LDA player0y
	CMP #104
     BNE .skipL042
.condpart2
	LDA #0
	STA player0y
	DEC perrovidas
.skipL042
.
 ; 

.L043 ;  if perrovidas  =  0 then COLUPF  =  52  :  gosub limpiarpantalla

	LDA perrovidas
	CMP #0
     BNE .skipL043
.condpart3
	LDA #52
	STA COLUPF
 jsr .limpiarpantalla

.skipL043
.L044 ;  if perrovidas  =  0 then gosub game

	LDA perrovidas
	CMP #0
     BNE .skipL044
.condpart4
 jsr .game

.skipL044
.L045 ;  if perrovidas  =  0 then gosub over

	LDA perrovidas
	CMP #0
     BNE .skipL045
.condpart5
 jsr .over

.skipL045
.
 ; 

.L046 ;  if joy0left  &&  player0x  >  21  &&  perrovidas  >  0 then gosub moverizquierda

 bit SWCHA
	BVS .skipL046
.condpart6
	LDA #21
	CMP player0x
     BCS .skip6then
.condpart7
	LDA #0
	CMP perrovidas
     BCS .skip7then
.condpart8
 jsr .moverizquierda

.skip7then
.skip6then
.skipL046
.L047 ;  if joy0right  &&  player0x  <  133  &&  perrovidas  >  0 then gosub moverderecha

 bit SWCHA
	BMI .skipL047
.condpart9
	LDA player0x
	CMP #133
     BCS .skip9then
.condpart10
	LDA #0
	CMP perrovidas
     BCS .skip10then
.condpart11
 jsr .moverderecha

.skip10then
.skip9then
.skipL047
.L048 ;  if joy0up  &&  perrosalto  =  0  &&  perrovidas  >  0  &&  collision(player0,missile0) then perrosalto  =  1

 lda #$10
 bit SWCHA
	BNE .skipL048
.condpart12
	LDA perrosalto
	CMP #0
     BNE .skip12then
.condpart13
	LDA #0
	CMP perrovidas
     BCS .skip13then
.condpart14
	bit 	CXM0P
	BVC .skip14then
.condpart15
	LDA #1
	STA perrosalto
.skip14then
.skip13then
.skip12then
.skipL048
.L049 ;  if joy0up  &&  perrosalto  =  0  &&  perrovidas  >  0  &&  collision(player0,missile1) then perrosalto  =  1

 lda #$10
 bit SWCHA
	BNE .skipL049
.condpart16
	LDA perrosalto
	CMP #0
     BNE .skip16then
.condpart17
	LDA #0
	CMP perrovidas
     BCS .skip17then
.condpart18
	bit 	CXM1P
	BPL .skip18then
.condpart19
	LDA #1
	STA perrosalto
.skip18then
.skip17then
.skip16then
.skipL049
.
 ; 

.L050 ;  if perrosalto  >=  1 then gosub saltarsubida

	LDA perrosalto
	CMP #1
     BCC .skipL050
.condpart20
 jsr .saltarsubida

.skipL050
.
 ; 

.L051 ;  if perrovidas  >  0  &&  perrosalto  =  0  &&  !collision(player0,missile0)  &&  !collision(player0,missile1) then player0y  =  player0y  +  1

	LDA #0
	CMP perrovidas
     BCS .skipL051
.condpart21
	LDA perrosalto
	CMP #0
     BNE .skip21then
.condpart22
	bit 	CXM0P
	BVS .skip22then
.condpart23
	bit 	CXM1P
	BMI .skip23then
.condpart24
	INC player0y
.skip23then
.skip22then
.skip21then
.skipL051
.
 ; 

.L052 ;  gosub premio

 jsr .premio

.
 ; 

.L053 ;  gosub marcador

 jsr .marcador

.
 ; 

.L054 ;  NUSIZ0  =  $30

	LDA #$30
	STA NUSIZ0
.L055 ;  missile0height  =  16

	LDA #16
	STA missile0height
.
 ; 

.L056 ;  NUSIZ1  =  $30

	LDA #$30
	STA NUSIZ1
.L057 ;  missile1height  =  16

	LDA #16
	STA missile1height
.
 ; 

.L058 ;  drawscreen

 jsr drawscreen
.L059 ;  goto mainloop

 jmp .mainloop

.
 ; 

.moverizquierda
 ; moverizquierda

.L060 ;  player0:

	LDX #<playerL060_0
	STX player0pointerlo
	LDA #>playerL060_0
	STA player0pointerhi
	LDA #7
	STA player0height
.L061 ;  perrodireccion  =  2

	LDA #2
	STA perrodireccion
.L062 ;  player0x  =  player0x  -  1

	DEC player0x
.L063 ;  return

	RTS
.
 ; 

.moverderecha
 ; moverderecha

.L064 ;  player0:

	LDX #<playerL064_0
	STX player0pointerlo
	LDA #>playerL064_0
	STA player0pointerhi
	LDA #7
	STA player0height
.L065 ;  player0x  =  player0x  +  1

	INC player0x
.L066 ;  perrodireccion  =  1

	LDA #1
	STA perrodireccion
.L067 ;  return

	RTS
.
 ; 

.saltarsubida
 ; saltarsubida

.L068 ;  player0y  =  player0y  -  1

	DEC player0y
.L069 ;  perrosalto  =  perrosalto  +  1

	INC perrosalto
.L070 ;  if perrosalto  =  60 then perrosalto  =  0

	LDA perrosalto
	CMP #60
     BNE .skipL070
.condpart25
	LDA #0
	STA perrosalto
.skipL070
.L071 ;  return

	RTS
.
 ; 

.caidauno
 ; caidauno

.L072 ;  if counter1  =  missile0vel then missile0y  =  missile0y  +  1  :  counter1  =  0

	LDA counter1
	CMP missile0vel
     BNE .skipL072
.condpart26
	INC missile0y
	LDA #0
	STA counter1
.skipL072
.L073 ;  if missile0y  =  104 then missile0y  =  0  :  missile0vel  =   ( rand  &  1 )   +  2  :  score  =  score  +  10

	LDA missile0y
	CMP #104
     BNE .skipL073
.condpart27
	LDA #0
	STA missile0y
; complex statement detected
 jsr randomize
	AND #1
	CLC
	ADC #2
	STA missile0vel
	SED
	CLC
	LDA score+2
	ADC #$10
	STA score+2
	LDA score+1
	ADC #$00
	STA score+1
	LDA score
	ADC #$00
	STA score
	CLD
.skipL073
.L074 ;  return

	RTS
.
 ; 

.caidados
 ; caidados

.L075 ;  if counter2  =  missile1vel then missile1y  =  missile1y  +  1  :  counter2  =  0

	LDA counter2
	CMP missile1vel
     BNE .skipL075
.condpart28
	INC missile1y
	LDA #0
	STA counter2
.skipL075
.L076 ;  if missile1y  =  104 then missile1y  =  0  :  missile1vel  =   ( rand  &  1 )   +  2  :  score  =  score  +  10

	LDA missile1y
	CMP #104
     BNE .skipL076
.condpart29
	LDA #0
	STA missile1y
; complex statement detected
 jsr randomize
	AND #1
	CLC
	ADC #2
	STA missile1vel
	SED
	CLC
	LDA score+2
	ADC #$10
	STA score+2
	LDA score+1
	ADC #$00
	STA score+1
	LDA score
	ADC #$00
	STA score
	CLD
.skipL076
.L077 ;  return

	RTS
.
 ; 

.premio
 ; premio

.L078 ;  if ballstatus  =  0 then ballstatus  =  1  :  ballx  =   ( rand  &  90 )   +  50  :  bally  =   ( rand  &  60 )   +  20

	LDA ballstatus
	CMP #0
     BNE .skipL078
.condpart30
	LDA #1
	STA ballstatus
; complex statement detected
 jsr randomize
	AND #90
	CLC
	ADC #50
	STA ballx
; complex statement detected
 jsr randomize
	AND #60
	CLC
	ADC #20
	STA bally
.skipL078
.L079 ;  if collision(player0,ball)  &&  ballstatus  =  1 then score  =  score  +  500  :  ballstatus  =  0  :  ballx  =  0  :  bally  =  0  :  perrovidas  =  perrovidas  +  1

	bit 	CXP0FB
	BVC .skipL079
.condpart31
	LDA ballstatus
	CMP #1
     BNE .skip31then
.condpart32
	SED
	CLC
	LDA score+1
	ADC #$05
	STA score+1
	LDA score
	ADC #$00
	STA score
	CLD
	LDA #0
	STA ballstatus
	STA ballx
	STA bally
	INC perrovidas
.skip31then
.skipL079
.L080 ;  return

	RTS
.
 ; 

.marcador
 ; marcador

.L081 ;  if perrovidas  >  3 then perrovidas  =  3

	LDA #3
	CMP perrovidas
     BCS .skipL081
.condpart33
	LDA #3
	STA perrovidas
.skipL081
.L082 ;  if perrovidas  =  3 then pfpixel 1 1 on  :  pfpixel 3 1 on  :  pfpixel 5 1 on

	LDA perrovidas
	CMP #3
     BNE .skipL082
.condpart34
	LDX #0
	LDY #1
	LDA #1
 jsr pfpixel
	LDX #0
	LDY #1
	LDA #3
 jsr pfpixel
	LDX #0
	LDY #1
	LDA #5
 jsr pfpixel
.skipL082
.L083 ;  if perrovidas  =  2 then pfpixel 1 1 on  :  pfpixel 3 1 on  :  pfpixel 5 1 off

	LDA perrovidas
	CMP #2
     BNE .skipL083
.condpart35
	LDX #0
	LDY #1
	LDA #1
 jsr pfpixel
	LDX #0
	LDY #1
	LDA #3
 jsr pfpixel
	LDX #1
	LDY #1
	LDA #5
 jsr pfpixel
.skipL083
.L084 ;  if perrovidas  =  1 then pfpixel 1 1 on  :  pfpixel 3 1 off  :  pfpixel 5 1 off

	LDA perrovidas
	CMP #1
     BNE .skipL084
.condpart36
	LDX #0
	LDY #1
	LDA #1
 jsr pfpixel
	LDX #1
	LDY #1
	LDA #3
 jsr pfpixel
	LDX #1
	LDY #1
	LDA #5
 jsr pfpixel
.skipL084
.L085 ;  if perrovidas  =  0 then pfpixel 1 1 off  :  pfpixel 3 1 off  :  pfpixel 5 1 off

	LDA perrovidas
	CMP #0
     BNE .skipL085
.condpart37
	LDX #1
	LDY #1
	LDA #1
 jsr pfpixel
	LDX #1
	LDY #1
	LDA #3
 jsr pfpixel
	LDX #1
	LDY #1
	LDA #5
 jsr pfpixel
.skipL085
.L086 ;  return

	RTS
.
 ; 

.limpiarpantalla
 ; limpiarpantalla

.L087 ;  pfpixel 5 1 off

	LDX #1
	LDY #1
	LDA #5
 jsr pfpixel
.L088 ;  pfpixel 3 1 off

	LDX #1
	LDY #1
	LDA #3
 jsr pfpixel
.L089 ;  pfpixel 1 1 off

	LDX #1
	LDY #1
	LDA #1
 jsr pfpixel
.L090 ;  pfpixel 22 1 off

	LDX #1
	LDY #1
	LDA #22
 jsr pfpixel
.L091 ;  pfpixel 23 1 off

	LDX #1
	LDY #1
	LDA #23
 jsr pfpixel
.L092 ;  pfpixel 24 1 off

	LDX #1
	LDY #1
	LDA #24
 jsr pfpixel
.L093 ;  pfpixel 25 1 off

	LDX #1
	LDY #1
	LDA #25
 jsr pfpixel
.L094 ;  pfpixel 26 1 off

	LDX #1
	LDY #1
	LDA #26
 jsr pfpixel
.L095 ;  pfpixel 27 1 off

	LDX #1
	LDY #1
	LDA #27
 jsr pfpixel
.L096 ;  pfpixel 28 1 off

	LDX #1
	LDY #1
	LDA #28
 jsr pfpixel
.L097 ;  pfpixel 29 1 off

	LDX #1
	LDY #1
	LDA #29
 jsr pfpixel
.L098 ;  pfpixel 30 1 off

	LDX #1
	LDY #1
	LDA #30
 jsr pfpixel
.L099 ;  pfpixel 31 1 off

	LDX #1
	LDY #1
	LDA #31
 jsr pfpixel
.L0100 ;  drawscreen

 jsr drawscreen
.
 ; 

.L0101 ;  missile0y  =  0

	LDA #0
	STA missile0y
.L0102 ;  missile1y  =  0

	LDA #0
	STA missile1y
.
 ; 

.L0103 ;  return

	RTS
.
 ; 

.game
 ; game

.L0104 ;  pfpixel 6 0 on

	LDX #0
	LDY #0
	LDA #6
 jsr pfpixel
.L0105 ;  pfpixel 7 0 on

	LDX #0
	LDY #0
	LDA #7
 jsr pfpixel
.L0106 ;  pfpixel 8 0 on

	LDX #0
	LDY #0
	LDA #8
 jsr pfpixel
.L0107 ;  pfpixel 11 0 on

	LDX #0
	LDY #0
	LDA #11
 jsr pfpixel
.L0108 ;  pfpixel 12 0 on

	LDX #0
	LDY #0
	LDA #12
 jsr pfpixel
.L0109 ;  pfpixel 13 0 on

	LDX #0
	LDY #0
	LDA #13
 jsr pfpixel
.L0110 ;  pfpixel 15 0 on

	LDX #0
	LDY #0
	LDA #15
 jsr pfpixel
.L0111 ;  pfpixel 19 0 on

	LDX #0
	LDY #0
	LDA #19
 jsr pfpixel
.L0112 ;  pfpixel 21 0 on

	LDX #0
	LDY #0
	LDA #21
 jsr pfpixel
.L0113 ;  pfpixel 22 0 on

	LDX #0
	LDY #0
	LDA #22
 jsr pfpixel
.L0114 ;  pfpixel 23 0 on

	LDX #0
	LDY #0
	LDA #23
 jsr pfpixel
.L0115 ;  pfpixel 24 0 on

	LDX #0
	LDY #0
	LDA #24
 jsr pfpixel
.
 ; 

.L0116 ;  pfpixel 5 1 on

	LDX #0
	LDY #1
	LDA #5
 jsr pfpixel
.L0117 ;  pfpixel 10 1 on

	LDX #0
	LDY #1
	LDA #10
 jsr pfpixel
.L0118 ;  pfpixel 13 1 on

	LDX #0
	LDY #1
	LDA #13
 jsr pfpixel
.L0119 ;  pfpixel 15 1 on

	LDX #0
	LDY #1
	LDA #15
 jsr pfpixel
.L0120 ;  pfpixel 16 1 on

	LDX #0
	LDY #1
	LDA #16
 jsr pfpixel
.L0121 ;  pfpixel 18 1 on

	LDX #0
	LDY #1
	LDA #18
 jsr pfpixel
.L0122 ;  pfpixel 19 1 on

	LDX #0
	LDY #1
	LDA #19
 jsr pfpixel
.L0123 ;  pfpixel 21 1 on

	LDX #0
	LDY #1
	LDA #21
 jsr pfpixel
.
 ; 

.L0124 ;  pfpixel 5 2 on

	LDX #0
	LDY #2
	LDA #5
 jsr pfpixel
.L0125 ;  pfpixel 7 2 on

	LDX #0
	LDY #2
	LDA #7
 jsr pfpixel
.L0126 ;  pfpixel 8 2 on

	LDX #0
	LDY #2
	LDA #8
 jsr pfpixel
.L0127 ;  pfpixel 10 2 on

	LDX #0
	LDY #2
	LDA #10
 jsr pfpixel
.L0128 ;  pfpixel 13 2 on

	LDX #0
	LDY #2
	LDA #13
 jsr pfpixel
.L0129 ;  pfpixel 15 2 on

	LDX #0
	LDY #2
	LDA #15
 jsr pfpixel
.L0130 ;  pfpixel 17 2 on

	LDX #0
	LDY #2
	LDA #17
 jsr pfpixel
.L0131 ;  pfpixel 19 2 on

	LDX #0
	LDY #2
	LDA #19
 jsr pfpixel
.L0132 ;  pfpixel 21 2 on

	LDX #0
	LDY #2
	LDA #21
 jsr pfpixel
.L0133 ;  pfpixel 22 2 on

	LDX #0
	LDY #2
	LDA #22
 jsr pfpixel
.
 ; 

.L0134 ;  pfpixel 5 3 on

	LDX #0
	LDY #3
	LDA #5
 jsr pfpixel
.L0135 ;  pfpixel 8 3 on

	LDX #0
	LDY #3
	LDA #8
 jsr pfpixel
.L0136 ;  pfpixel 10 3 on

	LDX #0
	LDY #3
	LDA #10
 jsr pfpixel
.L0137 ;  pfpixel 11 3 on

	LDX #0
	LDY #3
	LDA #11
 jsr pfpixel
.L0138 ;  pfpixel 12 3 on

	LDX #0
	LDY #3
	LDA #12
 jsr pfpixel
.L0139 ;  pfpixel 13 3 on

	LDX #0
	LDY #3
	LDA #13
 jsr pfpixel
.L0140 ;  pfpixel 15 3 on

	LDX #0
	LDY #3
	LDA #15
 jsr pfpixel
.L0141 ;  pfpixel 19 3 on

	LDX #0
	LDY #3
	LDA #19
 jsr pfpixel
.L0142 ;  pfpixel 21 3 on

	LDX #0
	LDY #3
	LDA #21
 jsr pfpixel
.
 ; 

.L0143 ;  pfpixel 6 4 on

	LDX #0
	LDY #4
	LDA #6
 jsr pfpixel
.L0144 ;  pfpixel 7 4 on

	LDX #0
	LDY #4
	LDA #7
 jsr pfpixel
.L0145 ;  pfpixel 10 4 on

	LDX #0
	LDY #4
	LDA #10
 jsr pfpixel
.L0146 ;  pfpixel 13 4 on

	LDX #0
	LDY #4
	LDA #13
 jsr pfpixel
.L0147 ;  pfpixel 15 4 on

	LDX #0
	LDY #4
	LDA #15
 jsr pfpixel
.L0148 ;  pfpixel 19 4 on

	LDX #0
	LDY #4
	LDA #19
 jsr pfpixel
.L0149 ;  pfpixel 21 4 on

	LDX #0
	LDY #4
	LDA #21
 jsr pfpixel
.L0150 ;  pfpixel 22 4 on

	LDX #0
	LDY #4
	LDA #22
 jsr pfpixel
.L0151 ;  pfpixel 23 4 on

	LDX #0
	LDY #4
	LDA #23
 jsr pfpixel
.L0152 ;  pfpixel 24 4 on

	LDX #0
	LDY #4
	LDA #24
 jsr pfpixel
.L0153 ;  drawscreen

 jsr drawscreen
.L0154 ;  return

	RTS
.
 ; 

.over
 ; over

.L0155 ;  pfpixel 6 6 on

	LDX #0
	LDY #6
	LDA #6
 jsr pfpixel
.L0156 ;  pfpixel 7 6 on

	LDX #0
	LDY #6
	LDA #7
 jsr pfpixel
.L0157 ;  pfpixel 10 6 on

	LDX #0
	LDY #6
	LDA #10
 jsr pfpixel
.L0158 ;  pfpixel 14 6 on

	LDX #0
	LDY #6
	LDA #14
 jsr pfpixel
.L0159 ;  pfpixel 16 6 on

	LDX #0
	LDY #6
	LDA #16
 jsr pfpixel
.L0160 ;  pfpixel 17 6 on

	LDX #0
	LDY #6
	LDA #17
 jsr pfpixel
.L0161 ;  pfpixel 18 6 on

	LDX #0
	LDY #6
	LDA #18
 jsr pfpixel
.L0162 ;  pfpixel 19 6 on

	LDX #0
	LDY #6
	LDA #19
 jsr pfpixel
.L0163 ;  pfpixel 21 6 on

	LDX #0
	LDY #6
	LDA #21
 jsr pfpixel
.L0164 ;  pfpixel 22 6 on

	LDX #0
	LDY #6
	LDA #22
 jsr pfpixel
.L0165 ;  pfpixel 23 6 on

	LDX #0
	LDY #6
	LDA #23
 jsr pfpixel
.L0166 ;  pfpixel 24 6 on

	LDX #0
	LDY #6
	LDA #24
 jsr pfpixel
.
 ; 

.L0167 ;  pfpixel 5 7 on

	LDX #0
	LDY #7
	LDA #5
 jsr pfpixel
.L0168 ;  pfpixel 8 7 on

	LDX #0
	LDY #7
	LDA #8
 jsr pfpixel
.L0169 ;  pfpixel 10 7 on

	LDX #0
	LDY #7
	LDA #10
 jsr pfpixel
.L0170 ;  pfpixel 14 7 on

	LDX #0
	LDY #7
	LDA #14
 jsr pfpixel
.L0171 ;  pfpixel 16 7 on

	LDX #0
	LDY #7
	LDA #16
 jsr pfpixel
.L0172 ;  pfpixel 21 7 on

	LDX #0
	LDY #7
	LDA #21
 jsr pfpixel
.L0173 ;  pfpixel 24 7 on

	LDX #0
	LDY #7
	LDA #24
 jsr pfpixel
.
 ; 

.L0174 ;  pfpixel 5 8 on

	LDX #0
	LDY #8
	LDA #5
 jsr pfpixel
.L0175 ;  pfpixel 8 8 on

	LDX #0
	LDY #8
	LDA #8
 jsr pfpixel
.L0176 ;  pfpixel 10 8 on

	LDX #0
	LDY #8
	LDA #10
 jsr pfpixel
.L0177 ;  pfpixel 14 8 on

	LDX #0
	LDY #8
	LDA #14
 jsr pfpixel
.L0178 ;  pfpixel 16 8 on

	LDX #0
	LDY #8
	LDA #16
 jsr pfpixel
.L0179 ;  pfpixel 17 8 on

	LDX #0
	LDY #8
	LDA #17
 jsr pfpixel
.L0180 ;  pfpixel 21 8 on

	LDX #0
	LDY #8
	LDA #21
 jsr pfpixel
.L0181 ;  pfpixel 22 8 on

	LDX #0
	LDY #8
	LDA #22
 jsr pfpixel
.L0182 ;  pfpixel 23 8 on

	LDX #0
	LDY #8
	LDA #23
 jsr pfpixel
.
 ; 

.L0183 ;  pfpixel 5 9 on

	LDX #0
	LDY #9
	LDA #5
 jsr pfpixel
.L0184 ;  pfpixel 8 9 on

	LDX #0
	LDY #9
	LDA #8
 jsr pfpixel
.L0185 ;  pfpixel 11 9 on

	LDX #0
	LDY #9
	LDA #11
 jsr pfpixel
.L0186 ;  pfpixel 13 9 on

	LDX #0
	LDY #9
	LDA #13
 jsr pfpixel
.L0187 ;  pfpixel 16 9 on

	LDX #0
	LDY #9
	LDA #16
 jsr pfpixel
.L0188 ;  pfpixel 21 9 on

	LDX #0
	LDY #9
	LDA #21
 jsr pfpixel
.L0189 ;  pfpixel 23 9 on

	LDX #0
	LDY #9
	LDA #23
 jsr pfpixel
.
 ; 

.L0190 ;  pfpixel 6 10 on

	LDX #0
	LDY #10
	LDA #6
 jsr pfpixel
.L0191 ;  pfpixel 7 10 on

	LDX #0
	LDY #10
	LDA #7
 jsr pfpixel
.L0192 ;  pfpixel 12 10 on

	LDX #0
	LDY #10
	LDA #12
 jsr pfpixel
.L0193 ;  pfpixel 16 10 on

	LDX #0
	LDY #10
	LDA #16
 jsr pfpixel
.L0194 ;  pfpixel 17 10 on

	LDX #0
	LDY #10
	LDA #17
 jsr pfpixel
.L0195 ;  pfpixel 18 10 on

	LDX #0
	LDY #10
	LDA #18
 jsr pfpixel
.L0196 ;  pfpixel 19 10 on

	LDX #0
	LDY #10
	LDA #19
 jsr pfpixel
.L0197 ;  pfpixel 21 10 on

	LDX #0
	LDY #10
	LDA #21
 jsr pfpixel
.L0198 ;  pfpixel 24 10 on

	LDX #0
	LDY #10
	LDA #24
 jsr pfpixel
.L0199 ;  drawscreen

 jsr drawscreen
.L0200 ;  return

	RTS
.
 ; 

 if (<*) > (<(*+7))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL02_0
	.byte  %01000100
	.byte  %01000100
	.byte  %01111100
	.byte  %01111100
	.byte  %01111100
	.byte  %10000111
	.byte  %00000111
	.byte  %00000100
 if (<*) > (<(*+7))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL060_0
	.byte  %00100010
	.byte  %00100010
	.byte  %00111110
	.byte  %00111110
	.byte  %00111111
	.byte  %11100000
	.byte  %11100000
	.byte  %00100000
 if (<*) > (<(*+7))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL064_0
	.byte %01000100
	.byte %01000100
	.byte %01111100
	.byte %01111100
	.byte %01111100
	.byte %10000111
	.byte %00000111
	.byte %00000100
 if ECHOFIRST
       echo "    ",[(scoretable - *)]d , "bytes of ROM space left")
 endif 
ECHOFIRST = 1
 
 
 
