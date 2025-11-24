/*
 * Enter a new entry in the central database for programlibraries
 */

#include <stdio.h>
#include "libr.h"
#include <pwd.h>

struct passwd *getpwuid();
char lib_name[FNAMESIZE];

main (argc, argv)
int argc;
char *argv[];
{
    char *username, *getlogin();
    LIBDESC ld, *ldesc = &ld;
    int status;
    if (argc != 3 || strchr (argv[1], '.'))
    {
	printf ("Usage: newadalib viewname(without .) libraryname\n");
	exit();
    }

    username = getlogin ();
    if (username == NULL)
	username = getpwuid (getuid()) -> pw_name;
    
    if (argv[2][0] != '/')
	strcpy (lib_name, cur_dir ());	/* put current path in libname */
    strcat (lib_name, argv[2]);
    openlib (lib_name, RW, ldesc, &status);
    closelib (ldesc);
    if (status == FALSE)
	printf ("Library %s cannot open\n", lib_name);
    else
    {
	
	printf ("Enter viewname: %s with library: %s for user: %s in database\n",
	  argv[1], lib_name, username);
	cdb_putrec (argv[1], username, lib_name);
    }
}
