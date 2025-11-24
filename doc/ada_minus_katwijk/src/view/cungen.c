/*
 * Routines voor beheer vrije lijst van Compilation Unit Numbers (cun's)
 * Ton Biegstraaten
 * 3-9-86
 */
#include <stdio.h>
#include "libr.h"
#include <pwd.h>
/*#define DEBUG*/
#include "DEBUG.h"
#include "cungen.h"

struct passwd *getpwnam();

char lijst_naam[FNAMESIZE];
unsigned short ccun;	/* current cun */
extern LUN *nlun;

bool locked = FALSE;		/* keeps track of locking and unlocking 
			   avoids double locking */

/*
 * Er zijn ro(o)t mensen, die hun gaven (het root password) misbruiken.
 * Zij worden gedoemd in het verdere leven van dit proces het masker van
 * adacomp te dragen.
 */
void
change_root_to_adacomp ()
{
    struct passwd *p;

/*   if (geteuid () == 0)
	printf ("root changed to adacomp\n");

    if (p = getpwnam ("adacomp"))
	setuid (p -> pw_uid);
    else
	setuid (1);
*/
}

void
lock (status)
int *status;
{
    int try = MAXTRY, fd;

    if (locked == TRUE)
	return;
    change_root_to_adacomp ();
    while (try)
    {
	PRINTF ("Voor creat lock\n");
	if ((fd = creat (LOCK_FILE, 0)) != -1)
	    break;		/* proces locked */
	
	--try;
	sleep (1);
	PRINTF ("file already locked\n");
    }
    if (try == 0)
    {
	printf (" lock not succesfull\n");
	*status = FALSE;
	return;
    }
    locked = TRUE;
    close (fd);
}

void
unlock ()
{
	locked = FALSE;
	unlink (LOCK_FILE);
}

void
maak_lijst (lijstnr, max, start, status)
int lijstnr, max, start, *status;
{
    short lokatie = 1, i;
    FILE *fl;

    if (lijstnr > MAX_FILENR)
    {
	printf ("max cuns reached\n");
	unlock ();
	*status = FALSE;
	return;
    }
    sprintf (lijst_naam, "%s%d", LIJST_DIR, lijstnr);
    if ((fl = fopen (lijst_naam, "w")) == NULL)
    {
	printf ("cannot make cun list: %s \n", lijst_naam);
	unlock ();
	*status = FALSE;
	return;
    }
    chmod (lijst_naam, 0777);
    PRINTF ("maak lijst %s\n", lijst_naam);
    fwrite (&lokatie, sizeof(lokatie), 1, fl);
    for (i = 1; i <= max; ++i)
    {
	lokatie = start + i;
        fwrite (&lokatie, sizeof (lokatie), 1, fl);
    }
    fclose (fl);
}

unsigned short
get_cun (status)
int *status;
{
    short i = 0, max, start, lokatie, numnul = 0;
    FILE *fl;

    /* wees er zeker van dat maar een proces dit uitvoert */
    lock (status);
    if (*status == FALSE)
	return 0;

    while (1)
    {
        max = (i > 1) ? MAXNUM << (i-1) : MAXNUM ;
	start = i ? max : 0;
	sprintf (lijst_naam, "%s%d", LIJST_DIR, i);
	if (access (lijst_naam, 6) == -1 ||
	    (fl = fopen (lijst_naam, "r+")) == NULL)
	{
	    if (max >= ~0 - CUN_OFFSET)
		max -= CUN_OFFSET;
	    maak_lijst (i, max, start);
	    continue;
	}
	fread (&lokatie, sizeof (lokatie), 1, fl);
	PRINTF ("\nv lok %d ", lokatie);
	if (lokatie > max)
	{
	    /* lijst leeg, lees volgende lijst */
	    ++i;
	    fclose (fl);
	    continue;
	}
	break;
    }

    /* zoek lokatie */
    fseek (fl, (long) lokatie * sizeof (lokatie), 0);
    fread (&ccun, sizeof (ccun), 1, fl);
    if (ccun == 0)
    {
	printf ("Incorrect cun %d\n", ccun);
	fclose (fl);
	*status = FALSE;
	return;
    }
    PRINTF ("nr %d ", ccun);

    /* nummer gevonden, maak plaats leeg */
    fseek (fl, (long) lokatie * sizeof (lokatie), 0);
    fwrite (&numnul, sizeof (numnul), 1, fl);	/* leeg locatie */
    fseek (fl, ((long) lokatie + 1) * sizeof (lokatie), 0);

    /* zoek volgende nummer en zet het klaar */
    while (1)
        if (fread (&lokatie, sizeof (lokatie), 1, fl) == 0)
        {
    	    lokatie = max + 1;
            break;
        }
        else if (lokatie != 0)
	{
	    lokatie = ftell (fl) / sizeof (lokatie) - 1;
    	    break;
	}

    PRINTF ("n lok %d\n", lokatie);
    fseek (fl, 0L, 0);
    fwrite (&lokatie, sizeof (lokatie), 1, fl);
    fclose (fl);
    unlock ();

    ccun += CUN_OFFSET;
    init_lun (nlun);
    log_ident (nlun) = ccun;
    PRINTF ("get_cun %d\n", ccun);
    return ccun;
}

/*
 * special_cun, some cuns are compiler generated
 */
short
special_cun (cun)
short cun;
{
    if (cun > CUN_OFFSET)
    {
	printf ("special cun %d too large\n", cun);
/*	*status = FALSE;*/
	return 0;
    }

    ccun = cun;
    init_lun (nlun);
    log_ident (nlun) = cun;
    return cun;
}

void
free_cun (cun, status)
int *status;
short cun;
{
    short i = 0, number, lokatie, offset, lijstnr, start, max;
    FILE *fl;

    PRINTF ("free cun %d\n", cun);

    if (cun <= CUN_OFFSET)
	return;

    cun -= CUN_OFFSET;
    /* wees er zeker van dat maar een proces dit uitvoert */
    lock (status);
    if (*status == FALSE)
    {
	unlock ();
	return;
    }

    PRINTF ("fc %d ", cun);
    for (lijstnr = 0; lijstnr < MAX_FILENR; lijstnr++)
    {
	max = (lijstnr > 1) ? MAXNUM << (lijstnr-1) : MAXNUM;
	start = (lijstnr) ? max : 0;
	if (cun > start + max)
	    continue;
	break;
    }
    PRINTF ("fr start %d lijstnr %d ", start, lijstnr);
    offset = cun - start;		/* bepaal offset binnen lijst */
    if (offset == 0)
    {
	printf ("illegal cun %d\n", cun + CUN_OFFSET);
	unlock ();
	*status = FALSE;
	return;
    }
    sprintf (lijst_naam, "%s%d", LIJST_DIR, lijstnr);
    if ((fl = fopen (lijst_naam, "r+")) == NULL)
    {
        printf ("cun list %s does not exist\n", lijst_naam);
	unlock ();
	*status = FALSE;
	return;
    }
    fseek (fl, 0L, 0);
    fread (&lokatie, sizeof (lokatie), 1, fl);
    PRINTF ("lok %d\n", lokatie);

    /* zoek offset */
    fseek (fl, (long) offset * sizeof (offset), 0);
    fread (&number, sizeof (number), 1, fl);
    if (number)
    {
	printf ("cun %d is already free\n", cun + CUN_OFFSET);
	fclose (fl);
	unlock ();
	*status = FALSE;
	return;
    }

    fseek (fl, (long) offset * sizeof (offset), 0);
    fwrite (&cun, sizeof (cun), 1, fl);

    /* offset wijzigen ? */
    if (offset < lokatie)
    {
        fseek (fl, 0L, 0);
        fwrite (&offset, sizeof (offset), 1, fl);	/* wijzig offset */
    }
    fclose (fl);
    unlock ();
}

/*
 * Interface tussen front, dat meldt dat een compilatie mislukt is
 * en de library manager.
 * Zet de status op FALSE
 */
void
fail (cun, status)
int *status;
short cun;
{
    *status = TRUE;
    free_cun (cun, status);
}

/*
 * gen_cun_adr() gives all cun lists a correct adres for the
 * first free cun
 */

gen_cun_adr (status)
int *status;
{
    short i = 0, max, lokatie;
    FILE *fl;

    /* wees er zeker van dat maar een proces dit uitvoert */
    lock (status);
    if (*status == FALSE)
	return 0;

    while (1)
    {
        max = (i > 1) ? MAXNUM << (i-1) : MAXNUM ;
	sprintf (lijst_naam, "%s%d", LIJST_DIR, i);
	if (access (lijst_naam, 6) == -1 ||
	    (fl = fopen (lijst_naam, "r+")) == NULL)
            break;
	fread (&lokatie, sizeof (lokatie), 1, fl);

        /* zoek eerste vrije nummer en zet het klaar */
        while (1)
            if (fread (&lokatie, sizeof (lokatie), 1, fl) == 0)
            {
    	        lokatie = max + 1;
                break;
            }
            else if (lokatie != 0)
	    {
	        lokatie = ftell (fl) / sizeof (lokatie) - 1;
    	        break;
	    }

        PRINTF ("n lok %d\n", lokatie);
        fseek (fl, 0L, 0);
        fwrite (&lokatie, sizeof (lokatie), 1, fl);
	    PRINTF ("\nv lok %d ", lokatie);
	++i;
	fclose (fl);
    }
    unlock ();

    return;
}

