/*
 * print contents of cdb
 */

#include <stdio.h>
#include "consts.h"
#include "cdb.h"
/*#define DEBUG*/
#include "DEBUG.h"

main (argc, argv)
int argc;
char *argv[];
{
    FILE *fd;

    if ((fd = fopen (CDB, "r")) == NULL)
	return FALSE;
    
    while (fread (&cdb, sizeof (cdb), 1, fd) != 0)
    {
	if (cdb .c_viewname[0] != '\0')
	    if (argc == 1 || (strcmp (cdb .c_username, argv[1]) == 0))
		printf ("viewname: %s\nusername: %s\nlibname : %s\n\n",
		    cdb .c_viewname, cdb .c_username, cdb .c_libname);
    }
    fclose (fd);
}
