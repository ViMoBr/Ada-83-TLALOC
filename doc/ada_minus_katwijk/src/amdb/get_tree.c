/*
 *	get_tree reads for each library unit
 *	the dastree and extracts the context
 *	of each unit.
 */


#define DEBUG

#include	"../h/print.h"
#include	<stdio.h>
#include	"../h/unix.h"
#ifndef FRONT
#include	"../h/rt_defs.h"
#endif FRONT
#include	"../h/tree.h"
#include	"../h/std.h"
#include	"../h/put_tree.h"
#include	"../h/record_man.h"
#include	"../h/lib_read.h"
#include	"../h/main.h"

#define t_next_of next_of
#undef next_of

/* avoids type and definitions clash between dapse and das compiler */
#define DDB_TREE
#include "debug.h"
#include "context.h"

extern struct with_unit lib_start;
extern struct with_unit *lib_head;
extern struct with_unit *lib_list;

t_tag null_tag;
ac mark_record;
FILE *outfile;

char *body_name();

short tree_in = 0;	/* is tree read in ? */
BODY_P levels (t_unit, lunl, status)
ac *t_unit;
LLIST *lunl;
int *status;
{
	BODY_P bp;
	bp = (BODY_P) malloc (sizeof (BODY));
	if ( bp == NULL)
	{
	   sysdb_error ("Can't get memory for body struct %s\n", t_unit -> tag);
	   *status = 0;
	   return NULL;
	}
	lowercase (t_unit -> tag);
	bp -> b_treeel = t_unit;
	bp -> b_bodylun = lunl;
	bp -> b_ldown = NULL;
	bp -> b_lnext = NULL;
#ifdef DEBUG
fprintf (stderr, "bodylun %d plun %d\n", log_id (lunl), phy_id (lunl));
fprintf (stderr, " body: name %s , node %d , lun %d\n", bp -> b_treeel -> tag, index_of (bp -> b_treeel), lun_of (bp -> b_treeel));
#endif
	return bp;
}

#ifdef DEBUG
int level = 0;
#endif
BODY_P *sub_levels (t_unit1, t_unit2, lunl, bpt, bp, status)
ac t_unit1, t_unit2;
LLIST *lunl;
BODY_P bpt;
BODY_P *bp;
int *status;
{

	ac t_unit;
	BODY_P encl_bp, encl_nbp, *stub_bp;

	*bp = 0;
#ifdef DEBUG
level++;
fprintf (stderr, "t _unit1 t_unit2 %d %d level %d\n", t_unit1, t_unit2, level);
#endif
	for (t_unit = t_unit1; t_unit; t_unit = t_unit2,t_unit2 = 0)
	{
	while (t_unit)
	{
#ifdef DEBUG
fprintf (stderr, "t_unit %d next %d d_of %d", t_unit, t_unit -> next, d_of (t_unit));
if (has_tag (t_unit))
    fprintf (stderr, " tag: %s", tag_of (t_unit));
fprintf (stderr, "\n");
#endif
		switch (d_of (t_unit))
		{
		case XSUBBODY :
#ifdef DEBUG
		     fprintf (stderr, "SUB body %s\n", tag_of (t_unit));
#endif
		     *bp = levels (t_unit -> specif, lunl, status);
		     if (*status == 0)
		        return NULL;
		     (*bp) -> b_lup = bpt;
#ifdef DEBUG
fprintf (stderr, "sub name %s body %d u %d d %d\n", body_name (*bp), *bp, (*bp) -> b_lup, (*bp) -> b_ldown);
#endif
		     sub_levels (t_unit -> fbodyloc, t_unit -> SBB_stats, lunl, *bp, &((*bp) -> b_ldown), status);
		     bp = &((*bp) -> b_lnext);
		     break;

		case XPACKBODY :
#ifdef DEBUG
		     fprintf (stderr, "PACK body %s\n", tag_of (t_unit));
#endif
		     *bp = levels (t_unit, lunl, status);
		     if (*status == 0)
		        return NULL;
		     (*bp) -> b_lup = bpt;
#ifdef DEBUG
fprintf (stderr, "sub name %s body %d u %d d %d\n", body_name (*bp), *bp, (*bp) -> b_lup, (*bp) -> b_ldown);
#endif
		     sub_levels (t_unit -> fbodyloc, t_unit -> PB_stats, lunl, *bp, &((*bp) -> b_ldown), status);
		     bp = &((*bp) -> b_lnext);
		     break;

		case XSEPARATE :
#ifdef DEBUG
		     fprintf (stderr, "SEPARATE stubbody %s lun %d node %d\n", tag_of (t_unit -> stub), lun_of (t_unit -> stub), index_of (t_unit -> stub));
fprintf (stderr, "enclunit %d\n", t_unit -> stub -> enclunit);
#endif
		     for (encl_bp = first_body (&bodylist); encl_bp; encl_bp = next_body (encl_bp))
		     {
/*
 * for subbodies treeel will point to the specification
 */
			 if (encl_bp -> b_treeel == t_unit -> stub -> enclunit)
			    break;
		     }
		     if (encl_bp == 0)
		     {
			fprintf (stderr, "Enclosing body %s for %s not found\n", tag_of (t_unit -> stub -> enclunit), tag_of (t_unit -> stub));
			break;
		     }

		     encl_nbp = encl_bp;
		     if (encl_nbp -> b_ldown)
		     {
			for (encl_nbp = encl_nbp -> b_ldown; encl_nbp -> b_lnext; encl_nbp = encl_nbp -> b_lnext);
			stub_bp = &(encl_nbp -> b_lnext);
		     }
		     else
			stub_bp = &(encl_nbp -> b_ldown);
		     sub_levels (t_unit -> next, 0, lunl, encl_bp, stub_bp, status);
		     t_unit = t_unit -> next;
		     break;


		case XBLOCK :
#ifdef DEBUG
		     fprintf (stderr, "BLOCK %s\n", tag_of (t_unit));
#endif
		     bp = sub_levels (t_unit -> fblockloc, t_unit -> BLK_stats, lunl, bpt, bp, status);
		     break;

#ifdef DEBUG
		case XSUB :
		     fprintf (stderr, "SUB spec %s lun %d node %d\n", tag_of (t_unit), lun_of (t_unit), index_of (t_unit));
		     break;

		case XPACKAGE :
		     fprintf (stderr, "PACK spec %s lun %d node %d\n", tag_of (t_unit), lun_of (t_unit), index_of (t_unit));
		     break;

		case XSTUB :
		     fprintf (stderr, "STUB  %s lun %d node %d\n", tag_of (t_unit), lun_of (t_unit), index_of (t_unit));
		     break;
#endif
		default:
		     break;
		}
#ifdef DEBUG
fprintf (stderr, "ENDWHILE t_unit %d t_unit -> next %d level %d\n", t_unit, t_unit -> next, level);
#endif
		t_unit = t_unit -> next;
	}
	}
#ifdef DEBUG
level--;
#endif
	return *bp ? &((*bp) -> b_lnext) : bp;
}

/*
 * bld_lev_struct : Build bodylist for name access
		    and allocate space for bodystructure.
		    Read for each lun in loadlist the program tree
		    and find proc,sub,package names.
		    Allocate for each name a body structure and link information
		    to the program tree and loadlist.
 */
bld_lev_struct (unit, status)
LUN *unit;
int *status;
{
	int j;
	CNTR_LLIST *closure = &(unit -> closure);
	LLIST *x = first_of (closure);
	register struct with_unit *l = lib_head;
	BODY_P *bp = &(bodylist .b_ldown);

	p_init();
/*
 * print loadlist
 */
#ifdef DEBUG
	for (j = 0; j < unit -> closure. closurecount; j++)
	{
	     fprintf (stderr, "%s\n", x -> _unit. _unit_name);
	     x = next_of (x);
	}
#endif
	x = first_of (closure);
	/*
	 *  read package standard
	 */
	proc_lib (log_id (last_of (closure)), tree_file (last_of (closure)));
	for ( j = 0; j < unit -> closure. closurecount -1; j++)
	{
#ifdef DEBUG
fprintf (stderr, "unit name %s\n", x -> _unit ._unit_name);
#endif
	    proc_lib ( log_id (x), tree_file (x));
	    lowercase (x -> _unit ._unit_name);
	    l = l -> next_unit;
#ifdef DEBUG
fprintf (stderr, "treenaam: %s unitnaam %s\n", tag_of (l -> unit), name_of (x));
#endif
	    bp = sub_levels (l -> unit, NULL, x, &bodylist, bp, status);
	    if (*status == 0)
	       return NULL;
	    x = next_of (x);
	}
	tree_in = 1;
}

p_init ()
{
	register int i;

	null_tag = l_alloc (2);
	mark_record = l_alloc (MARKSIZE);
	mark_record -> d = XMARK;

	std_init (1, st_table);
}
dump_core(){
	_cleanup ();
	abort ();
}
sys_error (a, b)
register char *a, *b;
{
	/*
	sysdb_error (a, b);
	*/
	fprintf (stderr, a, b);
	dump_core();
}

char *body_name (bp)
BODY_P bp;
{
	if (bp -> b_treeel)
	   return (bp -> b_treeel -> tag);
	if (bp == &bodylist)
	   return "start tree";
	return "no name";
}

body_node (bp)
BODY_P bp;
{
	return (index_of (bp -> b_treeel));
}

body_lun (bp)
BODY_P bp;
{
	return (lun_of (bp -> b_treeel));
}
