
/*
 * (c) copyright 1986, 1987, 1988, Delft University of Technology
 * Delft, The Netherlands
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 *	For further information contact
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 *	Translation of functions from package standard
 *	i.e. + in 3 + 4, should be as much as possible
 *	in-line. There are functions for which this
 *	is rather hard, e.g. A < B where A and B are
 *	structured values (arrays). In those cases
 *	we call a C function doing the job for us.
 *	Standard rules select between the implementations
 *	Some functions are implemented in terms of Ada functions,
 *	e.g. "&" and abs. The table is characterized here
 *	by "0" entries
 *
 *	(Pointers to) big parameters have been stored in a temp
 *	by pre_code.
 *
 *	procedures that are
 *	- C functions,
 *	- procedures on level 1
 *	- implementations of standard operators
 *	are called slightly different from the	rest (if any). No static link is
 *	pushed	a simple check is called "is_lev_one"
 */
#include	"includes.h"
/*
 *	Forward (static) declarations
 */
static	void	act_descr	();
static	void	actfunpars	();
static	void	act_pars	();
static	void	das_call	();
static	int	do_params	();
static	char	* get_Coper	();
static	char	* get_C_tag	();
static	void	func_name	();
static	bool	is_in_C	();
static	bool	need_desc	();
static	int	push_descriptors	();
static	void	simp_call	();

#define	has_monop(x)	(stdcodes [get_std_fun (x)]. monad != 0)
#define	has_dyop(x)	(stdcodes [get_std_fun (x)]. dyad  != 0)

/*
 *	In-line expansion table:
 *	This table contains information to be used in inline
 *	expansion of function calls.
 */
struct stdcodes {
	int f_code;		/* function code involved    */
	char *dyad,*monad;	/* inline codes if available */
	char *Cstring;		/* implementing C function   */
	char *CPstring;		/* prefix of C function name	*/
} stdcodes [] =
{
	0,	NULL,	NULL,	NULL,	NULL,	
	O_EQ,	"==",	NULL,	__EQUAL,	NULL,
	O_LESS,	"<",	NULL,	__LESS,	NULL,
	O_GR,	">",	NULL,	__GR,	NULL,
	O_LE,	"<=",	NULL,	__LE,	NULL,
	O_GE,	">=",	NULL,	__GE,	NULL,
	O_PLUS,	"+",	"+",	NULL,	NULL,
	O_MIN,	"-",	"-",	NULL,	NULL,
	O_MUL,	"*",	NULL,	NULL,	NULL,
	O_DIV,	"/",	NULL,	NULL,	NULL,
	O_MOD,	NULL,	NULL,	NULL,	"__mod",
	O_REM,	"%",	NULL,	NULL,	NULL,
	O_CAT,	NULL,	NULL,	NULL,	"__cat",
	O_NOT,	NULL,	"!",	__NOT,	NULL,
	O_POW,	NULL,	NULL,	NULL,	"__pow",
	O_AND,	"&",	NULL,	__AND,	NULL,
	O_OR,	"|",	NULL,	__OR,	NULL,
	O_XOR,	"xor",	NULL,	__XOR,	NULL,
	O_ABS,	NULL,	NULL,	NULL,	"__abs",
	O_FREE,	NULL,	NULL,	_AL_FREE,	NULL
};

#define	MONADIC	0
#define	DYADIC	1


/*
 * Name:	as_Ccall
 *
 * Abstract:	
 *
 * Description:	 is the function call, identified through node
 *		 to be implemented as a straightforward C call
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

bool	as_Ccall (node)
ac node;
{
	ac ass;
	ac type = g_types (node);

	if (type != notype)
	   return is_small (type);

	for (ass = g_fact (node); ass != NULL; ass = g_next (ass))
	    if (is_small (g_nexp (ass)) &&
	        g_flags (g_desc (g_parname (ass))) != INMODE)
	       return FALSE;

	return TRUE;
}

/*
 * Name:	Get_Ccode
 *
 * Abstract:	
 *
 * Description:	 Map the function fn, with adicity adic onto
 *		 the intermediate operator implementing it
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

char	*Get_Ccode (ac   fn,
                    int  adic)
{
	ASSERT (fn != NULL, ("Get_Ccode"));
	ASSERT (g_d (fn) == XSUB, ("Get_Ccode:2"));
	return adic == MONADIC ?
			stdcodes [get_std_fun (fn)]. monad :
			stdcodes [get_std_fun (fn)]. dyad ;
}

/*
 * Name:	act_descr
 *
 * Abstract:	
 *
 * Description:	 generate access code for the descriptors
 *		 of those parameters that need one
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
void	act_descr (p)
ac p;
{
	if (p == NULL)
	   return;

	act_descr (g_next (p));
	if (need_desc (p))
	   DESCRIPTOR (g_nexp (p));
}

/*
 * Name:	actfunpars
 *
 * Abstract:	
 *
 * Description:	 generate code for the parameters (mapped upon
 *		 intermediate C code)
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
void	actfunpars (parlist)
ac	parlist;
{
	ac	ass;
	int	i,
		com_cnt = 0;

	if (parlist == NULL)
	   return;

	FORALL (ass, parlist) {
	   if (need_desc (ass))
	      com_cnt ++;

	   com_cnt ++;
	}

	for (i = 1; i < com_cnt; i ++)
	    PARCOM ();

	act_pars (parlist);
	act_descr (parlist);
}

/*
 * Name:	actpars
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
void	act_pars (p)
ac	p;
{
	if (p == NULL)
	   return;

	act_pars (g_next (p));

	if (is_small (g_nexp (p))) {
	   if (is_scalar (g_types (g_nexp (p))))
	      SCONV (LONG);
	   sm_ch_code (get_type (g_parname (p)), g_nexp (p), NOTYPE);
	}
	else
	   parcheck_code (get_type (g_parname (p)), g_nexp (p), NOTYPE);
}

/*
 * Name:	das_call
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
void	das_call (op)
ac	op;
{
	ac	sub;

	ASSERT (op != NULL && g_d (op) == XCALL, ("das_call:1"));

	sub = g_fentity (g_next (op));

	CALL (pcc_type_of (g_types (op)));
	   func_name (op);
	   if (g_fact (op) != NULL) {
	      PARCOM ();
	         get_stlink (curr_level - level_of (sub),ADDRESS);
		 actfunpars (g_fact (op));
	   }
	   else
	      get_stlink (curr_level - level_of (sub),ADDRESS);
}

/*
 * Name:	do_Ccall
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

void	do_Ccall (op)
ac	op;
{
	ac	sub;

	ASSERT (op != NULL, ("do_Ccall:1"));
	ASSERT (g_d (op) == XCALL, ("do_Ccall:2"));

	sub = g_fentity (g_next (op));

	ASSERT (sub != NULL && g_d (sub) == XSUB, ("do_Ccall:3"));

	if (is_lev_one (sub))
	    simp_call (op);
	else
	    das_call (op);
}

/*
 * Name:	do_params
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
int	do_params (actlist, node, i)
ac	actlist,
	node;
int	i;
{
	ac	e;
	char	par_flags;
	bool	is_scal;
	int	type;
	ac	sub;
	int	off_set;
	bool	is_func;
	short	val_size = 0;

	ASSERT (node != NULL, ("do_params:1"));
	ASSERT (g_d (node) == XCALL, ("do_params:2"));

	sub = g_fentity (g_next (node));
	ASSERT (g_d (sub) == XSUB, ("do_params:3"));

	is_func = g_types (node) != notype;

	if (actlist == NULL) {	/* no actuals left	*/
	   if (!is_lev_one (sub)) {
	      COMMA ();
	      val_size = push (TRUE, ADDRESS);
	      get_stlink (curr_level - level_of (sub), ADDRESS);
	   }

	   if (is_func)
	      UCALL (ADDRESS);
	   else
	   {  COMMA ();
	      UCALL (VOID);
	   }

	   func_name (node);
	   return val_size;
	}

	e = g_nexp (actlist);
	par_flags = g_flags (g_desc (g_parname (actlist)));
	is_scal   = is_small (e);
	type 	  = pcc_type_of (e);

	if (is_scal) {
	   if (par_flags == OUTMODE) {
	      COMMA ();
	      val_size = push (FALSE, type);
	   }
	   else
	   {  COMMA ();
	      val_size = push (TRUE, type);
	      sm_ch_code (g_parname (actlist), e, type);
	   }
	}
	else
	{   COMMA ();
	    val_size = push (TRUE, ADDRESS);
	    parcheck_code (g_parname (actlist), e, type);
	}

	off_set = do_params (g_next (actlist), node, i - 1);

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

	/*
	 * recall that both off_set and val_size are in units
	 * of bytes
	 */
	return off_set + val_size;
}

/*
 * Name:	do_CAT
 *
 *	generate a name for a CAT function
 */
#define	is_char(x)	(g_d (x) == XENUMTYPE)
/*
static
*/
char	*do_CAT (node, v)
ac	node;
char	*v;
{
	ac	fparam,
		sparam;

	fparam = g_nexp (g_next (g_fact (node)));
	sparam = g_nexp (g_fact (node));

	if (is_char (g_types (fparam)) &&
	    is_char (g_types (sparam)) )
	   sprintf (v, "__catcc");
	else
	if (is_char (g_types (fparam)))
	   sprintf (v, "__catcs");
	else
	if (is_char (g_types (sparam)))
	   sprintf (v, "__catsc");
	else
	   sprintf (v, "__catss");

	return v;
}

/*
 * Name:	func_name
 *
 * Abstract:	
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	NOTYPE meaning a unset type environment
 *		for code generation.
 *
 */
static
char	* get_Coper (node, v)
ac	node;
char	v [];
{
	ac	sub,
		rettype;

	sub = g_fentity (g_next (node));
	rettype = g_types (node);
	ASSERT (sub != NULL && g_d (sub) == XSUB, ("get_Coper"));

	if (get_std_fun (sub) == O_CAT) {	/* special case */
	   return do_CAT (node, v);
	}

	rettype = root_type (rettype);
	if (rettype == std_short)
	   sprintf (v, "%s%s", stdcodes [get_std_fun (sub)]. CPstring, "s");
	else
	if (rettype == std_integer)
	   sprintf (v, "%s%s", stdcodes [get_std_fun (sub)]. CPstring, "i");
	else
	if (rettype == std_long || rettype == std_univ)
	   sprintf (v, "%s%s", stdcodes [get_std_fun (sub)]. CPstring, "l");
	else
	if (rettype == std_real)
	   sprintf (v, "%s%s", stdcodes [get_std_fun (sub)]. CPstring, "f");
	else
	   sprintf (v, "%s", stdcodes [get_std_fun (sub)]. Cstring);
	
	return v;
}

static
char	* get_C_tag (sub, s)
ac	sub;
char	*s;
{
	char	*t;

	sprintf (s, "_%s", g_tag (sub));

	t = s;
	while (*t != 0) {
	   if ('A' <= *t && *t <= 'Z')
	      *t = *t - 'A' + 'a';
	   t ++;
	}

	return s;
}

static
void	func_name (node)
ac	node;
{
	ac	sub;
	static char v [AIDL];	/* generated function name */

	sub = g_fentity (g_next (node));

	ASSERT (sub != NULL, ("func_name:1"));
	ASSERT (g_d (sub) == XSUB, ("func_name:2"));

	if (is_in_C (sub))
	   ICON (0, ADDRESS, get_Coper (node, v));
	else
	if (is_dollarname (g_tag (sub)))
	   TEXTLABCON (sub);
	else
	if (is_as_C (sub))
	   ICON (0, ADDRESS, get_C_tag (sub, v));
	else
	if (is_lev_one (sub))
	   TEXTLABCON (sub);
	else
	   code (sub, VAL, NOTYPE);
}

/*
 * Name:	hard_call
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

void	hard_call (callnode)
ac callnode;
{
	int	i = 0;
	short	n = 0;
	bool	is_func;
	int	nbytes;

	ASSERT (callnode != NULL && g_d (callnode) == XCALL, ("hardcall"));

	is_func = g_types (callnode) != notype;
/*
 *	stack the desciptor of the return type here
 */
	if (is_func) {
	   COMMA ();
	   n += push (TRUE, ADDRESS);
	   elemdesc (callnode, REF);
	   
	   s_flags (g_next (callnode), g_flags (g_next (callnode)) | LARG_EVAL);
	}

	n += push_descriptors (g_fact (callnode));

	nbytes = do_params (g_fact (callnode), callnode, i);
	if (!is_func) {
	   pop (nbytes + n);
	}
	/* return value is void */
}

/*
 * Name:	is_in_C
 *
 * Abstract:	
 *
 * Description:	
 *
 *	A tricky routine to be able to call
 *	"simple" C routines for the implementation
 *	of operations from package standard
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
bool	is_in_C (f)
ac f;
{
	struct stdcodes * x;

	ASSERT (f != NULL, ("is_in_C"));
	ASSERT (g_d (f) == XSUB, ("is_in_C:2"));

	if (is_std_fn (f) && lun_of (f) == STAN_LUN) {
	   x = &stdcodes [get_std_fun (f)];
	   if (x -> Cstring != NULL || x -> CPstring != NULL)
	      return TRUE;
	}
	return FALSE;
}

/*
 * Name:	need_desc
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
bool	need_desc (x)
ac	x;
{
	ac	form,
		acttype;

	form = basefilter (g_objtype (g_desc (g_parname (x))));
	acttype = root_type (g_exptype (g_nexp (x)));
	if (unco_value (form) ||
	   (is_composite (acttype) && g_d (form) == XINTERNAL))
	   return TRUE;
	return FALSE;
}

/*
 * Name:	push_descriptors
 *
 * Abstract:	
 *
 * Description:	
 *
 *	Very strange, the actuals are reversed here, since
 *	the front likes it that way. The parameters
 *	themselves ought to be, however the
 *	descriptors also
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

static
int	push_descriptors (act_list)
ac act_list;
{
	int n = 0;

	if (act_list == NULL)
	   return 0;

	if (need_desc (act_list)) {
	   COMMA ();
	       n += push (TRUE, ADDRESS);
	       DESCRIPTOR (g_nexp (act_list));
	 }

	 return n + push_descriptors (g_next (act_list));
}

/*
 * Name:	simp_call
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
void	simp_call (op)
ac op;
{
	if (g_fact (op) == NULL)
	   UCALL (pcc_type_of (g_types (op)));
	else
	   CALL (pcc_type_of (g_types (op)));

	func_name (op);
	actfunpars (g_fact (op));
}
