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
 *	MK_XXXX, node creating subroutines
 */
ac	mk_abort (x)
ac	x;
{
	ac	t = nalloc (XABORTSTAT);

	s_abortedtask (t, x);
	return t;
}

ac	mk_component (tags, expr)
ac	tags,
	expr;
{
	ac	t;

	t = nalloc (XCOMPASSOC);
	s_fcompchoice (t, tags);
	s_compexpr (t, expr);
	return (t);
}

ac	nalloc (d)
int	d;
{
	ac	t = alloc (d);

	s_lineno (t, yylineno);
	return t;
}


ac	mk_charlit (b, t)
char	b;
ac	t;
{
	ac	x;
	char	*y = (char	*)l_alloc (2);
	
	y [0] = b; y [1] = EOS;

	x = nalloc (XCHARLIT);
	s_tag (x, y);
	s_enclunit (x, t);
/*
 *	after creating the tag !!, no upper case
 *	conversion
 */
	return (x);
}

ac	mk_sbody (tag, spec)
char	*tag;
ac	spec;
{
	ac	t = nalloc (XSUBBODY);

	s_tag (t, tag);
	s_specif (t, spec);
	if (g_body_imp (spec) != NULL)
	   error ("more bodies tagged %s\n", tag);

	s_body_imp (spec, t);
	return t;
}

ac	mk_pbody (tag, spec)
char	*tag;
ac	spec;
{
	ac	t = nalloc (XPACKBODY);

	s_tag (t, tag);
	s_specif (t, spec);
	if (g_specif (t) == NULL) {
	   error ("fatal: cannot find corresponding spec %s\n", tag);
	   exit (13);
	}

	s_pack_body (spec, t);
	return t;
}

ac	mk_tbody (tag, spec)
char	*tag;
ac	spec;
{
	ac	t = nalloc (XTASKBODY);

	s_tag (t, tag);
	s_specif (t, spec);
	if (g_specif (t) == NULL) {
	   error ("fatal: canot find corresponding spec %s\n", tag);
	   exit (13);
	}

	s_taskbody (spec, t);
	return t;
}

ac	mk_task (tag)
char	*tag;
{
	ac	x,
		y;

	x = nalloc (XTASKTYPE);
	s_tag (x, tag);
	return x;
}

ac	mk_tselect ()
{
	return nalloc (XTASKSELECT);
}

ac	mk_accept (x)
ac	x;
{
	ac	t = nalloc (XACCEPT);

	s_specif (t, x);
	return t;
}

ac	mk_with (tr, id)
ac	tr;
char	*id;
{
	ac	t,
		x;

	if (tr == NULL) {
	   error ("fatal: cannot locate with-unit %s\n", id);
	   exit (9);
	}

	x = nalloc (XWITH);
	s_withunit (x, tr);
	s_tag (x, mk_tag (id, IDL));
	return x;
}


ac	mk_subtype (tag, parent)
char	*tag;
ac	parent;
{
	ac	t = nalloc (XSUBTYPE);

	s_tag (t, tag);
	s_parenttype (t, parent);
	if (is_sttype (parent))
	   set_sttype (t);

	return t;
}

ac	mk_filter (filtype, constraint)
ac	filtype,
	constraint;
{
	ac	t = nalloc (XFILTER);

	s_filtype (t, filtype);
	s_constraint (t, constraint);

	return t;
}

ac	mk_assign (left, right)
ac	left,
	right;
{
	ac	t = nalloc (XASSIGN);

	s_lhs (t, left);
	s_rhs (t, right);

	return t;
}

ac	mk_use (n)
ac	n;
{
	ac	t,
		r;

	if (n == NULL)
	   return NULL;

	if (g_d (n) != XNAME) {
	   error ("Construction too complicated for USE");
	   return NULL;
	}

	r = pack_name (g_fentity (n));
	if (r == NULL)
	   return NULL;

	t = nalloc (XUSE);
	s_packname (t, r);
	new_use (r);

	return t;
}



ac	mk_stub (tag, spec)
char	*tag;
ac	spec;
{
	ac	t = nalloc (XSTUB);

	s_tag (t, tag);
	s_stub_spec (t, spec);

	return t;
}

ac	mk_package (tag)
char	*tag;
{
	ac	t = nalloc (XPACKAGE);

	s_tag (t, tag);
	return t;
}

ac	mk_prpart ()
{
	return nalloc (XPRIVPART);
}

ac	mk_exception (tag)
char	*tag;
{
	ac	t = nalloc (XEXCEPTION);

	s_tag (t, tag);
	return t;
}

ac	mk_object (tag, d)
char	*tag;
ac	d;	/* descriptor		*/
{
	ac	t = nalloc (XOBJECT);

	s_tag (t, tag);
	s_desc (t, d);
	return t;
}

ac	mk_acctype (tag, actype)
char	*tag;
ac	actype;
{
	ac	t = nalloc (XACCTYPE);

	s_tag (t, tag);
	s_actype (t, actype);
	return t;
}

ac	mk_recnode (tag)
char	*tag;
{
	ac	t = nalloc (XRECTYPE);

	s_tag (t, tag);
	return t;
}

ac	mk_privtype (tag, discrs, flag)
char	*tag;
ac	discrs;
int	flag;
{
	ac	t = nalloc (XPRIVTYPE);

	s_tag (t, tag);
	s_fpdiscr (t, discrs);
	if (flag)
	   s_flags (t, g_flags (t) | LIMIT);

	return t;
}

ac	mk_generic ()
{
	ac	t = nalloc (XGENNODE);

	s_tag (t, NULL);	/* to be replaced	*/
	return t;
}


ac	mk_genpartype (t, k)
char	*t;
int	k;
{
	ac	x = nalloc (XGENPARTYPE);
	
	s_tag (x, mk_tag (t, IDL));
	s_genkind (x, k);
	return x;
}

ac	mk_incomplete (tag, discrs)
char	*tag;
ac	discrs;
{
	ac	t = nalloc (XINCOMPLETE);

	s_tag (t, tag);
	s_fidiscr (t, discrs);
	
	return t;
}

ac	mk_enum (tag)
char	*tag;
{
	ac	t = nalloc (XENUMTYPE);

	s_tag (t, tag);
	return t;
}

ac	mk_enlit (tag, tp)
char	*tag;
ac	tp;
{
	ac	t = nalloc (XENUMLIT);

	s_tag (t, tag);
	s_enclunit (t, tp);
	return t;
}

ac	mk_array (tag, index, elem)
char	*tag;
ac	index,
	elem;
{
	ac	t = nalloc (XARRAYTYPE);
	
	s_tag (t, tag);
	s_findex (t, index);
	s_elemtype (t, elem);
	return t;
}

ac	mk_rsel (x)
ac	x;
{
	ac	y = nalloc (XDISCR);

	s_comp (y, x);
	return y;
}

ac	mk_varnode ()
{
	return nalloc (XVARIANT);
}


ac	mk_dcons (agg)
ac	agg;
{
	ac	t = nalloc (XDISCRCONS);

	s_aggregate (t, agg);
	return t;
}

ac	mk_sub (tag, operator)
char	*tag;
bool	operator;
{
	ac	t = nalloc (XSUB);
	int	fn_code = 0;	/* default	*/

	s_tag (t, tag);
	if (operator) {
	   fn_code = std_oper (tag);
	   if (fn_code == 0) {
	      error ("illegal operator symbol %s\n", tag);
	      fn_code = 1;
	   }
	}

	set_std_fun (t, fn_code);

	return t;
}

ac	mk_entry (tag)
char	*tag;
{
	ac	t = nalloc (XENTRY);

	s_tag (t, tag);
	return t;
}

ac	mk_ecall (x)
ac	x;
{
	ac	t = nalloc (XENTRYCALL);

	s_fact (t, x);
	return t;
}

ac	mk_renobj (tag, type)
char	*tag;
ac	type;
{
	ac	t = nalloc (XRENOBJ);

	s_tag (t, tag);
	s_rentype (t, type);
	return t;
}

ac	mk_renpack (tag, renname)
char	*tag;
ac	renname;
{
	ac	t = nalloc (XRENPACK);

	s_tag (t, tag);
	s_renname (t, renname);
	return t;
}

ac	mk_aggnode (fcompas, aggtype)
ac	fcompas,
	aggtype;
{
	ac	t = nalloc (XAGGREGATE);

	s_fcompas (t, fcompas);
	s_aggtype (t, aggtype);

	return t;
}

ac	mk_in (inexpr, intype, not)
ac	inexpr;
ac	intype;
bool	not;
{
	ac	t = nalloc (XIN);

	s_inexpr (t, inexpr);
	s_intype (t, intype);

	if (not)
	   set_notin (t);
	else
	   set_in (t);

	return t;
}

ac	mk_literal (val, type)
ac	val,
	type;
{
	ac	t = nalloc (XLITERAL);

	s_val (t, val);
	s_littype (t, type);

	return t;
}

ac	mk_alloc (obtype, altype)
ac	obtype,
	altype;
{
	ac	t = nalloc (XALLOCATOR);

	s_obtype (t, obtype);
	s_altype (t, altype);

	return t;
}

ac	mk_attr (attr_val, entity)
int	attr_val;
ac	entity;
{
	ac	t = nalloc (XATTRIBUTE);

	s_attr_value (t, attr_val);
	s_entity (t, entity);
	return t;
}

ac	mk_namass (parname, nexp)
ac	parname,
	nexp;
{
	ac	t = nalloc (XNAMEDASS);

	s_parname (t, parname);
	s_nexp (t, nexp);
	return t;
}

ac	mk_whenitem (choice)
ac	choice;
{
	ac	t = nalloc (XWHENITEM);

	s_fwhenchoice (t, choice);
	return t;
}

ac	mk_if (ifitem)
ac	ifitem;
{
	ac	t = nalloc (XIF);

	s_IF_items (t, ifitem);
	return t;
}

ac	mk_ifitem (cond)
ac	cond;
{
	ac	t = nalloc (XIFITEM);

	s_ifcond (t, cond);
	return t;
}


ac	mk_block (tag, encl)
char	*tag;
ac	encl;
{
	ac	t = nalloc (XBLOCK);

	s_tag (t, tag);
	s_enclunit (t, encl);
	return t;
}

ac	mx_name (x, y)
ac	x,
	y;
{
	ac	t = nalloc (XNAME);

	s_fentity (t, x);
	s_types (t, y);

	return t;
}

ac	mk_loopblock (tag, encl, cond)
char	*tag;
ac	encl,
	cond;
{
	ac	t = nalloc (XLOOPBLOCK);

	s_tag (t, tag);
	s_enclunit (t, encl);
	s_cond (t, cond);
	return t;
}

ac	mk_forblock (tag, encl, dir)
char	*tag;
ac	encl;
int	dir;
{
	ac	t = nalloc (XFORBLOCK);

	s_tag (t, tag);
	s_enclunit (t, encl);

	set_forward (t, dir);
	return t;
}

ac	mk_icons (frange)
ac	frange;
{
	ac	t = nalloc (XINDEXCONS);

	s_frange (t, frange);
	return t;
}

ac	mk_exit (l)
ac	l;
{
	ac	t,
		y;

	if (l == NULL) {
	   error ("exit outside loop");
	   return NULL;
	}

	while (g_d (l) == XTAGSTAT)
	   l = g_t_stat (l);

	if (!is_loop (l)) {
	   error ("%s no loop name", g_tag (l));
	   return NULL;
	}

	t = nalloc (XEXIT);
	s_loopid (t, l);
	return t;
}


ac	mk_return ()
{
	ac	r,
		t;

	r = encl_sub ();
	if (r == NULL)
	   error ("Non enclosed return found");

	t = nalloc (XRETURN);
	s_enclsub (t, r);
	return t;
}

ac	mk_parexpr (x)
ac	x;
{
	ac	t = nalloc (XPARENTHS);
	
	s_subexpr (t, x);
	return t;
}

ac	mk_raise (exc)
ac	exc;
{
	ac	t = nalloc (XRAISE);

	s_exception (t, exc);
	return t;
}

bool	bas_attribute (x)
ac	x;
{
	if (g_attr_value (x) != A_BASE ||
	    g_entity (x) != NULL) {
	     error ("illegal base attribute");
	     return FALSE;
	}

	return TRUE;
}

ac	mk_newtype (x, tag, mark)
ac	x;
char	*tag;
int	mark;
{
	ac	t = nalloc (XNEWTYPE);

	s_old_type (t, x);
	s_tag (t, tag);
	s_mark (t, mark);
	return t;
}

ac	mk_separate (t)
char	*t;
{
	ac	x = nalloc (XSEPARATE);

	s_tag (x, mk_tag (t, IDL));
	return x;
}

ac	mk_index (x)
ac	x;
{
	ac	t = nalloc (XINDEX);

	s_indextype (t, x);
	return t;
}

ac	mk_thunk (x)
ac	x;
{
	ac	t = nalloc (XTHUNK);

	s_thexpr (t, x);
	return t;
}

ac	mk_rensub (subnode)
ac	subnode;
{
	ac	t = nalloc (XRENSUB);
	ac	y;

	y = g_fformal (subnode);
	s_fformal (t, g_fformal (subnode));
	s_flags (t, g_flags (subnode));
	s_tag (t, mk_tag (g_tag (subnode), IDL));
	s_rettype (t, g_rettype (subnode));

	while (y != NULL) {
	   s_enclunit (y, t);
	   y = g_next (y);
	}

	return t;
}

ac	mx_all (type)
ac	type;
{
	ac	t = nalloc (XALL);

	s_types (t, type);
	return t;
}

ac	mk_all (n)
ac	n;
{
	ac	t = nalloc (XALL);

	s_next (t, n);
	return t;
}


ac	mk_sbcall (x)
ac	x;
{
	ac	t = nalloc (XSUBCALL);

	s_subpr (t, x);
	return t;
}


ac	mk_case (x)
ac	x;
{
	ac	t = nalloc (XCASE);

	s_caseexpr (t, x);
	return t;
}

ac	mk_range (r_type, e1, e2)
ac	r_type,
	e1,
	e2;
{
	ac	t = nalloc (XRANGE);

	s_rangetype (t, r_type);
	if (e1)
	   s_next (e1, e2);

	s_frang_exp (t, e1);
	return (t);
}

ac	mk_first (node, ct)
ac	node,
	ct;
{
	ac	d = mk_attr (A_FIRST, NULL);

	s_types (d, ct);
	s_next (d, node);
	s_entity (d, mk_expr (std_univ, cp_value (1, std_univ)));
	set_static (g_entity (d));

	return mk_expr (ct, try_attrib (d));
}

ac	mk_last (node, ct)
ac	node,
	ct;
{
	ac	d = mk_attr (A_LAST, NULL);

	s_types (d, ct);
	s_next (d, node);
	s_entity (d, mk_expr (std_univ, cp_value (1, std_univ)));
	set_static (g_entity (d));

	return mk_expr (ct, try_attrib (d));
}

ac	mk_expr (e_type, prim)
ac	e_type,
	prim;
{
	ac	t = nalloc (XEXP);

	s_exptype (t, e_type);
	s_primary (t, prim);
	return t;
}

ac	mk_desc (subtype, kind, expr)
ac	subtype,
	expr;
int	kind;
{
	ac	t;

	if (subtype == NULL)
	   return NULL;

	t = nalloc (XOBJDESC);
	s_objtype (t, subtype != NULL ? subtype : std_univ);
	set_kind (t, kind);
	s_expr (t, expr);

	return t;
}

/*
 *	create a new and_then node or add an expression to
 *	the last item of the list.
 *	If top_node does not exist, it is created.
 *	top node is always the result of the function
 */
ac	mk_andthen (left, right, k)
ac	left,
	right;
int	k;
{
	ac	t,
		topnode;

	t = nalloc (XSCC);
	s_andthen (t, (k == S_AND_THEN));
	s_fsccexpr (t, left);
	s_next (left, right);
	topnode = mk_expr (std_boolean, t);

	return topnode;
}

ac	mk_select (left, right, k)
ac	left,
	right;
int	k;
{
	ac	t = nalloc (XSELECT);

	s_entity (t, right);
	s_next   (t, left);
	s_flags  (t, g_flags (t) | k);
	return t;
}

ac	mx_typeconv (types, convexpr)
ac	types,
	convexpr;
{
	ac	t = nalloc (XTYPECONV);

	s_convexpr (t, convexpr);
	s_newtype  (t, types);
	return t;
}

ac	mx_ecall (types, right)
ac	types,
	right;
{
	ac	t = nalloc (XENTRYCALL);

	s_types (t, types);
	s_fact  (t, right);

	return t;
}

ac	mk_call (left, right)
ac	left,
	right;
{
	ac	t = nalloc (XCALL);

	s_next (t, left);
	s_fact (t, right);

	return t;
}

ac	mk_slice (left, right)
ac	left,
	right;
{
	ac	t = nalloc (XSLICE);

	s_next (t, left);
	s_slrange (t, right);

	return t;
}

ac	mx_call (types, right)
ac	types,
	right;
{
	ac	t = nalloc (XCALL);

	s_fact (t, right);
	s_types (t, types);
	return t;
}

ac	mk_delay (x)
ac	x;
{
	ac	t = nalloc (XDELAY);

	s_delay_expr (t, x);
	return t;
}


ac	mk_unresrec (x)
char	*x;
{
	ac	t = nalloc (XUNRESREC);

	s_ident (t, x);
	return t;
}

ac	mx_slice (types, right)
ac	types,
	right;
{
	ac	t = nalloc (XSLICE);

	s_types (t, types);
	s_slrange (t, right);
	return t;
}

ac	mk_arrselect (left, right)
ac	left,
	right;
{
	ac	t = nalloc (XINDEXING);

	s_farg (t, right);
	s_next (t, left);

	return t;
}

ac	mk_applied (x)
ac	x;
{
	ac	t = nalloc (XNAME);

	s_fentity (t, x);
	return t;
}

ac	mk_unchar (c)
char	c;
{
	char	*ss ;
	ac	x;

	x = nalloc (XUNRESCHAR);
	s_ident (x, mk_chartag (c));

	return x;
}

ac	mk_subcall (x)
ac	x;
{
	ac	t = nalloc (XSUBCALL);

	s_subpr (t, x);
	return t;
}

ac	mk_foruse (x, y)
ac	x,
	y;
{
	ac	t = nalloc (XFORUSE);

	s_forused (t, x);
	s_useexpr (t, y);
	return t;
}

