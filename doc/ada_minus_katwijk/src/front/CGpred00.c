#
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
 * For further information contact
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 */

bool	known_descriptor (x)
ac	x;
{
	ASSERT (x != NULL, ("known_descriptor:1"));

	if (is_ncomp (x))
	   return FALSE;
	return TRUE;
}

bool	isdiscrdepexp (expp)
ac	expp;
{
	ac	p;

	ASSERT (( expp != NULL && g_d (expp) == XEXP), ("isdiscrdepexp"));
	/*
	 * assumes correctness of expression
	 * if it indeed contains a formal discriminant!
	 */
	p = g_primary (expp);

	/*
	 * if a discriminant is directly referenced as a primary,
	 * i.e. not selected,
	 * it must be inside the corresponding recordtype definition.
	 * In record aggregates and discriminant constraints
	 * discriminants in choices are not considered as expressions.
	 */
	if (g_d (p) != XNAME)
	   return FALSE;

	p = g_fentity (p);
	if (p == NULL)
	   return FALSE;

	if (g_d (p) != XOBJECT || kind_of (g_desc (p)) != KDISCR)
	   return FALSE;

	return TRUE;
}	/* end of isdiscrdepexp */

bool	is_table (agg)
ac	agg;
{
	return is_static (agg);
}

bool	is_composite (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = root_type (x);
	return g_d (x) == XRECTYPE || g_d (x) == XARRAYTYPE;
}

bool	othersarray (agg)
ac	agg;
{
	/* the front end will make a filter for all cases	*/
	/* except for the "others" case, so:			*/
	return g_d (g_aggtype (agg)) != XFILTER;
}

bool	is_ncomp (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;
	x = basefilter (x);

	switch (g_d (x)) {
	   case XARRAYTYPE:
	      return TRUE;

	   case XRECTYPE:
	      return g_REC_forms (x) != 0;

	   case XACCTYPE:
	      return g_ACC_nform (x) != 0;

	   case XINCOMPLETE:
	      return g_fidiscr (x) != 0;

	   case XPRIVTYPE:
	      return g_fpdiscr (x) != 0;

	   default:
	      return FALSE;
	}
}

bool	disc_dep (agg)
ac	agg;
{
	ac	cp;
	int	flags;

	/* just for a test:
	 */
	return FALSE;

	FORALL (cp, g_fcompas (agg))
	   flags |= g_flags (g_compexpr (cp));

	return flags & CSTREC;
}

bool	is_integer (t)
ac	t;
{
	while (TRUE) {
	   if (g_d (t) == XNEWTYPE)
	      t = g_old_type (t);
	   else
	   if (g_d (t) != XINTERNAL)
	      return FALSE;
	   else
	   switch (g_ind (t)) {
	      case I_UNIV:
	      case I_SHORT:
	      case I_LONG:
	      case I_INTEGER:
		 return TRUE;

	      default:
		 return FALSE;
	   }
	}
}

/*
bool	is_scalar (x)
ac	x;
{
	ac	t;

	t = root_type (x);
	return is_integer (t) || g_d (t) == XENUMTYPE;
}
*/

bool	pcc_float (x)
ac	x;
{
	return (pcc_type_of (x) == FLOAT);

}
bool	is_small (x)
ac	x;
{
	int	temp;

	ASSERT (x != NULL, ("is_small:1"));

	switch (g_d (x)) {
	   case XEXP:
		x = root_type (g_exptype (x));
		break;

	   case XOBJECT:
		x = root_type (g_objtype (g_desc (x)));
		break;

	   default:
		x = root_type (x);
		break;
	}

	ASSERT (x != NULL, ("is_small:2"));

	if (g_d (x) == XACCTYPE)
	   return TRUE;

	temp = (x == std_real || is_scalar (x) || x == notype);
	return temp;
}

/*
bool	is_stringlit (x)
ac	x;
{
	if (g_d (x) == XLITERAL
		    && g_val (x) -> litkind == S_STRINGLIT)
			return TRUE;
	return FALSE;
}
*/
bool	is_nulllit (x)
ac	x;
{
	if (g_d (x) == XLITERAL
		   && g_val (x) -> litkind == S_NULLLIT)
	   return TRUE;
	return FALSE;
}

bool	is_reallit (x)
ac	x;
{
	if (g_d (x) == XLITERAL &&
		   g_val (x) -> litkind == S_REALLIT)
	    return TRUE;
	return FALSE;
}

/*
bool	is_basetype (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = basefilter (x);
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XACCTYPE:
	   case XENUMTYPE:
	   case XINCOMPLETE:
	   case XPRIVTYPE:
	   case XARRAYTYPE:
	   case XRECTYPE:
	   case XINTERNAL:
	   case XNEWTYPE:
	   case XTASKTYPE:
	      return TRUE;

	   default:
	      return FALSE;
	}
}
*/
bool	is_typemark (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XPRIVTYPE:
	   case XINCOMPLETE:
	   case XSUBTYPE:
	      return TRUE;

	   default:
	      return is_basetype (x);
	}
}

bool	isoptfilter (tp)
ac	tp;
{
	if (tp == NULL)
	   return FALSE;

	return is_typemark (tp) || g_d (tp) == XFILTER ;
}	/* end of isoptfilter */

bool	is_recagg (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	ASSERT (g_d (x) == XAGGREGATE, ("is_recagg"));

	x = root_type (g_aggtype (x));
	if (x == NULL)
	   return FALSE;

	return g_d (x) == XRECTYPE;
}

bool	has_call_block (x)
ac	x;
{
	ac	pt;

	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XSUBTYPE)
	   return FALSE;

	pt = g_parenttype (x);

	ASSERT (g_d (pt) == XFILTER, ("has_call_block"));

	return g_FLT_vdoffset (pt) != 0;
}

bool	is_lev_one (x)
ac	x;
{
	ASSERT (x != NULL, ("is_lev_one"));
	ASSERT (g_d (x) == XSUB, ("is_lev_one"));

	if (is_dollarname (g_tag (x)))
	   return TRUE;

	if (is_std_fn (x) && lun_of (x) == STAN_LUN)
	   return TRUE;

	if (level_of (x) == 0)		/* SUBnode, remember !! */
	   return TRUE;

	return FALSE;
}

bool	is_dollarname (x)
char	*x;
{
	return x != NULL && x [0] == '$';
}

/*
 *	For handling unconstrained record objects
 *	some functions are required. These will
 *	be changed in the next version
 */
bool	is_unco (x)
ac	x;
{
	ac	t;

	ASSERT (x != NULL, ("is_unco"));

	t = get_type (x);

	if (g_d (t) != XRECTYPE)
	   return FALSE;

	return unco_value (t);
}

bool	unco_value (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = basefilter (x);
	switch (g_d (x)) {
	case XARRAYTYPE:
		return TRUE;
	case XRECTYPE:
		return g_REC_forms (x) != 0;
	case XACCTYPE:
/*		return x -> ACC_nform != 0;	*/	return FALSE;
	default:
		return FALSE;
	}
}

/*
 *	Determine those cases for which an allocator does not
 *	need to create a descriptor for the object to be allocated
 */
bool	alloc_1_value (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = basefilter (x);

	switch (g_d (x)) {
	   case XARRAYTYPE:
	      return FALSE;

	   case XRECTYPE:
	      return g_REC_forms (x) == 0;

	   default:
	      return TRUE;
	}
}

bool	is_typconv (x)
ac	x;
{
	ASSERT (x != NULL,("is_typconv : null argument"));
	ASSERT (g_d (x) == XEXP, ("is_typconv: not an expression argument"));

	return g_d (g_primary (x)) == XTYPECONV;
}

/*
 *	Check (if possible now, otherwise in runtime,
 *	a range constraint
 */
bool	check_needed (x, y)
ac	x,
	y;
{
	ac	t1,
		t2;
/*
 *	If the range is a range of a basetype, no further check
 */
	if (is_basetype (y))
	   return FALSE;

	ASSERT (g_d (x) == XSUBTYPE, ("check_needed:1"));
	t1 = g_parenttype (x);
	if (t1 == NULL)
	   return TRUE;

	ASSERT (g_d (t1) == XFILTER, ("check_needed:2"));

	t1 = g_frang_exp (g_constraint (t1));
	if (t1 == NULL)
	   return TRUE;

	t2 = g_next (t1);
	if (!is_static (t1) || !is_static (t2))
	   return TRUE;

	if (!is_static (y))
	   return TRUE;

	return !(loval (y) <= getvalue (t1) &&
	        getvalue (t1) <= getvalue (t2) &&
	        getvalue (t2) <= hival (y));
}

/*
 *	Does the initailizing expression has to
 *	provide the constraints?
 */
bool	expr_provides_constraints (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return FALSE;

	   switch (g_d (x)) {
	      case XARRAYTYPE:
	         return TRUE;

	      case XINCOMPLETE:
	         x = g_complete (x);
	         break;

	      case XPRIVTYPE:
	         x = g_impl (x);
	         break;

	      case XRECTYPE:
	         return g_REC_forms (x) != 0;
	
	      default:
	         return FALSE;
	   }
	}
}


