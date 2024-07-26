; Provided under the CC0 license. See the included LICENSE.txt for details.

 processor 6502
 include "vcs.h"
 include "macro.h"
 include "2600basic.h"
 include "2600basic_variable_redefs.h"
 ifconst bankswitch
  if bankswitch == 8
     ORG $1000
     RORG $D000
  endif
  if bankswitch == 16
     ORG $1000
     RORG $9000
  endif
  if bankswitch == 32
     ORG $1000
     RORG $1000
  endif
  if bankswitch == 64
     ORG $1000
     RORG $1000
  endif
 else
   ORG $F000
 endif

 ifconst bankswitch_hotspot
 if bankswitch_hotspot = $083F ; 0840 bankswitching hotspot
   .byte 0 ; stop unexpected bankswitches
 endif
 endif
; Provided under the CC0 license. See the included LICENSE.txt for details.

start
 sei
 cld
 ldy #0
 lda $D0
 cmp #$2C               ;check RAM location #1
 bne MachineIs2600
 lda $D1
 cmp #$A9               ;check RAM location #2
 bne MachineIs2600
 dey
MachineIs2600
 ldx #0
 txa
clearmem
 inx
 txs
 pha
 bne clearmem
 sty temp1
 ifnconst multisprite
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifconst pfres
 lda #(96/pfres)
 else
 lda #8
 endif
 endif
 sta playfieldpos
 endif
 ldx #5
initscore
 lda #<scoretable
 sta scorepointers,x 
 dex
 bpl initscore
 lda #1
 sta CTRLPF
 ora INTIM
 sta rand

 ifconst multisprite
   jsr multisprite_setup
 endif

 ifnconst bankswitch
   jmp game
 else
   lda #>(game-1)
   pha
   lda #<(game-1)
   pha
   pha
   pha
   ldx #1
   jmp BS_jsr
 endif
; Provided under the CC0 license. See the included LICENSE.txt for details.

     ; This is a 2-line kernel!
     ifnconst vertical_reflect
kernel
     endif
     sta WSYNC
     lda #255
     sta TIM64T

     lda #1
     sta VDELBL
     sta VDELP0
     ldx ballheight
     inx
     inx
     stx temp4
     lda player1y
     sta temp3

     ifconst shakescreen
         jsr doshakescreen
     else
         ldx missile0height
         inx
     endif

     inx
     stx stack1

     lda bally
     sta stack2

     lda player0y
     ldx #0
     sta WSYNC
     stx GRP0
     stx GRP1
     stx PF1L
     stx PF2
     stx CXCLR
     ifconst readpaddle
         stx paddle
     else
         sleep 3
     endif

     sta temp2,x

     ;store these so they can be retrieved later
     ifnconst pfres
         ldx #128-44+(4-pfwidth)*12
     else
         ldx #132-pfres*pfwidth
     endif

     dec player0y

     lda missile0y
     sta temp5
     lda missile1y
     sta temp6

     lda playfieldpos
     sta temp1
     
     ifconst pfrowheight
         lda #pfrowheight+2
     else
         ifnconst pfres
             lda #10
         else
             lda #(96/pfres)+2 ; try to come close to the real size
         endif
     endif
     clc
     sbc playfieldpos
     sta playfieldpos
     jmp .startkernel

.skipDrawP0
     lda #0
     tay
     jmp .continueP0

.skipDrawP1
     lda #0
     tay
     jmp .continueP1

.kerloop     ; enter at cycle 59??

continuekernel
     sleep 2
continuekernel2
     lda ballheight
     
     ifconst pfres
         ldy playfield+pfres*pfwidth-132,x
         sty PF1L ;3
         ldy playfield+pfres*pfwidth-131-pfadjust,x
         sty PF2L ;3
         ldy playfield+pfres*pfwidth-129,x
         sty PF1R ; 3 too early?
         ldy playfield+pfres*pfwidth-130-pfadjust,x
         sty PF2R ;3
     else
         ldy playfield-48+pfwidth*12+44-128,x
         sty PF1L ;3
         ldy playfield-48+pfwidth*12+45-128-pfadjust,x ;4
         sty PF2L ;3
         ldy playfield-48+pfwidth*12+47-128,x ;4
         sty PF1R ; 3 too early?
         ldy playfield-48+pfwidth*12+46-128-pfadjust,x;4
         sty PF2R ;3
     endif

     ; should be playfield+$38 for width=2

     dcp bally
     rol
     rol
     ; rol
     ; rol
goback
     sta ENABL 
.startkernel
     lda player1height ;3
     dcp player1y ;5
     bcc .skipDrawP1 ;2
     ldy player1y ;3
     lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
     ; so it doesn't cross a page boundary!

.continueP1
     sta GRP1 ;3

     ifnconst player1colors
         lda missile1height ;3
         dcp missile1y ;5
         rol;2
         rol;2
         sta ENAM1 ;3
     else
         lda (player1color),y
         sta COLUP1
         ifnconst playercolors
             sleep 7
         else
             lda.w player0colorstore
             sta COLUP0
         endif
     endif

     ifconst pfres
         lda playfield+pfres*pfwidth-132,x 
         sta PF1L ;3
         lda playfield+pfres*pfwidth-131-pfadjust,x 
         sta PF2L ;3
         lda playfield+pfres*pfwidth-129,x 
         sta PF1R ; 3 too early?
         lda playfield+pfres*pfwidth-130-pfadjust,x 
         sta PF2R ;3
     else
         lda playfield-48+pfwidth*12+44-128,x ;4
         sta PF1L ;3
         lda playfield-48+pfwidth*12+45-128-pfadjust,x ;4
         sta PF2L ;3
         lda playfield-48+pfwidth*12+47-128,x ;4
         sta PF1R ; 3 too early?
         lda playfield-48+pfwidth*12+46-128-pfadjust,x;4
         sta PF2R ;3
     endif 
     ; sleep 3

     lda player0height
     dcp player0y
     bcc .skipDrawP0
     ldy player0y
     lda (player0pointer),y
.continueP0
     sta GRP0

     ifnconst no_blank_lines
         ifnconst playercolors
             lda missile0height ;3
             dcp missile0y ;5
             sbc stack1
             sta ENAM0 ;3
         else
             lda (player0color),y
             sta player0colorstore
             sleep 6
         endif
         dec temp1
         bne continuekernel
     else
         dec temp1
         beq altkernel2
         ifconst readpaddle
             ldy currentpaddle
             lda INPT0,y
             bpl noreadpaddle
             inc paddle
             jmp continuekernel2
noreadpaddle
             sleep 2
             jmp continuekernel
         else
             ifnconst playercolors 
                 ifconst PFcolors
                     txa
                     tay
                     lda (pfcolortable),y
                     ifnconst backgroundchange
                         sta COLUPF
                     else
                         sta COLUBK
                     endif
                     jmp continuekernel
                 else
                     ifconst kernelmacrodef
                         kernelmacro
                     else
                         sleep 12
                     endif
                 endif
             else
                 lda (player0color),y
                 sta player0colorstore
                 sleep 4
             endif
             jmp continuekernel
         endif
altkernel2
         txa
         ifnconst vertical_reflect
             sbx #256-pfwidth
         else
             sbx #256-pfwidth/2
         endif
         bmi lastkernelline
         ifconst pfrowheight
             lda #pfrowheight
         else
             ifnconst pfres
                 lda #8
             else
                 lda #(96/pfres) ; try to come close to the real size
             endif
         endif
         sta temp1
         jmp continuekernel
     endif

altkernel

     ifconst PFmaskvalue
         lda #PFmaskvalue
     else
         lda #0
     endif
     sta PF1L
     sta PF2


     ;sleep 3

     ;28 cycles to fix things
     ;minus 11=17

     ; lax temp4
     ; clc
     txa
     ifnconst vertical_reflect
         sbx #256-pfwidth
     else
         sbx #256-pfwidth/2
     endif

     bmi lastkernelline

     ifconst PFcolorandheight
         ifconst pfres
             ldy playfieldcolorandheight-131+pfres*pfwidth,x
         else
             ldy playfieldcolorandheight-87,x
         endif
         ifnconst backgroundchange
             sty COLUPF
         else
             sty COLUBK
         endif
         ifconst pfres
             lda playfieldcolorandheight-132+pfres*pfwidth,x
         else
             lda playfieldcolorandheight-88,x
         endif
         sta.w temp1
     endif
     ifconst PFheights
         lsr
         lsr
         tay
         lda (pfheighttable),y
         sta.w temp1
     endif
     ifconst PFcolors
         tay
         lda (pfcolortable),y
         ifnconst backgroundchange
             sta COLUPF
         else
             sta COLUBK
         endif
         ifconst pfrowheight
             lda #pfrowheight
         else
             ifnconst pfres
                 lda #8
             else
                 lda #(96/pfres) ; try to come close to the real size
             endif
         endif
         sta temp1
     endif
     ifnconst PFcolorandheight
         ifnconst PFcolors
             ifnconst PFheights
                 ifnconst no_blank_lines
                     ; read paddle 0
                     ; lo-res paddle read
                     ; bit INPT0
                     ; bmi paddleskipread
                     ; inc paddle0
                     ;donepaddleskip
                     sleep 10
                     ifconst pfrowheight
                         lda #pfrowheight
                     else
                         ifnconst pfres
                             lda #8
                         else
                             lda #(96/pfres) ; try to come close to the real size
                         endif
                     endif
                     sta temp1
                 endif
             endif
         endif
     endif
     

     lda ballheight
     dcp bally
     sbc temp4


     jmp goback


     ifnconst no_blank_lines
lastkernelline
         ifnconst PFcolors
             sleep 10
         else
             ldy #124
             lda (pfcolortable),y
             sta COLUPF
         endif

         ifconst PFheights
             ldx #1
             ;sleep 4
             sleep 3 ; this was over 1 cycle
         else
             ldx playfieldpos
             ;sleep 3
             sleep 2 ; this was over 1 cycle
         endif

         jmp enterlastkernel

     else
lastkernelline
         
         ifconst PFheights
             ldx #1
             ;sleep 5
             sleep 4 ; this was over 1 cycle
         else
             ldx playfieldpos
             ;sleep 4
             sleep 3 ; this was over 1 cycle
         endif

         cpx #0
         bne .enterfromNBL
         jmp no_blank_lines_bailout
     endif

     if ((<*)>$d5)
         align 256
     endif
     ; this is a kludge to prevent page wrapping - fix!!!

.skipDrawlastP1
     lda #0
     tay ; added so we don't cross a page
     jmp .continuelastP1

.endkerloop     ; enter at cycle 59??
     
     nop

.enterfromNBL
     ifconst pfres
         ldy.w playfield+pfres*pfwidth-4
         sty PF1L ;3
         ldy.w playfield+pfres*pfwidth-3-pfadjust
         sty PF2L ;3
         ldy.w playfield+pfres*pfwidth-1
         sty PF1R ; possibly too early?
         ldy.w playfield+pfres*pfwidth-2-pfadjust
         sty PF2R ;3
     else
         ldy.w playfield-48+pfwidth*12+44
         sty PF1L ;3
         ldy.w playfield-48+pfwidth*12+45-pfadjust
         sty PF2L ;3
         ldy.w playfield-48+pfwidth*12+47
         sty PF1R ; possibly too early?
         ldy.w playfield-48+pfwidth*12+46-pfadjust
         sty PF2R ;3
     endif

enterlastkernel
     lda ballheight

     ; tya
     dcp bally
     ; sleep 4

     ; sbc stack3
     rol
     rol
     sta ENABL 

     lda player1height ;3
     dcp player1y ;5
     bcc .skipDrawlastP1
     ldy player1y ;3
     lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
     ; so it doesn't cross a page boundary!

.continuelastP1
     sta GRP1 ;3

     ifnconst player1colors
         lda missile1height ;3
         dcp missile1y ;5
     else
         lda (player1color),y
         sta COLUP1
     endif

     dex
     ;dec temp4 ; might try putting this above PF writes
     beq endkernel


     ifconst pfres
         ldy.w playfield+pfres*pfwidth-4
         sty PF1L ;3
         ldy.w playfield+pfres*pfwidth-3-pfadjust
         sty PF2L ;3
         ldy.w playfield+pfres*pfwidth-1
         sty PF1R ; possibly too early?
         ldy.w playfield+pfres*pfwidth-2-pfadjust
         sty PF2R ;3
     else
         ldy.w playfield-48+pfwidth*12+44
         sty PF1L ;3
         ldy.w playfield-48+pfwidth*12+45-pfadjust
         sty PF2L ;3
         ldy.w playfield-48+pfwidth*12+47
         sty PF1R ; possibly too early?
         ldy.w playfield-48+pfwidth*12+46-pfadjust
         sty PF2R ;3
     endif

     ifnconst player1colors
         rol;2
         rol;2
         sta ENAM1 ;3
     else
         ifnconst playercolors
             sleep 7
         else
             lda.w player0colorstore
             sta COLUP0
         endif
     endif
     
     lda.w player0height
     dcp player0y
     bcc .skipDrawlastP0
     ldy player0y
     lda (player0pointer),y
.continuelastP0
     sta GRP0



     ifnconst no_blank_lines
         lda missile0height ;3
         dcp missile0y ;5
         sbc stack1
         sta ENAM0 ;3
         jmp .endkerloop
     else
         ifconst readpaddle
             ldy currentpaddle
             lda INPT0,y
             bpl noreadpaddle2
             inc paddle
             jmp .endkerloop
noreadpaddle2
             sleep 4
             jmp .endkerloop
         else ; no_blank_lines and no paddle reading
             pla
             pha ; 14 cycles in 4 bytes
             pla
             pha
             ; sleep 14
             jmp .endkerloop
         endif
     endif


     ; ifconst donepaddleskip
         ;paddleskipread
         ; this is kind of lame, since it requires 4 cycles from a page boundary crossing
         ; plus we get a lo-res paddle read
         ; bmi donepaddleskip
     ; endif

.skipDrawlastP0
     lda #0
     tay
     jmp .continuelastP0

     ifconst no_blank_lines
no_blank_lines_bailout
         ldx #0
     endif

endkernel
     ; 6 digit score routine
     stx PF1
     stx PF2
     stx PF0
     clc

     ifconst pfrowheight
         lda #pfrowheight+2
     else
         ifnconst pfres
             lda #10
         else
             lda #(96/pfres)+2 ; try to come close to the real size
         endif
     endif

     sbc playfieldpos
     sta playfieldpos
     txa

     ifconst shakescreen
         bit shakescreen
         bmi noshakescreen2
         ldx #$3D
noshakescreen2
     endif

     sta WSYNC,x

     ; STA WSYNC ;first one, need one more
     sta REFP0
     sta REFP1
     STA GRP0
     STA GRP1
     ; STA PF1
     ; STA PF2
     sta HMCLR
     sta ENAM0
     sta ENAM1
     sta ENABL

     lda temp2 ;restore variables that were obliterated by kernel
     sta player0y
     lda temp3
     sta player1y
     ifnconst player1colors
         lda temp6
         sta missile1y
     endif
     ifnconst playercolors
         ifnconst readpaddle
             lda temp5
             sta missile0y
         endif
     endif
     lda stack2
     sta bally

     ; strangely, this isn't required any more. might have
     ; resulted from the no_blank_lines score bounce fix
     ;ifconst no_blank_lines
         ;sta WSYNC
     ;endif

     lda INTIM
     clc
     ifnconst vblank_time
         adc #43+12+87
     else
         adc #vblank_time+12+87

     endif
     ; sta WSYNC
     sta TIM64T

     ifconst minikernel
         jsr minikernel
     endif

     ; now reassign temp vars for score pointers

     ; score pointers contain:
     ; score1-5: lo1,lo2,lo3,lo4,lo5,lo6
     ; swap lo2->temp1
     ; swap lo4->temp3
     ; swap lo6->temp5
     ifnconst noscore
         lda scorepointers+1
         ; ldy temp1
         sta temp1
         ; sty scorepointers+1

         lda scorepointers+3
         ; ldy temp3
         sta temp3
         ; sty scorepointers+3


         sta HMCLR
         tsx
         stx stack1 
         ldx #$E0
         stx HMP0

         LDA scorecolor 
         STA COLUP0
         STA COLUP1
         ifconst scorefade
             STA stack2
         endif
         ifconst pfscore
             lda pfscorecolor
             sta COLUPF
         endif
         sta WSYNC
         ldx #0
         STx GRP0
         STx GRP1 ; seems to be needed because of vdel

         lda scorepointers+5
         ; ldy temp5
         sta temp5,x
         ; sty scorepointers+5
         lda #>scoretable
         sta scorepointers+1
         sta scorepointers+3
         sta scorepointers+5
         sta temp2
         sta temp4
         sta temp6
         LDY #7
         STY VDELP0
         STA RESP0
         STA RESP1


         LDA #$03
         STA NUSIZ0
         STA NUSIZ1
         STA VDELP1
         LDA #$F0
         STA HMP1
         lda (scorepointers),y
         sta GRP0
         STA HMOVE ; cycle 73 ?
         jmp beginscore


         if ((<*)>$d4)
             align 256 ; kludge that potentially wastes space! should be fixed!
         endif

loop2
         lda (scorepointers),y ;+5 68 204
         sta GRP0 ;+3 71 213 D1 -- -- --
         ifconst pfscore
             lda.w pfscore1
             sta PF1
         else
             ifconst scorefade
                 sleep 2
                 dec stack2 ; decrement the temporary scorecolor
             else
                 sleep 7
             endif
         endif
         ; cycle 0
beginscore
         lda (scorepointers+$8),y ;+5 5 15
         sta GRP1 ;+3 8 24 D1 D1 D2 --
         lda (scorepointers+$6),y ;+5 13 39
         sta GRP0 ;+3 16 48 D3 D1 D2 D2
         lax (scorepointers+$2),y ;+5 29 87
         txs
         lax (scorepointers+$4),y ;+5 36 108
         ifconst scorefade
             lda stack2
         else
             sleep 3
         endif

         ifconst pfscore
             lda pfscore2
             sta PF1
         else
             ifconst scorefade
                 sta COLUP0
                 sta COLUP1
             else
                 sleep 6
             endif
         endif

         lda (scorepointers+$A),y ;+5 21 63
         stx GRP1 ;+3 44 132 D3 D3 D4 D2!
         tsx
         stx GRP0 ;+3 47 141 D5 D3! D4 D4
         sta GRP1 ;+3 50 150 D5 D5 D6 D4!
         sty GRP0 ;+3 53 159 D4* D5! D6 D6
         dey
         bpl loop2 ;+2 60 180

         ldx stack1 
         txs
         ; lda scorepointers+1
         ldy temp1
         ; sta temp1
         sty scorepointers+1

         LDA #0 
         sta PF1
         STA GRP0
         STA GRP1
         STA VDELP0
         STA VDELP1;do we need these
         STA NUSIZ0
         STA NUSIZ1

         ; lda scorepointers+3
         ldy temp3
         ; sta temp3
         sty scorepointers+3

         ; lda scorepointers+5
         ldy temp5
         ; sta temp5
         sty scorepointers+5
     endif ;noscore
    ifconst readpaddle
        lda #%11000010
    else
        ifconst qtcontroller
            lda qtcontroller
            lsr    ; bit 0 in carry
            lda #4
            ror    ; carry into top of A
        else
            lda #2
        endif ; qtcontroller
    endif ; readpaddle
 sta WSYNC
 sta VBLANK
 RETURN
     ifconst shakescreen
doshakescreen
         bit shakescreen
         bmi noshakescreen
         sta WSYNC
noshakescreen
         ldx missile0height
         inx
         rts
     endif

; Provided under the CC0 license. See the included LICENSE.txt for details.

; playfield drawing routines
; you get a 32x12 bitmapped display in a single color :)
; 0-31 and 0-11

pfclear ; clears playfield - or fill with pattern
 ifconst pfres
 ldx #pfres*pfwidth-1
 else
 ldx #47-(4-pfwidth)*12 ; will this work?
 endif
pfclear_loop
 ifnconst superchip
 sta playfield,x
 else
 sta playfield-128,x
 endif
 dex
 bpl pfclear_loop
 RETURN
 
setuppointers
 stx temp2 ; store on.off.flip value
 tax ; put x-value in x 
 lsr
 lsr
 lsr ; divide x pos by 8 
 sta temp1
 tya
 asl
 if pfwidth=4
  asl ; multiply y pos by 4
 endif ; else multiply by 2
 clc
 adc temp1 ; add them together to get actual memory location offset
 tay ; put the value in y
 lda temp2 ; restore on.off.flip value
 rts

pfread
;x=xvalue, y=yvalue
 jsr setuppointers
 lda setbyte,x
 and playfield,y
 eor setbyte,x
; beq readzero
; lda #1
; readzero
 RETURN

pfpixel
;x=xvalue, y=yvalue, a=0,1,2
 jsr setuppointers

 ifconst bankswitch
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon_r  ; if "on" go to on
 lsr
 bcs pixeloff_r ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixelon_r
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixeloff_r
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN

 else
 jmp plotpoint
 endif

pfhline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 jmp noinc
keepgoing
 inx
 txa
 and #7
 bne noinc
 iny
noinc
 jsr plotpoint
 cpx temp3
 bmi keepgoing
 RETURN

pfvline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 sty temp1 ; store memory location offset
 inc temp3 ; increase final x by 1 
 lda temp3
 asl
 if pfwidth=4
   asl ; multiply by 4
 endif ; else multiply by 2
 sta temp3 ; store it
 ; Thanks to Michael Rideout for fixing a bug in this code
 ; right now, temp1=y=starting memory location, temp3=final
 ; x should equal original x value
keepgoingy
 jsr plotpoint
 iny
 iny
 if pfwidth=4
   iny
   iny
 endif
 cpy temp3
 bmi keepgoingy
 RETURN

plotpoint
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon  ; if "on" go to on
 lsr
 bcs pixeloff ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
  ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixelon
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixeloff
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts

setbyte
 ifnconst pfcenter
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 endif
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
; Provided under the CC0 license. See the included LICENSE.txt for details.

pfscroll ;(a=0 left, 1 right, 2 up, 4 down, 6=upup, 12=downdown)
 bne notleft
;left
 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
leftloop
 lda playfield-1,x
 lsr

 ifconst superchip
 lda playfield-2,x
 rol
 sta playfield-130,x
 lda playfield-3,x
 ror
 sta playfield-131,x
 lda playfield-4,x
 rol
 sta playfield-132,x
 lda playfield-1,x
 ror
 sta playfield-129,x
 else
 rol playfield-2,x
 ror playfield-3,x
 rol playfield-4,x
 ror playfield-1,x
 endif

 txa
 sbx #4
 bne leftloop
 RETURN

notleft
 lsr
 bcc notright
;right

 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
rightloop
 lda playfield-4,x
 lsr
 ifconst superchip
 lda playfield-3,x
 rol
 sta playfield-131,x
 lda playfield-2,x
 ror
 sta playfield-130,x
 lda playfield-1,x
 rol
 sta playfield-129,x
 lda playfield-4,x
 ror
 sta playfield-132,x
 else
 rol playfield-3,x
 ror playfield-2,x
 rol playfield-1,x
 ror playfield-4,x
 endif
 txa
 sbx #4
 bne rightloop
  RETURN

notright
 lsr
 bcc notup
;up
 lsr
 bcc onedecup
 dec playfieldpos
onedecup
 dec playfieldpos
 beq shiftdown 
 bpl noshiftdown2 
shiftdown
  ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif

 sta playfieldpos
 lda playfield+3
 sta temp4
 lda playfield+2
 sta temp3
 lda playfield+1
 sta temp2
 lda playfield
 sta temp1
 ldx #0
up2
 lda playfield+4,x
 ifconst superchip
 sta playfield-128,x
 lda playfield+5,x
 sta playfield-127,x
 lda playfield+6,x
 sta playfield-126,x
 lda playfield+7,x
 sta playfield-125,x
 else
 sta playfield,x
 lda playfield+5,x
 sta playfield+1,x
 lda playfield+6,x
 sta playfield+2,x
 lda playfield+7,x
 sta playfield+3,x
 endif
 txa
 sbx #252
 ifconst pfres
 cpx #(pfres-1)*4
 else
 cpx #44
 endif
 bne up2

 lda temp4
 
 ifconst superchip
 ifconst pfres
 sta playfield+pfres*4-129
 lda temp3
 sta playfield+pfres*4-130
 lda temp2
 sta playfield+pfres*4-131
 lda temp1
 sta playfield+pfres*4-132
 else
 sta playfield+47-128
 lda temp3
 sta playfield+46-128
 lda temp2
 sta playfield+45-128
 lda temp1
 sta playfield+44-128
 endif
 else
 ifconst pfres
 sta playfield+pfres*4-1
 lda temp3
 sta playfield+pfres*4-2
 lda temp2
 sta playfield+pfres*4-3
 lda temp1
 sta playfield+pfres*4-4
 else
 sta playfield+47
 lda temp3
 sta playfield+46
 lda temp2
 sta playfield+45
 lda temp1
 sta playfield+44
 endif
 endif
noshiftdown2
 RETURN


notup
;down
 lsr
 bcs oneincup
 inc playfieldpos
oneincup
 inc playfieldpos
 lda playfieldpos

  ifconst pfrowheight
 cmp #pfrowheight+1
 else
 ifnconst pfres
   cmp #9
 else
   cmp #(96/pfres)+1 ; try to come close to the real size
 endif
 endif

 bcc noshiftdown 
 lda #1
 sta playfieldpos

 ifconst pfres
 lda playfield+pfres*4-1
 sta temp4
 lda playfield+pfres*4-2
 sta temp3
 lda playfield+pfres*4-3
 sta temp2
 lda playfield+pfres*4-4
 else
 lda playfield+47
 sta temp4
 lda playfield+46
 sta temp3
 lda playfield+45
 sta temp2
 lda playfield+44
 endif

 sta temp1

 ifconst pfres
 ldx #(pfres-1)*4
 else
 ldx #44
 endif
down2
 lda playfield-1,x
 ifconst superchip
 sta playfield-125,x
 lda playfield-2,x
 sta playfield-126,x
 lda playfield-3,x
 sta playfield-127,x
 lda playfield-4,x
 sta playfield-128,x
 else
 sta playfield+3,x
 lda playfield-2,x
 sta playfield+2,x
 lda playfield-3,x
 sta playfield+1,x
 lda playfield-4,x
 sta playfield,x
 endif
 txa
 sbx #4
 bne down2

 lda temp4
 ifconst superchip
 sta playfield-125
 lda temp3
 sta playfield-126
 lda temp2
 sta playfield-127
 lda temp1
 sta playfield-128
 else
 sta playfield+3
 lda temp3
 sta playfield+2
 lda temp2
 sta playfield+1
 lda temp1
 sta playfield
 endif
noshiftdown
 RETURN
; Provided under the CC0 license. See the included LICENSE.txt for details.

;standard routines needed for pretty much all games
; just the random number generator is left - maybe we should remove this asm file altogether?
; repositioning code and score pointer setup moved to overscan
; read switches, joysticks now compiler generated (more efficient)

randomize
	lda rand
	lsr
 ifconst rand16
	rol rand16
 endif
	bcc noeor
	eor #$B4
noeor
	sta rand
 ifconst rand16
	eor rand16
 endif
	RETURN
; Provided under the CC0 license. See the included LICENSE.txt for details.

drawscreen
     ifconst debugscore
         ldx #14
         lda INTIM ; display # cycles left in the score

         ifconst mincycles
             lda mincycles 
             cmp INTIM
             lda mincycles
             bcc nochange
             lda INTIM
             sta mincycles
nochange
         endif

         ; cmp #$2B
         ; bcs no_cycles_left
         bmi cycles_left
         ldx #64
         eor #$ff ;make negative
cycles_left
         stx scorecolor
         and #$7f ; clear sign bit
         tax
         lda scorebcd,x
         sta score+2
         lda scorebcd1,x
         sta score+1
         jmp done_debugscore 
scorebcd
         .byte $00, $64, $28, $92, $56, $20, $84, $48, $12, $76, $40
         .byte $04, $68, $32, $96, $60, $24, $88, $52, $16, $80, $44
         .byte $08, $72, $36, $00, $64, $28, $92, $56, $20, $84, $48
         .byte $12, $76, $40, $04, $68, $32, $96, $60, $24, $88
scorebcd1
         .byte 0, 0, 1, 1, 2, 3, 3, 4, 5, 5, 6
         .byte 7, 7, 8, 8, 9, $10, $10, $11, $12, $12, $13
         .byte $14, $14, $15, $16, $16, $17, $17, $18, $19, $19, $20
         .byte $21, $21, $22, $23, $23, $24, $24, $25, $26, $26
done_debugscore
     endif

     ifconst debugcycles
         lda INTIM ; if we go over, it mucks up the background color
         ; cmp #$2B
         ; BCC overscan
         bmi overscan
         sta COLUBK
         bcs doneoverscan
     endif

overscan
     ifconst interlaced
         PHP
         PLA 
         EOR #4 ; flip interrupt bit
         PHA
         PLP
         AND #4 ; isolate the interrupt bit
         TAX ; save it for later
     endif

overscanloop
     lda INTIM ;wait for sync
     bmi overscanloop
doneoverscan

     ;do VSYNC

     ifconst interlaced
         CPX #4
         BNE oddframevsync
     endif

     lda #2
     sta WSYNC
     sta VSYNC
     STA WSYNC
     STA WSYNC
     lsr
     STA WSYNC
     STA VSYNC
     sta VBLANK
     ifnconst overscan_time
         lda #37+128
     else
         lda #overscan_time+128
     endif
     sta TIM64T

     ifconst interlaced
         jmp postsync 

oddframevsync
         sta WSYNC

         LDA ($80,X) ; 11 waste
         LDA ($80,X) ; 11 waste
         LDA ($80,X) ; 11 waste

         lda #2
         sta VSYNC
         sta WSYNC
         sta WSYNC
         sta WSYNC

         LDA ($80,X) ; 11 waste
         LDA ($80,X) ; 11 waste
         LDA ($80,X) ; 11 waste

         lda #0
         sta VSYNC
         sta VBLANK
         ifnconst overscan_time
             lda #37+128
         else
             lda #overscan_time+128
         endif
         sta TIM64T

postsync
     endif

     ifconst legacy
         if legacy < 100
             ldx #4
adjustloop
             lda player0x,x
             sec
             sbc #14 ;?
             sta player0x,x
             dex
             bpl adjustloop
         endif
     endif
     if ((<*)>$e9)&&((<*)<$fa)
         repeat ($fa-(<*))
         nop
         repend
     endif
     sta WSYNC
     ldx #4
     SLEEP 3
HorPosLoop     ; 5
     lda player0x,X ;+4 9
     sec ;+2 11
DivideLoop
     sbc #15
     bcs DivideLoop;+4 15
     sta temp1,X ;+4 19
     sta RESP0,X ;+4 23
     sta WSYNC
     dex
     bpl HorPosLoop;+5 5
     ; 4

     ldx #4
     ldy temp1,X
     lda repostable-256,Y
     sta HMP0,X ;+14 18

     dex
     ldy temp1,X
     lda repostable-256,Y
     sta HMP0,X ;+14 32

     dex
     ldy temp1,X
     lda repostable-256,Y
     sta HMP0,X ;+14 46

     dex
     ldy temp1,X
     lda repostable-256,Y
     sta HMP0,X ;+14 60

     dex
     ldy temp1,X
     lda repostable-256,Y
     sta HMP0,X ;+14 74

     sta WSYNC
     
     sta HMOVE ;+3 3


     ifconst legacy
         if legacy < 100
             ldx #4
adjustloop2
             lda player0x,x
             clc
             adc #14 ;?
             sta player0x,x
             dex
             bpl adjustloop2
         endif
     endif




     ;set score pointers
     lax score+2
     jsr scorepointerset
     sty scorepointers+5
     stx scorepointers+2
     lax score+1
     jsr scorepointerset
     sty scorepointers+4
     stx scorepointers+1
     lax score
     jsr scorepointerset
     sty scorepointers+3
     stx scorepointers

vblk
     ; run possible vblank bB code
     ifconst vblank_bB_code
         jsr vblank_bB_code
     endif
vblk2
     LDA INTIM
     bmi vblk2
     jmp kernel
     

     .byte $80,$70,$60,$50,$40,$30,$20,$10,$00
     .byte $F0,$E0,$D0,$C0,$B0,$A0,$90
repostable

scorepointerset
     and #$0F
     asl
     asl
     asl
     adc #<scoretable
     tay 
     txa
     ; and #$F0
     ; lsr
     asr #$F0
     adc #<scoretable
     tax
     rts
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
 
 
 
; Provided under the CC0 license. See the included LICENSE.txt for details.

; feel free to modify the score graphics - just keep each digit 8 high
; and keep the conditional compilation stuff intact
 ifconst ROM2k
   ORG $F7AC-8
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2F94-bscode_length
       RORG $FF94-bscode_length
     endif
     if bankswitch == 16
       ORG $4F94-bscode_length
       RORG $FF94-bscode_length
     endif
     if bankswitch == 32
       ORG $8F94-bscode_length
       RORG $FF94-bscode_length
     endif
     if bankswitch == 64
       ORG  $10F80-bscode_length
       RORG $1FF80-bscode_length
     endif
   else
     ORG $FF9C
   endif
 endif

; font equates
.21stcentury = 1
alarmclock = 2     
handwritten = 3    
interrupted = 4    
retroputer = 5    
whimsey = 6
tiny = 7
hex = 8

 ifconst font
   if font == hex
     ORG . - 48
   endif
 endif

scoretable

 ifconst font
  if font == .21stcentury
    include "score_graphics.asm.21stcentury"
  endif
  if font == alarmclock
    include "score_graphics.asm.alarmclock"
  endif
  if font == handwritten
    include "score_graphics.asm.handwritten"
  endif
  if font == interrupted
    include "score_graphics.asm.interrupted"
  endif
  if font == retroputer
    include "score_graphics.asm.retroputer"
  endif
  if font == whimsey
    include "score_graphics.asm.whimsey"
  endif
  if font == tiny
    include "score_graphics.asm.tiny"
  endif
  if font == hex
    include "score_graphics.asm.hex"
  endif
 else ; default font

       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100

       .byte %01111110
       .byte %00011000
       .byte %00011000
       .byte %00011000
       .byte %00011000
       .byte %00111000
       .byte %00011000
       .byte %00001000

       .byte %01111110
       .byte %01100000
       .byte %01100000
       .byte %00111100
       .byte %00000110
       .byte %00000110
       .byte %01000110
       .byte %00111100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00000110
       .byte %00011100
       .byte %00000110
       .byte %01000110
       .byte %00111100

       .byte %00001100
       .byte %00001100
       .byte %01111110
       .byte %01001100
       .byte %01001100
       .byte %00101100
       .byte %00011100
       .byte %00001100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00000110
       .byte %00111100
       .byte %01100000
       .byte %01100000
       .byte %01111110

       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01111100
       .byte %01100000
       .byte %01100010
       .byte %00111100

       .byte %00110000
       .byte %00110000
       .byte %00110000
       .byte %00011000
       .byte %00001100
       .byte %00000110
       .byte %01000010
       .byte %00111110

       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %00111100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00111110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100 

       ifnconst DPC_kernel_options
 
         .byte %00000000
         .byte %00000000
         .byte %00000000
         .byte %00000000
         .byte %00000000
         .byte %00000000
         .byte %00000000
         .byte %00000000 

       endif

 endif

 ifconst ROM2k
   ORG $F7FC
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 16
       ORG $4FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 32
       ORG $8FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 64
       ORG  $10FE0-bscode_length
       RORG $1FFE0-bscode_length
     endif
   else
     ORG $FFFC
   endif
 endif
; Provided under the CC0 license. See the included LICENSE.txt for details.

 ifconst bankswitch
   if bankswitch == 8
     ORG $2FFC
     RORG $FFFC
   endif
   if bankswitch == 16
     ORG $4FFC
     RORG $FFFC
   endif
   if bankswitch == 32
     ORG $8FFC
     RORG $FFFC
   endif
   if bankswitch == 64
     ORG  $10FF0
     RORG $1FFF0
     lda $ffe0 ; we use wasted space to assist stella with EF format auto-detection
     ORG  $10FF8
     RORG $1FFF8
     ifconst superchip 
       .byte "E","F","S","C"
     else
       .byte "E","F","E","F"
     endif
     ORG  $10FFC
     RORG $1FFFC
   endif
 else
   ifconst ROM2k
     ORG $F7FC
   else
     ORG $FFFC
   endif
 endif
 .word (start & $ffff)
 .word (start & $ffff)
