#include	"../h/print.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"

extern	struct tt_arr *Maacacw;

/*
 *	Runtime support for various predefined attributes
 *
 *	DELFT ADA GROUP
 */
struct enum_list {
	struct enum_list *n_enum;
	short enumval;
	char enumtag [1];
};

extern	char	*_short;
extern	char	*_integer;
extern	char	*_long;
extern	char	*_std_boolean;

static
char	*mk_val (s, d)
char	*s;
register struct ld_arr *d;
{
	register int i;

	i = 0;
	while (s [i] != (char)0)
	   i ++;

	d -> dtag = VD_ARR;
	d -> ttp  = &Maacacw;	/* string (yuck) */
	d -> vd_vsize = i;
	d -> vd_e_size = 1;
	d -> ld_i_x [0]. vd_i_lo = 0;
	d -> ld_i_x [0]. vd_i_hi = i - 1;

	return s;
}

static
char	*bool_cv (v, d)
char	v;
struct ld_arr *d;
{
	if (v == 0)
	   return mk_val ("FALSE", d);
	if (v == 1)
	   return mk_val ("TRUE", d);
	return mk_val ("FOUTE BOEL", d);
}


static
char	*integer_cv (v, d)
long	v;
struct	ld_arr	*d;
{
	static char s [20];
	sprintf (s, "%-d", v);
	return mk_val (s, d);
}

_Image (v, bt, d)
long v;
struct ld_arr *bt;	/* basetype descriptor	*/
struct ld_arr *d;	/* targetstring descriptor	*/
{
	struct enum_list *p;
/*
 *	find in the descriptor bt the, either
 *	implicitly or explicitly encoded representation
 *	of a value
 */
	if (bt == &_short || bt == &_integer || bt == &_long) {
	   return integer_cv ((long)v, d);
	}
	else
	if (bt == &_std_boolean) {
	   return bool_cv ((char)v, d);
	}
/*
 *	If we are here, we have a user defined enumeration type
 *	The descriptor is followed by a sequence of
 *	list elements
 */
	p = (struct enum_list *)((char *)bt + sizeof (struct ld_bit));

	while (p != (struct enum_list *)0 && p -> enumval != v)
	   p = p -> n_enum;

	if (p == (struct enum_list *)0) {
	   printf ("Cannot happen");
	   abort ();
	}

	return mk_val (p -> enumtag, d);
}

int
_Width (t, bt)
struct ld_bit	*t;
struct ld_bit	*bt;
{
	if (bt == &_short)
	   return integer_width (t);
	if (bt == &_integer)
	   return integer_width (t);
	if (bt == &_long)
	   return integer_width (t);
	if (bt == &_std_boolean)
	   return boolean_width (t);

	return enumeration_width (t);
}

int	numofdigs (l)
int l;
{
	return 10;
}

int	integer_width (t)
register struct ld_bit *t;
{
	register int i;
	register long j;

	j = 1;	/* 10 ^ 0		*/
	for (i = 0; i <= numofdigs (2147483647); i ++) {
	   j = j * 10;
	   if (t -> ld_r. cd_lo > -j && t -> ld_r. cd_hi < j)
	      return i + 1;

	}

	return i + 1;
}

static
int	in_subtype (p, t)
struct enum_list *p;
struct ld_bit *t;
{
	return t -> ld_r. cd_lo <= p -> enumval &&
	       p -> enumval <= t -> ld_r. cd_hi;
}

static
int	enumsize (s)
register char *s;
{
	register int i = 0;

	while (*s ++ != 0) i ++;
	return i;
}

static
int	set_max (max, p)
int	max;
register struct enum_list *p;
{
	int h = enumsize (p -> enumtag);
	return h > max ? h : max;
}

int	boolean_width (t)
struct ld_bit *t;
{
	if (t -> ld_r. cd_lo > 0)
	   return 5;		/* sizeof FALSE		*/
	if (t -> ld_r. cd_hi < 1)
	   return 4;		/* sizeof TRUE		*/
	return 5;
}

int	enumeration_width (t, bt)
struct ld_bit *t;
struct ld_bit *bt;
{
	/* with the current encoding there does not seem to be
	 * another way than to compute the max size
	 */
	register struct enum_list *p;
	register int max = 0;

	p = (struct ld_bit *)((char *)bt + sizeof (struct ld_bit));

	while (p != 0) {
	   if (in_subtype (p, t))
	      max = set_max (max, p);
	   p = p -> n_enum;
	}

	return max;
}

#define is_blank(c) (0 <= c && c <= ' ')
static char
upper (c)
char c;
{
	if ('a' <= c && c <= 'z')
	   c = c - 'a' + 'A';
        return c;
}

static void
mk_cs (s, l, t)
char *s;
int l;
char *t;
{
   register int i = 0;
   register char *tt = t;

   while (i < l && is_blank (s [i])) i ++;
   if (s [i] == '\'')
      while (i < l && !is_blank (s [i])) *tt ++ = s [i ++];
   else
      while (i < l && !is_blank (s [i])) *tt ++ = upper (s [i ++]);
   *tt = 0;
}

static
int	mk_v2 (t, s, l)
struct ld_bit *t;
char	*s;
int l;
{
	register struct enum_list *p;
	char hulpstring [50];

	mk_cs (s, l, hulpstring);

	if (t == &_short || t == &_integer || t == &_long)
	   return atol (hulpstring);

	if (t == &_std_boolean) {
	   if (eq_s (hulpstring, "FALSE"))
	      return 0;
	   if (eq_s (hulpstring, "TRUE"))
	      return 1;
	   _raise (&_constraint_error);
	}
	p = (struct ld_bit *)((char *)t + sizeof (struct ld_bit));

	while (p != (struct ld_bit *)0) {
	   if (eq_s (hulpstring, p -> enumtag))
	      return p -> enumval;
	   p = p -> n_enum;
	}

	_raise (&_constraint_error);
}
long	_Value (t, bt, s, d)
struct	ld_bit	*t;
struct	ld_bit	*bt;
char	*s;
struct	ld_arr	*d;
{
/*
 *	Convert the string s to a value of the scalar
 *	type bt (subtype t)
 *	raise constraint error if no match or outside constraints
 */
	long	x = mk_v2 (bt, s, d -> vd_vsize);
	if (t -> ld_r. cd_lo <= x &&
	    x <= t -> ld_r. cd_hi)
	   return x;

	_raise (&_constraint_error);
}

static
int	eq_s (s1, s2)
register char *s1, *s2;
{
	while (*s1 == *s2) {
	   if (*s1 == (char)0)
	      return -1;
	   s1 ++;
	   s2 ++;
	}

	return 0;
}

