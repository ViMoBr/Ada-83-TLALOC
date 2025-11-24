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

#include	<stdio.h>
#ifndef GMX_OLD
#include	<math.h>
#endif
#include	"../h/print.h"

static	int	sc_isdigit ();
static	long	sc_atol ();
static	double	sc_atof ();
static	int	sc_ctoi ();

void	sc_int (in, out)
char	*in,
	*out;
{
	long n;

	PRINTF (printf ("sc_int:%s; atol:", in));
	n = sc_atol (in, 10);
	sprintf (out, "%d", n);
	PRINTF (printf ("; sc_int: %s\n", out));
}

void	sc_real (in, out)
char	*in,
	*out;
{
	double n;

	PRINTF (printf ("sc_real:%s; atof:", in));
	n = sc_atof (in, 10);
	sprintf (out, "%f", n);
	PRINTF (printf ("; sc_real: %s\n", out));
}

void	sc_b_int (in, out)
char	*in,
	*out;
{
	char	*p;
	int	base;
	long	n;

	PRINTF (printf ("sc_b_int:%s; atol:", in));
	for (p = in; *p != '#'; p++)
		/* do noting */;
	*p++ = '\0';

	base = atol (in, 10);
	PRINTF (printf ("; base = %d", base));

	if (base < 2 || base > 16) {
	   error ("illegal base in based number %d", base);
	   base = 2;
	}

	PRINTF (printf ("; atol:"));
	n = sc_atol (p, base);

	sprintf (out, "%d", n);
	PRINTF (printf ("; sc_b_int: %s\n", out));
}

void	sc_b_real (in, out)
char	*in,
	*out;
{
	char	*p;
	int	base;
	double	n;

	PRINTF (printf ("sc_b_real:%s; atol:", in));
	for (p = in; *p != '#'; p++)
		/* do nothing */;
	*p++ = '\0';

	base = sc_atol (in, 10);
	PRINTF (printf ("; base = %d", base));

	if (base < 2 || base > 16) {
	   error ("illegal base in based number %d", base);
	   base = 2;
	}

	PRINTF (printf ("; atof:"));
	n = sc_atof (p, base);
	sprintf (out, "%f", n);
	PRINTF (printf ("; sc_b_real: %s\n", out));
}

#include <math.h>

static
double	sc_atof (p, base)
char	*p;
int	base;
{
	int	c,
		nd,
		eexp,
		exp,
		negexp,
		bexp;
	double	fl,
		flexp,
		exp5;
	double	big = 72057594037927936.;  /*2^56*/
	extern	double ldexp();

	exp = 0;
	fl = 0;
	nd = 0;

	while (sc_isdigit(c = *p++, base)) {
	   PRINTF (printf ("%c", c));
	   if (c == '_')
	      continue;
	   if (fl<big)
	      fl = 10*fl + sc_ctoi (c, base);
	   else
	      exp++;
	   nd++;
	}

	if (c == '.') {
	   PRINTF (printf ("%c", c));
	   while (sc_isdigit(c = *p++, base)) {
	      PRINTF (printf ("%c", c));
	      if (c == '_')
		 continue;

	      if (fl<big) {
		 fl = base * fl + sc_ctoi (c, base);
		 exp--;
	      }

	      nd++;
	   }
	}

	if (c == '#') {
	   PRINTF (printf ("%c", c));
	   c = *p++;
	}

	negexp = 1;
	eexp = 0;
	if ((c == 'E') || (c == 'e')) {
	   PRINTF (printf ("%c", c));
	   if ((c= *p++) == '+')
	      PRINTF (printf ("%c", c));
	   else if (c=='-') {
	           PRINTF (printf ("%c", c));
		   negexp = -1;
		}
		else
		   --p;

	   while (sc_isdigit(c = *p++, base)) {
	      PRINTF (printf ("%c", c));
	      if (c == '_')
		 continue;
	      eexp = 10 * eexp + (c - '0');
	   }

	   if (negexp<0)
	      eexp = -eexp;
	   exp = exp + eexp;
	}

	negexp = 1;

	if (exp<0) {
	   negexp = -1;
	   exp = -exp;
	}

#ifdef GMX_OLD
	if ((nd + exp * negexp) < - LOGHUGE) {
#else
	if ((nd + exp * negexp) < - HUGE) {
#endif
	   fl = 0;
	   exp = 0;
	}

	flexp = 1;
	exp5 = 5;
	bexp = exp;
	for (;;) {
	   if (exp&01)
	      flexp *= exp5;

	   exp >>= 1;

	   if (exp==0)
	      break;

	   exp5 *= exp5;
	}

	if (negexp<0)
	   fl /= flexp;
	else
	   fl *= flexp;

	fl = ldexp(fl, negexp*bexp);

	return fl;
}

static
long	sc_atol(p, base)
char	*p;
int	base;
{
	int	c,
		pow;
	long	n;

	n = 0;
	while (sc_isdigit(c = *p++, base)) {
	   PRINTF (printf ("%c", c));
	   if (c == '_')
	      continue;

	   n = n * base + sc_ctoi (c, base);
	   if (n < 0 && n != -n) {
	      warning ("integer constant too large");
	      return -n;
	   }
	}

	if (c == '#') {
	   PRINTF (printf ("%c", c));
	   c = *p++;
	}

	if (c == 'e' || c == 'E') {
	   PRINTF (printf ("%c", c));
	   pow = 0;
	   if (*p == '+') {
	      PRINTF (printf ("+"));
	      p++;
	   }

	   while (sc_isdigit(c = *p++, 10)) {
	       PRINTF (printf ("%c", c));
	       if (c == '_')
		  continue;

	       pow = 10 * pow + (c - '0');
	       if (pow < 0) {
		  warning ("integer constant too large");
		  return n;
	       }
	   }

	   while (pow-- != 0) {
	      n *= base;
	      if (n < 0) {
		 warning ("integer constant too large");
		 return n;
	      }
	   }
	}

	return n;
}

static
int	sc_ctoi (c, base)
int	c,
	base;
{
	if ('0' <= c && c <= '9')
	   c -= '0';
	else
	if ('a' <= c && c <= 'f')
	   c -= 'a' - 10;
	else
	if ('A' <= c && c <= 'F')
	   c -= 'A' - 10;
#ifdef DEBUG
	else
	{
	   error ("ctoi: not a digit %c", c);
	   return 1;
	}
#endif DEBUG
	if (c >= base) {
	   error ("%d: not a digit in base %d", c, base);
	   return 1;
	}

	return c;
}

static
int	sc_isdigit (c, base)
int	c,
	base;
{
	if (c == '_')
	   return 1;

	if (base <= 10)
	   if ('0' <= c && c < '0' + base)
	      return 1;
	   else
	      return 0;
	else
	   if (('0' <= c && c <= '9') ||
		    ('a' <= c && c <= 'a' + base - 11) ||
		    ('A' <= c && c <= 'A' + base - 11))
	      return 1;
	   else
	      return 0;
}

int	sc_strlen (s)
char	*s;
{
	int	n;

	for (n = 0; *s++ != '\0'; n++);
	return n;
}

