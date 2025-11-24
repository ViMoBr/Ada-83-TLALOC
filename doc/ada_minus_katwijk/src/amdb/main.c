#

/*
 *	include files
 */

#include "debug.h"
#include "context.h"
#include <signal.h>
#include <sgtty.h>

/*
 *	scalars
 */

short	main_lun = -1;
int	intflg;
bool	status;
char naam[UNAMESIZ];

/*
 *	structures
 */

LIBDESC		libstore;
LIBDESC		*library = &libstore;
LUN		x;

BODY_P first_body(), next_body();

char *daslib = DASLIB;
char *b_standard = B_STANDARD;
char *dasexit = DASEXIT;

char *body_name();

/*
 *	interrupt routine to stop a running program
 */

interrupt()
{
	intflg = TRUE;
	signal(SIGINT,interrupt);
}

/*
 * dfl_signals() dummy routine voor libman.a
 */
dfl_signals()
{
}

char master[FNAMESIZE], deb_unit[FNAMESIZE];
main(argc,argv)
int argc;
char **argv;
{
	char *debugunit, *pmaster;

	setbuf (stderr, NULL);
	strcpy (master, ".master");
	debugunit = deb_unit;
	if (params (argc, argv, &pmaster, &debugunit) == 0)
	   goto usage;
	openlib ( master, R, library, &status);
	if (status == FALSE)
	{
		fprintf(stderr,"cannot open library %s\n",argv[1]);
		exit(0);
	}
	gettty();
	signal(SIGINT,interrupt);
	db_program (debugunit);
	go();
	exit (0);
	usage:
		fprintf(stderr,"Usage : amdb [-p library] [debugunit]\n");
		exit(0);
}

params (argc, argv, master, debugunit)
int argc;
char **argv;
char **master, **debugunit;
{
	**debugunit = 0;
	if (argc == 1)
	   return 1;
	if (argc == 2)
	{
	   *debugunit = argv[1];
	   return 1;
	}
	if (argc == 3)
	   if (equal (argv[1], "-m"))
	   {
	      *master = argv[2];
	      return 1;
	   }
	if (argc == 4)
	   if (equal (argv[1], "-m"))
	   {
	      *master = argv[2];
	      *debugunit = argv[3];
	      return 1;
	   }
	   if (equal (argv[2], "-m"))
	   {
	      *master = argv[3];
	      *debugunit = argv[1];
	      return 1;
	   }
	return 0;
}
/*
 *	eq_list is a subroutine parameter for rec_list to be able
 *	to find the unitname when the sourcename is known;
 */
eq_list (lun, prefix, pointer, status)
char *prefix, **pointer;
LUN *lun;
bool *status;
{
	if (equal (source_name (lun), *pointer))
	{
	   *pointer = name_of (lun);
	   return TRUE;
	}
	return FALSE;
}

/*
 *	program command
 */

db_program (debugunit)
char *debugunit;
{
	char *unit_name;
	kill();
	for (;;)
	{
	    if (*debugunit == 0)
	    {
	        cls ();
		ccommand("program");
		prompt("enter unit (e for exit)");
		unit_name=inline();
		if (! *unit_name)
			continue;
		if (equal (unit_name, "e"))
		   exit (0);
	    }
	    else
	    {
	       unit_name = debugunit;
	       /*
		* check if suffix is .ada if not append it
		*/
	       if (strcmp (".ada", rindex (unit_name, '.')) != 0)
		   strcat (unit_name, ".ada");
	       if (rec_list (library, eq_list, &unit_name, &status) == FALSE)
	       {
		  sysdb_error ("name : %s not found", unit_name);
		  *debugunit = 0;
		  continue;
	       }
	    }
	    strcpy (naam, unit_name);
	    unit_name = naam;
	    status = TRUE;
	    get_lun (library, unit_name, &x, &status);
	    if (status == FALSE)
	    {
	       sysdb_error("unit %s not in library",unit_name);
	       *debugunit = 0;
	       continue;
	    }
	    if (!is_loaded ( (&x))) {
		    sysdb_error("unit %s not loaded",unit_name);
		    *debugunit = 0;
		    continue;
	    }

	    cls();
	    message("moment please"," fetching");
	    if (initialise(&x)) {
		    main_lun = 1;
		    for (st_current = first_body(&bodylist); st_current; st_current = next_body (st_current))
		    {
		        if (equal (unit_name, body_name (st_current)))
		           break;
		    }
		    proglun = &x;
		    return;
	    }
	    else {
		    main_lun = -1;
		    sysdb_error("loading not succeeded");
		    *debugunit = 0;
	    }
	}
}
