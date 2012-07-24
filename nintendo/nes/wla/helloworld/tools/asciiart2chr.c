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

		                                          /* �ffne TXT-Datei im Textmodus */
		in_file = fopen(argv[1], "rt");
		                                             /* Datei �ffnen erfolgreich? */
		if(NULL == in_file)
		{
			                 /* NEIN => Benutzer informieren und Programm abbrechen */
		  (void) printf("Datei %s konnte nicht ge�ffnet werden\n", argv[1]);
		  return EXIT_FAILURE;
		}

		                        /* �ffne Ausgabedatei zum Schreiben im Bin�rmodus */
		out_file = fopen(argv[2], "wb");
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

		                        /* Bitmaske zum Speichern der Bits initialisieren */
		  unsigned int bit_mask = 0x80;                     /* 0x80 == %1000 0000 */

			                                    /* Tempor�rer Speicher f�r ein Byte */
			unsigned int tmp_byte = 0x0;

			                                                /* f�r jedes der 8 Bits */
		  for(i = 0; (i < 8) && (readi != EOF); i++)
		  { 
				if('#' == readi)
		    {
					                         /* (7-i). Bit mithilfe der Bitmaske setzen */
		      tmp_byte = tmp_byte | bit_mask;
		    }
		    else if('.' == readi)
		    {
					                                                      /* Nichts tun */
		    }
		    else
		    {
					                      /* Ein Zeichen sollte immer '.' oder '#' sein */
		      (void) printf("Zeichen ungleich '.' oder '#' gefunden: %c \n", readi);
		    }  

				              /* Bitmaske f�r n�chsten Schleifendurchlauf vorbereiten */
		    bit_mask = bit_mask >> 1;

				                  /* N�chstes Zeichen einlesen und '\n's �berspringen */
				do
				{
					readi = fgetc(in_file);
				}
				while(readi == '\n');
		  }

			                                             /* Byte in Datei schreiben */
			(void) fputc(tmp_byte, out_file);
		
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

