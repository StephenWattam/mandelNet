
CC=ghc
CFLAGS=-O -Wall
#-fwarn-incomplete-patterns 
#-v
EXE=md

all:
	$(CC) $(CFLAGS) -o $(EXE) --make MandelDaemon 

test: all
	clear
	./$(EXE)

clean:
	rm -rfv *.o *.hi $(EXE)


