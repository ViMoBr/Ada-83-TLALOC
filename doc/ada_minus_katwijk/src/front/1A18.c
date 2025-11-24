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
 *	Generic instantiations
 */

/*
 *	Get a default value for generic parameter x.
 *	One special case: if x happens to be a BOX parameter
 *	then look into the current surroundings for an actual
 *	with the same tag (renaming)
 */
static
bool	def_generic (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;	/* should not happen	*/

	if (g_d (x) == XSUB)
	   return has_sdefault (x);

	if (g_d (x) != XOBJECT)
	   return FALSE;

	if (g_desc (x) == NULL)
	   return FALSE;	/* Just to be sure	*/

	return g_expr (g_desc (x)) != NULL;
}

/*
 * get_genpar:
 *	find a parameter with a tag t
 */
static
ac	get_genpar (f, tag)
ac	f;
char	*tag;
{	ac	x;
	short	d;

	if (f == NULL) return NULL;
	d = g_d (f);
	ASSERT (g_d (f) == XGENNODE, ("get_genpar"));

	FORALL (x, g_genpars (f)) {
	   if (eq_tags (tag, g_tag (x)))
	      return x;
	}
	return (NULL);
}

/*
 *	get_pgenpar
 *	find a parameter on position pos.
 */
static
ac	get_pgenpar (f, pos)
ac	f;
int	pos;
{	ac	x;
	int	i = 1;
	short	d;

	if (f == NULL)
           return (NULL);

	ASSERT (g_d (f) == XGENNODE, ("get_pgenpar"));
	pos --;
	FORALL (x, g_genpars (f)) {
	   if (pos == 0)
	      return x;

	   pos --;
	}

	return NULL;
}

static
ac	genunit (t)
ac	t;
{
	ac	t1;

	if (t == NULL)
	   return NULL;

/*
	p_table ("Just checking for instantiation");
 */
	t1 = td_n_name (bu_name (t));
	if (t1 == NULL) {
	   error ("Cannot locate proper generic unit name");
	   return NULL;
	}

	if (g_d (t1) != XNAME) {
	   error ("Name construction too complex in generic unit");
	   return NULL;
	}

	if (g_fentity (t1) == NULL ||
	    g_d (g_fentity (t1)) != XGENNODE) {
	   error ("Name construction not yielding a generic unit");
	   return NULL;
	}

	return g_fentity (t1);
}

/*
 *	Find in actlist the element bound to
 *	the elno-th formal (being forel)
 */
static
ac	get_xy (actlist, forel, elno)
ac	actlist,
	forel;
int	elno;
{
	while (actlist != NULL) {
	   if (!is_positional (actlist))
	      break;
	   if (elno == 1)
	      return actlist;
	   elno --;
	   actlist = g_next (actlist);
	}

	while (actlist != NULL) {
	   ASSERT (g_d (actlist) == XNAMEDASS, ("Illegal structuring ge par"));
	   if (eq_tags (g_parname (actlist), g_tag (forel)))
	      return actlist;
	   actlist = g_next (actlist);
	}

	return NULL;
}


static
ac	reb_elem (actlist, forel, elno)
ac	actlist;
ac	forel;
int	elno;
{
	ac	t,
		x;

	t = get_xy (actlist, forel, elno);
	if (t == NULL) {
	   if (def_generic (forel)) {
	      t = mk_namass (forel, NULL);	/* implicit encoding	*/
						/* of default		*/
	      return t;
	   }
	   else
	   { error ("Generic call: cannot bind formal %s\n", g_tag (forel));
	     return NULL;
	   }
	}

	if (is_positional (t)) {
	   t = mk_namass (forel, t);
	}
	else
	{ del_tag (g_parname (t));
	  s_parname (t, forel);
	}

	return t;
}

static
ac	rebind (actlist, forlist, elno)
ac	actlist,
	forlist;
int	elno;
{
	ac	t;

	if (forlist == NULL)
	   return NULL;

	t = reb_elem (actlist, forlist, elno);
	s_next (t, rebind (actlist, g_next (forlist), elno + 1));
	return t;
}


static
ac	generic_call (t)
ac	t;
{	extern	ac td_genpar	();
	ac	t1,
		t2,
		t3,
		t4;
	int	act_cnt = 0;
	int	nr_pos  = 0;
	ac	form;
	ac	act;
	ac	fnamed;

	if (t == NULL)
	   return NULL;

	ASSERT (g_d (t) == XCALL, ("Call expected here"));

	t1 = genunit (g_next (t));
	if (t1 == NULL) {
	   return NULL;
	}

	t2 = g_genpars (t1);

	act = g_fact (t);
	while (act != NULL) {
	   act_cnt ++;
	   act = g_next (act);
	}

	act = g_fact (t);
	while (act != NULL && is_positional (act)) {
	   nr_pos ++;
	   form = get_pgenpar (t1, nr_pos);
	   if (form == NULL) {
	      error ("Too much actual parameters for generic unit %s\n",
		                                 g_tag (t1));
	      return NULL;
	   }
	   t4 = bu_expr (act);
	   if (t4 == NULL) {
	      return NULL;
	   }

	   act = g_next (act);
	}

	nr_pos ++;	/* indicates where we are		*/
	while ((form = get_pgenpar (t1, nr_pos ++)) != NULL) {
	   fnamed = act;
	   while (fnamed != NULL) {
	      if (eq_tags (tag_of (form), g_parname (fnamed))) {
	         t4 = bu_expr (fnamed);
	         if (t4 == NULL) {
	            return NULL;
	         }
	         break;
              }
	      fnamed = g_next (fnamed);
	   }
	   if (fnamed == NULL && !def_generic (form)) {
	      error ("Generic call: unbound parameter for %s\n", g_tag (form));
	      return NULL;
	   }
	}

	if (act_cnt >= nr_pos) {	/* Again, too mucg actuals	*/
	   error ("Too much actuals for generic call %s\n", g_tag (t1));
	   return NULL;
	}

	s_fact (t, rebind (g_fact (t), g_genpars (t1), 1));

	/* Now process all actuals in a proper order	*/
	FORALL (t2, g_fact (t)) {
	   if (td_genpar (g_fact (t), t2) == NULL)
	      return NULL;
	}
	return t;
}


ac	instantiate (s, t)
char	*s;
ac	t;
{
	t = generic_call (t);
	if (t == NULL) {
	   error ("Unit %s not instantiated\n", s);
	   return;
	}

	return expand (s, t);
}

/*
 *	Convence the actual parameter act and the corresponding
 *	formal parameter form that they do not hate each other
 *	Do the top-down walk through the actual
 */
static
int	genparkind (x)
ac	x;
{
	int	v;

	if (x == NULL)
	   return 0;

	ASSERT (g_d (x) == XNAMEDASS, ("named ass expected (%d)", g_d (x)) );

	v = g_d (g_parname (x));
	/* For now:
	 */
	return v;
}

ac	td_genpar (actlist, act)
ac	actlist;
ac	act;
{	static	bool	gen_eqsubs ();
	static	bool	geneqtypes ();
	static	ac	find_gensubs	();
	static	ac find_ids	();

	ac	t1,
		t2,
		t3,
		temp,
		x;

	if (act == NULL) {	/* cannot happen			*/
	   return NULL;
	}

	if (g_nexp (act) == NULL) {	/* default parameter		*/
	   x = g_parname (act);
	   if (x == NULL) {		/* null			*/
	      return NULL;
	   }

	   if (g_d (x) == XOBJECT) {
	      s_nexp (act, cp_tree (type_of (x), g_expr (g_desc (x))));
	   }
	   else
	   if (g_d (x) == XSUB) {
	      if (has_sdefault (x)) {
	         t1 = find_ids (g_tag (x));
	         s_nexp (act, mk_expr (NULL, find_gensubs (actlist, x, t1)));
	         return act;
	      }
	      else
	      { s_nexp (act, mk_expr (NULL, cp_tree (g_sub_default (x))));
	        return act;
	      }
	  }
	ASSERT (FALSE, ("What am I doing here\n"));
	}

	switch (genparkind (act)) {
	case XOBJECT:
		if (!solve_expr (g_nexp (act), type_of (g_parname (act)))) {
	           error ("Error in actual for %s\n", g_tag (g_parname (act)));
		   return NULL;
		}
		return act;

	case XARRAYTYPE:
	case XACCTYPE:
		if (!is_name (g_primary (g_nexp (act)))) {
		   error ("Illegal construction corresponds to generic par %s\n",
                                               g_tag (g_parname (act)) );
                }
		t2 = td_n_name (g_primary (g_nexp (act)));
		t1 = type_name (t2);
		if (t1 == any_type)
		   return NULL;
		s_primary (g_nexp (act), t2);
		if (!geneqtypes (actlist, g_parname (act), t1)) {
		   error ("Non-matching actual generic parameter types (%s)\n",
		                              g_tag (g_parname (act)));
		   return NULL;
		}
		return act;

	case XGENPARTYPE:
		if (!is_name (g_primary (g_nexp (act)))) {
		   error ("Illegal construction corresponds to generic par %s\n",
                                              g_tag (g_parname (act)));
		}
		t2 = td_n_name (g_primary (g_nexp (act)));
		t1 = type_name (t2);
		if (t1 == any_type)
		   return NULL;
		s_primary (g_nexp (act), t2);
		
		if ((g_flags (t1) & LIMIT) == LIMIT) {
		   return NULL;
		}

		return act;

	case XSUB:
		temp = NULL;	/* empty set actually	*/
		temp = find_gensubs (actlist,
			             g_parname (act), g_primary (g_nexp (act)));
		if (temp == NULL) {
		   error ("No suitable actual for generic parameter %s\n",
			                              g_tag (g_parname (act)));
		   return NULL;
		}
		ASSERT (g_d (temp) == XNAME, ("td_genpar:1"));
		if (!is_singleton (g_types (temp))) {
		   error ("More than a single actual for generic param %s\n",
				                      g_tag (g_parname (act)));
		   return NULL;
		}

		s_primary (g_nexp (act), temp);
		s_exptype (g_nexp (act), g_types (temp));
		return act;

	default:
		error ("Unimplemented generic parameter for %s\n",
					g_tag (g_parname (act)) );
		return NULL;
	}
}

/*
 *	Check whether or not a type a_t is compatible
 *	with the generic type g_t;
 *	gen_setypes (l, x1, x2)
 *	investigate whether or not the types x1 and
 *	x2 are equal (in some sense). Take care:
 *	structural equivalence applies here
 *	gen_setypes is called for the secondary checks,
 *	i.e. for each generic parameter type it takes
 *	the real actual type
 *
 */
static
ac	get_act (l, x1)
ac	l,
	x1;
{
	if (x1 == NULL)
	   return NULL;

	while (l != NULL) {
	   if (x1 == g_parname (l))
	      return type_name (g_primary (g_nexp (l)));
	   l = g_next (l);
	}

	return NULL;
}

static
bool	gen_xxtypes (x1, x2)
ac	x1,
	x2;
{
	if (x1 == NULL || x2 == NULL)
	   return FALSE;

	if (is_anytype (x2)) {
	   if (match_univ (x1, x2))
	      return TRUE;
	}

	if (is_anytype (x1)) {
	   if (match_univ (x2, x1))
	      return TRUE;
	}

	return x1 == x2;
}

static
bool	gen_setypes (l, x1, x2)
ac	l,
	x1,
	x2;
{
	if (x1 == x2)
	   return TRUE;

	if (x1 == NULL || x2 == NULL)
	   return FALSE;

	if (!is_type (x1) || !is_type (x2))
	   return FALSE;

	if (g_d (g_enclunit (x1)) != XGENNODE)
	   return gen_xxtypes (base_type (x1), base_type (x2));

	return gen_xxtypes (base_type (get_act (l, x1)), base_type (x2));
}

static
bool	geneqtypes (l, x1, x2)
ac	l,
	x1,
	x2;
{
	ac	t1,
		t2,
		t3;

	if (x1 == NULL || x2 == NULL)
	   return FALSE;

	if (!is_type (x1) || !is_type (x2))
	   return FALSE;

	if (g_d (x1) == XGENPARTYPE) {
	   switch (g_genkind (x1)) {
	      case NEWINTTYPE:
		   return is_someinteger (x2);

	      case GENPRIVTYPE:
		   return has_eq_and_ass (x2);

	      case SCALARTYPE:
		   return is_scalar (x2);

	      default:
		   error ("Strange generic formal type %s\n", g_tag (x1));
		   return FALSE;

	   }
	}

	if (g_d (x1) == XARRAYTYPE) {
	   t1 = get_arraytype (x2);
	   if (t1 == NULL)
	      return FALSE;

	   if (!gen_setypes (l, g_elemtype (x1), g_elemtype (x2)))
	      return FALSE;

	   t2 = g_findex (x1);
	   t3 = g_findex (x2);

	   while (t2 != NULL && t3 != NULL) {
	      if (!gen_setypes (l, g_indextype (t2), g_indextype (t3)))
	         return FALSE;
	      t2 = g_next (t2);
	      t3 = g_next (t3);
	   }

	   return t2 == t3; /* (== NULL) */
	}

	return FALSE;
}

static
bool	gen_eqsubs (l, x1, x2)
ac	l,
	x1,
	x2;
{
	ac	p1,
		p2;

	if (x1 == NULL || x2 == NULL)
	   return FALSE;

	if (!is_sub (x2))
	   return FALSE;

	ASSERT (is_sub (x1), ("sub formal expected"));

	if (!gen_setypes (l, g_rettype (x1), g_rettype (x2)))
	   return FALSE;

	p1 = f_formal (x1);
	p2 = f_formal (x2);

	while (p1 != NULL && p2 != NULL) {
	   if (!gen_setypes (l, type_of (p1), type_of (p2)))
	      return FALSE;
	   p1 = g_next (p1);
	   p2 = g_next (p2);
	}
	return p1 == p2; /* (== NULL) */
}

ac	find_ops (s)
char	*s;
{
	ac	t;

	if (std_oper (s) == (byte)0) {
	   error ("%s not a standard operator\n", s);
	   return NULL;
	}

	t = mk_unresrec (s);
	t = mk_applied (t);
	return bu_name (t);
}

static
ac	find_ids (s)
char	*s;
{
	return bu_name (mk_applied (mk_unresrec (s)));
}

static
ac	find_gensubs (actlist, specif, ents)	/* NULL erroneous */
ac	actlist;
ac	specif;
ac	ents;
{
	ac	t,
		y;
	ac	temp = NULL;

	extern bool is_stringlit ();

	if (specif == NULL || ents == NULL)
	   return NULL;

	if (g_d (ents) == XLITERAL) {	/* It better be a string literal */
	   if (!is_stringlit (ents)) {
	      error ("Illegal form of generic subprogram parameter");
	      return NULL;
	   }
	   ents = find_ops (g_val (ents)-> litvalue);
	}
	FORSET (y, g_types (ents)) {
	   if (is_sub (y)) {
	      if (gen_eqsubs (actlist, specif, y))
	         temp = join (y, temp);
	   }
	   else
	   if (is_entype (y)) {
	      if ((y == restypes (specif) && is_paramless (specif))) {
	         if (g_d (ents) != XNAME && g_d (ents) != XSELECT)
	            temp = join (y, temp);
	      }
	   }
	}
	del_set (g_types (ents));
	s_types (ents, temp);
	if (!is_singleton (temp)) {
	   error ("Cannot solve actual generic parameter for %s\n",
				                         g_tag (specif));
	   return NULL;
	}

	t = td_n_name (ents);
	if (t == NULL) {
	   error ("Cannot solve (2) actual for generic %s\n",
			                                g_tag (specif));
	   return NULL;
	}

	if (is_entype (temp)) {
	   if (g_d (t) != XNAME || g_d (g_fentity (t)) != XENUMLIT) {
	      error ("Cannot apply %s with arbitrary construction\n",
		                                        g_tag (specif));
	      return NULL;
	   }
	}

	return t;
}


