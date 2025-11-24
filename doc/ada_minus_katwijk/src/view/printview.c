/*
 * routine om de gegevens van de database af te drukken
 */

#include "libr.h"

/*#define DEBUG*/
#include "DEBUG.h"

short status;
extern char viewname[], *strrchr(), *getlogin(), lib_name[];
char *username;

main(argc, argv)
int argc;
char **argv;
{
	bool status = TRUE;

	if (argc > 1)
	    if (argc == 2)
	    {
		strcpy (viewname, argv[1]);
		username = strrchr (viewname, '.');
		PRINTF ("viewname %s username %s\n", viewname, username);
		if (username == NULL)
		    username = getlogin ();
		else
		    *username++ = 0;
		if (cdb_libname (viewname, username, lib_name) == FALSE)
		{
		    printf ("No library for view: %s.%s\n", viewname, username);
		    exit ();
		}
	    }
	    else
	    {
		fprintf (stderr, "too many arguments\n");
		exit (1);
	    }
	else
	{
	    getlibname (&status);
	    username = getlogin ();
	}

	printf ("Viewname: %s\nuser    : %s\nlibrary : %s\n",
	    viewname, username, lib_name);
}
