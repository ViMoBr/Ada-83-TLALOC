
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
 *	Julianalaan 132 Delft The Netherlands.
 *
 * Design Decisions :
 *		"nele_code" is used by "code" to generate code for
 *		name constructs like:
 *			funny (x) (a .. b) (c)
 *		where:
 *			funny (x) is a function call returning an array
 *			(a .. b) is a slice of this array
 *			(c) is an index in the slice.
 *
 *		"ncode" reverses the links between the operations,
 *		and walks to the end of the list, calls "nelemcode" for
 *		the last operation.
 */

#include	"includes.h"
/*
 *	Forward (static) declarations
 */
static	void	do_all		();
static	void	do_attr		();
static	void	do_slice	();
static	void	do_select	();
static	void	do_indexing	();
static	void	do_call		();
static	void	do_entry_call	();
static	int	do_entry_params	();


#define	low_expr(x)	rang_expr (x, 1)
#define	high_expr(x)	rang_expr (x, 2)

#define		MONADIC 	0
#define		DYADIC		1

/*
 * Name:	nelemcode
 *
 * Abstract:	generate code for an operation
 *
 * Description:	see design decisions
 *
 * Externals:	
 *
 * Calls:	do_...
 *
 * Macros:	
 *
 */

void	nelemcode (x, val, ctype)
ac	x;
int	val;
int	ctype;
{
	if (x == NULL)
	   return;

	switch (g_d (x)) {
	   case XALL:
		do_all (x, val, ctype);
		break;

	   case XATTRIBUTE:
		do_attr (x, val, ctype);
		break;

	   case XCALL:
		do_call (x, val, ctype);
		break;

	   case XENTRYCALL:
		do_entry_call (x, val, ctype);
		s_flags (x, g_flags (x) | LARG_EVAL);
		break;

	   case XSLICE:
		do_slice (x, val, ctype);
		break;

	   case XSELECT:
		do_select (x, val, ctype);
		break;

	   case XINDEXING:
		do_indexing (x, val, ctype);
		break;

	   case XNAME:
		code (g_fentity (x), val, ctype);
		break;
	}
}

/*
 * Name:	do_all
 *
 * Abstract:	generate code for the all operation
 *
 * Description:
 *		There might be a problem with the ALL,
 *		If we have to access the descriptor before
 *		we actually computed the value, there
 *		is a problem. The way it is handled is easy,
 *		We mark the ALL node in the flags field
 *		if it has been computed already,
 *		Either nelemcode or DESCRIPTOR starts the
 *		evaluation of the left operand of ALL
 *
 *		do_all : several cases:
 *
 *		- the PASCAL case, the address of the value is the result
 *		  of the evaluation of the left hand side, plain and simple
 *		- tough case: the left part returns the address of the doublet
 *		  in which the value is hidden
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
void	do_all (x, val, ctype)
ac	x;
int	val;
int	ctype;
{
	int	type;

	if (x == NULL)
	   return;

	ASSERT (g_d (x) == XALL, ("do_all"));

	type = pcc_type_of (g_types (x));
	if (is_small (g_types (x))) {
	   if (type != ctype) {
	      SCONV (ctype);
	      ctype = type;
	   }
	   DEREF (type);
	}

	if (!unco_value (g_types (x)))		/* PASCAL case	*/
	   nelemcode (g_next (x), VAL, ctype);
	else
	{  PLUS (pointer_type_of (type));	/* now THROUGH the real doublet */

	  if (not_yet_processed (x) && has_Doff (x)) {
	     COMMA ();
	        ASSIGN (P_LONG);
	           LOC_OBJECT (curr_level, Doff (x), P_LONG);
	           nelemcode (g_next (x), VAL, ctype);
	  }
	  if (has_Doff (x))
	     LOC_OBJECT (curr_level, Doff (x), pointer_type_of (type));
	  else
	     nelemcode (g_next (x), VAL, ctype);

	  ICON (TADDRSIZE, LONG, "");
	}

	set_yet_processed (x);
}

/*
 * Name:	do_attr
 *
 * Abstract:	does the attributes
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
void	do_attr (x, val, ctype)
ac	x;
int	val;
int	ctype;
{
	int	index, off;
	ac	type;
	ac	next;
	int	pcc_type;
	if (x == NULL)
	   return;

	ASSERT (x != NULL && g_d (x) == XATTRIBUTE, ("do_attr:1"));

	next = g_next (x);
	type = get_type (next);

	switch (g_attr_value (x)) {
	   case A_CALLABLE:
		SCONV (INT);
		CALL (LONG);
		   ICON (0, PF_INT, "_Callable");
		   DEREF (ADDRESS);
		   code (next, VAL, ADDRESS);
		return;

	   case A_TERMINATED:
		SCONV (INT);
		CALL (LONG);
		   ICON (0, PF_INT, "_Terminated");
		   DEREF (ADDRESS);
		   code (next, VAL, ADDRESS);
		return;

	   case A_COUNT:
		CALL (LONG);
		   ICON (0, PF_INT, "_Count");
		   PARCOM ();
		      ICON (g_entry_nr (g_entity (next)), LONG, "");
		      DEREF (ADDRESS);
		      	code (g_next (next), VAL, ADDRESS);
			
		return;

	   case A_IMAGE:
		CALL (ADDRESS);
		   ICON (0, PF_INT, "__Image");
		   PARCOM ();
		      PARCOM ();
			 if (is_scalar (type))
			    code (g_entity (x), VAL, LONG);
			 else
		            code (g_entity (x), VAL, pcc_type_of (type));
			 DESCRIPTOR (root_type (type));
		      LOC_NAME (curr_level, g_ATTR_Doff (x), P_LONG);
		return;

	   case A_VALUE:
		CALL (LONG);
		   ICON (0, PF_INT, "__Value");
		   PARCOM ();
		      PARCOM ();
		         PARCOM ();
			    DESCRIPTOR (get_type (next));
		            DESCRIPTOR (root_type (get_type (next)));
		         code (g_entity (x), REF, ADDRESS);
		      DESCRIPTOR (g_entity (x));
		return;

	   case A_STORAGE_SIZE:
		CALL (LONG);
		   ICON (0, PF_INT, "_Stosize");
		   code (next, REF, ADDRESS);
		return;

	   case A_WIDTH:
		CALL (LONG);
		   ICON (0, PF_INT, "__Width");
		   PARCOM ();
		      DESCRIPTOR (get_type (next));
		      DESCRIPTOR (root_type (get_type (next)));
		return;

	   case A_POS:
		if (ctype != pcc_type_of (g_types (x)))
		   SCONV (ctype);
		SCONV (pcc_type_of (g_types (x)));
		/* fall through ! */
	   case A_VAL:
		code (g_entity (x), val, ctype);
		return;

	   case A_ADDRESS:
		nelemcode (g_next (x), REF, ctype);
		return;

	   case A_SIZE:
		if (ctype != LONG)
		   SCONV (ctype);

		DEREF (LONG);
		   PLUS (P_LONG);
			elemdesc (g_next (x), VAL);
			if (is_small (g_types (g_next (x))))
		           ICON (LD_BIT_BITIND, LONG, "");
			else
		           ICON (VD_SIZE, LONG, "");

		return;

	   case A_PRED:
	   case A_SUCC:
		if (ctype != pcc_type_of (g_types (x))) {
			SCONV (ctype);
			ctype = pcc_type_of (g_types (x));
		}
		CALL (pcc_type_of (g_types (x)));
		   ICON (0, PF_INT, __SCAL_CHECK);
		   PARCOM ();
		      elemdesc (x, VAL);
		      SCONV (LONG);
		      if (g_attr_value (x) == A_SUCC) {
			 PLUS (pcc_type_of (g_types (x)));
		      }
		      else
		         MINUS (pcc_type_of (g_types (x)));

		            code (g_entity (x), VAL, pcc_type_of (g_types (x)));
			    ICON (1, LONG, "");
		return;

	   case A_FIRST:
	   case A_LAST:
		if (is_small (g_types (g_next (x)))) {
		   /* easy, just on scalars */
		   if (ctype != pcc_type_of (g_types (x))) {
			SCONV (ctype);
			ctype = pcc_type_of (g_types (x));
		   }
		   DEREF (LONG);
		      PLUS (P_LONG);
			 elemdesc (g_next (x), VAL);
			 ICON (g_attr_value (x) == A_FIRST ?
			         LD_BIT_LO : LD_BIT_HI, LONG, "");
		}
		else
		{  if (g_d (g_next (x)) != XNAME) {
		      /* something to compute	*/
		      COMMA ();
		         nelemcode (g_next (x), val, ctype);
		   }
		   if (ctype != LONG) {
		      SCONV (ctype);
		      ctype = LONG;
		   }
		   DEREF (LONG);
	              PLUS (P_LONG);
		         elemdesc (g_next (x), VAL);
		         index = getvalue (g_entity (x));
	                 off = LD_ARR_I_X + (index - 1) * I_X_LD_ARR_SIZE;
		         ICON ((g_attr_value (x) == A_FIRST ?
				      off : off + TLONGSIZE), LONG, "");
		}
		return;

	   case A_LENGTH:
		/* both for scalar types and array subtypes
		 * the same structure, high - low + 1
		 * What's different is the offset in the
		 * descriptor
		 */
		pcc_type = pcc_type_of (g_types (x));
		if (g_d (g_next (x)) != XNAME) {	/* for side effects	*/
		   COMMA ();
		      nelemcode (g_next (x), val, ctype);
		}
		if (ctype != pcc_type) {
		   SCONV (ctype);
		   ctype = pcc_type;
		}
		PLUS (pcc_type);
		   ICON (1, pcc_type, "");
		   MINUS (pcc_type);
		   if (pcc_type != LONG) {
		      ctype = LONG;
		      SCONV (pcc_type);
		   }
		   DEREF (LONG);
		    PLUS (P_LONG);
		     elemdesc (g_next (x), VAL);
		      if (is_small (g_types (g_next (x))))
		         ICON (LD_BIT_HI, LONG, "");
		      else
		         ICON (LD_ARR_I_X + (getvalue (g_entity (x)) - 1) *
				   I_X_LD_ARR_SIZE + TLONGSIZE , LONG, "");
		   if (pcc_type != LONG) {
		      ctype = LONG;
		      SCONV (pcc_type);
		   }
		   DEREF (LONG);
		    PLUS (P_LONG);
		     elemdesc (g_next (x), VAL);
		     if (is_small (g_types (g_next (x))))
		        ICON (LD_BIT_LO, LONG, "");
		     else
		        ICON (LD_ARR_I_X + (getvalue (g_entity (x)) - 1) *
				                I_X_LD_ARR_SIZE, LONG, "");
		return;

	DEFAULT (("do_attr: attribute=%d", g_attr_value (x) ));
	}
}


/*
 * Name:	do_slice
 *
 * Abstract:	
 *
 * Description:	
 *		do_slice:
 *		simple case, just let a runtime routine do the work
 *
 *		As a side effect the target descriptor
 *		is initialized
 *
 *		Be sure that the descriptor of the construct
 *		to be sliced IS available, note that the
 *		actual order in which the parameters
 *		of the function slice
 *		are elaborated are in reversed order, somewhat annoying
 *		since now we have to make sure on beforehand that
 *		the descriptor is addressable.
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
void	do_slice (op, val, ctype)
ac	op;
int	val;
int	ctype;
{
	mak_addressable (g_next (op));	/* he generates COMMA	*/

	CALL (ADDRESS);
	   ICON (0, PF_ADDR, __SLICE);
	   PARCOM ();
	      PARCOM ();
	         PARCOM ();
	            PARCOM ();
		       nelemcode (g_next (op), REF, pointer_type_of (ctype));
		       elemdesc (g_next (op), VAL);
		    LOC_NAME (curr_level, g_SLI_Doff (op), P_LONG);
		 SCONV (LONG);
		 low_expr (g_slrange (op));
	      SCONV (LONG);
	      high_expr (g_slrange (op));
}

/*
 * Name:	do_select
 *
 * Abstract:	
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
void	do_select (op, val, ctype)
ac	op;
int	val;
int	ctype;
{
	ac	node;
	ac	nodetype;
	ac	t;
	int	type;
	int	res_type;

	ASSERT (op != NULL && g_next (op) != NULL, ("do_select:1"));

	node = g_next (op);	/* the record to be selkected */
	nodetype = root_type (g_types (node));

	type = pcc_type_of (g_types (op));

	if (is_small (g_types (op)) && val == VAL) {
	   if (ctype != type) {
	      SCONV (ctype);
	      ctype = type;
	   }
	   DEREF (is_discr (g_entity (op)) ? LONG : type);
	}
	/*
	 * A special case arises if we do a select on a discimimant
	 * In that case we are not really interested in the left
	 * context value but merely in the left context descriptor.
	 * So treat it special:
	 *
	 */
	if (is_discr (g_entity (op))) {
	    COMMA ();
	       nelemcode (node, REF, pcc_type_of (g_types (node)));
	       PLUS (P_LONG);
		  elemdesc (node, VAL);
	          ICON (TADDRSIZE * disc_num (g_entity (op)) +
					      LD_RECDISCR, LONG, "");
	    return;
	}

	/* first code for the left context, with a prefixed ADD */

	if (is_small (g_types (op)) && val == VAL)
	   res_type = pointer_type_of (type);
	else
	   res_type = ADDRESS;
	ctype = res_type;
	PLUS (res_type);
	   nelemcode (node, REF,ctype);

	if (is_varrec (nodetype))
	  if (need_check (g_types (node), g_entity (op))) {
	     /*
	      * fpath <= path && path <= nextpath
	      *
	      * the code we generate for an verified select is
	      * !in_the_path ? exception : accesscode
	      */
	      QUEST (res_type);
	         NOT (LONG);
	         if (low_path (g_entity (op)) == high_path (g_entity (op))) {
	            /* simple code */
		    EQ (LONG);
		      ICON (low_path (g_entity (op)), LONG, "");
		      DEREF (LONG);
		         PLUS (P_LONG);
			    elemdesc (node, VAL);
		            ICON (LD_REC_PATH, LONG, "");
	         }
	         else
	         {  ANDAND (LONG);
		       LE (LONG);
			  ICON (low_path (g_entity (op)), LONG, "");
		       DEREF (LONG);
			  PLUS (P_LONG);
			     elemdesc (node, VAL);
			     ICON (LD_REC_PATH, LONG, "");
		       LE (LONG);
			  DEREF (LONG);
			     PLUS (P_LONG);
			        elemdesc (node, VAL);
			        ICON (LD_REC_PATH, LONG, "");
			  ICON (high_path (g_entity (op)), LONG, "");
	         }

	         COLON (res_type);	/* then clause: */
	            CALL (res_type);
		       ICON (0, PF_ADDR, __CRAISE);
		       ICON (0, ADDRESS, EXC_CONSTRAINT);
	 }

	/*
	 * in case of an offset table attached to the
	 * basetype descriptor, we do need here the
	 * basetype, otherwise the subtype.
	 */

	if (g_OBJ_alloc (g_entity (op)) == XNO_TABLE)
	   ICON (g_OBJ_offset (g_entity (op)), LONG, "");
	else
	{  DEREF (LONG);
	      PLUS (P_LONG);
	         if (g_OBJ_alloc (g_entity (op)) == XTYPE_TABLE)
	            DESCRIPTOR (nodetype);
	         else
	            elemdesc (node, VAL);

	         ICON (g_OBJ_offset (g_entity (op)), LONG, "");
	}
}

/*
 * Name:	do_indexing
 *
 * Abstract:	
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
static
void	do_indexing (op, val, ctype)
ac	op;
int	val;
int	ctype;
{
	int	s;
	ac	node;
	int	dims;
	int	i;
	int	type;
	int	res_type;

	ASSERT (op != NULL, ("do_indexing:1"));

	node = g_next (op);
 	ASSERT (node != NULL && g_types (node) != NULL, ("do_indexing:2"));
	ASSERT (g_d (root_type (g_types (node))) == XARRAYTYPE, ("do_indexing:3"));

	dims = g_ARR_ndims (root_type (g_types (node)));
	type = pcc_type_of (g_types (op));

	if (ctype != type)
	   SCONV (ctype);

	if (is_small (g_types (op)) && val == VAL) {
	   DEREF (type);
	   res_type = pointer_type_of (type);
	}
	else
	   res_type = ADDRESS;

	PLUS (res_type);
	   nelemcode (node, REF, res_type);  /* left operand */

	/* if dims == 1 we code the access function inline if
	 * no run-time check has to be performed
	 */

	if (dims == 1 &&
/*
	     no_indexcheck (g_farg (op), g_types (g_next (op))) ) {
 *		Since there is a bug in the ACE codegenerator:
 */
	   TRUE) {
	   MUL (LONG);
	   if ((s = obj_size (g_types (op))) != 0) {
	      ICON (s, LONG, "");
	   }
	   else
	   {  DEREF (LONG);
	         PLUS (P_LONG);
		    elemdesc (op, VAL);
	            ICON (VD_SIZE, LONG, "");
	   }
	      MINUS (LONG);
	        code (g_farg (op), VAL, LONG);
	        DEREF (LONG);
	            PLUS (P_LONG);
		       elemdesc (node, VAL);
		       ICON (LD_ARR_I_X, LONG, "");
	}
	else
	{  CALL (LONG);
	      ICON (0, PF_INT, __INDEXING);
	      for (i = 1; i <= dims; i ++)
	          PARCOM ();

		 elemdesc (node, VAL);
		 subscripts (g_farg (op));
	}
}


/*
 * Name:	do_call
 *
 * Abstract:	
 *
 * Description:	
 *
 *	First we have to compute the parameters whose
 *	evaluation may cause the stack to behave unpredictable
 *	Then we split up between
 *
 *	-	inline functions, i.e. + and so on for
 *		predefined types,
 *	-	functions that may be implemented in a simple
 *		call of the PCC back end
 *	-	the hard case, do some assumptions on the
 *		runtime model and push parameters 
 *
 *
 *	This function is called during the evaluation of a name.
 *	On the name operations are performed (calling, indexing etc),
 *	and these are handled by:
 *	-- Handling each operation;
 *	All this is done in ncode.
 *	(There are no array's of functions and the like.)
 *	Now the next of XCALL will be XNAME, and XNAME's fentity is
 *	the function to be called.
 *
 *	The actual return type of the call is found in
 *	g_types (XCALL). Not in rettype of the function
 *	since renaming may be the case, in which case
 *	we need the return filter of the renaming subprogram.
 *
 *	Parameters are found in XCALL -> fact.
 *	This is a list of XNAMEDASS nodes.
 *
 *	(Pointers to) big parameters have been stored in a temp
 *	by pre_code.
 *
 *	procedures that are
 *		- C functions,
 *		- procedures on level 1
 *		- implementations of standard operators
 *
 *	are called slightly different from the
 *	rest (if any). No static link is
 *	pushed
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
void	do_call (op, val, ctype)
ac	op;
int	val;
int	ctype;
{
	int	t, s;
	ac	fn;
	ac	par;

	ASSERT (op != NULL, ("do_call:1"));
	ASSERT (g_d (op) == XCALL, ("do_call:2"));
	ASSERT (g_d (g_next (op)) == XNAME, ("do_call:3"));

	fn = g_fentity (g_next (op));

	ASSERT (fn != NULL, ("do_call:3"));
	ASSERT (g_d (fn) == XSUB || g_d (fn) == XINHERIT, ("do_call:4"));

	if (g_d (fn) == XINHERIT)
	   fn = g_inh_oper (fn);

	t = pcc_type_of (g_types (op));
	if (ctype != t) {
	   SCONV (ctype);
	   ctype = t;
	}

	if (is_computed (op)) {
	   LOC_OBJECT (curr_level, g_CALL_Voff (op), ctype);
	   return;
	}

	/*
 	 *	check to see whether or not a call to a function
 	 *	can be expanded into an inline C operation
   	 */

	if (is_inline (op)) {
	   if (is_binary (op)) {
	      if (Get_Ccode (fn, DYADIC) == NULL) {
	         do_Ccall (op);
	         return;
	      }

	      code (g_nexp (g_fact (op)), VAL, NOTYPE);
	      fprintf (outfile, Get_Ccode (fn, DYADIC));
	      code (g_nexp (g_next (g_fact (op))), VAL, NOTYPE);
	      return;
	   }
	   else
	   if (Get_Ccode (fn, MONADIC) == NULL) {
	      do_Ccall (op);
	      return;
	   }
	   	   
	   fprintf (outfile, Get_Ccode (fn, MONADIC));
	   code (g_nexp (g_fact (op)), VAL, NOTYPE);
	   return;
	}
	if (as_Ccall (op))
	   do_Ccall (op);
	else
	    hard_call (op);
}

/* Model for an entrycall :
 * =========================
 * 	 if (dats.call_rdv ((tdp) task,
 *			   (int) entry_nr,
 *			   (long) delay,
 *			   p1, p2, ... pn) == TRUE)
 *		pop parameters and copy out the parameters)
 *		do the statements in the then part
 *	 else
 *		do the statements in the else part
 * =========================
 */

static
void	do_entry_call (op, val, ctype)
ac	op;
int	val;
int	ctype;
{
	int	endlab		= new_lab ();
	int	falselab	= new_lab ();
	int	stack_reset;

	ASSERT (op != NULL, ("do_entry_call:1"));
	ASSERT (g_d (op) == XENTRYCALL, ("do_entry_call:2"));

	/* beware, we are in a expr,
	 * expecting a rhs of a comma operator
	 */

	stack_reset = do_entry_params (g_fact (op), op, falselab);
	pop (stack_reset);
	stats_code (g_call_next (op));
	genjump (endlab);

	/* else part of call_rdv */
	deflab (falselab);
	stats_code (g_call_stats (op));
	/* end of the entry call */
	deflab (endlab);
}

static
int	do_entry_params (actuals, entry, falselab)
ac	actuals;
ac	entry;
int	falselab;
{
	ac	e;
	char	par_flags;
	bool	is_scal;
	int	type;
	int	off_set;
	short	val_size	= 0;

	if (actuals == NULL) {
	    /* sofar we did the actuals, now for the entrycall ...
	     */

	    COMMA ();
	    CBRANCH ();
		FORCE (LONG);
		   CALL (LONG);
		      ICON (0, PF_INT, _CALL_RD);
		      PARCOM ();
			 PARCOM ();
			    DEREF (ADDRESS);
			       code (g_next (entry), VAL, ADDRESS);		/* tdp	*/
			   ICON (g_entry_nr (g_e_entry (entry)), LONG, "");
			code  (g_delay_expr (g_call_delay (entry)), VAL, LONG);
		ICON (falselab, ADDRESS, "");

	    return val_size;
	} /* end of actuals == NULL */

	e = 		g_nexp (actuals);
	par_flags = 	g_flags ( g_desc ( g_parname (actuals)));
	is_scal = 	is_small (e);
	type =		pcc_type_of (e);

	if (is_scal) {
	   if (par_flags == OUTMODE) {
	      COMMA ();
		 val_size = push (FALSE, type);
	   }
	   else
	   {  COMMA ();
	      val_size = push (TRUE, type);
	      sm_ch_code (g_parname (actuals), e, type);
	   }
	}
	else
	{     COMMA ();
	      val_size = push (TRUE, ADDRESS);
	      parcheck_code (g_parname (actuals), e, type);
	}

	off_set = do_entry_params (g_next (actuals), entry, falselab);

	/* here follows the normal exit part, i.e.
	 * copy out the out params, and go on,
	 */
	if (par_flags != INMODE && is_scal) {
	   if (is_typconv (e))
	      type = pcc_type_of (g_convexpr (g_primary (e)));
	   COMMA ();
	      ASSIGN (type);
		 if (is_typconv (e))
		    code (g_convexpr (g_primary (e)), VAL, type);
		 else
		    code (e, VAL, type);
		    DYN_OBJECT (off_set, type);
	}

	return off_set + val_size;
}

