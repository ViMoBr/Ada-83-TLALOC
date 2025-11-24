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
static	bool	ch_hide		();
static	bool	homograph	();
static	bool	not_the_same	();
static	bool	eq_discrs	();
static	bool	eq2_discr	();
static	ac	get_discrs	();
static	bool	decl_check	();
static	ac	return_type	();
static	bool	is_opfor	();
static	void	s_import	();
static	ac	cp_enum		();
static	void	add_do		();
static	ac	subcopy		();
static	bool	hide_check	();
/*
 *	D E C L A R A T I O N  P R O C E S S I N G
 *
 *	A D A -   C O M P I L E R
 *
 *	First part
 *		This file contains the functions and routines
 *		for declaration processing proper and
 *		making declarations accessible
 *
 *
 */

/*
 *	INTRODUCE, NEW_ENV en RESTORE_ENV
 *
 *	introduce links a record in the DAS tree.
 *	Two global variables are used:
 *	env:	points to the most enclosing environmental unit (see below)
 *	prev:	points to the previously introduced local of the current
 *		environmental unit (may be NULL).
 *	Initially, env points to the package STANDARD and prev to the last
 *	element of the locals-list of this package.
 *	If prev is NULL, the new record is linked to the environment, else
 *	it is linked to prev.
 */
void	INTRODUCE (x)
ac	x;
{
	introduce (x);
	add_def   (x);
}

/*
 *	Introduce a new entity
 *	Set enclosing pointers o.k. and make the thing
 *	visible (if ...)
 */
void	introduce (n)
ac	n;
{
	if (n == NULL)
	   return;

	PRINTF (printf ("introduce env = %o, prev = %o, n = %o %s\n",
			env, prev, n, has_tag (n) ? g_tag (n) : " "));

	if (env == NULL)
	   return;

/*
 *	make environmental pointer o.k.
 */
	if (is_enclosed (n))
	   s_enclunit (n, env);


	if (g_d (n) == XPRIVPART)
	   s_priv (g_enclunit (n), n);

	switch (g_d (n)) {
	   case XOBJECT:
	   case XRENPACK:
	   case XRENOBJ:
	   case XACCTYPE:
	   case XINCOMPLETE:
	   case XPRIVTYPE:
	   case XRECTYPE:
	   case XSUBTYPE:
		on_intro (n);

	   default:
		break;
	}

	if (prev == NULL) {
	   switch (g_d (env)) {
		case XRENSUB:
		case XENTRY:
		case XSUB:
	 	   s_fformal (env, n);
		   break;

		case XPACKAGE:
		   s_fvisitem (env, n);
		   break;

		case XGENNODE:
		   s_genpars (env, n);
		   break;

		case XPRIVPART:
		   s_fprivitem (env, n);
		   break;

		case XTASKTYPE:
		   s_fentry (env, n);
		   break;

		case XTASKBODY:
		case XSUBBODY:
		case XPACKBODY:
		   s_fbodyloc (env, n);
		   break;

		case XBLOCK:
		   s_fblockloc (env, n);
		   break;

		case XFORBLOCK:
		   s_looppar (env, n);
		   break;

		case XVARIANT:
		case XRECTYPE:
		   s_ffield (env, n);
		   break;

		case XINCOMPLETE:
		   s_fidiscr (env, n);
		   break;

		case XPRIVTYPE:
		   s_fpdiscr (env, n);
		   break;

		DEFAULT (("introduce: bad env %d %X\n", g_d (env), env));
	   }
	} else
	     s_next (prev, n);

	prev = n;
}

/*
 *	new_env creates a new environment, i.e. new values
 *	for the pair (env, prev)
 */
ac	NEWSCOPE (x)
ac	x;
{
	ac	t;

	t = new_env (x);
	new_scope   (x);	/* symbol table processing	*/
	return t;
}

ac	new_env (environ)
ac	environ;
{
	ac	x;

	s_enclunit (environ, env);
	env = environ;
	x = prev;
	prev = NULL;
	new_s (env);
	return x;
}

/*
 *	restore_env restores an older environment
 */
void	DELSCOPE (x, y)
ac	x,
	y;
{
	del_scope (x);		/* symbol table management	*/
	restore_env (x, y);
}

void	restore_env (envir, y)
ac	envir,
	y;
{
	/* restore an old environment */
	old_s (envir);
	env = g_enclunit (envir);
	prev = y;
}

/*
 *	ROUTINES FOR DECLARATION VERIFICATION
 *
 *
 *	Note: all error handling has to be done
 *	      by the caller
 *	defined are:
 *		LIST_INTRO
 *		LIST_CHECK
 *		SUBDECL
 *		OBJDECL
 *		PREDECL
 *		DECL_CHECK
 *		POST_DECL
 *		decl_tagstat
 */

void	LIST_INTRO (l, s)
ac	l;
char	*s;
{
	ac	t;

	FORALL (t, l)
	   OBJDECL (t, s);
}

void	LIST_CHECK (list)
ac	list;
{
	while (list != NULL) {
	   s_enclunit (list, env);
	   on_intro (list);

	   if (hide_check (list))
	      error ("tag %s of object decl non-unique", tag_of (list));

	   list = g_next (list);
	}
}

void	SUBDECL (x, s)
ac	x;
char	*s;
{
	char	*t;

	if (loc_iterate (g_tag (x), ch_hide, x) != NULL) {
	   switch (g_d (x)) {
	      case XSUB:
	         t = "error in subprogram declaration %s";
	         break;

	      case XRENSUB:
	         t = "error in declaration of renaming subprogram %s";
	         break;

	      case XENTRY:
	         t = "error in declaration of entry %s";
	         break;

	      default:
	         t = "error in subprogram decl %s";
	   }

	   error (t, tag_of (x));
	}

	introduce (x);
	add_def   (x);
}

static
bool	ch_hide (x, y)
ac	x,
	y;
{
	if (x == y)
	   return FALSE;

	if (g_d (y) == XCHARLIT)
	   return FALSE;

	if (!is_sub (y))
	   return homograph (x, y);

	if (is_derived (y)) {
	   if (eq_subs (y, x, TRUE, FALSE))
	      s_is_hidden (y, TRUE);

	   return FALSE;
	}

	return eq2_subs (x, y);
}


/*
 *	OBJDECL
 *	
 *	do the checks required for an object declaration
 *
 *
 *	x may not have the same tag as anything else
 *	in the same declarative part. A distinction is made for
 *	an initialization of a private-type constant
 *	But be aware of the character literals
 *	First check that x has a tag after all. (found
 *	to be disastrous @ 6-1-85)
 */
void	OBJDECL (x, s)
ac	x;
char	*s;
{
	ac	t;

	ASSERT (x != NULL, ("OBJDECL: null object"));

	if (!has_tag (x) || g_tag (x) == NULL) {
	   introduce (x);
	   if (has_tag (x))
	      add_def (x);

	   return;
	}

	t = loc_iterate (g_tag (x), homograph, x);
	if (t == NULL) {
	   introduce (x);
	   if (has_tag (x))
	      add_def (x);
	}
	else
	if (is_private_constant (t, x)) {
	   introduce (x);
	   s_object_spec (x, t);
	}
	else
	   error (s, tag_of (x));
}

static
bool	homograph (x, y)
ac	x,
	y;
{
	ASSERT (x != NULL && y != NULL, ("is_homo:1"));

	ASSERT (has_tag (x) && has_tag (y), ("is_homo:2"));

	if (is_charlit (x)) {
	   if (is_charlit (y))
	      return type_of (x) == type_of (y);
	   if (is_enumlit (y))

	   return FALSE;
	}

	if (is_enumlit (x)) {
	   if (is_charlit (y))
		return FALSE;
	   if (is_enumlit (y))
	      return type_of (x) == type_of (y);
	   if (is_sub (y))
	      return type_of (x) == type_of (y);
	   return TRUE;
	}

	if (is_sub (x)) {
	   if (is_charlit (y))
	      return FALSE;
	   if (is_enumlit (y))
	      return type_of (x) == type_of (y);
	   if (is_sub (y))
	      return eq2_subs (x, y);
	   return TRUE;
	}

	if (is_charlit (y))
	   return FALSE;

	return TRUE;
}

/*
 *	PREDECL
 *	check a (type) declaration prior to processing
 *	its specification or implementation.
 *	Find corresponding specifications (if any)
 *	and set up some links
 */
void	PREDECL (x)
ac	x;
{
	ac	t;

/*
 *	start checking
 */

	if (g_d (x) == XPRIVTYPE && g_d (env) != XPACKAGE) {
	   error ("Illegal place for declaring private type %s", g_tag (x));
	   return;
	}

/*
 *	locate another decl with the same tag
 */
	t = loc_iterate (g_tag (x), not_the_same, x);
/*
 *	there exists another declaration
 *	It better be an incomplete or a private type declaration
 */
	if (t != NULL) {
	   if (g_d (t) != XINCOMPLETE && g_d (t) != XPRIVTYPE) {
	      error ("Entity %s was already declared", g_tag (t));
	      return;
	   }

/*
 *	   Figure out whether the relation of the declaration
 *	   and its specification makes any sense
 */
	   if (g_d (t) == XPRIVTYPE && g_d (env) != XPRIVPART) {
	      error ("Implementation of private type %s in wrong environment",
	              g_tag (t));
	      return;
	   }

/*
 *	   check existence of already implemented incomplete
 *	   and private types
 */
	   if (g_d (t) == XINCOMPLETE && g_complete (t) != NULL) {
	      error ("Multiple complete types %s", g_tag (t));
	      return;
	   }

	   if (g_d (t) == XPRIVTYPE && g_impl (t) != NULL) {
	      error ("Multiple implementations for private type %s", g_tag (t));
	      return;
	   }

	   if (g_d (x) == XARRAYTYPE) {
	      error ("Unconstrained array type for private/incompl %s (not supported)", g_tag (t));
	      return;
	   }

/*
 *	   this seems enough, make a link
 */
	   if (g_d (x) == XTASKTYPE && g_d (t) == XPRIVTYPE) {
	      s_flags (x, g_flags (x) | LIMIT);
	   }

	   s_type_spec (x, t);
/*
 *	   The forward link, i.e. the link from the complete (private)
 *	   type to the type x is made in POSTDECL
 */
	}

	introduce (x);

	if (is_type (x) && g_type_spec (x) != NULL) {
            /* its an implementation */
	   return;
	}

	/* make it visible		*/
	add_def (x);
}

static
bool	not_the_same (x, y)
ac	x,
	y;
{
	return x != y;
}

/*
 *	POSTDECL
 *
 *	Do the checking required after processing a (type)
 *	declaration
 */
void	POSTDECL (x)
ac	x;
{
/*
 *	x points to the type being declared;
 *	If the type_spec field is non-zero
 *	then the corresponding incomplete (private) type
 *	is set to contain a pointer to this one.
 *
 */
	if (x == NULL)
	   return ;	/* error already been */

	off_intro (x);
	if (g_type_spec (x) != NULL) {
	   if (g_d (g_type_spec (x)) == XINCOMPLETE) {
		s_complete (g_type_spec (x), x);
	   }
	   else
	   {
	      ASSERT (g_d (g_type_spec (x)) == XPRIVTYPE, ("post-decl:1"));
	      s_impl (g_type_spec (x), x);
	   }
	}

	if (!eq_discrs (x, g_type_spec (x)))
	   error ("Mismatch between private/incomplete type and type %s",
                  g_tag (x) );
}

static
bool	eq_discrs (x, y)
ac	x,
	y;
{
	ac	t,
		r;

	if (x == NULL || y == NULL)
	   return TRUE;

	t = get_discrs (x);
	r = get_discrs (y);

	if (g_d (x) == XACCTYPE) {
	   if (y == NULL)
	      return TRUE;
	}

	return eq2_discr (t, r);
}

static
bool	eq2_discr (x, y)
ac	x,
	y;
{
	if (x == NULL && y == NULL)
	   return TRUE;

	if (x == NULL || y == NULL)
	   return (( x == NULL && !is_discr (y)) ||
	          ( y == NULL && !is_discr (x))  );

	if (!eq_tags (g_tag (x), g_tag (y)))
           return (FALSE);

/*
 *	trick:
 */
	if (!eq2_discr (g_next (x), g_next (y)))
	   return FALSE;

	x = g_desc (x);
	y = g_desc (y);

	if (base_type (g_objtype (x)) != base_type (g_objtype (y)))
	   return (FALSE);

	x = g_expr (x);
	y = g_expr (y);

	return ( ((x == NULL && y == NULL) ||
	       (x != NULL && y != NULL)) );

}

static
ac	get_discrs (x)
ac	x;
{
	while (TRUE) {
	   if (x == NULL)
	      return NULL;

	   switch (g_d (x)) {
	      case XRECTYPE:
		 return g_ffield (x);

	      case XNEWTYPE:
		 x = g_old_type (x);
	         break;

	      case XACCTYPE:
		 x = g_actype (x);
	         break;

	      case XINCOMPLETE:
		 return g_fidiscr (x);

	      case XPRIVTYPE:
		 return g_fpdiscr (x);

	      case XSUBTYPE:
		 return NULL;	/* may be introduced by privtype */

	      case XTASKTYPE:
	         return NULL;

	      case XARRAYTYPE:
		 return NULL;	/* Incorrect, I know		*/

	      default:
		 return NULL;
	   }
	}
}

/*
 *	enum_check (x)
 *
 *	an enumeration literal may overload
 *	other enumeration literals
 */
bool	enum_check (x)		/* TRUE erroneous */
ac	x;
{
	return loc_iterate (g_tag (x), homograph, x) != NULL;
}


/*
 *	DECL_CHECK
 *
 *	Check, in a (construction) whether or not the
 *	declarations make sense
 *
 *	c is a flag indicating whether or not stubs are allowed
 *
 */
void	DECL_CHECK (c, x, s)
bool	c;
ac	x;
char	*s;
{
	if (decl_check (c, x)) {
	   warning (s, g_tag (x));
	}
}

static
bool	decl_check (c, x)
bool	c;
ac	x;
{
	ac	y;

	if (g_d (x) == XPACKAGE && g_enclunit (x) == std)
	   return FALSE;

	if (g_d (x) == XPACKBODY)
	   if (decl_check (c, g_specif (x)))
	      return TRUE;

	if (g_d (x) == XTASKBODY)
	   if (decl_check (c, g_specif (x)))
	      return TRUE;

	if (g_d (x) == XGENNODE)
	   if (decl_check (c, g_genunit (x)))
	      return TRUE;

	FORALL (y, get_locallist (x)) {
	   switch (g_d (y)) {
		case XPACKAGE:
		     if (decl_check (FALSE, y))
		        return (TRUE);
		     break;

		case XPACKBODY:
		     if (g_specif (y) != NULL)
			if (decl_check (TRUE, g_specif (y)))
		           return TRUE;
		     break;

		case XSUB:
		     if (g_body_imp (y) == NULL)
		       if (c)
		          return TRUE;
		     break;

		case XTASKTYPE:
		     if (g_taskbody (y) == NULL)
		        return TRUE;
		     break;

		case XINCOMPLETE:
		     break;

		case XPRIVTYPE:
		     if (g_impl (y) == NULL)
		        return (TRUE);
		     break;

		case XSTUB:
		     return !c;
		}
	}

	return FALSE;
}


/*
 *	declaring a tagged statementr
 */
ac	decl_tagstat (x)
ac	x;
{
	ac	t;

	t = nalloc (XTAGSTAT);
	s_tag (t, g_tag (x));
	s_t_stat (t, x);

	OBJDECL (t, "statement tag (%s) not unique");

	return t;
}

/*
 *	Importing inherited declarations
 */
void	inherit (t, old_t)
ac	t,
	old_t;
{
	ac	x1,
		x2;

	if (t == NULL || old_t == NULL)
	   return;

	ASSERT (g_d (t) == XNEWTYPE, ("inherit???"));

	if (g_d (g_enclunit (old_t)) != XPACKAGE)
	   return;

	x1 = en_type (old_t);
	if (x1 != NULL) {
	   ASSERT (g_d (x1) == XENUMTYPE, ("ENUM expected"));
	   /* Import enumeration types here	*/
	   s_import (old_t, t);
	}

	FORALL (x1, g_fvisitem (g_enclunit (old_t))) {
	   if (is_opfor (x1, old_t))
	      add_do (x1, t, old_t);

	}
}

/*
 *	is x an operator for (type) y
 */

static
ac	return_type (x)
ac	x;
{
	ac	y,
		z;

	if (x == NULL)
	   return NULL;

	ASSERT (is_sub (x), ("return_type: sub expected"));

	if (g_d (x) != XINHERIT)
	   return g_rettype (x);

	while (g_d (x) == XINHERIT) {
	   y = g_old_type (x);
	   z = g_inh_type (x);
	   x = g_inh_oper (x);
	}

	if (eq_types (g_rettype (x), y))
	   return z;
	else
	   return g_rettype (x);
}

/*
 *	Is x an operator for y
 */
static
bool	is_opfor (x, y)
ac	x,
	y;
{
	ac	t;

	if (!is_sub (x))
	   return FALSE;

	if (is_derived (x) && g_is_hidden (x))
	   return FALSE;

	if (eq_types (return_type (x), y))
	   return TRUE;

	FORALL (t, f_formal (x))
	   if (eq_types (type_of (t), y))
	      return TRUE;

	return FALSE;
}

/*
 *	copy the enumeration literals belonging to type x
 *	to the (inherited) type y
 */
static
void	s_import (x, y)
ac	x,
	y;
{
	ac	t1,
		t2;

/* check hier dat alleen ENUMTYPE, geen NEWTYPE kan voorkomen */
	t1 = g_fenumlit (x);
	s_enlits (y, cp_enum (t1, y));
	t2 = g_enlits (y);
	add_def (t2);

	while (g_next (t1) != NULL) {
	   s_next (t2, cp_enum (g_next (t1), y));
	   t1 = g_next (t1);
	   t2 = g_next (t2);
	   add_def (t2);
	}
}

/*
 *	copy an enumeration literal
 */
static
ac	cp_enum (l, t)
ac	l,
	t;
{
	ac	x;

	if (g_d (l) == XCHARLIT)
	   x = nalloc (XCHARLIT);
	else
	   x = nalloc (XENUMLIT);

	s_tag (x, mk_tag (g_tag (l), IDL));
	s_enclunit (x, t);
	s_enuml_ord (x, g_enuml_ord (l));

	return x;
}

/*
 *	Add a (simplified in coding) inherited
 *	subprogram to the list of locals
 */
static
void	add_do (d, t, old_t)
ac	d,
	t,
	old_t;
{
	ac	x,
		help;

	if (d == NULL)
	   return;

	ASSERT (is_sub (d), ("add_do: sub expected"));

	x = subcopy (d, t, old_t);
	s_inh_type (x, t);
	s_inh_oper (x, d);
	s_old_type (x, old_t);

	SUBDECL (x, "Error in %s (inheritance)");
}
/*
 *	Copy the sub
 */
static
ac	subcopy (x, t, old_t)
ac	x,
	t,
	old_t;
{
	ac	t1,
		t2;

	if (x == NULL)
	   return NULL;

	t1 = nalloc (XINHERIT);

	ASSERT (is_sub (x), ("sub expected in copysib"));

	s_tag (t1, mk_tag (g_tag (x), IDL));

	return t1;
}

static
bool	hide_check (x)
ac	x;
{
	if (!has_tag (x) || g_tag (x) == NULL)
	   return FALSE;

	return loc_iterate (g_tag (x), homograph, x) != NULL;
}

