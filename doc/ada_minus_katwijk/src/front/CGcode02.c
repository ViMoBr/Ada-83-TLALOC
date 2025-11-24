
/*
 * (c) copyright 1986, 1987, 1988, Delft University of Technology
 * Delft, The Netherlands
 *
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
 *
 * 	Code is generated in two walks. The first one (possible empty)
 *	generates code resulting from pre_computing nodes,
 *	the second walk generates the normal code.
 */

#include	"includes.h"


/*
 * Name:	pre_code  (node)
 *		nam_pre_code  (node)
 *		call_pre_code (node)
 *		agg_pre_code (node)
 *
 * Abstract:	walks the subtree with root 'node' to generate
 *		code for constructs that need pre_computation.
 *
 * Description:	
 *
 * 	    1.  If a function returns big results it moves the stackpointer.
 * 		This means that it cannot be evaluated nested within another
 * 		function call (It would interfere with parameter passing),
 * 		or, in EM-code, in a pcc construct.
 * 		To overcome this problem, code is generated in two steps:
 * 		--	pre_code
 * 		--	code 
 *
 * 		Wether something is big is determined in the storage
 *		allocation compution.
 * 		If it is, it has a temp. (Voff)
 *
 *	    2.  Aggregates need precomputation, i.e. the value will be
 *		precomputed before actual code will be generated.
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
void	pre_code (node)
ac	node;
{
	ac	pr;

	if (node == NULL)
	   return;

	switch (g_d (node)) {
	   case XFILTER:
		pre_code (g_constraint (node));
		return;

	   case XRANGE:
		FORALL (node, g_frang_exp (node))
		    pre_code (node);
		return;

	   case XINDEXCONS:
		FORALL (node, g_farg (node)) {
		    pre_code (node);
		}
		return;

	   case XDISCRCONS:
		FORALL (node, g_aggregate (node)) {
		    pre_code (g_compexpr (node));
		}
		return;

	   case XALLOCATOR:
		pre_code (g_obtype (node));
		return;

	   case XEXP:
		if (g_d (g_primary (node)) == XAGGREGATE) {
		   agg_pre_code (g_primary (node), g_exptype (node));
		}
		else
		   pre_code (g_primary (node));
		return;

	   case XSCC:
		scc_pre_code (node);
		return;

	   case XOBJECT:
	   case XRENOBJ:
	   case XENUMLIT:
	   case XCHARLIT:
	   case XLITERAL:
		return;

	   case XNAME:
	   case XALL:
	   case XCALL:
	   case XENTRYCALL:
	   case XSLICE:
	   case XSELECT:
	   case XINDEXING:
	   case XATTRIBUTE:
		nam_pre_code (node);
		return;

	   case XNAMEDASS:
		pre_code (g_nexp (node));
		return;

	   case XIN:
		pre_code (g_inexpr (node));
		pre_code (g_intype (node));
		return;

	   default:
		return;
	}
}

void	nam_pre_code (node)
ac	node;
{
	ac	ass;

	if (node == NULL)
	   return;

	switch (g_d (node)) {
	   case XCALL:
		nam_pre_code (g_next (node));
		FORALL (ass, g_fact (node))
		   pre_code (ass);
		call_pre_code (node);
		return;

	   case XENTRYCALL:
		nam_pre_code (g_next (node));
		FORALL (ass, g_fact (node))
		   pre_code (ass);
		return;

	   case XINDEXING:
		nam_pre_code (g_next (node));
		FORALL (ass, g_farg (node))
		   pre_code (ass);
		break;

	   case XSELECT:
		nam_pre_code (g_next (node));
		break;

	   case XSLICE:
		nam_pre_code (g_next (node));
		pre_code (g_slrange (node));
		break;

	   case XATTRIBUTE:
		nam_pre_code (g_next (node));
		pre_code (g_entity (node));
		break;

	   case XALL:
		nam_pre_code (g_next (node));
		break;

	   case XNAME:
		break;

	   DEFAULT (("nam_pre_code: %d", g_d (node)));
	}
}

void	call_pre_code (node)
ac	node;
{
	int	type;

	if (node == NULL)
	   return;

	ASSERT (g_d (node) == XCALL, ("call_pre_code"));

	type = pcc_type_of (node);

	if (is_computed (node))
	   return;

	if (has_Voff (node)) {
	   COMMA ();
	      ASSIGN (type);
		 LOC_OBJECT (curr_level, Voff (node), type);
		 code (node, VAL, type);
	   set_computed (node);
	}
}

void	scc_pre_code (node)
ac	node;
{
	int	ctype;

	if (node == NULL)
	   return;

	ASSERT (g_d (node) == XSCC, ("scc_pre_code:1"));

	ctype = pcc_type_of (node);

	if (is_computed (node))
	   return;

	pre_code (g_fsccexpr (node));
	pre_code (g_next (g_fsccexpr (node)));

	if (has_Voff (node)) {
	   COMMA ();
	      ASSIGN (ctype);
		 LOC_OBJECT (curr_level, Voff (node), ctype);
		 if (is_small (g_fsccexpr (node))) {
		    if (g_andthen (node))
			ANDAND (ctype);
		    else
			OROR (ctype);
			
			code (g_fsccexpr (node), VAL, ctype);
			code (g_next (g_fsccexpr (node)), VAL, ctype);
		 }
		 else
	         {   CALL (UCHAR);
			ICON (0, PF_UCHAR, __SCCCOMP);
			PARCOM ();
		           PARCOM ();
			      PARCOM ();
				 PARCOM ();
				    code (g_fsccexpr (node), VAL, ctype);
				    code (g_next (g_fsccexpr (node)), VAL, ctype);
				 DESCRIPTOR (g_fsccexpr (node));
			      DESCRIPTOR (g_next (g_fsccexpr (node)));
			   ICON (g_andthen (node) ? SCC_AND : SCC_OR, LONG, "");
		 }
		 set_computed (node);
	}
}

/*
 * Name:	agg_pre_code
 *
 * Abstract:	
 *
 * Description:	agg_pre_code generates code for aggegrate constructs.
 *		simple static aggregates are constructed in the storage
 *		allocation walk, resulting in a GLOBAL table addressable
 *		via AGG_tablab.
 *		For non-table aggregates, a artificial subroutine is
 *		created that constucts the aggregate value. This routine
 *		can be called using AGG_tablab again, it now contains
 *		the entry point to the subroutine.
 *		Before we can use the value, it's descriptor (if not
 *		allready present) must be created.
 *		This will be done in the artificial subroutine itself
 *		before any other actions will be performed.
 *		So here we only have to call the artificial routine
 *		itself.
 *
 * Externals:	
 *
 * Calls:	
 *
 *
 */
void	agg_pre_code (agg, etype)
ac	agg;
ac	etype;
{
	if (agg == NULL)
	   return;

	ASSERT (g_d (agg) == XAGGREGATE, ("agg_pre_code:1"));

	if (is_computed (agg))
	   return;

	if (g_AGG_Voff (agg) != 0) {
	   /* we have a non-table aggregate */
	   /* make it by calling the assigning routine */
	   /* concerning the type, keep it simple,
	    * assume that the return type of the call is
	    * a pointer to a 4 byte location, (ADDRESS)
	    */

	   COMMA ();
	      ASSIGN (ADDRESS);
	         LOC_OBJECT (curr_level, g_AGG_Voff (agg), ADDRESS);
		 CALL (ADDRESS);
		    LICON (g_AGG_tablab (agg));
		    PARCOM ();
		       get_stlink (0, ADDRESS);

		       if (g_AGG_Doff (agg) == 0) {
		          if (g_d (g_aggtype (agg)) == XSUBTYPE ?
			        (has_call_block (g_aggtype (agg))) 
			      : (has_call_block (etype))) {
			     if (g_code_context  == INIT_SUB)
			       	 PAR_OBJECT (curr_level, PAR_1, P_LONG);
			     else
			 /* unconstraint aggregate, use the left side context */
			        DESCRIPTOR (g_context (agg));
			    
			  }
			  else
			/* contraint aggregate, use the expression context */
			     DESCRIPTOR (etype);
		       }
		       else
			  LOC_NAME (curr_level, g_AGG_Doff (agg), P_LONG);


		set_computed (agg);
	}
}

/*
 * Name:	code (node)
 *
 * Abstract:	generates code
 *
 * Description:	"code ()" dispatches its actions to functions
 *		named "..._code" whenever possible.
 *		
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
void	code (node, val, ctype)
ac 	node;
int	val;
int	ctype;
{
	int	type;

	if (node == NULL)
	   return;

	type = pcc_type_of (node);
	if (ctype == NOTYPE)
	   ctype = type;

	switch (g_d (node)) {
	   case XACCTYPE:
	   case XARRAYTYPE:
	   case XTASKTYPE:
	   case XSUBBODY:
	   case XTASKBODY:
	   case XENUMTYPE:
	   case XSUBTYPE:
	   case XRECTYPE:
	   case XFILTER:
		desc_const (node);	/* happens some times */
		return;

	   case XPARENTHS:
		code (g_subexpr (node), val, ctype);
		return;

	   case XTYPECONV:
		tconv_code (node,VAL, ctype);
		return;

	   case XLITERAL:
		lit_code (node,val, ctype);
		return;

	   case XENUMLIT:
	   case XCHARLIT:
		if (type != ctype) {
		   SCONV (ctype);
		}
		ICON (ord (node), type, "");
		return;

	   case XEXP:
		exp_code (node, val, ctype);
		return;

	   case XSCC:
		if (g_SCC_Voff (node) != 0) {
		   ASSERT (is_computed (node),("code: scc"));
		   LOC_OBJECT (curr_level, Voff (node), UCHAR);
		}
		else
		   scc_code (node, val, ctype);
		return;

	   case XIN:
		in_code (node, val, ctype);
		return;

	   case XNAME:
	   case XALL:
	   case XCALL:
	   case XENTRYCALL:
	   case XSLICE:
	   case XSELECT:
	   case XINDEXING:
	   case XATTRIBUTE:
		nelemcode (node, val, ctype);
		return;

	   case XAGGREGATE:
		/* concerning the type:
		 * assume the aggregate is processed in a "pointer to long
		 * environment, i.e. ADDRESS
		 */
		if (g_AGG_Voff (node) != 0) {
		   ASSERT (is_computed (node),("code :aggregate"));
		   LOC_OBJECT (curr_level, g_AGG_Voff (node), ADDRESS);
		}
		else
		   LICON (g_AGG_tablab (node));
		return;

	   case XALLOCATOR:
		allo_code (node, val, ctype);
		return;

	   case XSUB:
		ASSERT (val == VAL, ("code"));
		switch (stor_class (node)) {
		   case GLOBAL:
			GLOB_OBJECT (0, node , ADDRESS);
			break;

		   case FIXSTACK:
			LOC_OBJECT (level_of (node), off (node), type);
			break;

		   DEFAULT (("code: XSUB %s: stor_class=%d", g_tag (node), stor_class (node)));
		}
		return;

	   case XEXCEPTION:
		GLOB_NAME (0, node);
		return;

	   case XRENOBJ:
		switch (stor_class (node)) {
		   case NOALLOC:
			code (g_name (node), val, ctype);
			return;

		   case FIXSTACK:
			pcc_deref (node, val);
			LOC_OBJECT (level_of (node), off (node), type);
			return;

		   case GLOBAL:
			pcc_deref (node, val);
			GLOB_OBJECT (0, node, type);
			return;

		   DEFAULT (("code RENOBJ: stor_class", stor_class (node)));
		}

	   case XOBJECT:
		obj_code (node, val, ctype);
		return;

	   DEFAULT (("code: %d", g_d (node)));
	}
}


