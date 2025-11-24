/*
 * Interface tussen o.a. debugger en dapse voor functies
 * welke niet door de dapse geleverd worden,maar welke
 * wel gebruik maken van de interne strutuur van de dapse
 *
 *  dutinfd!abi   (7-3-85)
 */

#include "libr.h"

#define F_UNAME_SIZE 100

/*
 * geef de volledige unit naam terug van een lun
 */
char *full_unit_name(lun, status)
LUN *lun;
bool *status;
{
	char name[100];
	name[0] = '\0';
	_f_name (lun, name, status);
	return name;
}

_f_name (lun , name, status)
LUN *lun;
char *name;
bool *status;
{
	LUN parent;
	get_parent (currentfile (lun), lun, &parent, status);
	if ( *status == TRUE)
		_f_name (&parent, name, status);
	if (name[0] != '\0')
		strcat (name, ".");
	strcat (name, name_of (lun));
}

/*
 * Loop vanaf een gegeven library alle luns recursief door(ook subunits)
 * en voer per lun een functie uit welke als argument meegegeven wordt
 * met als parameters: de lun   , de prefix van de unit naam(alle parents)
 *                     een pointer naar een gebied door de aanroeper meegegeven
 *		       een pointer naar de status.
 * Wanneer de functie TRUE teruggeeft wordt het zoeken gestaakt,bij FALSE
 * gaat het zoeken door.
 */
rec_list (libname, user_sub, pointer, status)
char *libname, *pointer;
bool (*user_sub)();
bool *status;
{
	LUN lun;
	char prefix[F_UNAME_SIZE];
	prefix[0] = '\0';
	return _rec_list (libname, user_sub, pointer, prefix, &lun, status);
}

/*
 * _rec_list doet het werk voor rec_list
 */
_rec_list (libname, user_sub, pointer, prefix, lun, status)
char *libname, *pointer, *prefix;
bool (*user_sub)();
LUN *lun;
bool *status;
{
	char *naamp;
	int fp;
	int lunnr;

	naamp = prefix;
	while (*naamp++);
	--naamp;
	if ((fp = open (libname, R)) == -1)
	{
	   fprintf (stderr, "file: %s niet open\n", libname);
	   return FALSE;
	}
	lunnr = 1 /*FIRST_LUN*/;
	while (1)
	{
		if (!read_oclun (fp, lunnr, lun))
		{
		   close (fp);
		   return FALSE;
		}
		set_currentfile (lun, libname);
		lunnr++;
		if (user_sub (lun, prefix, pointer, status) == TRUE)
		{
		    close (fp);
	            return TRUE;
		}
		if (has_secondaries (lun))
		{
			if (prefix[0] != '\0')
			   strcat (prefix, ".");
			strcat (prefix, name_of (lun));
		        if (_rec_list (secondaries (lun), user_sub, pointer, prefix, lun, status) == TRUE)
			{
			    close (fp);
			    return TRUE;
			}
			*naamp = '\0';
		}
	}
}

