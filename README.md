# snake-assembly-tasm
in this project i am trying to program snake in assembly tasm the oldest version of x84 assembly.
the final version of the snake is snake2.asm
to run the snake you need dosbox(https://www.dosbox.com/download.php?main=1) you need to make a folder named tasm in main directory c:/tasm in it put all the files from the github and run the commands in dosbox-
mount c: c:\
c:
cd tasm
cycles = max
tasm /zi snake.asm
tlink /v snake.obj
snake
