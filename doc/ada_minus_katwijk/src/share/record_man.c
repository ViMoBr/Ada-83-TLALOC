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

#include	"../h/print.h"
#include	<stdio.h>
#include	"../h/tree.h"
#include	"../h/std.h"
#include	"../h/record_man.h"
#include	"../h/rec_sizes.h"
/*
 *	Forward (static) declarations
 */
static	void	byte_io	();
static	void	short_io	();
static	void	get_str	();
static	void	put_str	();
static	void	tag_io	();
static	void	ac_io	();
static	void	discr_io	();
static	bool	eoif	();
static	void	unlink	();
static	int	getlunbase	();
static	void	conv_index	();

/*
 *	Some useful and local constants
 */
#define	MAX_BLOCK	200
#define	BUF_SIZE	0x1000
char	*buf_pointer	= NULL;
int	buf_used	= BUF_SIZE;

struct tree_space {
	char	*tr_vec [MAX_BLOCK];
	int	tr_top;
} tree_space;

/*
 *	luns contains for each 'incore' unit
 *	its 'lun'
 *	the index in the record table from which
 *	records belong to this lun
 */
static short lun_index	= 0;

static	struct lun_tab {
	short	lun;
	short	l_index, h_index;
} luns [MAXLUN];

/*
 *	the real record managing table
 */
static ac rec_list [MAX_INCORE];

/*
 * absolute origin is reserved to prevent
 * problems with NULL pointer conversions
 */
short	low			= 0;
ac	mark_record;
short	mainlun, curr_lun;
bool	reading;
static	int	zero	= 0;
static	byte	zerobyte= 0;

static short high		= MAX_INCORE - 1;

void	tree_init ()
{
	register int i;

	for (i = tree_space. tr_top; i > 0; i --)
	    cfree (tree_space. tr_vec [i]);

	low	= 0;
	high	= MAX_INCORE - 1;
	lun_index = 0;
	buf_pointer = NULL;
	buf_used = BUF_SIZE;
	tree_space. tr_top = 0;

	ini_liblist ();
}

#include	"../h/tokens.h"
#ifdef ASC
#define	INT_WIDTH	5
#define	ILL		30
short col = INT_WIDTH + 2;

#define	putch(ch)	putchar(ch)

space(k,new_line)
register short k;
register bool new_line;
{
	register i;

	if (new_line) {
		putch('\n');
	}
	for (i=1; i <= k; i++) {
		putch(' ');
	}
}


asc_int(n)
register int	n;
{
	if (!reading) {
		printf("%5d",n);
	}
}


asc_index(l,r)
register int	l,r;
{
	if (!reading) {
		space(1,FALSE);
		putch('(');
		asc_int(l);
		putch(',');
		asc_int(r);
		putch(')');
	}
}



asc_discr(d,n)
register short d, n;
{
	if (!reading) {
		if (d == XMARK) {
			putch (';');
		} else {
			space(0,TRUE);
			if (n != -1)
			   printf ("%5d", n);
			else
			   printf ("     ");
			space(col-INT_WIDTH,FALSE);
			printf("%s",token [d]);
		}
	}
}


asc_field(s)
register char	*s;
{
	if (!reading) {
		space(col+INDENT,TRUE);
		printf("%s =>",s);
	}
}


asc_str(s,len)
char	*s;
int	len;
{
	register short cnt = 0;

	if (!reading) {
		while (cnt ++ < len && *s != EOS)
			putch (*s++);
	}
}

str_asc (s, l)
register char *s;
register short l;
{

	putch ('"');
	asc_str (s, l);
	putch ('"');
}

asc_tag (t)
register char *t;
{
	if (!reading)
	   { if (t == NULL)
	        t = "null_tag";
	     space (1, FALSE);
	     asc_str (t, IDL);
	   }
}

asc_flags(b)
register short b;
{
	if (!reading) {
		printf(" %c%c%c%c%d",
			"-D"[(b&DYNREC)!=0],
			"-C"[(b&CSTREC)!=0],
			"-V"[(b&VARREC)!=0],
			"-I"[(b&F_RINIT)!=0],
			(b&F_ALIGN) +1);
	}
}




asc_lit (lit)
register lit_ptr lit;
{
	if (!reading) {
		switch (lit -> litkind) {
			case S_INTLIT:
			case S_REALLIT:
			case S_CHARLIT:
				asc_str(lit->litvalue, lit -> n);
				break;
			case S_STRINGLIT:
				str_asc (lit-> litvalue, lit -> n);
				break;
			case S_NULLLIT:
				printf("null");
				break;
			}
	}
}

asc_dflags (x)
register ac x;
{
	if (reading)
	   return;

	if (g_d (x) == XMARK)
	   return;

	space (col + INDENT, TRUE);
	printf ("line %4d flags =>", g_lineno (x));
	switch (g_d (x)) {
		case XSUB:
		case XRENSUB:
			printf (is_std_fn(x) ? "std_oper": "user_proc");
			break;

		case XASSIGN:
			if (nocheck(x))
				printf("nocheck");
			break;

		case XOBJDESC:
			switch (kind_of (x)) {
				case KVAR:
					printf ("variable");
					break;

				case KCONST:
					printf ("const variable");
					break;

				case KNUMB:
					printf ("number");
					break;

				case KDISCR:
					printf ("discriminant");
					break;

				case KCOMP:
					printf ("record_field");
					break;

				case INMODE:
					printf ("input param");
					break;

				case OUTMODE:
					printf ("output param");
					break;

				case INOUTMODE:
					printf ("in out param");
					break;
			}

			break;

		case XPRIVTYPE:
			printf (g_flags (x) & LIMIT ? "limited": " ");
			break;

		case XIN:
			printf (is_in (x) ? "in": "not in");
			break;

		case XFORBLOCK:
			printf (is_forwards(x) ? "forwards":"backwards");
			break;

		case XEXP:
			printf (is_qualif(x) ? "qualified":"      ");
			break;

	}

	if (is_static (x))
	   printf (" static");

	if (is_error (x))
	   printf (" erroneous");
	if (is_generic (x))
	   printf (" generic");
	if (is_genpar (x))
	   printf (" generic parameter");
}

#else
#define	asc_int(m)
#define	asc_discr(n,d)
#define	asc_index(l, r)
#define	asc_field(s)
#define	asc_tag(s)
#define	asc_flags(b)
#define	asc_lit(lit)
#define	asc_dflags(x)
#endif ASC
#define	get_byte(f)	(eoif(f) ? (sys_error("unexpected EOF"), 1) : fgetc (f))
#define put_byte(f, i)	putc (i, f)

/*
 *	an external record is defined as an small integer number
 *	indicating the number of bytes that are following.
 */

#ifdef PC
#define	MAX_REC_SIZE	160
#endif PC
#ifndef MAX_REC_SIZE
#define MAX_REC_SIZE	100
#endif  MAX_REC_SIZE

static	struct	{
	byte	r_size;
	byte	c_size;
	byte	c_data [MAX_REC_SIZE];
} dat_vec;
/*
 *	obviously machine dependent
 */
struct	file_header {
	short	magic;
	short	f_lun;
	short	n_index;
} file_header;
/*
 *	external record manager
 */

void	open_rec (f)
FILE *f;
{
	short i;

	if (reading) {
	   dat_vec.r_size =  (short)get_byte (f);
	   dat_vec.c_size = 0;
	   for (i = 0; i < dat_vec.r_size; i++)
	       dat_vec.c_data[i] = (short)get_byte (f);

	}
	else
	   dat_vec.c_size = 0;
}

void	close_rec (f)
FILE *f;
{
	short i;

	if (!reading) {
	   put_byte (f, dat_vec.c_size);
	   for (i = 0; i < dat_vec.c_size; i++)
	       put_byte (f, dat_vec.c_data[i]);

	}
}

ac	l_alloc (size)
short size;
{
	char *p = buf_pointer;

	int my_size = size + (size % 2);

	if (my_size > BUF_SIZE)
	   sys_error ("cannot allocate > %d\n", BUF_SIZE);

	if (my_size >= BUF_SIZE - buf_used) {
	   p = (ac) calloc (1, BUF_SIZE);
	   if (p == NULL)
	      sys_error ("out of available core\n");
	   tree_space. tr_top ++;
	   ASSERT (tree_space. tr_top < MAX_BLOCK, ("treespace overflow"));
	   tree_space. tr_vec [tree_space. tr_top] = p;

	   buf_used = 0;
	}
	buf_used	= buf_used + my_size;
	buf_pointer	= p + my_size;
	return (ac) p;
}

static
void	byte_io (b_p)
byte *b_p;
{
	if (reading)
	   if (dat_vec.c_size >= dat_vec.r_size)
	      *b_p = NULL;
	   else
	      *b_p = dat_vec.c_data[dat_vec.c_size++];
	else
	   dat_vec.c_data[dat_vec.c_size++] = *b_p;
}

/*
 *	No field in the tree is of size "int", they are
 *	all limited to shorts
 */
static
void	short_io (b_p)
byte *b_p;
{
	register short i;

/*
	for (i = 0; i < sizeof (short); i++)
	    byte_io (& b_p [i]);
 */
	byte_io (& (b_p [0]));
	byte_io (& (b_p [1]));
}

static
void	get_str (buf, len)
char *buf;
short len;
{
	short i;

	for (i=0; i < len; i++)
	    byte_io (& (buf [i]));
}

short length (s)
char *s;
{	short i;

	if (s == NULL)
	   return (NULL);

	i = 1;
	while (*s != EOS) {
	   s++; i++;
	}
	return i;
}

static
void	put_str(buf, len)
char *buf;
short len;
{
	short i;
	for (i=0; i < len; i++)
	    byte_io (&buf [i]);
}

static
void	tag_io (t_p)
char **t_p;
{	byte n;
	short len;

	if (reading) {
	   byte_io (&n);
	   len = ( (short) n) & CMASK;
	   if (len == 0)
	      return ;
	   *t_p = l_alloc (len);
	   get_str (*t_p, len);
	}
	else
	if (*t_p == NULL)
	   byte_io (&zero);
	else
	{  len = length (*t_p);
	   n = (byte) len;
	   byte_io (&n);
	   put_str (*t_p, len);
	}
}

/*
 *	C environment causes strings of literals to be one
 *	longer, terminated by a zero
 */
ac	alloc_lit (type, value, size)
short type;
char *value;
short size;
{	register ac t;
	register short i;

	t = l_alloc (sizeof (struct literal) + size);
	((struct literal *)t) -> n = size;
	((struct literal *)t) -> litkind = type;
	for (i = 0; i < size; i++)
	    ((lit_ptr)t) -> litvalue [i] = value [i];

	((lit_ptr)t) -> litvalue [i] = '\0';
	return (t);
}

void	lit_io (lit_p)
lit_ptr *lit_p;
{	short i;
	byte k, n;

	if (!reading) {
	   k = (*lit_p) -> litkind;
	   n = (*lit_p) -> n;
	}

	byte_io (&n);
	byte_io (&k);
	switch (k) {
	   case S_INTLIT:
	   case S_REALLIT:
	   case S_STRINGLIT:
	   case S_CHARLIT:
		if (reading) {
		   *lit_p = l_alloc (sizeof (struct literal) + n - 1);
		   get_str (&(*lit_p) -> litvalue, n);
		}
		else
		   put_str ( (*lit_p) -> litvalue, n);
		break;

	   case S_NULLLIT:
		if (reading)
		   *lit_p = l_alloc (sizeof (struct literal));
	}
	if (reading) {
	   (*lit_p) -> n = n;
	   (*lit_p) -> litkind = k;
	}
}

/*
 *	convert a pointer to a (lun, index) pair
 *	and vice versa
 */
static
void	ac_io (a_p)
ac *a_p;
{
	short lun;
	short index;

	if (reading) {
	   short_io (&lun);
	   short_io  (&index);
	   if (lun == 0 && index == 0)
	      *a_p = NULL;
	   else
	   {  *a_p = rec_list [getlunbase (lun) + index];
	      if (*a_p == NULL) {
		 printf ("Help, NULL pointer (%d %d)\n", lun, index);
		 abort ();
	      }
	   }
	}
	else
	{  if (*a_p == NULL) {
	      short_io (&zero);
	      short_io (&zero);
	      asc_index (0, 0);
	   }
	   else
	   {  conv_index (& g_prev (*a_p), &lun, &index);
	      short_io (&lun);
	      short_io (&index);
	      asc_index (lun, index);
	   }
	}
}

static
void	discr_io (a_p)
ac	*a_p;
{
	short	n;
	short	lun;
	short	a_z;
	short	d;

	if (reading) {
	   short_io (&d);
	   if (d != XMARK) {
	      *a_p = old_alloc (d);
/*
 *	remember, alloc is clever enough to know when
 *	a record has to be linked in
 */
	   }
	   else
	      *a_p = mark_record;

	   if (has_link (*a_p)) {
	      short_io (&lun); short_io (&n);
	      conv_index (&a_z, &lun, &n);
	      s_prev (*a_p, a_z);

	      rec_list [getlunbase (lun) + n] = *a_p;
	   }

	}
	else
	{  short_io (& g_d (*a_p));
	   if (g_d (*a_p) == XMARK) {
	      asc_discr (XMARK,0);
	      return;
	   }
	   if (has_link (*a_p)) {
	      conv_index (& g_prev (*a_p), &lun, &n);
	      asc_discr (g_d (*a_p), n);
	      ASSERT (lun == mainlun, ("cannot write other lib"));
	      short_io (&lun);
	      short_io (&n);
	   }
	   else
	      asc_discr ( g_d (*a_p), -1);
	}
}

static
bool	eoif (f)
FILE *f;
{
	char c;
/*
 * test if the current yyin has reached end of file;
 * the eof condition is not automatically set to true
 * if the last word has been read.
 */
	c = getc (f);
	if (feof (f)) {
		return TRUE;
	} else {
		ungetc (c & CMASK, f);
		return FALSE;
	}
}

ac	get_rec (f)
FILE *f;
{
	ac  a;
	reading = TRUE;
	rec_io (&a, f);
	PRINTF ((printf ("token: %s\n", token [g_d (a)])));
	return a;
}

void	put_rec (f, a)
FILE *f;
ac a;
{
	reading = FALSE;
	rec_io (&a, f);
}

void	put_mark (f)
FILE *f;
{
	put_rec (f, mark_record);
}

void	new_lun (lun)
short	lun;
{	luns [lun_index] .lun = lun;
	luns [lun_index] .l_index = low;
	luns [lun_index]. h_index = low;
	curr_lun = lun_index;
	lun_index ++;
}

void	next_lun (lun, n)
short	lun;
short	n;
{
	luns [lun_index]. lun = lun;
	luns [lun_index]. l_index = high - n;
	luns [lun_index]. h_index = high;
	high = high - n - 1;
	lun_index ++;
}

short	nindex (lun)
short	lun;
{
	short i;

	for (i = 0; i < lun_index; i ++)
	    if (luns [i]. lun == lun)
		return luns [i]. h_index - luns [i]. l_index;

	ASSERT (FALSE, ("cannot find lun %d", lun));
}

static
void	unlink (t)
ac t;
{
	rec_list [g_prev (t)] = 0;
}

ac	old_alloc (x)
short	x;
{
	ac	t;

	ASSERT (x != XMARK, ("cannot allocate mark record"));
	t = (ac) l_alloc (size [x]);
	s_d (t, x);

	return t;
}

/*
 *	For new records:
 */
ac	alloc (x)
short	x;
{
	ac	t;

	ASSERT (x != XMARK, ("cannot allocate mark record"));

	t = (ac)l_alloc (size [x]);
	s_d (t, x);
	if (has_link (t)) {
	   s_prev (t, low);
	   rec_list [low] = t;
	   luns [curr_lun]. h_index = low ++;
	}

	return (t);
}

void	delete_rec (a_p)
ac	*a_p;
{
	if (has_tag (*a_p))
	   del_tag (g_tag (*a_p));

	if (has_link (*a_p)) {
	   unlink (*a_p);
	}

	*a_p = NULL;
}

void	del_rec (x)
ac	x;
{
}

void	del_tag (x)
ac	x;
{
/*	if (x != NULL)
	   cfree (x);	*/
}

short	lun_of (a)
ac	a;
{
	int	i;
	short	n = g_prev (a);

	for (i = 0; i <= lun_index; i ++) {
	   if (luns [i]. l_index <= n && n <= luns [i]. h_index)
	      return luns [i]. lun;
	}
}

short	index_of (a)
ac	a;
{
	short l;
	short t;

	return g_prev (a) - getlunbase (lun_of (a));
}

static
int	getlunbase (n)
short	n;
{
	int	i;

	for (i = 0; i < lun_index; i ++)
	   if (luns [i]. lun == n)
	      return luns [i]. l_index;
}

/*
 *	conv_index
 *	
 *	converts a pair (lun, relative index) to
 *	an absolute index and vice versa
 */
static
void	conv_index (a_index, a_lun, a_relind)
short	*a_index,
	*a_relind;
short	*a_lun;
{
	short	i;

	if (reading) {	/* lun/rel_index -> abs index */
	   *a_index = getlunbase (*a_lun) + *a_relind;
	   return;
	}

	*a_lun = lun_of (rec_list [*a_index]);
	*a_relind = *a_index - getlunbase (*a_lun);
}

/*
 *	initialization of package standard data
 *
 *	each fixed package may be initialized by the
 *	(simple) routine std_init, taking two
 *	parameters
 *	- a lun
 *	- a vector of entries
 */
void	std_init (lun, table)
short	lun;
ac	table [];
{
	ac	t;
	short	i,
		y,
		n;

	prev	= def_prev;
	env	= def_env;
	new_lun (lun);
	for (i = 0; table [i] != NULL; i ++) {
	    t = table [i];
	    if (has_link (t)) {
	       s_prev (t, low);
	       rec_list [low] = t;
	       luns [curr_lun]. h_index = low ++;

	       prev = t;
	    }
	}
}

void	p_init ()
{
	int i;
	mark_record	= l_alloc (MARKSIZE);
	s_d (mark_record, XMARK);

	std_init (1, st_table);
}


void	rec_io (r_p, f)
ac *r_p;
FILE *f;
{	static short zero = 0;
	discr	d;
	ac	t_p;
	ac	p;
	int	i, t1, t2;
	ac	my_zero = (ac) &zero;
	bool	mark_flag;

	if (reading)
	{	if (ferror(f)) {
			sys_error("read sys_error");
		}
		if (eoif (f)) {
			*r_p = NULL;
			return;
		}
	}
/*
 *	open a new record
 */
	open_rec (f);
	discr_io (r_p);
	p = *r_p;
	mark_flag = FALSE;
	if (p != mark_record) {
		short_io (&g_flags (p));
		asc_dflags(p);
		short_io (&g_lineno (p));
		d = g_d (p);
		if (has_tag (p))
		   { tag_io (& g_tag (p));
		     asc_field ("tag");
		     asc_tag (g_tag (p));
		   }

		if (is_enclosed (p))
		   { asc_field ("enclunit");
		     ac_io (& g_enclunit (p));
		   }

		switch (d) {
		case XABORTSTAT:
			break;
		case XACCTYPE:
			ac_io (& g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			ac_io (& g_actype (p));
			asc_field("ACC_alloc");
			asc_int (g_ACC_alloc (p));
			short_io (& g_ACC_alloc (p));
			asc_field("ACC_offset");
			asc_int(g_ACC_offset (p));
			short_io (& g_ACC_offset (p));
			asc_field("ACC_nform");
			asc_int(g_ACC_nform (p));
			short_io (& g_ACC_nform (p));
			short_io (& g_ACC_flags (p));
			break;

		case XAGGREGATE:
			asc_field("AGG_Doff");
			asc_int(g_AGG_Doff (p));
			short_io (& g_AGG_Doff (p));
			asc_field("AGG_Voff");
			asc_int(g_AGG_Voff (p));
			short_io (& g_AGG_Voff (p));
			break;

		case XALL:
			asc_field ("types");
			ac_io     (& g_types (p));
			asc_field("ALL_Doff");
			asc_int(g_ALL_Doff (p));
			short_io (&g_ALL_Doff (p));
			short_io (& g_ALL_Voff (p));
			break;

		case XALLOCATOR:
			asc_field("altype");
			ac_io (&g_altype (p));
			asc_field("ALLO_Doff");
			asc_int(g_ALLO_Doff (p));
			short_io (& g_ALLO_Doff (p));
			asc_field("ALLO_Toff");
			asc_int(g_ALLO_Toff (p));
			short_io (&g_ALLO_Toff (p));
			break;

		case XARRAYTYPE:
			ac_io (& g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			asc_field ("elemtype");
			ac_io     (& g_elemtype (p));
			asc_field("ARR_alloc");
			asc_int(g_ARR_alloc (p));
			short_io (& g_ARR_alloc(p));
			asc_field("ARR_flags");
			asc_flags(g_ARR_flags (p));
			short_io(&g_ARR_flags (p));
			asc_field("ARR_offset");
			asc_int(g_ARR_offset (p));
			short_io (&g_ARR_offset (p));
			asc_field("ARR_vdsize");
			asc_int(g_ARR_vdsize (p));
			short_io (&g_ARR_vdsize (p));
			asc_field("ARR_ndims");
			asc_int(g_ARR_ndims (p));
			short_io (& g_ARR_ndims (p));
			break;

		case XASSIGN:
			break;

		case XATTRIBUTE:
			asc_field ("types");
			ac_io (& g_types (p));
			asc_field("attr_value");
			asc_int( g_attr_value (p));
			short_io (&g_attr_value (p));
			break;

		case XBLOCK:
			asc_field ("BLK_SToff");
			asc_int(g_BLK_SToff (p));
			short_io (&g_BLK_SToff (p));
			short_io (&g_BLK_Moff (p));
			short_io (&g_BLK_MCoff (p));
			break;

		case XCALL:
			asc_field ("types");
			ac_io     (& g_types (p));
			asc_field("CALL_Doff");
			asc_int(g_CALL_Doff (p));
			short_io (&g_CALL_Doff (p));
			short_io (&g_CALL_Voff (p));
			break;

		case XCASE:
			break;

		case XCHARLIT:
			asc_field("CHARL_ord");
			asc_int(g_enuml_ord (p));
			short_io (& g_enuml_ord (p));
			break;

		case XCOMPASSOC:
/*****
			asc_field("astype");
			ac_io (&p -> astype);
****/
			break;

		case XDISCR:
			asc_field("comp");
			ac_io (&g_comp (p));
			break;

		case XDISCRCONS:
			break;

		case XENUMLIT:
			asc_field("enuml_ord");
			asc_int( g_enuml_ord (p));
			short_io (& g_enuml_ord (p));
			break;

		case XENUMTYPE:
			ac_io (& g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			asc_field("nenums");
			asc_int(g_nenums (p));
			short_io (& g_nenums (p));
			break;

		case XEXHANDLER:
			break;

		case XEXIT:
			asc_field("loopid");
			ac_io (& g_loopid (p));
			break;

		case XEXCEPTION:
			ac_io (& g_rnam (p));
			break;

		case XEXP:
			asc_field("exptype");
			ac_io (& g_exptype (p));
			break;

		case XFILTER:
			asc_field("filtype");
			ac_io (& g_filtype (p));
			asc_field("FLT_alloc");
			asc_int(g_FLT_alloc (p));
			short_io (&g_FLT_alloc (p));
			asc_field("FLT_flags");
			asc_flags(g_FLT_flags (p));
			short_io(&g_FLT_flags (p));
			asc_field("FLT_offset");
			asc_int(g_FLT_offset (p));
			short_io (&g_FLT_offset (p));
			asc_field("FLT_valsize");
			asc_int(g_FLT_valsize (p));
			short_io (&g_FLT_valsize (p));
			asc_field("FLT_vdoffset");
			asc_int(g_FLT_vdoffset (p));
			short_io (&g_FLT_vdoffset (p));
			break;

		case XFORBLOCK:
			break;

		case XFORUSE:
			asc_field ("forused");
			ac_io     (& g_forused (p));
			break;

		case XIF:
			break;

		case XIFITEM:
			break;

		case XIN:
			break;

		case XINCOMPLETE:
			ac_io (& g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			break;

		case XINDEX:
			asc_field("indextype");
			ac_io (& g_indextype (p));
			break;

		case XINDEXCONS:
			break;

		case XINDEXING:
			asc_field ("types");
			ac_io     (&g_types (p));
			break;

		case XINDIRECT:
			asc_field("indir");
			ac_io (& g_indir (p));
			break;

		case XINTERNAL:
			asc_field("ind");
			asc_int( g_ind (p));
			short_io (& g_ind (p));
			break;

		case XLITERAL:
			asc_field("littype");
			ac_io (& g_littype (p));
/* ONLY FOR THE SAKE OF THE ASCII INTERMEDIATE CODE !!!
 */
			asc_field ("litkind");
			asc_int (g_val (p) -> litkind);

			lit_io (& g_val (p));

			if (g_val (p) -> litkind == S_STRINGLIT) {
			   if (reading) {
				register ac temp;
				temp = l_alloc (sizeof (struct _stringlit));
				s_d(temp,  XLITERAL);
				s_littype (temp, g_littype (p));
				s_val (temp, g_val (p));
/*				cfree (p);	*/
				*r_p = p = temp;
			   }
			   asc_field ("LIT_Voff");
			   asc_int (g_LIT_Voff (p));
			   short_io (&g_LIT_Voff (p));

			   asc_field ("LIT_Doff");
			   asc_int (g_LIT_Doff (p));
			   short_io (&g_LIT_Doff (p));
			}
			asc_field("value");
			asc_lit (g_val (p));
			break;

		case XLOOPBLOCK:
			break;

		case XMARK:
			break;

		case XNAME:
			asc_field("types");
			ac_io (& g_types (p));
			asc_field("fentity");
			ac_io (& g_fentity (p));
			break;

		case XNAMEDASS:
			asc_field("parname");
			ac_io (& g_parname (p));
			break;

		case XOBJDESC:
			asc_field ("objtype");
			ac_io     (& g_objtype (p));
			break;

		case XOBJECT:
			ac_io (& g_object_spec (p));
			if (reading) {
			   set_to (g_object_spec (p), p);
			}
			asc_field("OBJ_alloc");
			asc_int(g_OBJ_alloc (p));
			short_io (& g_OBJ_alloc (p));
			asc_field("OBJ_offset");
			asc_int(g_OBJ_offset (p));
			short_io (&g_OBJ_offset (p));
			asc_field("OBJ_descoff");
			asc_int(g_OBJ_descoff (p));
			short_io (&g_OBJ_descoff (p));
			break;

		case XPACKAGE:
			break;

		case XGENNODE:
			break;

		case XGENPARTYPE:
			ac_io (& g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			short_io (& g_genkind (p));
			break;


		case XPACKBODY:
			asc_field("specif");
			ac_io (& g_specif (p));
			if (reading)
			   set_to (g_specif (p), p);
			asc_field("PBDY_SToff");
			asc_int(g_PBDY_SToff (p));
			short_io (&g_PBDY_SToff (p));
			short_io (&g_PB_Moff (p));
			short_io (&g_PB_MCoff (p));
			break;

		case XTASKBODY:
			asc_field ("specif");
			ac_io (& g_specif (p));
			if (reading)
			   set_to (g_specif (p), p);
			short_io (& g_TSB_Moff (p));
			short_io (& g_TSB_MCoff (p));
			break;

		case XACCEPT:
			asc_field ("specif");
			ac_io (& g_specif (p));
			break;

		case XENTRYCALL:
			asc_field ("types");
			ac_io (& g_types (p));
			asc_int ("e_num");
			short_io (& g_e_num (p));
			asc_field ("e_entry");
			ac_io (& g_e_entry (p));
			break;

		case XDELAY:
			break;

		case XTERMINATE:
			break;

		case XTASKSELECT:
			short_io (&g_SEL_count (p));
			break;


		case XTASKTYPE:
			ac_io (& g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			short_io (& g_TSKT_alloc (p));
			short_io (& g_TSKT_offset (p));
			short_io (& g_TSKT_flags (p)); 
			break;

		case XPARENTHS:
			break;

		case XPRIVPART:
			if (reading) {
		           s_priv (g_enclunit (p), p);
			}
			break;

		case XPRIVTYPE:
			break;

		case XRAISE:
			asc_field ("exception");
			ac_io (&g_exception (p));
			break;

		case XRANGE:
			asc_field("rangetype");
			ac_io (&g_rangetype (p));
			break;

		case XRECTYPE:
			ac_io (& g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			asc_field("REC_alloc");
			asc_int(g_REC_alloc (p));
			short_io (&g_REC_alloc (p));
			asc_field("REC_flags");
			asc_flags(g_REC_flags (p));
			short_io(&g_REC_flags (p));
			asc_field("REC_offset");
			asc_int(g_REC_offset (p));
			short_io (&g_REC_offset (p));
			asc_field("REC_forms");
			asc_int (g_REC_forms (p));
			short_io (&g_REC_forms (p));
			asc_field("REC_vdsize");
			asc_int(g_REC_vdsize (p));
			short_io (&g_REC_vdsize (p));
			asc_field("REC_nflds");
			asc_int(g_REC_nflds (p));
			short_io (&g_REC_nflds (p));
			asc_field("REC_ninits");
			asc_int(g_REC_ninits (p));
			short_io (&g_REC_ninits (p));
			asc_field("REC_npaths");
			asc_int(g_REC_npaths (p));
			short_io (&g_REC_npaths (p));
			asc_field("REC_maxpfld");
			asc_int (g_REC_maxpfld (p));
			short_io (&g_REC_maxpfld (p));
			asc_field ("REC_vsize");
			asc_int   (g_REC_vsize (p));
			short_io  (&g_REC_vsize (p));
			break;

		case XRENOBJ:
			asc_field("rentype");
			ac_io (&g_rentype (p));
			asc_field("ROBJ_alloc");
			asc_int(g_ROBJ_alloc (p));
			short_io (&g_ROBJ_alloc (p));
			asc_field("ROBJ_offset");
			asc_int(g_ROBJ_offset (p));
			short_io (&g_ROBJ_offset (p));
			break;

		case XRENPACK:
			asc_field("renname");
			ac_io (&g_renname (p));
			break;

		case XRENSUB:
		case XENTRY:
			asc_field ("rettype");
			ac_io (& g_rettype (p));
			short_io (&g_entry_nr (p));
			short_io (&g_ENTR_off (p));
			break;

		case XRETURN:
			asc_field("enclsub");
			ac_io (& g_enclsub (p));
			break;

		case XSCC:
			asc_int (g_andthen (p));
			short_io (& g_andthen (p));
			break;

		case XSELECT:
			asc_field ("types");
			ac_io     (& g_types (p));
			asc_field ("entity");
			ac_io (& g_entity (p));
			break;

		case XSEPARATE:
			break;

		case XSLICE:
			asc_field ("types");
			ac_io     (&g_types (p));
			asc_field("SLI_Doff");
			asc_int(g_SLI_Doff (p));
			short_io (&g_SLI_Doff (p));
			break;

		case XSTUB:
			ac_io (&g_stub_spec (p));
			break;

		case XSUB:
			asc_field ("rettype");
			ac_io (&g_rettype (p));
			asc_field("SUBS_retoff");
			asc_int(g_SUBS_retoff (p));
			short_io (&g_SUBS_retoff (p));
			asc_field("SUBS_alloc");
			asc_int(g_SUBS_alloc (p));
			short_io (&g_SUBS_alloc (p));
			asc_field("SUBS_offset");
			asc_int(g_SUBS_offset (p));
			short_io (&g_SUBS_offset (p));
			break;

		case XSUBBODY:
			asc_field("specif");
			ac_io (& g_specif (p));
			set_to (g_specif (p), p);
			asc_field("SUB_level");
			asc_int(g_SBB_level (p));
			short_io (&g_SBB_level (p));
			short_io (&g_SBB_Moff (p));
			short_io (&g_SBB_MCoff (p));
			break;

		case XSUBCALL:
			break;

		case XSUBTYPE:
			ac_io (&g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			break;

		case XNEWTYPE:
			ac_io (&g_type_spec (p));
			if (reading) {
			   set_to (g_type_spec (p), p);
			}
			asc_field ("old_type");
			ac_io (&g_old_type (p));
			short_io (&g_mark (p));
			break;

		case XINHERIT:
			asc_field ("is_hidden");
			asc_int   (g_is_hidden (p));
		        short_io  (&g_is_hidden (p));
			asc_field ("old_type");
			ac_io (& g_old_type (p));
			asc_field ("inhtype");
			ac_io (&g_inh_type (p));
			asc_field ("inh_oper");
			ac_io (&g_inh_oper (p));
			break;

		case XTHUNK:
			break;

		case XTRIPLE:
			asc_field ("triple");
			ac_io (& g_tripsub (p));
			asc_field ("type ");
			ac_io (&g_triptype (p));
			asc_field ("dtype");
			ac_io (&g_tripdtype (p));
			break;

		case XTYPECONV:
			asc_field("newtype");
			ac_io (& g_newtype (p));
			asc_field("TCON_Doff");
			asc_int(g_TCON_Doff (p));
			short_io (&g_TCON_Doff (p));
			break;

		case XTAGSTAT:
			break;

		case XUSE:
			asc_field("packname");
			ac_io (&g_packname (p));
			break;

		case XVARIANT:
			asc_field("VAR_ffld");
			asc_int(g_VAR_ffld (p));
			short_io (&g_VAR_ffld (p));
			asc_field("VAR_fpath");
			asc_int(g_VAR_fpath (p));
			short_io (&g_VAR_fpath (p));
			asc_field("VAR_fqfld");
			asc_int(g_VAR_fqfld (p));
			short_io (&g_VAR_fqfld (p));
			break;

		case XWHENITEM:
			break;

		case XWITH:
			break;

		default:
			sys_error("strange record kind: %d\n", d);
		
		}
	}
	  else {
		mark_flag = TRUE;
	}
#ifdef ASC
	if (!reading)
	if (mark_flag) {
		col -= INDENT;
	} else {
		col += INDENT;
	}
#endif ASC

	close_rec (f);
}

void	set_to (x, y)
register ac x, y;
{
	if (x == NULL)
	   return;

	switch (g_d (x)) {
	   case XINCOMPLETE:
		s_complete (x, y);
		return;

	   case XPRIVTYPE:
		s_impl (x, y);
		return;

	   case XSUB:
		s_body_imp (x, y);
		return;

	   case XTASKTYPE:
		s_taskbody (x, y);
		return;

	   case XPACKAGE:
		s_pack_body (x, y);
		return;

	   case XOBJECT:
		return;		/* to be finished some day	*/
	   DEFAULT (("set_to: %d\n", g_d (x)));
	}
}

