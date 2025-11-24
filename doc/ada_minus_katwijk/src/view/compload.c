#include "libr.h"
/*#define DEBUG*/
#include "DEBUG.h"

bool add_standard (), get_body ();

init_complist (lib, lun, status)
register LIBDESC *lib;
register LUN	 *lun;
bool	 *status;
{
	CNTR_LLIST *closure = &(lun-> closure);

	init_closure (closure);

	/*
	 * Adjust tree_stamp for the top lun,because
	 * that time is compared with other times and should be greater
	 */
	tree_stamp (lun) = MAXTIME - 1;
	comp_closure (lib, closure, lun, MAXTIME, status);
	if (!*status) return;

	if (!add_standard (lib, closure))
	{
	   *status = FALSE;
	   return;
	}
}

comp_closure (lib, closure, lun, tree_time, status)
register LIBDESC  *lib;
register CNTR_LLIST *closure;
LUN	  *lun;
long	  tree_time;
bool	  *status;
{
	register int i;
	LUN x;
	LUN *parent = &x;

	if (in_closure (lun, closure))
	{ *status = TRUE;
	  return;
	}

	PRINTF ("comp closure of %s\n", name_of (lun));
	if (tree_stamp (lun) > tree_time)
	{ printf ("%s out of order in compilation\n", name_of (lun));
	  *status = FALSE;
	  return;
	}

	for (i = 0; i < wcount (lun); i++)
	{
	   LUN x;

	   get_plun (library_name (lib), wlist (lun, i), &x);

	   PRINTF ("unit %s\n", name_of ((&x)));
	   comp_closure(lib, closure, &x, tree_stamp (lun), status);
	   if (!*status)
	   {
	      PRINTF ("compload: false1\n");
	      return;
	   }
	}

	if (is_subunit (lun))
	{
	   LUN x;
	   LUN *parent = &x;

	   get_parent (lib, lun, parent, status);
	   if (!*status)
	   {
	      PRINTF ("compload: false2\n");
	      return;
	    }

	   comp_closure (lib, closure, parent, tree_stamp (lun), status);

	   if (!*status)
	   {
	      PRINTF ("compload: false4\n");
	      return;
	   }
	}

	if (in_closure (lun, closure))
	{ *status = FALSE;
	  PRINTF ("compload: false5\n");
	  return;
	}

	if (!add_closure (lun, closure))
	{  *status = FALSE;
	   PRINTF ("compload: false6\n");
	   return;
	}

	*status = TRUE;
}

#define C_STARTPOINT	6
#define INTWIDTH	6

char *
alloc_int (x)
int x;
{
	char *y;

	y = (char *) malloc (INTWIDTH);
	sprintf (y, "%d", x);

	return y;
}

c_compute_args (lun, av, fl)
LUN  *lun;
char * av [];
CNTR_ALIST *fl;
{
	int j;
	char *int_alloc;
	int	loadpoint = C_STARTPOINT;
	CNTR_LLIST *closure = &(lun-> closure);
	LLIST *x = first_of (closure);

	int_alloc = alloc_int (log_ident (lun));
	av [2] = int_alloc;

	av [4] = "2";
	av [5] = tree_file (last_of (closure));

	for (j = 0; j < lun-> closure. closurecount - 2; j++)
	{
	   int_alloc = alloc_int (log_id (x));
	   av [loadpoint ++] = int_alloc;
	   av [loadpoint ++] = tree_file (x);
	   x = next_of (x);
	}

	if (fl -> _first != NULL)
	   { ALIST *l = fl -> _first;
	     for (j = 0; j < fl -> alistcount; j++)
	     {
	        av [loadpoint ++] = l -> _argument;
	        l = l -> _next;
	     }
	   }

	av [loadpoint] = (char *) NULL;
}

init_loadlist (lib, lun, status)
register LIBDESC *lib;
register LUN	 *lun;
bool	 *status;
{
	CNTR_LLIST *closure = &(lun-> closure);
	
	init_closure (closure);

	if (is_subprogram (lun))
	    load_closure (lib, closure, lun, MAXTIME, status);
	else
	{
	    *status = FALSE;
	    fprintf (stderr, "Start of loadlist: %s should be subspec\n",
		 name_of (lun));
	}
	if (!*status) return;

	if (!add_standard (lib, closure))
	{  *status = FALSE;
	   return;
	}
}

load_closure (lib, closure, lun, obj_time, status)
register LIBDESC  *lib;
register CNTR_LLIST  *closure;
LUN  *lun;
long obj_time;
bool *status;
{
	register int i;
	long obj_stamp = object_stamp (lun);

	LUN  bl;
	LUN  *bodylun = &bl;

	PRINTF ("load_closure %s \n", name_of (lun));
	if (in_closure (lun, closure))
	{ 
	  *status = TRUE;
	  PRINTF ("In closure\n");
	  return;
	}

	if (is_spec (lun) && (obj_stamp > obj_time) ||
	    is_body (lun) && (obj_stamp < obj_time))
	{
	  printf ("%s out of order in loader\n", name_of (lun));
	  *status = FALSE;
	  return;
	}

	for (i = 0; i < wcount (lun); i++)
	{  LUN wl;
	   LUN *withlun = &wl;

	   get_plun (library_name (lib), wlist (lun, i), withlun);
	   PRINTF ("with %s\n", name_of (withlun));

	   load_closure (lib, closure, withlun, obj_stamp, status);
	   if (*status == FALSE) 
	       return;
	}

	if (in_closure (lun, closure))
	{ 
	  *status = FALSE;
	  return;
	}

	if (!add_closure (lun, closure))
	{  
	   *status = FALSE;
	   return;
	}

	if (has_secondaries (lun))
	{
	   CNTR_LLIST s;
	   CNTR_LLIST *subs = &s;
	   LLIST *x;
	   LUN su;
	   LUN *subunit = &su;
	   int j;

	   get_subunits (lun, subs);
	   x = first_of (subs);
	   for (j = 0; j < subs-> closurecount; j++)
	   {
	      if (!get_plun (currentfile (x), phy_id (x), subunit))
	      { 
		 *status = FALSE;
	         return;
	      }

	      PRINTF ("sec unit %s\n", name_of (subunit));
	      load_closure (lib, closure, subunit, obj_stamp, status);
	      if (!*status) return;

	      x = next_of (x);
	   }

	   /* must also be initialised
	   get_plun (secondaries (lun), 0, subunit);
	   if (subs -> closurecount != numberofstubs (subunit))  
	   {
	      *status = FALSE;
	      printf ("Number of subunits should be %d in stead of %d\n",
		numberofstubs (subunit), subs -> closurecount);
	   }
	    */	
	}


	*status = TRUE;
	PRINTF ("Normal return load closure %s\n", name_of (lun));
}

bool
get_spec (lib, lun, spec_lun)
LIBDESC *lib;
LUN *lun, *spec_lun;
{
	int status = TRUE;
	
	get_parent (lib, lun, spec_lun, &status);
	if (!status) return FALSE;
	
	if (!is_compiled (spec_lun)) return FALSE;

	return TRUE;
}

bool
get_body (withlun, bodylun)
LUN *withlun, *bodylun;
{
	int status = TRUE;

    PRINTF ("Get body van %s\ecfile %s", name_of (withlun), secondaries (withlun));
	ll_get (secondaries (withlun), name_of (withlun), bodylun, &status);
	return (status ? TRUE : FALSE);
}

/*
 * get luns for loadlist depending on lun
 */
get_subunits (lun, subunits)
LUN *lun;
CNTR_LLIST *subunits;
{
	int recno = 1;
	LUN t;
	LUN *temp = &t;

	init_closure (subunits);

	PRINTF ("get_subunits\n");
	while (get_plun (secondaries (lun), recno, temp))
	{
	   if (is_occupied (temp))
	       if (!add_closure (temp, subunits)) break;

	   recno ++;
	}
}

l_compute_args (lun, av, libs, prefs)
LUN	   *lun;
char	   *av [];
CNTR_ALIST *libs;
CNTR_ALIST *prefs;
{
	CNTR_LLIST *closure = &(lun-> closure);
	LLIST *x = first_of (closure);
	LLIST *y;
	int j;
	int loadbase = 0;
	CNTR_ALIST t;
	CNTR_ALIST *temp = &t;
	ALIST *al;


	init_arglist (temp);

	add_arglist (LOADER, temp);
	add_arglist (DASLOAD, temp);

	if (prefs-> _first != NULL)
	{   ALIST *p = prefs-> _first;
	
	    for (j = 0; j < prefs-> alistcount; j++)
	    {
	        add_arglist (p-> _argument, temp);
	        p = p-> _next;
	    }
	}
	else
	    add_arglist ("start.o", temp);	/* bah */

/*
 *	Programming a la robert, get rid of it as soon	*
 *	as possible					*
 */

	y = x;
	for (j = 0; j < closure -> closurecount; j ++)
	{
	    if (!is_subu (x) &&  log_id (x) != 2)
	    if ((!(x -> _unit ._flags & (GNRC | SU)) && log_id (x) != 2) &&
		  (x -> _unit ._flags & BODY || x -> _unit ._flags & PS))
		    add_arglist (object_file (x), temp);

	    x = next_of (x);
	}
/*
 *	Second loop for the archives
 */
	x = y;
	for (j = 0; j < closure -> closurecount; j++)
	{
	   if (is_subu (x))
	      if (get_archname (x, object_file (x)))
	         add_arglist (object_file (x), temp);
	   x = next_of (x);
	}

	add_arglist (dasexit, temp);
	add_arglist (b_standard, temp);

	if (libs-> _first != NULL)
	{   ALIST *l = libs-> _first;
	
	    for (j = 0; j < libs-> alistcount; j++)
	    {
	        add_arglist (l-> _argument, temp);
	        l = l-> _next;
	    }
	}

	add_arglist (daslib, temp);
	add_arglist (daslib, temp);
	add_arglist (LIBM, temp);
	add_arglist (LIBC, temp);
	add_arglist (LIBC, temp);
	add_arglist ("-o", temp);
	add_arglist (exec_name (lun), temp);

	al = temp-> _first;
	for (j = 0; j < temp-> alistcount; j++)
	{
	    av [j] = al-> _argument;
	    al = al-> _next;
	}
	av [j] = (char *) 0;
}

/*
check_objs (lun, status)
LUN *lun;
bool *status;
{
	register int i;
	char *of;
	
	for (i = 0; i < count_closure (lun); i++)
	{  of = object_file (unit_closure (lun, i));
	   if (!reachable (of))
	   {  *status = FALSE;
	      return;
	   }
	}
}
*/

bool
add_standard (lib, closure)
LIBDESC *lib;
CNTR_LLIST *closure;
{
	LUN s;
	LUN *standard = &s;
	bool status;

	get_lun (lib, "STD_PS", standard, &status);
	if (!status) return FALSE;

/* for now ... HT
	if (!add_closure (standard, closure))
	   return FALSE;
 */

	return TRUE;
}

pr_closure (closure)
CNTR_LLIST *closure;
{
	LLIST *x = first_of (closure);

	printf ("closure is: ");
	while (x != NULL)
	{   printf ("(%d, %d) ", phy_id (x), log_id (x));
	    x = x-> _next;
	}
	printf ("\n");
}

set_tmpnames (name, a_lun, tmpdir, savetemps)
char *name;
register LUN *a_lun;
char *tmpdir;
bool savetemps;
{
	if (savetemps)
	{  setname (prep_name (a_lun), tmpdir, name, E_PREP);
	   setname (pcc_name  (a_lun), tmpdir, name, E_PCC);
	   setname (opt_name  (a_lun), tmpdir, name, E_OPT);
	   setname (ass_name  (a_lun), tmpdir, name, E_AS);
	   setname (front_name (a_lun), tmpdir, name, E_FRONT);
	}
	else
	{  xtmp (prep_name	(a_lun), tmpdir, 'a');
	   xtmp (pcc_name 	(a_lun), tmpdir, 'b');
	   xtmp (opt_name	(a_lun), tmpdir, 'c');
	   xtmp (ass_name 	(a_lun), tmpdir, 'd');
	   xtmp (front_name	(a_lun), tmpdir, 'e');
	}
}

xtmp (targ, source, ext)
char *targ, *source, ext;
{
	int pid = getpid ();

	sprintf (targ, "%s/%d%c", source, pid, ext);
}

strip_ext (r, s)
char *r, *s;
{
	int flag = 0;

	strcpy (r, s);

	while (*++r != '\0')
		if (*r == '.')
			flag = 1;
	if (!flag)
		return;

	while (*--r != '.');
	*r = '\0';
}

setname (targ, dir, source, ext)
char *targ, *dir, *source, ext;
{
	char prefix[FNAMESIZE];

	strip_ext (prefix, source);
	if (dir[0] == '.' && dir[1] == '\0')
		sprintf (targ, "%s.%c", prefix, ext);
	else
		sprintf (targ, "%s/%s.%c", dir, prefix, ext);
}

/*
 * list of package specs and bodies
 */
get_lluntab (lun, lluntab)
LUN	   *lun;
lunno	   lluntab [];
{
	CNTR_LLIST *closure = &(lun-> closure);
	LLIST *x = first_of (closure);
	LLIST *y;
	int i, j;
	int loadbase = 0;

	for (i = 0, j = 0; j < closure -> closurecount; j ++)
	{
	    if (!(x -> _unit ._flags & GNRC) && x -> _unit ._flags & PS)
	    {
	       lluntab[i] = log_id (x);
	       i++;
	    }

	    x = next_of (x);
	}
	lluntab[i] = 0;
}
