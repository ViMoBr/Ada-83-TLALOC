
/*
 * (c) copyright 1986, Delft University of Technology
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
 */

#include	"includes.h"
/*
 *	Forward (static) declarations
 */
static	void	agg_table	();
static	void	rec_table	();
static	void	arr_table	();
static	void	do_nam_agg	();
static	void	do_pos_agg	();
static	void	do_rec_aggr	();
static	void	make_sub	();
static	bool	is_pos_agg	();
static	void	make_rec_desc	();
static	void	make_arr_desc	();
static	void	lowerbound	();
static	void	upperbound	();
static	void	lxval		();
static	void	uxval		();
static	void	elementsize	();
static	ac	get_selectedpath	();
static	int	val_of_discr	();
static	void	OFFSET		();
static	void	CHECK_CODE	();
static	void	Obj_c		();
static	void	ch_ranges	();
static	void	ARRA_ASSIGNCODE	();
static	ac	get_primary	();
static	void	sm_code		();
static	bool	has_no_descr	();
static	ac	agg_elem	();
static	void	c_a_elem	();
static	void	make_table	();
static	bool	is_positional	();
static	ac	arr_aggelem	();
static	void	receldescriptor	();

/*
 *	local "static" functions used in the module
 */

/*
 *	AGGREGATES:
 *	For each aggregate a function is generated unless
 *	the structure of the aggregate is that simple that
 *	the aggregate can be implemented as a table
 */

void	gen_aggregate (agg, cttype)
ac	agg,
	cttype;
{
	ASSERT (agg != NULL, ("gen_aggregate:1"));

	if (is_table (agg)) {
	   agg_table (agg);
	}
	else
	   make_sub (agg);

	s_flags (agg, g_flags (agg) | ORDR_EVAL | LARG_EVAL);
}

static
void	agg_table (x)
ac	x;
{
	if (is_recagg (x))
	   rec_table (x);
	else
	   arr_table (x);
}

static
void	rec_table (agg)
ac	agg;
{
	ac	curr_node,
		cp,
		x;

	ASSERT (g_aggtype (agg) != NULL && g_d (g_aggtype (agg)) == XRECTYPE,
			          ("rec_table:1"));

	cp = g_ffield (root_type (g_aggtype (agg)));
	s_AGG_tablab (agg, new_lab ());
	OUTDATA;
	deflab (g_AGG_tablab (agg));

	while (cp != NULL) {
	   if (is_variant (cp)) {
	      curr_node = get_selectedpath (cp,
		                              g_comp (g_dis (curr_node)), agg);

	      ASSERT (curr_node != NULL, ("rec_table:1"));
	      cp = g_ffield (curr_node);
	   }
	   else
	   if (g_d (cp) == XSUBTYPE)
	      cp = g_next (cp);

	   if (is_discr (cp)) {
	      cp = g_next (cp);
	      continue;
	   }

	   /* Do whatever is to be done			*/
	   x = agg_elem (agg, cp);
	   c_a_elem (g_compexpr (x), g_AGG_tablab (agg));
	   cp = g_next (cp);
	}

	OUTEVEN;
	OUTTEXT;
}

static
void	arr_table (agg)
ac	agg;
{
	int	i,
		low,
		high;
	ac	cp,
		btp,
		eltype;
	MAXADDR	esz,
		aesz,
		vsize;
	char	datatext [AIDL];

	ASSERT (g_d (g_aggtype (agg)) == XFILTER, ("arr_table"));

	btp = root_type (g_aggtype (agg));
	ASSERT (g_d (btp) == XARRAYTYPE, ("arr_table"));

	eltype = g_elemtype (btp);
	low = loval (g_frange (g_constraint (g_aggtype (agg))));
	high = hival (g_frange (g_constraint (g_aggtype (agg))));

	s_AGG_tablab (agg, new_lab ());
	OUTDATA;

	deflab (g_AGG_tablab (agg));
	for (i = 0; i < high - low + 1; i ++) {
	    cp = arr_aggelem (agg, low, i);
	    c_a_elem (g_compexpr (cp), g_AGG_tablab (agg));
	}

	OUTEVEN;

	/* and now the static descriptor :
	 */
	
	s_AGG_Doff (agg, new_lab ());

	deflab (g_AGG_Doff (agg));
	PUT (DEF_LONG, VD_ARR);
	setdatalab (btp, datatext);
	PUT (DEF_SLONG, datatext);

	esz = sz_val (eltype, NULL);
	aesz = align (esz, getflags (eltype) & F_ALIGN);
	vsize = (high - low + 1) * aesz;

	PUT (DEF_LONG, vsize);
	PUT (DEF_LONG, aesz);
	PUT (DEF_LONG, low);
	PUT (DEF_LONG, high);

	OUTTEXT;
}

/*
 *	code for an aggregate with named asosciations (array aggregate)
 */
static
void	do_nam_agg (agg, offset, stack_saver, iter)
ac	agg;
int	offset,
	stack_saver,
	iter;
{
	int	iterlab,
		endlab,
		nextlab,
		incrlab,
		elemnr	= 0;
	ac	cp;

	/* start generating a loop to iterate through		*/
	/* the elements of the aggregate, i.e. simulate		*/
	/* some loop						*/

	/* iter := lowerbound					*/

	new_expr ();
	ASSIGN (LONG);
	   LOC_OBJECT (curr_level, iter, LONG);
	   lowerbound (agg);

	iterlab = new_lab ();
	deflab  (iterlab);
	endlab  = new_lab ();
	incrlab = new_lab ();

	/* check continuation, i.e. iter <= upperbound		*/

	new_expr ();
	CBRANCH ();
	   LE (LONG);
	      LOC_OBJECT (curr_level, iter, LONG);
	      upperbound (agg);
	   ICON (endlab, LONG, "");

	/* now the body of the loop, for each aggregate		*/
	/* element one piece of code				*/

	FORALL (cp, g_fcompas (agg)) {
	   elemnr ++;
	   nextlab = new_lab ();

	   CHECK_CODE (iter, cp, nextlab, elemnr);

	   ARRA_ASSIGNCODE (agg, g_compexpr (cp),
		            offset, iter,
			    g_elemtype (root_type (g_aggtype (agg))) );

	/* stack adjust not yet done		*/
	   genjump (incrlab);
	   deflab (nextlab);
	}

	/* increment iterator					*/

	deflab (incrlab);
	new_expr ();
	ASSIGN (LONG);
	   LOC_OBJECT (curr_level, iter, LONG);
	   PLUS (LONG);
	      LOC_OBJECT (curr_level, iter, LONG);
	      ICON (1, LONG, "");

	/* go do it again					*/

	genjump (iterlab);

	/* that's all folks, return of the function is generated	*/
	/* in the caller					*/
	deflab (endlab);
}

/*
 *	positional array elementen
 */
static
void	do_pos_agg (agg, offset, stack_saver, iter)
ac	agg;
int	offset,
	stack_saver,
	iter;
{
	int	endlab;
	ac	cp;

	endlab  = new_lab ();

	/* initialise the iterator,
	 * used to compute the target address
	 */
	
	new_expr ();
	ASSIGN (LONG);
	   LOC_OBJECT (curr_level, iter, LONG);
	   lowerbound (agg);


	/* for each aggregate
	 * element one piece of code
	 */

	FORALL (cp, g_fcompas (agg)) {
	   ARRA_ASSIGNCODE (agg, g_compexpr (cp),
			    offset, iter,
			    g_elemtype (root_type (g_aggtype (agg))) );

	   new_expr ();
	   ASSIGN (LONG);
	      LOC_OBJECT (curr_level, iter, LONG);
	      PLUS (LONG);
		 LOC_OBJECT (curr_level, iter, LONG);
		 ICON (1, LONG, "");
	}
	/* that's all folks, return of the function is generated	*/
	/* in the caller					*/

	deflab (endlab);
}

/*
 *	doe een record aggregate
 */
static
void	do_rec_aggr (agg, temploc, stack_saver)
ac	agg;
int	temploc,
	stack_saver;
{
	int	cetype;
	ac	cp,
		comp,
		component;

	FORALL (cp, g_fcompas (agg)) {
	   FORALL (comp, g_fcompchoice (cp)) {
	      component = g_fentity (g_primary (g_frang_exp (comp)));

	      if (g_d (component) == XSUBTYPE)
	         continue;

	      if (is_discr	(component))
	         continue;

	      if (is_small (g_compexpr (cp))) {
		 cetype = pcc_type_of (g_compexpr (cp));

	         new_expr ();
		 pre_code (g_compexpr (cp), VAL);
	         ASSIGN (cetype);
	            DEREF (cetype);
	              PLUS (pointer_type_of (cetype));
	                 LOC_OBJECT (curr_level, temploc, pointer_type_of (cetype));
		         OFFSET (component);
		   code (g_compexpr (cp), VAL, cetype);
	     }

	     else
	     {  new_expr ();
		pre_code (g_compexpr (cp), VAL);
	        CALL (LONG);
	           ICON (0, PF_INT, __ASSIGN);
	           PARCOM ();
	              PARCOM ();
			 receldescriptor (component);
	                 CALL (ADDRESS);
	                    ICON (0, PF_ADDR, __CHECK);
	                    PARCOM ();
	                       PARCOM ();
				  DESCRIPTOR (g_compexpr (cp));
			          receldescriptor (component);
			       code (g_compexpr (cp), VAL, LONG);
	                 PLUS (ADDRESS);
	                    LOC_OBJECT (curr_level, temploc, ADDRESS);
	                    OFFSET (component);
	     }
	/* stack adjust still to be done		*/
	   }
	}
}

/*
 *	make a function from an aggregate
 */
static
void	make_sub (agg)
ac	agg;
{
	PROC_VARS;

	int	entry_lab	= new_lab ();
	int	elab		= new_lab ();
	int	temp 		= incr_off (FRAMBASE, TADDRSIZE);
	int	temploc		= align (temp, MAX_ALIGN);
	int	stack_saver;
	int	fnr		= new_lab ();
	int	iter;
	int	dummy_lab	= new_lab ();
	ac	cp;
	char	datatext [AIDL];

	textlab (dummy_lab, datatext);
	temp		= incr_off (temp, TADDRSIZE);
	stack_saver	= align (temp, MAX_ALIGN);

	if (!is_recagg (agg)) {
	   temp = incr_off (temp, TLONGSIZE);
	   iter = align (temp, MAX_ALIGN);
	}

	PUSH_PROC (NULL);
	lev_maxoff = temp;

	/* for the iterator		*/
	FORALL (cp, g_fcompas (agg)) {
	   STAT_VARS;
	   PUSH_STAT;
	   sto_expr (cp);
	   POP_STAT;
	}

	COM (("artificial function for aggregate\n"));
	s_AGG_tablab (agg, entry_lab);

	deflab (entry_lab);
	/* The function start code:		*/
	OUT (("&%d	%d	%d	%d	%s\n",	
				ICFBEG, fnr, elab, FALSE, datatext));
	OUT (("[%d	%d	%d	%d	\n",
				fnr, (lev_maxoff + C_BASE) * BPB, 7, 13));
	/* the actual code					*/
	/* First we have to check if we have to make a 
	 * aggregate descriptor
	 * and if so make it now, because we need the data in the
	 * descriptor to allocate space for the aggregate
	 */

	if (is_recagg (agg))
	   make_rec_desc (agg);
	else
	   make_arr_desc (agg);

	/* we need some local storage here			*/
	/* and init it with a datastructure of the right size	*/
	new_expr ();
	ASS_MIN (ADDRESS);
	   REG (SP_DYN, ADDRESS);
	   DEREF (ADDRESS);
	      PLUS (ADDRESS);
	         PAR_OBJECT (curr_level, PAR_1, ADDRESS);
	         ICON (VD_SIZE, LONG, "");

	new_expr ();
	ASSIGN (ADDRESS);
	   LOC_OBJECT (curr_level, temploc, ADDRESS);
	   REG (SP_DYN, ADDRESS);

	new_expr ();		/* save stacktop		*/
	ASSIGN (ADDRESS);
	   LOC_OBJECT (curr_level, stack_saver, ADDRESS);
	   REG (SP_DYN, ADDRESS);

	/* As the caller of this routine will pop the parameters,
	 * and thus destroys the first two (as there are two longs
	 * as parameter) long values in the computed value, we now
	 * extend the stack with two dummy's
	 */

	new_expr ();
	ASS_MIN (ADDRESS);
	    REG (SP_DYN, ADDRESS);
	    ICON (2 * (pcc_size (ADDRESS)),LONG,"");

	/* dispatch, it is either a record or an array aggregate	*/
	if (is_recagg (agg))
	   do_rec_aggr (agg, temploc, stack_saver);
	else
	   if (is_pos_agg (agg))
	   	do_pos_agg  (agg, temploc, stack_saver, iter);
	   else
	   	do_nam_agg  (agg, temploc, stack_saver, iter);

	/* exit code for the routine				*/

	new_expr ();
	FORCE (ADDRESS);
	   LOC_OBJECT (curr_level, temploc, ADDRESS);
	/*
 	 * Function exit code:
	 */
	OUT (("&%d	\n", ICFEND));
	OUT (("&%d	%d	\n", ICDLABN, elab));
	OUT (("&%d	\n", ICFEND));
	new_expr ();
	UCALL (VOID);
	ICON (0, PF_INT, __HARDRET);
	OUT (("]\n"));

	POP_PROC;
}

/*
 * simple predicate
 */
static
bool	is_pos_agg (agg)
ac	agg;
{
	ac	cp;

	FORALL (cp, g_fcompas (agg)) {
	   if (g_fcompchoice (cp) != NULL)
	      return FALSE;
	}

	return TRUE;
}

/*
 *	make a record descriptor (if one is needed)
 */
static
ac	first_elem (t)
ac	t;
{
	if (t == NULL)
	   return NULL;

	switch (g_d (t)) {
	   case XRECTYPE:
	      return g_ffield (t);

	   case XINCOMPLETE:
	      return g_fidiscr (t);

	   case XPRIVTYPE:
	      return g_fpdiscr (t);

	   default:
	      ASSERT (FALSE, ("first-elem:0"));
	}
}

static
void	make_rec_desc (agg)
ac	agg;
{
	ac	cp,
		type,
		t2,
		x;
	int	cetype,
		i = 0;

	ASSERT (agg != NULL, ("make_rec_desc:1"));

	type = bf_type (g_aggtype (agg));
	t2   = root_type (type);

	if (g_REC_forms (t2) == 0)
	   return;

	new_expr ();
	ASSIGN (LONG);
	   DEREF (LONG);
	      PAR_OBJECT (curr_level, PAR_1, P_LONG);
	   ICON (VD_REC, LONG, "");

	new_expr ();
	ASSIGN (P_LONG);
	   /* Careful, What means + and what means - in offsets	*/
	   DEREF (P_LONG);
	      PLUS (P_LONG);
	         PAR_OBJECT (curr_level, PAR_1, P_LONG);
	         ICON (LD_REC_TTP, LONG, "");
	   DESCRIPTOR (t2);

	ASSERT (t2 != NULL && g_d (t2) == XRECTYPE, ("make_rec_desc:0"));

	FORALL (cp, first_elem (type)) {
	   if (g_d (cp) != XOBJECT)
	      break;

	   if (!is_discr (cp))
	      break;

	   x = agg_elem (agg, cp);
	   cetype = pcc_type_of (g_compexpr (x));

	   new_expr ();
	   pre_code (g_compexpr (x));
	   ASSIGN (LONG);
	      DEREF (cetype);
		 PLUS (pointer_type_of (cetype));
	            PAR_OBJECT (curr_level, PAR_1, pointer_type_of (cetype));
		    ICON (LD_RECDISCR + (i * TLONGSIZE), LONG, "");
	      code (g_compexpr (x), VAL, cetype);

	   i ++;
	}

	new_expr ();
	CALL (VOID);
	   ICON (0, PF_INT, __DC_CHECK);
	   PAR_OBJECT (curr_level, PAR_1, ADDRESS);
}

/*
 *	make an array descriptor (always needed)
 */
static
void	make_arr_desc (agg)
ac	agg;
{
	ac	cp;
	int	i = 0;
	ac	type;

	ASSERT (agg != NULL && g_aggtype (agg) != NULL, ("make_arr_desc:1"));

	type = bf_type (g_aggtype (agg));

	/* If we cannot make a descriptor, well, just do not	*/
	if (g_AGG_Doff (agg) == 0)
	   return;

	new_expr ();
	ASSIGN (LONG);
	   DEREF (LONG);
	      PAR_OBJECT (curr_level,PAR_1, P_LONG);
	   ICON (VD_ARR, LONG, "");

	new_expr ();
	ASSIGN (P_LONG);
	   DEREF (P_LONG);
	      PLUS (P_LONG);
	         PAR_OBJECT (curr_level,PAR_1, P_LONG);
	         ICON (LD_ARR_TTP,LONG, "");
	   DESCRIPTOR (type);

	/* are we lucky, we know DAS is restricted to one dimensional	*/
	/* array aggregates						*/
	/* take the (m .. n => e) case also into account                */
	/* implying that lower and upperbound do not have to be static  */
	new_expr ();
	ASSIGN (LONG);
	   DEREF (LONG);
	      PLUS (P_LONG);
	         PAR_OBJECT (curr_level,PAR_1, P_LONG);
	   	 ICON (LD_ARR_I_X, LONG, "");
           lxval (g_frange (g_constraint (g_aggtype (agg))));

	new_expr ();
	ASSIGN (LONG);
	   DEREF (LONG);
	      PLUS (P_LONG);
	         PAR_OBJECT (curr_level,PAR_1, ADDRESS);
	         ICON (LD_ARR_I_X + LO_LD_ARR_SIZE, LONG, "");
           uxval (g_frange (g_constraint (g_aggtype (agg))));

	new_expr ();
	CALL (VOID);
	   ICON (0, PF_INT, __IC_CHECK);
	   PAR_OBJECT (curr_level,PAR_1, ADDRESS);
}

/*
 *	Make an initialising subprogram
 *	for a record component
 *	This function creates an Ada- subbody that encodes the expression
 *	of a thunk_node from a object_descr node.
 *	The subroutine has 4 parameters :
 *	- the static link of the stackframe of the surrounding routine.
 *	- the target descriptor
 *	the target address
 *	the value descriptor of the record type that has the initialized
 *	components. (Used to enable assignments of the discrs)
 *	The subroutine performs an assign of the result of the expression
 *	to the target address. Every assign is run-time checked
 *	
 *	If the expression should have to be pre_computed , it is done now,
 *	so the resulting code of this pre-computation appears in this sub
 */
void	make_in_sub	(th)
ac	th;
{
	PROC_VARS;

	char	fn_name [AIDL];
	int	entry_lab 	= new_lab ();
	int	next_lab  	= new_lab ();
	int	fram_lab  	= new_lab ();
	int	elab		= new_lab ();
	int	fnr		= new_lab ();


	COM (("artificial subroutine for initialisation in types\n"));
	s_code_context (INIT_SUB);

	PUSH_PROC (NULL);
	sto_expr (g_thexpr (th), NULL);
	
	defexprlab (th);
	OUT (("&%d	%d	%d	%d	%s\n",	
				ICFBEG, fnr, elab, FALSE, ""));
	OUT (("[%d	%d	%d	%d	\n",
				fnr, (lev_maxoff + C_BASE) * BPB, 7, 13));


	/* the actual code */
	if (is_small (g_thexpr (th))) {
	   int thetype = pcc_type_of (g_thexpr (th));

	   new_expr ();
	   /* first pre-evaluate the thunk expression */
	   pre_code (g_thexpr (th));

	   ASSIGN (thetype);
	      DEREF (thetype);
	      PAR_OBJECT (curr_level, PAR_2,
                                      pointer_type_of (thetype));
	      CALL (thetype);
	         ICON (0, PF_INT, __SCAL_CHECK);
	         PARCOM ();
	            PAR_OBJECT (curr_level, PAR_1, P_LONG); /* target_descr */
	            sm_code (g_thexpr (th), VAL);

	}
	else {
	   if (has_no_descr (g_thexpr (th))) {
	      new_expr ();
	      /* first pre-evaluate the thunk expression */
	      pre_code (g_thexpr (th));
	      CALL (LONG);
	         ICON (0, PF_INT, __ASSIGN);
	         PARCOM ();
	            PARCOM ();
	               PAR_OBJECT (curr_level, PAR_1, P_LONG);
	               code (g_thexpr (th), VAL, NOTYPE);
	            PAR_OBJECT (curr_level, PAR_2, ADDRESS);
		}
		else
		{  new_expr ();
		   /* first pre-evaluate the thunk expression */
	           pre_code (g_thexpr (th));
		   CALL (LONG);
	              ICON (0, PF_INT, __ASSIGN);
		      PARCOM ();
	                 PARCOM ();
	                    PAR_OBJECT (curr_level, PAR_1, ADDRESS);
	                    CALL (LONG);
	                       ICON (0, PF_INT, __CHECK);
                               PARCOM ();
                                  PARCOM ();
                                     DESCRIPTOR (g_thexpr (th));
	/* target descriptpo:	*/
	                             PAR_OBJECT (curr_level, PAR_1, P_LONG);
	                          code (g_thexpr (th), VAL, NOTYPE);
				PAR_OBJECT (curr_level, PAR_2, ADDRESS);
	       }
	}

	/* end of the code */
	OUT (("&%d	%d	\n", ICDLABN, elab));
	OUT (("&%d	\n", ICFEND));
	OUT (("]\n"));

	deflab (next_lab);
	s_code_context (NORMAL);
	POP_PROC;
}

/*
 *	compute the "lowerbound" of the array aggregate descriptor
 *	Two cases are possible:
 *	 the aggregate value is completely specified (i.e. no others)
 *	 in this case the lowerbound value can be taken from
 *	 the (compiler-constructed) constraint directly
 *	 The expression being static can be asserted
 *	- the aggregate contains an others choice
 *	 Donot bother, take the value from the descriptor
 *	 that is passed as parameter to the implementing function
 */
static
void	lowerbound (agg)
ac	agg;
{
	ac	fr;

	if (g_AGG_Doff (agg) == 0) {	/* no private descriptor	*/
	   DEREF (LONG);
	      PLUS (P_LONG);
	         PAR_OBJECT (curr_level, PAR_1, ADDRESS);
	         ICON (LD_ARR_I_X, LONG, "");
	}
	else
	{  fr = g_frange (g_constraint (basefilter (g_aggtype (agg))));
           if (g_frang_exp (fr) == NULL)
              ICON (loval (fr), LONG, "");
           else
              code (g_frang_exp (fr), VAL, LONG);
        }
}

static
void	upperbound (agg)
ac	agg;
{
	ac	fr;

	if (g_AGG_Doff (agg) == 0) {	/* no private desc		*/
	   DEREF (LONG);
	      PLUS (P_LONG);
	         PAR_OBJECT (curr_level, PAR_1, P_LONG);
	         ICON (LD_ARR_I_X + LO_LD_ARR_SIZE, LONG, "");
	}
	else
	{ fr = g_frange (g_constraint (basefilter (g_aggtype (agg))));
	  if (g_frang_exp (fr) == NULL)
	     ICON (hival (fr), LONG, "");
	  else
	     code (g_next (g_frang_exp (fr)), VAL, LONG);
	}
}

static
void	lxval (x)
ac	x;
{
	ASSERT (x != NULL && g_d (x) == XRANGE, ("lxval: %d no range", g_d (x)));
        if (is_static (x))
           ICON (loval (x), LONG, "");
        else
        {  ASSERT (g_frang_exp (x) != NULL, ("lxval: expr = NULL"));
           code (g_frang_exp (x), VAL, LONG);
	}
}

static
void	uxval (x)
ac	x;
{
	ASSERT (x != NULL && g_d (x) == XRANGE, ("uxval: %d no range", g_d (x)));
        if (is_static (x))
           ICON (loval (x), LONG, "");
        else
	{  ASSERT (g_frang_exp (x) != NULL, ("uxval: expr = NULL"));
           code (g_next (g_frang_exp (x)), VAL, LONG);
	}
}

static
void	elementsize (agg)
ac	agg;
{
	ac	elt;

	elt = g_elemtype (root_type (g_aggtype (agg)));
	if (hasstatsize (elt)) {
	   ICON (getvalsize (basefilter (elt), NULL), LONG, "");
	}
	else
	{  DEREF (LONG);
	      PLUS (P_LONG);
	         PAR_OBJECT (curr_level, PAR_1, P_LONG);
	         ICON (LD_ARR_ESIZE, LONG, "");
	}
}

/*
 *	Simple support functions, not used outside this module
 */
static
ac	get_selectedpath (ac variant_node,
                          ac disc,
                          ac aggregate)
{
	ac	others	= NULL;
	ac	tmp;
	int	disc_value;

	if (variant_node == NULL)
	   return NULL;

	disc_value = val_of_discr (aggregate, disc);

	while (variant_node != NULL) {
	   tmp = g_varchoice (variant_node);
	   while (tmp != NULL) {
	      if (is_others (tmp))
	         others = variant_node;
	      else
	      if ((loval (tmp) <= disc_value) &&
	          (disc_value <= hival (tmp) ))
	         return variant_node;

	      tmp = g_next (tmp);
	   }

	   variant_node = g_next (variant_node);
	}

	return NULL;
}

static
int	val_of_discr (ac aggr,
                      ac discr)
{
	ac	walker;
	ac	t;
	ac	others = NULL;

	FORALL (walker, g_fcompas (aggr)) {
	   FORALL (t, g_fcompchoice (t)) {
	      if (is_others (t))
	         abort ();
	      if (g_fentity (g_primary (g_frang_exp (t))) == discr) {
		 return ord (g_fentity (g_primary (g_compexpr (walker))));
	      }
	   }

	}
	ASSERT (FALSE, ("x1"));
}

static
void	OFFSET (component)
ac	component;
{
	if (g_OBJ_alloc (component) == XNO_TABLE)
	   ICON (g_OBJ_offset (component), LONG, "");
	else
	{  DEREF (LONG);
	      PLUS (P_LONG);
	         if (g_OBJ_alloc (component) == XTYPE_TABLE)
	            DESCRIPTOR (root_type (get_type (component)));
	         else
	            PAR_OBJECT (curr_level, PAR_1, P_LONG);
	      ICON (g_OBJ_offset (component), LONG, "");
	}
}

static
void	CHECK_CODE (off, cp, l, d)
int	off;
ac	cp;			/* compass		*/
int	l;			/* false lab number	*/
int	d;			/* lwb + d (positional)	*/
{
	ac	ch_r;

	if (g_next (cp) == NULL)	/* last one, do not check	*/
	   return;

	ch_r = g_fcompchoice (cp);
	new_expr ();
	CBRANCH ();
	   if (ch_r == NULL) {		/* positional		*/
	      EQ (LONG);
	         LOC_OBJECT (curr_level, off, LONG);
	         PLUS (LONG);
	            ICON (d, LONG, "");
	            DEREF (LONG);
	               PLUS (P_LONG);
	                  PAR_OBJECT (curr_level, PAR_1, ADDRESS);
	                  ICON (LD_ARR_I_X, LONG, "");
	   }
	   else
	   ch_ranges (off, ch_r);
	   ICON (l, ADDRESS, "");
}

/*
 *	Obj_c is used as an actual parameter somewhere here
 */
static
void	Obj_c (x)
int x;
{
	LOC_OBJECT (curr_level, x, LONG);
}

static
void	ch_ranges (off, rl)
int	off;
ac	rl;
{
	if (is_others (rl)) {
	   ICON (TRUE, LONG, "");
	   return;
	}
	v_ranges (rl, Obj_c, off);
}

static
void	ARRA_ASSIGNCODE (agg, expr, t_offs, iter, eltype)
ac	agg;
ac	expr;
int	t_offs;
int	iter;
ac	eltype;
{
	if (is_small (expr)) {
	   int extype = pcc_type_of (expr);
	   new_expr ();
	   pre_code (expr);
	   ASSIGN (extype);
	      DEREF (extype);
	         PLUS (pointer_type_of (extype));
	            LOC_OBJECT (curr_level, t_offs, pointer_type_of (extype));
	            MUL (LONG);
	               MINUS (LONG);
	                  LOC_OBJECT (curr_level, iter, LONG);
		          lowerbound (agg);
		       elementsize (agg);
	         code (expr, VAL, extype);
	}
	else
	{  new_expr ();
	   pre_code (expr);
	   CALL (LONG);
	      ICON (0, PF_INT, __ASSIGN);
	      PARCOM ();
	         PARCOM ();
		    DESCRIPTOR (eltype);
	            CALL (ADDRESS);
	               ICON (0, PF_INT, __CHECK);
	               PARCOM ();
	                  PARCOM ();
	                     DESCRIPTOR (expr);
			     DESCRIPTOR (eltype);
	                  code (expr, VAL, NOTYPE);
	         PLUS (ADDRESS);
	            LOC_OBJECT (curr_level, t_offs, ADDRESS);
	            MUL (LONG);
	               MINUS (LONG);
	                  LOC_OBJECT (curr_level, iter, ADDRESS);
			  lowerbound (agg);
	               elementsize (agg);
	}
}

static
ac	get_primary (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	while (g_d (x) == XEXP)
	   x = g_primary (x);

	if (g_d (x) == XNAME)
	   return g_fentity (x);

	return x;
}

/*
 *	generate an argument for the checking function
 *	always a LONG result
 */
static
void	sm_code (exp, val)
ac	exp;
int	val;
{
	ac	pr;

	pr = get_primary (exp);

	/* if the primary is an object and this object is a
	 * discriminant in a record type, then we cannot use code
	 * to generate the actual code. ( noalloc for discrs.)
	 * Now we use the offset in the value_descriptor
	 * i.e. obj -> OBJ_offset and the address of the value_
	 * descriptor i.e. parameter 3.
	 * otherwise we generate code by means of code ()
	 */

	if (g_d (pr) == XOBJECT)
	   if (is_discr (pr)) {
	      DEREF (LONG);
		 PLUS (ADDRESS);
		    PAR_OBJECT (curr_level,PAR_3,ADDRESS);
		    ICON (g_OBJ_offset (pr), LONG, "");
	      return;
	   }
	code (exp,val, LONG);
}

static
bool	has_no_descr (exp)
ac	exp;
{
	ac	pr;

	pr = get_primary (exp);
	if (g_d (pr) != XAGGREGATE)
	   return FALSE;

	return has_call_block (g_aggtype (pr));
}

static
ac	agg_elem (agg, elem)
ac	agg;
ac	elem;
{
	ac	cp,
		pp;

	FORALL (cp, g_fcompas (agg))
	   FORALL (pp, g_fcompchoice (cp)) {
	      if (g_fentity (g_primary (g_frang_exp (pp))) == elem)
	           return cp;
	   }

	ASSERT (FALSE, ("agg_elem: no element found"));
}

static
void	c_a_elem (expr, lab)
ac	expr;
int	lab;
{
	/* only the simple case now	*/
	switch (sz_val (g_exptype (expr), NULL)) {
	   case TBYTESIZE:
	      PUT (DEF_BYTE, getvalue (expr));
	      break;

	   case TWORDSIZE:
	      PUT (DEF_WORD, getvalue (expr));
	      break;

	   case TLONGSIZE:
	      PUT (DEF_LONG, getvalue (expr));
	      break;

	   DEFAULT (("c_a_elem, illegal type"));
	
	}
}

static
void	make_table (agg)
ac	agg;
{	ac	t;

	ASSERT (agg != NULL, ("make_table:0"));
	t = root_type (g_aggtype (agg));
	ASSERT (t != NULL, ("make_table:1"));
	if (g_d (t) == XRECTYPE)
	   rec_table (agg);
	else
	   arr_table (agg);
}

static
bool	is_positional (cp)
ac	cp;
{
	return g_fcompchoice (cp) == NULL;
}

/*
 *	preliminary versions of some selecting routines:
 */

static
ac	arr_aggelem (agg, low, i)
ac	agg;
int	low;
int	i;
{
	ac	cp;
	int	cnt = 0;

	FORALL (cp, g_fcompas (agg)) {
	   if (is_positional (cp)) {
	      if (cnt == i)
	         return cp;
	   }
	   else
	   if (isinchoices (low + i, g_fcompchoice (cp)))
		return cp;

	   cnt ++;
	}
}

static
void	receldescriptor (x)
ac	x;
{
	ASSERT (g_d (x) == XOBJECT, ("record element descr "));
	if (has_call_block (get_type (x))) {
	   PLUS (P_LONG);
	      PAR_OBJECT (curr_level, PAR_1, P_LONG);
	      ICON (cboffset (get_type (x)), LONG, "");
	}
	else
	   DESCRIPTOR (get_type (x));
}
