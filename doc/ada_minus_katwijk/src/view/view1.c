/*
 * Procedure voor het halen van de treename van een unit
 * Ton Biegstraaten
 */
#include <stdio.h>
#include <pwd.h>
/*#define DEBUG
/**/
#include "DEBUG.h"

/* SPEC and XBODY should equal the consts in the compiler */
#define SPEC 01
#define XBODY 02
/*
#include "unix.h"
#ifndef FRONT
#include "rt_defs.h"
#endif
#include "tree.h"
#undef kind_of
#define DDB_TREE
*/
#include "libr.h"

typedef int boolean;

#define DEF_VIEW	"adaview"
#define DEF_LIBNAME	"adalibrary"
/* number of characters used from unit_name */
#define U_LENGTH	7

long time();

extern short ccun;
extern LUN *lun;
LIBDESC libdesc, *ldesc = &libdesc;
LUN newlun, *nlun = &newlun;
char viewname[UNAMESIZE] = "";
char lib_name[FNAMESIZE] = "";
char prefix[FNAMESIZE] = "";
char dir_path[FNAMESIZE] = "";
char file_name[FNAMESIZE] ;

LUN alun, blun, *lun = &alun, *xlun = &blun;

struct passwd *getpwuid();
/*
 * Search the name of an existing tree file
 */
char *
f_name (unit_name, kind, status)
char *unit_name;
int kind;
boolean *status;
{

    PRINTF ("Vind van unit %s de treename\n", unit_name);
    get_libdesc (ldesc, status);
    if (*status == FALSE)
	return NULL;
    PRINTF ("get_libdesc goed:name %s, uname %s\n", ldesc -> _libname, unit_name);

    get_lun (ldesc, unit_name, lun, status);
    if (*status == FALSE)
	PRINTF ("get_lun status false\n");
    if (is_spec (lun) && kind == XBODY)
	*status = get_body (lun, lun);
    if (*status == FALSE)
    {
	PRINTF ("get_body fout\n");
	return NULL;
    }
    PRINTF ("get_lun is goed\n");

    if (kind == SPEC && is_spec (lun) || kind == XBODY && is_body (lun))
    {
	/* voeg wanneer nodig lun toe aan de context van nlun */
        if (add_context (lun, nlun))
	    t_init_complist (ldesc, lun, status);
	    /*PRINTF ("No context check\n");*/
	PRINTF ("treename %s status %d\n", tree_name (lun), *status);
	/* tree file should exist to be valid */
	if (readable (tree_name (lun)))
	    return tree_name (lun);
    }
    
    *status = FALSE;
    PRINTF ("blijkbaar geen kloppend soort, vraag %d is %d\n", kind, kind_of (lun));
    PRINTF ("Of treename : %s onleesbaar\n", tree_name (lun));
    return NULL;
}

/*
 * del_lun remove the lun from the library
 */
del_lun (unit_name, status)
char *unit_name;
boolean *status;
{
    LUN alun, *lun = &alun;

    PRINTF ("Delete unit %s\n", unit_name);
    get_libdesc (ldesc, status);
    if (*status == FALSE)
	return ;
    PRINTF ("get_libdesc goed:name %s, uname %s\n", ldesc -> _libname, unit_name);

    get_lun (ldesc, unit_name, lun, status);
    if (*status == FALSE)
	return ;
    PRINTF ("get_lun is goed\n");
    free_lun (lun, status);
    log_ident (lun) = 0;
    name_of (lun) [0] = 0;
    source_name (lun) [0] = 0;

	unlink (tree_name (lun));
    tree_name (lun) [0] = 0;

    unlink (object_name (lun));
    object_name (lun) [0] = 0;

    if (exec_name (lun) [0] != 0) {
       exec_name (lun) [0] = 0;
    }
    secondaries (lun) [0] = 0;
    set_free (lun);
    wcount (lun) = 0;
    put_lun (ldesc, lun, status);
}

add_context (l1,l2)
LUN *l1, *l2;
{
    /* voeg toe aan  context lijst,geef FALSE terug, wanneer al aanwezig,
       direct of indirect */
    
    return TRUE;
}

/*
 * Generate names for tree, assembler and object output files
 */

/*
 * Generate a path prefix for the output files
 * possibilities are:
 * -no prefix (current directory)
 * -directory of source file
 * -directory of library
 * -user specified directory
 *
 * The current environment allows only one choice, because a user profile
 * can not be specified yet.
 * The directory of the library is used as path prefix.
 */

char *
cur_dir ()
{
    char *p;
    FILE *pf, *popen ();

    if (dir_path[0] == 0)
    {
	pf = popen ("pwd", "r");
	if (pf == NULL)
	{
	    fprintf (stderr, "cannot find current directory, fatal\n");
	    return NULL;
        }
	fread (dir_path, sizeof (*dir_path), FNAMESIZE, pf);
	p = &dir_path[0];
	while (*p != '\0' && *p != '\n')
	    p++;
	if (*p == '\n')
	    *p = '\0';
	pclose (pf);
	strcat (dir_path, "/");
    }

    return dir_path;
}

char *
path_prefix ()
{
    char *p, *q, *r, *strrchr();

    if (prefix[0] != 0)
	return &prefix[0];
    getlibname ();
    p = strrchr (lib_name, '/');
    if (p == NULL)
    {
	printf ("Illegal library name %s, assume current dir\n", lib_name);
	strcpy (prefix, cur_dir ());
    }
    else
    {
	q = &lib_name[0];
	r = &prefix[0];
	while (q <= p)
	    *r++ = *q++;
	*r = '\0';
    }
    return &prefix[0];
}

char*
a_name (unit_name, status)
char *unit_name;
int *status;
{
    path_prefix ();
    strcpy (file_name, prefix);
    strncat (file_name, ASDIR, 14);
    strcat (file_name, "/");
    strncat (file_name, unit_name, U_LENGTH);
    sprintf (file_name, "%s%05d.s", file_name, ccun);
    return &file_name[0];
}

char*
t_name (unit_name, status)
char *unit_name;
int *status;
{
    path_prefix ();
    strcpy (tree_name (nlun), prefix);
    strncat (tree_name (nlun), TREEDIR, 14);
    strcat (tree_name (nlun), "/");
    strncat (tree_name (nlun), unit_name, U_LENGTH);
    sprintf (tree_name (nlun), "%s%05d.t", tree_name (nlun), ccun);
    PRINTF ("Tree name %s\n", tree_name (nlun));
    return tree_name (nlun);
}

char*
o_name (unit_name, status)
char *unit_name;
int *status;
{
    path_prefix ();
    strcpy (object_name (nlun), prefix);
    strncat (object_name (nlun), OBJDIR, 14);
    strcat (object_name (nlun), "/");
    strncat (object_name (nlun), unit_name, U_LENGTH);
    sprintf (object_name (nlun), "%s%05d.o", object_name (nlun), ccun);
    PRINTF ("Object name %s\n", object_name (nlun));
    return object_name (nlun);
}

char*
c_name (unit_name, status)
char *unit_name;
int *status;
{
    path_prefix ();
    strcpy (object_name (nlun), prefix);
    strncat (object_name (nlun), OBJDIR, 14);
    strcat (object_name (nlun), "/");
    strncat (object_name (nlun), unit_name, U_LENGTH);
    sprintf (object_name (nlun), "%s%05d.c", object_name (nlun), ccun);
    PRINTF ("Object name %s\n", object_name (nlun));
    return object_name (nlun);
}

get_libdesc (ldesc, status)
LIBDESC *ldesc;
boolean *status;
{
    getlibname (status);
    if (*status == FALSE)
	return;

    openlib (lib_name, RW, ldesc, status);
    closelib (ldesc);
}

getlibname (status)
boolean *status;
{
    char *p, *getenv (), *usernm, *getlogin ();

    /* should be visited once each compilation */
    if (lib_name[0] != '\0')
	return;
    if (viewname[0] == '\0')
        if ((p = getenv ("ADAVIEW")) == NULL)
	    strncpy (viewname, DEF_VIEW, UNAMESIZE);
        else
	    strncpy (viewname, p, UNAMESIZE);
    /* find library name for view/user combination */
    PRINTF ("viewname %s\n", viewname);
    /* viewname could be name or name.username */
    if ((p = strrchr (viewname, '.')) != NULL)
    {
	*p = 0;
	usernm = ++p;
    }
    else
	usernm = getlogin ();
    if (usernm == NULL)
	usernm = getpwuid (getuid()) -> pw_name;
    PRINTF ("username %s\n", usernm);

    if (cdb_libname (viewname, usernm, lib_name) == FALSE)
    {
	/* assume only for default case default values and introduce them in
	   the central database */
	if (strcmp (viewname, DEF_VIEW) == 0)
	{
	    PRINTF ("default initialisation\n");
	    strncpy (lib_name, cur_dir (), FNAMESIZE);
	    strncat (lib_name, DEF_LIBNAME, FNAMESIZE);
	    /*sleep (1);*/
	    cdb_putrec (DEF_VIEW, usernm, lib_name);
	}
	else
	{
	    *status = FALSE;
	    return;
	}
    }
    PRINTF ("libname %s\n", lib_name);

}

t_init_complist (ldesc, lun, status)
LIBDESC *ldesc;
LUN *lun;
boolean *status;
{
    LUN tlun, *tl = &tlun;
    if (log_ident (lun) == 2) 
	return;
    init_lun (tl);
    tl -> real_lun ._csv[tl -> real_lun ._csc++] = phy_ident (lun);
    PRINTF ("complist of %s\n", name_of (lun));
    init_complist (ldesc, tl, status);
    return;
}

