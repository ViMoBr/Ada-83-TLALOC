/*
 * (c) copyright 1986, Delft University of Technology
 * Delft, The Netherlands
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 * For further information contact
 *	Jan van Katwijk
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 */

/*
 * C source for ada makefile generator
 * In this file routines are included that determine the dependency
 * between compilation units in the input.
 * A list structure is build to contain all information.
 *
 * Ton Biegstraaten dutinfd!abi 24-3-87
 * last changed 12-1-88
 */

#include <stdio.h>
#include "adadep.h"

/*#define DEBUG
/**/
#ifdef DEBUG
#undef stderr
#define stderr stdout
#define PRINTF printf
#else
#define PRINTF dummy
static dummy ()
{
}
#endif

/*
 * unit_list is the head of the compilation unit list
 * p_curwlist is a pointer to the current element of the withlist
 * p_curstlist is a pointer to current element in
 * the stubname list;
 */
 
struct unode *give_unptr(), *look_for();
struct unode_list unit_list, *p_unit_list = &unit_list, *p_curwlist,
       *p_curstlist;
struct unode *curunit; /* the current data for the compilation unit at hand */

char *mem_for(), *malloc(), *full_stub_name();
extern struct sf_list *p_sf_list;

/*
 * alloc_unit : a new list element is allocated and initialised
 */
struct unode *
alloc_unit ()
{
    register struct unode * p_un;

    p_unit_list -> ul_next = (struct unode_list *) 
				mem_for (sizeof (struct unode_list));
    p_unit_list = p_unit_list -> ul_next;
    p_unit_list -> ul_node = (struct unode *) mem_for (sizeof (struct unode));
    p_un = p_unit_list -> ul_node;;
    PRINTF ("alloc ul %x un %x\n", p_unit_list, p_un);
    p_unit_list -> ul_next = NULL;
    p_un -> u_context .ul_next = NULL;
    p_un -> u_stubs .ul_next = NULL;
    p_un -> u_name[0] = 0;
    p_un -> u_sname[0] = 0;
    p_un -> u_spec = NULL;
    /*
    p_lijst (unit_list .ul_next, 10);/* for debugging */
    return p_un;
}

/*
 * new_unit : a new unit is added to the list
 *	      a reference from an other unit can already exist
 *	      current pointers are initialised
 */
void
new_unit ()
{
    PRINTF ("new unit\n");
    curunit = alloc_unit ();
    p_curwlist = &(curunit -> u_context);
    p_curstlist = &(curunit -> u_stubs);
    curunit -> u_flags = UNIT_TEXT; /* text of unit is in input */
}

/*
 * add_wlist : add the withunitname to the withlist
 */
void
add_wlist (wuname)
char *wuname;
{
    register struct unode *un;
    
    uppercase (wuname);
    un = give_unptr (wuname, PS);
    PRINTF ("add_w un %x\n", un);
    p_curwlist -> ul_next = (struct unode_list *) 
				mem_for (sizeof (struct unode_list));
    p_curwlist = p_curwlist -> ul_next;
    p_curwlist -> ul_node = un;
    p_curwlist -> ul_next = NULL;
    /*
    p_lijst (unit_list .ul_next, 15);
    */
}

/*
 * add_parlist : add the parent name to the parent list
 */
void
add_parlist (parname)
char *parname;
{
    register struct unode *un;

    uppercase (parname);
    un = give_unptr (full_stub_name (parname), BODY);
    un -> u_spec = curunit -> u_spec;
    curunit -> u_spec = un;

    /*
    p_lijst (unit_list .ul_next, 20);
    */
}

/*
 * look_for looks for an unode with the given name
 */
struct unode *
look_for (uname, kind)
register char *uname;
int kind;
{
    register struct unode_list *p_unl;
    int mask = UNIT_TEXT | COMP_VALID | VISITED | GNRC;

    PRINTF ("look_for uname %s kind %x\n", uname, kind);
    /*
    p_lijst (unit_list .ul_next, 5);
    */
    for (p_unl = unit_list .ul_next; p_unl; p_unl = p_unl -> ul_next)
    {
	PRINTF (" fl: %x %x %x kind SB%x name %s\n",
	    p_unl -> ul_node -> u_flags,
            p_unl -> ul_node -> u_flags & ~mask,
            (p_unl -> ul_node -> u_flags & (SU|BODY)) & ~mask,
	    kind & BODY,
	    p_unl -> ul_node -> u_name);
        /*
         * Looks awfull,but references to units that appear later in the text
         * are possible even common.
         * In case of a body dependence its is not always clear if
         * a package body or subprogram body is involved.
         * but because stubs have their selected component name
         * knowing it is a body is sufficient
         */
	if ((((kind & ~mask) == (p_unl -> ul_node -> u_flags & ~mask)) ||
	  ((kind & BODY ) == p_unl -> ul_node -> u_flags) ||
	  (kind == (p_unl -> ul_node -> u_flags & BODY))) &&
          strcmp (p_unl -> ul_node -> u_name, uname) == 0)
	    return p_unl -> ul_node;
    }
    
    return NULL;
}

/*
 * give_unptr : looks for a unode with name uname and returns the pointer
 *		or allocates a new unode struct
 */
 struct unode*
 give_unptr (uname, kind)
 char *uname;
 int kind;
 {
    register struct unode *p_un;

    p_un = look_for (uname, kind);
    if (p_un == NULL)
    {
	p_un = alloc_unit ();
	strncpy (p_un -> u_name, uname, FNAMESIZE);
	p_un -> u_flags = kind;
    }

    return p_un;
}
/*
 * unodemv : an unode can be used(and allocated) before defined.
 *   A new unit is always allocated new so a unit can be double defined.
 *   This routine moves data to the correct place and removes the obsolete
 *   allocation.
 */
struct unode *
unodemv (current, first)
register struct unode *current, *first;
{
    PRINTF ("Unode move %x %x\n", current, first);
    first -> u_flags |= current -> u_flags;
    first -> u_context = current -> u_context;
    first -> u_spec = current -> u_spec;
    first -> u_stubs = current -> u_stubs;
    extract (current);
    free (current);	
    extract (first);
    p_unit_list -> ul_next = (struct unode_list *) mem_for(sizeof (struct unode));
    p_unit_list = p_unit_list -> ul_next;
    p_unit_list -> ul_node = first;
    p_unit_list -> ul_next = NULL;
    return first;
}

/*
 * extract : verwijder unode uit de unode ljst
 */
extract (current)
struct unode *current;
{
    register struct unode_list *p1, *p2;

    p2 = &unit_list;
    for (p1 = p2 -> ul_next; p1; p1 = p1 -> ul_next)
    {
	if (p1 -> ul_node == current)
	{
	    p2 -> ul_next = p1 -> ul_next;
	    PRINTF ("remove ul %x un %x prev %x nxt %x\n", p1, current, p2, p1 -> ul_next);
        if (p1 -> ul_next == NULL)
		p_unit_list = p2;
	    free (p1);
	    return;
	}
	p2 = p1;
    }
}

/*
 * add_uname : fill in data for current unit
 *  test if unit already exists, replace unit in that case
 */
void
add_uname (uname, kind)
char *uname;
int kind;
{
    register struct unode *p_un;
    
    uppercase (uname);
    PRINTF ("add unit %s\n", uname);
    if (kind & SU)
    {
	kind |= BODY;	/* a subunit is always a body */
	p_un = look_for (full_stub_name (uname), kind);
    }
    else
        p_un = look_for (uname, kind);
    /* a unit can be referenced before defined 
       and will then be added as its type (BODY,SP) */

    if (p_un)
    {
    	if (p_un -> u_flags & UNIT_TEXT)
    	{
    	    fprintf (stderr, "Text of unit %s has been seen more than once\n", uname);
    	    exit ();
    	}
	curunit = unodemv (curunit, p_un);
    }
    strncpy (curunit -> u_sname, sfname, FNAMESIZE);
    strncpy (curunit -> u_name,
             kind & SU ? full_stub_name (uname) :
              uname, FNAMESIZE);
    curunit -> u_flags |= kind;

    /* look for specification if body and not su*/
    /* for su spec is always known because of separate (...) */
    if ((kind & (SU|BODY)) == BODY)
        curunit -> u_spec = give_unptr (uname, kind & ~(UNIT_TEXT|BODY));
}

/*
 * adj_kind : adjust kind for units
 *      The full kind of a procedure is sometimes only known afterwards.
 *      For global procedures BODY or SPEC is backpatched, but not GI
 *      type. ALso for local procedures the type is not known.
 *      In all that cases the kind is adjusted afterwards.
 */
void
adj_kind (kind)
int kind;
{
    curunit -> u_flags |= kind;
}

/*
 * stub_spec in a body a stub can be specified and should be administrated
 *      as such
 *      Afterwards it is compared with the parent names list and they
 *      should be equal.
 */
stub_spec (stubname, flag)
char *stubname;
int flag;
{
    char stname [FNAMESIZE];
    
    if (flag & SU)
    {
	p_curstlist -> ul_next = (struct unode_list *)
				mem_for(sizeof (struct unode_list));
	p_curstlist = p_curstlist -> ul_next;
	PRINTF ("stubspec %s alloc ul %x\n", stubname, p_curstlist);
	p_curstlist -> ul_next = NULL;
        strncpy (stname, curunit -> u_name, FNAMESIZE);
        strcat (stname, ".");
	strcat (stname, stubname);
	p_curstlist -> ul_node = give_unptr (stname, flag);
    }
}

/*
 * full_stub_name : generate for stubs the selected component name
 */
char *
full_stub_name (uname)
char *uname;
{
    static char st_name[FNAMESIZE];
    
    if (curunit -> u_spec)
    {
        strncpy (st_name, curunit -> u_spec -> u_name, FNAMESIZE);
        strcat (st_name, ".");
        strcat (st_name, uname);
    }
    else
        strncpy (st_name, uname, FNAMESIZE);

    return st_name;
}

/*
 * add_sfunit : builds a list of sourcefile units comparable to the unodelist
 */
add_sfunit (sf_name)
char *sf_name;
{
    static char prev_name[FNAMESIZE] = {0};
    register struct sf_node *p_sf;
        
    p_sf_list -> sl_next = (struct sf_list *)
                                mem_for (sizeof (struct sf_list));
    p_sf_list = p_sf_list -> sl_next;
    p_sf_list -> sl_node = (struct sf_node *)
                                mem_for (sizeof (struct sf_node));
    p_sf = p_sf_list -> sl_node;
    strncpy (p_sf -> sf_name, sf_name, FNAMESIZE);
    strncpy (prev_name, sf_name, FNAMESIZE);
    PRINTF ("alloc sl %x sf %x name %s\n", p_sf_list, p_sf, sf_name);
    p_sf_list -> sl_next = NULL;
    p_sf -> sf_dofirst .sl_next = NULL;
    p_sf -> sf_flags = COMP_VALID;    
}

/*
 * mem_for allocates memory or quits
 */
char *
mem_for (size)
int size;
{
    char *p;

    p = malloc (size);
    if (p == NULL) exit (1);
    return p;
}

/* DEBUGGING ROUTINES */

/*
 * print_structuur prints the complete structure list
 */

print_structuur ()
{
    p_lijst (unit_list .ul_next, "F:", 2);
}

/*
 * p_lijst prints the list of the argument
 */
p_lijst (ulp, prefix, offset)
struct unode_list *ulp;
char *prefix;
int offset;
{
    int i;
    struct unode *up;

    for (;ulp; ulp = ulp -> ul_next)
    {
	for (i = 0 ;i < offset; i++) putc (' ', stderr);
	
	up = ulp -> ul_node;
        prnt_unode (up, prefix, offset);
    }
}

prnt_unode (up, prefix, offset)
struct unode *up;
char *prefix;
int offset;
{
	fprintf (stderr, "%s up -> flags %x", prefix,
	        up -> u_flags);
	fprintf (stderr, "---%s\n", up -> u_name);
	if (up -> u_flags & VISITED)
	{
	    fprintf (stderr, "has been visited\n");
	    return;
	}
	up -> u_flags |= VISITED;
	/*
	fprintf (stderr, "ulp %x up %x context %x stubs %x\n",
	       ulp, up, up -> u_context .ul_next,  up -> u_stubs .ul_next);
	*/
	if (up -> u_context .ul_next)
	    p_lijst (up -> u_context .ul_next, "context", offset + 2);
	if (up -> u_stubs .ul_next)
	    p_lijst (up -> u_stubs .ul_next, "stubnms", offset + 2);
        if (up -> u_spec)	
            prnt_unode (up -> u_spec, "specification", offset+2);
	up -> u_flags &= ~VISITED;
}
