
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
 *	Forward (static) functions
 */
static	char	upper	();
static	bool	adic	();
static	int	eq_string	();
/*
 *	SCANNER  SUPPORT  ROUTINES
 *
 */

/*
 *	Attribute representations
 */
static
struct {
	char * string;
	int    attrval;
} attr [] =
{
	"ADDRESS",	A_ADDRESS,
	"BASE",		A_BASE,
	"FIRST",	A_FIRST,
	"IMAGE",	A_IMAGE,
	"LAST",		A_LAST,
	"LENGTH",	A_LENGTH,
	"POS",		A_POS,
	"PRED",		A_PRED,
	"SIZE",		A_SIZE,
	"SUCC",		A_SUCC,
	"VAL",		A_VAL,
	"COUNT",	A_COUNT,
	"WIDTH",	A_WIDTH,
	"VALUE",	A_VALUE,
	"TERMINATED",	A_TERMINATED,
	"CALLABLE",	A_CALLABLE,
	NULL,		0
};

/*
 *	operator table:
 */
struct stf {
	char *std_name;
	byte  fn_code;
	} op_tab [] =
{
	"=",	O_EQ,
	"<",	O_LESS,
	">",	O_GR,
	"<=",	O_LE,
	">=",	O_GE,
	"+",	O_PLUS,
	"-",	O_MIN,
	"*",	O_MUL,
	"/",	O_DIV,
	"MOD",	O_MOD,
	"REM",	O_REM,
	"&",	O_CAT,
	"NOT",	O_NOT,
	"**",	O_POW,
	"AND",	O_AND,
	"OR",	O_OR,
	"XOR",	O_XOR,
	"ABS",	O_ABS,
	NULL,	0
};

/*
 *	Monadic and dyadic operators separately:
 */
static
char	*mon_list [] = {
	"+",
	"-",
	"NOT",
	"ABS",
	NULL
};

static
char	*dyad_list [] = {
	"AND",
	"OR",
	"XOR",
	"=",
	"<",
	">",
	"<=",
	">=",
	"+",
	"-",
	"&",
	"*",
	"/",
	"MOD",
	"REM",
	"**",
	NULL
};


/*
 *	Map a character onto its uppercase equivalent
 *	depending on the value of flag f
 */
static
char	upper (x, f)
char	x;
bool	f;
{
	if (f)
	   return x;

	if ('a' <= x && x <= 'z')
	   x = x - 'a' + 'A';

	return x;
}

/*
 * string_to_tag :
 * remove quotes from an Ada string
 * and repack it in a tag. Used for converting operator denotatations
 * to ordinary identifier tags
 */
char	*string_to_tag (x)
struct literal *x;
{
	char	*t;
	int	i;

	t = (char *)l_alloc (x -> n + 1);
	for (i = 0; i < x -> n; i ++)
	    t [i] = upper ((x -> litvalue) [i], FALSE);

	t [i] = EOS;
	return t;
}

/*
 *	Create a tag with size limited to s.
 *	C-names, i.e. names with a leading $ are treated
 *	separately
 */
char	*mk_tag (v, s)
char	*v;
int	s;
{
	char	*tag;
	int	i;

	if (s > IDL)
	   s = IDL;

	tag = (char *)l_alloc (s + 1);
	for (i=0; i < s ; i++)
	    tag [i] = upper (v [i], v [0] == '$');
	tag [i] = EOS;

	return tag;
}


/*
 *	check a string x being a standard operator
 *	Return the operator encoding if found
 */
char	std_oper (x)
char	*x;
{
	int	i;

	for (i=0; op_tab [i]. std_name != NULL; i++)
	    if (eq_string (x, op_tab [i]. std_name) == 0)
	       return (op_tab [i]. fn_code);

	return 0;	/* not found		*/
}

/*
 *	Check t being a standard operator
 */
char	*chk_char (t, s)
char	*t;
char	*s;
{
	if (std_oper (t) == 0) {
	   error (s, t);
	   return "+";
	}
	return t;
}


/*
 *	check an operator being monadic
 *	check an operator being dyadic
 */
static
bool	adic (tbl, x)
char	**tbl;
ac	 x;
{
	int	i;

	for (i = 0; tbl [i] != NULL; i ++)
	    if (eq_string (g_tag (x), tbl [i]) == 0)
	      return TRUE;

	return FALSE;
}

bool	dyadic (x)
ac	x;
{
	return adic (dyad_list, x);
}

bool	monadic (x)
ac	x;
{
	return adic (mon_list, x);
}

/*
 * 	Check equality between identifier tags
 */
bool	eq_tags (a, b)
char	*a,
	*b;
{
	int	i = 1;

	if (a == NULL || b == NULL)
	   return FALSE;

	while (*a == *b && *a != EOS && i < IDL)
	      { a++ ; b++; i++; }

	return (*a == *b);
}

/*
 *	Return a tag for x
 */
char	*tag_of (x)
ac	x;
{
	return (x == NULL ? "NULL" :
		g_tag (x) == NULL ? "NULL" :
                                    g_tag (x));
}


/*
 *	Check equality between strings
 *	returns -1, 0, 1
 */
static
int	eq_string (a, b)
char	*a,
	*b;
{
	while (upper (*a, TRUE) == upper (*b, FALSE) && *a != NULL) {
	   a++;
	   b++;
	}

	if (upper (*a, FALSE) > upper (*b, FALSE))
	   return 1;

	if (upper (*a, FALSE) < upper (*b, FALSE))
	   return -1;

	return 0;
}

/*
 *	Map the string representation of an Ada attribute
 *	to its numerical equivalent
 */
int	srch_attr (str)
char	*str;
{
	int	i;

	for (i = 0; attr [i]. string != NULL; i ++)
	    if (eq_string (attr [i]. string, &str [0]) == 0)
	       return attr [i]. attrval;

	return -1;
}

/*
 *	Search for a reserved word, return its numerical
 *	equivalent once found
 */
int	srch_resw (text)
ac	text;
{
	int	i,
		last,
		r,
		c_test;

	last = 0;
	r = MAX_RESW;

	while (last <= r) {
	   i = (last + r) / 2;
	   c_test = eq_string (res_word [i].stringrep, text);
	   if (c_test == NULL)
	      return (res_word [i].res_value);

	   if (c_test > 0)	/* index too small	*/
	      r = i - 1;
	   else
	      last = i + 1;
	}

	PRINTF (printf ("not found : %s \n", text));

	return (-1);	/* too bad	*/
}

/*
 *	Generating unique tags
 */
#define	MAX_LET	26
static	char	anon_tag [20];
static	char	*inc;
static	int	cnt;

void	in_antag ()
{
	sprintf (anon_tag, "aaaaa%d", (int)mainlun);
	inc = &anon_tag [0];
	cnt = 0;
}

char	*gen_tag ()
{
	if ( ++cnt >= MAX_LET) {	
	   inc ++;
           if (*inc != 'a') {
              error ("Too much tags created in compilation, split up\n");
              exit (121);
	   }
	   cnt = 0;
	}
	(*inc)++;
	return anon_tag;
}

/*
 *	simple check
 */
bool	is_and_then (x)
int	x;
{
	return (x == S_AND_THEN || x == S_OR_ELSE);
}

/*
 *	Misscelaneous
 */
char	*char_tag (b)
char	b;
{
	static char h[] = "?";

	h [0] = b;
	return h;	/* I hope you use it quick as you can	*/
}

char	*mk_chartag (n)
char	n;
{
	char	*tag;

	tag = (char *)l_alloc (1 + 1);
	tag [0] = n;
	tag [2] = EOS;

	return tag;
}


/*
 * strange routine:
 */
bool	is_NOT_EQ (x)
char	*x;
{
	return (x [0] == '/' && x [1] == '=');
}

void	IInit ()
{
	tree_init ();
	p_init ();
	libv_init ();
}

/*
 *	Pragma driver
 */
void	do_pragma_0 (s)
char	*s;
{
	warning ("Pragma (%s) not implemented", s);
}

void	do_pragma_1 (s, n1)
char	*s;
ac	n1;
{
	warning ("Pragma (%s) not implemented", s);
}

void	do_pragma_2 (s, n1, n2)
char	*s;
ac	n1,
	n2;
{
	ac	t;

	if (!eq_tags (s, "INTERFACE")) {
	   warning ("pragma %s not (yet) implemented",s);
	   return;
	}

	if (n1 == NULL || g_d (n1) != XNAME)
	   return;

	ASSERT (g_fentity (n1) != NULL && g_d (g_fentity (n1)) == XUNRESREC,
	                 ("do_pragma_2:0"));

	if (!eq_tags (g_ident (g_fentity (n1)), "C")) {
	   warning ("Unable to interface to %s", g_ident (g_fentity (n1)));
	   return;
	}

	if (n2 == NULL || g_d (n2) != XNAME)
	   return;

	ASSERT (g_fentity (n2) != NULL && g_d (g_fentity (n2)) == XUNRESREC,
	                 ("do_pragma_2:1"));

	t = look_id (g_ident (g_fentity (n2)));
	if (t == NULL) {
	   warning ("Cannot identify %s in Pragma Interface",
                                            g_ident (g_fentity (n2)));
	   return;
	}

	if (!is_singleton (t)) {
	   warning ("cannot uniquely identify %s in Pragma Interface",
	                                    g_ident (g_fentity (n2)));
	   return;
	}

	set_as_C (t);
}


void	do_pragma_3 (s, n1, n2, s2)
char	*s;
ac	n1,
	n2;
char	*s2;
{
	warning ("NOT yet implemented (%s)", s);
}


