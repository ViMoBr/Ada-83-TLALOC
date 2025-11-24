
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
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"
/*
 *	Forward (static) declarations:
 */
static	void	process_node	();
static	void	DISCRIM	();
static	void	attrib_enum	();
static	void	attrib_table	();
static	void	arrv_desc	();
static	int	srec_desc	();
static	ac	first_fld	();
static	ac	next_fld	();
static	ac	firstvar	();
static	void	recv_desc	();
static	void	cb_desc		();
static	void	accv_desc	();
static	void	range_desc	();

/*
 *	DESCRIPTOR GENERATION
 */


#define	is_varnode(x)	(x != NULL && g_d (x) == XVARIANT)

/*
 *	generate a path function for a variant record
 */
void	path_function (node)
ac	node;
{
	int	pathlab,
		elab;

	if (g_REC_forms (node) == 0) 
	   return;

	if (!is_varrec (node))
	   return;
/*
 *	It's a variant record, so create an artifical function:
 */
	pathlab = new_lab ();
	s_REC_pathf (node, pathlab);
	elab    = new_lab ();
	deflab (pathlab);

	OUT (("&%d	%d	%d	%d	%s\n",	
				ICFBEG, pathlab, elab, FALSE, ""));
	OUT (("[%d	%d	%d	%d	\n",	
				pathlab, C_BASE * BPB, 7, 13));

	new_expr ();
	process_node (node);

	OUT (("&%d	%d	\n", ICDLABN, elab));
	OUT (("&%d	\n", ICFEND));
	OUT (("]\n"));
}

/*
 *	
 */
static
void	process_node (x)
ac	x;
{
	ac	y;

	if (g_dis (x) == NULL) {
	   ICON (g_VAR_fpath (x), INT, "");
	   return;
	}

/*
 *	If there is a variant:
 */

	for (y = firstvar (x); y != NULL; y = g_next (y)) {
	   if (is_others (g_varchoice (y)) ||
				 g_next (y) == NULL) {
	      ICON (g_VAR_fpath (y), INT, "");
	      return;
	   }

	   QUEST (INT);
	   v_ranges (g_varchoice (y), DISCRIM,
			      disc_num (g_comp (g_dis (x))));
	      COLON (INT);
	          process_node (y);
	}
}

/*
 *	access code to a discriminant in a path function
 *	depends on the layout of a recordsubtype descriptor
 */
static
void	DISCRIM (y)
int	y;
{
	DEREF (LONG);
	   PLUS  (P_LONG);
	      LOC_OBJECT (curr_level, - 2 * TADDRSIZE, P_LONG);
	      ICON  (y * TLONGSIZE, LONG, "");
}

/*
 *	Create a run-time descriptor for enumerationliterals
 *	Complicated by the requirement of the enumeration literals
 *	being encoded in run-time.
 *	attrib_enum generates code for the runtime
 *	representation of a single enumeration literal
 *	in the form (next, value, literal_value)
 *	attrib_table generates code for a list of enumerationliterals
 *	and finally, enum_desc, generates the whole descriptor
 */
static
void	attrib_enum (l, x)
int	l;		/* label		*/
ac	x;
{
	static char datatext [30];

	char	*c;

	ASSERT (x != NULL && has_tag (x), ("attrib_enum:1"));

	c = g_tag (x);

	textlab (l, datatext);
	PUT (DEF_SLONG, datatext);
	PUT (DEF_WORD, g_enuml_ord (x));
	if (g_d (x) == XENUMLIT) {
	   while (*c != EOS) {
	      PUT (DEF_BYTE, *c);
	      c ++;
	   }
	}
	else
	{  PUT (DEF_BYTE, '`');
	   PUT (DEF_BYTE, *c);
	   PUT (DEF_BYTE, '`');
	}

	PUT (DEF_BYTE, 0);
	OUTEVEN;
	deflab (l);
}

static
void	attrib_table (node)
ac	node;
{
	ac	x;

	ASSERT (node != NULL && g_d (node) == XENUMTYPE, ("attrib_table:1"));

	FORALL (x, g_fenumlit (node))
	   attrib_enum (new_lab (), x);

	PUT (DEF_LONG, 0);
}

/*
 *	Create a descriptor for an enumeration type
 */
void	enum_desc (node)
ac	node;
{
	OUTDATA;
	defexprlab (node);
	PUT (DEF_LONG, CD_BIT_H);
	PUT (DEF_LONG, TBYTESIZE);
	PUT (DEF_LONG, 0);
	PUT (DEF_LONG, g_nenums (node) - 1);
	attrib_table (node);
	OUTTEXT;
}

/*
 *	Generate a descriptor for a task type
 */
void	task_desc (x)
ac	x;
{
	alloc_desc (x);

	/* the tag		*/
	move (NULL, TD_TSK, x, TT_TSK_DTAG);

	/* The priority		*/
	move (NULL, 0, x, TT_TSK_PRIO);

	/* The default segment size	*/
	move (NULL, DEFSTACKSIZE, x, TT_TSK_MEMSIZE);

	/* The entry adres (temporary	*/
	new_expr ();
	ASSIGN (P_LONG);
	   desc_address (x, TT_TSK_ADDR);
	   ICON (0, ADDRESS, _START_T);

	/* The static link of the task type creator	*/
	new_expr ();
	ASSIGN (P_LONG);
	   desc_address (x, TT_TSK_ST_LINK);
	   get_stlink (0, ADDRESS);
}

/*
 *	Create a descriptor for an array
 */
void	arr_desc (node)
ac	node;
{
	int	i,
		offs = 0;
	ac	ind;

	ASSERT (node != NULL && g_d (node) == XARRAYTYPE, ("arr_desc:1"));

	ind = g_findex (node);
	alloc_desc (node);

	move (NULL, TD_ARR, node, TT_ARR_DTAG);
	move (NULL, g_ARR_ndims (node), node, TT_ARR_NDIMS);
	move (NULL, g_ARR_flags (node), node, TT_ARR_AFLAGS);
	move (g_elemtype (node), 0, node, TT_ARR_E_CDP);

	offs = TT_ARR_IXRP;
	FORALL (ind, g_findex (node)) {
	   move (g_indextype (ind), 0, node, offs);
	   offs += TADDRSIZE;
	}

	dat_alloc (node, offs);
}

/*
 *	Create a descriptor for an array subtype
 *	The implementation is as a static procedure, called from sub_desc
 */
static
void	arrv_desc (x)
ac	x;
{
	int	offs,
		numofc,
		i;
	ac	y;

	ASSERT (x != NULL && g_d (x) == XSUBTYPE, ("arrv_desc"));

	y = g_parenttype (x);

	ASSERT (y != NULL && g_d (y) == XFILTER, ("arrv_desc:2"));

	move (NULL, VD_ARR, x, LD_ARR_DTAG);
	move (root_type (x), 0, x, LD_ARR_TTP);
	move (NULL, 0, x, VD_SIZE);
	move (NULL, 0, x, LD_ARR_ESIZE);

	offs = LD_ARR_I_X;
	for (i = 0; i < g_ARR_ndims (root_type (x)); i ++) {
	   move (g_parenttype (x), 2 * i + 1, x, offs);
	   move (g_parenttype (x), 2 * i + 2, x, offs + TLONGSIZE);
	   offs += I_X_LD_ARR_SIZE;
	}

	new_expr ();
	CALL (VOID);
	   ICON (0, PF_INT, __IC_CHECK);
	   desc_const (x);

	dat_alloc (x, offs);
}

/*
 *	Generate the static part of a record type descriptor
 */
static
int	srec_desc (x, pathlab)
ac	x;
int	pathlab;
{
	ac	y;
	int	statlab = new_lab ();
	char	datatext [AIDL];

	OUTDATA;
	deflab (statlab);

	PUT (DEF_LONG, g_REC_nflds (x));
	PUT (DEF_LONG, g_REC_forms (x));
	PUT (DEF_LONG, g_REC_ninits (x));
	PUT (DEF_LONG, g_REC_flags (x));
	PUT (DEF_LONG, g_REC_vdsize (x));
	/* even if pathlab == 0 we print something,
	 * because we have to deal in runtime with
	 * variant records that are not real variant
	 * records. (a record with a discriminant that's
	 * not DISCDEP is made variant.
	 */
	if (pathlab != 0) {
	   textlab (pathlab,datatext);
	   PUT (DEF_SLONG, datatext);

	   for (y = first_fld (x); y != NULL; y = next_fld (y)) {
	      PUT (DEF_BYTE, low_path (y));
	      PUT (DEF_BYTE, high_path (y));
	   }
	}
	else
	   PUT (DEF_LONG,	0);

	OUTEVEN;
	OUTTEXT;

	return statlab;
}

/*
 *	iterators over the fields and variants in a record type,
 *	useful when generating recordtype descriptors
 */
static
ac	first_fld (x)
ac	x;
{
	ASSERT (x != NULL && (g_d (x) == XRECTYPE || g_d (x) == XVARIANT),
	                                       ("first_fld"));

	x = g_ffield (x);
	while (is_varnode (x))
	   x = g_ffield (x);

	if (x == NULL)
	   return NULL;

	if (g_d (x) == XSUBTYPE)
	   return g_next (x);

	return x;
}

static
ac	next_fld (x)
ac	x;
{
	if (x == NULL)
	   return NULL;

	if (g_d (x) == XRECTYPE)
	   return NULL;

	if (g_next (x) == NULL)
	   return next_fld (g_enclunit (x));

	x = g_next (x);

	if (g_d (x) == XSUBTYPE)
	   x = g_next (x);

	if (!is_varnode (x))
	   return x;

	/* It's a variant node	*/
	if (g_ffield (x) == NULL)
	   return next_fld (x);

	return first_fld (x);
}

/*
 *	Get the first variant node
 */
static
ac	firstvar (x)
ac	x;
{
	ac	y;

	if (x == NULL)
	   return NULL;

	FORALL (y, g_ffield (x)) {
	   if (g_d (y) == XVARIANT)
	      break;

	   y = g_next (y);
	}

	return y;
}

/*
 *	Create a record type descriptor
 */
void	rec_desc (x)
ac	x;
{
	ac	y;
	int	st_lab,
		fnlab,
		distance,
		fld_number = 0;
	static char datatext [AIDL];

	do_recflds (x);

	if (g_REC_npaths (x) != 1)	/* Real variant record	*/
	   fnlab = g_REC_pathf (x);
	else
	   fnlab = 0;

	st_lab = srec_desc (x, fnlab);
	alloc_desc (x);
	move (NULL, TD_REC, x, TT_REC_DTAG);

	textlab (st_lab, datatext);
	lab_store (datatext, x, TT_REC_SP);

	move (NULL, g_REC_vsize (x), x, TT_REC_VSIZE);
	distance = TT_REC_F_EDP;

	for (y = first_fld (x); y != NULL; y = next_fld (y)) {
	   move (get_type (y), 0, x, distance);
	   distance += TADDRSIZE;
	}

/*
 *	field initialization
 */

	if ((g_REC_flags (x) & (DYNREC|CSTREC)) == DYNREC)
	   distance += g_REC_nflds (x) * TLONGSIZE;
	   /* skip offtable */

	if (g_REC_ninits (x) > 0) {
	   /* fill st_link field */
	   /* we KNOW that the alloc is FIXSTACK so .. */
	   new_expr ();
	   ASSIGN (P_LONG);
	       desc_address (x, distance);
	       get_stlink (0, ADDRESS);

	   distance += TADDRSIZE;
	}

	for (y = first_fld (x); y != NULL; y = next_fld (y)) {
	   if (!is_discr (y) && g_expr (g_desc (y)) != NULL) {
	      move (NULL, fld_number, x, distance);
	      distance += TLONGSIZE;

	      ASSERT (g_d (g_expr (g_desc (y))) == XTHUNK, ("rec_desc"));

	      setexprlab (g_expr (g_desc (y)), datatext);
	      lab_store (datatext, x, distance);
	      distance += TADDRSIZE;
	   }
	   fld_number ++;
	}

	if (g_REC_flags (x) & (DYNREC | VARREC | CSTREC)) {
	   new_expr ();
	   CALL (VOID);
	      ICON (0, PF_INT, __REC_INIT);
	      desc_const (x);
	}

	dat_alloc (x, distance);
}

/*
 *	The inevitable record subtype descriptor
 */
static
void	recv_desc (x)
ac	x;
{
	ac	ftp,
		cx;
	int	offs,
		i;

	ASSERT (x != NULL && g_d (x) == XSUBTYPE, ("recv_desc:1"));

	cx = g_parenttype (x);

	ASSERT (cx != NULL && g_d (cx) == XFILTER, ("recv_desc:2"));

	ftp = root_type (x);
	move (NULL, VD_REC, x, LD_REC_DTAG);
	move (ftp, 0, x, LD_REC_TTP);

	offs = LD_RECDISCR;
	for (i = 1; i <= getnform (ftp); i++) {
	   move (cx, i, x, offs);
	   offs += VD_DISCR_LD_REC_SIZE;
	}

	new_expr ();
	CALL (VOID);
	   ICON (0, PF_INT, __DC_CHECK);
	   desc_const (x);
	
	dat_alloc (x, g_REC_vdsize (ftp));
}


/*
 *	Create a call block descriptor
 */
static
void	cb_desc (x)
ac	x;
{
	int	i,
		offs,
		numofconstr;
	ac	cx,
		ftp;

	ASSERT (x != NULL, ("cb_desc:0"));

	cx = g_parenttype (x);
	ASSERT (cx != NULL && g_d (cx) == XFILTER, ("cb_desc:1"));

	ftp = root_type (x);
	numofconstr = getnform (ftp);

	move (NULL, CB, x, CB_DTAG);
	move (ftp, 0, x, CB_TTP);
	move (NULL, g_FLT_vdoffset (cx), x, CB_VDOFF);

	offs = CB_ACT;
	for (i = 1; i <= numofconstr; i++) {
	   move (NULL, is_discdep (cx, i) ?
					CB_PARPAR : CB_VALUE, x, offs);
	   move (cx, i, x, offs + TAG_CB_SIZE);
	   offs += CB_ACT_SIZE;
	}

	/* the computations will be initiated elsewhere */
	dat_alloc (x, offs);
}

/*
 *	Generate a descriptor for an access type
 */
void	acc_desc (x)
ac	x;
{
	int	offs,
		i;

	ASSERT (x != 0 && g_d (x) == XACCTYPE, ("acc_desc:0"));

	alloc_desc (x);
	move (NULL, TD_ACC, x, TT_ACC_DTAG);
	move (NULL, g_ACC_nform (x), x, TT_ACC_NFORM);

	offs = TT_ACC_CDP;
	for (i = 1; i <= g_ACC_nform (x); i ++) {
	   move (discrdescnode (g_actype (x), i), 0, x, offs);
	   offs += CDP_TT_ACC_SIZE;
	}
}

/*
 *	accesssubtype descriptor
 */
static
void	accv_desc (x)
ac	x;
{
	int	offs,
		numofconstr,
		i;
	ac	cx,
		ftp;

	ASSERT (x != NULL && g_d (x) == XSUBTYPE, ("accv_desc:0"));

	cx = g_parenttype (x);
	ASSERT (cx != NULL && g_d (cx) == XFILTER, ("accv_desc:1"));

	ftp = root_type (x);
	numofconstr = getnform (ftp);

	move (NULL, CD_ACC, x, LD_ACC_DTAG);
	move (ftp, 0, x, LD_ACC_TTP);

	offs = LD_ACC_CONS;
	for (i = 1; i <= numofconstr; i++) {
	   move (cx, i, x, offs);
	   offs += CONS_LD_ACC_SIZE;
	}

	new_expr ();
	CALL (VOID);
	   ICON (0, PF_INT, __AC_CHECK);
	   desc_const (x);

	dat_alloc (x, offs);
}

/*
 *	Create a descriptor for a simple (?) range
 */
static
void	range_desc (x)
ac	x;
{
	int	offs;
	ac	cx,
		ftp;

	ASSERT (x != NULL && g_d (x) == XSUBTYPE, ("range_desc:0"));

	cx = g_parenttype (x);
	ASSERT (cx != NULL && g_d (cx) == XFILTER, ("range_desc:1"));

	ftp = g_filtype (cx);
	move (NULL, is_basetype (ftp) ? CD_BIT_H : CD_BIT_S, x, LD_BIT_DTAG);
	move (NULL, obj_size (ftp), x, LD_BIT_BITIND);
	move (cx, 1, x, LD_BIT_LO);
	move (cx, 2, x, LD_BIT_HI);

	dat_alloc (x, LD_BIT_HI + TLONGSIZE);

	if (check_needed (x, ftp)) {
	   new_expr ();
	   CALL (VOID);
	      ICON (0, PF_INT, __RC_CHECK);
	      PARCOM ();
	         desc_const (x);
	         desc_const (ftp);
	   }
}

/*
 *	Create a descriptor for a subtype
 */
void	sub_desc (x)
ac	x;
{
	ASSERT (x != NULL && g_d (x) == XSUBTYPE, ("sub_desc"));

	if (g_d (g_parenttype (x)) != XFILTER)
	   return;

	alloc_desc (x);

	switch (filkind (g_parenttype (x))) {
	   case CD_BIT_S:
		range_desc (x, g_parenttype (x));
		return;

	   case VD_ARR:
		arrv_desc (x);
		return;

	   case CD_ACC:
		accv_desc (x, g_parenttype (x));
		return;

	   case CB:
		cb_desc (x, g_parenttype (x));
		return;

	   case VD_REC:
		recv_desc (x, g_parenttype (x));
		return;
	}
}

