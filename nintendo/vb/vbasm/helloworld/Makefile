################################################################################
# VARIABLEN                                                                    #
################################################################################

# Dateien, die durch ein 'clean' gel�scht werden sollen
CLEANABLE_OBJS = dist/hello.vb

ASSEMBLER = vbasm # Damit wird unser Assemblercode in eine Objektdatei kompiliert
#DEPLOYER = # Legt das Programm fest, um das ROM auf eine Karte zu �bertragen
EMU = vb  # Legt den Emulator fest, mit dem wir unser ROM testen
CC = gcc # C-Compiler
CFLAGS = -Wall -ansi -pedantic -g -O0 # C-Compiler-Argumente
ASSFLAGS = # Argumente f�r den Assembler

################################################################################
# RULES                                                                        #
################################################################################

# 'Phony targets' sind Aktionen und keine Dateien und m�ssen daher immer
# ausgef�hrt werden

.PHONY: all run deploy

all: dist/hello.vb

dist/hello.vb: src/main.asm
	 cd src && $(ASSEMBLER) main.asm -o ../dist/hello.vb && cd ..
 
run: dist/hello.vb
	$(EMU) dist/hello.vb
  
#deploy: dist/hello.vb
#	$(DEPLOYER) dist/hello.vb

# l�scht alle (durch dieses Makefile) erzeugten Dateien
clean:
	-rm $(CLEANABLE_OBJS)
