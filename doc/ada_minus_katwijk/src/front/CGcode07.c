
/*
 * (c) copyright 1986, 1987, 1988, Delft University of Technology
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

#include	"includes.h"


/*
 *	allocate space, if we have to for object x
 *	initialize both
 *	the fixed stack/ global part of the variable,
 *	i.e. the pointer to the object
 *	the current stacktop
 */
void	allocate (x)
ac	x;
{
	static char datatext [AIDL];
	int	size;
	
	ASSERT (x != NULL && g_d (x) == XOBJECT, (":allocate:1"));

	size = g_OBJ_alloc (x) == GLOBAL ?
		   obj_size (g_objtype (g_desc (x))):
		   TADDRSIZE;

 	if (g_OBJ_alloc (x) == GLOBDYN && g_OBJ_descoff (x) != 0) {
	   setdatalab (x, datatext);
	   OUT (("&%d	%d	%s\n", ICCOMM, 2 * TADDRSIZE, datatext));
	   return;
	}

	if (g_OBJ_alloc (x) == GLOBAL || g_OBJ_alloc (x) == GLOBDYN) {
	   setdatalab (x, datatext);
	   OUT (("&%d	%d	%s\n",ICCOMM,  size, datatext));
	}

	if (g_OBJ_descoff (x) != 0)  /* The weirdos */
	   return;

	if (g_OBJ_alloc (x) == FIXDYN || g_OBJ_alloc (x) == GLOBDYN) {
	   new_expr ();
	      ASS_MIN (ADDRESS);
		 REG (SP_DYN, ADDRESS);
		 AND (ADDRESS);
		    PLUS (ADDRESS);
	               desc_address (g_objtype (g_desc (x)), VD_SIZE);
		       ICON (1, LONG, "");
/*
 *	TWO'S COMPLEMENT OF 1
 */
		    ICON (-2, LONG, "");

	   new_expr ();	
	      ASSIGN (ADDRESS);
		if (g_OBJ_alloc (x) == FIXDYN)
		   LOC_OBJECT (curr_level, g_OBJ_offset (x), ADDRESS);
		else
		   GLOB_OBJECT (0, x, ADDRESS);
		REG (SP_DYN, ADDRESS);

		TESTBYTE (0);
		sav_stack (x);
	}
}

void	list_name (node)
ac	node;
{
	ASSERT (node != NULL && g_d (node) == XOBJECT, ("list_name:1"));

	switch (g_flags (g_desc (node))) {
	   case KVAR:
	   case KCONST:
		OUT ((")~%s = -%d.\n", g_tag (node), g_OBJ_offset (node)));
		break;

	   case KNUMB:
	   case KCOMP:
	   case KDISCR:
		break;

	   case INMODE:
	   case OUTMODE:
	   case INOUTMODE:
		OUT ((")~%s = %d.\n", g_tag (node), g_OBJ_offset (node)));
		break;
	}
}

