################################################################################
# VARIABLEN                                                                    #
################################################################################

# Dateien, die durch ein 'clean' gel�scht werden sollen
CLEANABLE_OBJS = dist/hello.vb obj/main.o

CCVB = v810-gcc # Damit wird unser Quellcode in eine Objektdatei kompiliert
OBJCOPY = v810-objcopy # Das ROM in ein g�ltiges VB-ROM umwandeln
#DEPLOYER = # Legt das Programm fest, um das ROM auf eine Karte zu �bertragen
EMU = vb  # Legt den Emulator fest, mit dem wir unser ROM testen
CC = gcc # C-Compiler
CFLAGS = -Wall -ansi -pedantic -g -O0 # C-Compiler-Argumente
CFLAGSVB = -Wall -nodefaultlibs -mv810 -xc # Argumente f�r den Cross-Compiler

################################################################################
# RULES                                                                        #
################################################################################

# 'Phony targets' sind Aktionen und keine Dateien und m�ssen daher immer
# ausgef�hrt werden

.PHONY: all run deploy

all: dist/hello.vb

dist/hello.vb: src/main.c
	 $(CCVB) $(CFLAGSVB) -I./include -o obj/main.o src/main.c
	 $(OBJCOPY) -S -O binary obj/main.o dist/hello.vb

run: dist/hello.vb
	$(EMU) dist/hello.vb
  
#deploy: dist/hello.vb
#	$(DEPLOYER) dist/hello.vb

# l�scht alle (durch dieses Makefile) erzeugten Dateien
clean:
	-rm $(CLEANABLE_OBJS)
