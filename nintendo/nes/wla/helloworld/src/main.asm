; Speicherarchitektur des NES-Systems einbinden. Diese definiert die sp�tere
;  Struktur des NES-ROMs
.INCLUDE "nes_memory.inc"

; F�ge die Header-Datei ein, in dem die Bitmasken und die einzelnen Adressen
;  sinvolle Namen bekommen haben
.INCLUDE "nes.inc"

; F�lle alle nicht genutzten Daten mit $00 auf.
.EMPTYFILL $00

; Wir wechseln nun zu Adresse $00 (absolut: $00) von BANK 0 in SLOT 0
.BANK 0 SLOT 0
.ORG $0000

; Die ersten 4 Bytes (Byte 0-Byte 3) eines NES-Roms bestehen immer aus dem 
  ;  String "NES^Z", wobei '^Z' das Substitute Character mit dem Wert 26 
  ;  (== $1A) ist.
  .DB $4E, $45, $53, $1A

  ; Byte 4 beschreibt die Anzahl der im NES-Rom enthaltenen 16KiB PRG-Roms.
  ;  Im PRG-Rom steht unser kompilierter Code
  ;  Das fertige NES-Rom wird derzeit nur 1x16KiB PRG-Rom enthalten.
  .DB 1

  ; Byte 5 beschreibt die Anzahl der im NES-Rom enthaltenen 8KiB CHR-Roms.
  ;  Im CHR-Rom stehen die 8x8 Kacheln f�r den Bildschirm / Hintergrund und die 
  ;  Sprites, die auf dem Hintergrund dargestellt werden sollen. In unserem Fall
  ;  (Hello World) sind dies nur die einzelnen Buchstaben und Zeichen, die auf 
  ;  dem Bildschirm dargstellt werden sollen.
  ;  Das fertige NES-Rom wird derzeit nur 1x8KiB CHR-Rom enthalten, n�mlich eine
  ;  normale ASCII-Tabelle, die die druckbaren Zeichen enth�lt.
  .DB 1

  ; Byte 6 ist komplexer aufgebaut:
  ;   Oberes Nibble (Bit 7 (MSB) - Bit 4):
  ;     Beinhaltet das untere Nibble der Mapper-Nummer (zu kompliziert, um hier 
  ;      in ein paar S�tzen erkl�rt zu werden)
  ;   Unteres Nibble (Bit 3 - Bit 0 (LSB):
  ;     Bit 0:  0 = Horizontales Spiegeln der Name und Attribute Tables
  ;             1 = Vertikales Spiegeln der Name und Attribute Tables 
  ;     Bit 1:  0 = ROM besitzt / verwendet kein SRAM
  ;             1 = ROM besitzt / verwendet SRAM (bspw. f�r Spielst�nde)
  ;     Bit 2:  0 = ROM besitzt einen 512-byte Trainer (unwichtig)
  ;             1 = ROM besitzt keinen 512-byte Trainer (unwichtig)
  ;     Bit 3:  1 = NES-Rom benutzt 4 unterschiedliche Name Tables (ohne 
  ;              Spiegelung)
  ;             0 sonst
  ;
  ; Vertikale Spiegelung einschalten (f�r dieses Programm nicht wichtig)
  ;  und unteres Mapper-Nibble auf 0 setzen (wir benutzen keinen Mapper)
  .DB %00000001 

  ; Byte 7 ist wie folgt aufgebaut:
  ;   Oberes Nibble (Bit 7 (MSB) - Bit 4):
  ;     Beinhaltet das obere Nibble der Mapper-Nummer (zu kompliziert, um hier 
  ;      in ein paar S�tzen erkl�rt zu werden)
  ;     Oberes und unteres Mapper-Nibble ergeben dann die Nummer des verwendeten 
  ;      Mappers
  ;   Unteres Nibble (Bit 3 - Bit 0 (LSB):
  ;    alle Bits sind standardm��ig 0.
  ;  
  ; Da wir keinen Mapper benutzen, sind alle Bits 0 
  .DB %00000000

  ; Byte 8-15 sind nach Definition des iNES-Headers alle $00 und werden f�r
  ;  zuk�nftige iNES-Header-Erweiterungen vorgesehen
  ;  In diesem Punkt wiedersprechen sich aber einige Quellen. Manchmal werden
  ;  diese Bytes auch zur Unterscheidung von PAL- oder NTSC-Roms verwendet

; Wechsel zur Zero-Page
.SLOT 1

; Deklariere globale Variablen, die in der Zero-Page abgelegt werden sollen und
;  global sichtbar sind
nmis: .DB $00

; Wechsel zur Adresse $3FFA (absolut: $FFFA, da SLOT 3 bei Adresse $C000 
;  beginnt) von BANK 1 in SLOT 3
.BANK 1 SLOT 3
.ORG $3FFA

; Nun definieren wir die Vektorentabelle bzw. die Unterbrechungszeiger, die 
;  bestimmen, an welche Adresse gesprungen werden soll, wenn eines der 3 
;  unterschiedlichen Unterbrechungssignale 'empfangen' wird.
;  Diese Adressen stehen immer an den letzten 6 Bytes des ersten PRG-Roms, also
;  an den Speicherstellen:
;    $FFFA und $FFFB: Adresse der zugeh�rigen NMI-Routine
;    $FFFC und $FFFD: Adresse der zugeh�rigen RESET-Routine
;    $FFFE und $FFFF: Adresse der zugeh�rigen IRQ-Routine
;
;  Hinweis: Jede Adresse besteht aus 16 Bits, also 2 Bytes. Deshalb ben�tigen 
;   die 3 Adressen insgesamt 6 Bytes

  ; Achtung: Reihenfolge der Adressen beachten (siehe oben)
  ;  Der Makro-Assembler nimmt uns hier einen Gro�teil der Arbeit ab
  .DW nmi, reset, irq

; R(ead)O(nly)-Daten liegen derzeit im PRG-ROM von $0000-$0100 
;  (absolut: $C000-$C100) 
.ORG $0000
; Diese Zeichenkette wollen wir auf dem Bildschirm ausgeben
helloWorldText:
; Durch folgende Zeile kann die Funktion des Newlines ('\n') getestet werden:
;   .BYT "Hello",10,"World",0
;
  .BYT "Hello",$20,"World",0

; Nun zur Adresse $0100 von BANK 1 in SLOT 3 wechseln (absolut: $C100)
.ORG $0100

; Nun kommt unser eigentlicher Code. Dieser wird ab Adresse $C000 beginnen.

; Die IRQ-Routine wird ausgef�hrt, wenn ein Software-Interrupt ausgel�st wurde
;  (�ber den Befehl BRK). Dies kann bspw. zum Debugging von Codeteilen benutzt
;  werden
irq:
  ; 'rti' (= Return from Interrupt) sorgt daf�r, dass wir wieder zum 
  ;  Hauptprogramm zur�ckspringt. Der Programmz�hler und das P-Register wurden
  ;  vor dem Sprung zu dieser Routine auf den Stack gerettet, sodass wir 
  ;  'gleich' normal weiterarbeiten k�nnen
  rti

; NMI (= Non-Maskable Interrupt). Diese Programmunterbrechung kann nicht durch
;  das I-Flag im P-Register maskiert / unterdr�ckt werden. Hierf�r m�ssen wir
;  das PPUCTRL-Register der PPU benutzen
;
; Ein Interrupt wird immer dann 'gesendet', wenn die PPU den sogenannten 
;  VBLANK-Zustand betritt. Nach Zeichnen des letzten Pixel der letzten Zeile 
;  eines Bildes, muss als n�chstes das erste Pixel der ersten Zeile des n�chsten
;  Bildes gezeichnet werden. Diese Umstellung bzw. die Zeit, die zwischen
;  dem Zeichnen dieser beiden Pixel (oder Zeilen) vergeht, ist die sogenannte 
;  'VBLANK-Period'. In dieser Zeit ist es sicher, die PPU-Register zu lesen und
;  zu schreiben, ohne das es zu einem unvorhersehbaren Verhalten kommen kann, da
;  die Register der PPU in dieser Zeit nicht 'benutzt' werden.
; 
; Da PAL- und NTSC-Konsolen eine unterschiedliche Bildwiederholungsrate 
;  besitzen, wird dieses Signal auf diesen Konsolen auch unterschiedlich oft 
;  ausgel�st.
nmi:
  ; Z�hle die Anzahl der 'empfangenen' NMI-Signale

  ; Hinweis: Die Variable 'nmis' ist eine 8-Bit Variable, kann also nur die 
  ;  Werte $00-$FF (0-255) annehmen. Der eigentliche Wert der Variablen ist aber
  ;  unwichtig. Wir wollen diese Variable nur benutzen, um festzustellen, ob der
  ;  NES sich im VBLANK-Zustand befindet
  inc nmis
  rti

; Ein RESET-Interrupt wird beim Einschalten des NES, als auch bei einem 
;  Soft-Reset (durch Dr�cken des Reset-Knopfes an der Konsole) ausgel�st.
;
; Hinweis: Bei einem Soft-Rest wird der Speicher des NES nicht geleert
;
; Hier beginnt also unser Programm! => Endlich!
reset:
  ; Zuerst m�ssen wir alles erst einmal richtig initialisieren 

  ; Setze das I-Flag im P-Register auf 0. Dies sorgt daf�r, dass wir ab jetzt 
  ;  alle zuk�nftigen Unterbrechungsanforderungen ignorieren
  sei  

  ; BCD-Modus ausschalten. Wir arbeiten stets im Bin�r-Modus
  cld   

  ; Alles was uns beim Initialisieren st�ren k�nnte, muss abgeschaltet werden
  ldx #0
  ; W�hrend der Initialisierung kein NMI-Interrupt beim Betreten des 
  ;  VBLANK-Zustand ausl�sen. Dies gilt solange, bis wir Bit 7 von PPUCTRL 
  ;  wieder setzen
  ;
  ; Das Suffix '.W' signalisiert dem Makro-Assembler, dass es sich bei PPUCTRL
  ;  definitiv um eine 16 Bit-Adresse handelt.
  stx PPUCTRL.W  
  ; Bildschirm komplett ausschalten. W�hrend der Initialisierung wird nichts 
  ;  sichtbar auf dem Bildschirm dargestellt
  stx PPUMASK.W   
    
  ; Stack initialisieren. Wir setzen den Stapelzeiger auf Adresse $(1)FF.
  ;  Das 9. Bit des Stapelzeigers ist immer 1, deshalb setzen wir den
  ;  Stapelzeiger auf die letzte Speicherstelle in Seite 1 mithilfe des 
  ;  Bytes $FF
  ;
  ; Anstatt des Befehls 'ldx #$FF' k�nnten wir auch das weiter oben mit 0 
  ;  initialisierte X-Register mit 'dex' dekrementieren. Beide Befehle ben�tigen
  ;  aber 2 Taktzyklen, sodass beide Befehle hier 'gleichschnell' ausgef�hrt 
  ;  werden
  ldx #$FF  
  ; Transferiere den Inhalt des X-Registers in das Register, das den 
  ;  Stapelzeiger enth�lt          
  txs     

  ; L�sche auf jeden Fall das Bit 7 im PPUSTATUS-Register, da wir uns nicht 
  ;  darauf verlassen k�nnen, dass es beim Einschalten oder beim 'Reset' auf 0
  ;  gesetzt wurde
  ;
  ; Durch den Befehl 'bit PPUSTATUS.W' wird Bit 7 des Registers ausgelesen und 
  ;  nach dem Auslesen autoamtisch auf 0 gesetzt.
  bit PPUSTATUS.W    

; Wir m�ssen insgesamt 2 VBLANK-Zust�nde abwarten, bevor wir den PPU-Speicher
;  benutzen k�nnen 
;  (Quelle: http://wiki.nesdev.com/w/index.php/PPU_power_up_state)
vwait1:

  ; Mithilfe von 'bit PPUSTATUS.W' k�nnen wir relativ leicht das Bit 7 von 
  ;  PPUSTATUS abfragen, da es automatisch durch den Befehl 'bit' in das N-Flag
  ;  (Negativ-Flag) kopiert wird
  bit PPUSTATUS.W

  ; Nur wenn das Bit 7 von PPUSTATUS gesetzt ist, befindet sich die PPU derzeit 
  ;  im VBLANK-Zustand  
  ; 
  ; Nach dem 'bit'-Befehl k�nnen wir nun das N-Flag des P-Registers testen. 
  ;
  ; 'bpl' (branch on plus) verzweigt zur angegebenen Adresse, wenn das N-Flag 
  ;  des P-Registers gleich 0 ist.
  ;
  ; Wenn N==0 ist, dann ist die PPU nicht im VBLANK-Zustand und wir m�ssen auf
  ; den ersten VBLANK-Zustand warten => springe wieder hoch zum Label 'vwait1'
  bpl vwait1

  ; Wenn diese Zeile erreicht ist, war die PPU schon einmal im VBLANK-Zustand

  ; Wir m�ssen nun noch auf den zweiten VBLANK-Zustand warten. Da dieser Zustand
  ;  erst in ein paar tausend Taktzyklen erreicht ist, k�nnen wir diese Zeit 
  ;  auch sinvoll nutzen, indem wir bspw. die Zero-Page 'nullen'.

  ; In Y-Register steht der Wert, mit dem die Zero-Page initialisiert werden 
  ;  soll (in diesem Fall 0)
  ldy #0

  ; Im X-Register wird der Offset der zu initialisierenden Adresse 
  ;  zwischengespeichert. Dieses X-Register wird dann f�r die sogenannte 
  ;  indizierte Adressierung benutzt
  ldx #$00 ;

; Die folgende Schleife 'nullt' die Zero-Page ($00-$FF)
clear_zp:
  ; Schreibe den Inhalt des Y-Registers (0) an die Adresse $00+x, wobei x den 
  ;  aktuellen Inhalt des X-Registers repr�sentiert
  sty $00,x
  ; inkrementiere den Inhalt des X-Registers um 1 (f�r den n�chsten 
  ;  Schleifendurchlauf)
  inx   
  ; 'bne' testet das Z-Flag im P-Register. Dieses Flag wird gesetzt, sofern die
  ;  letzte Operation (bspw. 'inx' das Ergebnis 0 hatte).
  ;  Dies ist genau dann der Fall, wenn der Inahlt des X-Register $FF == 255 ist
  ;  und die Inkrementierung des X-Registers eine 0 ergibt (da wir ja nur 
  ;  8 Bit-Register zur Verf�gung haben
  ;
  ; Der folgende Befehl springt also 255-mal zum Label clear_zp, sodass wir mit
  ;  dieser Schleife die komplette Seite 0 (Zero-Page) mit 0 initialisieren 
  ;  k�nnen
  bne clear_zp
  
; Gleicher Code wie oben, wir warten darauf, dass die PPU den VBLANK-Zustand 
;  betritt
; 
; Hier m�ssen wir das Bit 7 des PPU-Registers PPUSTATUS nicht l�schen, da wir 
;  automatisch wissen, dass es gel�scht sein muss. Durch das Auslesen weiter 
;  oben wurde das Bit automatisch wieder auf 0 gesetzt
vwait2:
  bit PPUSTATUS.W
  bpl vwait2

; Jetzt ist alles initialisiert, die PPU ist auch verf�gbar => Los geht's

start:
  ; Springe zum Unterprogramm 'draw_helloworld'
  jsr draw_helloworld

  ; Ab jetzt wollen wir auf den Speicher der PPU zugreifen. Wir m�ssen also ab
  ;  jetzt sicherstellen, dass wir nur w�hrend des VBLANK-Zustands auf den 
  ;  PPU-Speicher zugreifen
  ;
  ; Also aktivieren wir die Eigenschaft, dass bei jedem VBLANK ein NMI-Interrupt
  ;  ausgel�st wird
  lda #VBLANK_NMI
  sta PPUCTRL.W

  ; Lade die Anzahl der ausgel�sten und registrieren NMI-Interrupts
  lda nmis

; Mit der folgenden Schleife warten wir auf den n�chsten VBLANK-Zustand
local_loop3:
  ; Ist die Anzahl der ausgel�sten und registrierten NMI-Interrupts noch gleich?
  ;
  ; WENN ja DANN m�ssen wir wieder zum anonymen Laben (':') springen, da wir
  ;  noch nicht im VBLANK-Zustand sind
  ; WENN nein DANN befinden wir uns gerade in einem VBLANK-Zustand, wir k�nnen
  ;  also jetzt u.a. den Bildschirm einschalten
  cmp nmis
  beq local_loop3

  ; Jetzt m�ssen wir noch den vertikalen und den horizontalen 'Screen Scroll 
  ;  Offset' setzen. Da wir kein 'Scrolling', also die Bewegung des 
  ;  Bildschirminhalts ben�tigen, setzen wir beide Offsets auf 0 und schalten 
  ;  das Scrolling damit ab
  ;
  ; Hinweis: Der erste geschriebene Wert nach PPUSCROLL ist der vertikale 
  ; Screen Offset. Der zweite Wert entsprechend der horizontale Screen Offset
  lda #0 
  sta PPUSCROLL.W
  sta PPUSCROLL.W

  ; Mit den folgeden beiden Befehlen aktivieren wir das Ausl�sen eines 
  ;  NMI-Interrupts bei Betreten des VBLANK-Zustands. Des Weiteren setzen wir
  ;  wir die Adresse der 'Pattern Tables' von Hintergrund und von den Sprites 
  ;  auf $1000. Wir benutzen also eigentlich nur eine 'Pattern Table' f�r 
  ;  Hintergrund und Sprites
  lda #BG_1000|OBJ_1000
  sta PPUCTRL.W

  ; Mit den folgende beiden Begehlen schalten wir nun das Zeichen von 
  ;  Hintergrund und Sprites ein
  lda #BG_ON|OBJ_ON
  sta PPUMASK.W

; Wir sind nun fertig und wechseln nun in eine Endlosschleife
loop:
  jmp loop

; Dieses Unterprogramm l�scht den Bildschirm
clear_screen:
  ; Wir werden Leerzeichen in die komplette 'Name Table 0' schreiben
  ; 
  ; Dazu m�ssen wir zuerst die Adresse der 'Name Table 0' ($2000) laden
  ;  High-Byte in den Akkumulator und das Low-Byte in das X-Register
  lda #$20
  ldx #$00

  ; nun m�ssen wir der PPU 'sagen', dass Sie auf diese Adresse zeigen soll.
  ;  Als erstes schreiben wir das High-Byte der Adresse nach PPUADDR
  ;  Dann das Low-Byte der Adresse nach PPUADDR
  sta PPUADDR.W
  stx PPUADDR.W

  ; Nun laden wir den Wert 240.
  ;
  ; Hier muss ich jetzt etwas weiter ausholen:
  ;  Eine 'Name Table' speichert den Inhalt von 30 Zeilen, die je 32 Zeichen 
  ;  besitzen. Insgesamt kann der Bildschirm also 30*32 == 960 Zeichen 
  ;  darstellen. Wir k�nnen den Inhalt des Bildschirm also mit 2 ineinander 
  ;  verschachtelten Schleifen l�schen. Nachteile von 2 ineinander 
  ;  verschachtelten Schleifen sind die Verschlechterung der Performance und
  ;  eine wahrscheinlich komplizierte Berechnung des Adressenoffsets. 
  ;
  ;  Deshalb machen wir folgendes => Wir zerlegen 960 == 30*32 in die eindeutige
  ;   Primfaktorzerlegung: 30*32 = 2*3*5*2^5 = 2^6*3*5. Nun suchen wir die 
  ;   gr��te Ganzzahl, die aus diesen Primfaktoren konstruiert werden kann und
  ;   noch in ein 8-Bit Register passt. Dies ist 240. 960/240=4.
  ;   Also ist 30*32 == 960 == 240*4
  ;
  ;  Als Hilfsrezept: 
  ;   Wir suchen eine Ganzzahl, sodass A*960/A=960 ergibt, wobei A eine kleine
  ;   Ganzzahl ist und 960/A die gr��te Ganzzahl, die durch 8 Bit (<= 255) 
  ;   dargestellt werden kann.
  ;  Durch Ausprobieren von A erhalten wir:
  ;   A=1 => 960/A ist zu gro�
  ;   A=2 => 960/A ist zu gro�
  ;   A=3 => 960/A ist zu gro�
  ;   A=4 => 960/A == 960/4 == 240 und diese Zahl kann durch 8 Bit dargestellt
  ;    werden.   
  ; 
  ;  Wir k�nnen unsere ineinander verschachtelten Schleifen auch durch eine
  ;   Schleife relasieren, in dem wir 240-mal eine Schleife ausf�hren, die
  ;   4-mal den Schleifeninhalt der inneren (verschachtelten) Schleife 
  ;   beinhaltet. 
  ldx #240

  ; Wenn wir hier das A-Register mit einem anderen Wert laden, bspw. 65 == $41,
  ;  dann wird der Bildschirm mit einem anderen Zeichen (n�mlich dem 'A') 
  ;  geleert bzw. bef�llt

  ; Die folgende Schleife l�scht 'Name Table 0' (Adressen: $2000-$23BF)
clear_nt0:
  ; Leerzeichen ist im ASCII-Code 32 == $20. Dies ist zuf�llig der Inhalt des
  ;  Akkumulators, da wir diesen f�r die Positionierung des 'PPU-Speicherzeiger'
  ;  benutzt haben
  ;
  ; 4-mal den Akkumulator-Inhalt nach PPUDATA schreiben. PPUDATA schreibt den
  ;  Inhalt des Akkumulators an die Adresse, die vorher �ber PPUADDR bestimmt
  ;  wurde. Danach wird der 'PPU-Speicherzeiger' auf die n�chste Speicherstelle
  ;  gesetzt.
  ; 
  ; Mit dem Block .REPEAT *** .ENDR sparen wir uns etwas Schreibarbeit
  .REPEAT 4
    sta PPUDATA.W
  .ENDR
  ; Schleifenz�lvariable dekrementieren
  dex 
  ; Wenn Inahlt des X-Register nicht 0 ist wieder nach oben (zum Label 
  ;  'clear_nt0')
  bne clear_nt0
  ; Nun m�ssen wir noch die 'Attribute Table 0' (Adressen $23C0-$23FF) l�schen
  ; 
  ; Die 'Attribute Table' speichert die oberen 2 Bits f�r jeweils eine 4x4 gro�e
  ;  Kachel (zu kompliziert, um es hier kurz zu beschreiben)
  ldx #64 
  lda #0

; Diese Schleife initialisiert die 'Attribute Table 0' mit 0
init_at0:
  ; Schreibe 0 an die aktuelle Adresse im PPU-Speicher
  sta PPUDATA.W 
  ; Dekrementiere den Inhalt des X-Registers
  dex
  ; Wenn Inahlt des X-Register nicht 0 ist wieder nach oben (zum Label 
  ;  'init_at0')
  bne init_at0

  ; Bildschirm wurde vollst�ndig geleert. Verlasse dieses Unterprogramm
  rts 


; Dieses Unterprogramm l�scht den Bildschirm bzw. initialisiert diesen mit 
;  Leerzeichen, bereitet das Schreiben des "Hello World"-Textes vor und schreibt
;  diesen (mithilfe eines Unterprogramms 'printMsg') auf den Bildschirm
draw_helloworld:
  ; Als erstes wollen wir den Bildschirm l�schen bzw. mit Leerzeichen 
  ;  initialisieren
  ;
  ; Springe zum Unterprogramm 'clear_screen'
  jsr clear_screen

  ; Nun m�ssen wir unsere Farbpalette initialisieren. 
  ;  Dazu m�ssen wir die einzelnen Farbwerte (, die jeweils 1 Byte breit sind) 
  ;  nach ($3F00-$3F1F) schreiben. 
  ;  Im Adressraum $3F00-$3F0F liegen die Farben (die Farbpalette) f�r den
  ;  Hintergrund des Bildschirms
  ;  Im Adressraum $3F10-$3F1F liegen die Farben (die Farbpalette) f�r die 
  ;  Sprites (, die vor dem Hintergrund gezeichnet werden)
  ;
  ; Also lassen wir den 'PPU-Speicherzeiger' nach Adresse $3F00 zeigen.
  lda #$3F
  sta PPUADDR.W
  lda #$00
  sta PPUADDR.W

  ; Zus�tzlich initialisieren wir eine Schleifenvariable um 4*8 Bytes zu 
  ;  schreiben, also die einzelnen Farbwerte
  ldx #8
init_palette:
  ; F�r ein "Hello World"-Programm ist eine Monochrome-Palette ausreichend. Mehr 
  ;  noch, wir reduzieren uns hier auf die beiden Farben schwarz und wei�.
  ;
  ; Die Farbwerte f�r diese Farben k�nnen wir einer Farbtafel 
  ;  (Quelle: http://www.games4nintendo.com/nes/faq.php#47) entnehmen:
  ;   Schwarz == $0F (Quelle: http://www.games4nintendo.com/nes/faq.php#48)
  ;   Wei� == $30
  ;
  ; Bei einem Byte (, welches genau eine Farbe definiert) werden Bit 6 und Bit 7
  ;  ignoriert.  
  ;  Insgesamt k�nnen wir somit theoretisch mit den restlichen 6 Bits 
  ;  (Bit 0 - Bit 5) 64 unterschiedliche Farben beschreiben.
  ;
  ; Dies wird jedoch durch eine weitere Tatsache eingeschr�nkt. Jedes 4. Byte im
  ;  Adressraum ($3F00-$3F1F) sollte die Hintergrundfarbe enthalten, damit man
  ;  diese als Pseudo-Transparenz benutzen kann. (Dies ist zu komplex, um es 
  ;  hier in ein paar S�tzen zu beschreiben
  ;
  ; Dies f�hrt dann zu 32-8 == 24 Farben plus einer Hintergrundfarbe, also 
  ;  insgesamt 25 Farben, die gleichzeitig benutzt werden k�nnen

  ; Hintergrund auf schwarz setzen
  lda #$0F
  sta PPUDATA.W

  ; Diese folgenden beiden Farben sind egal, da Sie innerhalb dieses Programms
  ;  nie benutzt werden
  sta PPUDATA.W
  sta PPUDATA.W

  ; Vordergrund-Farbe auf wei� setzen
  lda #$30
  sta PPUDATA.W
  
  ; Dekrementiere den Inhalt des X-Registers
  dex
  ; Wenn Inahlt des X-Register nicht 0 ist wieder nach oben (zum Label 
  ;  'init_palette')
  bne init_palette

  ; Die Farbpalette ist nun initialisiert. Wir k�nnen also mit dem Schreiben
  ;  der Zeichenkette "Hello World" (in den Bildschirmspeicher) beginnen.

  ; Lade das High-Byte der Adresse / des Labels 'helloWorldText' und speichere
  ;  es tempor�r in Adresse $01
  ;
  ; Hinweis: Mit '& $FF00' werden die unteren 8 Bits der 16 Bit-Adresse gel�scht.
  ;  Mit '>> 8' werden die oberen 8 Bits nach rechts verschoben, sodass diese in
  ;  8 Bit bzw. 1 Byte passen 
  lda #((helloWorldText & $FF00) >> 8)
  sta $01.B

  ; Lade das Low-Byte der Adresse / des Labels 'helloWorldText' und speichere es
  ;  tempor�r in Adresse $00
  ;
  ; Hinweis: Mit '& $00FF isolieren wir die unteren 8 Bits aus der 16 
  ;  Bit-Adresse
  lda #(helloWorldText & $00FF)
  sta $00.B

  ; Das erste Zeichen unserer Zeichenkette soll nach Adresse $2082 geschrieben
  ;  werden. Dies ist die 3. Spalte in der 4. Zeile. Dort beginnt unser 
  ;  "Hello World"-Schriftzug.
  ; 
  ; Hinweis: Wenn wir als Startadresse der Zeichenkette $205F w�hlen, steht der
  ;  Buchstabe 'H' in der letzten Spalte der 2. Zeile und der Rest des Strings
  ;  in Zeile 3.
  ;
  ; Hinweis: Wenn wir als Startadresse der Zeichenkette $21AA w�hlen, ist der 
  ;  Text in etwa zentriert (hontizontal, als auch vertikal)
  ;
  ; Wir speichern die Adresse an mithilfe der Speicherstellen an Adresse $02 und
  ;  $03
  lda #$20
  sta $03.B
  lda #$82
  sta $02.B

  ; Springe zum Unterprogramm 'print_hello_world', die unseren Text nun endlich 
  ;  ausgibt
  jsr print_hello_world
 
  ; 'Hello World' steht nun auf dem Bildschirm. Wir k�nnen dieses Unterprogramm
  ;  also verlassen
  rts

; Dieses Unterprogramm gibt unsere Zeichenkette auf dem Bildschirm aus. 
;  Eigentlich ist dieses Unterprogramm generisch, es kann also jede Zeichenkette
;  auf dem Bildschirm darstellen.
;
; Dieses Unterprogramm besitzt die folgenden Parameter:
;   $00  - das Low-Byte der Adresse, wo die darszustellende Zeichenkette 
;           abgelegt ist
;   $01  - das High-Byte der Adresse, wo die darszustellende Zeichenkette 
;           abgelegt ist
;   $02  - das Low-Byte der Bildschirmadresse, wo die darzustellende 
;           Zeichenkette beginnen soll
;   $03  - das High-Byte der Bildschirmadresse, wo die darzustellende 
;           Zeichenkette beginnen soll
print_hello_world:
; Wir erstellen symbolische Namen f�r die einzelnen Teile unserer Adresse
;
; Das Low-Byte der Bildschirmstartadresse
.DEFINE dstLo $02
; Das High-Byte der Bildschirmstartadresse
.DEFINE dstHi $03 
; Das Low-Byte der Adresse, wo die 'Hello World'-Zeichenkette abgelegt ist
.DEFINE src $00 

; Das Hight-Byte der Adresse, wo die 'Hello World'-Zeichenkette abgelegt ist,
;  benutzen wir gleich implizit (ohne dass wir dies extra angeben m�ssen)

  ; Der PPU-Speicher soll auf die gew�nschte Bildschirmstartadresse zeigen
  lda dstHi.B
  sta PPUADDR.W
  lda dstLo.B
  sta PPUADDR.W
  
  ; Z�hlvariable vorbereiten. Diese wird zum Z�hlen bzw. f�r den Adressoffset
  ;  der einzelnen Zeichen benutzt 
  ldy #0
char_loop:
  ; Lade den ASCII-Wert des n�chsten Zeichens. Wir benutzen hier implizit das 
  ;  High-Byte der 'Hello World'-Zeichenkette durch die indirekt-indizierte 
  ;  Adressierung
  lda (src),y

  ; Unsere Zeichenkette muss durch ein Terminierungszeichen 0 bzw. '\0' beendet
  ;  werden
  ;
  ; Wenn wir als letztes die '\0' gelesen haben, springe zu 'done'
  beq done
  
  ; Inkrementiere den Inhalt des Y-Registers, um beim n�chsten 
  ;  Schleifendurchlauf das n�chste Zeichen der Zeichenkette zu lesen
  iny

  ; �berspringe den n�chsten Befehl, wenn das Inkrementieren von Y keine 0 als
  ;  Ergebnis hatte
  bne check

  ; Inkrementiere das High-Byte der 'src'-Adresse der Zeichenkette
  ;
  ; Hinweis: Dies muss nur gemacht werden, wenn unsere Zeichenkette >256 Zeichen
  ;  beinhaltet, also in mehr als einer Seite liegt
  inc src+1

check: 
  ; Ist das aktuelle Zeichen ein Newline-Zeichen ('\n')?
  cmp #10
  ; Wenn ja, dann springe zu 'newline', da wir die neue Zeile von Hand setzen 
  ;  m�ssen
  beq newline

  ; Kein Newline-Zeichen, also k�nnen wir das Zeichen direkt in den Bildschirm
  ;  schreiben
  sta PPUDATA.W 
  ; Auf geht's zum n�chsten Zeichen
  bne char_loop

; Dieser Programmteil �bernimmt 'h�ndisch' die Verarbeitung eines Newline-
;  Zeichens
newline: 
  ; Lade den Wert 32 in den Akkumulator (dies ist die Breite einer 
  ;  Bildschirmzeile)
  lda #32 
  
  ; L�sche das �bertragsbit im P-Register; jetzt wird addiert und wir k�nnen uns
  ;  nicht verlassen, dass das �bertragbit == 0 ist
  clc 
  ; Addiere das Low-Byte der gew�nschten Bildschirmstartadresse zum aktuellen 
  ;  Inhalt des Akkumulators (derzeit 32)
  ; 
  ; Dies ergibt das neue Low-Byte der neuen Bildschirmstartadresse, also 
  ;  speichern wir diese neue Adresse, damit wir uns diese 'merken' k�nnen
  adc dstLo.B
  sta dstLo.B
  ; Akkumulator leeren
  lda #0 
  ; Addiere das High-Byte der gew�nschten Bildschirmstartadresse zum aktuellen 
  ;  Inhalt des Akkumulators (derzeit 0)
  ; 
  ; Dies ergibt das neue High-Byte der neuen Bildschirmstartadresse, also 
  ;  speichern wir diese neue Adresse, damit wir uns diese 'merken' k�nnen
  ;
  ; Hinweis: Es ist wichtig, dass das �bertragsbit hier nicht gel�scht werden 
  ;  darf, da dieses in die Addition mit einbezogen wird. Bei der Berechung des 
  ;  neuen Low-Bytes k�nnen wir eventuell eine Seitengrenze �berschritten haben
  adc dstHi.B
  sta dstHi.B

  ; Lassen wir die PPU auf diese neu berechnete Bildschirmstartadresse zeigen
  ;
  ; Wie immer erst das High-Byte der gew�nschten Adresse
  sta PPUADDR.W
  ; Dann das Low-Byte der gew�nschten Adresse
  lda dstLo.B
  sta PPUADDR.W
  
  ; Wir haben das Newline-Zeichen behandelt, jetzt k�nnen wir uns um das n�chste
  ;  Zeichen k�mmern
  jmp char_loop 
done:
  ; Wie haben die Zeichenkette auf dem Bildschirm dargestellt, nun k�nnen wir
  ;  also dieses Unterprogramm verlassen
  rts 

; CHR-Rom einbinden
.BANK 2 SLOT 4
; Pattern Table f�r Hintergrund
.ORG $0000
.INCBIN "../bin/pattern_table_1.chr"
; Pattern Table f�r Fordergrund (Sprites und Text)
.ORG $1000
.INCBIN "../bin/pattern_table_2.chr"

