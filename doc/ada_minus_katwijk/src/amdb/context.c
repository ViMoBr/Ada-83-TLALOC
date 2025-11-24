#
/*
 *	routines for contexts
 */

/*
 *	include files
 */

#include "debug.h"
#include "context.h"
#include "mode.h"
#include <ctype.h>
#include <filehdr.h>
#include <aouthdr.h>
#include <syms.h>
#include <scnhdr.h>

/*
#define DEBUG
*/
/*
#define DEB1
*/
#ifdef DEBUG
#define DEB1
#endif

/*
 *	scalars
 */

BODY bodylist =
		/*
		 * first element of body struct for both level and adress access
		 * via resp b_ldown and b_adown. No next fields.
		*/
{0,0,{MY_DELETE, MY_DELETE, MY_DELETE},0,0,0,0,0,0};
BODY_P st_current;
BODY_P first_in_list;
BODY_P first_body(), next_body();
LUN *proglun;

char * readsym();
char *full_body_name(), *body_name();

/*
 *	setup the loaded units of this program and initialise
 *	their unit and body descriptors
 */

setcontext (unit, symtable, file, aout)
LUN		*unit;
struct syment	*symtable;
struct filehdr	*file;
struct aouthdr	*aout;
{
	register long		symcount;
	register struct syment  *symbol;
	int			status,i,withlun;
	BODY_P			body;

	/* generate a list of loaded units */

	init_loadlist (library, unit, &status);
	if (!status)
	   return FALSE;
#ifdef DEBUG
fprintf (stderr, "loadlist binnen\n");
#endif

	/*
	 * Read program tree and build bodylist for name access(level structure)
	 */
	bld_lev_struct (unit, &status);

#ifdef DEB1
	/*
	 * druk lijst van bodies af
	 */
	for (body = first_body (&bodylist); body; body = next_body (body))
	    fprintf (stderr, "body %s lup %s ldown %s lnext %s\n",
		     body_name (body), body_name (body ->b_lup),
		     body_name (body -> b_ldown), body_name (body -> b_lnext));
#endif

	if (!status)
	   return FALSE;
#ifdef DEBUG
fprintf (stderr, "bodylist binnen\n");
#endif

	/* search symboltable for runtime info on bodies */

	rewind();
	symcount = file -> f_nsyms;
	symbol = symtable;
	while (symcount-- > 0) {
		if (symbol -> n_value <= aout -> tsize)
			das_rt (symbol);
		symbol++;
	}

#ifdef DEBUG
fprintf (stderr, "symbols geladen\n");
#endif
	/* as a last step build the adress tree of bodies */

	build_tree ();
#ifdef DEB1
	/*
	 * print address tree
	 */
	for (body = first_body (&bodylist); body; body = next_body (body))
	    fprintf (stderr, "body %s aup %s adown %s anext %s\n",
		     body_name (body), body_name (body ->b_aup),
		     body_name (body -> b_adown), body_name (body -> b_anext));
fprintf (stderr, "body tree gemaakt\n");
getchar();
#endif
	return TRUE;
}

/*
 *	store the text symbol if it is a DAS runtime
 *	symbol generated specially for this debugger
 */

das_rt (symbol)
struct syment * symbol;
{
	register char *s_name;
	register int   unit,i;

	s_name = readsym (symbol -> n_name);
	if (s_name[0] == 'D' && ((s_name[1] == 'S') || (s_name[1] == 'E'))) {
		/* format is D[SE]X... or D[SE]_X...*/
		i = s_name[2] == 'X' ? 3 : 4;
		unit = t63tonum (&s_name[i]);
		store (symbol -> n_value, s_name, unit);
	}
}

/*
 * Here it is assumed that the assembler can use at least 64 different
 * characters to form a valid identifier.
 * In this way, there are as few extra characters needed to make a name
 * unique.
 * Further it is assumed that a lun does not exceed 64 * 52 - 1 (3327),
 * or else the generated name might not start with a letter.
 */
static char ass_chars[] =
{ 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p',
  'q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F',
  'G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V',
  'W','X','Y','Z','_','0','1','2','3','4','5','6','7','8','9',EXTRA_LETTER
};
#define	SS	3
#define ALFABETSIZE	63

mk_s (str, d1, d2)
register char *str;
register unsigned d1, d2;
{
	register int i;

	for (i = SS - 1; i >= 0; i --)
	   { str [i] = ass_chars [d1 % ALFABETSIZE];
	     d1 = d1 / ALFABETSIZE;
	   }

	for (i = SS + SS - 1; i >= SS; i --)
	   { str [i] = ass_chars [d2 % ALFABETSIZE];
	     d2 = d2 / ALFABETSIZE;
	   }

	str [SS + SS] = '\0';
}

/*
 *	alf_val zoekt char op in ass_chars
 */

alf_val (c)
char c;
{
	register short i;
	for (i = 0; i < ALFABETSIZE; i++)
	     if (ass_chars[i] == c)
		 return i;
	return 0;
}

/*
 *	t63tonum converts a base 63 number to a number in base 10
 */

t63tonum (body_name)
char body_name[];
{
	register int i, nr;

	for (i = 0, nr = 0; i < 3; i++)
	     nr = nr * ALFABETSIZE + alf_val (body_name[i]);

#ifdef DEBUG
fprintf ( stderr, "unit_nr: name %s nr %d\n",body_name,nr);
#endif
	return (nr);
}

/*
 *	first_body returns the first body of a sequential list which
 *	contains all bodies in the bodylist.
 *
 *	next_body returns the next body of the list
 */
BODY_P first_body (body)
BODY_P body;
{
	if (body == 0)
	    return 0;
	first_in_list = body;
	while (body -> b_ldown != 0)
	      body = body -> b_ldown;
	
	return body;
}

BODY_P next_body (body)
BODY_P body;
{
	BODY_P bp;
	if (body -> b_lnext == 0)
	   if (body == first_in_list)
	      return NULL;
	   else
	      return body -> b_lup;
	if (body == first_in_list)
	    first_in_list = body -> b_lnext;
	body = body -> b_lnext;
	bp = body;
	while (bp -> b_ldown != 0)
	      bp = bp -> b_ldown;
	if (bp != body)
	   return bp;
	else
	   return body;
}

/*
 *	construct a tree reflecting the nesting of package 
 *	and subprogram bodies in the source program
 */

build_tree ()
{
	register BODY_P body,smallest,prev,next;
	BODY_P x;

	bodylist .b_adown = 0;
	bodylist .b_aup = 0;
	bodylist .b_anext = 0;

	for (body = first_body (&bodylist) ; body != &bodylist; body = next_body (body)) 
	{
	    top_down (&x, body, &bodylist);
	    body -> b_anext = x -> b_adown;
	    x -> b_adown = body;
	    body -> b_adown = 0;
	    body -> b_aup = x;
	    order (x);
	}
}

/*
 *	check if there is a body in the range of the
 *	first body in the down field of parameter body
 */

order (bp)
BODY_P bp;
{
	BODY_P x,prev, body;

	body = bp;
	if (!(body = body -> b_adown))
		return;
	prev = body;
	for (x = body -> b_anext; x; x = x -> b_anext) {
		if (body_range (body, x)) {
			x -> b_aup = body;
			prev -> b_anext = x -> b_anext;
			x -> b_anext = body -> b_adown;
			body -> b_adown = x;
			x = prev;
		}
		prev = x;
	}
}

/*
 *	search tree root for the closest surrounding package or
 *	subprogram body of body
 */

top_down (enclosing, body, root)
BODY_P * enclosing,body,root;
{
	register BODY_P i;

	*enclosing = root;
	for (i = root -> b_adown; i; i = i -> b_anext) 
		if (body_range (i, body)) {
			top_down (enclosing, body, i);
			return;
		}
}

/*
 *	search tree starting from body bottom up for a body
 *	that contains the adress
 */

context (enclosing, address, body)
BODY_P *enclosing,body;
long address;
{
	BODY_P z;
	
#ifdef DEBUG
fprintf ( stderr, "in context name \n");
#endif
	if (body) {
		if (in_range (body, address)) {
#ifdef DEBUG
fprintf (stderr, " cnt body %s", body_name (body));
#endif
			*enclosing = body;
			for (z = body -> b_adown; z; z = z -> b_anext) {
				if (in_range (z, address)) {
					context (enclosing, address, z);
					return;
				}
			}
		}
		else 
			if (body -> b_aup != 0)
			    context (enclosing, address, body -> b_aup);
			else
			    sysdb_error ("break address %d out of any body", address);
	}
}

in_range(body,address)
BODY_P body;
long address;
{
#ifdef DEBUG
fprintf ( stderr, "in_range: name %s start %d end %d address %d\n", body_name (body), body -> b_start, body -> b_end, address);
#endif
	if (!body)
		return FALSE;
	if ((body -> b_start <= address) && (address <= body -> b_end))
		return TRUE;
	return FALSE;
}

body_range (body1, body2)
BODY_P body1,body2;
{
#ifdef DEBUG
fprintf (stderr, "body1 %s body2 %s\n", body_name (body1), body_name (body2));
#endif
	if (in_range (body1, body2 -> b_start) && in_range (body1, body2 -> b_end))
		return TRUE;
	return FALSE;
}

/*
 *	store the symbol representing the runtime representation 
 *	of a package or subprogram body identifier
 */

store (n_value, name, unit)
long n_value;
char *name;
int unit;
{ 
	register BODY_P body;
	long		node;
	int		status, i;
	char 		*save;

#ifdef DEB1
fprintf ( stderr," in store unit %d name %s n_value %D\n",unit,name,n_value);
#endif
	/* compute the node number */
	save = name;
	i = save[2] == 'X' ? 3 : 4;
	name += SS + i;
	node = t63tonum (name);
	name += SS;
#ifdef DEBUG
	fprintf(stderr,"node %d\n",node);
#endif
	if (! *name)
		return;		/* apparantly real body name missing, so no store*/
	lowercase (name);	/* convert to lowercase */
#ifdef DEBUG
	fprintf (stderr, "name %s\n", name);
#endif
	for (body = first_body (&bodylist); body; body = next_body (body))
	{
#ifdef DEBUG
fprintf (stderr, "name %s body_name %s lun %d unit %d index %d node %d\n",
name, body_name (body), body_lun (body), unit, body_node (body), node);
#endif
	    if (equal (name, body_name (body)) &&
		(body_lun (body) == unit) &&
		(body_node (body) == node ))
	       break;
	}
	if (body == 0 )
	   sysdb_error ("body name : %s for store not found",name);
#ifdef DEBUG
fprintf (stderr, "bodyp %d\n ", body);
#endif
	for (i = 0;i < POSSIBLE;i++)
	    body->b_event[i] = MY_DELETE;
	if (save[1] == 'E')
	{
	   if (bodylist .b_end < n_value) 
	      bodylist .b_end = n_value;
	   body -> b_end = n_value;
	}
	else
	{
	   if (bodylist .b_start > n_value)
	      bodylist .b_start = n_value;
	   body -> b_start = n_value;
	}
}

/*
 *	sel_comp_not
 *	vind de body pointer bij een naam in selected component notatie
 */

BODY_P sel_comp_name (name, l_body)
char *name;
BODY_P l_body;
{
    char c;
    char *p;

    for (p = name; *p != '\0' && *p != '.'; p++);

    c = *p;
    *p = '\0';

    for (l_body = l_body -> b_ldown; l_body; l_body = l_body -> b_lnext)
	 if (equal (name, body_name (l_body)))
	     break;

    *p = c;
    if (l_body == 0 || c == '\0')
	return l_body;

    return (sel_comp_name (++p, l_body));
}

/*
 *	use command
 */

use_unit()
{
	register BODY_P l_body;
	char *body_n;
	char tree[50];

	if (c_mode -> mode_flag == TRUE)
	    clrmenu ();
	ccommand("use");
	for (;;) {
		prompt("enter name ");
		body_n = inline();
		if (!*body_n)
			break;
		l_body = sel_comp_name (body_n, &bodylist);
		if (!l_body) {
			sysdb_error("name %s not with program",body_n);
			continue;
		}
		break;
	}
        if (c_mode -> mode_flag == TRUE)
	    menu (c_mode -> mode_name);
	if (!*body_n)
	    return;
	st_current = l_body;
	cunit (full_body_name (st_current));
}


/*
 *	print the name (including the path) of the body
 */

pr_name (body)
register BODY_P body;
{
	fprintf (stdout, "%s", full_body_name (body));
}

char *full_body_name (body)
register BODY_P body;
{
	static char buf [100];
	buf[0] = '\0';
	if (body != &bodylist)
	{
	   _fb_name (body -> b_lup, buf);
	   strcat (buf, body_name (body));
	}
	return &buf[0];
}

_fb_name (body, buf)
register BODY_P body;
char *buf;
{
	if (body == &bodylist)
	   return;
	_fb_name (body -> b_lup, buf);
	strcat (buf, body_name (body));
	strcat (buf, ".");
}

/*
 *	search the body trees for the newly entered 
 *	package or subprogram body
 */

tree_search (address)
long address;
{
#ifdef DEBUG
fprintf ( stderr, "in tree search");
#endif
	context (&cur_body, address, cur_body);
#ifdef DEBUG
fprintf (stderr, "cur_body %s adres %d\n", body_name (cur_body), address);
#endif
}
