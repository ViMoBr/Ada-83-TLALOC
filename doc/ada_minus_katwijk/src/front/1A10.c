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

#define	LOC_SIZE	20
static char loc_str [LOC_SIZE];

#define	is_char(x)	(g_d (x) == XNAME && g_d (g_fentity (x)) == XCHARLIT)


/*
 *	try to compute a given call
 *
 *	stuff for the compile time evaluation of
 *	functions from standard
 */
#define	Ser	0
#define	S1	1
#define	S2	2
#define	S3	3
#define	S4	4
#define	S5	5
#define	S6	6
#define	S7	7
/*
 *	the numbers above describe scenarios for the
 *	evaluation of function classes
 *
 *	Which scenarion to select is determined through
 *	the next table
 */

struct scen_struct {
	byte oper_no;
	byte s_int, s_flt, s_enumt, s_stringt;
} scenario[] =
{
	O_PLUS,	S1,	S2,	Ser,	Ser,
	O_MIN,	S1,	S2,	Ser,	Ser,
	O_MUL,	S1,	S2,	Ser,	Ser,
	O_DIV,	S1,	S2,	Ser,	Ser,
	O_REM,	S1,	S2,	Ser,	Ser,
	O_MOD,	S1,	S2,	Ser,	Ser,
	O_POW,	S1,	S2,	Ser,	Ser,
	O_EQ,	S3,	S4,	S3,	Ser,
	O_LESS,	S3,	S4,	S3,	Ser,
	O_GR,	S3,	S4,	S3,	Ser,
	O_LE,	S3,	S4,	S3,	Ser,
	O_GE,	S3,	S4,	S3,	Ser,
	O_AND,	S1,	Ser,	S5,	Ser,
	O_OR,	S1,	Ser,	S5,	Ser,
	O_XOR,	S1,	Ser,	S5,	Ser,
	O_CAT,	Ser,	Ser,	S6,	S7,
	0,	Ser,	Ser,	Ser
};

/*
 *	Static (forward) declarations:
 */
static	bool	in_r	();
static	ac	integerbase	();
static	ac	get_enumlit	();
static	bool	is_monadic	();
static	bool	is_standard	();
static	bool	const_pars	();
static	struct scen_struct * look_scen	();
static	ac	mon_op		();
static	int	f_param		();
static	ac	gf_param	();
static	int	s_param		();
static	ac	gs_param	();
static	ac	scen1		();
static	ac	scen3		();
static	ac	scen5		();
static	ac	scen6		();
static	ac	scen7		();
static	ac	realfun		();
static	ac	try_arraymisery	();
static	ac	constraint	();
static	ac	i_th_index	();
static	bool	is_false	();
static	bool	is_true		();

/*
 *	Check whether or not the value val fits within the
 *	range of values indicated by the type_mark
 */
static
bool	in_r (type_mark, val)
ac	type_mark;
long	val;
{
	ASSERT (type_mark != NULL, ("in_r:1"));

	type_mark = stat_range (type_mark);

	if (type_mark == NULL)
	   return FALSE;

	return small_val (type_mark) <= val && val <= larg_val (type_mark);
}

/*
 *	Get the smallest integer from the range s
 */
ac	smallest_int (s)
ac	s;
{
	int	lv,
		hv;

	ASSERT (g_d (s) == XRANGE, ("smallest_int"));

	if (!is_static (s))
	   return std_univ;

	lv = small_val (s);
	hv = larg_val  (s);

	if (in_r (std_short, lv) && in_r (std_short, hv))
	   return std_short;

	if (in_r (std_integer, lv) && in_r (std_integer, hv))
	   return std_integer;

	/* hardly any option but:		*/
	return std_long;
}

long	low_int (x)
ac	x;
{
	if (x == std_short)
	   return (char)-127;
	else
	if (x == std_integer)
	   return (short)-32767;
	else
	if (g_d (x) == XNEWTYPE)
	   return low_int (stat_range (g_old_type (x)));
	else
	   return (long)-2147483648;
}

long	high_int (x)
ac	x;
{
	if (x == std_short)
	   return 127;
	else
	if (x == std_integer)
	   return (short) 32767;
	else
	if (g_d (x) == XNEWTYPE)
	   return high_int (stat_range (g_old_type (x)));
	else
	   return (long)2147483647;
}

static
ac	integerbase (x)
ac	x;
{
	if (x == NULL)
	   return std_integer;

	if (x == std_short ||
	    x == std_integer ||
	    x == std_long)
	   return x;

	if (x == std_univ)
	   return std_long;

	if (g_d (x) == XNEWTYPE)
	   return integerbase (g_old_type (x));

	return NULL;
}


/*
 *	Convert a character literal from the ASCII domain
 *	to the domain where it belongs, i.e. the
 *	domain of the corresponding type definition
 */
char	valofchar (basetype, search_char)
ac	basetype;
char	search_char;
{
	ac	t;

	if (basetype == NULL)	/* should not happen but alas */
	   return search_char;

	if (search_char == EOS)	/* can happen, C # DAS */
	   return EOS;

	ASSERT (g_d (basetype) == XENUMTYPE, ("valofchar: no enumtype"));

	FORALL (t, g_fenumlit (basetype)) {
	   if (g_tag (t) [0] == search_char
	       && g_tag (t) [1] == '\0')
	      return (char) g_enuml_ord (t);
	}

	error ("can't find character %o", search_char);
	return search_char;
}

static
ac	get_enumlit (e_type, cnt)
ac	e_type;
int	cnt;
{
	ac	e_lit;

	ASSERT (g_d (e_type) == XENUMTYPE, ("get_enumlit: %d\n",
					         g_d (e_type)) );

	e_lit = g_fenumlit (e_type);
	for (; --cnt >= 0; ) {
	  if (e_lit == NULL) {
	     error ("range error in %s", g_tag (e_type));
	     return g_fenumlit (e_type);
	  }

	  e_lit = g_next (e_lit);
	}

	return e_lit;
}

ac	cp_value (x, y)
int	x;
ac	y;
{
	ac	z,
		t,
		b = base_type (y);

	if (is_someinteger (b)) {
	   z = nalloc (XLITERAL);
	   s_littype (z, y);
	   sprintf (loc_str, "%d", x);
	   s_val (z, alloc_lit (S_INTLIT, loc_str, LOC_SIZE));
	   return z;
	 }

	if (is_entype (b)) {
	   t = mk_applied (get_enumlit (b, x));
	   set_static (t);
	   return t;
	}

	ASSERT (FALSE, ("cp_value %d\n", g_d (b)));
}

/*
 *	some routines for handling static expressions
 *	and verification of selection domains
 */

ac	stat_range (x)
ac	x;
{
	int	d;

	while (TRUE) {
	   if (x == NULL)
	      return NULL;

	   d = g_d (x);

	   PRINTF (printf ("in stat_range %d, %s\n", d, g_tag (x)));

	   ASSERT (is_scalar (x), ("attempt to compute stat range %d", g_d (x)));

	   if (d == XFILTER)
	      if (is_sttype (x))
	         return g_constraint (x);
	      else
	         return base_type (g_filtype (x));

	   if (d == XSUBTYPE)
	      x = g_parenttype (x);
	   else
	   if (d == XENUMTYPE)
	      return (x);
	   else
	   if (d == XNEWTYPE)
	      x = g_old_type (x);
	   else
	   if (is_someinteger (x))
	      return x;
	   else
	      x = base_type (x);
	}
}

/*
 *	ord of an enumeration literal or a numer literal
 *
 *	Note that an enumeration literal is represented
 *	as a pointer to the definition, while a numer
 *	is represented by a literal record
 */
long	ord (x)
ac	x;
{
	ac	y;

	if (g_d (x) == XENUMLIT || g_d (x) == XCHARLIT)
	   return (long) g_enuml_ord (x);

	if (g_d (x) == XLITERAL)
	   return (long) atoi (g_val (x) -> litvalue);

	if (g_d (x) == XNAME)
	   return ord (g_fentity (x));

	ASSERT (FALSE, ("illegal call to ord %d", g_d (x)));
}

/*
 *	get the smallest (largest) value in a range
 *	converted to a long integer
 */
int	small_val (x)
ac	x;
{
	while (TRUE) {
	   switch (g_d (x)) {
	      case XNEWTYPE:
	         x = g_old_type (x);
	         break;

	      case XSUBTYPE:
	         x = stat_range (x);
	         break;

	      case XFILTER:
	         x = g_constraint (x);
	         break;

	      case XENUMTYPE:
	         return 0;

	      case XINTERNAL:
	         if (x == std_short || x == std_integer || x == std_long)
		    return low_int (x);

	         if (x == std_univ)
		    return low_int (x);
	         ASSERT (FALSE, ("Help"));

	      case XRANGE:
	         if (g_frang_exp (x) == NULL) {
		    x = stat_range (g_rangetype (x));
	            break;
	         }
	         else
	         {  ASSERT (is_sttype (x), ("loval:"));
	            return  ord (g_primary (g_frang_exp (x)));
	         }

	      DEFAULT (("small_val:1"));
	   }
	}
}

int	larg_val (x)
ac	x;
{
	ac	tmp1,
		tmp2;

	while (TRUE) {
	   switch (g_d (x)) {
	      case XNEWTYPE:
		 x = g_old_type (x);
	         break;

	      case XSUBTYPE:
		 x = stat_range (x);
	         break;

	      case XFILTER:
		 x = g_constraint (x);
	         break;

 	      case XENUMTYPE:
		return g_nenums (x) - 1;

	      case XINTERNAL:
		 if (x == std_short || x == std_integer || x == std_long)
		    return high_int (x);

		 if (x == std_univ)
		    return high_int (x);
		 ASSERT (FALSE, ("Help"));

	      case XRANGE:
		 ASSERT (is_sttype (x), ("Hival:"));
		 tmp1 = g_frang_exp (x);
		 tmp2 = g_rangetype (x);
		 if (tmp1 == NULL)
		   x = stat_range (tmp2);
	         else
		 if (g_next (tmp1) != NULL)
		   return ord (g_primary (g_next (tmp1)));
		 else
		   return ord (g_primary (tmp1));

	         break;

	      DEFAULT (("larg_val:1"));
	   }
	}
}

bool	in_range (type_mark, primary)
ac	type_mark,
	primary;
{
	if (type_mark == NULL)
	   return FALSE;

	return in_r (type_mark, ord (primary));
}


static
bool	is_monadic (x)
ac	x;
{
	return g_next (f_formal (x)) == NULL;
}

static
bool	is_standard (x)
ac	x;	/* is x a compile-time executable ? */
{
	short	lun;

	lun = lun_of (x);
	return (lun == 1 || lun == 2);
}

static
bool	const_pars (x)
ac	x;
{
	ac	y;

	for (; x != NULL; x = g_next (x)) {
	   y = g_nexp (x);
	   if (y == NULL)
	      return FALSE;

	   if (is_static (y))
	      continue;

	   if (g_primary (y) == NULL)	/* shouldnt happen though */
	      return FALSE;

	   if (is_stringlit (g_primary (y)))
	      continue;

	   return FALSE;
	}

	return TRUE;
}

static
struct scen_struct * look_scen (x)
byte	x;
{
	int	i = 0;
	struct scen_struct *t;

	while ((t = &scenario [i]) && t -> oper_no != (byte)0) {
	   if (t -> oper_no == x)
	      return t;

	   i++;
	}

	return NULL;
}

static
ac	mon_op (x, sub)
ac	x;
ac	sub;
{
	int	op_value;
	ac	actprimary,	/* primary appearing as actual		*/
		restype,	/* result type			*/
		fact;

	if (x == NULL)
	   return NULL;

	ASSERT (g_d (x) == XCALL, ("mon_op"));

	restype = g_types (x);
	fact = g_fact (x);

	if (fact == NULL)
	   return x;

	if (g_nexp (fact) == NULL)
	   return x;

	actprimary = g_primary (g_nexp (fact));

	if (get_std_fun (sub) == O_PLUS)
	   return actprimary;

	if (!const_pars (fact))
	   return x;

	op_value = ord (actprimary);
	switch (get_std_fun (sub)) {
	   case O_ABS:
	      op_value = op_value < 0? -op_value: op_value;
	      break;

	   case O_MIN:
	      op_value = -op_value;
	      break;

	   case O_PLUS:
	      break;

	   case O_NOT:
	      op_value = 1 - op_value;
	      break;

	   DEFAULT (("Illegal call to mon_op"));
	}

	return cp_value (op_value, restype);
}


/*
 *	be careful:
 *	This routine KNOWS that the actual parameters
 *	are in reverse order.
 */
static
int	f_param (x)
ac	x;
{
	ASSERT (x != NULL && g_next (x) != NULL, ("f_param:1"));

	return ord (g_primary (g_nexp (g_next (x))));
}

static
ac	gf_param (x)
ac	x;
{
	return g_primary (g_nexp (g_next (x)));
}


static
int	s_param (x)
ac	x;
{
	ASSERT (x != NULL, ("s_papram:1"));

	return ord (g_primary (g_nexp (x)));
}

static
ac	gs_param (x)
ac	x;
{
	return g_primary (g_nexp (x));
}

/*
 *	Operators over numbers
 */
static
ac	scen1 (params, op, restype)
ac	params;
int	op;
ac	restype;
{
	int	lop,
		rop,
		t3;

	lop = f_param (params);
	rop = s_param (params);

	switch (op) {
	   case O_PLUS:
		t3 = lop + rop;
		break;

	   case O_MIN:
		t3 = lop - rop;
		break;

	   case O_MUL:
		t3 = lop * rop;
		break;

	   case O_DIV:
		if (rop == 0) {
		   error ("division by zero");
		   t3 = 0;
	    	   break;
		}
		t3 = lop / rop;
		break;

	   case O_REM:
		if (rop == 0) {
		   error ("division by zero");
		   t3 = 0;
		   break;
		}
		t3 = lop % rop;
		break;

	   case O_MOD:
		if (rop == 0) {
		   error ("zero modulus");
		   t3 = 0;
		   break;
		}
		if (lop == 0) {
		   t3 = 0;
		   break;
		}
		t3 = lop % rop;
		if ((t3 < 0) != (rop < 0))
		   t3 += rop;
		break;

	   case O_POW:
		if (rop == 0) {
		   t3 = 1;
		   break;
		}
		for (t3 = lop; --rop != 0;)
		   t3 *= lop;
		break;

	   case O_AND:
		t3 = lop & rop;
		break;

	   case O_OR:
		t3 = lop | rop;
		break;

	   case O_XOR:
		t3 = (lop & rop) | (lop & ~rop);
		break;

	   default:
		t3 = 0;
		error ("operator not yet implemented");
	}

	return cp_value (t3, restype);
}

/*
 *	relational operators over scalars
 */
static
ac	scen3 (params, op)
ac	params;
int	op;
{
	bool	t3;
	int	lop,
		rop;
	ac	r;

	lop = f_param (params);
	rop = s_param (params);

	switch (op) {
	   case O_EQ:
		t3 = lop == rop;
		break;

	   case O_GR:
		t3 = lop > rop;
		break;

	   case O_LESS:
		t3 = lop < rop;
		break;

	   case O_GE:
		t3 = lop >= rop;
		break;

	   case O_LE:
		t3 = lop <= rop;
	        break;

	   default:
		t3 = FALSE;
		error ("unimplemented S3 operator");
	}

	if (t3)
	   r = mk_applied (std_true);
	else
	  r = mk_applied (std_false);

	s_types (r, std_boolean);
	return r;
}

/*
 *	Operators over boolean values
 */
static
ac	scen5 (params, op)
ac	params;
int	op;
{
	ac	r;
	bool	lop,
		rop;

	lop = f_param (params) == 1;
	rop = s_param (params) == 1;

	switch (op) {
	   case O_AND:
		lop = lop & rop;
		break;

	   case O_OR:
		lop = lop | rop;
		break;

	   case O_XOR:
		lop = lop ^ rop;
		break;

	   default:
		lop = FALSE;	/* cannot happen */
	}

	r = mk_applied (lop ? std_true : std_false);
	s_types (r, std_boolean);
	return r;
}

static
ac	scen6 (params, op, type)
ac	params;
int	op;
ac	type;
{
	static char hulp [3];

	ASSERT (params != NULL, ("scen6:1"));
	ASSERT (op = O_CAT, ("scen6:2"));

	hulp [0] = g_tag (g_fentity (gf_param (params))) [0];
	hulp [1] = g_tag (g_fentity (gs_param (params))) [0];
	hulp [2] = 0;

	return mk_literal (alloc_lit (S_STRINGLIT, hulp, 3), type);
}

static
ac	new_stringlit (s1, s2, n)
char	*s1,
	*s2;
int	n;
{
	int	i;
	char	*p,
		hulp [100];

	p = hulp;
	while (*s1 != 0)
	   *p ++ = *s1 ++;

	while (*s2 != 0)
	   *p ++ = *s2 ++;

	*p = 0;

	return alloc_lit (S_STRINGLIT, hulp, n);
}

static
ac	scen7 (params, op, type)
ac	params;
int	op;
ac	type;
{
	ac	left,
		right;

	ASSERT (params != NULL, ("scen7:1"));
	ASSERT (op = O_CAT, ("scen7:2"));

	left = gf_param (params);
	right = gs_param (params);

	ASSERT (g_d (left) == XLITERAL && g_d (right) == XLITERAL, ("xxx"));
	
	return mk_literal (new_stringlit (g_val (left)  -> litvalue,
	                                  g_val (right) -> litvalue,
	                                  g_val (left)  -> n +
	                                  g_val (right) -> n + 1), type);
}

static
ac	scen8 (params, op, type)
ac	params;
int	op;
ac	type;
{
	ac	right;
	int	left;
	char	hulp [2];

	left = g_tag (g_fentity (gf_param (params))) [0];
	right = gs_param (params);

	hulp [0] = (char)left;
	hulp [1] = 0;

	return mk_literal (new_stringlit (hulp,
	                                  g_val (right) -> litvalue,
	                                  g_val (right) -> n + 1 + 1), type);
}

static
ac	scen9 (params, op, type)
ac	params;
int	op;
{
	ac	left;
	int	right;
	char	hulp [2];

	left = gf_param (params);
	right = g_tag (g_fentity (gs_param (params))) [0];

	hulp [0] = (char)right;
	hulp [1] = 0;

	return mk_literal (new_stringlit (g_val (left) -> litvalue,
	                                  hulp,
	                                  g_val (left) -> n + 1 + 1), type);
}

/*
 *	distinguish between four cases:
 *	char & char
 *	string & string
 *	char & string
 *	string & char
 */
ac	do_stringlit (params, type)
ac	params;
{
	ac	left,
		right;

	left = gf_param (params);
	right= gs_param (params);

	if (is_char (left) && is_char (right))
	   return scen6 (params, O_CAT, type);

	if (is_stringlit (left) && is_stringlit (right))
	   return scen7 (params, O_CAT, type);

	if (is_char (left) && is_stringlit (right))
	   return scen8 (params, O_CAT, type);

	if (is_char (right) && is_stringlit (left))
	   return scen9 (params, O_CAT, type);

	ASSERT (FALSE, ("do-stringlit: wat maak je me nou?"));
}

static
ac	realfun (x)
ac	x;
{
	ac	t1;

	if (x == NULL)
	   return x;

	if (g_d (x) == XRENSUB) {
	   t1 = g_subname (x);
	   if (t1 == NULL)
	      return x;

	   if (g_d (t1) != XNAME)
	      return t1;

	   return realfun (g_fentity (t1));
	}

	if (g_d (x) == XINHERIT)
	   return realfun (g_inh_oper (x));

	return x;
}

/*
 *	replace a function or procedure call by whatever
 *	to make it simpler
 *
 *	cases:
 *	-	compute the result
 *	-	replace a call to a function renaming an enumeration
 *		literal
 *	-	call to a procedure renaming an entry call
 */
ac	repl_func (x)
ac	x;
{
	ac	sub;	
	ac	t,
		tt,
		t1,
		t2,
		t3,
		actpar,
		task,
		restype;
	byte	fun_code,
		scen;
	struct scen_struct * curr_scenario;

	if (x == NULL)
	   return NULL;

	if (g_d (x) == XENTRYCALL)
	   return x;

	ASSERT (g_d (x) == XCALL, ("repl_func:1"));

	t = g_next (x);
	if (g_d (t) != XNAME)
	   return x;		/* No compiletime computation	*/

	sub = g_fentity (t);
/*
 *	types patching at name node, remove triples
 */
	if (g_d (g_types (t)) == XTRIPLE) {
	   del_tripels (g_types (t));
	   s_types (t, restypes (sub));
	}
/*
 *	Get rid of "derived" functions
 */
	if (g_d (sub) == XINHERIT) {
	   s_fentity (t, realfun (sub));
	   return repl_func (x);
	}
/*
 *	First step: replace call to a renamed enumeration literal
 */
	if (g_d (sub) == XRENSUB) {
	   tt = realfun (sub);
	   if (g_d (tt) == XENUMLIT || g_d (tt) == XCHARLIT) {
	      t = mk_applied (tt);
	      s_types (t, type_of (tt));
	      return t;
	   }
	   else
	   /* Massage a call to a renaming sub renaming an entry call	*/
	   { tt = g_subname (sub);
	     if (g_d (tt) == XSELECT && g_d (g_types (tt)) == XENTRY) {
	        task = g_enclunit (g_types (tt));
		t2 = mx_ecall (notype, g_fact (x));
	        t3 = cp_tree (g_next (tt));

		s_types (t3, task);
		s_next  (t2, t3);
		s_e_entry (t2, g_entity (tt));
	        s_call_delay (t2, mak_inf_delay ());
	        s_call_stats (t2, NULL);

		return t2;
	    }
	    else
	    /* Massage a call to an ordinary renaming sub	*/
	    {
	       ASSERT (g_d (tt) == XNAME, ("repl_func:1"));

	       s_fentity (t, realfun (sub));
	    }

	    return repl_func (x);
	  }
	}

	actpar = g_fact (x);
	fun_code = get_std_fun (sub);
	restype = g_types (x);

/*
 *	First dispatch the standard monadic operators.
 *	Take care, the integer + monadic
 *	has to disappear here since we do NOT have
 *	a suitable low level operator for it.
 *	Therefore, first monadics with any kind
 *	of operand, then the dyadics with
 *	static operands
 */

	if (!is_standard (sub))
	   return x;

	if (is_monadic (sub))
	     return mon_op (x, sub);

	if (!const_pars (actpar))
	   return x;

	curr_scenario = look_scen (fun_code);

	t = g_exptype (g_nexp (actpar));

	if (is_strtype (restype) &&  fun_code == O_CAT) {
	    return do_stringlit (actpar, restype);
	}

	if (is_someinteger (t))
	   scen = curr_scenario -> s_int;
	else
	if (is_float (t))
	   scen = curr_scenario -> s_flt;
	else
	if (is_entype (t))
	   scen = curr_scenario -> s_enumt;
	else
	  scen = Ser;

	switch (scen) {
	   case Ser:
	   default:
		fprintf (stderr, "bad luck");
		return x;

	   case S1:
		return scen1 (actpar, fun_code, restype);
		break;

	   case S2:
		return x;

	   case S3:
		return scen3 (actpar, fun_code);

	   case S5:
		return scen5 (actpar, fun_code);

	   case S6:
		return scen6 (actpar, fun_code);

	   case S7:
		return scen7 (actpar, fun_code);
	}

}

/*
 *	try to compute a given attribute
 *	if possible, replace the name construct by a static
 *	expression containing the value
 */
static
ac	try_arraymisery (node)
ac	node;
{
	ac	t,
		h,
		tt;
	int	v,
		i_value;

	ASSERT (node != NULL, ("try_array: NULL"));
	ASSERT (g_d (node) == XATTRIBUTE, ("try_arr: %d\n", g_d (node)));

	t = g_next (node);	/* left subtree		*/
	if (g_d (t) == XNAME && is_basetype (g_fentity (t))) {
	   /* we find the scalar type of which to take
	      * the first and the last already in
	      * g_types (node)
	      */
	     if (!is_sttype (g_types (node)))
		return node;

	     switch (g_attr_value (node)) {
		case A_FIRST:
		        v = small_val (g_types (node));
			break;

		case A_LAST:
		        v = larg_val (g_types (node));
			break;

		case A_LENGTH:
		        v = larg_val (g_types (node)) -
		            small_val (g_types (node)) + 1;
			break;

		/* no defaults possible */
	     }

	   }
	  else
	  {
	   /* the fentity is not a basetype, we find
	    * the constraint of the arrayobject
	    * in its (explicit or implicit) subtype
	    */

	   /*
	    * NOTE: we just discovered that it would
	    * be nice to be able to take the 'last'
	    * of an unconstrained string parameter, so:
	    */
	   if (g_d (rootfilter (g_types (t))) != XSUBTYPE)
	      if (!(g_d (rootfilter (g_types (t))) == XARRAYTYPE &&
		    g_d (t) == XSLICE))
		return node;

	   if (g_d (t) == XSLICE) {
	      tt = g_slrange (t);
	   }
	   else
	   {  i_value = g_entity (node) == NULL ? 1 :
				   ord (g_primary (g_entity (node)));

	      tt = i_th_index (g_types (t), i_value);
	   }
	   if (!is_static (tt))
	      return node;

	   switch (g_attr_value (node)) {
		case A_FIRST:
			v = small_val (tt);
			break;

		case A_LAST:
			v = larg_val  (tt) ;
			break;

		case A_LENGTH:
			v = larg_val (tt) - small_val (tt) + 1;
			break;

		/* there cannot be no default */
		}
	   }

	/* if we are here, we have to replace the
	 * name construct by a static expression
	 */
	/*
	 *		  ...  literal
	 */
	tt = g_types (node);
/*!!!*/	h = cp_value (v, tt);
	return h;
}

/*
 *	This one is called from outside
 */
ac	try_attrib (node)
ac	node;
{
	ac	h,
		h1;
	int	v;

	ASSERT (node != NULL && g_d (node) == XATTRIBUTE, ("try_attrib"));

	switch (g_attr_value (node)) {
	   case A_VAL:
	   case A_SUCC:
	   case A_PRED:
	   case A_POS:
		if (!is_static (g_entity (node)) ||
		    !is_sttype (g_types (node)) )
		   return node;

		v = ord (g_primary (g_entity (node)));

		switch (g_attr_value (node)) {
		   case A_SUCC:
			v = v + 1;
			break;

		   case A_PRED:
			v = v - 1;
			break;

		   case A_VAL:
			/* we have the value already */
			break;

		   case A_POS:
			/* we have a numerical form of the value */
			s_types (node, std_integer);
			break;
		}

		break;

	   case A_ADDRESS:
	   case A_VALUE:
	   case A_IMAGE:
	   case A_STORAGE_SIZE:
	   case A_WIDTH:	/* this is, obviously, a simplification	*/
		return node;	/* never static		*/

	   case A_SIZE:
		{ ac tt;
		tt = base_type (g_types (g_next (node)));
		if (is_entype (tt))
		   v = sizeof (char);
		else
		if (is_someinteger (tt)) {
		   tt = integerbase (tt);
	           if (tt == std_short)
		      v = sizeof (char);
		   else
		   if (tt == std_integer)
		      v = sizeof (short);
		   else
		      v = sizeof (long);
	        }
		else
		if (is_float (tt))
		   v = sizeof (double);
		else
		if (is_accesstype (tt))
		   v = sizeof (long);
		else
		   return node;
		}

	   case A_LENGTH:
	   case A_FIRST:
	   case A_LAST:
		/*
		 * We know the indextype of the arrays,
		 * however we should know the constraints
		 * so we have to compute them.
		 */

		/* Very careful:
		 */
		if (!is_scalar (g_types (g_next (node)))) {
		     /* must be the array misery */
		   return try_arraymisery (node);
		}
		/* now the simple case here:
		   just scalar
		 */
		if (!is_sttype (g_types (node)))
		   return node;

		switch (g_attr_value (node)) {
		   case A_FIRST:
			v = small_val (g_types (g_next (node)));
			break;

		   case A_LAST:
			v = larg_val (g_types (g_next (node)));
			break;

		   case A_LENGTH:
			v = larg_val  (g_types (g_next (node))) -
			    small_val (g_types (g_next (node))) + 1;
			break;

		/* there is no default here */
		}
		break;
	   DEFAULT (("Cannot happen in attr");
	}

	/* first check the value to be in the range
	 * of the parenttype
	 * If not: a runtime exception will be raised
	 * do not worry, the runtime system will do it
	 */
	if (!(small_val (g_types (g_next (node))) <= v &&
	      v <= larg_val (g_types (g_next (node)))  ))
	return node;

	/* now convert the numerical value to the
	 * value of the correct type
	 */
	h = cp_value (v, g_types (g_next (node)));
	return h;
}

static
ac	constraint (type)
ac	type;
{
 	ac	t;

	t = rootfilter (type);
	return g_d (t) == XSUBTYPE ?
		        g_constraint (g_parenttype (t)) : NULL);
}

static
ac	i_th_index (type, i)
ac	type;
int	i;
{
	ac	h;

	ASSERT (g_d (constraint (type)) == XINDEXCONS, ("i_th_index"));

	h = g_frange (constraint (type));

	while (--i > 0 && h != NULL)
	      h = g_next (h);

	if (h == NULL)
            return std_integer;	/* cannot happen */

	return h;
}

void	coerce_filter (filter, type)
ac	filter,
	type;
{
	s_filtype (filter, type);
	filter = g_constraint (filter);
	s_rangetype (filter, type);
}

static
bool	is_false (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	ASSERT (g_d (x) == XEXP, ("is_false"));

	x = g_primary (x);

	if (g_d (x) != XNAME)
	   return FALSE;

	x = g_fentity (x);
	if (x != std_false)
	   return FALSE;

	return TRUE;
}

static
bool	is_true (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	ASSERT (g_d (x) == XEXP, ("is_true"));

	x = g_primary (x);

	if (g_d (x) != XNAME)
	   return FALSE;

	x = g_fentity (x);
	if (x != std_true)
	   return FALSE;

	return TRUE;
}

ac	try_scc (x)
ac	x;
{
	ac	t1,
		t2;

	ASSERT (g_d (x) == XSCC, ("try-scc"));

	t1 = g_fsccexpr (x);
	t2 = g_next (t1);

	if (g_andthen (x)) {
	   if (is_false (t1) || is_false (t2))
	      return cp_value (0, std_boolean);
	   else
	   if (is_true (t1) && is_true (t2))
	      return cp_value (1, std_boolean);
	}
	else
	if (is_true (t1) || is_true (t2))
	   return cp_value (1, std_boolean);
	else
	if (is_false (t1) && is_false (t2))
	   return cp_value (0, std_boolean);

	return x;
}

