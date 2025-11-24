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
static	bool	eq_rettype	();
static	ac	eff_type	();
static	ac	find_renamedsubs	();
static	bool	get_sub		();
static	bool	is_package	();
static	ac	find_taskspec	();
static	bool	is_task		();
static	ac	find_entry	();
static	bool	primary_env	();
static	ac	give_stub	();
static	bool	is_overloadable	();
static	void	p3_proc		();
static	void	p4_proc		();
static	void	p1_proc		();
static	void	p2_name		();
/*
 *	D E C L A R A T I O N  P R O C E S S I N G
 *
 *	A D A -   C O M P I L E R
 *
 *
 */

/*
 *	find next item, walk through enumeration literals
 */
ac	next_def (x)
ac	x;
{
	if (x == NULL)
           return (NULL);

	if (is_entype (x))
	   return fenum_of (x);

	if (g_next (x) != NULL)
	   return g_next (x);

	if (g_d (x) == XENUMLIT || g_d (x) == XCHARLIT)
	   return g_next (g_enclunit (x));

	return g_next (x);
}

/*
 *	Given an entity x, find the list of locals
 *	hanging in the Ada tree under it
 */
ac	get_locallist (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	switch (g_d (x)) {
	   case XGENNODE:
	      return g_genpars (x);

	   case XBLOCK:
	      return g_fblockloc (x);

	   case XTASKTYPE:
	      return g_fentry (x);

	   case XSUBBODY:
	   case XPACKBODY:
	   case XTASKBODY:
	      return g_fbodyloc (x);

	   case XPACKAGE:
	      return g_fvisitem (x);

	   case XFORBLOCK:
	      return g_looppar (x);

	   case XRENSUB:
	   case XSUB:
	   case XENTRY:
	   case XINHERIT:
	      return f_formal (x);

	   case XPRIVPART:
	      return g_fprivitem (x);

	   case XRECTYPE:
	   case XVARIANT:
	      return g_ffield (x);

	   case XINCOMPLETE:
	      return g_fidiscr (x);

	   case XPRIVTYPE:
	      return g_fpdiscr (x);

	   DEFAULT (("get_local: no locallist %d %x\n", g_d (x), x));
	}
}

/*
 *	Check whether or not to subprograms are "equal"
 *	Used in checking for hiding and so on
 *	Parameterized to take equality of subprogram names into account
 *	and equality of parameter names
 */
bool eq_subs (p1, p2, sam_tag, s_partag)
ac	p1,
	p2;
bool	sam_tag,
	s_partag;
{
	ac	bt1,
		bt2;
	ac	sp1,
		sp2;

	sp1 = p1;
	sp2 = p2;

	if (p1 == NULL || p2 == NULL)
	   return FALSE;

	if (!is_sub (p1))
	   return FALSE;

	if (!is_sub (p2))
	   return FALSE;

	if (is_derived (p2) && !is_derived (p1))
	   return eq_subs (p2, p1, sam_tag, s_partag);

	if (sam_tag)
	   if (!eq_tags (g_tag (p1), g_tag (p2)))
	      return (FALSE);

	if (!eq_rettype (p1, p2))
	   return (FALSE);

/*
 *	now go for the parameters
 */

	p1 = f_formal (p1);
	p2 = f_formal (p2);

	while (p1 != NULL && p2 != NULL) {
	   if (kind_of (g_desc (p1)) != kind_of (g_desc (p2)))
	      return FALSE;
	   if (s_partag)
	      if (!eq_tags (g_tag (p1), g_tag (p2)))
	         return FALSE;

	   bt1 = base_type (eff_type (type_of (p1), sp1));
	   bt2 = base_type (eff_type (type_of (p2), sp2));

	   if (is_anytype (bt1) && is_anytype (bt2)) {
	      if (bt1 != bt2)
	         return FALSE;
	   }
	   else
	      if (is_anytype (bt1)) {
	         if (!match_univ (bt2, bt1))
	            return FALSE;
	      }
	      else
	         if (is_anytype (bt2)) {
	            if (!match_univ (bt1, bt2))
	               return FALSE;
	         }
	         else
	            if (bt1 != bt2)
	               return FALSE;

	   p1 = g_next (p1);
	   p2 = g_next (p2);
	}

	return (p1 == NULL && p2 == NULL);
}

/*
 *	eq2_sub
 *	are subs sufficiently equal to hide each other
 *	(i.e. are they homographs?)
 */
bool	eq2_subs (p1, p2)
ac	p1,
	p2;
{
	ac	bt1,
		bt2;
	ac	sp1,
		sp2;

	sp1 = p1;
	sp2 = p2;

	if (p1 == NULL || p2 == NULL)
	   return FALSE;

	if (!is_sub (p1))
	   return FALSE;

	if (!is_sub (p2))
	   return FALSE;

	if (is_derived (p2) && !is_derived (p1)) {
	   return eq2_subs (p2, p1);
	}

	if (!eq_tags (g_tag (p1), g_tag (p2)))
	   return FALSE;

	if (!eq_rettype (p1, p2))
	   return FALSE;

/*
 *	now go for the parameters
 */
	p1 = f_formal (p1);
	p2 = f_formal (p2);

	while (p1 != NULL && p2 != NULL) {
	   bt1 = base_type (eff_type (type_of (p1), sp1));
	   bt2 = base_type (eff_type (type_of (p2), sp2));

	   if (is_anytype (bt1) && is_anytype (bt2)) {
	      if (bt1 != bt2)
	         return FALSE;
	   } else
	   if (is_anytype (bt1)) {
	      if (!match_univ (bt2, bt1))
	         return FALSE;
	   } else
	   if (is_anytype (bt2)) {
	      if (!match_univ (bt1, bt2))
	         return FALSE;
	   } else
	   if (bt1 != bt2)
	      return FALSE;

	   p1 = g_next (p1);
	   p2 = g_next (p2);
	}

	return (p1 == NULL && p2 == NULL);
}

static
bool	eq_rettype (x, y)
ac	x, y;
{
	ac	r1,
		r2;

	r1 = eff_type (g_rettype (x), x);
	r2 = eff_type (g_rettype (y), y);

	if (is_anytype (r2)) {
	   if (match_univ (r1, r2))
	      return TRUE;
	}

	if (is_anytype (r1)) {
	   if (match_univ (r2, r1))
	      return TRUE;
	}

	return r1 == r2;
}

static
ac	eff_type (t, s)
ac	t;
ac	s;
{
	if (s == NULL)
	   return t;

	ASSERT (is_sub (s), ("eff_type: XSUB expected (%d)", g_d (s)));

	if (is_derived (s) && eq_types (g_old_type (s), t))
	   return g_inh_type (s);

	return t;
}

/*
 *	FIND_RENAMED_SUB
 *	Find in a set of defining occurrences "ents" the
 *	subprogram definition such that the one found can
 *	be renamed by the specification
 *	
 *	A bu_walk has been performed over the construction
 *	being renamed
 */
ac	FIND_RENAMEDSUBS (t1, t2, s)
ac	t1,
	t2;
char	*s;
{
	ac	t;

	t = find_renamedsubs (t1, t2);
	if (t == NULL) {
	   error (s, g_tag (t1));
	}

	return t;
}

static
ac	find_renamedsubs (specif, ents)	/* NULL erroneous	*/
ac	specif,
	ents;
{
	ac	t,
		y;
	ac	temp	= NULL;		/* result set	*/

	if (ents == NULL)
	   return NULL;

	if (g_d (ents) == XLITERAL) { /* it better be a string literal	*/
	   if (!is_stringlit (ents)) {
	      error ("Cannot rename this procedure to strange literal");
	      return NULL;
	   }

	   ents = find_ops (g_val (ents) -> litvalue);
	}

	if (!is_name (ents))
	   return NULL;

	FORSET (y, g_types (ents)) {
	   if (is_sub (y)) {
	      if (eq_subs (specif, y, FALSE, FALSE))
		 temp = join (y, temp);
	   }
	   else
	   if (is_entype (y)) {
	      if ((y == restypes (specif)) && is_paramless (specif)) {
		 if (g_d (ents) != XNAME && g_d (ents) != XSELECT)
	            temp = join (y, temp);
	      }
	   }
	}

	del_set (g_types (ents));
	s_types (ents, temp);

	if (!is_singleton (temp)) {
	   error ("Cannot solve name construction renaming %s\n", g_tag (specif));
	   return NULL;
	}

	t = td_n_name (ents);
	if (t == NULL) {
	   error ("Cannot solve (2) name construction renaming %s\n",
							g_tag (specif));
	   return NULL;
	}

	if (is_entype (temp)) {
	   if (g_d (t) != XNAME || g_d (g_fentity (t)) != XENUMLIT) {
	      error ("Cannot rename %s with arbitrary construction",
							g_tag (specif));
	      return NULL;
	   }
	}

	return t;
}

/*
 *	find_subspec (x, y)
 *
 *	try to locate a non_hidden, equivalent,
 *	specification
 *
 *	if NOT found, it does not have to mean 'error',
 *	the caller does a subhide_check.
 */
ac	FIND_SUBSPEC (t1, t2, s)
ac	t1,
	t2;
char	*s;
{
	ac	t;

	t = loc_iterate (g_tag (t1), get_sub, t1);
	if (t == NULL) {
	   t = t1;

	   chk_6_7_4 (t1);
	   SUBDECL (t1, s);
	}

	return t;
}

static
bool	get_sub (x, y)
ac	x,
	y;
{
	if (x == y)
	   return FALSE;

	if (is_sub (y)) {
	   if (is_derived (y))
	      return FALSE;

	   return eq_subs (x, y, TRUE, TRUE);
	}

	return FALSE;
}


/*
 *	find_packspec (x)
 *
 *	try to locate a package specification within the
 *	current local environment
 */

ac	FIND_PACKSPEC (t, s)
ac	t;
char	*s;
{
	ac	t1;

	t1 = loc_iterate (t, is_package, NULL);
	if (t1 == NULL)
	   error (s, t);

	return t1;
}

static
bool	is_package (dum, y)
ac	dum,
	y;
{
	if (g_d (y) == XPACKAGE)
	   return TRUE;

	if (g_d (y) != XGENNODE)
	   return FALSE;

	if (g_genunit (y) == NULL)
	   return FALSE;

	return (g_d (g_genunit (y)) == XPACKAGE);
}


/*
 *	find_task...
 */
ac	FIND_TASKSPEC (t, s)
char	*t,
	*s;
{
	ac	t1;

	t1 = find_taskspec (t);
	if (t1 == NULL)
	   error (s, t);

	return t1;
}

static
ac	find_taskspec (tag)
char	*tag;
{
	ac	a;

	a = loc_iterate (tag, is_task, NULL);

	if (a == NULL)
	   return NULL;

	if (g_d (a) == XTASKTYPE)
	   return a;

	if (g_d (a) == XINCOMPLETE)
	   return g_complete (a);

	if (g_d (a) == XPRIVTYPE)
	   return g_impl (a);

	ASSERT (g_d (a) == XOBJECT, ("find_taskspec:1"));

	if (g_d (g_objtype (g_desc (a))) == XTASKTYPE)
	   return g_objtype (g_desc (a));

	ASSERT (FALSE, ("cannot find task type"));
}

static
bool	is_task (dum, y)
ac	dum,
	y;
{
	if (g_d (y) == XTASKTYPE)
	   return TRUE;

	if (g_d (y) == XOBJECT &&
	    g_d (g_objtype (g_desc (y))) == XTASKTYPE)
	   return TRUE;

	if (g_d (y) == XPRIVTYPE &&
	    g_impl (y) != NULL && g_d (g_impl (y)) == XTASKTYPE)
	   return TRUE;

	if (g_d (y) == XINCOMPLETE &&
            g_complete (y) != NULL && g_d (g_complete (y)) == XTASKTYPE)
	   return TRUE;

	return FALSE;
}


/*
 *	FIND_ENTRY
 */
ac	FIND_ENTRY (t1, t2, s)
ac	t1,
	t2;
char	*s;
{
	ac	t;

	t = find_entry (t1, t2);
	if (t == NULL)
	   error (s, g_tag (t1));

	return t;
}

static
ac	find_entry (t, e)
ac	t,
	e;
{
	ac	x,
		y,
		z;

	x = encl_taskbody (e);
	if (x == NULL)
	   return NULL;

	y = g_specif (x);
	FORALL (z, g_fentry (y)) {
	   if (eq_subs (t, z, TRUE, TRUE))
	      return z;
	}

	return NULL;
}

/*
 *	get_..stub functions
 *	In order to locate the parents of subunits
 *	for packag body
 *	task body
 *	subprogram body
 */
ac	get_pbstub (env, tag)
ac	env;
char	*tag;
{
	ac	y;

	ASSERT (primary_env (env), ("XXX"));

	y = give_stub (env, tag);
	if (y == NULL || !is_package (g_stub_spec (y)))
	   return NULL;
	
	return y;
}

ac	get_tbstub (env, tag)
ac	env;
char	*tag;
{
	ac	y;

	ASSERT (primary_env (env), ("XXX"));

	y = give_stub (env, tag);
	if (y == NULL || !is_task (y, g_stub_spec (y)))
	   return NULL;

	return y;
}

ac	get_sstub (ct, node)
ac	ct,
	node;
{
	ac	t;

	if (ct == NULL) {
	   error ("cannot find proper environment for %s\n", g_tag (node));
	   exit (10);
	}

	t = give_stub (ct, g_tag (node));

	if (t == NULL) {
	   error ("fatal: cannot locate parent of %s\n", g_tag (node));
	   exit (11);
	}

	if (is_derived (t) ||
	    !eq_subs (node, g_stub_spec (t), TRUE, TRUE)) {
	   error ("fatal: profile of separate routine %s not compatible\n",
							g_tag (node));
	   exit (12);
	}

	return t;
}

static
bool	primary_env (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XTASKBODY:
	   case XPACKBODY:
	   case XSUBBODY:
		return TRUE;

	   default:
		return FALSE;
	}
}

static
ac	give_stub (x, tag)
ac	x;
char	*tag;
{
	ac	y;

	FORALL (y, get_locallist (x)) {
/*
	   if (g_d (y) == XSTUB && eq_tags (tag, g_tag (g_stub_spec (y))))
 */
	   if (g_d (y) == XSTUB && eq_tags (tag, g_tag (y)))
	      return y;
	}

	return NULL;
}

/*
 *	Local checking routines
 */
static
bool	is_overloadable (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	return (is_sub (x) || is_enumlit (x));
}

/*
 *	Is the symbol x really one we want to
 *	encounter on the symbol table?
 */
bool	need_entering (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XACCTYPE:
	   case XRECTYPE:
	   case XARRAYTYPE:
	   case XNEWTYPE:
	   case XENUMTYPE:
	   case XTASKTYPE:
		return g_type_spec (x) == NULL;

	   case XPACKBODY:
	   case XSUBBODY:
	   case XTASKBODY:
	        return FALSE;

	   case XOBJECT:
	        return g_object_spec (x) == NULL;

	   default:
		return TRUE;
	}
}

/*
 *	Does the symbol x hides the, already processed, symbol y ?
 */
bool	does_hide (x, y)
ac	x,
	y;
{
/*
 *	Trivial case first, check equality identifiers
 */
	if (g_d (y) == XCHARLIT)
	   return FALSE;

	if (!eq_tags (g_tag (x), g_tag (y)))
	   return FALSE;

/*
 *	First a special case: body does not hide corresponding
 *	specification
 */
	if (is_body (x) && g_specif (x) == y)
	   return FALSE;

	if (g_d (x) == XSTUB)
	   return FALSE;


	if (!is_overloadable (x))
	   return TRUE;

	if (!is_overloadable (y))
	   return FALSE;

	if (is_enumlit (x) && is_enumlit (y))
	   return FALSE;

	if (eq_subs (x, y, TRUE, FALSE))
	   return TRUE;

	return FALSE;
}

/*
 *	Similar to does_hide. Used in processing
 *	visibility for imported (i.e. used) declarations
 */
bool	donotlike (x, y)
ac	x,
	y;
{
	if (x == NULL || y == NULL)
	   return FALSE;

	if (!eq_tags (g_tag (x), g_tag (y)))
	   return FALSE;

	if (is_sub (x) && is_sub (y))
	   return FALSE;

	if (is_enumlit (x) && is_enumlit (y))
	   return FALSE;

	if (g_d (x) == XCHARLIT && g_d (y) == XCHARLIT)
	   return FALSE;

	return TRUE;
}

/*
 *	Is the symbol found to be used or to be skipped?
 *	(Occurs when walking through the tree)
 */
bool	skip (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	switch (g_d (x)) {
	   case XWITH:
	   case XUSE:
	   case XPACKBODY:
	   case XSUBBODY:
	   case XTASKBODY:
	   case XSTUB:
	        return TRUE;

	   default:
	        return FALSE;
	}
}

/*
 *	Implicit use clause processing:
 *	When entering a package body the visibility of
 *	the corresponding specification has to be reestablished
 */
void	open_U ()
{
	ac	x,
		y;

	x = env;
	if (g_d (x) == XPACKBODY) {
	   x = g_fvisitem (g_specif (x));
	   while (x != NULL) {
	      if (g_d (x) == XUSE)
	         new_use (g_packname (x));
	      x = g_next (x);
	   }
	}
}

/*
 *	Preprocess the declarations that are to be made visible
 *	in the processing of a subunit (i.e. the declarations
 *	of the parent units#
 */
static
void	p3_proc (x)
ac	x;
{
	ac	y;

	ASSERT (x != NULL, ("p3_proc:1"));

	ASSERT (g_d (x) == XPACKAGE || g_d (x) == XSUB, ("p3_proc:2"));

/*
 *	This is a specification. Our namelist mechanis puts the
 *	entries on the visibility stack
 *	Don't bother
 */

	FORALL (y, get_locallist (x)) {
	   if (g_d (y) == XUSE) {
	      new_use (g_packname (y));
	   }
	}
}

static
void	p4_proc (x, tag)
ac	x;
char	*tag;
{
	ac	y;

	ASSERT (x != NULL, ("p4_proc:1"));
	ASSERT (g_d (x) == XPACKBODY ||
	        g_d (x) == XSUBBODY ||
	        g_d (x) == XTASKBODY, ("p4_proc:2"));

	new_scope (x);
	FORALL (y, get_locallist (x)) {
	   if (g_d (y) == XSTUB && eq_tags (tag, g_tag (y)))
	      return;

	   if (g_d (y) == XUSE) {
	      new_use (g_packname (y));
	      continue;
	   }

	   if (skip (y) || !has_tag (y))
	      continue;

	   add_def (y);
	}

	error ("%s not found in %s (library disorganized?)\n", tag, g_tag (x));
	exit (117);
}

static
void	p1_proc (x, tag)
ac	x;
char	*tag;
{
	if (x == NULL)
	   return;

	ASSERT (x != NULL, ("p1_proc:1"));
	ASSERT (g_d (x) == XPACKBODY ||
	        g_d (x) == XSUBBODY ||
	        g_d (x) == XTASKBODY , ("p1_proc:3"));


	if (g_enclunit (x) == std) {	/* at the outside	*/
	   p3_proc (g_specif (x));
	   p4_proc (x, tag);
	}
	else
	{  p1_proc (g_enclunit (x), g_tag (x));
	   p4_proc (x, tag);
	}
}

void	p_proc (x, tag)
ac	x;
char	*tag;
{
	if (x == NULL)
	   return;

	ASSERT (g_d (x) == XSEPARATE, ("p_proc:1"));

	p1_proc (((struct lib_unit *)g_septree (x)) -> unit, tag);
}

/*
 *	Get the name (including the left context)
 *	of a compilation unit
 */
char	*procname (x)
ac	x;
{
	static char y [100];

	y [0] = 0;		/* kind of init */

	ASSERT (x != NULL, ("procname:1"));
	ASSERT (g_d (x) == XPACKBODY ||
	        g_d (x) == XTASKBODY ||
	        g_d (x) == XSUBBODY, ("procname:2"));

	p2_name (g_enclunit (x), y);
	cat_to (y, g_tag (g_specif (x)));
	return y;
}

static
void	p2_name (x, y)
ac	x;
char	*y;
{
	if (x == NULL)
	   return;

	if (!(g_d (x) == XPACKBODY ||
	    g_d (x) == XTASKBODY ||
	    g_d (x) == XSUBBODY))
	   return;

	if (g_enclunit (x) == std)
	   return;

	p2_name (g_enclunit (x), y);
	cat_to (y, g_tag (g_specif (x)));
	cat_to (y, ".");
}
 
