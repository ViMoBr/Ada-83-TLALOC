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
/*
 *	Forward (static) declarations
 */
static	ac	make_actual	();
static	ac	act_of		();
static	ac	acts		();
static	bool	compl_domain	();
static	bool	check_variant	();
static	bool	get_discrim	();
static	ac	perf_select	();
static	ac	disc_elem	();
static	ac	disc_list	();
static	ac	agg_nn		();
static	ac	agg_unwind	();
static	ac	compass_check	();
static	ac	check_aggelem	();
static	ac	get_imp		();
static	ac	check_rec	();
static	bool	res_compchoice	();
static	bool	is_unresolved	();
static	ac	mk_indconstr	();
/*
 *	local definition:
 */
#define	is_typconv(x)	(g_d (g_primary (x)) == XTYPECONV)
#define	head(x)		(x -> forward -> data)
#define	tail(x)		(x -> backwards -> data)

/*
 *	everything you did want to know about aggregates
 *	and probably much more
 */


/*
 *	Get the enclosing record of a component
 */
ac	encl_rectype (v)
ac	v;
{
	if (v == NULL)
	   return NULL;

	while (g_d (v) == XVARIANT)
	   v = g_enclunit (v);

	return v;
}

/*
 *	create an actual list from the list y corresponding
 *	to the formal list x
 */
static
ac	make_actual (x)
ac	x;
{
	ac	t;

	ASSERT (x != NULL && g_d (x) == XOBJECT, ("make_actual:1"));

	t = nalloc (XNAMEDASS);
	s_parname (t, x);
	s_nexp (t, cp_tree (g_expr (g_desc (x))));

	return (t);
}

/*
 *	reorder the actual parameters, the
 *	last actual is first and vice versa
 *
 *	The routine just makes a simple recursive walk
 *	through the formals, and returns the pointer
 *	to the actual linked to the last formal
 */
static
ac	act_of (form, actlist)
ac	form,
	actlist;
{
	ac	t;

	while (actlist != NULL && g_parname (actlist) != form)
	      actlist = g_next (actlist);

	if (actlist == NULL)	/* default param */
	     actlist = make_actual (form);

	if (g_nexp (actlist) != NULL) {
	   if (kind_of (g_desc (form)) != INMODE &&
/*
	       !is_assignable (g_primary (g_nexp (actlist))) &&
 */
	       !is_object (g_primary (g_nexp (actlist))) &&
	       !is_typconv (g_nexp (actlist)) )
	        error ("actual for %s not an object",
					g_tag (form));
	   }

	return actlist;
}

static
ac	acts (formals, actuals, lastlink)
ac	formals,
	actuals,
	lastlink;
{
	ac	t,
		temp;

	if (formals == NULL)
	   return lastlink;

	t = act_of (formals, actuals);
	temp = acts (g_next (formals), actuals, t);
	s_next (t, lastlink);

	return temp;
}

/*
 *	The function actlist is called from from outside:
 */
ac	act_list (formals, actuals)
ac	formals,
	actuals;
{
	return (acts (formals, actuals, NULL));
}

/*
 *	simple minded list manipulations
 *
 *	before checking the whole domain a list is built
 *	with all ranges in it + an indicator for the
 *	'others'
 */
void	l_insert (x, y)
ac	x;
p_link	y;
{
	p_link	z,
		r;

	z = y;
	r = (p_link )calloc (1, sizeof (struct _linkelem));

	r -> forward = NULL;
	r -> data    = x;

	while (y -> forward != NULL) {
	   if (larg_val (x) < small_val (y -> forward -> data)) {
	      y -> forward -> backwards = r;
	      r -> forward = y -> forward;
	      y -> forward = r;
	      return;
	   }

	   y = y -> forward;
        }

/*
 *	link in after y
 */
	z -> backwards = r;
	y -> forward = r;
	r -> backwards = y;
}

/*
 *	remove a linkelem structure list.
 *	if b == TRUE then do a del_tree
 *	on the ranges hanging on the
 *	list elements.
 *	(in case of a case statement b == TRUE,
 *	 in case of a variant record b == FALSE)
 */
void	rem_list (x, b)
p_link	x;
bool	b;
{
	p_link	y;

	while (x != NULL) {
	   y = x;
	   x = x -> forward;
	   cfree (y);
        }
}

/*
 *	Generate a list
 */
p_link	new_list ()
{
	p_link	x;

	x = (p_link )calloc (1, sizeof (struct _linkelem));

	x -> data = NULL;
	x -> forward = NULL;
	x -> backwards = NULL;

	return x;
}

/*
 *	Complete the domain.
 *	Eliminate Others, check the completeness
 *	of the ranges in the following functions
 */
static
bool	compl_domain (list, others)
p_link	list;
bool	others;
{
	p_link	q;
	int	lv,
		hv;
	bool	result = TRUE;

	if (list -> forward == NULL)
	   return others;

	q = list -> forward;
	while (q -> forward != NULL) {
	   lv = larg_val (q -> data);
	   hv = small_val(q -> forward -> data);

	   if (hv != lv + 1 && ((lv >= hv) || !others) )
	      result = FALSE;

	   if (lv < small_val (q -> data))
	     result = FALSE;

	  q = q -> forward;
	}

/* now check the last pair and the upper limit */
	lv = small_val (q -> data);
	hv = larg_val  (q -> data);
	if (lv > hv)
	   result = FALSE;

	return result;
}

/*
 *	Check the completeness of a list of ranges
 */
bool	verif_domain (range, list, others)
ac	range;
p_link	list;
bool	others;
{
	int	lv,
		hv;

	if (range == NULL)
	   return FALSE;

	if (list == NULL)
	   return FALSE;

	if (!compl_domain (list, others))
	   return FALSE;

	if (others)
	   return TRUE;

	if (list -> forward == NULL)
	   return FALSE;

	lv = small_val (range);
	hv = small_val (head (list));

	if (lv != hv) {
	    error ("no match lowerbound domain and static range");
	    return FALSE;
	}

	lv = larg_val (range);
	hv = larg_val (tail (list));

	if (hv != lv) {
	    error ("no match upperbound domain and static range");
	    return FALSE;
	}

	return TRUE;
}

/*
 *	Check the variants in a variant record
 */
void	CHECK_VARIANT (t1, t2, s, t3)
ac	t1,
	t2,
	t3;
char	*s;
{
	if (!check_variant (g_fvariant (t1), t2)) {
	   error ("illegal ranges in variant of %s", g_tag (t3));
	   set_error (t3);
	}
}
/*
 * check_variant
 * check that the ranges specified as alternatives in a
 * variant part are complete
 * algorithms are same as in case statement
 */
static
bool	check_variant (variant_list, disc_type)
ac	variant_list,
	disc_type;
{
	ac	b;
	p_link	a;
	bool	others = FALSE;
	bool	result = TRUE;

	a = new_list ();

	while (variant_list != NULL) {
	   b = g_varchoice (variant_list);

	   while (b != NULL) {
	      s_rangetype (b, propagate (disc_type, g_rangetype (b)));

	      if (!td_range (b))
		  result = FALSE;
	      else
	      if (is_others (b))
	          others = TRUE;
	      else
	      if (!is_static (b))
	         result = FALSE;
	      else
	         l_insert (b, a);

	      b = g_next (b);
	    }

	    variant_list = g_next (variant_list);
	}

	if (result)
	   if (!verif_domain (stat_range (disc_type), a, others))
	        result = FALSE;

	rem_list (a);

	return result;
}

/*
 * for both record and array aggregates, sometimes a filter record
 * has to be constructed
 *
 * the following set of routines does the job for record aggregates
 *
 */

/*
 *	get the value of discriminant "discriminant", convert it
 *	to a manageable form and store it in disc_value
 */
static
bool	get_discrim (agg, discrim, a_disc_value)
ac	agg,
	discrim;
int	*a_disc_value;
{
	ac	walker,
		t,
		others = NULL;

	
	ASSERT (agg != NULL && g_d (agg) == XAGGREGATE, ("get_discrim_1"));

	FORALL (walker, g_fcompas (agg)) {
	   ASSERT (g_d (walker) == XCOMPASSOC, ("get_discrim_2"));

	   FORALL (t, g_fcompchoice (walker)) {

	      ASSERT (g_d (t) == XRANGE, ("get_discrim_3"));
	      ASSERT (!is_others (t), ("Still others in rec agg"));
/*
	      printf ("In get_discrim, looking for %s, found %s\n",
	               g_tag (discrim),
		       g_tag (g_fentity (g_primary (g_frang_exp (t)))) );
 */
	      if (g_fentity (g_primary (g_frang_exp (t))) == discrim) {
	         if (!is_static (g_compexpr (walker))) {
	            error ("static expression for %s expected in agg",
	                                   g_tag (discrim) );
	          *a_disc_value = (int)0;
	          return FALSE;
	         }

	         *a_disc_value = ord (g_primary (g_compexpr (walker)));
	         return TRUE;
	      }
	   }
	}

	*a_disc_value = (int)0;
	return FALSE;
}

/*
 * perf_select
 *	given a list of alternatives and its discriminant
 *	(and the aggregate where to find the discriminants value)
 *	do the selection, i.e. return the selected alternative
 */
static
ac	perf_select (variant_list, discriminant, aggregate)
ac	variant_list,
	discriminant,
	aggregate;
{
	ac	tmp,
		others = NULL;
	int	disc_value;

	if (variant_list == NULL)
	   return NULL;

	if (!get_discrim (aggregate, discriminant, &disc_value)) {
	   error ("illegal discriminant value in aggregate %s",
		             g_tag (encl_rectype (variant_list)));
	   set_error (aggregate);
	   return NULL;
	}

	while (variant_list != NULL) {
	   tmp = g_varchoice (variant_list);

	   while (tmp != NULL) {
	     if (is_others (tmp))
	        others = variant_list;
	     else
	     if ( (small_val (tmp) <= disc_value) &&
	            (disc_value <= larg_val (tmp) ))
	        return (variant_list);

	     tmp = g_next (tmp);
	   }

	   variant_list = g_next (variant_list);
	}

	return others;
}

/*
 *	Create the element of a discriminant
 */
static
ac	disc_elem (discriminant, agg)
ac	discriminant,
	agg;
{
	ac	t2,
		t,
		disctype = type_of (discriminant);
	int	temp;

	if (!get_discrim (agg, discriminant, &temp)) {
	   error ("illegal discr value in %s aggregate",
			g_tag ((ac)get_selecttype (g_aggtype (agg))) );
	   set_error (agg);
	   t = NULL;
	}
	else
	   t = cp_value (temp, disctype);

	t2 = mk_range (NULL, mk_expr (NULL, mk_applied (discriminant)), NULL);

	return  mk_component (t2, mk_expr (disctype, t));
}

/*
 *	Make a list of discriminants
 */
static
ac	disc_list (f_list, agg)
ac	f_list,
	agg;
{
	ac	x;

	if (f_list == NULL || !is_discr (f_list))
	   return NULL;

	x = disc_elem (f_list, agg);
	s_next (x, disc_list (g_next (f_list), agg));

	return x;
}

/*
 *	Do a single walk over the elements, check that all
 *	associations belong to something, remove the Others
 *	choice and normalize the aggregate
 */
static
ac	agg_nn (left, e)
ac	left,
	e;
{
	ac	t = mk_component (left, cp_tree (e));

	set_visited (t);

	if (!is_visited (left)) {
	   error ("Component association for %s ?",
			     tag_of (g_primary (g_frang_exp (g_fentity (left)))));
	}

	unvisit (left);

	if (g_next (left) != NULL)
	   s_next (t, agg_nn (g_next (left), e));

	s_next (t, NULL);

	return t;
}

static
ac	agg_unwind (ca)
ac	ca;
{
	ac	t1;

	t1 = g_fcompchoice (ca);

	if (g_next (t1) == NULL) {
	   unvisit (t1);
	   unvisit (ca);
	   return ca;
	}

	s_next (ca, agg_nn (g_next (t1), g_compexpr (ca)));
	s_next (t1, NULL);
	unvisit (ca);
	unvisit (t1);

	return ca;
}

static
ac	compass_check (agg)
ac	agg;
{
	ac	ca,
		r,
		t;
	bool	stat = TRUE;

	ASSERT (agg != NULL, ("compas_check: NULL"));

	FORALL (ca, g_fcompas (agg)) {
	   if (!is_visited (ca)) {
	      error ("Unbound component association");
	      return NULL;
	   }

	   ca = agg_unwind (ca);

	   stat &= is_static (g_compexpr (ca));
/*
 *	if the last compassoc is an "others", it is simply
 *	removed
 */
	  if (g_next (ca) != NULL &&
			g_fcompchoice (g_next (ca)) != NULL &&
				is_others (g_fcompchoice (g_next (ca)))) {
	      if (!is_visited (g_next (ca)))
	         warning ("Superfluous others choice in aggregate");

	      del_tree (g_next (ca));
	      s_next (ca, NULL);
	  }

	}

	if (stat)
	   set_static (agg);

	return agg;
}

/*
 *	agg_field (x, y, z)
 *
 *	given an aggregate x, locate the association
 *	to recordfield y, position from z in this locals list
 *
 *	If the association is positional, make it into a
 *	named one. If y is a discriminant check that
 *	the expression in the aggregate is a static one.
 *
 *	Used in "rec_agg" 
 *	do the top_down walk through a component association here
 */
static
ac	check_aggelem (agg, ca, defobject)
ac	agg,
	ca,
	defobject;
{
	ac	t;

	if (!is_visited (ca)) {
	   set_visited (ca);
	   t = g_compexpr (ca);
	   s_exptype (t, td_reduce (type_of (defobject), g_exptype (t)));

	   if (g_exptype (t) == NULL)
	      return NULL;

	   t = td_expr (t);
	   if (t == NULL)
	      return NULL;
	}

	if (base_type (type_of (defobject)) !=
	         base_type (g_exptype (g_compexpr (ca)))) {
	   error ("Incompatible types in aggregate assoc for %s",
						tag_of (defobject) );
	   return NULL;
	}

	return ca;
}


ac	agg_field (agg, object, pos_cnt)
ac	agg,
	object;
int	pos_cnt;
{
	ac	ca,
		r,
		tmp;
	int	lc;

	lc = 1;

	FORALL (ca, g_fcompas (agg)) {
	   if (lc < pos_cnt) {
	      lc ++;
	      continue;
	   }

	   if (g_fcompchoice (ca) == NULL)
	      if (lc == pos_cnt) {
	         r = mk_range (NULL, mk_expr (NULL, mk_applied (object)), NULL);
	         set_visited (r);
	         s_fcompchoice (ca, r);
	         ca = check_aggelem (agg, ca, object);
		 return ca;
	      }
	      else
		   warning ("illegal ordering rec aggregate comps");
	   else
	   if (!is_others (g_fcompchoice (ca)))
	      FORALL (r, g_fcompchoice (ca)) {
	         tmp = g_primary (g_frang_exp (r));
		 if (eq_tags (g_ident (g_fentity (tmp)),
						g_tag (object))) {
		    del_tag (g_ident (g_fentity (tmp)));
		    s_fentity (tmp, object);
	            set_visited (r);
		    ca = check_aggelem (agg, ca, object);
	            return ca;
	         }
	      }
	   else
	   { /* others choice, expand		*/
	      r = mk_range (NULL, mk_expr (NULL, mk_applied (object)), NULL);
	      tmp = mk_component (g_fcompchoice (ca), NULL);
	      s_fcompchoice (ca, r);
	      set_visited (r);
	      ca = check_aggelem (agg, ca, object);
	      s_compexpr (tmp, cp_tree (g_compexpr (ca)));
	      s_next (ca, tmp);
	      set_visited (tmp);
	      return ca;
	  }
	lc ++;
	}

	if (ca == NULL)
	   return NULL;		/* nothing found here */
}

/*
 *	check that all fields in a path of the
 *	type of an aggregate have an assocation,
 *	perform all selections necessary
 */
static
ac	get_imp (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (g_d (x) == XINCOMPLETE)
	   return get_imp (g_complete (x));

	if (g_d (x) == XPRIVTYPE)
	   return get_imp (g_impl (x));

	return x;
}

static
ac	check_rec (agg)
ac	agg;
{
	ac	component,
		curr_node;

	int	pos = 1;
	int	cnt;

	curr_node = get_selecttype (g_aggtype (agg));

	ASSERT (curr_node != NULL, ("no select type in check_rec"));

/*
 *	Careful: the aggregate may be on a type which has as a
 *	specification either an incomplete type or a private type
 *	The discriminants belong to the specification
 */

	if (g_d (curr_node) == XINCOMPLETE) {
	   FORALL (component, g_fidiscr (curr_node)) {
	      if (agg_field (agg, component, pos) == NULL) {
	         error ("No assoc for %s in aggregate", g_tag (component));
	         return NULL;
	      }
	      pos ++;
	   }

	   curr_node = get_imp (curr_node);
	}
	else
	if (g_d (curr_node) == XPRIVTYPE) {
	   if (!in_spec (curr_node)) {
	      error ("No aggregate for private type %s allowed\n", g_tag (curr_node));
	      return NULL;
	   }

	   FORALL (component, g_fpdiscr (curr_node)) {
	      if (agg_field (agg, component, pos) == NULL) {
	         error ("No assoc for %s in aggregate", g_tag (component));
	         return NULL;
	      }
	      pos ++;
	   }

	   curr_node = get_imp (curr_node);
	}

	cnt = pos;
	if (curr_node == NULL) {
	   error ("No aggregate allowed for type ");
	   return NULL;
	}

	ASSERT (g_d (curr_node) == XRECTYPE, ("check_rec: %d should be rectype",
						       g_d (curr_node)) );
	FORALL (component, g_ffield (curr_node)) {
	   cnt --;
	   if (cnt > 0)
	      continue;
/*
 *	Here we have skipped the specification
 */

	   if (g_d (component) == XVARIANT) {
	      curr_node = perf_select (component,
					   g_comp (g_dis (curr_node)), agg);
	      if (curr_node == NULL) {
		 error ("cannot select with %s",
				g_tag (g_comp (g_dis (g_enclunit (component)))));
		 return NULL;
	      }

	      component = g_ffield (curr_node);
	   }

	   if (g_d (component) == XSUBTYPE)
	      component = g_next (component);

	   if (agg_field (agg, component, pos) == NULL) {
	      error ("No assoc for %s in aggregate",
					g_tag (component));
	      return NULL;
	   }

	   pos++;
	}

	return agg;
}

/*
 *	guide the checks through a record aggregate,
 *	basically two:
 *		check that for each field in the
 *		corresponding type there is an assocation,
 *		check that for each assocation in the
 *		aggregate there is a field
 */
ac	rec_agg (agg, y)
ac	agg,
	y;
{
	int	stat_agg = TRUE;

	agg = check_rec (agg);
	if (agg == NULL)
	   return NULL;

	agg = compass_check (agg);
/*
 * he does the checking that the discriminants are reasonable
 */
/*
 *	norm takes care of normalizing the record aggregates
 *	i.e. a single left element per component association
 */
	return agg;
}

/*
 *	For array aggregates,
 *	the following cases are distinguished:
 *
 *	1: positional elements, the context has to
 *	   supply a domain specification for iteration
 *	2: an `others' assocation, again the
 *	   context has to specificy the domain
 *	   to use in an iteration
 *	3: (M..N => exp), (in general one association
	   with non-static expression) this case
 *	   can be transformed into a much simpler
 *	   equivalent case:
 *	      subtype X = base_type_of_aggregate (M..N)
 *	      ...X'(others => exp)
 *	   a filter (=domain generator here) is generated
 *	4: all other cases, named associations with
 *	   static indices.
 *	   sort the indeices, check on the usual way
 *	   that they are complete, take the first and
 *	   the last element from the domain and use them
 *	   to construct a filter.
 *
 *	y, the second parameter is a type obtained
 *	from the real context
 */

static
bool	res_compchoice	(r)
ac	r;
{
	char	*t;
	ac	p;

	ASSERT (r != NULL && g_d (r) == XRANGE, ("res_compchoice:1"));
	ASSERT (g_frang_exp (r) != NULL, ("res_compchoice:2"));

	t = g_ident (g_fentity (g_primary (g_frang_exp (r))));
	p = look_id (t);

	if (is_empty (p)) {
	   error ("index %s in aggregate ?", t);
	   s_frang_exp (r, NULL);
	   return FALSE;
	}
	else
	if (!is_singleton (p)) {
	   error ("index %s in aggregate ??", t);
	   s_frang_exp (r, NULL);
	   return FALSE;
	}
	else
	if (is_type (p)) {
	   s_rangetype (r, p);
	   s_frang_exp (r, NULL);
	   return TRUE;
	}
	else
	if (has_type (p)) {
	   s_rangetype (r, restypes (p));
	   s_frang_exp (r, bu_expr (mk_expr (NULL, mk_applied (p))));
	   return TRUE;
	}
	else
	{ error ("index %s in aggregate ???", t);
	  s_frang_exp (r, NULL);
	  return FALSE;
	}
}

static
bool	is_unresolved (r)
ac	r;
{
	ac	t;

	ASSERT (g_d (r) == XRANGE, ("is_unresolved"));

	if (g_frang_exp (r) == NULL)
	   return FALSE;

	t = g_frang_exp (r);
	if (g_primary (t) == NULL)
	   return FALSE;

	t = g_primary (t);

	if (g_d (t) != XNAME)
	   return FALSE;

	return g_d (g_fentity (t)) == XUNRESREC;
}


/*
 *	strictly local
 */
bool	unco_arr (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XARRAYTYPE:
	      return TRUE;

	   case XSUBTYPE:
	      return FALSE;

	   case XNEWTYPE:
	      return unco_arr (g_old_type (x));

	   case XINCOMPLETE:
	      return unco_arr (g_complete (x));

	   case XPRIVTYPE:
	      return unco_arr (g_impl (x));

	   DEFAULT (("unco_arr:2"));
	}
}

/*
 *	The cracker for array aggregates
 */
ac	arr_agg (agg, y)
ac	agg,
	y;
{
	ac	ca,
		ct,
		r,
		t,
		indtype;
	int	others_cnt = 0;
	int	pos_cnt = 0;
	bool	nstat_flag  = FALSE;
	bool	stat_agg    = TRUE;

	ASSERT (agg != NULL && g_d (agg) == XAGGREGATE, ("arr_agg:1"));

	t = get_arraytype (g_aggtype (agg));

	ASSERT (t != NULL, ("t = NULL in arr_agg"));

	indtype = get_indextype (t, 1);
	ca = g_fcompas (agg);
	ct = g_elemtype (t);

	if (g_fcompchoice (ca) == NULL) {	/* positional	*/
	   while (ca != NULL && g_fcompchoice (ca) == NULL) {
	      ac t1 = g_compexpr (ca);
	      pos_cnt ++;

	      s_exptype (t1, td_reduce (ct, g_exptype (t1)));

	      if (g_exptype (t1) == NULL) {
	         error ("Type error in aggregate component");
	         return NULL;
	      }

	      t1 = td_expr (t1);

	      if (t1 == NULL)
	         return NULL;

	      stat_agg &= is_static (t1);
	      ca = g_next (ca);
	   }
/*
 *	and now for something ....
 */

	   if (ca != NULL && g_fcompchoice (ca) != NULL)	/* named	*/
	      if (!is_others (g_fcompchoice (ca))) {
	         error ("Illegal mix named and positional choices");
	         return NULL;
	      }
	      else
	         others_cnt ++;

	   goto Lx;		/* I'm deeply sorry for this	*/
	}

L_named:
	while (ca != NULL) {
	   ac t1 = g_compexpr (ca);
	   r = g_fcompchoice (ca);
	   while (r != NULL) {
	      if (is_unresolved (r))
	         if (!res_compchoice (r)) {
	            error ("Aggregate choice illegal");
		    return NULL;
	         }
	      if (!is_others (r)) {
	         r = bu_expr (r);
	         if (r == NULL)
	            return NULL;

	         s_rangetype (r, td_reduce (indtype, g_rangetype (r)));

		 if (g_rangetype (r) == NULL) {
		    error ("Type error in named associations");
	            return NULL;
	         }

	         r = td_range (r);
	         if (r == NULL)
	            return NULL;

	         if (!is_static (r))
	            nstat_flag = TRUE;
	      }
	      else
	         others_cnt ++;
	      r = g_next (r);
	   }

	  s_exptype (t1, td_reduce (ct, g_exptype (t1)));

	  if (g_exptype (t1) == NULL) {
	     error ("Tyep error in aggregate component");
	     return NULL;
	  }

	  t1 = td_expr (t1);
	  if (t1 == NULL)
	     return NULL;

	  if (is_static (t1))
	     stat_agg &= TRUE;

	  ca = g_next (ca);
	}
Lx:
/*
 *	now for the hard part:
 *	check flags and decide whether or not a filter
 *	is to be made
 */
	if (others_cnt != 0) {
           if (unco_arr (y)) {
	      error ("Cannot have others in aggregate for type %sN", g_tag (t));
              return NULL;
	   }
	   return agg;
	}

	if (nstat_flag) {
	/* o.k. first the check, then go get the M..N stuf
	 * and make it into a filter
	 */
	   ca = g_fcompas (agg);
	   if (g_next (ca) != NULL ||
	             g_next (g_fcompchoice (ca)) != NULL) {
	      error ("Illegal set of non-static componebt choices");
	      return NULL;
	   }
	   s_aggtype (agg, mk_indconstr (g_aggtype (agg), g_fcompchoice (ca)));
	   s_fcompchoice (ca, mk_range (NULL, NULL, NULL));

/*
 *	Reaching the end of the then clause for the nstat_flag test
 */
	}
	else
	if (pos_cnt != 0) {
	   int low, high;
	   ac t1, t2, t3;

	  low = small_val (stat_range (indtype));
	  high= low + (pos_cnt - 1);

	  t1 = mk_expr (indtype, cp_value (low, indtype));
	  t2 = mk_expr (indtype, cp_value (high, indtype));
	  set_static (t1);
	  set_static (t2);

	  t3 = mk_range (indtype, t1, t2);
	  set_static (t3);

	  s_aggtype (agg, mk_indconstr (g_aggtype (agg), t3));
	}
	else
	/*
	 * walk again along the list, enter all static expressions
	 * into a single list, check, check ....
	 */
	{ p_link dom_list = new_list ();
	  ac t1, t2, t3;
	  FORALL (ca, g_fcompas (agg))
	     FORALL (r, g_fcompchoice (ca))
	        l_insert (r, dom_list);

	  if (!compl_domain (dom_list, FALSE)) {
	     error ("Incomplete domain in aggregate for %s",
	                        g_tag (t));
	          rem_list (dom_list);
		  return NULL;
	  }

	  t1 = mk_expr (indtype,
	                       cp_value (small_val (head (dom_list)), indtype));
	  t2 = mk_expr (indtype,
			       cp_value (larg_val (tail (dom_list)), indtype));

	  set_static (t1);
	  set_static (t2);

	  t3 = mk_range (indtype, t1, t2);
	  set_static (t3);

	  s_aggtype (agg, mk_indconstr (g_aggtype (agg), t3));
	  rem_list (dom_list);
	}


	stat_agg &= (others_cnt == 0 && !nstat_flag);
	if (stat_agg)
	   set_static (agg);

	return agg;
}

static
ac	mk_indconstr (type, firstrange)
ac	type,
	firstrange;
{
	ac	t1,
		t2;

	t1 = nalloc (XINDEXCONS);
	s_frange (t1, firstrange);
	t2 = nalloc (XFILTER);
	s_filtype (t2, type);
	s_constraint (t2, t1);

	return t2;
}

