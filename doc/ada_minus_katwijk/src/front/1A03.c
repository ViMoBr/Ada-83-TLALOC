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
static	ac	i_list		();
static	void	prep		();
static	ac	ex_h_of		();
static	void	add_mak		();
static	void	ch2_exc		();

/*
 *	check compilation order
 */
void	component_ordering (k1, k2, s)
int	k1;
int	k2;
char	*s;
{
	if (k1 == COMP_OTHERS || k1 > k2)
	   warning (s);
}


/*
 *	check order of parameter kinds
 */
bool	param_order (old, new)	/* TRUE erroneous	*/
int	old,
	new;
{
	return (old != new && old == PPP_NAME);
}

/*
 *	convert array
 *
 *	an "implied array", e.g. an array presented as
 *	a constrained array, either in a type definition
 *	or in a variable declaration is transformed
 *	into an unconstrained array and a filter call
 */
static
ac	i_list (ind)
ac	ind;
{
	ac	indtype,
		t;

	if (ind == NULL)
	   return NULL;

	ASSERT (g_d (ind) == XRANGE, ("i_list: no RANGE"));

	if (g_rangetype (ind) == NULL)
	   indtype = any_type;
	else
	if (g_rangetype (ind) == std_univ)
	   indtype = std_integer;
	else
	if (!is_singleton (g_rangetype (ind))) {
	   error ("Cannot uniquely identify index type");

	   indtype = std_integer;
	}
	else
	   indtype = g_rangetype (ind);

	t = mk_index (indtype);
	s_next (t, i_list (g_next (ind)));

	return t;
}

void	set_indices (array, rangelist)
ac	array,
	rangelist;
{
	ASSERT (array != NULL && g_d (array) == XARRAYTYPE,
		      ("Set indices: no valid array") );

	ASSERT (rangelist != NULL, ("Set_indices: rangelist == NULL"));

	ASSERT (g_d (rangelist) == XRANGE, ("set_indices %d\n", g_d (rangelist)));
	s_findex (array, i_list (rangelist));
}

ac	conv_array (indcons, eltype)
ac	indcons,
	eltype;
{
	return mk_array (mk_tag (gen_tag (), IDL), NULL, eltype);
}

/*
 *	preprocess with and use clauses
 */
static
void	prep (x)
ac	x;
{
	if (x == NULL)
	   return;

	if (g_d (x) == XUSE) {
	   new_use (g_packname (x));
	   return;
	}

	if (g_d (x) == XWITH) {
	   introduce (g_withunit (x));
	   add_def (g_withunit (x));
	   return;
	}

	if (g_d (x) == XSEPARATE) {
	   return;
	}

	ASSERT (FALSE, ("illegal %d in withlist", g_d (x)));
}

void	withprocess (x)
struct lib_unit *x;
{
	ac	y;

	FORALL (y, ((struct lib_unit *)x) -> with_list) {
	   prep (y);
	}
}

/*
 *	Check rn being a static range
 */
ac	static_range (type, rn)
ac	type,
	rn;
{
	s_rangetype (rn, propagate (type, g_rangetype (rn)));
	rn = td_range (rn);
	if (rn == NULL)
	   error ("Cannot resolve types in case statement");

	if (!is_static (rn)) {
	     set_error (rn);
	     error ("non static range in case statement");
	     return NULL;
	}

	return rn;
}

/*
 *	Management for exception handlers
 *	intro_exh: enter an exception handler
 */
void	intro_ex_h ()
{
	switch (g_d (env)) {
		case XSUBBODY:	s_SBB_exh (env, env);
				  break;
		case XPACKBODY:	s_PB_exh (env, env);
				  break;
		case XBLOCK:	s_BLK_exh (env, env);
				  break;
		case XTASKBODY:
				s_task_exh (env, env);
				break;
	}
}

/*
 *	Is the current environment enclosed by an exception handler?
 */
static
ac	ex_h_of (x)
ac	x;
{
	ASSERT (x != NULL, ("ex_h_of: null pointer"));

	switch (g_d (x)) {
	   case XSUBBODY:
	      return g_SBB_exh (x);

	   case XPACKBODY:
	      return g_PB_exh  (x);

	   case XBLOCK:
	      return g_BLK_exh (x);

	   case XTASKBODY:
	      return g_task_exh (x);

	   default:
	      return NULL;
	}
}

bool is_in_ex_h (environ)
ac	environ;
{
	while (TRUE) {
	   if (environ == NULL)
	      return FALSE;

	   if (ex_h_of (environ) != NULL)
	      return TRUE;

	   if (g_d (environ) == XSUBBODY)
	      return FALSE;

	   if (g_d (environ) == XTASKBODY)
	      return FALSE;

	   if (g_d (environ) == XPACKBODY)
	      return FALSE;

	   environ = g_enclunit (environ);
	}
}

/*
 *	construct delay-nodes for the tree
 *	mak_delay: make delay x
 *	mak_inf_delay: make delay INFINITE
 */
ac	mak_delay (x)
ac	x;
{
	ac	t;

	if (x == NULL)
	   x = mk_expr (std_integer, cp_value (0, std_integer));

	t = mk_delay (x);
	return t;
}

ac	mak_inf_delay()
{
	return mk_delay (mk_expr (std_long, cp_value (65000, std_long)));
}

/*
 *	Check heading and trailing identifier being the same
 */
void	CHECK_OPTIDENT (t1, t2, s)
char	*t1;
char	*t2;
char	*s;
{
	if (t1 == NULL && t2 != NULL) {
	   warning (s, t2);
	}
	else
	if (t2 == NULL) {
	   return;
	}
	else
	if (!eq_tags (t1, t2)) {
	   warning (s, t1);
	}
}

/*
 *	Create a decent structure for encoding a call
 *	to an operator
 */
ac	call_std_function (sub, p1, p3)
ac	sub,
	p1,
	p3;
{
	ac	t1,
		t2,
		t3;

	if (p1 == NULL)	/* Not even a left operand		*/
	   return NULL;

	t1 = mk_applied (mk_unresrec (sub));

	if (p3 != NULL) {
	   t2 = mk_namass (NULL, p3);
	}
	else
	   t2 = NULL;

	t3 = mk_namass (NULL, p1);
	s_next (t3, t2);
	return mk_expr (NULL, mk_call (t1, t3));
}

/*
 *	Check that l is empty
 */
void	NO_DISCRS (l, t, s)
char	*t,
	*s;
ac	l;
{
	if (l != NULL)
	   error (s, t);
}

/*
 *	Check a type being scalar
 *	(indextype or something like that)
 */
ac	IS_SCALAR (t, tag, s)
ac	t;
char	*tag,
	*s;
{
	if (t == NULL || t == any_type)
	   return std_integer;

	if (!is_scalar (t)) {
	   error (s, tag);
	   return std_integer;
	}

	return t;
}

/*
 *	Check x being a package specification node
 */
ac	packspec (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (g_d (x) == XPACKAGE)
	   return x;

	if (g_d (x) == XGENNODE && g_d (g_genunit (x)) == XPACKAGE)
	   return g_genunit (x);

	return NULL;
}

/*
 *	Check the number of parameters for a call to
 *	an operator
 */
void	ch_funpars (x, cnt)
ac	x;
int	cnt;
{
	switch (cnt) {
	   case 1:
		if (!monadic (x))
	           error ("%s cannot be used as monadic operator", g_tag (x));
	        return;

	   case 2:
	        if (!dyadic (x))
	           error ("%s cannot be used as dyadic operator", g_tag (x));
	        return;

	   default:
	        error ("Illegal number of parameters for (redeclaration of) %s",
	                g_tag (x));
	}
}

/*
 *	Generate dotted name structure for separate subunits
 *	Warning: not properly incorporated yet
 */
static struct c {
	int aa;
	char mak [MAKSIZE];
};

char	*mak_nam (l)
ac	l;
{
	ac	z;
	static struct c d;

	d. aa = 0;

	ASSERT (l != NULL, ("mak_nam:1"));
	FORALL (z, l) {
	   if (g_d (z) == XSEPARATE) {
	      add_mak (&d, g_tag (z));
	   }
	}
	d. mak[d. aa] = EOS;
	return d. mak;
}

static
void	add_mak (s, t)
struct c *s;
char	*t;
{
	char	*t2 = t;

	if (s -> aa != 0)
	   s -> mak [s -> aa ++] = '.';

	while (*t2)
	   s -> mak [s -> aa++] = *t2++;
}


/*
 *	Shrortcutted verification functions:
 */
bool	sep_pb (x)
ac	x;
{
	return TRUE;		/* Not complete	*/
}

bool	sep_sub (x)
ac	x;
{
	return TRUE;
}

bool	sep_tb (x)
ac	x;
{
	return TRUE;
}

/*
 *	Check the uniqueness of exceptions in a handler
 */
static
void	ch2_exc (l, e)
ac	l;
ac	e;
{
	ac	x;

	FORALL (x, l) {
	   ASSERT (g_d (x) == XRANGE, ("ch2_exc"));
	   if (g_frang_exp (x) == NULL)
	      continue;
	   if (e == g_fentity (g_primary (g_frang_exp (x)))) {
	      error ("Exception %s double in handlers\n", g_tag (e));
	   }
	}
}

void	chk_exceptions (l1, l2, e)
ac	l1,
	l2,
	e;
{
	ac	x,
		ce;

	ASSERT (e != NULL && g_d (e) == XRANGE, ("chk_ex:0"));

	if (g_frang_exp (e) == NULL)
	   return;

	e = g_fentity (g_primary (g_frang_exp (e)));

	ASSERT (e != NULL && g_d (e) == XEXCEPTION, ("chk_exc:1"));
	FORALL (x, l1) {
	   ASSERT (g_d (x) == XWHENITEM, ("chk_exceptions"));
	   ch2_exc (g_fwhenchoice (x), e);
	}

	ch2_exc (l2, e);
}


/*
 *	Check an expression being static
 */
ac	STATIC_EXPR (e, t, s)
ac	e,
	t,
	s;
{
	if (e == NULL)
	   return NULL;

	e = solve_expr (bu_expr (e), t);
	if (e == NULL) {
	   error (s);
	   return NULL;
	}

	if (!is_static (e)) {
	   error (s);
	   return NULL;
	}

	return e;
}

/*
 *	Check an entity x being a simple variable name
 */
ac	chk_varname (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (g_d (x) != XNAME) {
	   error ("Simple variable name expected");
	   return NULL;
	}

	if (g_fentity (x) == NULL) {
	   return NULL;
	}

	switch (g_d (g_fentity (x))) {
  	   case XOBJECT:
	   case XRENOBJ:
		return g_fentity (x);

	   default:
		error ("Cannot use %s in representation", g_tag (g_fentity (x)));
		return NULL;
	}
}

/*
 *	MACHDEP and dirty and so on but:
 */
void	on_intro (n)
ac	n;
{
	while (n != NULL) {
	   set_intro (n);
	   n = g_next (n);
	}
}

void	off_intro (x)
ac	x;
{
	while (x != NULL) {
	   out_intro (x);
	   x = g_next (x);
	}
}


/*
 *	is the parameter new acceptable in the context of old ?
 */
int	acceptable (old, new, ems)
int	old,
	new;
char	*ems;
{
	if (old == XSUB)	/* NULL value		*/
	   return old;

	if (old == XSLICE || new == XSLICE) {
	   error (ems);
	   return XSUB;
	}

	if (old == XCALL && new != XCALL) {
	   error (ems);
	   return XSUB;
	}

	return new;
}

