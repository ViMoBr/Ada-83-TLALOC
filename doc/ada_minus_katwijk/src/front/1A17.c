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
 *	Forward (static) declarations
 */
static	bool	discr_with_def	();
static	bool	defconstraints	();
static	bool	const_type	();
static	ac	do_select	();
static	ac	fld_solve	();
static	ac	loop_of	();



/*
 *	Add to the set s the elements of the set source that are
 *	in some way compatible with elem
 *	return the set
 */
ac	add_new (source, elem, s)
ac	source,
	elem,
	s;
{
	ac	t;

	ASSERT (is_anytype (elem), ("add_new: illegal anytype"));

	switch (g_ind (elem)) {
	   case I_ANY_AGGREGATE:
	      FORSET (t, source)
		 if (may_have_aggregate (t))
		    s = add_set (t, s);
	      break;

	   case I_ANY_TYPE:
	      s = add_set (source, s);
	      break;

	   case I_ANY_ACCESS_TYPE:
	      FORSET (t, source)
		 if (is_accesstype (t))
		    s = add_set (t, s);
	      break;

	   case I_ANY_STRING_TYPE:
	      FORSET (t, source)
		 if (is_stringtype (t))
		    s = add_set (t, s);
	      break;

	   case I_UNIV:
	      FORSET (t, source)
		 if (is_someinteger (base_type (t)))
		    s = add_set (t, s);
	      break;

	   DEFAULT (("unexpected internal type %s", g_ind (elem)));
	}

	return s;
}

/*
 *	reduce the set at with respect to the context type ct
 */
ac	td_reduce (ct, at)
ac	ct,
	at;
{
	ac	e,
		temp = NULL;

	if (ct == NULL || at == NULL) {
	   return NULL;
	}

	ASSERT (is_singleton (ct), ("td_red, ct not unique"));

	FORSET (e, at) {
	   if (is_anytype (e)) {
	      if (match_univ (ct, e)) {
	         temp = add_set (ct, temp);
	      }
	   }
	   else
	   if (eq_types (ct, e))
	      temp = add_set (e, temp);
	}

	del_set (at);
	return temp;
}

/*
 *	Intersect, according to some strange rules, the sets s1
 *	and s2 and return the intersection, throw away the second set
 */
ac	reduce (univ_type, s)
ac	univ_type,
	s;
{
	ac	e,
		temp = NULL;

	FORSET (e, s) {
	    if (e == univ_type) {
	       temp = join (e, temp);
	       continue;
	    }

	    if (match_univ (e, univ_type))
	       temp = join (e, temp);
	}

	del_set (s);
        return temp;
}

ac	propagate (s1, s2)
ac	s1,
	s2;
{
	ac	e,
		temp = NULL;

	if (s1 == NULL || s2 == NULL)
	   return NULL;

	if (is_singleton (s1))
	   if (is_anytype (first (s1)))
	      return reduce (first (s1), s2);

	FORSET (e, s2) {
	    if (is_anytype (base_type (e)))
	       temp = add_new (s1, base_type (e), temp);
	    else
	    if (is_element (e, s1))
	       temp = add_set (e, temp);
	}

	del_set (s2);
	return temp;
}

/*
 *	Get the type from a construct
 */
ac	type_of (x)
ac	x;
{
	ac	t;

	while (TRUE) {
	   if (x == NULL)
	      return notype;

	   switch (g_d (x)) {
	   case XENUMLIT:
	   case XCHARLIT:
	        x = g_enclunit (x);
		break;

	   case XENUMTYPE:
		return x;

	   case XPARENTHS:
		x = g_subexpr (x);
		break;

	   case XOBJECT:
		x = g_desc (x);
		break;

	   case XOBJDESC:
		x = g_objtype (x);
		break;

	   case XRENOBJ:
		x = g_rentype (x);
		break;

	   case XVARIANT:
		x = g_enclunit (x);
		break;

	   case XEXP:
		return g_exptype (x);

	   case XNAMEDASS:
		x = g_nexp (x);
		break;

	   case XSCC:
	   case XIN:
		return std_boolean;

	   case XLITERAL:
		return g_littype (x);

	   case XAGGREGATE:
		return g_aggtype (x);

	   case XRANGE:
		return g_rangetype (x);

	   case XSLICE:
	   case XSELECT:
	   case XNAME:
	   case XINDEXING:
	   case XATTRIBUTE:
	   case XALL:
	   case XCALL:
		return g_types (x);

	   case XFILTER:
		return g_filtype (x);

	   case XALLOCATOR:
		return g_altype (x);

	   case XENTRY:
	   case XSUB:
	   case XRENSUB:
	   case XINHERIT:
	   case XRECTYPE:
	   case XARRAYTYPE:
	   case XNEWTYPE:
	   case XGENPARTYPE:
	   case XPACKAGE:
	   case XBLOCK:
	   case XFORBLOCK:
	   case XLOOPBLOCK:
		return x;

	   case XSET:
	        abort ();
	   default:
		if (is_type (x))
		   return x;
		else
		   return notype;
	   }
	}
}

ac	types_of (x)
ac	x;
{
	ac	y,
		temp = NULL;

	FORSET (y, x)
	   temp = add_set (type_of (y), temp);

	return temp;
}

/*
 *	compute from a given construct the base type
 */
ac	base_type (t)
ac	t;
{
	while (t != NULL) {
	   if (g_d (t) == XSUBTYPE)
	      t = g_parenttype (t);
	    else
	    if (g_d (t) == XFILTER && g_filtype (t) != NULL)
	       t = g_filtype (t);
	    else
	       return t;
	}

	return NULL;
}

/*
 *	compute the basetype, taking incompletes and privtypes
 *	into account
 */
ac	bsf_type (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	while (TRUE) {
	   switch (g_d (x)) {
	      case XSUBTYPE:
	         x = g_parenttype (x);
		 break;

              case XFILTER:
                 x = g_filtype (x);
	         break;

	      case XINCOMPLETE:
	         if (g_complete (x) != NULL)
	            x = g_complete (x);
	         else
	            return x;
		 break;

	      case XPRIVTYPE:
		 if (g_impl (x) != NULL && in_spec (x))
	            x = g_impl (x);
	         else
		    return x;

		 break;

	      default:
	         return x;
	   }
	}
}

/*
 *	walk through all renaming subtypes
 */
ac	rootfilter (t)
ac	t;
{
	while (t != NULL && g_d (t) == XSUBTYPE &&
	                              g_d (g_parenttype (t)) != XFILTER)
	   t = g_parenttype (t);

	return t;
}

/*
 * check that a type, given as subtype indication
 * is reasonable, i.e. not something unconstrained
 */
static
bool	discr_with_def (x)
ac	x;
{
	return is_discr (x) && has_expr (x);
}

/*
 *	Has a type x a constraint with default discriminants ?
 */
static
bool	defconstraints (x)
ac	x;
{
	switch (g_d (x)) {
	   case XINCOMPLETE:
	   case XPRIVTYPE:
	   case XRECTYPE:
	      if (get_locallist (x) != NULL)
		 return discr_with_def (get_locallist (x));

	   default:
	      return FALSE;
	}
}

/*
 *	Check whether or not type x is sufficiently
 *	constrained to allow the creation of objects
 */
ac	CONST_TYPE (t, a, s)
ac	t;
char	*s;
char	*a;
{
	static bool const_type ();

	if (t == NULL)
	   return std_integer;

	if (!const_type (t)) {
	   error (s, a);
	   return std_integer;
	}
	return t;
}
/*
 *	is type x sufficently constrained
 *	to appear as object or component type
 */
static
bool	const_type (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;	/* no message here	   */

	switch (g_d (x)) {
	   case XARRAYTYPE:
	      return FALSE;

	   case XRECTYPE:
	      if (g_ffield (x) == NULL)
	         return TRUE;

	      if (!is_discr (g_ffield (x)))
	         return TRUE;

	      if (has_defaults (x))
	         return TRUE;
	      return FALSE;

	   case XINCOMPLETE:
	      return g_fidiscr (x) == NULL;

	   case XPRIVTYPE:
	      return g_fpdiscr (x) == NULL;

	   case XSUBTYPE:
	      return const_type (g_parenttype (x));

	   default:
	      return TRUE;
	}
}

/*
 *	are types t1 and t2 matching according to LRM for use in a type conv
 */
bool	arr_typesmatching (t1, t2)
ac	t1,
	t2;
{
	ac	ind1,
		ind2;

	if (g_d (t1) != XARRAYTYPE || g_d (t2) != XARRAYTYPE)
	   return FALSE;

	ind1 = g_findex (t1);
	ind2 = g_findex (t2);

	while (ind1 != NULL && ind2 != NULL) {
	   if (base_type (g_indextype (ind1)) !=
		                      base_type (g_indextype (ind2)) ) {
	      return FALSE;
	   }
	   ind1 = g_next (ind1);
	   ind2 = g_next (ind2);
	}
	return (ind1 == NULL && ind2 == NULL &&
	      eq_types (g_elemtype (t1), g_elemtype (t2)) );
}

/*
 *	select, use namelist functions and do-select to
 *	solve the names
 *	selects the tag tag in the (unit, record or whatever) t1
 *	kind is used to distinguish between character literals and identifiers
 */
ac	select (t1, tag, kind)
ac	t1;
char	*tag;
int	kind;
{
	ac 	unit;

	if (t1 == NULL)
	   return NULL;

	ASSERT (has_selection (t1), ("cannot select %s", tag));
/*
 *	First try as a unit, within the open scopes
 */
	unit = open_scopes (t1);
	if (unit != NULL) {
	   if (kind == ID_OPSYM)
	      return loc_lookup (unit, tag);
	   else
	      return loc_char   (unit, tag);
	}

/*
 *	try a genuine selection in t1
 */
	unit = get_selecttype (t1);
	if (unit != NULL)
	   if (kind == ID_OPSYM)
	       return do_select (unit, tag);
	   else
	      return NULL;

/*
 *	It beter be a unit selection in a non-open scope
 */
	if (kind == ID_OPSYM)
	   return loc_lookup (t1, tag);
	else
	   return loc_char   (t1, tag);
}

static
ac	do_select (d, tag)
ac	d;
char	*tag;
{
	ac	t;

	while (TRUE) {
	   if (d == NULL)
	      return NULL;

	   switch (g_d (d)) {
	      case XRECTYPE:
		 return fld_solve (g_ffield (d), tag);

	      case XINCOMPLETE:
		 t = fld_solve (g_fidiscr (d), tag);
		 if (t != NULL)
		    return t;
		 d = g_complete (d);
		 break;

	      case XPRIVTYPE:
		 t = fld_solve (g_fpdiscr (d), tag);
		 if (t != NULL)
		     return t;
		 else
		    if (in_spec (d))
		       d = g_impl (d);
		    else
		       d = NULL;
		 break;

	      case XTASKTYPE:
		 return loc_lookup (d, tag);

	      default:
		 return NULL;
	   }
	}
}

/*
 *	find a field in a record
 *	or any other list of components
 */
static
ac	fld_solve (x, y)
ac	x;
char	*y;
{
	ac	t,
		a;

	FORALL (t, x) {
	   if (g_d (t) == XOBJECT)
	      if (eq_tags (g_tag (t), y))
	         return t;

	   if (g_d (t) == XVARIANT) {
	      a = fld_solve (g_ffield (t), y);
	      if (a != NULL)
	         return a;
	   }
	}

	return NULL;
}

ac	c_object (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (!is_object (x)) {
	   error ("renaming to non-object");
	   return x;
	}

	return x;
}

/*
 *	check whether an implicit dereferencing has to be
 *	performed before the operation, indicated in the
 *	node following the one pointed to by node. Make
 *	dereferencing explicit
 *	link the second parameter, possibly preceded by a dereferencing
 *	operation to the next field of the first
 */
void	insert_all (n1, n2)
ac	n1,
	n2;
{
	ac	t;

	if (dereftype (g_types (n2)) != NULL) {
	   t = mx_all (do_deref (g_types (n2)));
	   s_next (t, n2);
	   n2 = t;
	}

	s_next (n1, n2);
}

/*
 * get_formal:
 *	find a parameter with a tag t
 */
ac	get_formal (f, tag)
ac	f;
char	*tag;
{
	ac	x;

	while (TRUE) {
	   if (f == NULL)
	      return NULL;
	   
	   switch (g_d (f)) {
	   case XTRIPLE:
	      f = g_tripsub (f);
	      break;

	   case XINHERIT:
	      f = g_inh_oper (f);
	      break;

	   default:
	   /* to be sure:		*/
	      ASSERT (is_sub (f), ("get_formal"));
	      FORALL (x, f_formal (f)) {
	         if (eq_tags (tag, g_tag (x)))
	            return x;
	      }
	      return NULL;
	   }
	}
}

/*
 *	get_pformal
 *	find a parameter on position pos.
 */
ac	get_pformal (f, pos)
ac	f;
int	pos;
{
	ac	x;
	int	i = 1;

	while (TRUE) {
	   if (f == NULL)
	      return NULL;

	   switch (g_d (f)) {
	      case XTRIPLE:
	         f = g_tripsub (f);
	         break;

	      case XINHERIT:
	         f = g_inh_oper (f);
	         break;

	      default:
	         ASSERT (is_sub (f), ("get_pformal"));
	         pos --;
	         FORALL (x, f_formal (f)) {
	            if (pos == 0)
	               return x;
	            pos --;
	         }
	         return NULL;
	   }
	}
}

/*

 *	bind the i-th constraint specification
 *	or find the constraint with name tag
 *	- res_param or
 *	- res_pparam
 */
ac	res_pparam (node, pos)
ac	node;
int	pos;
{
	ac	t;

	while (TRUE) {
	   if (node == NULL)
	      return NULL;

	   ASSERT (is_type (node), ("res_pparam:1"));
	   if (g_type_spec (node) != NULL)
	      node = g_type_spec (node);
	   else
	   if (g_d (node) == XNEWTYPE)
	      node = g_old_type (node);
	   else
	      break;
	}

	switch (g_d (node)) {
	   case XINCOMPLETE:
		 t = g_fidiscr (node);
	         break;

	   case XPRIVTYPE:
		 t = g_fpdiscr (node);
	         break;

	   case XRECTYPE:
	         t = g_ffield (node);
		 break;

	   DEFAULT (("res_pparam:1"));
	}

	while (pos--, t != NULL && is_discr (t))
	   if (pos == 0)
	      return t;
	   else
	      t = g_next (t);

	return NULL;
}

/*
 *	find the discr with tag tag
 */
ac	res_param (node, tag)
ac	node;
char	*tag;
{
	ac	y;

	switch (g_d (node)) {
	   case XRECTYPE:
	   case XPRIVTYPE:
	   case XINCOMPLETE:
		if (g_type_spec (node) != NULL)
		   return res_param (g_type_spec (node), tag);

		break;

	   DEFAULT (("res_param: out of domain"));
	}

	FORALL (y, get_locallist (node)) {
	   if (!is_discr (y))
	      return NULL;

	   if (eq_tags (tag, g_tag (y)))
	      return y;
	}

	return NULL;
}

void	set_sttype (x)
ac	x;
{
	set_static (x);
}

/*
 *	Find a (parent) enumeration type for t
 */
ac	en_type (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return NULL;

	   switch (g_d (t)) {
	      case XENUMTYPE:
	         return t;;

	      case XNEWTYPE:
	         t = g_old_type (t);
	         break;

	      case XINCOMPLETE:
	         t = g_complete (t);
	         break;

	      case XPRIVTYPE:
	         if (!in_spec (t))
	            return NULL;
	         t = g_impl (t);
	         break;

	      case XSUBTYPE:
	         t = g_parenttype (t);
	         break;

	      case XFILTER:
	         t = g_filtype (t);
	         break;

	      case XGENPARTYPE:
	         return NULL;

	      default:
	         return NULL;
	   }
	}
}


/*
 *	get first enumeration literal of
 */
ac	fenum_of (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (g_d (x) == XENUMTYPE)
	   return g_fenumlit (x);

	if (g_d (x) == XNEWTYPE) {
	   ASSERT (en_type (x) != NULL, ("Cannot take fenum of non enum"));
	   return g_enlits (x);
	}

	ASSERT (FALSE, ("fenum_of: Help"));
}

/*
 *	get first formal parameter of x
 */
ac	f_formal (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return NULL;

	   ASSERT (is_sub (x), ("f_formal: XSUB expected (%d)", g_d (x)));
	   if (is_derived (x)) {
	      x = g_inh_oper (x);
	   }
	   else
	   if (g_d (x) == XTRIPLE)
	      x = g_tripsub (x);
	   else
	   {
	      ASSERT (g_d (x) == XSUB || g_d (x) == XRENSUB || g_d (x) == XENTRY, ("f_formal"));
	      return g_fformal (x);
	   }
	}
}

/*
 *	get index type
 * t points to an arraytype. Get the index base type of the
 * given dimension. Return NULL is dim is too high.
 */
ac	get_indextype (t, dim)
ac	t;
int	dim;
{
	int	i;
	ac	ind;

	t = get_arraytype (t);
	if (t == NULL)
	   return NULL;

	ind = g_findex (t);
	for (i = 1; i <= dim - 1; i ++) {
	   ind = g_next (ind);
	   if (ind == NULL)
	      return NULL;
	}

	return g_indextype (ind);
}

/*
 *	get the restypes from t
 */
ac	restypes (t)
ac	t;
{
	ac	tt;

	if (g_d (t) == XTRIPLE)
	   return eff_rettype (t);

	if (g_d (t) == XSUB)
	   return g_rettype (t);

	if (g_d (t) == XINHERIT) {
	   tt = restypes (g_inh_oper (t));

	   if (eq_types (tt, g_old_type (t)))
	      return g_inh_type (t);
	   else
	      return tt;
	}

	if (g_d (t) == XRENSUB)
	   return g_rettype (t);

	if (g_d (t) == XENTRY)
	   return notype;

	return t;
}

/*
 *	get an arraytype (or NULL) from a type x
 */
ac	get_arraytype (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return NULL;

	   switch (g_d (x)) {
	      case XARRAYTYPE:
		   return x;

	      case XINCOMPLETE:
		   x = g_complete (x);
		   break;

	      case XPRIVTYPE:
		   if (in_spec (x)) {
		      x = g_impl (x);
		   }
		   else
		      return NULL;
		   break;

	      case XSUBTYPE:
		   x = g_parenttype (x);
		   break;

	      case XFILTER:
		   x = g_filtype (x);
		   break;

	      case XACCTYPE:
		   x = g_actype (x);
		   break;

	      case XNEWTYPE:
		   x = g_old_type (x);
		   break;

	      default:
		   return NULL;
	   }
	}
}

/*
 *	get the type (from which x is derived or subtyped)
 *	that allows the slicing
 */
ac	get_slicetypes (x)
ac	x;
{
	x = get_arraytype (x);
	if (x == NULL)
	   return NULL;

	if (g_findex (x) == NULL)
	   return NULL;

	if (g_next (g_findex (x)) != NULL)
	   return NULL;

	return x;
}

/*
 *	get, starting from x, up in the chain a type
 *	(or other construct) that allows selection
 */
ac	get_selecttype (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return NULL;

	   switch (g_d (x)) {
	      case XRECTYPE:
	      case XTASKTYPE:
		   return x;

	      case XPRIVTYPE:
		if (g_fpdiscr (x) != NULL)
	           return x;

		   if (g_impl (x) != NULL)
		      x = g_impl (x);
		   break;

	      case XINCOMPLETE:
		   if (g_fidiscr (x) != NULL)
		      return x;

		   x = g_complete (x);
		   break;

	      case XSUBTYPE:
		   x = g_parenttype (x);
		   break;

	      case XFILTER:
		   x = g_filtype (x);
		   break;

	      case XACCTYPE:
		   x = g_actype (x);
		   break;

	      case XNEWTYPE:
		   x = g_old_type (x);
		   break;

	      default:
		   return NULL;
	   }
	}
}

/*
 *	locate up in the chain, starting with t,
 *	a type that allows dereferencing
 */
ac	dereftype (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return NULL;

	   switch (g_d (t)) {
	      case XACCTYPE:
	         return t;

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
		 if (in_spec (t))
		    t = g_impl (t);
		 else
		    t = NULL;
		 break;


	      case XNEWTYPE:
		 t = g_old_type (t);
		 break;

	      default:
		 t = NULL;
	   }
	}
}

/*
 *	perform a dereferencing
 */
ac	do_deref (t)
ac	t;
{
	t = dereftype (t);
	if (t == NULL)
	   return NULL;

	return g_actype (t);
}

/*
 *	Replace a single "NAME" node by the value of its
 *	entity once the latter is known
 */
bool	is_constant (x)
ac	x;
{
	int	f;

	if (x == NULL)
	   return FALSE;

	ASSERT (g_d (x) == XOBJECT, ("is_constant"));

	f = g_flags (g_desc (x)) & 07;

	if (f != KNUMB && f != KCONST)
	   return FALSE;

	return g_expr (g_desc (x)) != NULL;
}

ac	repl_name (node)
ac	node;
{
	ac	t1,
		t2;

	ASSERT (g_d (node) == XEXP, ("repl_name"));
	ASSERT (g_primary (node) != NULL, ("repl_name:2"));

	if (g_d (g_primary (node)) != XNAME) {
	   t1 = g_primary (node);
	   if (g_d (t1) == XLITERAL) {
	      set_static (node);
	      return node;
	   }

	return node;
	}

	ASSERT (g_fentity (g_primary (node)) != NULL, ("repl_name:3"));

	t1 = g_fentity (g_primary (node));
/*
 *	Renaming objects not yet taken care of
 */
	if (g_d (t1) == XCHARLIT || g_d (t1) == XENUMLIT) {
	   set_static (node);
	   return node;
	}

	if (g_d (t1) != XOBJECT)
	   return node;

	if (is_constant (t1) && is_scalar (type_of (t1))) {
	   t2 = g_desc    (t1);
	   s_primary (node, cp_value (ord (g_primary (g_expr (t2))),
					type_of (t1)) );
	   set_static (node);
	}

	return node;
}

/*
 *	find the enclosing loop for x
 */
static
ac	loop_of (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	switch (g_d (x)) {
	   case XLOOPBLOCK:
	   case XFORBLOCK:
		return x;

	   case XTAGSTAT:
		return g_t_stat (x);

	   DEFAULT (("loop_of"));
	}
}

ac	get_loop (x)
ac	x;
{
	if (x == NULL)
	   return encl_loop ();

	if (g_d (x) != XNAME) {	/* not simple enough		*/
	   error ("Cannot reduce to simple loop name");
	   return encl_loop ();
	}

	if (is_loop (g_fentity (x))) {
	   return loop_of (g_fentity (x));
	}

	error ("Cannot identify %s as loop", g_tag (g_fentity (x)));
	return encl_loop ();
}


/*
 *	sub_name returns the identifier of a real subprogram
 *	if any
 */
ac	sub_name (name)
ac	name;
{
	ac	t,
		x,
		temp = NULL;

	if (name == NULL)
	   return NULL;

	if (g_d (name) != XNAME) {
	   error ("Sub name expected here");
	   return NULL;
	}

	t = g_fentity (name);

	FORSET (x, t) {
	   if (is_sub (x))
	      temp = add_set (x, temp);
	}

	return temp;
}

/*
 *	transform a name construct into its simple name, i.e. its primary
 */
ac	simple_name (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (g_d (x) != XNAME) {
	   error ("name construction irreducible");
	   return NULL;
	}

	return g_fentity (x);
}

/*
 *	Check that a given name construct yields the name of an exception
 */
ac	get_exc (x)
ac	x;
{
	ac	y;

	if (x == NULL) {
	   error ("construction does not yield exception");
	   return NULL;
	}

	if (g_d (x) != XNAME) {
	   error ("Construction too complicated, exception expected");
	   return NULL;
	}

	if (g_d (g_fentity (x)) != XEXCEPTION) {
	   error ("%s not an exception", g_tag (g_fentity (x)) );
	   return NULL;
	}

	y = g_fentity (x);
	while (g_rnam (y) != NULL)
	   y = g_rnam (y);

	return y;
}

ac	c_typename (x)
ac	x;
{
	if (x == NULL)
	   return any_type;

	if (g_d (x) == XINCOMPLETE && g_complete (x) == NULL)
	   error ("%s not yet a complete type", g_tag (x));

	return x;
}


ac	type_name (name)
ac	name;
{
	ac	x;

	if (name == NULL)
	   return any_type;

	if (g_d (name) != XNAME) {
	   error ("Simple name for type expected");
	   return any_type;
	}

	if (!is_type (g_fentity (name))) {
	   error ("Type name expected (%s)", g_tag (g_fentity (name)));
	   return any_type;
	}

	x = g_fentity (name);

	if (g_type_spec (x) != NULL)
	   return g_type_spec (x);

	return rootfilter (x);
}


/*
 *	Do not get confused here,
 *	pack_name returns a package (if any)
 *	not a template (a generic)
 */
ac	pack_name (name)
ac	name;
{
	ac	t;

	if (name == NULL)
	   return NULL;

	if (g_d (name) == XNAME)
	   name = g_fentity (name);

	if (name == NULL)
	   return NULL;

	if (g_d (name) == XRENPACK)
	   return pack_name (g_renname (name));

	if (g_d (name) != XPACKAGE) {
           error ("%s not a package (use or renaming)",
				has_tag (name) ? g_tag (name) : "???");
	   return NULL;
	}

	if (is_generic (name)) {
	   error ("Cannot use a generic package here (%s)\n", g_tag (name));
	   return NULL;
	}

	return name;
}

/*
 *	st_range, check a range on being static (and mark it)
 */

ac	st_range (n)
ac	n;
{
	ac	t;

	if (n == NULL)
	   return NULL;

	if (!is_static (g_rangetype (n)))
	   return n;

	t = g_frang_exp (n);
	if (t == NULL || !is_static (t))
	   return n;

	t = g_next (t);
	if (t == NULL || !is_static (t))
	   return n;

	set_static (n);
	return n;
}

/*
 *	Due to syntactical problems, the broader
 *	construct simple_expr is sometimes recognized
 *	instead of the type name we really want
 *	Therefore, transform the construct here.
 */
ac	get_name_from_expr (x)
ac	x;
{
	if (x == NULL)
	   return NULL;		/* basic escape */

	ASSERT (g_d (x) == XEXP, ("get_name_from_expr:1"));

	x = g_primary (x);	/* we should give the XEXP node back here */
	if (x == NULL) {
	   error ("Erroneous construct instead of typename");
	   return NULL;
	}

	if (!is_name (x)) {
	   error ("Erroneous construct, type name expected");
	   return NULL;
	}

	x = type_name (td_n_name (bu_name (x)));
	if (x == NULL)
	   x = any_type;
	else
	   x = c_typename (x);

	return x;
}


