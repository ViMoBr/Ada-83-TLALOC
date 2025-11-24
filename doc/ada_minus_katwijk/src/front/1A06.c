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

#
#include	"includes.h"
/*
 *	Forward (static) declarations
 */
static	ac	td_scalar	();
static	ac	td_array	();
static	ac	x_constr	();
static	ac	disc_field	();
static	ac	mk_ca	();
static	bool	not_bound_in	();
static	ac	repl_others	();
static	ac	exp3_comp	();
static	ac	exp2_comp	();
static	ac	exp_components	();
static	ac	bu_discr	();
static	ac	bu_array	();
static	ac	bu_record	();
static	ac	bu_scalar	();
static	ac	td_a1	();
static	bool	has_r_attr	();

ac	SOLVE_FILTER (f, tp, t, s)
ac	f,
	tp;
char	*t,
	*s;
{
	ac	t2;

	if (f == NULL)
	   return notype;

	f = bu_filter (f);
	if (f == NULL)
	   return notype;

	s_filtype (f, propagate (tp, g_filtype (f)));
	if (g_filtype (f) == NULL) {	/* Nothing left		*/
	   error (s, t);
	   return notype;
	}

	t2 = td_filter (f);
	if (t2 == NULL) {
	   error (s, t);
	   return notype;
	}

	return t2;
}

/*
 *	Remaining specific top-down functions
 *	Contains:
 *		- td_..		(where .. has something to do with types)
 */


ac	TD_FILTER (t, s, tag)
ac	t;
char	*s,
	*tag;
{
	t = td_filter (t);
	if (t == NULL) {
	   error (s, tag);
	}
	return t;
}


/*
 *	td_filter
 */
ac	td_filter (x)
ac	x;
{
	ac	t;

	if (x == NULL)
	   return NULL;

	ASSERT (g_d (x) == XFILTER, ("td_filter (%d)", g_d (x)));

	t = g_filtype (x);
	if (t == notype)
	   return t;

	if (is_scalar (t))
	   return td_scalar (x);

	if (has_indexconstraint (t))
	   return td_array (x);

	if (has_discriminantconstraint (t))
	   return td_discr (x);

	ASSERT (FALSE, ("td_filter:xxx"));
}

/*
 *	td_scalar
 */
static
ac	td_scalar (x)
ac	x;
{
	ac	t;

	ASSERT (g_d (x) == XFILTER, ("td_scalar:1"));
	t = g_constraint (x);
	if (t == NULL)
	   return NULL;

	ASSERT (g_d (t) == XRANGE, ("td_scalar:2"));
	if (has_r_attr (t)) {
	   s_constraint (x, td_n_attrib (g_primary (g_frang_exp (t)), t));
	   return x;
	}
/*
 *	Only simple case for now	
 */
	if (g_filtype (x) == std_univ)
	   s_filtype (x, std_integer);

	s_rangetype (t, td_reduce (g_filtype (x), g_rangetype (t)));
	s_constraint (x, td_range (t));
	if (is_static (g_constraint (x)))
	   set_static (x);

	return x;
}

/*
 *	td_array (x)
 */
static
ac	td_array (x)
ac	x;
{
	ac	t;

	ASSERT (x != NULL, ("td_array: NULL"));
	t = g_constraint (x);

	ASSERT (t != NULL, ("td_array:2 NULL"));
	t = (ac)mk_icons (t);
	t = td_indexcons (t, g_filtype (x));
	if (t == NULL)
	   return NULL;

	s_constraint (x, t);
	return x;
}

/*
 *	td_discr (fil)
 *	Top-down procesing of a discriminant (is it really?)
 *	constraint
 */
ac	td_discr (fil)
ac	fil;
{
	ac	bt,
		cd,
		dl,
		cal;

/*
 *	watch out: if type is an accesstype,
 *	an incompletetype as basetype is
 *	o.k
 */
	if (fil == NULL)
	   return NULL;

	bt = get_selecttype (g_filtype (fil));

	ASSERT (bt != NULL, ("td_discr: null type"));
	dl = g_d (bt) == XRECTYPE ? g_ffield (bt) :
		    g_d (bt) == XPRIVTYPE ? g_fpdiscr (bt) :
		    g_d (bt) == XINCOMPLETE ? g_fidiscr (bt) : NULL;

	cal = g_constraint (fil);
	if (cal == NULL) {		/* can be caused by bu- ...	*/
	   return NULL;
	}

	for (cd = dl; cd != NULL && is_discr (cd); cd = g_next (cd)) {
	   if (disc_field (cal, cd) == NULL) {
	     error ("no discrim. constraint for %s", g_tag (cd));
	     return NULL;
	  }
	}

	s_constraint (fil, x_constr (cal, dl, bt));
	return fil;
}

/*
 *
 *	Discriminant constraint processing
 *	x_constr:	final checking and polishing of a discriminant
 *			constraint
 *
 *	disc_field:	1. find binding for discriminants
 *			2. do top-down walking through component expressions
 */

static
ac	x_constr (cal, dl, type)
ac	cal,
	dl,
	type;
{
	ac	t1,
		t2;

	if (cal == NULL)
	   return NULL;

	ASSERT (dl != NULL, ("x_constr:1"));
	ASSERT (g_d (cal) == XCOMPASSOC, ("x_constr:2"));

	FORALL (t1, cal) {
	   if (!is_visited (t1)) {
	      error ("Discriminant constraint for %s has unbound constr",
	             g_tag (type) );
	      return NULL;
	   }
	   FORALL (t2, g_fcompchoice (t1)) {
	      if (is_others (t2))
	         continue;
	      if (!is_visited (t2)) {
	         error ("Unbound component association for %s",
			     g_tag (g_primary (g_frang_exp (t2))) );
	         return NULL;
	      }
	      unvisit (t2);
	   }
	   unvisit (t1);
	}

	t2 = mk_dcons (exp_components (cal, dl));
	return t2;
}

/*
 *	disc_field (x, y)
 *
 *	simplified version of agg_field, to be used
 *	for discriminant constraint verification
 *
 */
static
ac	disc_field (x, y)
ac	x,
	y;
{
	ac	ca,
		r;

	FORALL (ca, x) {
	   FORALL (r, g_fcompchoice (ca)) {
	      if (is_others (r))
	         goto L;
	      if (g_fentity (g_primary (g_frang_exp (r))) == y) {
	         set_visited (r);
	         goto L;
	      }
	   }
	}

	/* if we are here: nothing found 
	 * that is possible
	 * someone else will have to solve the mess
	 */
	return (NULL);

L:	if (!is_visited (ca)) {
	   set_visited (ca);
	   s_exptype (g_compexpr (ca), td_reduce (type_of (y),
					    g_exptype (g_compexpr (ca))));
	   s_compexpr (ca, td_expr (g_compexpr (ca)));
	}
	return (ca);
}

/*
 * td_index_cons:
 * recall that an array, including its factorization
 * may be imperfect, i.e. the indextype is to be
 * computed from the compiler constructed filter
 */
ac	td_indexcons (cons, type)
ac	cons,
	type;
{	ac	r,
		h;

	int count = 0;

	ASSERT (cons != NULL, ("td_indexcons: NULL"));
	type = get_arraytype (type);
	r = g_frange (cons);
	h = g_findex (type);

	while (r != NULL && h != NULL) {
	   count ++;
	   s_rangetype (r, propagate (g_indextype (h), g_rangetype (r)));
	   r = td_range (r);
	   if (r == NULL)
	      return NULL;
	   if (base_type (g_indextype (h)) == any_type)
	      s_indextype (h, g_rangetype (r));
	   r = g_next (r);
	   h = g_next (h);
	}
	if (h != NULL || r != NULL) {
	   error ("Number of discriminants for %s incorrect", g_tag (type));
	   return NULL;
	}

	return cons;
}

/*
 *	Replace, in an record aggregate, the others choice by
 *	real component associations
 *	elem: the others element
 *	cal:  theoriginal component association list
 *	dl:   the unprocessed part of the list of discriminants
 */
static
ac	mk_ca (el, ex)
ac	el,
	ex;
{
	ac	t1;

	t1 = mk_range (NULL,
	               mk_expr (NULL,
	                        mk_applied (el)), NULL);
	return mk_component (t1, cp_tree (ex));
}

static
bool	not_bound_in (cal, el)
ac	cal,
	el;
{
	ac	t1,
		t2;

	FORALL (t1, cal) { 
	   FORALL (t2, g_fcompchoice (t1)) {
	      if (is_others (t2))
	         break;		/* from everything in fact	*/
	      if (g_fentity (g_primary (g_frang_exp (t2))) == el)
	         return FALSE;
	   }
	}
	return TRUE;
}

static
ac	repl_others (elem, cal, dl)
ac	elem,
	cal,
	dl;
{
	ac	x;

	if (dl == NULL || !is_discr (dl))
	   return NULL;

	if (not_bound_in (cal, dl)) {
	   x = mk_ca (dl, g_compexpr (elem));
	   s_next (x, repl_others (elem, cal, g_next (dl)));
	   return x;
	}

	return repl_others (elem, cal, g_next (dl));
}

/*
 *	Component expanding:
 *	The positional components in a discriminant constraint
 *	are extended to be full named constraint components
 */
static
ac	exp3_comp (cc, e, cal, dl, t)
ac	cc,
	e,
	cal,
	dl,
	t;
{
	ac	x,
		y;

	if (cc == NULL)
	   return exp2_comp (t, cal, dl);

	ASSERT (g_d (cc) == XRANGE, ("exp3_comp"));

	y = g_next (cc);
	s_next (cc, NULL);
	x = mk_component (cc, cp_tree (e));
	s_next (cc, NULL);
	s_next (x, exp3_comp (y, e, cal, dl, t));
	return x;
}

static
ac	exp2_comp (elem, cal, dl)
ac	elem,
	cal,
	dl;
{
	ac	t;

	if (elem == NULL)
	   return NULL;

	if (is_others (g_fcompchoice (elem)))
	   return repl_others (elem, cal, dl);

	t = g_next (elem);
	s_next (elem, exp3_comp (g_next (g_fcompchoice (elem)),
	                         g_compexpr (elem), cal, dl, t));
	return elem;
}

/*
 *	called from x_constr
 */
static
ac	exp_components (cal, dl)
ac	cal,
	dl;
{
	return exp2_comp (cal, cal, dl);
}

/*
 *	Do the bottom-up walk in a discriminant
 *	constraint
 */
static
ac	bu_discr (cons)
ac	cons;
{
	ac	t,
		h,
		tp,
		seltype;

	register int i = 1;

	if (cons == NULL)
	   return NULL;

	ASSERT (g_d (cons) == XFILTER, ("FILTER expected here"));

	seltype = get_selecttype (g_filtype (cons));
	if (seltype == NULL) {
	   error ("Cannot put discriminant constraint on %s",
				tag_of (base_type (g_filtype (cons))));
	   return NULL;
	}

	FORALL (t, g_constraint (cons)) {
	   if (g_compexpr (t) == NULL)
	      return NULL;	/* erroneous		*/


	/* if the element of the constraint was a single ls_name
	 * then it appears as a name, rather than as an expr
	 * just to ease the work on the index constraint
	 * Here we pay for it; the name is transformed
	 * into a proper EXP prior to entering bu_...
	 */
	   if (is_name (g_compexpr (t))) {
	      s_compexpr (t, mk_expr (NULL, g_compexpr (t)));
	   }
	   if (bu_expr (t) == NULL)
	      return NULL;

	   if (g_fcompchoice (t) == NULL) {	/* positional	*/
	     h = (ac) mk_range (NULL,
                mk_expr (NULL, mk_applied
		   (res_pparam (seltype, i))), NULL);
	     s_fcompchoice (t, h);
	     i ++;
	   }
	  else
	  { FORALL (h, g_fcompchoice (t)) {
	       ac p, q;
	       ASSERT (g_d (h) == XRANGE, ("bu_discr:0"));
	       if (is_others (h))
	          continue;	/* do not bother		*/
	       p = g_primary (g_frang_exp (h));
	       ASSERT (p != NULL && g_d (p) == XNAME, ("bu_discr:1"));
	       ASSERT (g_d (g_fentity (p)) == XUNRESREC, ("bu_discr:2"));
	       q = res_param (seltype, g_ident (g_fentity (p)));
	       if (p == NULL) {
		  error ("Cannot locate discriminant key %s", 
		          g_ident (g_fentity (p)) );
		  return NULL;
	       }
	       s_fentity (p, q);
	   }
	 }

	}
	return cons;
}

/*
 *	Bottom-up walk through an index constraint
 *	(dispatched by bu_filter)
 */
static
ac	bu_array (x)
ac	x;
{
	ac	t;

	if (x == NULL)
	   return NULL;

	s_constraint (x, td_a1 (g_constraint (x)));
	return x;
}

/*
 *	Bottom-up walk through a discriminant constraint
 */
static
ac	bu_record (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	return bu_discr (x);
}

/*
 *	Bottom-up walk through a range constraint
 */
static
ac	bu_scalar (x)
ac	x;
{
	ac	t;

	if (x == NULL)
	   return NULL;

	t = g_constraint (x);

	if (t == NULL)
	   return NULL;

	t = bu_expr (t);
	if (t == NULL)
	   return NULL;

	if (g_filtype (x) == NULL)
	   s_filtype (x, types_of (t));
	else
	   s_filtype (x, propagate (type_of (t), g_filtype (x)));

	return x;
}

/*
 *	External interface to solving filters
 */
ac	bu_filter (x)
ac	x;
{
	ac	t;

	if (x == NULL)
	   return NULL;

	if (g_filtype (x) == NULL)
	   return bu_scalar (x);

	t = g_filtype (x);

	if (t == NULL)
	   return NULL;	/* empty filter	*/

	if (is_scalar (t))
	   return bu_scalar (x);

	if (has_indexconstraint (t))
	   return bu_array (x);

	if (has_discriminantconstraint (t))
	   return bu_record (x);

	error ("Illegal filter type (%s)\n",
		        has_tag (t) ? g_tag (t) : "???");

	return NULL;
}

/*
 *	Is x a type conversion
 */
bool	is_tpconv (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XNAME)
	   return FALSE;

	if (g_fentity (x) == NULL)
	   return FALSE;

	if (!is_singleton (g_fentity (x)))
	   return FALSE;

	return is_type (g_fentity (x));
}

static
ac	td_a1 (lst)
ac	lst;
{
	ac	t;

	if (lst == NULL)
	   return NULL;

	ASSERT (g_d (lst) == XCOMPASSOC || g_d (lst) == XRANGE,
					("td_a1 (%d)", g_d (lst)));

	if (g_d (lst) == XRANGE)
	   t = lst;
	else
	   t = g_compexpr (lst);	/* take the ranges	*/

	if (t == NULL)	/* should not happen		*/
	   return NULL;

	if (g_d (t) != XRANGE) {	/* It better be a name	*/
	   if (g_d (t) == XATTRIBUTE) {
	      t = td_n_name (bu_name (t));	/* It's a range		*/
	      if (g_d (t) != XRANGE) {
	         error ("Index constraint not a range ???\n");
	         return mk_range (std_integer, NULL, NULL);
	      }
	   }
	   else
	     t = (ac)type_name (td_n_name (bu_name (t)));

	   if (t == NULL)
	      t = std_integer;
	   t = (ac) mk_range (t, NULL, NULL);
	}
	else
	   t = bu_expr (t);	/* == bu_range			*/

	if (t == NULL)
	   return mk_range (t, NULL, NULL);

	s_next (t, td_a1 (g_next (lst)));

	return t;
}

/*
 *	local to td_range
 */
static
bool	has_r_attr (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	x = g_frang_exp (x);
	if (x == NULL)
	   return FALSE;

	ASSERT (g_d (x) == XEXP, ("is_r_attrib"));
	x = g_primary (x);
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XATTRIBUTE)
	   return FALSE;

	return g_attr_value (x) == A_RANGE;
}

/*
 *	td_range, 
 *	Resolve the types in a range constraint like construct
 */
ac	td_range (r)
ac	r;
{
	ac	e;
	bool	stat_range = TRUE;	/* default		*/

	if (is_others (r))
	   return r;

	if (has_r_attr (r))
	   return td_n_attrib (g_primary (g_frang_exp (r)), r);

	if (!is_singleton (g_rangetype (r)))
	   return NULL;

	if (g_rangetype (r) != any_type) {
	   if (!is_scalar (g_rangetype (r))) {
	      error ("non scalar range type");
	      return NULL;
	   }	
	}

	e = g_frang_exp (r);
	if (e == NULL) {
	   if (is_static (g_rangetype (r)))
	      set_static (r);
	   return r;
	}

	for (; e != NULL; e = g_next (e)) {
	   e = solve_expr (e, g_rangetype (r));
	   if (e == NULL)	/* Only errors			*/
	      return NULL;

	   if (!is_static (e))
	     stat_range = FALSE;
	}

/*
 *	a special case of a range is a simple name
 *	If this name is the name of a type or subtype,
 *	the range construction has to be adjusted
 */
	e = g_frang_exp (r);
	if (g_next (e) == NULL && is_tpname (e)) {
	   s_frang_exp (r, NULL);
	}
	if (stat_range)
	   set_static (r);

	return r;
}



