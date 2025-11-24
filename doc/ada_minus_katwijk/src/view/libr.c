#include "libr.h"
#include <signal.h>
#include <ctype.h>

/*#define DEBUG*/
#include "DEBUG.h"

bool get_plun (), read_oclun (), write_oclun (), master_header ();

#define ENDOFFILE 2
#define file_exists(x)	(!access(x, AABLE))

openlib (filename, mode, ldesc, status)
char	*filename;
int	mode;
LIBDESC	*ldesc;
bool	*status;
{
	set_libraryname (ldesc, filename);
	ldesc-> _mode = mode;

	if (!file_exists (filename))
	{
	    char dir_name[FNAMESIZE], *pd;
	   createmaster (".header", filename, "null");
	   /* make ass obj and tree dirs */
	   strcpy (dir_name, "mkdir ");
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
	   init_standard (filename);
	}

	master_fp (ldesc) = open (filename, mode);

	if (master_fp (ldesc) == -1)
	{  
	   PRINTF ("openlib : %s not open\n", filename);
	   *status = FALSE;
	   return;
	}
	PRINTF ("Openlib fd %d\n", master_fp (ldesc));

/*
	if (mode == RW) chmod (filename, LOCK);
 */
	*status = TRUE;
}


closelib (ldesc)
LIBDESC *ldesc;
{
	PRINTF ("Close van %d\n", master_fp(ldesc));
	close (master_fp(ldesc));
/*
	if (ldesc-> _mode == RW) chmod (library_name (ldesc), UNLCK);
	signal (SIGINT, SIG_DFL);
 */
}

get_lun (libdesc, name, lun, status)
LIBDESC *libdesc;
char	*name;
LUN	*lun;
bool	*status;
{
	LUN t;
	LUN *temp = &t;

        uppercase (name);
	getf_lun (library_name (libdesc), name, temp, status);
	if (!*status) return;

	if (!get_plun (currentfile (temp), phy_ident (temp), lun))
	{   *status = FALSE;
	    return;
	}
	PRINTF ("getlun geeft terug %s\n", name_of (lun));
}

alloclun (libdesc, parent, name, lun, status)
LIBDESC *libdesc;
char	*parent;
char	*name;
LUN	*lun;
bool	*status;
{
	LUN p;
	LUN *pa= &p;

	if (*parent)
	{
	   get_lun (libdesc, parent, pa, status);
	   if (!*status) return;
	   if (is_spec (pa) && strcmp (name_of (pa), name) != 0)
	       /* blijkbaar wordt de body niet gealloceerd, maar een subunit
		  dus nem de body ipv de spec 
		*/
	       *status = get_body (pa, pa);
	   if (!*status) return;
	   ll_alloc (secondaries (pa), name, pa, lun, status);
	}
	else
	{
	   ll_alloc (library_name (libdesc), name, pa, lun, status);
	}
}

put_lun (ldesc, lun, status)
LIBDESC *ldesc;
LUN	*lun;
bool	*status;
{
	int fp;


	if ((fp = open (currentfile (lun), W)) == -1)
	{   
	    PRINTF ("put_lun : %s not open\n", currentfile (lun));
	    *status = FALSE;
	    return;
	}

	if (!write_oclun (fp, lun))
	{
	   *status = FALSE;
	   close (fp);
	   return;
	}
	*status = TRUE;
	close (fp);
}

set_compiled(libdesc, lun)
LIBDESC *libdesc;
LUN *lun;
{
	set_occupied (lun);
	lun-> real_lun. _flags |= COMPILED;

	PRINTF ("set compiled\n");
	if (is_subunit (lun))
	{
	    ins_arcv (lun);
	    PRINTF ("archive gemaakt\n");
	}
}

set_invalid (lun)
LUN *lun;
{
	set_free (lun);
}

get_parent (lib, lun, parent, status)
LIBDESC *lib;
LUN *lun, *parent;
bool *status;
{
	LUN h;
	LUN *headlun = &h;

	if (!master_header (currentfile (lun), headlun))
	{   
	    PRINTF ("get_parent : master_header false\n");
	    *status = FALSE;
	    return;
	}

	getf_lun (parentmaster (headlun), name_of (headlun), parent, status);
}

getf_lun (filename, tname, lun, status)
char	*filename;
char	*tname;
LUN	*lun;
bool	*status;
{
	char *name;
	char buf [UNAMESIZE];
	char *bufp = buf;
	LUN bodylun;
	int i;
	name = tname;	/* don't change tname */
	for (i = 0; i < UNAMESIZE; i ++) {
	   if (*name == '.' || *name == 0)
	      break;
	   *bufp++  = *name++;
	}
	*bufp = 0;

	ll_get (filename, buf, lun, status);
	if (*status == FALSE)
	{
	    PRINTF ("getf_lun : llget van %s fout, file %s\n", filename, buf);
	    return;
	}

	if (*name++ == '.')
	{
	    /* recursief zoeken gaat tegenwoordig via de body,zoals het hoort 
	       het aanroepen van alloclun,get_lun, getf_lun met dubbele namen
	       voor de body van een spec geeft nu problemen
	       Het zoeken van een body kan nu niet meer direct.
	       Haal eerst de spec en dan zelf de body door te testen of
	       er een body gewenst is.
	       Feitelijk moet de kind bij het zoeken worden meegegeven.
	       */
	    if (is_spec (lun))
	    {
		if (strcmp (name, buf) == 0)	/* unit is body */
		    *status = get_body (lun, lun);
		else
		{
		    *status = get_body (lun, lun);
		    getf_lun (secondaries (lun), name, lun, status);
		}
	    }
	}
}

ll_get (filename, name, lun, status)
char *filename;
char *name;
LUN *lun;
bool *status;
{
	int fp;
	LUN t;
	LUN *temp = &t;
	int recno = 1;


	if ((fp = open (filename, R)) == -1)
	{  
	   PRINTF ("ll_get : %s not open\n", filename);
	   *status = FALSE;
	   return;
	}

	while (1)
	{
	   if (!read_oclun (fp, recno, temp))
	   {  *status = FALSE;
	      break;
	   }
PRINTF ("In ll_get, looking for %s, finding %s\n", name, name_of (temp));
	   if (!strcmp (name_of (temp), name))
	   {  *status = TRUE;
	      set_currentfile (lun, filename);
	      read_oclun (fp, recno, lun);
	      break;
	   }
	   recno ++;
	}

	close (fp);
}

ll_alloc (filename, name, plun, lun, status)
char  *filename;
char *name;
LUN  *plun;
LUN  *lun;
int  *status;
{
	LUN t;
	LUN *temp = &t;
	int fp;
	int recno = 1;

	if (!file_exists (filename))
	    createmaster (name_of (plun), filename, currentfile (plun));

	if ((fp = open (filename, W)) == -1)
	{  
	   PRINTF ("ll_alloc : %s not open\n", filename);
	   *status = FALSE;
	   return;
	}

	while (1)
	{
	   if (!read_oclun (fp, recno, temp))
	   { int offset;

	     offset = lseek (fp, 0L, ENDOFFILE);
	     phy_ident (lun) = offset / OCLSIZE;
	     break;;
	   }
   
	   if (is_free (lun))
	   { phy_ident (lun) = phy_ident (temp);
	     break;;
	   }
	   recno ++;
	}

	set_currentfile (lun, filename);
	close (fp);
	*status = TRUE;
}

bool
get_plun (filename, lunnumber, lun)
char *filename;
lunno lunnumber;
LUN *lun;
{
	int fp;


	if ((fp = open (filename, R)) == -1)
	{
	    PRINTF ("get_plun : %s not open\n", filename);
	    return FALSE;
	}

	if (!read_oclun (fp, lunnumber, lun))
	{   
	    close (fp);
	    PRINTF ("read oclun fout in get_plun\n");
	    return FALSE;
	}

	set_currentfile (lun, filename);
	close (fp);
	return TRUE;
}

bool
read_oclun (stream, lunnumber, lun)
int	stream;
lunno	lunnumber;
LUN	*lun;
{
	int	rn;

	PRINTF ("Request to read from stream %d lun %d %d bytes\n", stream, lunnumber, OCLSIZE);

	if (lseek (stream, (long) (lunnumber * OCLSIZE), 0) == -1)
	{
	    PRINTF ("read_oclun : lseek fout\n");
	    return FALSE;
	}
	if ((rn = read (stream, lun, OCLSIZE)) != OCLSIZE)
	{
	    PRINTF ("read_oclun %d bytes few\n", OCLSIZE - rn);
	    return FALSE;
	}

	return TRUE;
}

bool
write_oclun (stream, lun)
int	stream;
LUN	*lun;
{
	if (lseek (stream, (long) (phy_ident (lun) * OCLSIZE), 0) == -1)
	{
	    PRINTF ("write_oclun : lseek fout\n");
	    return FALSE;
	}
	/*
	 * convert to a uniform case eg uppercase
	 */
	uppercase (lun -> real_lun ._unit_name);
	if (write (stream, lun, OCLSIZE) != OCLSIZE)
	{
	    PRINTF ("write_oclun : write fout\n");
	    return FALSE;
	}

	return TRUE;
}

set_lunno (lun, filename)
LUN *lun;
char *filename;
{
	/*
	log_ident (lun) = (ino_of (filename) & LUNMASK);
	if (log_ident (lun) < LOW_LUN) log_ident (lun) += LOW_LUN;
	*/
	printf ("Illegal call set_lunno\n");
}

set_stamps (lun)
LUN *lun;
{
	time (&(source_stamp (lun)));
	time (&(tree_stamp (lun)));
	time (&(object_stamp (lun)));
	time (&(exec_stamp (lun)));
	time (&(secs_stamp (lun)));
}

set_fnames (lun, filename, treedir, outfile)
LUN *lun;
char *filename;
char *treedir;
char *outfile;
{
	if (is_subunit (lun) && is_compiled (lun))
	    extr_arcv (lun);

	if (has_secondaries (lun) && is_compiled (lun))
	{   LUN mh;
	    LUN *mas_head = &mh;

	    if (master_header (secondaries (lun), mas_head))
	    {
	PRINTF ("set_fname: unlink (%s)\n", archivefile (lun));
	        unlink (archivefile (mas_head));
	    }
/*
 * tijdelijk eruit,misschien wel definitief
 * abi 4-2-86
	    unlink (secondaries (lun));
 */
	PRINTF ("set_fname: unlink (%s)\n", secondaries (lun));
	}

	strncpy (source_name (lun), filename, FNAMESIZE);
	setname (tree_name (lun), treedir, filename, E_TREE);
	setname (object_name (lun), treedir, filename, E_OBJECT);

	if (outfile)
		strncpy (exec_name (lun), outfile, FNAMESIZE);
	else
		setname (exec_name (lun), CURRDIR, filename, E_EXEC);
}

set_secnames (lun, secdir)
LUN *lun;
char *secdir;
{
   sprintf (secondaries (lun), "%s/.su%d", secdir, ino_of (source_name (lun)));
	PRINTF ("set_secnames: secondaries (lun) = %s\n", secondaries (lun));
}

bool
master_header (file, header)
char *file;
LUN *header;
{
	return (get_plun (file, 0, header) ? TRUE : FALSE);
}

uppercase (s)
char *s;
{
	while (*s)
	{
	      if (islower (*s))
		 *s = toupper (*s);
	      s++;
	}
}
