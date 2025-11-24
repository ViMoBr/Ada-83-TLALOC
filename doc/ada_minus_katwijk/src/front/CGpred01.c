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
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

static	bool	is_anytype	();
static	bool	index_fits	();
static	bool	no_indexcheck	();
static	bool	is_subtypeof	();

/*
 * Name:	is_binary
 *
 * Abstract:	
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

bool	is_binary (node)
ac	node;
{
	if (node == NULL)
	   return FALSE;

	ASSERT (g_d (node) == XCALL, ("is_binary"));

	if (g_fact (node) == NULL)
	   return FALSE;

	if (g_next (g_fact (node)) == NULL)
	   return FALSE;

	if (g_next (g_next (g_fact (node))) != NULL)
	   return FALSE;

	return TRUE;		/* Let's hope it		*/
}

/*
 * Name:	is_inline
 *
 * Abstract:	
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
bool	is_inline (node)
ac	node;
{
	ac	ass,
		fn;

	if (node == NULL)
	   return FALSE;

	if (g_next (node) == NULL)
	   return FALSE;

	fn = g_fentity (g_next (node));

	if (!is_std_fn (fn) || lun_of (fn) != STAN_LUN)
	   return FALSE;
	
	if (!is_small (g_types (node)))
	   return FALSE;

	FORALL (ass, g_fact (node)) {
	   if (!is_small (g_nexp (ass)))
	      return FALSE;
	}

	/* let it be ... */
	return TRUE;
}


/*
 * Name:		no_paramcheck
 *
 * Abstract:	
 *
 * Description:	
 *			target is left, source is right,
 *			just as an assign !
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
static
bool	is_anytype (e)
ac	e;
{
	if (g_d (e) == XINTERNAL)
	   switch (g_ind (e)) {
	      case I_UNIV:
	      case I_ANY_TYPE:
	      case I_ANY_ACCESS_TYPE:
	      case I_ANY_STRING_TYPE:
	      case I_ENUM:
	      case I_ANY_BOOL_VECTOR:
	      case I_ANY_SCALAR_VECTOR:
		 return TRUE;

	      default:
		 return FALSE;
	   }

	return FALSE;
}

bool	no_paramcheck (left, right)
ac	left,
	right;
{
	left = get_type (left);
	right= get_type (right);

	if (left == right)
	   return TRUE;

	if (is_anytype (left))
	   return TRUE;		/* for standard operators */

	if (root_type (left))
	   return TRUE;

	if (g_d (root_type (left)) == XARRAYTYPE)
	   return eq_arrays (left, right);

	if (g_d (root_type (left)) == XRECTYPE)
	   return eq_records (left, right);

	return FALSE;	/* you never know, do you */
}

/*
 *	Does x need constraining prior to actual use ?
 *	Used in some cases where a choice can be made to
 *	obtain a result descriptor
 */
bool	is_unc (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XARRAYTYPE:
	      return TRUE;

	   case XRECTYPE:
	      return g_ffield (x) != NULL && is_discr (g_ffield (x));

	   case XINCOMPLETE:
	      return g_fidiscr (x) != NULL;

	   case XPRIVTYPE:
	      return g_fpdiscr (x) != NULL;

	   default:
	      return FALSE;
	}
}

/*
 *	assignment check required ?
 */
bool	as_chk (left, right)
ac	left,
	right;
{
	if (left == NULL || right == NULL)
	   return FALSE;

	if (is_unco (left))
	   return TRUE;

	if (is_unc (left))
	   return FALSE;

	if (is_subtypeof (get_type (right), get_type (left)))
	   return TRUE;

	return FALSE;
}

/*
 * Name:		comp_ranges
 *
 * Abstract:		Check the values of range source
 *			to be within values of range target
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

bool	comp_ranges (source, target)
ac	source,
	target;
{
	ac	r;

	ASSERT (target != NULL, ("comp_ranges has NULL target"));
	ASSERT (source != NULL, ("comp_ranges has NULL source"));
/*	fprintf (stderr, "comp_ranges, %X %X %d %d (line %d)\n",
	         source,
	         target,
	         g_d (source),
	         g_d (target),
	         g_lineno (source));
 */

	if (is_basetype (target))
	   return TRUE;

	if (is_subtypeof (source, target))
	   return TRUE;

	target = basefilter (target);

	if (g_d (target) == XINTERNAL)
	   return TRUE;

	ASSERT (g_d (target) == XFILTER, ("comp_ranges:1"));

	r = g_constraint (target);

	if (is_static (source) && is_static (target))
	   return
	      is_inrange (loval (source), r) &&
	      is_inrange (hival (source), r) ;

	return FALSE;

}

/*
 * Name:		eq_arrays
 *
 * Abstract:	
 *
 * Description:	
 *
 * Externals:		local statics are:
 *			index_fits
 *			no_indexcheck
 *			is_subtypeof
 * Calls:	
 *
 * Macros:	
 *
 */
static
bool	index_fits (t1, f)
ac	t1,
	f;
{
	ASSERT (t1 != NULL && f != NULL, ("index_fits"));

	if (g_d (f) == XSUBTYPE)
	   return index_fits (t1, g_parenttype (f));

	ASSERT (g_d (f) == XFILTER, ("index_fits:1"));
	f = g_constraint (f);

	ASSERT (f != NULL && g_d (f) == XINDEXCONS, ("index_fits:2"));
	f = g_frange (f);

	ASSERT (f != NULL && g_d (f) == XRANGE, ("index_fits:3"));
	if (g_frang_exp (f) != NULL)
	   return FALSE;	/* for the time being	*/

	return is_subtypeof (t1, g_rangetype (f));
}

static
bool	no_indexcheck (index_expr, array_type)
ac	index_expr,
	array_type;
{
	ac	t1;

	ASSERT (index_expr != NULL && array_type != NULL, ("no_indexcheck"));
	t1 = get_type (index_expr);

	ASSERT (t1 != NULL, ("no_index:2"));

	if (g_d (array_type) == XARRAYTYPE)	/* formal string (...) */
	   return FALSE;

	ASSERT (g_d (array_type) == XSUBTYPE,
				("no_index:3 %d\n", g_d (array_type)));
	return index_fits (t1, g_parenttype (array_type));
}

static
bool	is_subtypeof (right, left)
ac	left,
	right;
{
	while (TRUE) {
	   if (right == left)
	      return TRUE;

	   if (is_basetype (right))	/* too far	*/
	      return FALSE;

	   switch (g_d (right)) {
	      case XSUBTYPE:
		 right = g_parenttype (right);
	         break;

	      case XFILTER:
		 right = g_filtype (right);
	         break;

	      default:
		 return FALSE;
	   }
	}
}

bool	eq_arrays (left, right)
ac	left,
	right;
{
	/* keep it simple */
	if (hasstatsize (left))
	   return obj_size (left) == obj_size (right);

	if (is_subtypeof (right, left))
	   return TRUE;

	return FALSE;
}

/*
 * Name:	eq_records
 *
 * Abstract:	
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

bool	eq_records (left, right)
ac	left,
	right;
{
	return FALSE;	/* keep it simple for the time being */
}

/*
 *	Is x addressed through a callblock
 */
bool	throughcallblock (x)
ac	x;
{
	return g_d (x) == XSUBTYPE &&
	       g_d (g_parenttype (x)) == XFILTER &&
	       g_FLT_vdoffset (g_parenttype (x)) != 0;
}

/*
 *	Has x a compile-time computational size
 */
bool	hasstatsize (t)
ac	t;
{
	ac	bft;

	if (t == NULL)
	   return FALSE;

	bft = basefilter (t);

	if (g_d (bft) == XARRAYTYPE)
	   return FALSE;


	if (g_d (bft) == XRECTYPE && g_REC_forms (bft) > 0)
	   return FALSE;

	return (getflags (bft) & (DYNREC|CSTREC)) == 0;
}

/*
 *	Does the aggregate  agg has discriminants in its basetype
 */
bool	nodescr_aggr (agg)
ac	agg;
{
	ac	type;

	ASSERT (agg != NULL && g_d (agg) == XAGGREGATE,
	                 ("nodescr_aggr:1"));

	type = root_type (g_aggtype (agg));
	if (type == NULL)
	   return TRUE;
	if (g_ffield (type) == NULL)
	   return TRUE;
	return !is_discr (g_ffield (type));
}

bool	unco_agg (exp)
ac	exp;
{
	ac	agg;

	ASSERT (exp != NULL && g_d (exp) == XEXP,
	         ("unco_agg:1"));
	agg = g_primary (exp);

	if (g_d (agg) != XAGGREGATE)
	   return FALSE;

	if (g_d (g_aggtype (agg)) == XARRAYTYPE && 
	     g_AGG_Doff (agg) == 0)
		return TRUE;

	return FALSE;
}
	
