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
static	bool	seems_range	();
static	bool	convertable	();
static	bool	limprivtype	();
/*
 *	Predicates and predicate support
 */

bool	eq_types (x, y)
ac	x,
	y;
{
	if (x == NULL || y == NULL)
	   return FALSE;


	x = bsf_type (x);
	y = bsf_type (y);
	if (x == y)
	   return TRUE;

	if (g_d (y) == XTRIPLE) {
	   return x == g_tripsub (y);
	}

	if (g_d (x) == XTRIPLE) {
	   return y == g_tripsub (x);
	}

	return FALSE;
}

/*
 *	Is the subprogram denoted by the
 *	first parameter "equal" to the one
 *	implicitly denoted by the second (TRIPLE)
 *	parameter
 */
bool	sub_equal (x, y)
ac	x,
	y;
{
	ASSERT (x != NULL && y != NULL, ("sub_equal:1"));
	ASSERT (g_d (y) == XTRIPLE, ("sub_equal:2"));

	if (g_d (x) == XSUB)
	   return x == g_tripsub (y);

	if (g_d (x) == XINHERIT)
	   return x == g_tripsub (y);

	return FALSE;
}

/*
 *	check the selectability of ent in types tp
 *	kind indicates identifier vs character literal
 */
bool	ch_select (tp, ent, kind)
ac	tp,
	ent;
int	kind;
{
	ac	t,
		x,
		h;

	FORSET (x, ent) {
	   h = select (tp, g_tag (x), kind);

	   FORSET (t, h) {
	      if (t == x)
	         return TRUE;
	   }
	}

	return FALSE;
}

/*
 *	Is the appearance of x such that it can be used
 *	as a range ?
 */
static
bool	seems_range (x)
ac	x;
{
	ac	t;

	if (x == NULL)
	   return FALSE;

	if (g_d (x) == XRANGE)
	   return TRUE;

	if (g_d (x) == XNAME) {
	   FORSET (t, g_fentity (x)) {
	      if (is_type (t))
	         return TRUE;
	   }
	}

	if (g_d (x) == XEXP)
	   return seems_range (g_primary (x));


	return FALSE;
}

/*
 *	check the sliceability of the type t1
 *	with the (potential) range p
 */
bool	chk_slice (t1, p)
ac	t1,
	p;
{
	ac	t;

	if (t1 == NULL)
	   return FALSE;

	if (p == NULL)
	   return FALSE;

	ASSERT (get_arraytype (t1) != NULL, ("chk_slice"));

	t = get_indextype (t1, 1);
	if (t == NULL)
	   return FALSE;	/* should not happen	*/

	if (!is_element (type_of (p), t))
	   return FALSE;

	return seems_range (p);
}

/*
 *	check the indexability of the type t1
 *	with the expression p
 */
bool	chk_index (t1, p)
ac	t1,
	p;
{
	int	i = 1;
	ac	t;

	t1 = get_arraytype (t1);

	ASSERT (t1 != NULL, ("chk_index NULL"));
	while (p != NULL) {
	   t = get_indextype (t1, i);
	   if (t == NULL)
	      return FALSE;

	   if (!is_element (t, g_exptype (p)))
	      return FALSE;

	   i ++;
	   p = g_next (p);
	}

	return TRUE;
}

/*
 *	is the current context within the enclunit of t
 */
bool	in_spec (t)
ac	t;
{
	if (t == NULL)
	   return NULL;

	ASSERT (g_d (t) == XPRIVTYPE, ("in_spec %d\n", g_d (t)));

	return is_openscope (g_enclunit (t));
}

/*
 *	Check whether or not a name construction is a type conversion
 *	x: type to (???) convert to
 *	y: construction to be converted
 */
static
bool	convertable (x, y)
ac	x,
	y;
{
	if (x == NULL || y == NULL)
	   return FALSE;

	if (g_d (x) == XPRIVTYPE)
	   x = g_impl (x);

	if (g_d (y) == XPRIVTYPE)
	   y = g_impl (y);

	if (g_d (x) == XNEWTYPE)
	   while (g_d (x) == XNEWTYPE)
	      x = g_old_type (x);
	else
	   while (g_d (y) == XNEWTYPE)
	      y = g_old_type (y);


	if (eq_types (x, y))
	   return TRUE;

	if (is_numerical (x) && is_numerical (y))
	   return TRUE;

	if (arr_typesmatching (x, y))
	   return TRUE;

	return FALSE;
}

/*
 *	Check whether a type conversion between types x, y
 *	is possoble and whether thjere is a possibility
 *	that the left hand side, i.e. l, can be massaged
 *	into a type as required for a type conversion
 */
bool	chk_typeconv (l, x, y)
ac	l,
	x,
	y;
{
	ac	a,
		b;
	bool	f = FALSE;

	if (x == NULL)
	   return FALSE;

	if (l == NULL)
	   return FALSE;

	FORSET (a, x)
	   FORSET (b, type_of (y))
              if (convertable (a, b))
	         f = TRUE;
	
	if (!f)
	   return FALSE;	/* not two types convertable	*/

	if (g_d (l) == XNAME) {
	   FORSET (a, g_fentity (l)) {
	      if (is_type (a))
	         return TRUE;
	   }
	   return FALSE;
	}
	else
	if (g_d (l) == XSELECT) {
	   FORSET (a, g_entity (l)) {
	      if (is_type (a))
	         return TRUE;
	   }
	   return FALSE;
	}

	return FALSE;
}

/*
 *	td check for type conversion
 */
bool	td_tpconv (l, t1, t2)
ac	l,
	t1,
	t2;
{
	ac	x;

	if (t1 == NULL)
	   return FALSE;

	if (l == NULL)
	   return FALSE;

	if (!eq_types (t1, t2))
	   return FALSE;

	switch (g_d (l)) {
	   case XNAME:
		FORSET (x, g_fentity (l))
		   if (is_type (x))
		      return TRUE;
		return FALSE;

	   case XSELECT:
		FORSET (x, g_entity (l))
		   if (is_type (x))
		      return TRUE;
		return FALSE;

	   default:
		return FALSE;
	}
}

/*
 *	match universal with ordinary type
 */
bool	match_univ (t, univ_type)
ac	t,
	univ_type;
{
	if (t == NULL)
	   return FALSE;

	ASSERT (univ_type != NULL && g_d (univ_type) == XINTERNAL, ("match:1"));

	t = bsf_type (t);

	if (!has_eq_and_ass (t))
	   return FALSE;

	switch (g_ind (univ_type)) {
	   case I_NO_TYPE:
	      return t == notype;

	   case I_UNIV:
	      return is_someinteger (t);

	   case I_ANY_TYPE:
	      return TRUE;

	   case I_ANY_BOOL_VECTOR:
	      return (is_bool_vect (t));

	   case I_ANY_AGGREGATE:
	      return may_have_aggregate (t);

	   case I_ANY_ACCESS_TYPE:
	      return (is_accesstype (t));

	   case I_ANY_SCALAR_VECTOR:
	      return (is_sc_vector (t));

	   case I_ANY_STRING_TYPE:
	      return is_stringtype (t);

	   case I_ENUM:
	      return en_type (t) != NULL;

	   DEFAULT (("illegal universal type %d\n", g_ind (univ_type)));
	}
}

void	no_eq_and_ass_in (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return;	

	   if (g_d (t) == XVARIANT) {
	      t = g_enclunit (t);
	      continue;
	   }

	   if (g_d (t) == XRECTYPE) {
	      s_flags (t, g_flags (t) & ~HAS_ASSIGN);
	      return;
	   }
	}

	ASSERT (FALSE, ("strange place to be"));
}

/*
 *	LRM 4.3.1 and 4.3.2
 */
bool	may_have_aggregate (t)
ac	t;
{
	while (TRUE) {
	   if (t == NULL)
	      return FALSE;

	   switch (g_d (t)) {
	      case XARRAYTYPE:
	         return get_indextype (t, 2) == 0 && has_eq_and_ass (t);

	      case XRECTYPE:
	         return has_eq_and_ass (t);

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

	      default:
	         return FALSE;
	   }   
	}
}

/*
 *	limprivtype is used in the following two functions
 *	Overloading of the = operator is only allowed if the operator
 *	type of both operands is of the same limited type
 *	The resulttype must then be the predefined type boolean
 */
static
bool	limprivtype (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return TRUE;

	   switch (g_d (x)) {
	      case XSUBTYPE:
	         x = g_parenttype (x);
	         break;

	      case XFILTER:
	         x = g_filtype (x);
	         break;

	      case XTASKTYPE:
	         return TRUE;

	      case XPRIVTYPE:
	         return (g_flags (x) & LIMIT) == LIMIT;

	      default:
	         return FALSE;
	   }
	}
}

/*
 *	Check the rules 6.7.5. of LRM
 */
void	chk_6_7_5 (sub, ren)
ac	sub,
	ren;
{
	if (sub == NULL || ren == NULL)
	   return;

	if ((g_flags (sub) & 037) != O_EQ)
	   return;

	if (g_d (ren) != XRENSUB)	/* much too complicated		*/
	   return;

	ren = g_fentity (ren);
	if (g_d (ren) != XSUB || g_d (ren) != XRENSUB) {
	   error ("LRM 6.7: '=' can only rename '=' (%s)\n", g_tag (ren));
	   return;
	}

	if ((g_flags (ren) & 037) != O_EQ) {
	   error ("LRM 6.7: '=' can only rename '=' (%s)\n", g_tag (ren));
	   return;
	}

	return;
}

/*
 *	Check the rules from LRM 6.7.4
 */
void	chk_6_7_4 (x)
ac	x;
{
	ac	p1,
		p2;

	if (x == NULL)	/* something went wrong			*/
	   return;

	if (!g_flags (x) & 037)
	   return;

	if ((g_flags (x) & 037) != O_EQ)
	   return;

	if (g_rettype (x) != std_boolean) {
	   error ("Trying to overload '=' with non-boolean result type\n");
	   s_rettype (x, std_boolean);
	}

	p1 = g_fformal (x);
	if (p1 == NULL)
	   return;

	p2 = g_next (p1);
	if (p2 == NULL)
	   return;

	if ((type_of (p1) != type_of (p2)) ||
	   (!limprivtype (type_of (p1)) && !is_anytype (type_of (p1)) ))
	   error ("Parameter type problem (LRM 6.7.4) in '='\n");
}

/*
 *	check the task type
 */
ac	chk_task (x)
ac	x;
{
	ac	t;

	if (x == NULL)
	   return NULL;

	ASSERT (is_name (x), ("chk_task:1"));

	t = base_type (g_types (x));

	if (t == NULL || g_d (t) != XTASKTYPE) {
	   error ("Illegal type, task type expected\n");
	   return NULL;
	}

	if (g_d (x) == XNAME) {
	   if (g_d (base_type (g_fentity (x))) == XTASKTYPE) {
	      error ("Cannot abort task type %s\n", g_tag (g_fentity (x)));
	      return NULL;
	   }
	}

	return x;
}

bool	is_taskobject (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	return TRUE;
}

bool	is_subprogram (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XNAME)
	   return FALSE;

	x = g_fentity (x);

	switch (g_d (x)) {
	   case XSUB:
	   case XRENSUB:
	   case XENUMLIT:
	   case XCHARLIT:
	   case XINHERIT:
	      return TRUE;

	   default:
	      return FALSE;
	}

}


bool	has_defaults (x)
ac	x;
{
	ac	y;

	if (x == NULL)
	   return FALSE;

	ASSERT (g_d (x) == XRECTYPE, ("has_defaults:1"));

	y = g_ffield (x);
	while (y != NULL && is_discr (y)) {
	   if (g_expr (g_desc (y)) == NULL)  /* no default expression	*/
	      return FALSE;

	   y = g_next (y);
	}

	return TRUE;
}


ac	rettype (x)
ac	x;
{
	if (x == NULL)
	   return notype;

	switch (g_d (x)) {
	   case XNAME:
	      return g_rettype (g_fentity (x));

	   default:
	      return notype;
	}
}


	
