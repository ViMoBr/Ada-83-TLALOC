
/*
 * (c) copyright 1986, Delft University of Technology
 * Delft, The Netherlands
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * must be obtained, in writing, from the Delft University of Tech.
 *
 *	Contact for information
 *	Jan van Katwijk
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 *	Forward (static) declarations
 */
static	MAXADDR	variant	();
static	void	var_vd	();
static	MAXADDR	recf_vd	();
static	MAXADDR	recfield	();
static	MAXADDR	formals	();
static	MAXADDR	fld_offsets	();
static	MAXADDR	offtable	();
static	void	rec_inits	();
/*
 *XXX	ATTRIBUTE COMPUTATION
 */

/*
 *	Sometimes allocation is marked directly by the allocating procedures,
 *	sometimes by assigning the result of an allocating proc to
 *	lev_off.
 *	Typeref expects the new lev_off as result value, all others
 *	don't. These mechanisms won't clash, but it's messy.
 */
MAXADDR	typeconv (typeconv, off)
ac	typeconv;
MAXADDR	off;
{
	ASSERT (g_d (typeconv) == XTYPECONV, ("typeconv"));

	if (g_d (root_type (g_newtype (typeconv))) == XARRAYTYPE) {
	   off = incr_off (off, getvdsize (g_newtype (typeconv)));
	   s_TCON_Doff (typeconv, (off = align (off, MAX_ALIGN)));
	}

	return off;
}	/* end of tmp_typeconv */

/*
 * aggregate:	AGGREGATE CompAssoc {CompAssoc} M;
 */
MAXADDR	aggregate (agg, off, exptype)
ac	agg;
MAXADDR	off;
ac	exptype;
{
	ac	type;

	ASSERT (agg != NULL, ("aggregate:0"));
	ASSERT (g_d (agg) == XAGGREGATE, ("aggregate %d", g_d (agg)));

	type = root_type (g_aggtype (agg));
	if (g_d (type) == XRECTYPE) {
	   /* temps for value pointer and descr		*/
	   if (!is_table (agg)) {
	      off = incr_off (off, TADDRSIZE);
	      s_AGG_Voff (agg, (off = align (off, MAX_ALIGN)));
	   }

	   off = incr_off (off, getvdsize (type));
	   s_AGG_Doff (agg, (off = align (off, MAX_ALIGN)));

	   if (nodescr_aggr (agg))
	         return off;

	   if (disc_dep (agg))
	         return off;	/* do not bother		*/
	}
	else
	{  /* temps for value pointer and descr		*/
	   if (!is_table (agg)) {
	      off = incr_off (off, TADDRSIZE);
	      s_AGG_Voff (agg, (off = align (off, MAX_ALIGN)));
	   }

	  if (othersarray (agg))
	     return off;	/* forget about the Doff	*/

	  off = incr_off (off, getvdsize (type));
	  s_AGG_Doff (agg, (off = align (off, MAX_ALIGN)));
	}

	return off;
}

/* Allocator:	ALLOCATOR opt_constraint M;
 */
MAXADDR	all (al, off)
ac	al;
MAXADDR	off;
{
	ASSERT (g_d (al) == XALL, ("all %d", g_d (al)));

	/* only if needed we allocate a temp for the
	 * Doff.
	 */
	if (!known_descriptor (g_types (al))) {
	   off = incr_off (off,TADDRSIZE);
	   s_ALL_Doff (al, (off = align (off, MAX_ALIGN)));
	}

	return off;
}

/*
 *	Storage for the call
 */
MAXADDR	calling (op, off)
ac	op;
MAXADDR	off;
{
	ASSERT (g_d (op) == XCALL, ("Calling %d", g_d (op)));

	if (!known_descriptor (g_types (op))) {
	   off = incr_off (off, getvdsize (g_types (op)));
	   s_CALL_Doff (op, (off = align (off, MAX_ALIGN)));
	   s_flags (op, g_flags (op) | ORDR_EVAL);
	}

	if (is_composite (g_types (op))) {
	   off = incr_off (off, TADDRSIZE);
	   s_CALL_Voff (op, (off = align (off, MAX_ALIGN)));
	   s_flags (op, g_flags (op) | LARG_EVAL);
	}

	return off;
}	/* end of calling */

/*
 *	Storage for a task select
 * a taskselect construction has two locals, one to hold
 * the address of the calling task during a RDV,
 * one to hold the address of the first parameter of the RDV
 * for now, assumed that the values will be temps on a stack.
 */
MAXADDR	taskselect (node, off)
ac	node;
MAXADDR off;
{
	off = incr_off (off, TADDRSIZE);
	s_SEL_actuals (node, (off = align (off, MAX_ALIGN)));

	off = incr_off (off, TADDRSIZE);
	s_SEL_caller (node, (off = align (off, MAX_ALIGN)));

	return off;
}

MAXADDR entry (node, off)
ac	node;
MAXADDR	off;
{
	ac	p;
	MAXADDR	paroff;

	ASSERT (g_d (node) == XENTRY, ("entry"));

	if (curr_level == 0) {
	   paroff = 0;
	   s_ENTR_all (node, GLOBAL);
	}
	else 
	{  paroff = 0;
	   s_ENTR_all (node, FIXSTACK);
	   off += TADDRSIZE;
	   off = align (off, ADDR_ALIGN);
	   s_ENTR_off (node, off);
	}

	off = formals (g_fformal (node), &paroff, off, TASK);
	FORALL (p, g_fformal (node)) {
	   if (is_ncomp (g_objtype (g_desc (p)))) {
	      s_OBJ_descoff (p, (paroff = align (paroff, MAX_ALIGN)));
	      paroff += TADDRSIZE;
	   }
	}

	return off;
}

MAXADDR	scc (node, off)
ac	node;
MAXADDR	off;
{
	ASSERT (g_d (node) == XSCC, ("scc on %d", g_d (node)));

	s_SCC_Voff (node, 0);
	if (((g_flags (node) & LARG_EVAL) == LARG_EVAL) ||
	   ((g_flags (node) & ORDR_EVAL) == ORDR_EVAL) ) {
	   off = incr_off (off, TWORDSIZE);
	   s_SCC_Voff (node, (off = align (off, MAX_ALIGN)));
	}

	return off;
}

MAXADDR	slicing (op, off)
ac	op;
MAXADDR	off;
{
	MAXADDR	old_off;

	ASSERT (g_d (op) == XSLICE, ("Slicing"));

	off = incr_off (off, sz_vdarr (1));
	off = align (off, MAX_ALIGN);
	s_SLI_Doff (op, off);
	s_flags (op, g_flags (op) | ORDR_EVAL);

	return off;
}	/* end of slicing */

MAXADDR	attributing (op, off)
ac	op;
MAXADDR	off;
{
	ASSERT (g_d (op) == XATTRIBUTE, ("attributing"));

	switch (g_attr_value (op)) {
	   case A_IMAGE:
	      off = incr_off (off, sz_vdarr (1));
	      off = align (off, MAX_ALIGN);
	      s_ATTR_Doff (op, off);
	      s_flags (op, g_flags (op) | ORDR_EVAL);

	      return off;

	   default:
	      return off;
	}
}

/*
 *	storage for subbody:
 *	 give off a new value, if the function has a return
 *	 value, allocate a temp to keep it
 */
MAXADDR	subbody (x, off)
ac	x;
MAXADDR	off;
{
	ASSERT (g_d (x) == XSUBBODY, ("subbody"));

	s_SBB_level (x, curr_level);
	off = FRAMBASE;
	
	if (g_rettype (g_specif (x)) != notype) {
	   off += pcc_size (pcc_type_of (g_rettype (g_specif (x))));
	   s_SBB_valoff (x, off = align (off, ADDR_ALIGN));
	}

	lev_maxoff = off;

	return off;
}

MAXADDR	taskbody (x, off)
ac	x;
MAXADDR	off;
{
	ASSERT (g_d (x) == XTASKBODY, ("taskbody"));

	s_TSB_level (x, curr_level);
	off = FRAMBASE;

	lev_maxoff = off;
	return off;
}

/*
 * object:		OBJECT M ;
 */
MAXADDR	object (objp, off)
ac	objp;
MAXADDR	off;
{
	ac	dp;
	short	flags;
	short	kind;

	if (objp == NULL)
	   return;

	ASSERT (g_d (objp) == XOBJECT, ("object %d", g_d (objp) ));

	if (g_object_spec (objp) != NULL) {
	   return;
	}

	dp = g_desc (objp);
	kind = kind_of (dp);
	
	flags = getflags (g_objtype (dp));

	if (has_tasks (flags)) {
	   s_must_do_task_init (TRUE);
	   off = current_env_to_master (objp, off);
	}

	if ((flags & DYNREC) || (flags & UNCONS_REC)) {
	   /*
	    * can only hold for structured objects!
	    * allocation on DYNSTACK
	    */
	   if (curr_level == 0)
	      s_OBJ_alloc (objp, GLOBDYN);
	   else
	   {  s_OBJ_alloc (objp, FIXDYN);
	      off += TADDRSIZE;
	      off = align (off, ADDR_ALIGN);
	      s_OBJ_offset (objp, off);
	   }
	}
	else
	if (kind == KNUMB)
	   s_OBJ_alloc (objp, NOALLOC);
	else
	if (kind == KCONST && g_expr (dp) != NULL &&
	         is_scalar (g_objtype (dp)) && is_static (g_expr (dp)) )
	   s_OBJ_alloc (objp, NOALLOC);
	else
	if (kind == KCONST && g_expr (dp) != NULL &&
	         expr_provides_constraints (g_objtype (dp)) ) {
	   if (curr_level == 0) {
	      s_OBJ_offset (objp, new_lab ());
	      s_OBJ_alloc (objp, GLOBDYN);
	      s_OBJ_descoff (objp, new_lab ());
	   }
	   else
	   {  s_OBJ_alloc (objp, FIXDYN);
	      off += TADDRSIZE;
	      off = align (off, ADDR_ALIGN);
	      s_OBJ_offset (objp, off);
	   }
	}
	else
	if (curr_level == 0 ||
		        (kind == KCONST && static_or_discr (g_expr (dp)))) {
	   /*
	    * GLOBAL allocation
	    */
	   s_OBJ_alloc (objp, GLOBAL);
	   s_OBJ_offset (objp, new_lab ());
	} else
	{  /*
	    * allocation FIXSTACK
	    */
	   s_OBJ_alloc (objp, FIXSTACK);
	   off += sz_val (g_objtype (dp), NULL);
	   off = align (off, flags & F_ALIGN);
	   s_OBJ_offset (objp, off);
	}

	return off;
}	/* end of object */

/*
 * RenamedObj:	RENOBJ name M ;
 */
MAXADDR	renobj (renobjp, off)
ac	renobjp;
MAXADDR	off;
{
	ASSERT (renobjp != NULL && g_d (renobjp) == XRENOBJ, ("renobj:0"));

	off = typeref (g_rentype (renobjp), off);

	if (g_d (g_name (renobjp)) == XNAME) {
	   if (curr_level == 0) {
	      s_ROBJ_alloc (renobjp, GLOBAL);
	      s_ROBJ_offset (renobjp, new_lab ());
	   }
	   else
	   {  s_ROBJ_alloc (renobjp, FIXSTACK);
	      off += TADDRSIZE;
	      s_ROBJ_offset (renobjp, (off = align (off, ADDR_ALIGN)));
	   }
	} else
	   /*
	    * simple name is renamed
	    */
	   s_ROBJ_alloc (renobjp, NOALLOC);

	return off;
}	/* end of renobj */

/*
 * RecordType:	RECTYPE recfields opt_variant_sel M ;
 * opt_variant_sel:
 *		|
 *		variants DISCR M ;
 * variants:	variant_list  ;
 * variant_list:	|
 * 		variant_list variant ;
 */
MAXADDR	rectype (recp, off)
ac	recp;
MAXADDR	off;
{
	ac	p;
	ac	prevp = NULL;

	int	npathflds = 0;	/* local fld in path counter */
	MAXADDR fldoff	  = 0;	/* local field offset in path */
	MAXADDR vdoff	  = 0;	/* local desc. offset in path */

	ASSERT (recp != NULL, ("recp == NULL"));
	ASSERT (g_d (recp) == XRECTYPE, ("rectype %d\n", g_d (recp)));

	s_REC_nflds	(recp, 0);
	s_REC_npaths	(recp, 0);
	s_REC_ninits	(recp, 0);
	s_REC_forms	(recp, 0);
	s_REC_flags	(recp, 0);
	s_REC_alloc	(recp, GLOBAL);
	s_REC_offset	(recp, new_lab ());
	s_REC_maxpfld	(recp, 0);
	s_REC_vdsize	(recp, 0);
	s_REC_vsize	(recp, 0);
	/*
	 * NOTE: recp's attributes may be non-locally modified by:
	 *	"recfield", "variant", "var_vd".
	 */
/*
 *	Verify whether or not the record type allows
 *	unconstrained objects
 */
	p = g_ffield (recp);

	if (p != NULL)
	   if (is_discr (p) && has_expr (p))
	      s_REC_flags (recp, g_REC_flags (recp) | UNCONS_REC);

	FORALL (p, g_ffield (recp)) {
	   if (g_d (p) == XVARIANT)
	      break;
	   off = recfield (p, prevp, recp, &npathflds, &fldoff, off);
	   prevp = p;
	}

	s_fvariant (recp, p);
	if (g_fvariant (recp) == NULL) {
	   s_REC_npaths (recp, g_REC_npaths (recp) + 1);
	   s_REC_maxpfld (recp, max (g_REC_maxpfld (recp), npathflds));
	} else
	   FORALL (p, g_fvariant (recp))
	      off = variant (p, recp, npathflds, fldoff, off);

	if (g_REC_forms (recp) > 0 &&
	    ((g_REC_flags (recp) & CSTREC) == 0 || g_fvariant (recp) != NULL) ) {
	   /*
	    * case 'no discr dep' and 'nform>0' => VARREC
	    * because discriminants must be kept somewhere
	    */
	   s_REC_flags (recp, g_REC_flags (recp) | VARREC);
	}

	/*
	 * On global level ONLY GLOBAL (as far as now)
	 */
	if (curr_level == 0)
	   s_REC_alloc (recp, GLOBAL);	/* force (!) GLOBAL	*/

	/*
	 */
	if (g_REC_alloc (recp) == FIXSTACK)
	   off += sz_tdrec (g_REC_forms (recp), g_REC_nflds (recp),
		        g_REC_ninits (recp), g_REC_flags (recp));

	s_REC_vdsize (recp, sz_vdrec (g_REC_forms (recp), g_REC_maxpfld (recp),
				g_REC_flags (recp) ));

	if (g_REC_flags (recp) & CSTREC) {
	   /*
	    * there are cb filters so compute the offsets
	    * of their future vd counterparts in recp's descriptor space.
	    * In front of that space goes the root vd_rec; since its size
	    * depends on several attributes which are only known after
	    * a first bottom-up pass over the record type, a separate pass
	    * has to be done to compute the offsets.
	    */

	   vdoff = g_REC_vdsize (recp);
	   FORALL (p, g_ffield (recp)) {
	      if (g_d (p) == XVARIANT)
	         break;
	      vdoff = recf_vd (p, vdoff);
	   }

	   if (g_fvariant (recp) == NULL) {
	      s_REC_vdsize (recp, max (g_REC_vdsize (recp), vdoff));
	   } else
	      FORALL (p, g_fvariant (recp))
	         var_vd (p, recp, vdoff);
	}

/*
 *	If the record needs an index table then the
 *	field offsets contain an offset in that table
 *	>>>relative to the descriptor base<<< they
 *	belong to.
 */
	s_REC_vsize (recp, 0);	/* default knowledge	*/

	if (is_arec (recp))
	   s_REC_vsize (recp, getvalsize (recp, NULL));
	else
	if (!is_brec (recp))
	   off += fld_offsets (recp);

	off = align (off, MAX_ALIGN);
	s_REC_offset (recp, off);

	rec_inits (recp);
	return off;
}	/* end of rectype */

/*
 * variant:	VARIANT ranges recfields  opt_variant_sel M ;
 */
static
MAXADDR	variant (varp, recp, npathflds, fldoff, off)
ac	varp;
ac	recp;
int	npathflds;
MAXADDR	fldoff;
MAXADDR	off;
{
	ac	p;
	ac	prevp = NULL;

	ASSERT (varp != NULL && g_d (varp) == XVARIANT, ("variant:0"));

	/*
	 * NOTE: modification of recp's attributes
	 */
	s_VAR_ffld (varp, g_REC_nflds (recp) + 1);
	s_VAR_fpath (varp, g_REC_npaths (recp) + 1);
	s_VAR_fqfld (varp, npathflds + 1);

	FORALL (p, g_varchoice (varp))
	   off = bitrange (p, off);

	FORALL (p, g_ffield (varp)) {
	   if (g_d (p) == XVARIANT)
	      break;
	   off = recfield (p, prevp, recp, &npathflds, &fldoff, off);
	   prevp = p;
	}

	s_fvariant (varp, p);

	if (g_fvariant (varp) == NULL) {
	   s_REC_npaths (recp, g_REC_npaths (recp) + 1);
	   s_REC_maxpfld (recp, max (g_REC_maxpfld (recp), npathflds));
	} else
	{  FORALL (p, g_fvariant (varp))
	      off = variant (p, recp, npathflds, fldoff, off);
	}

	return off;
}	/* end of variant */

static
void	var_vd (varp, recp, vdoff)
ac	varp;
ac	recp;
MAXADDR	vdoff;
{
	ac	p;
	/*
	 * NOTE: modification of recp's attributes
	 */
	FORALL (p, g_ffield (varp)) {
	   if (g_d (p) == XVARIANT)
	      break;

	   vdoff = recf_vd (p, vdoff);
	}

	if (g_fvariant (varp) == NULL)
	   s_REC_vdsize (recp, max (g_REC_vdsize (recp), vdoff));
	else
	{  FORALL (p, g_fvariant (varp))
	      var_vd (p, recp, vdoff);
	}
}	/* end of var_vd */

/*
 *	Look for offsets for local value (subtype) descriptors
 */
static
MAXADDR	recf_vd (fldp, vdoff)
ac	fldp;
MAXADDR	vdoff;
{
	ac	cdp;

	if (g_d (fldp) != XSUBTYPE)
	   return vdoff;

	cdp = g_parenttype (fldp);	/* known to have a filter	*/

	if (g_d (cdp) != XFILTER || (g_FLT_flags (cdp) & CSTREC) != CSTREC)
	   return vdoff;

	vdoff = align (vdoff, MAX_ALIGN);
	s_FLT_vdoffset (cdp, vdoff);

	return vdoff + getvdsize (cdp);
}	/* end of recf_vd */

/*
 *	A record field
 */
static
MAXADDR	recfield (fldp, prevp, recp, npfldp, fldoffp, off)
ac	fldp,
	prevp,
	recp;
int	*npfldp;
MAXADDR *fldoffp,
	off;
{
	MAXADDR	fldoff;
	ac	dp;
	short	flags;

	fldoff = *fldoffp;

	/*
	 * NOTE: modification of recp's attributes
	 */

	ASSERT (g_d (fldp) == XOBJECT ||
                              g_d (fldp) == XSUBTYPE, ("recfield"));

	if (g_d (fldp) == XSUBTYPE) {
	   off = optfilter (g_parenttype (fldp), off);
	   return off;
	}

/*
 *	It's a genuine component, set the allocation class
 *	but wait until the current element is processed,
 *	allocation of the current element depends only
 *	on the preceding components.
 */
	s_OBJ_alloc (fldp, XNOTFILLED);
	dp = g_desc (fldp);
	off = typeref (g_objtype (dp), off);
	flags = getflags (g_objtype (dp));

	/*
	 * Initializing (real) components:
	 * Set flags and make storage class FIXSTACK
	 */
	if (g_expr (dp) != NULL && kind_of (dp) != KDISCR) {
	   s_REC_flags (recp, g_REC_flags (recp) | F_RINIT);
	   s_REC_ninits (recp, g_REC_ninits (recp) + 1);
	   if (curr_level != 0)
	      s_REC_alloc (recp, FIXSTACK);
	}

	if (kind_of (dp) == KDISCR) {
	   /*
	    * discriminant offset in record's value desc.
	    * only depends on number of previous discrs.
	    * undo alignment, it is only
	    * a discriminant, kept in rthe descriptor.
	    */
	   flags &= ~F_ALIGN;
	   s_OBJ_offset (fldp, sz_vdrec (g_REC_forms (recp), 0, 0));
	   s_REC_forms (recp, g_REC_forms (recp) + 1);
	   s_OBJ_alloc (fldp, DISCALLOC);
	} else
	{  if ((g_REC_flags (recp) & (DYNREC | CSTREC)) == 0) {
	      /*
	       * field offsets are static as far as we know;
	       */

	      fldoff = align (fldoff, flags & F_ALIGN);
	      s_OBJ_offset (fldp, fldoff);
	      s_OBJ_alloc (fldp, XNO_TABLE);
	   }
	   s_REC_nflds (recp, g_REC_nflds (recp) + 1);
	   (*npfldp)++;
	}

	s_REC_flags (recp, g_REC_flags (recp) | flags);
	s_REC_alloc (recp, max (g_REC_alloc (recp), getalloc (g_objtype (dp))));

	if ((kind_of (dp) != KDISCR) &&
		((g_REC_flags (recp) & (DYNREC | CSTREC)) == 0))
	   fldoff += sz_val (g_objtype (dp), NULL);

	*fldoffp = fldoff;

	return off;
}	/* end of recfield */

MAXADDR	tasktype (taskp, off)
ac	taskp;
MAXADDR	off;
{
	MAXADDR	paroff;
	/* tasktype descriptor static and constant in size,
	 * size = 6 longs
	 */

	if (curr_level == 0) {
	   s_TSKT_alloc (taskp, GLOBAL);
	   s_TSKT_offset (taskp, new_lab ());
	}
	else
	{  s_TSKT_alloc (taskp, FIXSTACK);
	   off += sz_tdtask ();
	   off = align (off, MAX_ALIGN);
	   s_TSKT_offset (taskp, off);
	}

	s_TSKT_flags (taskp, g_TSKT_flags (taskp) | (F_RINIT | F_TASK));

	return off;
	/* end of tasktype */
}

/*
 * ArrayType:	ARRAYTYPE indices type M ;
 * indices:	index_list  ;
 * index_list:	|
 * 		index_list index ;
 * index:		INDEX M ;
 */
MAXADDR	arrtype (arrp, off)
ac	arrp;
MAXADDR	off;
{
	ac	p,
		tp;

	/*
	 * NOTE:
	 * arrp may point to one of the following arraytypes:
	 *   1.	genuine unconstrained arraytype (as in DAS source)
	 *   2.	anonymous unconstr. arraytype (made by parser
	 *		from constrained one)
	 */

	ASSERT (arrp != NULL && g_d (arrp) == XARRAYTYPE,
					("arrtype %X %d\n", arrp, g_d (arrp)));

	off = typeref  (g_elemtype (arrp), off);
	s_ARR_ndims (arrp, 0);
	s_ARR_flags (arrp, 0);
	s_ARR_alloc (arrp, GLOBAL);
	s_ARR_ndims (arrp, 0);
	/*
	 * nform is 2*ndims for an array type
	 */
	FORALL (p, g_findex (arrp)) {
	   s_ARR_ndims (arrp, g_ARR_ndims (arrp) + 1);
	   off = typeref (g_indextype (p), off);
	   s_ARR_alloc (arrp,
		        max (g_ARR_alloc (arrp), getalloc (g_indextype (p))));
	}

	tp = g_elemtype (arrp);
	s_ARR_flags (arrp, g_ARR_flags (arrp) | getflags (tp));

	if (curr_level == 0) {
	   s_ARR_alloc (arrp, GLOBAL);		/* force global	*/
	   s_ARR_offset (arrp, new_lab ());
	}
	else
	   s_ARR_alloc (arrp, max (g_ARR_alloc (arrp), getalloc (tp)));

	if (g_ARR_alloc (arrp) == FIXSTACK) {
	   off += sz_tdarr (g_ARR_ndims (arrp));
	   off = align (off, MAX_ALIGN);
	   s_ARR_offset (arrp, off);
	}

	s_ARR_vdsize (arrp, sz_vdarr (g_ARR_ndims (arrp)));

	return off;
}	/* end of arrtype */

/*
 * AccType:	ACCTYPE type M ;
 */
MAXADDR	acctype (accp, off)
ac	accp;
MAXADDR	off;
{
	ac	tp;

	s_ACC_nform	(accp, 0);
	s_ACC_alloc	(accp, GLOBAL);
	s_ACC_offset	(accp, new_lab ());
		
	s_ACC_flags	(accp, F_RINIT | ADDR_ALIGN);

	tp = g_actype (accp);
	/*
	 * no typeref should be done here
	 * directly since Ada allows
	 * recursive type dependence when one of the intermediate
	 * types is an access type. The "accessed" type needs
	 * not to be visited before the access type has been
	 * visited, unless it is an access type itself.
	 * Only the (scalar) types of the indices, discriminants,
	 * and the scalar types referenced themselves must be
	 * visited, since their attributes are needed to
	 * determine the alloc attribute of the access type.
	 */
	tp = basefilter (tp);
	if (g_d (tp) == XACCTYPE) {
	      /*
	    * an access type is being accessed
	    * (possibly via a subtype, incompl or priv type).
	    * Start doing typerefs to reach it,
	    * being prepared not to get in infinite recursion
	    * (see notes with typeref).
	    *
	    * Since on recursive type dependence of only
	    * access types, typeref might have set
	    * the current accesstype accp visited,
	    * test it, and do not destroy the attributes
	    * if so.
	    */
	   off = typeref (g_actype (accp), off);
	   if (ISBUSY (accp)) {
	      /* circular through accesstype	*/
	      s_ACC_alloc (accp, GLOBAL);
	      s_ACC_offset (accp, new_lab ());
	      s_ACC_nform (accp, g_ACC_nform (tp));
	   }
	}
	else
	{  off = optbitfilter (g_actype (accp), off);
	   s_ACC_alloc (accp, getbitalloc (tp));
	   if (curr_level == 0) {
	      s_ACC_alloc (accp, GLOBAL);
	      s_ACC_offset (accp, new_lab ());
	   }

	   switch (g_d (tp)) {
		case XFILTER:
		case XINTERNAL:
		case XENUMTYPE:
		case XTASKTYPE:
		case XRECTYPE:
		case XARRAYTYPE:
		case XNEWTYPE:
		case XINCOMPLETE:
		   s_ACC_nform (accp, getnform (tp));
		   break;

		DEFAULT (("acctype %d", g_d (tp) ));
	   }

	   if (g_ACC_nform (accp) == 0) {
	      s_ACC_alloc (accp, GLOBAL);
	      s_ACC_offset (accp, new_lab ());
	   }

	   if (g_ACC_alloc (accp) == FIXSTACK) {
	      off += sz_tdacc (g_ACC_nform (accp));
	      off = align (off, MAX_ALIGN);
	      s_ACC_offset (accp, off);
	   }
/*
 *	Iff the accesstype defines access to a task dependent
 *	type, make the environment a master
 */
	   if (getflags (tp) & F_TASK)
	      off = current_env_to_master (accp, off);
	}

	return off;
}	/* end of acctype */

/*
 * Filter
*/
MAXADDR	filter (ftp, off)
ac	ftp;
MAXADDR	off;
{
	ac	p,
		btp,
		cp;

	ASSERT (ftp != NULL && g_d (ftp) == XFILTER, ("filter"));

	off = typeref (g_filtype (ftp), off);
	s_FLT_flags (ftp, (getflags (g_filtype (ftp)) & ~(CSTREC | VARREC)));

	/* of kind only DYNREC passes from typedef to filter */
	s_FLT_alloc (ftp, getalloc (g_filtype (ftp)));
	btp = root_type (g_filtype (ftp));

	cp = g_constraint (ftp);
	switch (g_d (cp)) {
	   case XINDEXCONS:
	      FORALL (p, g_frange (cp)) {
	         off = bitrange (p, off);
	         s_FLT_flags (ftp, g_FLT_flags (ftp) | getrgflags (p));
	         s_FLT_alloc (ftp, max (g_FLT_alloc (ftp), getrgalloc (p)));
	      }
	      break;

	   case XDISCRCONS:
	      FORALL (p, g_aggregate (cp)) {
	         s_FLT_flags (ftp, g_FLT_flags (ftp) |
                                   getexpflags (g_compexpr (p)));
	         s_FLT_alloc (ftp, max (g_FLT_alloc (ftp), 
                                        getexpalloc (g_compexpr (p))));
	      }
	      break;

	   case XRANGE:
	      off = bitrange (cp, off);
	      s_FLT_alloc (ftp, max (g_FLT_alloc (ftp), getrgalloc (cp)));
	      break;

	   DEFAULT (("filter: %d", g_d (cp) ));
	}

	if (g_d (btp) == XACCTYPE) {
	   s_FLT_flags (ftp, g_FLT_flags (ftp) & ~DYNREC);
	   /*
	    * because DYNREC does not show that there are
	    * non-static values in the (sub)type definition
	    * but that the size of objects of the (sub)type
	    * is static,
	    * and access variables are just pointers,
	    * filters to access types are forced to be static.
	    * CSTREC indicates that there will be a discriminant
	    * dependent filter for the accesstype.
	    * VARREC cannot hold here.
	    *
	    * Note that a filter ON an access type (as is the case here),
	    * can only be an index or discriminant constraint.
	    */
	}

	if (curr_level == 0) {
	   s_FLT_alloc (ftp, GLOBAL);
	}

	if (g_FLT_alloc (ftp) == GLOBAL)
	   s_FLT_offset (ftp, new_lab ());
	else
	if (g_FLT_alloc (ftp) == FIXSTACK) {
	   if (g_FLT_flags (ftp) & CSTREC) {
	      off += sz_cb (g_d (btp) == XRECTYPE ?
                            g_REC_forms (btp)
	                    : g_d (btp) == XARRAYTYPE
	                    ? (2 * g_ARR_ndims (btp))
	                    : g_ACC_nform (btp));
	   }
	   else
	         off += getvdsize (ftp);

	   off = align (off, MAX_ALIGN);
	   s_FLT_offset (ftp, off);
	}

	if ((g_FLT_flags (ftp) & (DYNREC | CSTREC)) == 0) {
	/*
	 * the size of a value is staticly determinable;
	 * compute it.
	 */
	   s_FLT_valsize (ftp, getvalsize (ftp, NULL));
	}

	return off;
}	/* end of filter */

/*
 * subprogram:	SUB locals type M ;
 */
MAXADDR	subprogram (subp, off)
ac	subp;
MAXADDR	off;
{
	ac	p;
	MAXADDR paroff;
/*
 *	for routines on level 1, i.e. surrounded by
 *	level 0, we do not need a static link !
 */
	if (curr_level == 0) {
	   paroff = PARBASE - TADDRSIZE;
	   s_SUBS_alloc (subp, GLOBAL);
	}
	else
	{  paroff = PARBASE;
	   s_SUBS_alloc (subp, FIXSTACK);
	   off += TADDRSIZE;
	   s_SUBS_offset (subp, (off = align (off, ADDR_ALIGN)));
	}

	off = formals (g_fformal (subp), &paroff, off, NOTASK);
	/*
	 * if a formal parameter is unconstrained composite,
	 * allocate a pointer in parstack to the descriptor
	 * of the actual.
	 * The object node contains the offset.
	 */
	FORALL (p, g_fformal (subp)) {
	   if (is_ncomp (g_objtype (g_desc (p)))) {
	      /*
	       * address descriptor of the actual on the parstack
	       */
	      paroff = align (paroff, MAX_ALIGN);
	      s_OBJ_descoff (p, paroff);
	      paroff += TADDRSIZE;
	   }
	}

	/*
	 * if the return value is unconstrained composite, then
	 * allocate a pointer on the parstack to the descriptor space.
	 */
	if (is_ncomp (g_rettype (subp))) {
	   paroff = align (paroff, MAX_ALIGN);
	   s_SUBS_retoff (subp, paroff);
	   paroff += TADDRSIZE;
	}

	return off;
}	/* end of subprogram */

/*
 *	proces the formals
 */
static
MAXADDR	formals (forms, paroffp, off, env)
ac	forms;
MAXADDR *paroffp,
	off;
int	env;
{
	MAXADDR	paroff;
	ac	p,
		prevp,
		partype;

	paroff = *paroffp;
	/*
	 * Compute offset of parameters in parameter stack
	 * Assume that the formals are in the right order.
	 */
	FORALL (p, forms) {
	   partype = root_type (g_objtype (g_desc (p)));
	   s_OBJ_alloc (p, env == NOTASK ? PARSTACK : ENTRYSTACK);
	   paroff = align (paroff, MAX_ALIGN);
	   s_OBJ_offset (p,
	            paroff + paramoffset (pcc_type_of (partype), PARSTACK));
	   paroff += parameter_size (partype);
	   prevp = p;
	}

	*paroffp = paroff;

	return off;
}	/* end of formals */

/*
 *	do a block
 */
MAXADDR	block (x, off)
ac	x;
MAXADDR	off;
{
	off = incr_off (align (off, ADDR_ALIGN), TADDRSIZE);
	s_BLK_SToff (x, off);

	return off;
}

/*
 * RenamedSub:	RENSUB locals type M ;
 */
MAXADDR	rensub (rensubp, off)
ac	rensubp;
MAXADDR	off;
{
	MAXADDR	paroff = 0;

	off = formals (g_fformal (rensubp), &paroff, off, NOTASK);

	return off;
}	/* end of rensub */

static
MAXADDR	fld_offsets (recp)
ac	recp;
{
	if (is_erec (recp) || is_frec (recp))
	   return offtable (recp, sz_tdrec (g_REC_forms (recp),
					    g_REC_nflds (recp),
					    g_REC_ninits (recp), 0));
	else
	{  offtable (recp, sz_vdrec (g_REC_forms (recp), 0, 0));
	   return 0;
	}
}

/*
 *	Important notice: This routine assumes that the
 *	record type for which the offset table has to be
 *	created needs one, i.e. not of AREC or BREC.
 */
static
MAXADDR	offtable (recp, off)
ac	recp;
MAXADDR	off;
{
	ac	fldp;
	MAXADDR	old_off = off;
	int	dummy;

	ASSERT (!is_arec (recp) && !is_brec (recp), ("offtable"));

	FORALL (fldp, g_ffield (recp)) {
	   if (g_d (fldp) == XVARIANT) 
	      break;

	   if (g_d (fldp) == XSUBTYPE)
	      continue;

	   if (is_discr (fldp))
	      continue;

	   off = align (off, MAX_ALIGN);
	   if (g_OBJ_alloc (fldp) == XNOTFILLED) {
	      s_OBJ_alloc (fldp, (is_frec (recp)) ? XTYPE_TABLE : XSUB_TABLE);
	      s_OBJ_offset (fldp, off);
	   }

	   off += TADDRSIZE;
	}

	FORALL (fldp, g_fvariant (recp))
	   if (is_frec (recp))
	     off += offtable (fldp, off);
	   else
	     dummy = offtable (fldp, off);

	return off - old_off;
}

/*
 *	Compute initialization requirements
 *	for record components
 */
static
void	rec_inits (recp)
ac	recp;
{
	ac	fldp,
		f2;

	FORALL (fldp, g_ffield (recp))
	   if (g_d (fldp) == XVARIANT)
	      rec_inits (fldp);
	   else
	   if (g_d (fldp) == XSUBTYPE)
	      continue;
	   else
	   if (is_discr (fldp))
	      continue;
	   else
	   if (has_init (fldp)) {
	      make_in_sub (g_expr (g_desc (fldp)));
	      f2 = fldp;
	      while (g_next (f2) != NULL &&
		       g_d (g_next (f2)) == XOBJECT &&
		          g_desc (g_next (f2)) == g_desc (fldp) )
	         f2 = g_next (f2);

	      fldp = f2;
	      continue;
	   }

}

