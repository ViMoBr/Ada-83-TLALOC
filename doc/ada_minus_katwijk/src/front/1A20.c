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
 * Information about the software in general, and also about licensing
 * can be obtained from:
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 *	G E N E R I C  E X P A N S I O N
 *
 *	This module is responsible for the generic expansion
 *	of a unit. Given a (correctly processed) CALL
 *	structure representing the call to a generic
 *	unit this module returns a, completely processed, tree
 *
 *	Version	1
 *	J van Katwijk
 */

/*
 *	I M P L E M E N T A T I O N
 */
#define	MAPSIZE	04000
struct map_struct {
	ac	mapin, mapout;
};

typedef	struct map_struct	mapelement;
struct mapper {
	ac	map_func;
	int	mapcnt;
	int	mapmax;
	mapelement	mapdata[1];
};

typedef	struct mapper	*map;
/*
 *	Forward declarations:
 */
static	map	map_malloc	();
static	void	upd_map		();
static	ac	look_map	();
static	int	map_size	();
static	map	new_map		();
static	ac	inst_list	();
static	ac	inst_elem	();
static	ac	new_		();
static	ac	to_be_exp	();
static	void	func_map	();
static	void	par_map		();
static	ac	repl_genpar	();
static	ac	repl_genpar2	();

static
map	map_malloc (n)
int	n;
{
	char	*p;

	p = (char *)malloc (n * sizeof (mapelement) + sizeof (struct mapper));

	if (p == NULL) {
	   printf ("memory problem, unrecoverable\n");
	   abort ();
	}

	((map)p) -> mapmax = n;
	((map)p) -> mapcnt = 0;

	return (map)p;
}

static
void	upd_map (m, p, q)
map	m;
ac	p,
	q;
{
	mapelement	a;

	if (m == NULL)
	   return;

	a. mapin = p;
	a. mapout = q;

	if (m -> mapcnt >= m -> mapmax) {
	   printf ("Map overflow, unrecoverable");
	   abort ();
	}

	m -> mapdata [m -> mapcnt ++] = a;
}

static
ac	look_map (m, x)
map	m;
ac	x;
{
	mapelement	*l;
	int	i;

	if (m == NULL)
	   return x;

	l = &m -> mapdata [0];

	for (i = 0; i < m -> mapcnt; i ++) {
	   if (l [i]. mapin == x)
	      return l [i]. mapout;
	}

	return x;
}


static
int	mapsize (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	ASSERT (g_d (x) == XGENNODE, ("mapsize"));

	return 1000;
}

static
map	new_map (x, y)
ac	x,
	y;
{
	int	size;
	map	z;

	if (x == NULL)
	   return (map)0;

	size = mapsize (y);

	z = map_malloc (size);
	z -> map_func = x;
	
	return z;
}

/*
 *	Tree copying is for (almost) free now. Just instantiate
 *	the topnode under a NULL mapping
 */
ac	cp_tree (x)
ac	x;
{
	return inst_elem (x, NULL);
}

/*
 *	Instantiate a list of items. The elements in the list
 *	are connected by their next pointers
 */
static
ac	inst_list (list, the_map)
ac	list;
map	the_map;
{
	ac	x,
		y,
		z;

	if (list == NULL)
	   return NULL;

	y = inst_elem (list, the_map);
	z = y;


	FORALL (x, g_next (list)) {
	   s_next (y, inst_elem (x, the_map));
	   y = g_next (y);
	}

	return z;
}

/*
 *	inst_elem instantiates a tree element, including
 *	its subtrees. The routine new_ takes care
 *	the generation of a node inclusing the translation
 *	of back links.
 */
static
ac	inst_elem (elem, the_map)
ac	elem;
map	the_map;
{
	ac	new_elem;

	if (elem == NULL)
	   return NULL;

	new_elem = new_ (elem, the_map);

	switch (g_d (elem)) {
	case XACCTYPE:
		break;

	case XAGGREGATE:
                if (g_d (g_aggtype (elem)) == XFILTER) {
	           s_aggtype (new_elem, inst_elem (g_aggtype (elem), the_map));
                }
		s_fcompas (new_elem, inst_list (g_fcompas (elem), the_map));
		break;

	case XALL:
		s_next (new_elem, inst_elem (g_next (elem), the_map));
		break;

	case XALLOCATOR:
		if (g_d (g_obtype (elem)) == XFILTER) {
		   s_obtype (new_elem, inst_list (g_obtype (elem), the_map));
		}
		break;

	case XARRAYTYPE:
		s_findex (new_elem, inst_list (g_findex (elem), the_map));	
		break;

	case XASSIGN:
		s_lhs (new_elem, inst_elem (g_lhs (elem), the_map));
		s_rhs (new_elem, inst_elem (g_rhs (elem), the_map));
		break;

	case XATTRIBUTE:
		s_next   (new_elem, inst_elem (g_next   (elem), the_map));
		s_entity (new_elem, inst_elem (g_entity (elem), the_map));
		new_elem = try_attrib (new_elem);
		break;

	case XABORTSTAT:
		s_abortedtask (new_elem, inst_elem (g_abortedtask (elem), the_map));
		break;

	case XENTRYCALL:
		s_next (new_elem, inst_elem (g_next (elem), the_map));
		s_fact (new_elem, inst_list (g_fact (elem), the_map));
		s_call_delay (new_elem, inst_elem (g_call_delay (elem), the_map));
		break;

	case XBLOCK:
		s_fblockloc (new_elem, inst_list (g_fblockloc(elem), the_map));
		s_BLK_stats (new_elem, inst_list (g_BLK_stats (elem), the_map));
		s_BLK_exh   (new_elem, inst_list (g_BLK_exh (elem), the_map));
		break;

	case XCALL:
		s_next (new_elem, inst_elem (g_next (elem), the_map));
		s_fact (new_elem, inst_list (g_fact (elem), the_map));
		new_elem = repl_func (new_elem);
		break;

/*
	case XCALLTHUNK:
		break;
 */

	case XCASE:
		s_caseexpr (new_elem, inst_elem (g_caseexpr (elem), the_map));
		s_CASE_items (new_elem, inst_list (g_CASE_items (elem), the_map));
		break;

	case XTASKSELECT:
		s_SELECT_items (new_elem, inst_list (g_SELECT_items (elem), the_map));
		break;

	case XCHARLIT:
		break;

	case XCOMPASSOC:
		s_fcompchoice (new_elem, inst_list (g_fcompchoice (elem), the_map));
		s_compexpr   (new_elem, inst_elem (g_compexpr (elem), the_map));
		break;

	case XDISCR:
		break;

	case XDISCRCONS:
		s_aggregate (new_elem, inst_list (g_aggregate (elem), the_map));
		break;

	case XENUMLIT:
		break;

	case XENUMTYPE:
		s_fenumlit (new_elem, inst_list (g_fenumlit (elem), the_map));
		break;

	case XEXCEPTION:
		break;

	case XEXHANDLER:
		s_EXH_items (new_elem, inst_list (g_EXH_items (elem), the_map));
		break;

	case XEXIT:
		s_exitcond (new_elem, inst_elem (g_exitcond (elem), the_map));
		break;

	case XEXP:
		s_primary (new_elem, inst_elem (g_primary (elem), the_map));
		break;

	case XFILTER:
		s_constraint (new_elem, inst_elem (g_constraint (elem), the_map));
		break;

	case XFORBLOCK:
		s_looppar (new_elem, inst_list (g_looppar (elem), the_map));
		s_FB_stats(new_elem, inst_list (g_FB_stats(elem), the_map));
		break;

	case XFORUSE:
		s_useexpr (new_elem, inst_elem (g_useexpr (elem), the_map));
		break;

	case XGENNODE:
		s_genpars (new_elem, inst_list (g_genpars (elem), the_map));
		s_genunit (new_elem, inst_elem (g_genunit (elem), the_map));
		break;

	case XGENPARTYPE:
		break;

	case XGOTO:
		break;

	case XIF:
		s_IF_items (new_elem, inst_list (g_IF_items (elem), the_map));
		break;

	case XDELAY:
		s_delay_expr (new_elem, inst_elem (g_delay_expr (elem), the_map));
		break;

	case XTERMINATE:
		break;

	case XIFITEM:
		s_ifcond (new_elem, inst_elem (g_ifcond (elem), the_map));
		s_IF_stats (new_elem, inst_list (g_IF_stats (elem), the_map));
		break;

	case XIN:
		s_inexpr (new_elem, inst_elem (g_inexpr (elem), the_map));
		if (g_d (g_intype (elem)) == XFILTER)
		   s_intype (new_elem, inst_elem (g_intype (elem), the_map));
		break;

	case XINCOMPLETE:
		s_fidiscr (new_elem, inst_list (g_fidiscr (elem), the_map));
		break;

	case XINDEX:
		break;

	case XINDEXCONS:
		s_frange (new_elem, inst_list (g_frange (elem), the_map));
		break;

	case XINDEXING:
		s_next (new_elem, inst_elem (g_next (elem), the_map));
		s_farg (new_elem, inst_list (g_farg (elem), the_map));
		break;

	case XINDIRECT:
		break;

	case XINTERNAL:
		break;

/*
	case XLABDEF:
		break;
 */

	case XLITERAL:
		s_val (new_elem, g_val (elem));	/* share	*/
		break;

	case XLOOPBLOCK:
		s_cond (new_elem, inst_elem (g_cond (elem), the_map));
		s_LPB_stats (new_elem, inst_list (g_LPB_stats (elem), the_map));
		break;

	case XMARK:
		break;

	case XNEWTYPE:
		s_enlits (new_elem, inst_list (g_enlits (elem), the_map));
		break;

	case XINHERIT:
		break;

	case XNAME:
		break;

	case XNAMEDASS:
		s_nexp (new_elem, inst_elem (g_nexp (elem), the_map));
		break;

	case XOBJDESC:
		s_expr (new_elem, inst_elem (g_expr (elem), the_map));
		break;

	case XOBJECT:
		s_desc (new_elem, inst_elem (g_desc (elem), the_map));
		break;

	case XPACKAGE:
		s_fvisitem (new_elem, inst_list (g_fvisitem (elem), the_map));
		break;

	case XTASKTYPE:
		s_fentry (new_elem, inst_list (g_fentry (elem), the_map));
		break;

	case XPACKBODY:
		s_fbodyloc (new_elem, inst_list (g_fbodyloc (elem), the_map));
		s_PB_stats (new_elem, inst_list (g_PB_stats (elem), the_map));
		s_PB_exh   (new_elem, inst_list (g_PB_exh   (elem), the_map));
		break;

	case XPARENTHS:
		s_subexpr (new_elem, inst_elem (g_subexpr (elem), the_map));
		break;

	case XPRIVPART:
		s_fprivitem (new_elem, inst_list (g_fprivitem (elem), the_map));
		break;

	case XPRIVTYPE:
		s_fpdiscr (new_elem, inst_list (g_fpdiscr (elem), the_map));
		break;

	case XRAISE:
		break;

	case XRANGE:
		s_frang_exp (new_elem, inst_list (g_frang_exp (elem), the_map));
		break;

	case XRECTYPE:
		s_ffield (new_elem, inst_list (g_ffield (elem), the_map));
		s_dis    (new_elem, inst_elem (g_dis    (elem), the_map));
		break;

	case XRENOBJ:
		s_name (new_elem, inst_elem (g_name (elem), the_map));
		break;

	case XRENPACK:
		break;

	case XRENSUB:
		s_fformal (new_elem, inst_list (g_fformal (elem), the_map));
		s_subname (new_elem, inst_elem (g_subname (elem), the_map));
		break;

	case XRETURN:
		s_retexpr (new_elem, inst_elem (g_retexpr (elem), the_map));
		break;

	case XSCC:
		s_fsccexpr (new_elem, inst_list (g_fsccexpr (elem), the_map));
		break;

	case XSELECT:
		s_next (new_elem, inst_elem (g_next (elem), the_map));
		break;

	case XSET:
		break;

	case XSEPARATE:
		break;

	case XSETELEM:
		break;

	case XSLICE:
		s_next (new_elem, inst_elem (g_next (elem), the_map));
		s_slrange (new_elem, inst_elem (g_slrange (elem), the_map));
		break;

	case XSTUB:
		break;

/*
	case XSTRINGLIT:
		break;
 */

	case XSUB:
		s_fformal (new_elem, inst_list (g_fformal (elem), the_map));
		break;

	case XENTRY:
		s_fformal (new_elem, inst_list (g_fformal (elem), the_map));
		break;

	case XSUBBODY:
		s_fbodyloc (new_elem, inst_list (g_fbodyloc (elem), the_map));
		s_SBB_stats (new_elem, inst_list (g_SBB_stats (elem), the_map));
		s_SBB_exh  (new_elem, inst_list (g_SBB_exh  (elem), the_map));
		break;

	case XTASKBODY:
		s_fbodyloc (new_elem, inst_list (g_fbodyloc (elem), the_map));
		s_task_stats (new_elem, inst_list (g_task_stats (elem), the_map));
		s_task_exh (new_elem, inst_list (g_task_exh (elem), the_map));
		break;

	case XACCEPT:
		s_accept_stats (new_elem, inst_list (g_accept_stats (elem), the_map));
		break;

	case XSUBCALL:
		s_subpr (new_elem, inst_elem (g_subpr (elem), the_map));
		break;

	case XSUBTYPE:
		if (g_d (g_parenttype (elem)) == XFILTER) {
		   s_parenttype (new_elem, inst_elem (g_parenttype (elem), the_map));
		}
		break;

	case XTAGSTAT:
		break;

	case XTHUNK:
		s_thexpr (new_elem, inst_elem (g_thexpr (elem), the_map));
		break;

	case XTYPECONV:
		s_convexpr (new_elem, inst_elem (g_convexpr (elem), the_map));
		break;

	case XUSE:
		break;

	case XUNRESREC:
		break;

	case XUNRESCHAR:
		break;

	case XVARIANT:
		s_ffield (new_elem, inst_list (g_ffield (elem), the_map));
		if (g_fvariant (g_enclunit (new_elem)) == NULL)
		   s_fvariant (g_enclunit (new_elem), new_elem);
		s_dis (new_elem, inst_elem (g_dis (elem), the_map));
		s_varchoice (new_elem, inst_list (g_varchoice (elem), the_map));
		break;

	case XWHENITEM:
		s_fwhenchoice (new_elem, inst_list (g_fwhenchoice (elem), the_map));
		s_WI_stats (new_elem, inst_list (g_WI_stats (elem), the_map));
		break;

	case XWITH:
		break;

/*
	case XQUALIF:
		break;
 */

	case XTRIPLE:
		break;
	}

	return new_elem;
}


static
ac	new_ (elem, the_map)
ac	elem;
map	the_map;
{
	ac	new_elem;

	new_elem = nalloc (g_d (elem));
/*
 *	Open your eyes again
 */
	if (has_link (elem))
	   upd_map (the_map, elem, new_elem);

	s_lineno (new_elem, yylineno);	/* imported from the parser */
	s_flags (new_elem, g_flags (elem));
	if (has_tag (elem))
	   s_tag (new_elem, g_tag (elem));	/* share	*/

	if (is_enclosed (elem))
	   s_enclunit (new_elem, look_map (the_map, g_enclunit (elem)));

	if (is_type (elem)) {
	   s_type_spec (new_elem, look_map (the_map, g_type_spec (elem)));
	   set_to (g_type_spec (new_elem), new_elem);
	}

	if (is_name (elem))
	   s_types (new_elem, look_map (the_map, g_types (elem)));

	switch (g_d (elem)) {
	case XACCTYPE:
		s_actype (new_elem, look_map (the_map, g_actype (elem)));
		break;

	case XAGGREGATE:
                if (g_d (g_aggtype (elem)) != XFILTER) {
		   s_aggtype (new_elem, look_map (the_map, g_aggtype (elem)));
		}
                break;

	case XALL:
		break;

	case XALLOCATOR:
		s_altype (new_elem, look_map (the_map, g_altype (elem)));
		if (g_d (g_obtype (elem)) != XFILTER) {
		   s_obtype (new_elem, look_map (the_map, g_obtype (elem)));
		}
		break;

	case XARRAYTYPE:
		s_elemtype (new_elem,
		   CONST_TYPE (look_map (the_map, g_elemtype (elem)),
		                        "Unconstrained type %s\n",
		                        g_tag (new_elem) ));
		break;

	case XASSIGN:
		break;

	case XATTRIBUTE:
		s_attr_value (new_elem, g_attr_value (elem));
		break;

	case XABORTSTAT:
		break;

	case XENTRYCALL:
		s_e_num (new_elem, g_e_num (elem));
		s_e_entry (new_elem, look_map (the_map, g_e_entry (elem)));
		break;

	case XBLOCK:
		break;

	case XCALL:
		break;

/*
	case XCALLTHUNK:
		s_thunk (new_elem, look_map (the_map, g_thunk (elem)));
		break;
 */

	case XCASE:
		break;

	case XTASKSELECT:
		s_SEL_count (new_elem, g_SEL_count (elem));
		break;

	case XCHARLIT:
		s_enuml_ord (new_elem, g_enuml_ord (elem));
		break;

	case XCOMPASSOC:
		break;

	case XDISCR:
		s_comp (new_elem, look_map (the_map, g_comp (elem)));
		break;

	case XDISCRCONS:
		break;

	case XENUMLIT:
		s_enuml_ord (new_elem, g_enuml_ord (elem));
		break;

	case XENUMTYPE:
		s_nenums (new_elem, g_nenums (elem));
		break;

	case XEXCEPTION:
		s_rnam (new_elem, look_map (the_map, g_rnam (elem)));
		break;

	case XEXHANDLER:
		break;

	case XEXIT:
		s_loopid (new_elem, look_map (the_map, g_loopid (elem)));
		break;

	case XEXP:
		s_exptype (new_elem, look_map (the_map, g_exptype (elem)));
		break;

	case XFILTER:
		s_filtype (new_elem, look_map (the_map, g_filtype (elem)));
		break;

	case XFORBLOCK:
		break;

	case XFORUSE:
		s_forused (new_elem, look_map (the_map, g_forused (elem)));
		break;

	case XGENNODE:
		break;

	case XGENPARTYPE:
		s_genkind (new_elem, g_genkind (elem));
		break;

	case XGOTO:
		break;

	case XIF:
		break;

	case XDELAY:
		break;

	case XTERMINATE:
		break;

	case XIFITEM:
		break;

	case XIN:
/*
 *	Tricky
 */
		if (g_d (g_intype (elem)) != XFILTER) {
		   s_intype (new_elem, look_map (the_map, g_intype (elem)));
		}
		break;

	case XINCOMPLETE:
		break;

	case XINDEX:
		s_indextype (new_elem, look_map (the_map, g_indextype (elem)));
		break;

	case XINDEXING:
		break;

	case XINDIRECT:
		ASSERT (FALSE, ("Ik hoor hier niet INDIR"));
		break;

	case XINTERNAL:
		ASSERT (FALSE, ("Ik hoor hier niet INTERN"));
		break;

/*
	case XLABDEF:
		break;
 */

	case XLITERAL:
		s_littype (new_elem, look_map (the_map, g_littype (elem)));
		break;

	case XLOOPBLOCK:
		break;

	case XMARK:
		ASSERT (FALSE, ("Help: internal"));
		break;

	case XNEWTYPE:
		s_old_type (new_elem, look_map (the_map, g_old_type (elem)));
		s_mark (new_elem, g_mark (elem));
		break;

	case XINHERIT:
		s_old_type (new_elem, look_map (the_map, g_old_type (elem)));
		s_inh_type (new_elem, look_map (the_map, g_inh_type (elem)));
		s_inh_oper (new_elem, look_map (the_map, g_inh_oper (elem)));
		s_is_hidden (new_elem, g_is_hidden (elem));
		break;

	case XNAME:
		if (!is_genpar (g_fentity (elem))) {
		   s_fentity (new_elem, look_map (the_map, g_fentity (elem)));
		}
		else
		   new_elem = repl_genpar (new_elem, elem, the_map);

		break;

	case XNAMEDASS:
		s_parname (new_elem, look_map (the_map, g_parname (elem)));
		break;

	case XOBJDESC:
	 { int k = g_flags (elem) & KMASK;
		  if (k == KVAR || k == KCOMP)
		      s_objtype (new_elem,
		         CONST_TYPE (look_map (the_map, g_objtype (elem)),
		               "Unconstrained type after instantiation", NULL));
		   else
		      s_objtype (new_elem, look_map (the_map, g_objtype (elem)));
		break;
	  }

	case XOBJECT:
		break;

	case XPACKAGE:
		break;

	case XTASKTYPE:
		break;

	case XPACKBODY:
		s_specif (new_elem, look_map (the_map, g_specif (elem)));
		s_pack_body (g_specif (new_elem), new_elem);
		break;

	case XPARENTHS:
		break;

	case XPRIVPART:
		s_priv (g_enclunit (new_elem), new_elem);
		break;

	case XPRIVTYPE:
		break;

	case XRAISE:
		s_exception (new_elem, look_map (the_map, g_exception (elem)));
		break;

	case XRANGE:
		s_rangetype (new_elem, look_map (the_map, g_rangetype (elem)));
		break;

	case XRECTYPE:
		break;

	case XRENOBJ:
		s_rentype (new_elem, look_map (the_map, g_rentype (elem)));
		break;

	case XRENPACK:
		s_renname (new_elem, look_map (the_map, g_renname (elem)));
		break;

	case XRENSUB:
		s_rettype (new_elem, look_map (the_map, g_rettype (elem)));
		break;

	case XRETURN:
		s_enclsub (new_elem, look_map (the_map, g_enclsub (elem)));
		break;

	case XSCC:
		s_andthen (new_elem, g_andthen (elem));
		break;

	case XSELECT:
		s_entity (new_elem, look_map (the_map, g_entity (elem)));
		break;

	case XSET:
		ASSERT (FALSE, ("XXXSET"));
		break;

	case XSEPARATE:
		ASSERT (FALSE, ("XXXSEPARATE"));
		break;

	case XSETELEM:
		ASSERT (FALSE, ("XXXSETELEM"));
		break;

	case XSLICE:
		break;

	case XSTUB:
		s_stub_spec (new_elem, look_map (the_map, g_stub_spec (elem)));
		break;

/*
	case XSTRINGLIT:
		s_littype (new_elem, look_map (the_map, g_littype (elem)));
		break;
 */

	case XSUB:
		s_rettype (new_elem, look_map (the_map, g_rettype (elem)));
		break;

	case XENTRY:
		s_rettype (new_elem, look_map (the_map, g_rettype (elem)));
		s_entry_nr (new_elem, g_entry_nr (elem));
		break;

	case XSUBBODY:
		s_specif (new_elem, look_map (the_map, g_specif (elem)));
		s_body_imp (g_specif (new_elem), new_elem);
		break;

	case XTASKBODY:
		s_specif (new_elem, look_map (the_map, g_specif (elem)));
		s_taskbody (g_specif (new_elem), new_elem);
		break;

	case XACCEPT:
		s_specif (new_elem, look_map (the_map, g_specif (elem)));
		break;

	case XSUBCALL:
		break;

	case XSUBTYPE:
		if (g_d (g_parenttype (elem)) != XFILTER) {
		   s_parenttype (new_elem, look_map (the_map, g_parenttype (elem)));
		}
		break;


	case XTAGSTAT:
		break;

	case XTHUNK:
		break;

	case XTYPECONV:
		s_newtype (new_elem, look_map (the_map, g_newtype (elem)));
		break;

	case XUSE:
		s_packname (new_elem, look_map (the_map, g_packname (elem)));
		break;

	case XUNRESREC:
		ASSERT (FALSE, ("UNRESREC"));
		break;

	case XUNRESCHAR:
		ASSERT (FALSE, ("UNRESREC"));
		break;

	case XWHENITEM:
		break;

	case XVARIANT:
		break;

	case XWITH:
		ASSERT (FALSE, ("WITH"));
		break;

/*
	case XQUALIF:
		break;
 */

	case XTRIPLE:
		break;
	}
	return new_elem;
}

static
ac	to_be_exp (x)
ac	x;
{
	ASSERT (x != NULL, ("to_be_exp"));

	x = g_fentity (g_next (x));

	ASSERT (x != NULL, ("to_be_exp"));
	ASSERT (g_d (x) == XGENNODE, ("to_be_exp:3"));

	return g_genunit (x);
}

static
void	func_map (the_map, formal, actual)
map	the_map;
ac	formal,
	actual;
{
	ac	x,
		y;

	y = actual;

	ASSERT (y != NULL, ("func_map:1"));
	ASSERT (is_sub (y), ("func_map:2"));

	upd_map (the_map, formal, y);

	x = f_formal (formal);
	y = f_formal (y);

	while (x != NULL) {
	   upd_map (the_map, x, y);
	   x = g_next (x);
	   y = g_next (y);
	}
}

static
void	par_map (the_map, t)
map	the_map;
ac	t;
{
	ac	x;

	ASSERT (t != NULL && g_d (t) == XCALL, ("par_map"));

	FORALL (x, g_fact (t)) {
	   switch (g_d (g_parname (x))) {
	   case XACCTYPE:
	   case XGENPARTYPE:
		ASSERT (x != NULL, ("par_map:1"));
		ASSERT (g_nexp (x) != NULL, ("par_map:2"));	
		ASSERT (g_d (g_primary (g_nexp (x))) == XNAME, ("par_map:3"));
		upd_map (the_map, g_parname (x),
		                  g_fentity (g_primary (g_nexp (x))));
		break;

	   case XSUB:
		func_map (the_map, 
		               g_parname (x),
				type_of (g_nexp (x)) );
		break;

	   case XOBJECT:
		ASSERT (x != NULL && g_d (g_primary (g_nexp (x))) == XNAME, ("par_map:4"));
		upd_map (the_map, g_parname (x),
		                  g_fentity (g_primary (g_nexp (x))) );
		break;

	   default:
		printf ("Cannot create map for %s (yet)\n",
			         g_tag (g_parname (x)) );
		break;
	   }
	}
}

/*
 *	The real expander is here:
 */
ac	expand (s, t)
char	*s;
ac	t;
{
	map	the_map;
	ac	x;

	ASSERT (t != NULL && g_d (t) == XCALL, ("expand"));

	x = to_be_exp (t);
	the_map = new_map (t, g_fentity (g_next (t)));
	par_map (the_map, t);

	if (g_d (x) == XPACKAGE) {
	   ac z;
	   ac y = nalloc (XPACKAGE);
/*
 *	First a simple circularity check
 */
	   if (open_scopes (x) != NULL) {
	      error ("Cannot make circular instantiation (%s)\n", s);
	      return NULL;
	   }
/*
 *	Mark that an instantiation has taken place
 */
	set_instantiated (x);
	   s_tag (y, mk_tag (s, IDL));
	   introduce (y);
	   add_def (y);
	   upd_map (the_map, x, y);
	   s_fvisitem (y, inst_list (g_fvisitem (x), the_map));
	   z = inst_elem (g_pack_body (x), the_map);

	   if (z != NULL) {
	      s_tag (z, g_tag (y));
	      introduce (z);
		return y;
	   }
	}
	else
	{
	   ASSERT (FALSE, ("expand:2"));
	}
}

static
ac	repl_genpar (new_elem, elem, the_map)
ac	new_elem,
	elem;
map	the_map;
{
	ac	t;

	FORALL (t, g_fact (the_map -> map_func)) {
	   if (g_fentity (elem) == g_parname (t)) {
	       return repl_genpar2 (new_elem, elem, t, the_map);
	   }
	}

	ASSERT (FALSE, ("Sorry: parameter not found"));
}

static
ac	repl_genpar2 (new_elem, elem, t, the_map)
ac	new_elem,
	elem,
	t;
map	the_map;
{
	switch (g_d (g_primary (g_nexp (t)))) {
	   case XNAME:
		s_fentity (new_elem, look_map (the_map, g_fentity (elem)));
		return new_elem;

	   case XSELECT:
		return cp_tree (g_primary (g_nexp (t)));

	   DEFAULT (("repl_genpar2"));
	}
}

