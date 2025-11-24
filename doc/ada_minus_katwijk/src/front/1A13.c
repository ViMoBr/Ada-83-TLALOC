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
 *	Forward (static) declaration
 */
static	bool	has_default	();
static	bool	eq_trip		();
static	ac	mx_trip		();
static	ac	new_trip	();
static	bool	parfits		();
static	bool	par_match	();
static	ac	param		();
static	ac	g		();
static	bool	fits		();
/*static*/	bool	try_sub		();

static
bool	has_default (x)
ac	x;
{
	ASSERT (x != NULL && g_d (x) == XOBJECT, ("has_default"));

	if (g_desc (x) == NULL)
	   return FALSE;

	return g_expr (g_desc (x)) != NULL;
}

/*
 *	Make a pointer into either NULL or a pointer to a triple
 */
ac	get_triple (x)
ac	x;
{
	if (g_d (x) == XTRIPLE) {
	   return x;
	}
	return NULL;
}

/*
 *	reduce the set of triples, taking the notes
 *	of page 72 of Ada- into account
 */
ac	reduce_triples (temp)
ac	temp;
{
	if (temp == NULL)
	   return NULL;

	if (g_tripnext (temp) == NULL)
	   return temp;

	printf ("Hier moeten de hiding regels worden toegepast");

	return reduce_triples (g_tripnext ((ac)temp));
}

/*
 *	Reduce the set of triples tripset by taking into
 *	account the required return type rettypes
 */
ac	red_tripset (tripset, rettypes)
ac	tripset,
	rettypes;
{
	ac	trip = NULL;
	ac	tripel;

	for (tripel = tripset;
	     tripel != NULL;
	     tripel = g_tripnext (tripel))  {
	  if (g_d (tripel) != XTRIPLE)
	     continue;

	  if (rettypes == notype) {
	     if (eff_rettype (tripel) == notype) {
		  trip = new_trip (g_tripsub (tripel),
		                   g_triptype (tripel),
		                   g_tripdtype (tripel), trip);

	     }
	  }
	  else
	  if (is_anytype (eff_rettype (tripel))) {
	     if (fits (rettypes, eff_rettype (tripel))) {
		trip = new_trip (g_tripsub (tripel),
		                  g_triptype (tripel),
		                  g_tripdtype (tripel), trip);
	     }
	  }
	  else
	  if (is_element (eff_rettype (tripel), rettypes)) {
	     trip = new_trip (g_tripsub (tripel),
		              g_triptype (tripel),
		              g_tripdtype (tripel), trip);
	  }
	}

	del_tripels (tripset);

	return trip;
}

/*
 *	For debugging purposes
 */
void	pr_tripels (t)
ac	t;
{
	while (t != NULL) {
	   PRINTF ((printf ("%s %d %X %X\n", g_tag (g_tripsub (t)),
						  g_tripmark (t),
						  g_triptype (t),
						  g_tripdtype (t) )));
	   t = g_tripnext (t);
	}
}

/*
 *	delete a set of triplles
 */
void	del_tripels (t)
ac	t;
{
	ac	a_t;

	while (t != NULL) {
	   a_t = g_tripnext (t);
	   cfree (t);
	   t = a_t;
	}
}

/*
 *	Given a triple t, compute the actual return type
 */
ac	eff_rettype (t)
ac	t;
{
	ac	h,
		tt;

	ASSERT (t != NULL && g_d (t) == XTRIPLE, ("eff_rettype"));

	h = g_tripsub (t);

	if (g_d (h) == XENTRY)
	   return notype;
	else
	if (g_d (h) == XINHERIT) {
	   tt = restypes (g_inh_oper (h));

	   if (eq_types (tt, g_old_type (h)))
	      return g_inh_type (h);
	   else
	      return tt;
	}
	else
	   return g_rettype (h) == g_triptype (t) ?
			        g_tripdtype (t) : g_rettype (h);
}

/*
 *	Concatenate two sequences of triples, remove t1
 */
ac	cat_trips (t1, t2)
ac	t1,
	t2;
{
	ac	ts = t1;

	if (t1 == NULL)
	   return t2;

	if (t2 == NULL)
	   return t1;

	while (g_tripnext (ts) != NULL)
	   ts = g_tripnext (ts);

	s_tripnext (ts, t2);
	return t1;
}

/*
 *	make a new triple (includes some local functions
 *	the new triple is linked in front of a_t
 */
static
bool	eq_trip (t, sub, ft, tt)
ac	t,
	sub,
	ft,
	tt;
{
	if (t == NULL)
	   return FALSE;

	ASSERT (g_d (t) == XTRIPLE, ("eq_trip"));

	if (g_tripsub (t) != sub)
	   return FALSE;

	return eq_types (g_tripdtype (t), tt) &&
	       eq_types (g_tripdtype (t), ft);
}

static
ac	mx_trip (sub, t1, ft)
ac	sub,
	t1,
	ft;
{
	ac	t;

	t = (ac)calloc (1, sizeof (struct _triple));
	s_d (t, XTRIPLE);
	s_tripsub (t, sub);
	s_triptype (t, t1);
	s_tripdtype (t, ft);

	return t;
}

static
ac	new_trip (sub, t, ft, a_t)
ac	sub,
	ft,
	t,
	a_t;
{
	ac	t1,
		tt;

	PRINTF ((printf ("in new_trip: %s %X %X %X\n", sub, t, ft, *a_t) ));
/*
 *	First check whether or not an "equivalent" tripel exists
 */
	if (base_type (ft) == base_type (t)) {
	   t = NULL;
	   ft = NULL;
	}

	t1 = a_t;
	while (t1 != NULL) {
	   if (eq_trip (t1, sub, ft, t))
	      return a_t;
	   t1 = g_tripnext (t1);
	}

	tt = mx_trip (sub, t, ft);	/* temp member	*/

	PRINTF ((printf ("added %s %X %X\n", g_tag (sub), t, ft) ));

	s_tripnext (tt, a_t);
	return tt;
}

/*
 *	The actual checking is done in the following function
 *	It takes a specification of a subprogram and a list
 *	of actual parameters.
 *	Notice that the list of actuals may be anything
 *	The yield of the function is a list of viable triples
 */
ac	chk_sub (sub, acts)
ac	sub,
	acts;
{
	ac	act,
		x,
		form,		/* pointer to formal		*/
		temp = NULL,
		trip = NULL;
	int	act_cnt = 0;
	int	nr_pos  = 0;

	ac	fnamed;

	act = acts;

	while (act != NULL) {
	   act_cnt ++;
	   act = g_next (act);
	}

	act = acts;

	while (act != NULL && is_positional (act)) {
	   nr_pos ++;
	   form = get_pformal (sub, nr_pos);
	   if (form == NULL) {	/* too high		*/
	      del_tripels (trip);
	      return NULL;
	   }

	   trip = cat_trips (trip, param (sub, type_of (form), type_of (act)));
	   act = g_next (act);
	}

	nr_pos ++;	/* indicates where we are		*/
	while ((form = get_pformal (sub, nr_pos ++)) != NULL) {
	   fnamed = act;

	   while (fnamed != NULL) {
	      if (eq_tags (tag_of (form), g_parname (fnamed))) {
	         trip = cat_trips (trip, param (sub, type_of (form),
                                                       type_of (fnamed) ));
	         break;
	      }

	      fnamed = g_next (fnamed);
	   }

	   if (fnamed == NULL && !has_default (form)) {
	      del_tripels (trip);
	      return NULL;
	   }

	}

	if (act_cnt >= nr_pos) {	/* too much actuals	*/
	   del_tripels (trip);
	   return NULL;
	}

/*
 *	If we are here then something is left. For each element
 *	in the triple set we try to "solve" the call; if
 *	a triple is not viable, it will be marked
 */

	temp = NULL;	/* clean up the mess			*/
	PRINTF ((printf ("in chk_sub, calling try_sub for:\n") ));

	pr_tripels (trip);

	for (x = (ac)trip; x != NULL; x = g_tripnext (x)) {
	   if (try_sub (g_tripsub (x), g_triptype (x), g_tripdtype (x), acts))
	      temp = new_trip (g_tripsub (x),
		                 g_triptype (x),
		                 g_tripdtype (x), temp);

	}

	del_tripels (trip);
	return temp;
}

/*
 *	parfits, check the legality of a set of actual parameter
 *	types vs a formal parameter type
 */
static
bool	parfits (actt, mt)
ac	actt,
	mt;
{
	ac	t;

	mt = base_type (mt);

	FORSET (t, actt) {
	   if (bsf_type (t) == bsf_type (mt))
	      return TRUE;

	   if (is_anytype (bsf_type (t)) &&
		          match_univ (bsf_type (mt), bsf_type (t))) {
	      return TRUE;
	   }
	}

	return FALSE;
}
/*
 *	Is there a match between a formal parameter type partype
 *	and an actual parameter type acttype
 */
static
bool	par_match (partype, acttype)
ac	partype,
	acttype;
{
	if (base_type (partype) == base_type (acttype))
	   return TRUE;

	ASSERT (!is_anytype (partype), ("parmatch: illegal anytype"));

	if (is_anytype (acttype))
	   return match_univ (partype, acttype);

	return FALSE;
}

/*
 *	Construct a set of viable triples for a given parameter
 *	in a function or subprogram
 */
static
ac	param (sub, partype, acttypes)
ac	sub,
	partype,
	acttypes;
{
	ac	triplist = NULL;
	ac	t,
		t1,
		t2;

	partype = base_type (partype);

	PRINTF ((printf ("param %s %s\n", g_tag (sub), g_tag (partype)) ));

	if (is_derived (sub)) {
	   if (base_type (partype) == base_type (g_old_type (sub))) {
	      FORSET (t, acttypes) {
	         if (par_match (g_inh_type (sub), t))
	            triplist = new_trip (sub, partype, t, triplist);
	      }

	      return triplist;
	   }
	   else
	      return NULL;
	}

	if (is_anytype (partype)) {
	   FORSET (t, acttypes)
	      if (match_univ (t, partype))
	         triplist = new_trip (sub, partype, base_type (t), triplist);
	}
	else
	FORSET (t, acttypes)
	   if (par_match (partype, t))
	      triplist = new_trip (sub, partype, partype, triplist);

	return triplist;
}

/*
 *	pl_call
 *	Called with a NAME node. Check whether to make a function
 *	of it
 */
static
ac	g(x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	while (g_d (x) == XINHERIT)
	   x = g_inh_oper (x);

	return x;
}

ac	pl_call (node)
ac	node;
{
	ac	t1;

	if (node == NULL)
	   return NULL;

	if (g_d (node) == XNAME) {	/* take parameterless call	*/
	   if (is_call (node) && is_paramless (g_fentity (node))) {
	      s_fentity (node, g (g_fentity (node)));	/* remove XINHERIT	*/
	      t1 = mx_call (g_types (node), NULL);
	      s_next (t1, node);
	      s_fact (t1, act_list (f_formal (g_fentity (node)), NULL));
	      return repl_func (t1);
	   }

	}

	return node;
}

/*
 *	
 *	purpose: to implement "derived" types in a more or
 *	less proper way
 */
static
bool	fits (rettypes, eff_type)
ac	rettypes,
	eff_type;
{
	ac	t;

	FORSET (t, rettypes)
	    if (match_univ (t, eff_type))
	       return TRUE;

	return FALSE;
}

/*
 *	Check to see whether or not a triple, of which the
 *	three components are passed as a parameter, is valid
 *	with a given actual parameter list
 */
/*
static*/
bool	try_sub (sub, t, dt, acts)
ac	sub,
	t,
	dt,
	acts;
{
	ac	form,
		fnamed,
		act,
		matchtype;
	int	nr_pos	= 0;

	PRINTF ((printf ("in try_sub %s %X %X\n", g_tag (sub), t, dt) ));

	act = acts;
	while (act != NULL && is_positional (act)) {
	   nr_pos ++;
	   form = get_pformal (sub, nr_pos);
	   ASSERT (form != NULL, ("form == NULL"));

	   if (type_of (form) == t)
	      matchtype = dt;
	   else
	      matchtype = type_of (form);

	   if (!parfits (type_of (act), matchtype))
	      return FALSE;

	   act = g_next (act);
	}

	nr_pos ++;
	while ((form = get_pformal (sub, nr_pos ++)) != NULL) {
	   FORALL(fnamed, act) {
	      ASSERT (g_d (fnamed) == XNAMEDASS, ("Verkeerde param"));
	      if (eq_tags (tag_of (form), g_parname (fnamed))) {
	         if (type_of (form) == t)
	            matchtype = dt;
	         else
	            matchtype = type_of (form);
	         if (!parfits (type_of (fnamed), matchtype))
	            return FALSE;
	         break;
	      }
	   }

	   ASSERT (fnamed != NULL || has_default (form),
		        ("Problem in try_sub %s fnamed NULL", g_tag (sub)));

	}

	PRINTF ((printf ("try_sub successful %s %X %X\n", g_tag (sub), t, dt)));

	return TRUE;
}

