/*
 * Remove an entry in the central database for programlibraries
 */

#include <stdio.h>
#include "libr.h"
#include <pwd.h>

struct passwd *getpwuid();

main (argc, argv)
int argc;
char *argv[];
{
    char *username, *getlogin();
    LIBDESC ld, *ldesc = &ld;
    int status;
    if (argc != 2 || strchr (argv[1], '.'))
    {
	printf ("Usage: rmadalib viewname(without .)\n");
	exit();
    }

    username = getlogin ();
    if (username == NULL)
	username = getpwuid (getuid()) -> pw_name;
    
    printf ("Remove viewname: %s for user: %s in database\n",
	  argv[1], username);
    cdb_rmlib (argv[1], username);
}
