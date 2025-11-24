#
#/*                    predicates.c                          */
#

/*
 * (c) copyright 1986-1995, Delft University of Technology
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
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

static	bool	index_fits	();
static	bool	no_indexcheck	();
static	bool	is_subtypeof	();

/*
 *	is_... and has_... predicates
 */

bool	is_private_constant (t, x)
ac	t,
	x;
{
	ac	type1,
		type2;

	ASSERT (t != NULL && x != NULL, ("is_private_constant:1"));

	if (g_d (t) != XOBJECT)
	   return FALSE;

	type1 = g_objtype (g_desc (t));
	type2 = g_objtype (g_desc (x));

	if (type1 != type2)
	   return FALSE;

	if (g_d (type1) != XPRIVTYPE)
	   return FALSE;

	if (g_expr (g_desc (t)) == NULL &&
	    g_expr (g_desc (x)) != NULL)
	   return TRUE;

	return FALSE;
}

bool	is_local_private (t)
ac	t;
{
	if (t == NULL || g_d (t) != XPRIVTYPE)
	   return FALSE;

	if (env == NULL || g_enclunit (t) != env)
	   return FALSE;

	return TRUE;
}

bool	is_sizeable (x)
ac	x;
{
	if (g_d (x) == XOBJECT)
	   return TRUE;

	if (!is_type (x))
	   return FALSE;

	x = rootfilter (x);

	switch (g_d (x)) {
	   case XARRAYTYPE:
		return FALSE;

	   case XRECTYPE:
	        if (g_ffield (x) == NULL)
	           return TRUE;		/* NULL record	*/
	        if (!is_discr (g_ffield (x)))
	           return TRUE;		/* Ordinary record type */
	        if (g_expr (g_desc (g_ffield (x))) != NULL)
	           return TRUE;		/* Default constraint	*/
	        return FALSE;

	   default:
		return TRUE;
	}
}

bool	is_accesstype (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = base_type (x);
	return g_d (x) == XACCTYPE;
}

/*
 *	Has x equality and assignment?
 */

bool	has_eq_and_ass (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return FALSE;

	   switch (g_d (x)) {
	      case XGENPARTYPE:
	         if ((g_flags (x) & LIMIT) != LIMIT)
	            return TRUE;
	         FALSE;

	      case XPRIVTYPE:
		 if ((g_flags (x) & LIMIT) != LIMIT)
	            return TRUE;
		 if (in_spec (x))
		    return TRUE;
		 return FALSE;

	      case XENUMTYPE:
	      case XINTERNAL:
	      case XACCTYPE:
	         return TRUE;

	      case XINCOMPLETE:
	         x = g_complete (x);
	         break;

	      case XSUBTYPE:
	         x = g_parenttype (x);
	         break;

	      case XFILTER:
	         x = g_filtype (x);
	         break;

	      case XARRAYTYPE:
	         return g_flags (x) & HAS_ASSIGN;

	      case XRECTYPE:
	         return g_flags (x) & HAS_ASSIGN;

	      case XNEWTYPE:
	         x = g_old_type (x);
	         break;

	      case XTASKTYPE:
		 return FALSE;

	      default:
		if (x != type_of (x)) {
	           x = type_of (x);
		   break;
		}
		ASSERT (FALSE, ("type %d kwijt", g_d (x)));
	   }
	}
}

/*
 *	Is x an assignable object ?
 */
bool	is_assignable (x)
ac	x;
{
	return is_object (x) && has_eq_and_ass (type_of (x));
}

/*
 *	has the type t slicing as an allowable operation?
 */
bool	has_slicing (t)
ac	t;
{
	return get_slicetypes (t) != NULL;
}

/*
 *	does the type t allows selection?
 */
bool	has_selection (t)
ac	t;
{
	if (t == NULL)
	   return FALSE;

	t = base_type (t);

	switch (g_d (t)) {
	   case XRECTYPE:
	   case XTASKTYPE:
		return TRUE;

	   case XBLOCK:
	   case XSUBBODY:
	   case XTASKBODY:
	   case XPACKBODY:
	   case XSUB:
		return is_openscope (t);

	   case XPACKAGE:
		return !is_generic (t) || is_openscope (t);

	   default:
		return get_selecttype (t) != NULL;
	}
}

/*
 *	Does the type t allow indexing?
 */
bool	has_indexing (t)
ac	t;
{
	if (t == NULL)
	   return NULL;

	return get_arraytype (t) != NULL;
}

/*
 *	does the type t allows calling
 */
bool	has_calling (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return FALSE;

	   switch (g_d (t)) {
	      case XTRIPLE:
	      case XENTRY:
	      case XSUB:
	      case XRENSUB:
	      case XINHERIT:
		 return TRUE;

	      case XSUBTYPE:
	         t = g_parenttype (t);
	         break;

	      case XFILTER:
	         t = g_filtype (t);
	         break;

	      case XACCTYPE:
	         t = g_actype (t);
	         break;

	      default:
		 return FALSE;
	   }
	}
}

/*
 *	allows the type t an indexconstraint?
 */
bool	has_indexconstraint (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return FALSE;

	   switch (g_d (t)) {
	      case XARRAYTYPE:
	         return TRUE;

	      case XNEWTYPE:
	         t = g_old_type (t);
	         break;

	      case XACCTYPE:
	         t = g_actype (t);
	         break;

	      case XSUBTYPE:
	         t = g_parenttype (t);
		 if (t != NULL && g_d (t) == XFILTER)
		    return FALSE;
	         break;

	      default:
		return FALSE;
	   }
	}
}

/*
 *	allows the type t a discriminant constraint
 */
bool	has_discriminantconstraint (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return FALSE;

	   switch (g_d (t)) {
	      case XNEWTYPE:
	         t = g_old_type (t);
	         break;

	      case XRECTYPE:
	         return is_discr (g_ffield (t));

	      case XPRIVTYPE:
		 return g_fpdiscr (t) != NULL;
/*
		 if ((g_flags (t) & LIMIT) == LIMIT) {
		    if (!in_spec (t))
		       return FALSE;
		 }
	         t = g_impl (t);
	         break;
 */

	      case XINCOMPLETE:
	         return g_fidiscr (t) != NULL;

	      case XACCTYPE:
	         t = g_actype (t);
	         break;

	      default:
		 return FALSE;

	   }
	}
}

/*
 *	can the type t be considered to be a scalar
 */
bool	is_scalar (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return FALSE;

	   if (is_someinteger (t))
	      return TRUE;

	   switch (g_d (t)) {
	      case XINCOMPLETE:
	         t = g_complete (t);
	         break;

	      case XPRIVTYPE:
	          if (!in_spec (t))
	             return FALSE;

	          t = g_impl (t);
	          break;

	      case XSUBTYPE:
	         t = g_parenttype (t);
	         break;

	      case XFILTER:
	         t = g_filtype (t);
	         break;

	      case XNEWTYPE:
	         t = g_old_type (t);
	         break;

	      case XENUMTYPE:
	         return TRUE;

	      case XGENPARTYPE:
		 return g_genkind (t) == SCALARTYPE ||
		       g_genkind (t) == NEWINTTYPE;

	   default:
		return FALSE;
	   }
	}
}

/*
 *	Can the type t be considered a float
 */
bool is_float (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return FALSE;

	   if (t == std_real)
	      return TRUE;

	   switch (g_d (t)) {
	      case XSUBTYPE:
	         t = g_parenttype (t);
	         break;

	        case XFILTER:
	         t = g_filtype (t);
	         break;

	      case XINCOMPLETE:
	         t = g_complete (t);
	         break;

	      case XPRIVTYPE:
	         if (!in_spec (t))
	            return FALSE;
	         t = g_impl (t);
	         break;

	      case XNEWTYPE:
	         t = g_old_type (t);
	         break;

	      case XGENPARTYPE:
		 return g_genkind (t) == NEWFLOATTYPE;

	      default:
		 return FALSE;
	   }
	}
}

/*
 *	is the type t a numerical type
 */
bool	is_numerical (t)
ac	t;
{
	return is_someinteger (t) || is_float (t);
}

/*
 *	has the item t a type
 */
bool	has_type (t)
ac	t;
{
	switch (g_d (t)) {
	   case XENUMLIT:
	   case XCHARLIT:
	   case XOBJECT:
	   case XRENOBJ:
	   case XINHERIT:
/* these too
 */
	   case XACCEPT:
	   case XSUB:
	   case XRENSUB:
	      return TRUE;

	   default:
	      return FALSE;
	}
}

/*
 *	is t a type
 */
bool	is_type (t)
ac	t;
{
	if (t == NULL)
	   return FALSE;

	switch (g_d (t)) {
	   case XSUBTYPE:
	   case XFILTER:
	   case XGENPARTYPE:
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

/*
 *	is obj an object, according to LRM 3.2
 */

bool	is_object (obj)
ac	obj;
{
	int	t;

	while (TRUE) {
	   if (obj == NULL)
	      return FALSE;

	   switch (g_d (obj)) {
	      case XOBJECT:
	         t = kind_of (g_desc (obj));
	         return !(t == KNUMB || t == KCONST || t == INMODE);

	      case XNAME:
	         obj = g_fentity (obj);
	         break;

	      case XATTRIBUTE:
	      case XCALL:
	      case XENTRYCALL:
	         return FALSE;

	      case XALL:
	         return TRUE;

	      case XINDEXING:
	      case XSLICE:
	      case XSELECT:
	         obj = g_next (obj);
	         break;

	      case XRENOBJ:
	         obj = g_name (obj);
	         break;

	      default:
	         return FALSE;
	   }
	}
}

/*
 *	is f an enumeration literal (or character literal)
 */
bool	is_enumlit (f)
ac	f;
{
	if (g_d (f) == XENUMLIT)
	   return TRUE;

	return FALSE;
}

bool	is_charlit (f)
ac	f;
{
	return g_d (f) == XCHARLIT;
}

/*
 *	is f an enumeration type
 */
bool	is_entype (f)
ac	f;
{
	if (f == NULL)
	   return FALSE;

	while (g_d (f) == XNEWTYPE)
	   f = g_old_type (f);

	return f != NULL && g_d (f) == XENUMTYPE;
}

/*
 *	Is f to be considered a subroutine
 */
bool	is_sub (f)
ac	f;
{
	switch (g_d (f)) {
	   case XSUB:
	   case XRENSUB:
	   case XENTRY:
	   case XTRIPLE:
	   case XINHERIT:
	      return TRUE;

	   default:
	      return FALSE;
	}
}

/*
 *	is the type x a static type
 */
bool is_sttype (x)
ac	x;
{
	if (is_static (x))
	   return TRUE;

	if (g_d (x) == XNEWTYPE)
	   return is_sttype (g_old_type (x));

	return FALSE;
}

/*
 *	Can x be considered a function that can be called
 *	without parameters
 */
bool	is_paramless (x)
ac	x;
{
	ac	y;

	if (x == NULL || !is_sub (x))
	   return FALSE;

	FORALL (y, f_formal (x)) {
	   if (!has_expr (y))
	      return FALSE;
	}

	return TRUE;
}


/*
 *	is f the stringtype?
 *	Warning: incomplete implementation still
 */
bool	is_strtype (f)
ac	f;
{
	if (f == NULL)
	   return FALSE;

	f = base_type (f);
	while (g_d (f) == XNEWTYPE)
	   f = base_type (g_old_type (f));

	return f != NULL && g_d (f) == XARRAYTYPE;
}


/*
 *	is x an integer type
 */
bool	is_someinteger (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = base_type (x);
	if (x == std_integer || x == std_short || x == std_long)
	   return TRUE;

	if (x == std_univ)
	   return TRUE;

	if (g_d (x) == XNEWTYPE)
	   return g_mark (x) == NEWINTTYPE;

	if (g_d (x) == XGENPARTYPE)
	   return g_genkind (x) == NEWINTTYPE;

	return FALSE;
}

/*
 *	is x a bool vector
 */
bool	is_bool_vect (x)
ac	x;
{
	ac	t;

	t = get_arraytype (x);
	if (t == NULL)
	   return FALSE;

	if (g_next (g_findex (t)) != NULL)
	   return FALSE;
/*
	return is_someinteger (g_indextype (g_findex (t))) &&
               base_type (g_elemtype (t)) == std_boolean;
*/
	return base_type (g_elemtype (t)) == std_boolean;
}

/*
 *	is_sc_vector, is x a scalar vector (LRM ...)
 */
bool	is_sc_vector (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = base_type (x);
	/* actual universal type:	*/

	if (g_d (x) == XINTERNAL && g_ind (x) == I_ANY_STRING_TYPE)
	   return TRUE;

	x = get_arraytype (x);
	if (x == NULL)
	   return FALSE;

	if (g_next (g_findex (x)) != NULL)
	   return FALSE;

	return is_scalar (g_indextype (g_findex (x)));
}

/*
 *	is x reasonable as call
 */
bool	is_call (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XNAME)
	   return FALSE;

	if (!is_sub (g_fentity (x)))
	   return FALSE;	

	return TRUE;
}

/*
 *	is the component specification r an "others" choice?
 */
bool is_others (r)
ac	r;
{
	ASSERT (r != NULL, ("is_others:1"));
	ASSERT (g_d (r) == XRANGE, ("is_others:2"));

	return g_rangetype (r) == NULL && g_frang_exp (r) == NULL;
}

/*
 *	is_derived, check to see whether x is an inherited something
 */
bool	is_derived (x)
ac	x;
{
	return x != NULL && g_d (x) == XINHERIT;
}

/*
 *	is x a string literal
 */
bool	is_stringlit (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (g_d (x) != XLITERAL)
	   return FALSE;

	if (g_val (x) == NULL)
	   return FALSE;

	if (g_val (x) -> litkind == S_STRINGLIT)
	   return TRUE;

	return FALSE;
}

/*
 *	is x a string type?
 */
bool	is_stringtype (x)
ac	x;
{
	ac	y,
		z;

	x = get_arraytype (x);
	if (x == NULL)
	   return FALSE;

	y = g_findex (x);
	if (y == NULL)
	   return FALSE;

	if (g_next (y) != NULL)
	   return FALSE;

	if (g_indextype (y) == any_type || is_someinteger (g_indextype (y))) {
/*
 *	Give it a try
 */
	   z = g_elemtype (x);
	   if (!is_entype (z))
	      return FALSE;

	   FORALL (y, fenum_of (z)) {
	      if (is_charlit (y))
	         return TRUE;
	   }

	}

	return FALSE;
}

/*
 *	is x an object or a value, i.e. suitable for name operations
 */

bool	is_object_or_value (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XNAME)
	   return TRUE;

	if (is_type (g_fentity (x)))
	   return FALSE;

	return TRUE;
}

/*
 *	Consists an expression solely of a type name
 */
bool	is_tpname (x)
ac	x;
{
	ac	y;

	ASSERT (x != NULL, ("is_tpname NULL"));
	ASSERT (g_d (x) == XEXP, ("is_tpname (%d)\n", g_d (x)));

	y = g_primary (x);
	if (y == NULL)
	   return FALSE;

	if (g_d (y) != XNAME)
	   return FALSE;

	if (g_fentity (y) == NULL)
	   return FALSE;

	if (is_type (g_fentity (y)))
	   return TRUE;

	return FALSE;
}

/*
 *	is x a name construct
 */

bool	is_name (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XALL:
	   case XATTRIBUTE:
	   case XCALL:
	   case XENTRYCALL:
	   case XINDEXING:
	   case XSELECT:
	   case XSLICE:
	   case XNAME:
		return TRUE;

	   default:
		return FALSE;
	}
}

/*
 *	Is x a legitimate entry call
 */
bool	is_ecall (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XSELECT)
	   return FALSE;

	if (g_d (g_types (x)) == XENTRY)
	   return TRUE;

	if (g_d (g_types (x)) == XTRIPLE)
	   return g_d (g_tripsub (g_types (x))) == XENTRY;

	return FALSE;
}

/*
 *	is an parameter association positional (or named)
 */
bool	is_positional (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XNAMEDASS)
	   return TRUE;

	return g_parname (x) == NULL;
}

/*
 *
 *	is x a loop?
 */
bool	is_loop (x)
ac	x;
{
	switch (g_d (x)) {
	   case XLOOPBLOCK:
	   case XFORBLOCK:
	      return TRUE;

	   case XTAGSTAT:
	      return is_loop (g_t_stat (x));

	   default:
	      return FALSE;
	}
}


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

bool	is_basetype (x)
ac	x;
{
	if (x == NULL)
	   return NULL;
	x = basefilter (x);
	if (x == NULL)
	   return FALSE;


	switch (g_d (x)) {
	   case XGENPARTYPE:
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
bool	is_anytype (x)
ac	x;
{
	x = base_type (x);
	if (x == NULL || g_d (x) != XINTERNAL)
	   return FALSE;

	switch (g_ind (x)) {
	   case I_UNIV:
	   case I_ANY_TYPE:
	   case I_ANY_ACCESS_TYPE:
	   case I_ANY_STRING_TYPE:
	   case I_ENUM:
	   case I_ANY_BOOL_VECTOR:
	   case I_ANY_AGGREGATE:
	   case I_ANY_SCALAR_VECTOR:
	      return TRUE;

	   default:
	      return FALSE;
	}

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
	
