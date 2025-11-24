
/*
 * (c) copyright 1986, Delft University of Technology
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
 *      Jan van Katwijk
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 *XXX	LOW LEVEL TREE ROUTINES
 */

ac	list_element (x, i)
ac	x;
int	i;
{
	while ((i = i - 2) > 0)
	   x = g_next (x);

	return x;
}

int	filkind (node)
ac	node;
{
	ASSERT (node != NULL, ("filkind:1"));

 	if (g_d (node) == XSUBTYPE)
           node = g_parenttype (node); /* This must be the filter. do not
					   go up in the chain
					 */

	ASSERT (g_d (node) == XFILTER, ("filkind: %d\\n", g_d (node)));

	if (g_FLT_vdoffset (node) != 0)
	   return CB;

	switch (g_d (root_type (g_filtype (node)))) {
	   case XARRAYTYPE:
		return VD_ARR;

	   case XRECTYPE:
	   case XINCOMPLETE:
		return VD_REC;

	   case XACCTYPE:
		return CD_ACC;

	   default:
	       return CD_BIT_S;
	}
}

int	stor_class (node)
ac	node;
{
	ASSERT (node != NULL, ("stor_class:0"));

	while (TRUE) {

	   switch (g_d (node)) {
	      case XFILTER:
	           return  g_FLT_alloc (node);

	      case XSUBBODY:
                   node = g_specif (node);
	           break;

	      case XSUBTYPE:
	           node = g_parenttype (node);
	           break;

	      case XTASKTYPE:
	           return g_TSKT_alloc (node);

	      case XSUB:
	           return g_SUBS_alloc (node);
	   
	      case XRECTYPE:
	           return g_REC_alloc (node);

	      case XARRAYTYPE:
	           return g_ARR_alloc (node);

	      case XACCTYPE:
	           return g_ACC_alloc (node);

	      case XOBJECT:
	           return g_OBJ_alloc (node);

	      case XAGGREGATE:
	           node = g_aggtype (node);
	           break;

	      case XNEWTYPE:
		   node = g_old_type (node);
		   break;

	      case XALLOCATOR:
	           return HEAP;

	      case XEXCEPTION:
	           return GLOBAL;

	      case XRENOBJ:
	           return g_ROBJ_alloc (node);

	      case XENUMTYPE:
	           return GLOBAL;

	      case XINTERNAL:
	           return GLOBAL;

	      case XPRIVTYPE:
	           node = g_impl (node);
		   break;

	      case XINCOMPLETE:
	           node = g_complete (node);
	           break;


	      DEFAULT (("stor_class: %d\\n", g_d (node)));
	   }

	}

}

int	off (node)
ac	node;
{
	ASSERT (node != NULL, ("off"));
	
	while (TRUE) {
	   switch (g_d (node)) {
	      case XTASKTYPE:
		 return g_TSKT_offset (node);

	      case XSUBTYPE:
	         node = g_parenttype (node);
	         break;

	      case XFILTER:
	         return g_FLT_offset (node);

	      case XRECTYPE:
	         return g_REC_offset (node);

	      case XARRAYTYPE:
	         return g_ARR_offset (node);

	      case XACCTYPE:
	         return g_ACC_offset (node);

	      case XOBJECT:
	         return g_OBJ_offset (node);

	      case XAGGREGATE:
	         if (g_AGG_Doff (node) == 0) {
	            node = g_aggtype (node);
	            break;
	         }
	         else
	            return g_AGG_Doff (node);

	      case XALLOCATOR:
	         if (g_ALLO_Doff (node) == 0) {
	            node = g_obtype (node);
	            break;
	         }
	         else
	            return g_ALLO_Doff (node);

	      case XEXCEPTION:
		 return 0;

	      case XRENOBJ:
	         return g_ROBJ_offset (node);

	      case XENUMTYPE:
		 return 0;		/* always global */

	      case XSUB:
	         return g_SUBS_offset (node);

	      case XPRIVTYPE:
	         node = g_impl (node);
	         break;

	      case XINCOMPLETE:
	         node = g_complete (node);
	         break;

	      DEFAULT (("ERROR in off: %d", g_d (node)));
	   }
	}
}

int	level_of (x)
ac	x;
{
	ASSERT (x != NULL, ("level_of:1"));

	while (TRUE) {
	   if (x == NULL)
	      return 0;

	   if (!is_enclosed (x))
	      x = curr_proc;

	   switch (g_d (x)) {
	      case XSUBBODY:
	         return g_SBB_level (x) & 0377;

	      case XTASKBODY:
	         return g_TSB_level (x) & 0377;

	      default:
	         x = g_enclunit (x);
	   }
	}
}

ac	surrounding_block (x)
ac	x;
{
	while (TRUE) {
	   if (x == std)
	      return x;

	   ASSERT (x != NULL, ("surrounding_block:1"));
	   switch (g_d (x)) {
	      case XBLOCK:
	      case XSUBBODY:
	      case XTASKBODY:
		 return x;

	      default:
	         x = g_enclunit (x);
	   }
	}
}

int	get_stacktop (x)
ac	x;
{
	ASSERT (x != NULL, ("het_stacktop:1"));

	switch (g_d (x)) {
	   case XBLOCK:
	      return g_BLK_SToff (x);

	   case XSUBBODY:
	   case XTASKBODY:
	      return SToff_BASE;

	   DEFAULT (("get_stacktop: %d", g_d (x)));
	}
}

int	cboffset (x)
ac	x;
{
	x = basefilter (x);

	ASSERT (x != NULL && g_d (x) == XFILTER, ("cboffset:0"));

	return g_FLT_vdoffset (x);
}

bool	has_Voff (x)
ac	x;
{
	return Voff (x) != 0;
}

MAXADDR	Voff (x)
ac	x;
{
	switch (g_d (x)) {
	   case XCALL:
		return g_CALL_Voff (x);

	   case XSCC :
	        return g_SCC_Voff (x);

	   DEFAULT (("get_Voff: wrong node"));
	}
}

bool	has_Doff (x)
ac	x;
{
	return Doff (x) != 0;
}

MAXADDR	Doff (x)
ac	x;
{
	switch (g_d (x)) {
	   case XCALL:
	      return g_CALL_Doff (x);

	   case XALL:
	      return g_ALL_Doff (x);

	   case XSLICE:
	      return g_SLI_Doff (x);

	   case XATTRIBUTE:
	      return g_ATTR_Doff (x);

	   DEFAULT (("get_Doff: wrong node."));
	}
}

ac	get_type (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return NULL;

	   switch (g_d (x)) {
	      case XEXP:
	         x = g_exptype (x);
	         break;

	      case XLITERAL:
	         x = g_littype (x);
	         break;

	      case XOBJECT:
	         x = g_objtype (g_desc (x));
	         break;

	      case XOBJDESC:
	         x = g_objtype (x);
	         break;

	      case XRENOBJ:
	         x = g_rentype (x);
	         break;

	      case XAGGREGATE:
	         x = g_aggtype (x);
	         break;

	      case XALLOCATOR:
	         x = g_altype (x);
	         break;

	      case XNAME:
	      case XALL:
	      case XCALL:
	      case XATTRIBUTE:
	      case XSLICE:
	      case XSELECT:
	      case XENTRYCALL:
	      case XINDEXING:
	         x = g_types (x);
	         break;

	      case XENTRY:
		 return x;

	      case XSUBTYPE:
	      case XRECTYPE:
	      case XARRAYTYPE:
	      case XACCTYPE:
	      case XENUMTYPE:
	      case XINTERNAL:
	      case XTASKTYPE:
		 return x;

	      case XNEWTYPE:
	         x = g_old_type (x);
	         break;

	      case XPRIVTYPE:
	         x = g_impl (x);
	         break;

	      case XINCOMPLETE:
	         x = g_complete (x);
	         break;

	      DEFAULT (("get_type of %d", g_d (x)));
	   }
	}
}

ac	get_discr (x, i)
ac	x;
int	i;
{
	while (TRUE) {
	   if (x == NULL)	/* may happen when we reach       */
	      return NULL;	/* an empty list of discriminants */

	   switch (g_d (x)) {
	      case XRECTYPE:
		 if (g_type_spec (x) != NULL) {
	            x = g_type_spec (x);
	            break;
	         }
		 x = g_ffield (x);
		 break;

	      case XPRIVTYPE:
		 x = g_fpdiscr (x);
		 break;

	      case XINCOMPLETE:
		 x = g_fidiscr (x);
		 break;

	      case XACCTYPE:
		 if (g_type_spec (x) != NULL) {
	            x = g_type_spec (x);
	            break;
	         }
	         x = g_actype (x);
	         break;

	      case XNEWTYPE:
		if (g_type_spec (x) != NULL) {
	           x = g_type_spec (x);
	           break;
	        }
	       x = g_old_type (x);
	       break;

	      /* Special case, we reached the discriminants	*/
	      case XOBJECT:
	         while (--i > 0 && x != NULL)
	            x = g_next (x);

	         return x;

	      DEFAULT (("get_discr: illegal type %d", g_d (x)));
	   }
	}

}

ac	root_type (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
              return NULL;

	   switch (g_d (t)) {
	      case XSUBTYPE:
	         t = g_parenttype (t);
	         break;

	      case XRECTYPE:
	      case XARRAYTYPE:
	      case XACCTYPE:
	      case XENUMTYPE:
	      case XTASKTYPE:
	      case XINTERNAL:
	         return t;

	      case XFILTER:
	         t = g_filtype (t);
	         break;

	      case XPRIVTYPE:
	         t = g_impl (t);
	         break;

	      case XINCOMPLETE:
	         t = g_complete (t);
	         break;

	      case XNEWTYPE:
	         t = g_old_type (t);
	         break;

	      default:
	         return t;
	   }
	}
}

ac	base_subtype (tp)
ac	tp;
{
	while (TRUE) {
	   switch (g_d (tp)) {
	      case XSUBTYPE:
	         if (g_d (g_parenttype (tp)) == XFILTER)
	            return tp;

	         tp = g_parenttype (tp);
	         break;

	      case XPRIVTYPE:
	         tp = g_impl (tp);
	         break;

	      case XINCOMPLETE:
	         tp = g_complete (tp);
	         break;

	      case XNEWTYPE:
	         tp = g_old_type (tp);
	         break;

	      default:
		 return tp;
	   }
	}
}

ac	basefilter (tp)
ac	tp;
{
	while (TRUE) {
	   if (tp == NULL)
	      return NULL;

	   switch (g_d (tp)) {
	      case XSUBTYPE:
	         tp = g_parenttype (tp);
	         break;

	      case XPRIVTYPE:
	         tp = g_impl (tp);
	         break;

	      case XINCOMPLETE:
		 if (g_complete (tp) == NULL)
		    return tp;

	         tp = g_complete (tp);
	         break;

	      case XNEWTYPE:
	         tp = g_old_type (tp);
	         break;

	      default:
		 return tp;
	   }
	}
}

ac	bf_type (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return NULL;

	   switch (g_d (x)) {
	      case XSUBTYPE:
	         x = g_parenttype (x);
	         break;

	      case XFILTER:
	         x = g_filtype (x);
	         break;

	      case XINCOMPLETE:
	      case XPRIVTYPE:
		 return x;

	      case XNEWTYPE:
	         x = g_old_type (x);
	         break;

	      default:
		 return x;
	   }
	}
}

/*
 *	given a discriminant y, get the order number
 *	(used in call blocks)
 */
int	disc_num (y)
ac	y;
{
	ac	x;
	int	i;

	ASSERT (y != NULL, ("disc_num:1"));
	ASSERT (g_d (y) == XOBJECT, ("disc_num:2"));

	x = g_enclunit (y);
	switch (g_d (x)) {
	   case XRECTYPE:
	      x = g_ffield (x);
	      break;

	   case XPRIVTYPE:
	      x = g_fpdiscr (x);
	      break;

	   case XINCOMPLETE:
	      x = g_fidiscr (x);
	      break;

	   case XNEWTYPE:
	      x = g_old_type (x);
	      break;

	   DEFAULT (("illegal discriminant %d", g_d (x)));
	}

	i = 0;
	while (x != NULL && x != y) {
	   x = g_next (x);
	   i++;
	}

	ASSERT (x != NULL, ("discriminant not found"));
	return i;
}

