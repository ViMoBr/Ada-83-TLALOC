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
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

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
 *	has the type t slicing as an alowable operation?
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
 *	Is the type t a basetype
 *	(used once in 1A10 in attribute pre-computation
 */
bool	is_basetype (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

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
/* these to
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
 *	is x an (actual or formal) universal type
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

