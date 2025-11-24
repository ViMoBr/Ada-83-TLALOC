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

#
#include	"includes.h"
#include	"../h/view.h"
/*
 *	Forward (static) declarations
 */
static	void	dump_core	();
static	void	print_nice	();
static	void	print_leftcontext	();

/*
 *	pass1 uses yyin as name for its input stream, so
 *	everyone will use it. However, since in pass 1
 *	that variable is declared in lex.yy.c, it cannot
 *	be redeclared here, by convention it will be declared
 *	in the scanner modules of the passes
 */
int verbose = 0;
#define PRINTVERBOSE if (verbose) printf

extern	char	*mktemp		();
FILE	*yyin;
FILE	*outfile;
char	*m_prog;
char	*standard_tree	= "std_ps.t";
char	*outname	= NULL;
/* char	*inter_file	; */
char	lib_vector [1000] = {0};	/* communication string		*/
int	yylineno;
/*
 *	Options:
 */
char	backflag	= TRUE;
bool	sdb_code	= TRUE;
int	tracelevel	= 0;
char	eflag		= FALSE;	/* edit directly after an error */
int	no_of_compiled	= 0;
int	errors		= 0;
int	errline		= 0;


/*
 *	Operations on library communication vector
 */
void	libv_init ()
{
	lib_vector [0] = 0;
}

void	cat_to (s1, s2)
char	*s1,
	*s2;
{
	char	*s = s1;

	while (*s != '\0') s++;

	while (*s2 !=  '\0') *s ++ = *s2 ++;
	*s = '\0';
}

char	*tmpvec (s)
char	*s;
{
	static char p [100];

	p [0] = 0;
	cat_to (p, s);
	return p;
}

char	*add_tmpvec (p, s)
char	*p,
	*s;
{
	cat_to (p, s);
	return p;
}

void	s_add (f, s)
char	*f,
	*s;
{
	char vector [100];

	sprintf (vector, f, s);
	cat_to  (lib_vector, vector);
}

void	s_d_add (f, s, n)
char	*f,
	*s;
int	n;
{
	char vector [100];

	sprintf (vector, f, s, n);
	cat_to (lib_vector, vector);
}

void	d_add (f, n)
char	*f;
int	n;
{
	char vector [100];

	sprintf (vector, f, n);
	cat_to (lib_vector, vector);
}

/*
 *	Give inter_file a reasonable value
 *
void	init_tempfile (char * target)
{
	static char model [] = "/tmp/ada%c%c%d";
	static char curl = 'A';
	static char curr = 'A';
	char*	help1, *help2;

	help1 = model;
	help2 = target;

	while ((*help2 ++ = *help1++));

	if (curr > 'Z') {
	   curr = 'A';
	   curl ++;
	   if (curl > 'Z') {
	      error ("Too many intermediate files, compilation aborted\n");
	      exit (123);
	   }
	}

	sprintf (target, model, curl, curr ++, getpid ());
}
*/

static
void	compile (f)
char	*f;
{
	int	status	= TRUE;

	if (f == NULL)
	   yyin = stdin;
	else
	if ((yyin = fopen (f, "r")) == NULL) {
	   error ("main: cannot open %s\n", f);
	   exit (1);
	}

	no_of_compiled ++;

	if (f == NULL)
	   m_prog = "standard_input";
	else
	   m_prog = f;

	yylineno = 1;
	fprintf (stderr,
           "Delft Ada- compiler (c) Delft University of Technology 1987/88\n");
	fprintf (stderr,
               "(c) Ada to C version of 1995\n");

	fprintf (stderr,
               "Compiling file %s\n", m_prog);

	if (yyparse () != 0 || errors != 0) {
	   fail (mainlun, &status);
	   fclose (stdout);
	   fclose (stderr);
	   fclose (yyin);
	   exit (21);
	} else
	   fclose (yyin);
}

main (argc, argv)
int	argc;
char	*argv[];
{
	char	*inname;

	argv ++;
	argc --;
	signal(3, dump_core);
	signal(4, dump_core);
	signal(10, dump_core);
	signal(11, dump_core);

	if (argc < 1) {
	   compile (NULL);
	}
	else
	while (argc > 0 && errors == 0) {
	   if ((*argv) [0] == '-') {		/* guess its a flag	*/
		      switch ((*argv) [1]) {
			case 'v':
		           verbose++;
			   break;

			case 'p':
			   argv++;
			   argc--;
			   set_pl_name (argv[0]);
			   break;

			case 't':
			   tracelevel =  atoi ( &argv [0][1]);
			   break;

			case 'n':
		           backflag = FALSE;
			   break;

			case 'g':
			   sdb_code = FALSE;
			   break;

			case 'e':
			   eflag = TRUE;
			   break;

			case 'o':	/* other outputname */
			   outname = argv [1];
		           argc --; argv ++;
			   break;
			   
		        default:
				;
		      }
		}
		else
		     compile (argv [0]);

	           argv ++; argc --;
	     }

	     if (no_of_compiled == 0)
	        compile (NULL);
}

static
void	start_editor (s, l)
char	*s;
int	l;
{
	char vec [100];
        sprintf (vec, "vi +%d %s\n", l, s);
	printf (vec);
	system (vec);
	exit (222);
}

void	print_names (s)
ac	s;
{
	ac	t1;

	if (s == NULL)
	   return;

	ASSERT (g_d (s) == XSET, ("print_names:1"));

	if (yylineno > errline)
	   FORSET (t1, s)
	      print_nice (t1);
}


static
void	print_nice (t)
ac	t;
{
	ASSERT (t != NULL, ("print_nice:1"));

	t = base_subtype (t);

	if (!has_tag (t))
	   return;
	
	if (g_tag (t) == NULL)
	   return;

	print_leftcontext (g_enclunit (t));
	fprintf (stderr, "%s\n", g_tag (t));
}

static
void	print_leftcontext (t)
ac	t;
{
	if (t == NULL)
	   return;

	if (has_tag (t) && g_tag (t) != NULL)
	   fprintf (stderr, "%s.", g_tag (t));

	print_leftcontext (g_enclunit (t));
}


void	error (str, param1, param2)
char	*str,
	*param1,
	*param2;
{
	if (yylineno > errline) {
	   fprintf (stderr, "error line %d: ", yylineno);
	   fprintf (stderr, str, param1, param2);
	   fprintf (stderr, "\n");
	}
	if (eflag)
	   start_editor (m_prog, yylineno);

	errors++;
	errline =  yylineno;
}

static
void	dump_core ()
{
	printf ("Call a UNIX/Ada expert, unrecoverable error\n");
	signal (4, 0);
	_cleanup ();
	abort ();
}

void	sys_error (a, b)
char	*a,
	*b;
{
	printf (a, b);
	dump_core();
}


void	scan_error (a, b)
char	*a,
	*b;
{
	fprintf (stderr, "scan_error line %d: %s %s\n",  yylineno, a, b);
	errors++;
}

void	warning (a, b)
char	*a,
	*b;
{
	if ( yylineno > errline) {
	   fprintf (stderr, "warning line %d: ",  yylineno);
	   fprintf (stderr, a, b);
	   fprintf (stderr, "\n");
	}
}


void
generate_code (ac	mainlun,
	       ac	with_list,
	       ac	tree,
	       int	kind,
	       int	errors)
{
	int	a_s = TRUE;
	ac	z;
	
	if (errors != 0)
	   return;

	if (mainlun == STD_LUN) {   /* special treatment	*/
           generate_C ("std_ps.c", NULL, tree, STD_LUN);
	   writ_tree ("std_ps.t", NULL, tree, STD_LUN);
	   return;	/* don't update libs */
	}
	else
	if (kind & GEN) {	/* generic unit		*/
	   writ_tree (t_name (mainlun, &a_s), with_list, tree, mainlun);

        if (!a_s) {
           fail ((short)mainlun, &a_s);
           exit (35);
        }
	   PRINTVERBOSE ("lib_vector = %s\n", lib_vector);
	}
	else
	if (backflag) {
	    if (outname == NULL)
	       outname = c_name (g_tag (tree), &a_s);
            generate_C (outname, with_list, tree, mainlun);
	    writ_tree ( t_name (g_tag (tree), &a_s), with_list, tree, mainlun);
            if (!a_s) {
               fail ((short)mainlun, &a_s);
               exit (35);
            }
	}
	else
	    writ_tree ( t_name (g_tag (tree)), with_list, tree, mainlun);

        FORALL (z, with_list) {
           if (g_d (z) == XWITH)
              s_add (":#wu:%s", g_tag (g_withunit (z)));
        }

        PRINTVERBOSE ("lib_vector = %s\n", lib_vector);
        update_lib (lib_vector, &a_s);
        if (!a_s) {
           fail ((short)mainlun, &a_s);
           exit (35);
        }
	PRINTVERBOSE ("back end run completed\n");
}


void	say_start (s1, s2)
char	*s1,
	*s2;
{
	fprintf (stderr,"*** compiling unit %s (kind = %s) line = %d\n",
                                                    s2, s1,  yylineno);
}

static int xc = 0;
static
void	ntabs (n)
int	n;
{
	while (--n > 0)
	   PRINTVERBOSE (" -");
}


void	new_s (x)
ac	x;
{
	if (x == NULL)
	   return;

	switch (g_d (x)) {
	case XBLOCK:
		ntabs (++xc);
		PRINTVERBOSE ("Block\n");
		break;

	case XTASKTYPE:
		ntabs (++xc);
		PRINTVERBOSE ("Task specification %s\n", g_tag (x));
		break;

	case XPACKAGE:
		ntabs (++xc);
		PRINTVERBOSE ("Package specification %s\n", g_tag (x));
		break;

	case XPACKBODY:
		ntabs (++xc);
		PRINTVERBOSE ("Package body %s\n", g_tag (x));
		break;

	case XSUBBODY:
		ntabs (++xc);
		PRINTVERBOSE ("Sub program body %s\n", g_tag (x));
		break;

	case XTASKBODY:
		ntabs (++xc);
		PRINTVERBOSE ("Task body %s\n", g_tag (x));
		break;

	default:
		break;
	}
}

void	old_s (x)
ac	x;
{
	if (x == NULL)
	   return;

	switch (g_d (x)) {
	case XBLOCK:
		ntabs (xc--);
		PRINTVERBOSE ("end of block\n");
		break;

	case XTASKTYPE:
		ntabs (xc--);
		PRINTVERBOSE ("End of task specification %s\n", g_tag (x));
		break;

	case XPACKAGE:
		ntabs (xc--);
		PRINTVERBOSE ("End of package specification %s\n", g_tag (x));
		break;

	case XPACKBODY:
		ntabs (xc--);
		PRINTVERBOSE ("End of package body %s\n", g_tag (x));
		break;

	case XSUBBODY:
		ntabs (xc--);
		PRINTVERBOSE ("End of sub program body %s\n", g_tag (x));
		break;

	case XTASKBODY:
		ntabs (xc--);
		PRINTVERBOSE ("End of task body %s\n", g_tag (x));
		break;

	default:
		break;
	}
}

