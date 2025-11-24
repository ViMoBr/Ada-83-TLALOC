/*
 * (c) copyright 1987, Delft University of Technology
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
 *	Forward (static) declarations
 */
static	ac	bu_agg		();
static	ac	bu_allocator	();
static	ac	bu_literal	();
static	ac	td_agg		();
static	ac	td_allocator	();
static 	ac	td_inoperator	();
static	ac	td_scc		();
static	ac	td_literal	();
/*
 *	Basic type checker
 *	Functions in this module perform the bu_... and td_...
 *	functions required for type checking
 *
 *	major functions:
 *	bu_expr (node) return possibly modified tree
 *	td_expr (node) returns  possibly modified tree
 */

ac	bu_expr (node)
ac	node;
{
	ac	t,
		t1,
		t2;
	ac	desc;

	if (node == NULL)
	   return NULL;

	switch (g_d (node)) {
	  case XEXP:
	       t = bu_expr (g_primary (node));
	       if (is_qualif (node))
	          s_exptype (node, propagate (type_of (t), g_exptype (node)));
	       else
	          s_exptype (node, exptype_copy (type_of (t)));
	       s_primary (node, t);
	       s_flags (node, g_flags (node) | BUWALK);
	       return node;

	case XCOMPASSOC:
		t = bu_expr (g_compexpr (node));
		if (t == NULL)
		   return NULL;

		return node;

	case XAGGREGATE:
	       return bu_agg (node);

	case XALLOCATOR:
	      return bu_allocator (node);

	case XSCC:
	      t1 = bu_expr (g_fsccexpr (node));
	      t2 = bu_expr (g_next (g_fsccexpr (node)));
	      if (t1 == NULL || t2 == NULL)
		 return NULL;


	      s_fsccexpr (node, t1);
	      s_next    (t1, t2);
	      return node;

	case XIN:
	      t1 = bu_expr (g_intype (node));
	      t2 = bu_expr (g_inexpr (node));
	      if (t1 == NULL || t2 == NULL)
		 return NULL;


	      s_intype (node, t1);
	      s_inexpr (node, t2);
	      return node;

	case XPARENTHS:
	      t = bu_expr (g_subexpr (node));

	      if (t == NULL)
	         return NULL;
	      s_subexpr (node, t);
	      return node;

	case XLITERAL:
	      return bu_literal (node);

	case XNAME:		/* READ: XAPPLIED	*/
	case XSELECT:
	case XSLICE:
	case XINDEXING:
	case XCALL:
	case XATTRIBUTE:
	case XALL:
	        return bu_name (node);

	case XRANGE:
	      if (g_frang_exp (node) == NULL)
	         return node;

	      t1 = g_frang_exp (node);
	      t2 = g_next (t1);

	      t1 = bu_expr (t1);
	      t2 = bu_expr (t2);
	      if (t1 == NULL) {
	         t1 = t2;
	         t2 = NULL;
	      }
	      else
	         s_next (t1, t2);
	      s_frang_exp (node, t1);
	      if (g_rangetype (node) == NULL) {
	         s_rangetype (node, copy (type_of (t1)));
	      }
	      else
		 s_rangetype (node, propagate (type_of (t1), g_rangetype (node)));
	      if (t2 != NULL) {
	         s_rangetype (node, propagate (type_of (t2),
	                                      g_rangetype (node)) );
	      }
	      if (g_rangetype (node) == NULL) {
	         error ("Incompatible range types in range constraint");
		 return NULL;
	      }
	      return node;

	case XNAMEDASS:
		s_nexp (node, bu_expr (g_nexp (node)));
		return node;

	case XFILTER:
	      return bu_filter (node);

	DEFAULT (("ernstige fout %d\n", g_d (node)));
	}
}

/*
 *	Remaining bu_ and td_ functions
 */

static
ac	bu_agg (node)
ac	node;
{
	ac	t;

	if (node == NULL)
	   return NULL;

	ASSERT (g_d (node) == XAGGREGATE, ("Checking aggregate"));

	FORALL (t, g_fcompas (node))
	   if (bu_expr (t) == NULL)
	      return NULL;

	return node;
}

/*
 *	basic bu walk through an allocator
 */
static
ac	bu_allocator (node)
ac	node;
{	ac	expnode,
		prim;

	if (node == NULL)
	   return NULL;

	if (g_d (g_obtype (node)) == XFILTER)
	   s_obtype (node, bu_filter (g_obtype (node)));
	else
	if (g_d (g_obtype (node)) == XEXP) {
	   expnode = g_obtype (node);		/* it better be an aggregate */
	   prim    = g_primary (expnode);
	   expnode = bu_expr (expnode);
	   if (expnode == NULL) {	/* something erroneous occurred	*/
	      error ("Error in allocator");
	      return NULL;
	   }

	   s_obtype (node, expnode);
	}

	return node;
}

/*
 *	bu_literal
 *	Walk through a literal
 */
static
ac	bu_literal (node)
ac	node;
{
	return node;
}

/*
 *	top-down processing of an expression
 */
ac	td_expr (node)
ac	node;
{
	ac	t1,
		t2;
	ac	temp	= NULL;
	ac	prim;

	if (node == NULL)
	   return NULL;

	ASSERT (g_d (node) == XEXP, ("td_expr"));

	if (g_primary (node) == NULL)	/* some error occured somewhere */
	   return NULL;

	ASSERT (g_flags (node) & BUWALK, ("bu_walk forgotten"));

	prim = g_primary (node);

	switch (g_d (prim)) {
	case XAGGREGATE:
		t1 = td_reduce (g_exptype (node), g_aggtype (prim));
		t2 = td_agg (prim, t1);
		s_primary (node, t2);
		return node;

	case XALLOCATOR:
		s_altype (prim, td_reduce (g_exptype (node), g_altype (prim)));
		if (!is_singleton (g_altype (prim))) {
		   error ("Error: type error in allocator");
		   return NULL;
		}

		s_primary (node, td_allocator (prim));
		return node;

	case XIN:
		if (!eq_types (g_exptype (node), std_boolean)) {
		   error ("Type error in use of in-operator");
		   return NULL;
		}

		s_primary (node, td_inoperator (prim));
		return node;

	case XSCC:
		t1 = td_scc (prim);
		if (t1 == NULL)
		   return NULL;

		s_primary (node, t1);
		return node;

	case XPARENTHS:
		t2 = solve_expr (g_subexpr (prim), g_exptype (node));
		if (is_static (t2)) {
		   set_static (node);
		   s_primary (node, t2);
		}
		else
		   s_subexpr (prim, t2);
		if (is_static (t2)) {
		   set_static (node);
		   s_primary (node, t2);
		}
		return node;

	case XTYPECONV:
		sys_error ("should not happen: typeconv");

	case XSELECT:
	case XSLICE:
	case XINDEXING:
	case XCALL:
	case XATTRIBUTE:
	case XALL:
		s_primary (node, td_name (g_primary (node), type_of (node)));
		if (g_primary (node) == NULL) {
		   return NULL;
		}
		if (!is_object_or_value (g_primary (node))) {
	           error ("Expression context: no real value/object");
	        }
		return repl_name (pl_call (node));

	case XNAME:	/* a leaf, remember		*/
		s_types (prim, td_reduce (g_exptype (node), g_types (prim)));
		if (!is_singleton (g_types (prim))) {
	           error ("Cannot reduce primary (name) types");
		   return NULL;
		}

		FORSET (t1, g_fentity (prim)) {
/*
		   if (eq_types (type_of (t1), g_types (prim))) {
		      temp = add_set (t1, temp);
		   }
 */
		   ac t5 = td_reduce (g_types (prim), type_of (t1));
		   if (t5 != NULL)
		      temp = add_set (t1, temp);
		   else
		   if (is_paramless (t1) &&
		       eq_types (restypes (t1), g_types (prim))) {
		      temp = add_set (t1, temp);
		   }
		}
		if (!is_singleton (temp)) {
		   error ("Cannot uniquely identify name");
		   return NULL;
		}

	        if (g_d (g_types (node)) == XTRIPLE) {
		   del_tripels (g_types (node));
		   s_types    (node, restypes (temp));
		}

		s_fentity (prim, temp);
	        s_primary (node, pl_call (prim));
		if (!is_object_or_value (g_primary (node))) {
		   error ("Expression: no real value or object");
	        }
		return repl_name (node);

	case XLITERAL:
		s_littype (prim, td_reduce (g_exptype (node), g_littype (prim)));
		t2 = td_literal (prim);
		if (t2 == NULL)
		   return NULL;
		s_primary (node, t2);
		if (is_scalar (type_of (prim))) {
		   set_static (node);
		}

		s_exptype (node, g_littype (prim));	/* this is a trick	*/
		return node;

	DEFAULT (("illegal top down call"));
	}
}

/*
 *	td_agg (node)
 *	Main dispatching routine for top-down walk through aggregates
 */
static
ac	td_agg (agg, y)
ac	agg,
	y;
{
	ac	z;

	if (agg == NULL)
	   return NULL;

	s_aggtype (agg, td_reduce (y, g_aggtype (agg)));
	if (g_aggtype (agg) == NULL) {		/* no types left	*/
	   error ("No valid aggregate type left");
	   return NULL;
	}

	if (!is_singleton (agg)) {		/* too much types	*/
	   error ("Too many aggregate types %s",
	                    g_tag (base_type (g_aggtype (agg))) );
	   return NULL;
	}
	if (has_selection (g_aggtype (agg))) {
	   return (ac)rec_agg (agg, y);
	}
	else
	if (has_indexing (g_aggtype (agg))) {
	   return (ac)arr_agg (agg, y);
	}
	ASSERT (FALSE, ("type spec %d in aggregate", g_d (g_aggtype (agg))));
}

/*
 *	td_allocator
 */
static
ac	td_allocator (node)
ac	node;
{
	ac	t1,
		t2;

	if (node == NULL)
	   return NULL;

	ASSERT (g_d (node) == XALLOCATOR, ("allocator expected here"));

	if (!is_singleton (g_altype (node)))
	   return NULL;

	if (g_obtype (node) == NULL)
	   return NULL;

	if (g_d (g_obtype (node)) == XFILTER) {
	   t1 = g_obtype (node);
	   t2 = dereftype (g_altype (node));
	   if (t2 != NULL)
	      t2 = g_actype (t2);

	   s_filtype (t1, td_reduce (t2, g_filtype (t1)));
	   if (!is_singleton (g_filtype (t1))) {
	      error ("Cannot solve allocator");
	      return NULL;
	   }

	   t1 = td_filter (t1);
	   if (t1 == NULL)
	      return NULL;
	   
	   s_obtype (node, t1);
	   return node;
	}
	else
	if (g_d (g_obtype (node)) == XEXP) {	/* aggregate case	*/
	   t1 = g_obtype (node);
	   t2 = dereftype (g_altype (node));

	   if (t2 != NULL)
	      t2 = g_actype (t2);

	   t1 = solve_expr (t1, t2);
	   if (t1 == NULL) {
	      error ("Cannot solve expression in allocator %s", g_tag (t2));
	      return NULL;
	   }

	   if (!has_eq_and_ass (type_of (g_obtype (node))))
	      error ("Initailization in allocator not allowed here");
	
	   s_obtype (node, t1);
	   return node;
	}
	else
	{ t1 = dereftype (g_altype (node));
	  if (t1 != NULL)
	     t1 = g_actype (t1);

	  t2 = g_obtype (node);
	  if (!eq_types (base_type (t1), base_type (t2))) {
	     error ("Type error in allocator");
	     return NULL;
	  }

	  t2 = CONST_TYPE (t2,
	          "unconstrained type in allocator %s",
	                g_tag (base_type (t1)));
	  if (t2 == NULL)
	     return NULL;

	  return node;
	}
}

/*
 *	td_inoperator
 */
static
ac	td_inoperator (inop)
ac	inop;
{
	ac	cons;

	if (g_d (g_intype (inop)) == XFILTER)
	   s_intype (inop, td_filter (g_intype (inop)));

	s_exptype (g_inexpr (inop), propagate (g_intype (inop),
			                       g_exptype (g_inexpr (inop))));
	if (!is_singleton (g_exptype (g_inexpr (inop)))) {
	   error ("Type problem in in expression");
	   return NULL;
	}

	s_inexpr (inop, solve_expr (g_inexpr (inop), g_intype (inop)));

	return inop;
}

/*
 *	td_scc
 */
static
ac	td_scc (scc)
ac	scc;
{
	ac	exp1,
		exp2,
		ct;

	exp1 = g_fsccexpr (scc);
	ASSERT (exp1 != NULL, ("td_scc:1"));

	exp2 = g_next (exp1);
	ASSERT (exp2 != NULL, ("td_scc:2"));

	if (eq_types (std_boolean, g_exptype (exp1))) {
	   exp1 = solve_expr (exp1, std_boolean);
	   exp2 = solve_expr (exp2, std_boolean);
	}
	else
	{  exp1 = solve_expr (exp1, any_bool_vect);
	   exp2 = solve_expr (exp2, any_bool_vect);
	}

	if (exp1 == NULL || exp2 == NULL)
	   return NULL;

/*
 *	Try to evaluate the expressions involved
 */
	return try_scc (scc);
}

/*
 *	The main function of td_literal is to check the consistency
 *	of the literal with the typemark
 *	Can be improved to take subtypes into account
 */
static
ac	td_literal (x)
ac	x;
{
	ac	t,
		tt;
	lit_ptr	y;

	register int i;

	if (x == NULL)
	   return NULL;

	ASSERT (g_d (x) == XLITERAL, ("td_literal"));

	t = base_type (type_of (x));
	if (!is_someinteger (t)) {
	   s_littype (x, t);
	   if (is_stringlit (x)) {
	      tt = get_arraytype (t);
	      if (tt == NULL) {		/* Something was already wrong */
	         return;
	      }
	      y = g_val (x);

	      for (i = 0; i < y -> n; i ++)
	          y -> litvalue [i] =
	               valofchar (g_elemtype (tt), y -> litvalue [i]);
	   }
	   return x;
	}

	if (g_d (t) == XGENPARTYPE) {
	   s_littype (x, t);
	   return x;		/* dynamic check	*/
	}
	if (!in_range (t, x)) {
	   error ("Number does not fit in integer type (%s %d)\n",
			g_tag (t), ord (x));
	   return NULL;
	}

	return x;
}

