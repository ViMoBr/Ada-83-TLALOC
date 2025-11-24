/*
 * view3 implements procedures for managing the central database
 * for administrating program libraries.
 * It contains routines for updating the database and for retrieving data.
 * In the future it should include routines to check the consistency
 * of the whole ADA system
 */

#include <stdio.h>
#include "libr.h"
#include "cdb.h"

/*#define DEBUG*/
#include "DEBUG.h"
extern char viewname[], lib_name[];
/*
 * cdb_libname retrieves the library name given the view and username
 */

bool
cdb_libname (viewname, username, libname)
char *viewname, *username, *libname;
{
    FILE *fd;

    PRINTF ("view %s user %s\n", viewname, username);
    if ((fd = fopen (CDB, "r")) == NULL)
	return FALSE;
    
    while (fread (&cdb, sizeof (cdb), 1, fd) != 0)
    {
	if (strcmp (cdb .c_viewname, viewname) ||
	  strcmp (cdb .c_username, username))
	{
	    PRINTF ("Not equal to %s.%s\n",  cdb .c_viewname ,cdb .c_username);
	    continue;
	}
	strcpy (libname, cdb .c_libname);
	PRINTF ("Equal to %s.%s library %s\n",  cdb .c_viewname ,cdb .c_username, cdb .c_libname);
	fclose (fd);
	return TRUE;
    }
    fclose (fd);
    return FALSE;
}
	
/*
 * cdb_putrec inserts a new view/user/library record in the database
 */

cdb_putrec (viewname, username, libname)
char *viewname, *username, *libname;
{
    FILE *fd;
    bool status = TRUE;
    short reccnt, emptyrec = 0;	/* teller voor database records */

    lock (&status);
    if (status == FALSE)
    {
	printf ("view: %s user: %s library: %s not inserted\n",
	    viewname, username, libname);
	unlock ();
	return FALSE;
    }

    /* check if entry is really new */

    reccnt = emptyrec = -1;

    if ((fd = fopen (CDB, "r")) != NULL)
    {
	while (fread (&cdb, sizeof (cdb), 1, fd) != 0)
	{
	    reccnt++;
	    if (cdb .c_viewname[0] == 0)
	    {
		if (emptyrec == -1)
		    emptyrec = reccnt;
		continue;
	    }
	    if (strcmp (cdb .c_viewname, viewname) ||
	      strcmp (cdb .c_username, username))
	    {
		PRINTF ("Not equal to %s.%s\n",  cdb .c_viewname ,cdb .c_username);
		continue;
	    }
	    strcpy (libname, cdb .c_libname);
	    PRINTF ("Equal to %s.%s library %s\n",  cdb .c_viewname ,cdb .c_username, cdb .c_libname);
	    printf ("%s.%s already in database\n", viewname, username);
	    fclose (fd);
	    unlock ();
	    return FALSE;
	}
	fclose (fd);
    }

    /* "a" does not work on this machine so work around */
    if ((fd = fopen (CDB, "r+")) == NULL)
    {
	/* not r+ ? assume it does not exist */
	if ((fd = fopen (CDB, "w")) == NULL)
	{
	    printf ("Cannot write database\n");
	    unlock ();
	    return FALSE;
	}
    }

    if (emptyrec == -1) emptyrec = reccnt+1;
    PRINTF ("Emptyrec is %d offset %d\n", emptyrec, emptyrec * sizeof (cdb));
    fseek (fd, (long) (emptyrec * sizeof (cdb)), 0);
    strncpy (&cdb .c_viewname[0], viewname, UNAMESIZE);
    strncpy (&cdb .c_username[0], username, UNAMESIZE);
    strncpy (&cdb .c_libname[0], libname, FNAMESIZE);

    if (fwrite (&cdb, sizeof (cdb), 1, fd) != 1)
	printf ("Cannot write database\n");
    
    unlock ();
    fclose (fd);

}

/*
 * cdb_rmlib removes a library
 */
cdb_rmlib (viewname, username)
char *viewname, *username;
{
    FILE *fd;
    bool status = TRUE;
    short reccnt;	/* teller voor database records */

    lock (&status);
    if (status == FALSE)
    {
	printf ("view: %s user: %s not deleted\n",
	    viewname, username);
	unlock ();
	return FALSE;
    }

    /* find entry*/
    if ((fd = fopen (CDB, "r")) != NULL)
    {
	reccnt = -1;
	while (fread (&cdb, sizeof (cdb), 1, fd) != 0)
	{
	    reccnt++;
	    if (cdb .c_viewname[0] == 0)
		continue;
	    if (strcmp (cdb .c_viewname, viewname) ||
	      strcmp (cdb .c_username, username))
	    {
		PRINTF ("Not equal to %s.%s\n",  cdb .c_viewname ,cdb .c_username);
		continue;
	    }
	    PRINTF ("Equal to %s.%s library %s\n",
		cdb .c_viewname ,cdb .c_username, cdb .c_libname);

	    /* remove library itself */
	    rm_proglib (cdb .c_libname, &status);
	    if (status == TRUE)
	    {
                char dir_name[FNAMESIZE], *pd;

                strcpy (lib_name, cdb .c_libname);
		unlink (cdb .c_libname);
                /* remove ass obj and tree dirs */
                strcpy (dir_name, "rmdir ");
                
                strcat (dir_name, path_prefix ());
                pd = &dir_name[0];
                while (*pd++ != '\0');
                pd--;
                strcpy (pd, ASDIR);
                system (dir_name);
                strcpy (pd, OBJDIR);
                system (dir_name);
                strcpy (pd, TREEDIR);
                system (dir_name);
            }
            else
            {
                printf ("library not removed\n");
                unlock ();
                return FALSE;
            }
            if ((fd = fopen (CDB, "r+")) == NULL)
            {
                printf ("Cannot write database\n");
                unlock ();
                return FALSE;
            }

            PRINTF ("reccnt voor seek is %d\n", reccnt);
            PRINTF ("fseek %d\n", fseek (fd, (long) (reccnt * sizeof (cdb)), 0));
            PRINTF ("ftell %d\n", ftell (fd));
            cdb .c_viewname[0] = 0;
            cdb .c_username[0] = 0;
            cdb .c_libname[0] = 0;

            if (fwrite (&cdb, sizeof (cdb), 1, fd) != 1)
                printf ("Cannot write database\n");
        
            unlock ();
            return TRUE;
        }
        fclose (fd);
    }
    unlock ();
    printf ("%s.%s not found\n", viewname, username);
    return FALSE;
}

/*
 * set_pl_name makes it possible to specify the name of the program library
 * other than by default
 */
set_pl_name (pl_name)
char *pl_name;
{
    strncpy (viewname, pl_name, UNAMESIZE);
}
