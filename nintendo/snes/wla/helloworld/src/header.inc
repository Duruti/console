; Definiere die Speicherarchitektur des Zielsystems (des Super Nintendos)
;  Nur LOROM
.MEMORYMAP 
  ; Es gibt nur einen 'Speicherslot' im Super Nintendo, also ist dieser auch 
  ;  unser Standardspeicherslot
  DEFAULTSLOT 0                         
  ; Wir haben einen 'Speicherslot', der insgesamt $8000 Bytes umfassen kann    
  SLOTSIZE $8000             
  ; Speicherslot 0 beginnt bei Adresse $8000
  SLOT 0 $8000                  
.ENDME         

; Jede ROM-Bank besitzt 32KB, also $8000 Bytes
.ROMBANKSIZE $8000             
; Unser ROM (die kompilierte SMC-Datei) muss mindestens 2 MBits umfassen, da 
;  dies die kleinste zul�ssige Gr��e eines SNES-Roms ist. Also ben�tigen wir 
;  insgesamt 8*32KB gro�e ROM-B�nke.
;
;  32KB*8 == 32*2^10*8 Bits*8 == 2^5*2^10*2^3*2^3 Bits == 2^21 Bit == 2*2^20 Bit 
;  == 2 MBits
.ROMBANKS 8

; Nun m�ssen wir unseren SNES-Header definieren, der Metadaten �ber das 
;  eigentliche ROM beinhaltet.
;
; Hinweis: Dieser 'SNES-Header' wird auch manchmal 'Internal Header' oder 
;  'Embedded Cartridge Information' genannt.
;  Des Weiteren ist es auch eigentlich kein Header, da diese Daten mitten im ROM
;  und nicht am Anfang des ROMs liegen.
;  Au�erdem sollte der SNES-Header nicht mit dem SMC/SWC-Header verwechselt 
;  werden, der beim Kopieren eines Spiels auf 3,5"-Disketten erstellt 
;  wird/wurde (also beim 'Kopiervorgang' des SNES-Moduls).
.SNESHEADER
  ; ROM-ID
  ;  Eine 1-4 Zeichen lange Zeichenkette. Wir belassen es bei "SNES"
  ID "SNES"
  
  ; Interner Name unseres ROMs. 
  ;  Dies beinflusst NICHT den Dateinamen des kompilierten ROMs.
  ;  Diese Zeichenkette darf nicht l�nger als 21 Zeichen == Bytes sein
  ;  Leere Zeichen sollten / (m�ssen?) mit Leerzeichen aufgef�llt werden
  NAME "SNES HELLO WORLD     "  
  ;    "000000000111111111122" - Z�hlhilfe
  ;    "123456789012345678901" - Z�hlhilfe

  ; Unser ROM ist ein SLOWROM.
  SLOWROM
  ; Wir wollen erst einmal nur LOROM nutzen
  LOROM

  ; Wir definieren nur ein ROM $00. Unser ROM besitzt damit keine Co-Prozessoren
  ;  und keinen SRAM.
  CARTRIDGETYPE $00          
  ; Unser ROM umfasst 2 MBits 
  ROMSIZE $08                  
  ; Keinen SRAM
  SRAMSIZE $00                  
  ; L�ndercode $09 f�r Deutschland, �sterreich und die Schweiz
  COUNTRY $09
  ; Unser ROM stammt nat�rlich von Nintendo. 
  ;  Andere Quellen empfehlen hier den Wert $00, da dies von den meisten 
  ;  Emulatoren wahrscheinlich ignoriert wird. Das Dokument 'Snesrom.txt' in
  ;  Qwertie's SNES-Base behauptet, dass $00 ein ung�ltiger Wert ist, deshalb 
  ;  belasse ich es bei $01 == Nintendo
  LICENSEECODE $01
  ; Unser ROM hat die Version 1.00
  VERSION $00
.ENDSNES

; Hier definieren wir die Vektortabelle / die Unterbechungszeiger f�r den 
;  nativen 65816-Modus 
.SNESNATIVEVECTOR              
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  IRQ EmptyHandler
.ENDNATIVEVECTOR

; Hier definieren wir Vektortabelle / die Unterbechungszeiger f�r den '6502 
;  Emulation'-Mode
.SNESEMUVECTOR
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  ; Unser Code wird durch ein Label 'Start:' eingeleitet
  RESET Start
  IRQBRK EmptyHandler
.ENDEMUVECTOR

.BANK 0 SLOT 0                  
.ORG 0
.SECTION "EmptyVectors" SEMIFREE

; 'EmptyHandler' springt automatisch wieder zur�ck zum 'Hauptprogramm'
EmptyHandler:
  ; rti == return from interrupt
  rti

.ENDS

; Alle leeren Bytes werden mit dem Wert / Byte $00 aufgef�llt
.EMPTYFILL $00
