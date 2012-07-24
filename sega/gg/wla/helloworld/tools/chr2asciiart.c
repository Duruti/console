/******************************************************************************/
/* 'HEADER'-ABSCHNITT                                                         */
/******************************************************************************/

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]);

/******************************************************************************/
/* IMPLEMENTATION-ABSCHNITT                                                   */
/******************************************************************************/

int main(int argc, char *argv[])
{
	                                      /* Programm ben�tigt 2 Startargumente */
	if(3 == argc)
	{
		                                           /* Zeiger auf zu lesende Datei */
		FILE *in_file = NULL;
		                                       /* Zeiger auf zu schreibende Datei */
		FILE *out_file = NULL;
		                              /* tempor�re Variable zum Lesen eines Bytes */
		unsigned int readi=0;
		                     /* Z�hler, um die Anzahl der einzelnen Bits zu lesen */
		unsigned int bit_counter=0;		

		    /* �ffne CHR-Datei im Bin�rmodus (abschalten von Textkonvertierungen) */
		in_file = fopen(argv[1], "rb");
		                                             /* Datei �ffnen erfolgreich? */
		if(NULL == in_file)
		{
			                 /* NEIN => Benutzer informieren und Programm abbrechen */
		  (void) printf("Datei %s konnte nicht ge�ffnet werden\n", argv[1]);
		  return EXIT_FAILURE;
		}

		                         /* �ffne Ausgabedatei zum Schreiben im Textmodus */
		out_file = fopen(argv[2], "wt");
		                                             /* Datei �ffnen erfolgreich? */
		if(NULL == out_file)
		{
			                 /* NEIN => Benutzer informieren und Programm abbrechen */
		  (void) printf("Datei %s konnte nicht zum Schreiben angelegt werden\n", 
				argv[2]);		  
			return EXIT_FAILURE;
		}

		                                               /* Erstes Zeichen einlesen */
		readi = fgetc(in_file);
		
		                    /* Solange bis wir nicht das Dateiende erreicht haben */
		while(EOF != readi)
		{
			                                     /* interne Z�hl-/Schleifenvariable */
		  int i = 0;

		                      /* Bitmaske zum Analysieren der Bits initialisieren */
		  unsigned int bit_mask = 0x80;                     /* 0x80 == %1000 0000 */

			                                                /* f�r jedes der 8 Bits */
		  for(i = 0; i < 8; i++)
		  { 
				                   /* Extrahiere das (7-i). Bit mithilfe der Bitmaske */
		    unsigned int bit = readi & bit_mask; 
				                 /* Schiebe das extrahierte Bit nun auf die 0. Stelle */
		    bit = bit >> (7-i);

				                   /* Z�hle die Bits intern zur sp�teren Formatierung */
		    bit_counter++;

				                                                         /* Teste Bit */
		    if(0 == bit)
		    {
					      /* Es ist eine 0, die durch ein '.' repr�sentiert werden soll */
		      (void) fputc('.', out_file);
		    }
		    else if(1 == bit)
		    {
					      /* Es ist eine 1, die durch ein '#' repr�sentiert werden soll */
		      (void) fputc('#', out_file);
		    }
		    else
		    {
					                              /* Ein Bit sollte immer 0 oder 1 sein */
		      (void) printf("Bit ungleich 0 oder 1 gefunden: %x \n", bit);
		    }     

				              /* Bitmaske f�r n�chsten Schleifendurchlauf vorbereiten */
		    bit_mask = bit_mask >> 1;
		  }

		                               /* Neue Zeile beginnen nach jeweils 8 Bits */
		  (void) fputc('\n', out_file);

		                            /* Eine Zeile Abstand nach 8 Bytes == 64 Bits */
		  if(0 == bit_counter % 64)
		  {
		    (void) fputc('\n', out_file);
		  }

			                              /* Lese das n�chste Zeichen aus der Datei */
		  readi = fgetc(in_file);		
		}

		                                       /* Schlie�e die ge�ffneten Dateien */
		fclose(in_file);
		fclose(out_file);
	}
	else
	{
			   /* Zeige dem Benutzer, welche Startargumente �bergeben werden m�ssen */
		(void) printf("USAGE: %s INFILE OUTFILE\n", argv[0]);
	}  

  return EXIT_SUCCESS;  
}

