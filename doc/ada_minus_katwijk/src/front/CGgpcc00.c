
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
 *	julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"
/*
 *	Forward (static) declarations
 */
static	void	mk_s	();
static	int	index	();
static	void	ENTRY_PARAMETERBASE	();
static	void	DYN_NAME	();
static	bool	is_pointer_type	();
/*
 *XXX	ROUTINES FOR GENERATION OF PCC CODE
 */

/* the assembler directive '.text' or '.data' is active.
 * text_flag is changed by the macro's OUTTEXT and OUTDATA.
 * the next routine will check whether one of the directives has to be issuid.
 */

static	int	text_mode = TRUE;
short	text_flag	= TRUE;

void	printout (a,b,c,d,e,f)
{
	if (text_mode) {	
	    if (!text_flag) {
	       fprintf (outfile, "&%d	\n", ICDATA);
	       text_mode = FALSE;
	    }
	}
	else
	    if (text_flag) {
	       fprintf (outfile, "&%d	\n", ICTEXT);
	       text_mode = TRUE;
	    }

	fprintf (outfile, a,b,c,d,e,f);
}

#define	C_LANGUAGE	1
#define	Ada		6

void	init_outfile ()
{
/*	OUT (("&%d	\n", ICINIT));
	OUT (("&%d	%d	\n", ICLANGUAGE, Ada));
	OUT (("&%d	\n", ICTEXT));
 */
	fprintf (outfile, "/*	Translated from Ada source %s	*/\n", m_prog);
}

void	new_expr ()
{
	static int xxxx = 0;

/*	OUT ((".%d	\n", xxxx++)); */
	fprintf (outfile, "\n	;");
}

static char ass_chars[] =
{ 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p',
  'q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F',
  'G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V',
  'W','X','Y','Z','_','0','1','2','3','4','5','6','7','8','9',EXTRA_LETTER
};

#define	SS	3
#define ALFABETSIZE	63

static
void	mk_s (str, d1, d2)
char	*str;
unsigned d1,
	d2;
{
	int	i;

	for (i = SS - 1; i >= 0; i --) {
	   str [i] = ass_chars [d1 % ALFABETSIZE];
	   d1 = d1 / ALFABETSIZE;
	}

	for (i = SS + SS - 1; i >= SS; i --) {
	   str [i] = ass_chars [d2 % ALFABETSIZE];
	   d2 = d2 / ALFABETSIZE;
 	}

	str [SS + SS] = '\0';
}

static
int	index (s1, c)
char	*s1,
	c;
{
	while (*s1 != '\0') {
	   if (*s1 == c)
	      return TRUE;

	   s1++;
	}
}

void	labconvert (node, vector)
ac	node;
char	*vector;
{
	unsigned short lun;
	unsigned short ind;
	char	*format;
	static	char	x[10];
	int	i;

/*
 * print an '_' for the entry of a global routine
 * and also for normal names 
 */
	if (g_d (node) == XSUBBODY) {
	   node = g_specif (node);
	   format = "_X%s%s";
	}
	else
	if (g_d (node) == XSUB) {
	   format = "_M%s%s";
	}
	else
	   format = "_X%s%s";

	lun = lun_of   (node);
	ind = index_of (node);

	mk_s (x, lun, ind);

	if (!has_tag (node))
	   sprintf (vector, "_M%s", x);
	else
	if (is_std_fn (node))
	   if (index ("=/+-*<>&", g_tag (node) [0]))
	      sprintf (vector, "_M%s", x);
	   else
	      sprintf (vector, "_M%s%s", x, g_tag (node));
	else
	if (g_tag (node)[0] == '$')
	   sprintf (vector, "_%s", &g_tag (node) [1]);
	else
	if (g_tag (node) [0] == '%')
	   sprintf (vector, "%s%s", x, &g_tag (node)[1]);
	else
	   sprintf (vector, format, x, g_tag (node));

}

void	setdatalab (node, vector)
ac	node;
char	*vector;
{
	labconvert (node, vector);
}

void	deflab (n)
int	n;
{
	OUT (("L%d	\n", n)); 
}

void	defdatalab (node)
ac	node;
{
	char datatext [AIDL];

	setdatalab (node, datatext);
	OUT (("&%d	%s\n", ICGLOBL, datatext));
	OUT (("&%d	%s\n", ICDLABS, datatext));
}

void	textlab (n, vector)
int	n;
char	*vector;
{
	sprintf (vector, ".L%d", n);
}

void	setexprlab (node, vector)
ac	node;
char	*vector;
{
	setdatalab (node, vector);
}

void	defexprlab (node)
ac	node;
{
	char datatext [AIDL];

	setdatalab (node, datatext);
/*
	OUT (("&%d	%s\n", ICGLOBL, datatext));
*/
	OUT (("&%d	%s\n", ICDLABS, datatext));
}

void	defgloblab (x)
ac	x;
{
	char datatext [AIDL];
	setdatalab (x, datatext);

	OUTDATA;
	OUT (("&%d	%s\n", ICGLOBL, datatext));
	OUTTEXT;
}

void	TEXTLABCON (node)
ac	node;
{
	char datatext [AIDL];

	setdatalab (node, datatext);
	ICON (0, ADDRESS, datatext);
}

void	PAR_OBJECT (level, offset, type)
int	level,
	offset,
	type;
{
	DEREF (type);
	   PAR_NAME (level, offset, pointer_type_of (type));
}

void	PAR_NAME (level, offset, type)
int	level,
	offset,
	type;
{
	PLUS (type);
	   get_stlink (curr_level - level,type);
	   ICON (offset, LONG, "");
}

/*
 *	Temporarily solution; We need to get the proper base address
 *	of the actual parameters of the rendezvous
 */
static
void	ENTRY_PARAMETERBASE (node, type)
ac	node;
int	type;
{
	ac t;
	struct _accepts *p = ast;

	ASSERT (node != NULL, ("ENTRY_PARS:1"));

	while (p != NULL) {
	   t = p -> served_entry;
	   if (g_specif (t) == g_enclunit (node)) {
/*
 * It's a strange way to compute the level, but believe me it works
 */
	      LOC_OBJECT (level_of (node) + 1, g_SEL_actuals (p -> current_taskselect),
                            type);
	      return;
	   }

	   p = p -> prev_accept;
	}

	ASSERT (FALSE, ("ENTRY_PARAMETERS"));
}

void	ENTRY_PAR (node, type)
ac	node;
int	type;
{
	PLUS (type);
	   ENTRY_PARAMETERBASE (node, type);
	   ICON (off (node), LONG, "");
}

/* DYN_OBJECT and DYN_NAME are only used for
 * the copy out of scalar parameters.
 */

void	DYN_OBJECT (offset, type)
int	offset,
	type;
{
	DEREF (type);
	   DYN_NAME (offset, type);
}

static
void	DYN_NAME (off, type)
int	off,
	type;
{
	int	ptype = pointer_type_of (type);

	PLUS (ptype);
	   REG (SP_DYN, ptype);
	   off += paramoffset (type, PARSTACK);
	   ICON (off, LONG, "");
}

void	LOC_OBJECT (level, off, type)
int	level,
	off,
	type;
{
/*
	DEREF (type);
	   LOC_NAME (level, off, pointer_type_of (type));
 */
	fprintf (outfile, "( %s )(* (", name_of_ctype (type));
        LOC_NAME (level, off, type);
        fprintf (outfile, "))" );
}

void	LOC_NAME (level, off, type)
int	level,
	off,
	type;
{
        get_stlink (curr_level - level,type);
        fprintf (outfile, "- %d", off);
}

void	get_stlink (n,type)
int	n,
	type;
{
	if (n == 0)
           fprintf (outfile, "(BaseP)");
	else
	{
           fprintf (outfile, "* (");
              get_stlink (n - 1, type);
              fprintf (outfile, " + %d", LINK_OFFSET);
           fprintf (outfile, ")");
	}
}

void	GLOB_OBJECT (n, node, type)
int	n;
ac	node;
int	type;
{
	char datatext [AIDL];

	setdatalab (node, datatext);
	P_NAME (n, type, datatext);
}

void	GLOB_NAME (n, node)
int	n;
ac	node;
{
	char datatext [AIDL];

	setdatalab (node, datatext);
	ICON (n, ADDRESS, datatext);
}

void	LNAME (type, labelno)
int	type,
	labelno;
{
	char	label [AIDL];

	sprintf (label, ".L%d", labelno);
	P_NAME (0, type, label);
}

void	LICON (labelno)
int	labelno;
{
	char	label [AIDL];

	sprintf (label, ".L%d", labelno);
	ICON (0, ADDRESS, label);
}

void	P_BINARY (o, p)
int	o,
	p;
{
	printout ("%d\t%d\t\n",o, p);
}

void	P_TRINARY (x, y, z)
int	x,
	y,
	z;
{
	printout ("%d\t%d\t%d\t0\t\n", x, y, z);
}

void	P_UNARY (o, p)
int	o,
	p;
{
	printout ("%d\t0\t%d\t\n", o, p);
}

void	P_REG (a, p)
int	a,
	p;
{
	printout ("94\t0\t%d\t%d\t\n", a, p);
}

void	P_NAME (o, p, st)
int	o,
	p;
char	*st;
{
	printout ("2\t%d\t0\t%d\t%s\n", o, p, st);
}

void	P_CONST (o, p, st)
int	o,
	p;
char	*st;
{
	printout ("4\t%d\t0\t%d\t%s\n", o, p, st);
}

void	genjump (l)
int	l;
{
	OUT (("&%d	%d	\n", ICJLABN, l));
}

void	pcc_deref (x, y)
ac	x;
int	y;
{
	if (y == VAL)
	   DEREF (pcc_type_of (x));
}

/* pcc_size returns the amount of bytes 
 * allocated on the stack for the object */

int	pcc_size (type)
int	type;
{
	switch (type) {
	   case FLOAT:
		return TFLOATSIZE;

	   default:
		return TLONGSIZE;
	}
}

void	le (type)
int	type;
{
	if (type == UCHAR)
	   ULE (type);
	else 
	   LE (type);
}

void	ge (type)
int	type;
{
	if (type == UCHAR)
	   UGE (type);
	else 
	   GE (type);
}

void	sconv (type)
int	type;
{
	switch (type) {
	   case SHORT:
		SCONV (INT);
	        return;

	   case UCHAR:
	   case USHORT:
		SCONV (UNSIGNED);
	        return;

	   default:
		return;
	}
}

int	pcc_type_of (node)
ac	node;
{
	if (node == NULL)
	   return NOTYPE;

	switch (g_d (node)) {
	   case XOBJECT:
		return pcc_type_of (g_desc (node));

	   case XOBJDESC:
		return pcc_type_of (g_objtype (node));

	   case XSUBTYPE:
		return pcc_type_of (g_parenttype (node));

	   case XLITERAL:
		return pcc_type_of (g_littype (node));

	   case XENUMTYPE:
	   case XCHARLIT:
	   case XENUMLIT:
		return UCHAR;

	   case XSCC:
		return UCHAR;

	   case XNAME:
	   case XALL:
	   case XATTRIBUTE:
	   case XCALL:
	   case XSELECT:
	   case XINDEXING:
	   case XSLICE:
	   case XENTRYCALL:
		return pcc_type_of (g_types (node));

	   case XTYPECONV:
		return pcc_type_of (g_newtype (node));

	   case XEXP:
		return pcc_type_of (root_type (g_exptype (node)));

	   case XSUB:
	   case XEXCEPTION:
		return ADDRESS;

	   case XARRAYTYPE:
	   case XRECTYPE:
		return ADDRESS;

	   case XINCOMPLETE:
		if (g_complete (node) != NULL)
		   return pcc_type_of (g_complete (node));
		else
		   return ADDRESS;

	   case XPRIVTYPE:
		return pcc_type_of (g_impl (node));

	   case XFILTER:
		return pcc_type_of (g_filtype (node));

	   case XNEWTYPE:
		return pcc_type_of (g_old_type (node));

	   case XINTERNAL:
		switch (g_ind (node)) {
		   case I_INTEGER:
			return INT;
		   case I_LONG:
		   case I_UNIV:
		   case I_INTTYPES:
			return LONG;
		   case I_SHORT:
			return CHAR;
		   case I_ANY_ACCESS_TYPE:
		   case I_ANY_SCALAR_VECTOR:
 		   case I_ANY_BOOL_VECTOR:
		   case I_ANY_STRING_TYPE:
 		   case I_ANY_TYPE:	/* is erroneous but for the
					 * sake of the programs that
					 * use this internal type
					 */
			return ADDRESS;
		   case I_STD_REAL:
			return FLOAT;
		   case I_ENUM:
			return UCHAR;
		   case I_NO_TYPE:
			return NOTYPE;
		   DEFAULT (("cannot find ind of _internal %d\n", g_ind (node)));
		}

	   default:
		return TADDRSIZE;	/* should be address */
	}
}

void	PUT (type, val)
int	type;
int	val;
{
	switch (type) {
	   case DEF_LONG:
		glob_init (val,LONG,"");
		break;
	   case DEF_WORD:
		glob_init (val,INT,"");
		break;
	   case DEF_BYTE:
		glob_init (val,UBYTE,"");
		break;
	   case DEF_DOUBLE:
		glob_init (val, DOUBLE, "");
		break;
	   case DEF_ADDR:
		glob_init (val,ADDRESS,"");
		break;
	   case DEF_STRING:
		while (*(char *) val != '\0')
		   OUT (("&%d	%d	\n", ICBYTE, *(char *) val++));
		break;
	   case DEF_SLONG:
		glob_init (0, ADDRESS, val);
		break;
	}
}

void	glob_init (value, type, str_value)
int	value,
	type;
char	*str_value;
{
	switch (type) {
	   case DOUBLE:
		OUT (("&%d	%s\n", ICDOUBLE, value));
		break;

	   default:
		new_expr ();
		INIT (type);
		   ICON (value, type, str_value);
		break;
	}
}

void	comment (a, b)
char	*a;
char	*b;
{
	OUT (("&%d	", ICCOM));
	OUT ((a, b));
}

int	pointer_type_of (type)
int	type;
{
	/* let's keep it simple for the moment ...
	 * only one level of pointer's are known,
	 * so no double references are generated.
	 */
	/* IMPORTANT :
	 *
	 * see ./h/pcc.h for multiple cases !
	 */

	int	ptype;
	
	if (is_pointer_type (type))
	   return type;

	switch (type) {
	   case CHAR:
		ptype = P_CHAR;
		break;
/*
 *	   case SHORT:
 *		ptype = P_SHORT;
 *		break;
 */

	   case INT:
		ptype = P_INT;
		break;

	   case LONG:
		ptype = P_LONG;
		break;
	
	   case FLOAT:
		ptype = P_FLOAT;
		break;

/*
 *	   case DOUBLE:
 *		ptype = P_DOUBLE;
 *		break;
 */
	   case UBYTE:
		ptype = P_UBYTE;
		break;

/*	   case UCHAR:
 *		ptype  = P_UCHAR;
 *		break;
 */
	   case USHORT:
		ptype = USHORT;
		break;

/*	   case UNSIGNED:
 *		ptype = P_UNSIGNED;
 *		break;
 */
	   case ULONG:
		ptype = P_ULONG;
		break;

	   case ADDRESS:
		ptype = type;
		break;

	   DEFAULT (("pointer_type_of : unknown type to be pointered\n"));
	}

	return ptype;
}

static
bool	is_pointer_type (type)
int	type;
{
	switch (type) {
	   case P_CHAR :
	   case P_INT :
	   case P_LONG :
	   case P_FLOAT :
	   case P_UCHAR :
	   case P_USHORT :
	   case P_ULONG :
		return TRUE;

	   default:
		return FALSE;
	}
}

int	new_lab ()
{
	static int labno = 0;

	return ++labno;
}

short	max (a, b)
short	a,
	b;
{
	return  a > b ? a : b;
}
char	*name_of_ctype (int ct)
{
	switch (ct)
	{
	   case	NOTYPE:		 return " ";
	   case	BYTE:		 return "char";
	   case	SHORT:		 return "short";
	   case	LONG:		 return "long";
	   case	FLOAT:		 return "float";
	   case	UBYTE:		 return "char";
	   case	USHORT:		 return "unsigned short";
	   case	ULONG:		 return "unsigned long";
	   case	P_UCHAR:
	   case	P_BYTE:		 return "char *";
	   case	P_SHORT:	 return "short *";
	   case	P_LONG:		 return "long	*";
	   case	P_DOUBLE:	 return "double *";
	   case	P_USHORT:	 return "unsigned short *";
	   case	P_ULONG:	 return "unsigned long	*";

	   default:
				 return "int";
	}
}
