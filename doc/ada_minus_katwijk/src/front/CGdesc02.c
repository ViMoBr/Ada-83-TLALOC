
/*
 * (c) copyright 1986,1987,1988, Delft University of Technology
 * Delft, The Netherlands
 *
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 *	For further information contact
 *	Jan van Katwijk
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"


/*
 *	Get the element descriptor of an arbitrary name construct
 */
void	elemdesc (x, v)
ac	x;
int	v;
{
	switch (g_d (x)) {
	   case XALL:
	/*
	 * An all node may have to be computed twice, once for
	 * the value once for the descriptor. Keep track of
	 * the descriptor once the value is computed
	 */
	      if (!has_Doff (x))
	         DESCRIPTOR (g_types (x));
	      else
	      {  if (not_yet_processed (x)) {	/* process and save	*/
	            COMMA ();	/* within an expression		*/
	               ASSIGN (P_LONG);
	                  LOC_OBJECT (curr_level, Doff (x), P_LONG);
	                  nelemcode (g_next (x), VAL, P_LONG);
	            set_yet_processed (x);
	          }
	         /* Now get the value			*/
	         DEREF (P_LONG);
	         if (v == VAL)
	            DEREF (P_LONG);
	            LOC_NAME (curr_level, Doff (x), P_LONG);
	      }
	      return;

	   case XCALL:
	   /* if Doff is specified, the call was alreay computed	*/
	      if (!has_Doff (x))
	         DESCRIPTOR (g_types (x));
	      else
	      {  if (v == VAL)
	            DEREF (P_LONG);
	         LOC_NAME (curr_level, Doff (x), P_LONG);
	      }
	      return;

	   case XATTRIBUTE:
	      if (!has_Doff (x))
	         DESCRIPTOR (g_types (x));
	      else
	         LOC_NAME (curr_level, Doff (x), P_LONG);
	      return;

	   case XSLICE:
	   /* always precomputed		*/
	      LOC_NAME (curr_level, Doff (x), P_LONG);
	      return;

	   case XNAME:
	      DESCRIPTOR (g_fentity (x));
	      return;

	   default:
	      if (throughcallblock (g_types (x))) {
	         PLUS (P_LONG);
	            elemdesc (g_next (x), VAL);
	            ICON (cboffset (g_types (x)), LONG, "");
	      }
	      else
	         DESCRIPTOR (g_types (x));
	      return;
	}
}

/*
 *	Get the descriptor of a string literal
 */
void	str_desc (e)
ac	e;
{
	ASSERT (e != NULL && g_d (e) == XEXP, ("str_lit:0"));

	if (g_ARR_alloc (root_type (g_exptype (e))) == GLOBAL)
	   LICON (g_LIT_Doff (g_primary (e)));
	else
	   LOC_NAME (curr_level, g_LIT_Doff (g_primary (e)), P_LONG);
}

/*
 *	a more or less intelligent routine for getting the
 *	address of a descriptor of any tree structure
 */
void	DESCRIPTOR (node)
ac	node;
{
	ASSERT (node != NULL, ("DESCRIPTOR:0"));

	while (TRUE) {
	   node = base_subtype (node);

	   switch (g_d (node)) {
	      case XEXP:
	         if (is_stringlit (g_primary (node))) {
		    str_desc (node);
	            return;
		 }
		 else
		    node = g_primary (node);
		 break;

	      case XPARENTHS:
		 node = g_subexpr (node);
		 break;

	      case XACCTYPE:
	      case XARRAYTYPE:
	      case XENUMTYPE:
	      case XSUBTYPE:
	      case XRECTYPE:
	      case XFILTER:
	      case XINTERNAL:
	      case XTASKTYPE:
	   	 desc_const (node);
	   	 return;

	      case XNEWTYPE:
	         node = g_old_type (node);
	         break;

	      case XLITERAL:
	         node = g_littype (node);
	         break;

	      case XENUMLIT:
	      case XCHARLIT:
	         node = g_enclunit (node);
	         break;

	      case XSCC:
	      case XIN:
	         node = std_boolean;
	         break;

	      case XNAME:
	      case XALL:
	      case XCALL:
	      case XATTRIBUTE:
	      case XSELECT:
	      case XINDEXING:
	      case XSLICE:
	      case XENTRYCALL:
	         elemdesc (node, VAL);
	         return;

	      case XAGGREGATE:
	   	 switch (g_d (root_type (g_aggtype (node)))) {
	   	    case XRECTYPE:
	   	        if (disc_dep (node))
	   	           PAR_OBJECT (curr_level, PAR_1, P_LONG);
	   	        else
	   	        if (nodescr_aggr (node))
	                      desc_const (root_type (g_aggtype (node)));
	   	        else
	                      LOC_NAME (curr_level, g_AGG_Doff (node), P_LONG);
	                   return;

	   	    case XNEWTYPE:
	   		ASSERT (FALSE, ("Aggregate over newtype"));
	                return;

	   	    case XARRAYTYPE:
	   		if (is_table (node)) {
	                      LICON (g_AGG_Doff (node));
	                      return;
	   	        }
	   	        if (g_AGG_Doff (node) != 0) /* own descr */
	                    LOC_NAME (curr_level, g_AGG_Doff (node), P_LONG);
	   		else
	                    desc_const (base_subtype (g_aggtype (node)));
	                return;
	         }
	         return;

	      case XOBJECT:
	   	 if (g_OBJ_alloc (node) == PARSTACK &&
	             g_OBJ_descoff (node) != 0) {
	   	    PAR_OBJECT (level_of (node) + 1,
	                          g_OBJ_descoff (node), P_LONG);
	            return;
	         }
	         else
	         if (g_OBJ_descoff (node) != 0) {
	            if (g_OBJ_alloc (node) == FIXDYN)
	               LOC_OBJECT (level_of (node), g_OBJ_descoff (node), P_LONG);
	            else
		       GLOB_OBJECT (sizeof (P_LONG), node, P_LONG);
		    return;
	         }
		 else
	   	 if (is_unco (node)) {
	              if (g_OBJ_alloc (node) == FIXUNCONS) {
	                 LOC_OBJECT (level_of (node), off (node), P_LONG);
	                 return;
	              }
	              else
	              {  GLOB_OBJECT (0, node, P_LONG);
	                 return;
	              }
	         }
	           /* otherwise:		*/
	         node = g_objtype (g_desc (node));
	         break;

	      case XRENOBJ:
	         node = g_rentype (node);
	         break;

	      case XALLOCATOR:
	         node = g_altype (node);
	         break;

	      case XTYPECONV:
	         if (is_unc (g_newtype (node)))
	            node = g_convexpr (node);
	         else
	            node = g_newtype (node);
	         break;

	      DEFAULT (("Getting a descriptor from %d ??\n", g_d (node)));
	   }
	}
}

/*
 *	In the doublet model, treatment of descriptors
 *	is separate from treatment of values.
 *	In some cases, see literature, the descriptor
 *	depends on the value to be computed. This implies
 *	that the value (or a part of it) has to be computed
 *	before the descriptor can be accessed.
 *	The next routine makes descriptors addressable.
 */
void	mak_addressable (node)
ac	node;
{
	if (node == NULL)
	   return;

	while (g_d (node) == XEXP)
	   node = g_primary (node);

	if (g_d (node) == XALL) {
	   if (has_Doff (node) && not_yet_processed (node)) {
	      COMMA ();	/* only within expressions */
	      ASSIGN (P_LONG);
	         LOC_OBJECT (curr_level, Doff (node), P_LONG);
	         nelemcode (g_next (node), VAL, P_LONG);
	      set_yet_processed (node);
	   }
	}
}
