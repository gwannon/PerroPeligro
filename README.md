# PerroPeligro™
PerroPeligro™ es un juego de plataformas para Atari 2600 de 4,1Kb. PerroPeligro™ deberá saltar de una plataforma a otra y evitar caerse. Si se cae pierde una de sus 3 vidas y vuelve a aparecer por arriba. Cada plataforma que pasa da 100 puntos.

Está desarrollado a partir de [batari Basic](https://github.com/batari-Basic/batari-Basic). batari Basic (bB) es un lenguaje similar a BASIC para crear juegos Atari 2600.

Es un lenguaje compilado que se ejecuta en una computadora y crea un binario que se puede ejecutar en un emulador Atari 2600 como Stella o se puede usar el archivo binario para fabricar un cartucho que funcione en un Atari 2600 real.

[Repositorio en GitHub](https://github.com/gwannon/PerroPeligro)

## Cómo se juega
PerroPeligro™ tiene que evitar caerse y para ello debe saltar de plataforma en plataforma (rectángulos grises y azules). Si coge su premio (cuadrado verde) consigue 500 puntos y recupera una vida hasta un máximo de 3. De esta forma te puedes arriesgarte a caerte si sabes que vas a coger el premio.

Cada plataforma que pasa le da 100 puntos.

## Controles
* Flecha Arriba: saltar
* Flecha Izquierda: moverse a la izquierda
* Flecha derecha: moverse a la derecha


## Cómo instalar bB
Simplemente hay que bajarse su repositorio en [github](https://github.com/batari-Basic/batari-Basic) y seguir las instrucciones de instalación.

1. Descargar y descomprimir la distribución básica de batari Basic, asegurando que se mantenga la estructura del directorio en el zip.
2. Abrir una ventana de terminal, ejecutar el instalador y seguir las instrucciones: ./install_ux.sh

## Cómo compilar el juego.
1. Para compilar solamente abría que ejecutar 2600basic sh /ruta/al/archivo/PerroPeligro.bas
2. Se generan varios archivos. PerroPeligro.bas.asm es el código en ensamblador y PerroPeligro.bas.bin es el binario con el juego.

## Ejecutar en emulador Stella

PerroPeligro™ está pensado para jugarse en una Atari 2600. Por eso se puede ejecutar en el emulador Stella para Atari 2600. Para instalar el Stella basta con ejecutar el comando:

```
sudo pacman -Rs stella
```

Para lanzar el juego seria:

```
stella ./PerroPeligro.bas.bin
```