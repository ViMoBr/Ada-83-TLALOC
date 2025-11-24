
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
#include	"../h/tokens.h"
#include <stdio.h>
/*
 *	Forward (static) declarations
 */
static	void	gentrace	();
static	void	mk_prefix	();

/*
 * Generating code for run-time tracing
 */

static
void	gentrace (v)
char *v;
{
	int	l = new_lab ();

	new_expr ();
	CALL (VOID);
	   ICON (0, PF_INT, "_printf");
	   LICON (l);

	OUTDATA;

	deflab (l);
	OUT (("&%d	%s	\n", ICSTRING, v));
	OUTEVEN;
	OUTTEXT;
}

/*
 *	For each Ada statement, the following
 *	"tracing code" is generated
 */
void	genstattrace (srcf, blk, line)
char	*srcf;
ac	blk;
int	line;
{
	char	hulp [100];
   
	sprintf (hulp, "%s: %d\\n", srcf, line);

	gentrace (hulp);
}

void	genproctrace (text, srcf, blk, line)
char	*text,
	*srcf;
ac	blk;
int	line;
{
	char	hulp [100],
		hulp2 [100];

	mk_prefix (blk, hulp);
	sprintf (hulp2, "%s %s %s %d\\n",text, srcf, hulp, line);

	gentrace (hulp2);
}

/*
 *	The next function should yield the whole static
 *	path from STANDARD to the current function
 */
static
void	mk_prefix (c, s)
ac	c;
char	*s;
{
	char	v[100];

	if (c == NULL)
	   *s = 0;
	else
	   if (!has_tag (c) ||g_tag (c) == NULL)
              mk_prefix (g_enclunit (c), s);
	   else
	   {  mk_prefix (g_enclunit (c), v);
	      sprintf (s, "%s.%s", v, g_tag (c));
	   }
}

void	sdb_proc (x, v)
ac	x;
char	*v;
{
	static int proc_cnt = 1;
	char	vv[100];

	if (sdb_code) {
	      curr_line = g_lineno (x);
	      sprintf (vv, "%s.%d", g_tag (g_specif (x)), proc_cnt ++);
	      OUT (("&%d	%s\n", ICDEF, vv));
	      OUT (("&%d	%d	\n", ICSCL, 2));
	      OUT (("&%d	%d	\n", ICTYPE, 36));
	      OUT (("&%d	%s	\n", ICSYMV, v));
	      OUT (("&%d	\n",	ICENDEF));
	      OUT (("&%d	%d	\n", ICLN, curr_line));
	      OUT (("&%d	.bf	\n", ICDEF));
	      OUT (("&%d	%d	\n", ICLINE, curr_line));
	      OUT (("&%d	\n", ICENDEF));
	}
}

void	sdb_block (x)
ac	x;
{
	static	int blok_cnt = 1;
	static	char v [100];
	int	lab;

	if (sdb_code) {
	   lab = new_lab ();
	   deflab (lab);
	   curr_line = g_lineno (x);
	   if (g_tag (x) != NULL) {
	      sprintf (v, "%s", g_tag (x));
	      OUT (("&%d	%s\n", ICDEF, v));
	      OUT (("&%d	%d	\n", ICSCL, 2));
	      OUT (("&%d	%d	\n", ICTYPE, 36));
	      OUT (("&%d	.L%d	\n", ICSYMV, lab));
	      OUT (("&%d	\n", ICENDEF));
	   }
	   OUT (("&%d	%d	\n", ICLN, curr_line));
	   OUT (("&%d	.bb	\n", ICDEF));
	   OUT (("&%d	%d	\n", ICLINE, curr_line));
	   OUT (("&%d	\n", ICENDEF));
	}
}

void	sdb_end ()
{
	if (sdb_code) {
	   OUT (("&%d	%d	\n", ICLN, curr_line + 1));
	   OUT (("&%d	.eb	\n", ICDEF));
	   OUT (("&%d	%d	\n", ICLINE, curr_line + 1));
	   OUT (("&%d	\n", ICENDEF));
	}
}

void	sdb_procend ()
{
	if (sdb_code) {
	   OUT (("&%d	%d	\n", ICLN, curr_line + 1));
	   OUT (("&%d	.ef	\n", ICDEF));
	   OUT (("&%d	%d	\n", ICLINE, curr_line + 1));
	   OUT (("&%d	\n", ICENDEF));
	}
}

