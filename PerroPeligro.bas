 rem DiscDog

 playfield:
 ................................
 .X.X.X..........................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end

 player0:
 %01000100
 %01000100
 %01111100
 %01111100
 %01111100
 %10000111
 %00000111
 %00000100
end

 COLUPF = 176
 scorecolor = 52
 score = 0
 
 player0x = 52
 player0y = -16

 missile0x = 52
 missile0y = 0
 missile0height = 16

 missile1x = 92
 missile1y = 0
 missile1height = 16

 ballx = 80
 bally = 50
 ballheight = 4
 CTRLPF = $21


 dim perrosalto = a
 dim missile0vel = b
 dim missile1vel = c
 dim puntos = d
 dim perrodireccion = e
 dim perrovidas = f
 dim counter1 = g
 dim counter2 = h
 dim ballstatus = i


 puntos = 0
 perrodireccion = 1
 perrovidas = 3
 missile0vel = 5
 missile1vel = 3
 counter1 = 0
 counter2 = 0
 ballstatus = 0;


mainloop

 AUDV0 = 0
 COLUP0 = 4
 COLUP1 = 132

 counter1 = counter1 + 1
 if perrovidas > 0 then gosub caidauno

 counter2 = counter2 + 1
 if perrovidas > 0 then gosub caidados

 if player0y = 104 then player0y = 0 : perrovidas = perrovidas - 1

 if perrovidas = 0 then COLUPF = 52 : gosub limpiarpantalla
 if perrovidas = 0 then gosub game
 if perrovidas = 0 then gosub over 

 if joy0left && player0x > 21 && perrovidas > 0 then gosub moverizquierda
 if joy0right && player0x < 133 && perrovidas > 0 then gosub moverderecha
 if joy0up && perrosalto = 0 && perrovidas > 0 && collision(player0,missile0) then perrosalto = 1
 if joy0up && perrosalto = 0 && perrovidas > 0 && collision(player0,missile1) then perrosalto = 1

 if perrosalto >= 1 then gosub saltarsubida

 if perrovidas > 0 && perrosalto = 0 && !collision(player0,missile0) && !collision(player0,missile1) then player0y = player0y + 1

 gosub premio
  
 gosub marcador

 NUSIZ0 = $30
 missile0height = 16

 NUSIZ1 = $30
 missile1height = 16

 drawscreen
 goto mainloop

moverizquierda
 player0:
 %00100010
 %00100010
 %00111110
 %00111110
 %00111111
 %11100000
 %11100000
 %00100000
end
 perrodireccion = 2
 player0x = player0x - 1
 return

moverderecha
 player0:
%01000100
%01000100
%01111100
%01111100
%01111100
%10000111
%00000111
%00000100
end
 player0x = player0x + 1
 perrodireccion = 1	
 return

saltarsubida
 player0y = player0y - 1
 perrosalto = perrosalto + 1
 if perrosalto = 60 then perrosalto = 0
 return

caidauno
  if counter1 = missile0vel then missile0y = missile0y + 1 : counter1 = 0
  if missile0y = 104 then missile0y = 0 : missile0vel = (rand & 1) + 2 : score = score + 10
  return

caidados
  if counter2 = missile1vel then missile1y = missile1y + 1 : counter2 = 0
  if missile1y = 104 then missile1y = 0 : missile1vel = (rand & 1) + 2 : score = score + 10
  return

premio
  if ballstatus = 0 then ballstatus = 1 : ballx  = (rand & 90) + 50 : bally  = (rand & 60) + 20 
  if collision(player0,ball) && ballstatus = 1 then score = score + 500 : ballstatus = 0 : ballx = 0 : bally = 0 : perrovidas = perrovidas + 1
  return

marcador
 if perrovidas > 3 then perrovidas = 3 
 if perrovidas = 3 then pfpixel 1 1 on : pfpixel 3 1 on : pfpixel 5 1 on  
 if perrovidas = 2 then pfpixel 1 1 on : pfpixel 3 1 on : pfpixel 5 1 off 
 if perrovidas = 1 then pfpixel 1 1 on : pfpixel 3 1 off : pfpixel 5 1 off 
 if perrovidas = 0 then pfpixel 1 1 off : pfpixel 3 1 off : pfpixel 5 1 off 
 return

limpiarpantalla
 pfpixel 5 1 off 
 pfpixel 3 1 off
 pfpixel 1 1 off
 pfpixel 22 1 off
 pfpixel 23 1 off
 pfpixel 24 1 off
 pfpixel 25 1 off
 pfpixel 26 1 off
 pfpixel 27 1 off
 pfpixel 28 1 off
 pfpixel 29 1 off
 pfpixel 30 1 off
 pfpixel 31 1 off
 drawscreen

 missile0y = 0
 missile1y = 0

 return

game
 pfpixel 6 0 on	
 pfpixel 7 0 on	
 pfpixel 8 0 on	
 pfpixel 11 0 on	
 pfpixel 12 0 on	
 pfpixel 13 0 on
 pfpixel 15 0 on	
 pfpixel 19 0 on	
 pfpixel 21 0 on	
 pfpixel 22 0 on	
 pfpixel 23 0 on	
 pfpixel 24 0 on

 pfpixel 5 1 on	
 pfpixel 10 1 on	
 pfpixel 13 1 on	
 pfpixel 15 1 on	
 pfpixel 16 1 on	
 pfpixel 18 1 on	
 pfpixel 19 1 on	
 pfpixel 21 1 on

 pfpixel 5 2 on
 pfpixel 7 2 on
 pfpixel 8 2 on
 pfpixel 10 2 on	
 pfpixel 13 2 on
 pfpixel 15 2 on	
 pfpixel 17 2 on
 pfpixel 19 2 on	
 pfpixel 21 2 on
 pfpixel 22 2 on

 pfpixel 5 3 on	
 pfpixel 8 3 on	
 pfpixel 10 3 on	
 pfpixel 11 3 on	
 pfpixel 12 3 on	
 pfpixel 13 3 on	
 pfpixel 15 3 on	
 pfpixel 19 3 on
 pfpixel 21 3 on

 pfpixel 6 4 on	
 pfpixel 7 4 on
 pfpixel 10 4 on		
 pfpixel 13 4 on
 pfpixel 15 4 on
 pfpixel 19 4 on
 pfpixel 21 4 on
 pfpixel 22 4 on
 pfpixel 23 4 on
 pfpixel 24 4 on
 drawscreen
 return

over
 pfpixel 6 6 on
 pfpixel 7 6 on
 pfpixel 10 6 on
 pfpixel 14 6 on
 pfpixel 16 6 on
 pfpixel 17 6 on
 pfpixel 18 6 on
 pfpixel 19 6 on
 pfpixel 21 6 on
 pfpixel 22 6 on
 pfpixel 23 6 on
 pfpixel 24 6 on

 pfpixel 5 7 on
 pfpixel 8 7 on
 pfpixel 10 7 on
 pfpixel 14 7 on
 pfpixel 16 7 on
 pfpixel 21 7 on
 pfpixel 24 7 on

 pfpixel 5 8 on
 pfpixel 8 8 on
 pfpixel 10 8 on
 pfpixel 14 8 on
 pfpixel 16 8 on
 pfpixel 17 8 on
 pfpixel 21 8 on
 pfpixel 22 8 on
 pfpixel 23 8 on

 pfpixel 5 9 on
 pfpixel 8 9 on
 pfpixel 11 9 on
 pfpixel 13 9 on
 pfpixel 16 9 on
 pfpixel 21 9 on
 pfpixel 23 9 on

 pfpixel 6 10 on
 pfpixel 7 10 on
 pfpixel 12 10 on
 pfpixel 16 10 on
 pfpixel 17 10 on
 pfpixel 18 10 on
 pfpixel 19 10 on
 pfpixel 21 10 on
 pfpixel 24 10 on
 drawscreen	
 return

