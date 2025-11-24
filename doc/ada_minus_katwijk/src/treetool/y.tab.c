# define XUNION 257
# define XRECORD 258
# define SEMCOL 259
# define IDENT 260
# define STARREF 261
# define COMMA 262
# define LBRACK 263
# define RBRACK 264
# define SUB 265
# define BUS 266
# define NUMBER 267
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 94 "treegen.y"

typedef	char	*pchar;

char	*mk_tag ();
int	line_no = 0;
#define	DEPTH	20
#define	NNAMES	600
#define	MAXTYPENAME	30
#define	FOR(x, y)	for (x = 0; x < y; x ++)

#include	<stdio.h>
#include	"lex.yy.c"

/*
 *	Stack of "open" record structures
 */
struct bla {
	char	*rectag;
	int	recflags;
};

struct recstack {
	struct bla X [DEPTH];
	int	top;
} _recstack;

struct {
	char	*names[NNAMES];
	int	filp;
} fieldnames;

init_fields ()
{
	_recstack. top = -1;
	fieldnames. filp = 0;
	printf ("\n");
}

new_untab (x, y)
char	*x;
int	y;
{
	if (_recstack. top >= DEPTH) {
	   warning ("Help, stack full");
	   exit (21);
	}

	_recstack. top ++;
	_recstack. X [_recstack. top]. rectag = x;
	_recstack. X [_recstack. top]. recflags = y;
	return _recstack. top;
}

pop_untab (x)
int x;
{

	if (_recstack. top != x) {
	   printf ("Synchronization error\n");
	   exit (22);
	}
	_recstack. top --;
}


int	does_exist (t)
register char *t;
{
	int i;
	FOR (i, fieldnames. filp) {
	    if (eq_tags (t, fieldnames. names [i]))
	       return (-1);
	}
	return 0;
}

add_field (t)
register char *t;
{
	fieldnames. filp ++;
	fieldnames. names [fieldnames. filp] = t;
}

char	*mk_tag (s, l)
register char *s;
register int l;
{
	register int d;
	register char *c = calloc (1, l);

	if (c == (char *)-1) {
	   printf ("Ran out of memory");
	   exit (23);
	}
	FOR (d, l + 1) {
	   c [d] = s [d];
	}

/*
	printf ("Added %s\n", c);
 */
	return c;
}

warning (s, p)
char	*s;
int	p;
{
	printf (s, p);
}

char	*new_string (s)
char	*s;
{
	char	*c = calloc (1, MAXTYPENAME);

	if (c == (char *)-1) {
	   printf ("Ran out of memory\n");
	   exit (24);
	}

	c [0] = '\0';
	return strcat (c, s);
}


sel_code (x)
int x;
{
	if (x < 0) {
	   printf ("Help, x < 0");
	   abort ();
	}

	if (x == 0) {
	   if (_recstack. X [0]. recflags == XRECORD)
	      printf ("(( *(struct %s *)x)", _recstack. X [_recstack. top]. rectag);
	   else
	      printf ("((*x)");
	   return;
	}

	sel_code (x - 1);
	printf (".%s", _recstack. X [x]);
}


pr_access (x, y, z)
int x;
char *y;
char *z;
{

	printf ("#define	g_%s(x)\t", z);
	sel_code (x);
	printf (".%s", z);
	printf (")\n");
	printf ("#define	s_%s(x, y)\t", z);
	sel_code (x);
	printf (".%s = ((%s)y))\n", z, y);
}
char	*gettag (x)
int x;
{
/*
	return _recstack. X [_recstack. top]. rectag;
 */
	return _recstack. X [0]. rectag;
}

int	eq_tags (x, y)
register char *x, *y;
{
	while (*x == *y) {
	   if (*x == '\0')
	      return -1;
	   if (*y == '\0')
	      return -1;
	   x ++;
	   y ++;
	}

	return 0;
}


main (argc, argv)
int	argc;
char	**argv;
{
	if (argc < 2) {
	   printf ("Usage %s: %s filename\n", argv [0], argv [0]);
	   exit (101);
	}

	yyin = fopen (argv [1], "r");
	if (yyin == (FILE *)-1) {
	   printf ("cannot open %s\n", argv [1]);
	   exit (102);
	}
	yyparse ();
}

yyerror ()
{
	printf ("Unrecoverable error (%d)\n", line_no);
	exit (25);
}


#ifndef ATT_SIZE
#define ATT_SIZE	150
#endif

union _attr_elem {
  int  _t0;
  pchar  _t1;
} _attr_stack [ATT_SIZE];
union _attr_elem *_ap =      &_attr_stack [ATT_SIZE - 1];
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
short termi[] ={

  -1,   0,  -1,  -1,  -1,  -1, 260, 260, 260, 260,
 264,  -1, 260, 260,  -1, 264, 263, 263, 260,  -1,
 259,  -1, 267,  -1, 264, 260,  -1,  -1, 259,  -1,
  -1, 260, 266, 260, 259,  -1,  -1,  -1, 259,  -1,
  -1 };
# define YYNPROD 21
# define YYLAST 64
short yyact[]={

  32,  23,  21,  37,  29,   8,  22,  14,   8,  27,
  14,  33,  26,   8,  25,  14,  36,  30,  40,  18,
  31,   8,  17,  14,  16,  39,  35,   9,   8,  28,
  10,  11,  13,  20,  12,   7,   6,   5,  15,   4,
   3,   2,  19,   1,  24,   0,   0,  19,   0,   0,
   0,   0,   0,   0,   0,  34,  19,   0,   0,   0,
   0,   0,   0,  38 };
short yypact[]={

-1000,-1000,-1000,-230,-1000,-1000,-237,-237,-236,-238,
-245,-1000,-259,-237,-1000,-250,-251,-254,-256,-1000,
-242,-1000,-267,-1000,-253,-256,-1000,-1000,-233,-1000,
-1000,-244,-263,-256,-234,-1000,-1000,-1000,-241,-1000,
-1000 };
short yypgo[]={

   0,  43,  41,  40,  39,  37,  32,  30,  29,  35,
  31,  34,  33 };
short yyr1[]={

   0,   1,   2,   3,   3,   3,   4,   5,   8,   8,
   6,   9,   7,   7,  10,  10,  12,  12,  11,  11,
  11 };
short yyr2[]={

   0,   2,   0,   0,   2,   2,   5,   5,   1,   0,
   3,   3,   1,   2,   3,   5,   1,   3,   1,   2,
   4 };
short yychk[]={

-1000,  -1,  -2,  -3,  -4,  -5,  -6,  -9, 258, 257,
  -7, -10, -11,  -6, 260,  -7, 260, 260, 264, -10,
 -12, 261, 265, 260,  -7, 264, 263, 263,  -8, 260,
 259, 262, 267, 264,  -8, 259, 260, 266,  -8, 259,
 259 };
short yydef[]={

   2,  -2,   3,   1,   4,   5,   0,   0,   0,   0,
   0,  12,   0,   0,  18,   0,   0,   0,   9,  13,
   0,  19,   0,  16,   0,   9,  10,  11,   0,   8,
  14,   0,   0,   9,   0,   6,  17,  20,   0,   7,
  15 };
	/* @(#)veyaccpar	1.9	86/09/11 */
/*
 *	ERROR RECOVERY MODULE FOR YACC
 *
 *	Delft University of Technology
 */

/*
 *	The program consists of several "packages",
 *	each describing a datastructure.
 *
 *	The old YACC recovery is given as default
 */
#ifdef REPAIR

typedef	short	yyline_t;
yyline_t	rr_lino;

/*
 *	interface to the outside world
 */

#ifdef RRTRACE
/* intermediate "tracing" results will be written on:
 */
#define	TROUTFILE	"/tmp/troutfile"
#endif
static	int rr_errors = 0;
extern	short termfun ();	/* termination function, defined
				 * on the interval 0 .. maxq
				 */
extern	short rr_insert ();	/* defined over the set of terminals */
extern	short rr_skip    ();	/* defined over the set of terminals */


extern	short rr_bonus ();		/* constant function		     */


extern		syntax_error ();
extern	YYSTYPE	creat_val ();
extern		del_symbol ();
extern	char	*rr_token();
extern	yyline_t yylino ();

/*
 *	forward declarations:
 */
static	short	rrnext_tok ();
static	short	get_pf ();
static	short	push ();
static	short	get_wsymbol ();
static	long	Insert_cost ();
static	long	Delete_cost ();
static	long	Continuation();
static	short	pf_elems ();
static	short	win_elems ();
static		rr_repair ();
#ifdef RRTRACE
static	FILE	*rr_trcinit ();
#endif RRTRACE
static		rrtr_close ();


#define	ERRSIZE		1024
static	char	error_diag [ERRSIZE];
static	char	*err_ptr;

/*
 *	definitions:
 */
#define	min(a, b)	(a < b ? a : b)
#define	max(a, b)	(a < b ? b : a)
#define	INFINITE	32000
#define	ACCBONUS	00000
#define	MAXPOST		50
#define	MAXWIND		8
#define	MAXDOM		150
#endif REPAIR

/*
 *	We start just with the standard parser of YACC
 *	Take good care, the "semantic value stack" is
 *	made global here.
 */
# define YYFLAG -1000
# define YYERROR goto yyerrlab
# define YYACCEPT return(0)
# define YYABORT return(1)

/*	parser for yacc output	*/

int yydebug = 0; /* 1 for debugging */
YYSTYPE yyv[YYMAXDEPTH]; /* where the values are stored */
short   yys[YYMAXDEPTH];	/* parse stack */
short	*yyps;
YYSTYPE	*yypvt;
int yychar = -1; /* current input token number */
int yynerrs = 0;  /* number of errors */
short yyerrflag = 0;  /* error recovery flag */

yyparse() {

	short yyj, yym;
	register short yystate, yyn;
	register YYSTYPE *yypv;
	register short *yyxi;
#ifdef REPAIR
	init_input ();
#endif

	yystate = 0;
	yychar = -1;
	yynerrs = 0;
	yyerrflag = 0;
	yyps= &yys[-1];
	yypv= &yyv[-1];

 yystack:    /* put a state and value onto the stack */

	if (yydebug)
	   printf( "state %d, char 0%o\n", yystate, yychar);
	if (++yyps > &yys [YYMAXDEPTH])
	   yyerror ("Yacc stack overflow");
	*yyps = yystate;
	++yypv;
	*yypv = yyval;

 yynewstate:

	yyn = yypact[yystate];

	if( yyn<= YYFLAG ) goto yydefault; /* simple state */

	if (yychar < 0)
#ifdef REPAIR
	   if ((yychar = rrnext_tok ()) < 0)
#else
	   if ((yychar = yylex ()) < 0)
#endif
	      yychar = 0;
	if( (yyn += yychar)<0 || yyn >= YYLAST ) goto yydefault;

	if( yychk[ yyn=yyact[ yyn ] ] == yychar ){ /* valid shift */
		yychar = -1;
		yyval = yylval;
		yystate = yyn;
		if( yyerrflag > 0 ) --yyerrflag;
		goto yystack;
		}
 yydefault:
	/* default state action */

	if( (yyn=yydef[yystate]) == -2 ) {
	        if (yychar < 0)
#ifdef REPAIR
	           if ((yychar = rrnext_tok ()) < 0)
#else
		   if ((yychar = yylex ()) < 0)
#endif REPAIR
	              yychar = 0;
		/* look through exception table */

		for( yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate) ; yyxi += 2 ) ; /* VOID */

		while( *(yyxi+=2) >= 0 ){
			if( *yyxi == yychar ) break;
			}
#ifdef REPAIR
		if ((yyn = yyxi [1]) < 0)
				return rr_errors;
#else
		if ((yyn = yyxi [1]) < 0)
				YYACCEPT;
#endif REPAIR
		}

	if( yyn == 0 ) /* error */
#ifndef REPAIR
	{	/* let YACC clear the mess */
		/* error ... attempt to resume parsing */

		switch( yyerrflag ){

		case 0:   /* brand new error */

			yyerror( "syntax error" );
		yyerrlab:
			++yynerrs;

		case 1:
		case 2: /* incompletely recovered error ... try again */

			yyerrflag = 3;

			/* find a state where "error" is a legal shift action */

			while ( yyps >= yys ) {
			   yyn = yypact[*yyps] + YYERRCODE;
			   if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ){
			      yystate = yyact[yyn];  /* simulate a shift of "error" */
			      goto yystack;
			      }
			   yyn = yypact[*yyps];

			   /* the current yyps has no shift onn "error", pop stack */

			   if( yydebug ) printf( "error recovery pops state %d, uncovers %d\n", *yyps, yyps[-1] );
			   --yyps;
			   --yypv;
			   }

			/* there is no state on the stack with an error shift ... abort */

	yyabort:
			return(1);


		case 3:  /* no shift yet; clobber input char */

			if( yydebug ) printf( "error recovery discards char %d\n", yychar );

			if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */
			yychar = -1;
			goto yynewstate;   /* try again in the same state */

			}

		}
#else
	/* now the new one: */
	/* we know the context of the parse, it's all global */
	{
#ifdef RRTRACE
	   FILE *rrfp;
#endif RRTRACE
	   rr_errors ++;
#ifdef RRTRACE
	   rrfp = rr_trcinit ();
	   fprintf (rrfp, "Syntax error (%d, %d)\n\n", yystate, yychar);
#endif RRTRACE

#ifdef RRTRACE
	   rr_repair (rrfp);	/* he does them all */
	   rrtr_close (rrfp);
#else
	   rr_repair ();
#endif RRTRACE
	   yychar = -1;		/* start fresh*/
	   goto yynewstate;	/* only the input has been changed */
	}
#endif REPAIR

	/* reduction by production yyn */

	if (yydebug)
	   printf ("reduce %d\n", yyn);
	yyps -= yyr2[yyn];
	yypvt = yypv;
	yypv -= yyr2[yyn];
	yyval = yypv[1];
	yym=yyn;
		/* consult goto table to find next state */
	yyn = yyr1[yyn];
	yyj = yypgo[yyn] + *yyps + 1;
	if (yyj >= YYLAST ||
	    yychk [yystate = yyact [yyj]] != -yyn)
	    yystate = yyact [yypgo [yyn]];

#ifdef REPAIR
	if (rr_errors == 0)
	   YYreduce (yym);
#else
	YYreduce (yym);
#endif REPAIR
	goto yystack;  /* stack new state and value */

	}
/*
 *	The remaining code is almost all for repair
 */
#ifdef REPAIR




/*
 *	During repair we need from time to time some kind of
 *	a parse stack to parse a piece. The stack is 
 *	a structure:
 */
struct rrparstack {
	short C_top;
	short C_data [YYMAXDEPTH];
};

typedef	struct rrparstack	rrps;
static init_stk (ps)
register rrps	*ps;
{
	ps -> C_top = 0;
}

static	short push (ps, val)
register rrps *ps;
register short  val;
{
	ps -> C_top ++;
	ps -> C_data [ps -> C_top] = val;
}
static ps_init (ps)
register rrps *ps;
{
	register short *ls;
	register short i;

	init_stk (ps);
	for (ls = &yys [0]; ls != yyps; ls ++)
	    push (ps, *ls);
	/* and another one:
	 */
	push (ps, *ls);
}

static cp_stack (x, y)
register rrps *x, *y;
{
	register int i;

	for (i = 1; i <= x -> C_top; i++)
	    y -> C_data [i] = x -> C_data [i];

	y -> C_top = x -> C_top;
}


static rr_pop (ps, amount)
register rrps *ps;
register short amount;
{
	ps -> C_top -= amount;
}

static short top_of (ps)
register rrps *ps;
{
	return ps -> C_data [ps -> C_top];
}
/*
 *	end of stack module, treat rrps from now as a limited private
 *	type
 */


/*
 *	after the repair the transformed input is stored in a
 *	lookahead structure
 */
struct rr_inp {
	short inp;
	short rp;
	struct {
		short inpdata;
		YYSTYPE inplexv;
		yyline_t inplino;
	} inpsequence [MAXPOST + MAXWIND];
};

typedef struct rr_inp restinput;
restinput lookah;

static init_input ()
{
	lookah. inp = 0;
	lookah. rp  = 0;
}

static add_input (sym, lexval, lino)
short sym;
YYSTYPE	lexval;
yyline_t lino;
{
	lookah. inpsequence [lookah. inp]. inpdata = sym;
	lookah. inpsequence [lookah. inp]. inplexv = lexval;
	lookah. inpsequence [lookah. inp]. inplino = lino;
	lookah. inp ++;
}

static short emp_las ()
{
	return lookah. rp >= lookah. inp;
}

static next_las (a_sym, a_lex, a_lino)
short *a_sym;
YYSTYPE *a_lex;
yyline_t *a_lino;
{
	*a_sym = lookah. inpsequence [lookah. rp]. inpdata;
	*a_lex = lookah. inpsequence [lookah. rp]. inplexv;
	*a_lino = lookah. inpsequence [lookah. rp]. inplino;
	lookah. rp ++;
}

static short rrnext_tok ()
{
	short x;

	if (emp_las ()) {
	   x = yylex ();
	   rr_lino = (yyline_t) yylino ();
	}
	else {
		next_las (&x, &yylval, &rr_lino);
	}
	return x;
}

/*
 *	Window management:
 *
 *	On encountering an error a window is read in with
 *	symbols from the right context
 *
 *	All functions and datastructures operating on
 *	the implementation of the window are given here
 */
struct win_l {
	int win_size;		/* actual window size */
	struct {
		short win_symbol;	/* actual symbol */
		YYSTYPE win_lexval;	/* "value"       */
		yyline_t win_lino;
	} symbols [MAXWIND];
};

typedef struct win_l	rrwindow;

init_window (window)
rrwindow *window;
{
	window-> win_size = 0;
}

static short win_elems (window)
rrwindow *window;
{
	return window -> win_size;
}

add_window (window, x, y, lino)
rrwindow *window;
short x;
YYSTYPE y;
yyline_t lino;
{
	if (window -> win_size >= MAXWIND)
	   yyerror ("Window overflow, should not happen");

	window -> symbols [window -> win_size]. win_symbol = x;
	window -> symbols [window -> win_size]. win_lexval = y;
	window -> symbols [window -> win_size]. win_lino = lino;
	window -> win_size ++;
}

static short
win_ful (window)
rrwindow *window;
{
	return window -> win_size >= MAXWIND;
}

static short get_wsymbol (window, i)
rrwindow *window;
short i;
{
	return window -> symbols [i - 1]. win_symbol;
}

YYSTYPE
get_wlexval (window, i)
rrwindow *window;
short i;
{
	return window -> symbols [i - 1]. win_lexval;
}

fill_window (window)
rrwindow *window;
{
	register short i;

	init_window (window);
	add_window (window, yychar, yylval, rr_lino);
	while (!win_ful (window) && yychar != 0)
	{ yychar = rrnext_tok ();
	  add_window (window, yychar, yylval, rr_lino);
	}
}

/*
 *	the postfix.
 *	An yylval must be added explicitly for each token that will
 *	be used in the repair.  This way creat_val () is not called
 *	for tokens that won't be used after all.
 */
struct postfix {
	short n_pf;
	struct {
		short	p_lex;			/* the yylex */
		YYSTYPE	p_lval;			/* and yylval */
	} rc_list [MAXPOST];
};

typedef struct postfix rrpf;

init_pf (pf)
register rrpf *pf;
{
	pf -> n_pf = 0;
}

add_pf (pf, x)
register rrpf *pf;
short x;
{
	if (pf -> n_pf >= MAXPOST)
	   yyerror ("Postfix overflow");

	pf -> rc_list [pf -> n_pf ++]. p_lex = x;
}

static short get_pf (pf, i)
register rrpf *pf;
short i;
{
	return pf -> rc_list [i - 1]. p_lex;
}

static short pf_elems (pf)
register rrpf *pf;
{
	return pf -> n_pf;
}

static set_pf_lval (pf, i, lval)
register rrpf *pf;
short i;
YYSTYPE lval;
{
	pf -> rc_list [i - 1]. p_lval = lval;
}

static YYSTYPE pf_lval (pf, i)
register rrpf *pf;
short i;
{
	return pf -> rc_list [i - 1]. p_lval;
}

/*
 *	The next routine does exactly one parse step
 *	i.e. a step
 *
 *	[q0 ... qn, s ...] |- ...
 *
 *	The transition that is made is given as result
 *	value, one of:
 */
#define	RRSHIFT		1
#define	RRREDUCE	2
#define	RRACCEPT	3
#define	RRERROR		4

static short parse_step (pstack, symb)
register rrps *pstack;
short symb;
{
	short rrn, rrstate;
	short rrm, rrj, *rrxi;

	rrstate = top_of (pstack);
#ifdef PARSETRACE
	printf ("doing a parse step d (%d, %o)\n", rrstate, symb);
#endif PARSETRACE
	rrn = yypact [rrstate];

	if (rrn < YYFLAG)
	   goto rrdefault;

	if ((rrn += symb) < 0 || rrn >= YYLAST)
	   goto rrdefault;

	if (yychk [rrn = yyact [rrn]] == symb)
	   { push (pstack, rrn);
	     return RRSHIFT;
	   }

rrdefault:
	if ((rrn = yydef [rrstate]) == -2)
	{
	   if (symb < 0) symb = 0;
	   for (rrxi = yyexca;
	        (*rrxi != (-1) || (rrxi [1] != rrstate));
	        rrxi += 2 );	/* VOID */

	   while ( *(rrxi += 2) >= 0)
	         if (*rrxi == symb)
	            break;

	   if ( (rrn = rrxi [1]) < 0) return RRACCEPT;
	}

	if (rrn == 0)
	   return RRERROR;

	/* reduction */
	rr_pop (pstack, yyr2 [rrn]);


	rrm = rrn;
	rrn = yyr1 [rrn];
	rrj = yypgo [rrn] + top_of (pstack) + 1;

	if (rrj >= YYLAST ||
	    yychk [rrstate = yyact [rrj]] != -rrn)
	   rrstate = yyact [yypgo [rrn]];

	push (pstack, rrstate);
	return RRREDUCE;
}

/*
 *	The actual repair is a transformation over
 *	a window and a "context". The latter being
 *	a private structure
 */
struct rrct {
	rrwindow	s_win;
	rrpf	s_pf;
	rrps	s_ps;
};

typedef struct rrct	rrcontext;

static
#ifdef RRTRACE
rr_repair (rrfp)
FILE *rrfp;
#else
rr_repair ()
#endif RRTRACE
{
	rrcontext context;
	register rrcontext *x = &context;
	short i;
	long t1, t2, t3;
	long tt;
	short s;
	short pfi;
	short win;
	int old_min = INFINITE;

	ps_init (&x -> s_ps);
	init_pf (&x -> s_pf);
	fill_window (&x -> s_win);

#ifdef RRTRACE
	fprintf (rrfp, "pf_index\twinindex\tstate\tsymbol\tdelcos\tinsco\tcon\n\n");
#endif RRTRACE
	/* for all insertions and all deletions find minimum cost */
	do {
	   for (i = 1; i <= win_elems (&x -> s_win); i++)
	   {
	      s = get_wsymbol (&x -> s_win, (short)i);
	      if (is_valid (&x -> s_ps, s))
		 { t1 = Delete_cost (&x -> s_win, i);
		   t2 = Insert_cost (&x -> s_pf);
		   t3 = Continuation (&x -> s_ps, &x -> s_win, i);
		   tt = t1 + t2 - t3;
#ifdef RRTRACE
		fprintf (rrfp, "%d\t\t%d\t\t%d\t%d\t%d\t%d\t%d\n",
				pf_elems (&x -> s_pf),
				i,
				top_of (&x -> s_ps),
				s,
				t1,
				t2,
				t3);
#endif RRTRACE
		   if (tt < old_min)
	              { old_min = tt;
		        pfi = pf_elems (&x -> s_pf);
		        win = i;
	              }
	         }
	   }
	} while (do_t_shift (x) != RRACCEPT);

/*
 *	Now start with the repair
 */
	if (old_min == INFINITE)
		yyerror ("did not find feasible repair; goodbye");

	init_input ();
	for (i = 1; i <= pfi; i ++) {
		set_pf_lval (&x -> s_pf, i, creat_val (get_pf (&x -> s_pf, i)));
		add_input (get_pf (&x -> s_pf, i), pf_lval (&x -> s_pf, i), -1);
	}
	for (i = pfi + 1; i < win; i ++)
	    {
	       del_symbol (get_wlexval (&x -> s_win, i));
	    }

	for (i = win; i <= win_elems (&x -> s_win); i ++)
	   {
	      add_input (get_wsymbol (&x -> s_win, (short)i),
	                 get_wlexval (&x -> s_win, i));
#ifdef RRTRACE
	      fprintf (rrfp, "window %o\n",
				get_wsymbol (&x -> s_win, (short)i));
#endif RRTRACE
	   }
	set_error_diag (x, win, pfi);
	syntax_error (top_of (&x -> s_ps), (int) rr_lino, error_diag);

#ifdef RRTRACE
	fprintf (rrfp, "repair %s\n", error_diag);
#endif RRTRACE
}

do_t_shift (x)
rrcontext *x;
{
	short t;
	short sym;

	do {
		sym = termfun (top_of (&x -> s_ps));
	        t = parse_step (&x -> s_ps, sym);
	} while (t == RRREDUCE);
	add_pf (&x -> s_pf, sym);
	return t;
}

int
is_valid (x, y)
rrps *x;
short y;
{
	rrps local_stack;
	short t;

	cp_stack (x, &local_stack);

	do {
	      t = parse_step (&local_stack, y);
	} while (t == RRREDUCE);

	return t != RRERROR;
}

static long
Delete_cost (window, i)
rrwindow *window;
short i;
{
	short j;

	long sum = 0;
	for (j = 1; j <= i; j ++)
	    sum += rr_skip (get_wsymbol (window, j), j);

	return sum;
}

static long
Insert_cost (pf)
rrpf *pf;
{
	short i;
	long sum = 0;

	for (i = 1; i <= pf_elems (pf); i++)
	    sum += rr_insert (get_pf (pf, i), i);

	return sum;
}

static long
Continuation (x, y, i)
rrps *x;
rrwindow *y;
short i;
{
	rrps localstack;
	short pos = 1;
	short sym;
	int t;
	int sum = 0;

	cp_stack (x, &localstack);
	while (1)
	{
	    sym = get_wsymbol (y, i);
	    t = parse_step (&localstack, sym);
	    while (t == RRREDUCE)
	          t = parse_step (&localstack, sym);

	    if (t == RRERROR)
	       return sum;
	    sum += rr_bonus (sym, pos);
	    i ++; pos ++;
	}
}

static err_reset ()
{
	err_ptr = error_diag;
	err_ptr[0] = '\0';
}

static err_concat (s)
register char *s;
{
	while (*err_ptr++ = *s++)
		;
	err_ptr--;
}

set_error_diag (x, win, pfi)
register rrcontext *x;
register short win;
register short pfi;
{
	register short i;

	err_reset ();
	if (win == 1) {
		err_concat ("inserted `");
		for (i = 1; i <= pfi; i++) {
			err_concat (rr_token (get_pf (&x -> s_pf, i),
				pf_lval (&x -> s_pf, i)));
			if (i != pfi) {
				err_concat (" ");
			}
		}
	}
	else if (pfi == 0) {
		err_concat ("deleted `");
		for (i = 1; i < win; i++) {
			err_concat (rr_token (
				get_wsymbol (&x -> s_win, i),
					get_wlexval (&x -> s_win, i)));
			if (i != win - 1) {
				err_concat (" ");
			}
		}
	}
	else {
		err_concat ("replaced `");
		for (i = 1; i < win; i++) {
			err_concat (rr_token (
				get_wsymbol (&x -> s_win, i),
					get_wlexval (&x -> s_win, i)));
			if (i != win - 1) {
				err_concat (" ");
			}
		}
		err_concat ("' with `");
		for (i = 1; i <= pfi; i++) {
			err_concat (rr_token (get_pf (&x -> s_pf, i),
				pf_lval (&x -> s_pf, i)));
			if (i != pfi) {
				err_concat (" ");
			}
		}
	}
	err_concat ("'");
}

#ifdef RRTRACE
rr_trce (rrpf)
FILE *rrpf;
{
}

static
FILE *rr_trcinit ()
{
	FILE *ff;
	long tvec [4];

	ff = fopen (TROUTFILE, "a");
	if (ff == NULL)
	   yyerror ("Cannot open tracefile ");

	fprintf (ff, "\f Error repair attempt :");
	time (tvec);
	fprintf (ff, "  TIME %s\n\n", ctime (tvec));
/*
 *	give the user the opportunity to write the source file
 */
	rr_usermess (ff);
	fprintf (ff, "\f");
	return ff;
}

static rrtr_close (ff)
FILE *ff;
{
	fprintf ("\f end of Repair attempt\n");
	fclose (ff);
}
#endif RRTRACE

/*
 *	that's all folks
 */

#endif REPAIR
/*
 *	The user is interested in doing actions on
 *	reductions:
 *	YACC will include a large case statement
 *	somewhere here
 */
YYreduce (x)
short x;
{
	switch (x) {
	
case 2:
# line 26 "treegen.y"
{{ init_fields ();}
} break;
case 4:
# line 29 "treegen.y"
 {
_ap += 1; } break;
case 5:
# line 30 "treegen.y"
 {
_ap += 1; } break;
case 6:
# line 33 "treegen.y"
{{ printf ("/* end of record %s*/ \n", gettag (_ap [0]. _t0));
		  pop_untab (_ap [0]. _t0);
		
	}
} break;
case 7:
# line 38 "treegen.y"
{{ printf ("\n /* end of union %s */ \n", gettag (_ap [0]. _t0));
		  pop_untab (_ap [0]. _t0);
		
	}
} break;
case 9:
# line 43 "treegen.y"
{{ yyval = NULL; }
} break;
case 10:
# line 47 "treegen.y"
{	_ap -= 1;
{ _ap [0]. _t0 = new_untab (yypvt[-1], XRECORD);
		}
} break;
case 11:
# line 52 "treegen.y"
{	_ap -= 1;
{ _ap [0]. _t0 = new_untab (yypvt[-1], XUNION);
		}
} break;
case 14:
# line 60 "treegen.y"
{{ cfree (_ap [0]. _t1);
		
	_ap += 1;
	}
} break;
case 15:
# line 64 "treegen.y"
{{ if (yypvt[-1] != NULL && does_exist (yypvt[-1])) {
		     warning ("possible error with %s\n", yypvt[-1]);
		  }
		  pop_untab (_ap [0]. _t0);
		
	_ap += 1;
	}
} break;
case 16:
# line 72 "treegen.y"
{{ if (!does_exist (yypvt[-0])) {
		     pr_access (_ap [1]. _t0, _ap [0]. _t1, yypvt[-0]);
		     add_field (yypvt[-0]);
		  }
		}
} break;
case 17:
# line 78 "treegen.y"
{{ if (!does_exist (yypvt[-0])) {
		     pr_access (_ap [1]. _t0, _ap [0]. _t1, yypvt[-0]);
		     add_field (yypvt[-0]);
		  }
		}
} break;
case 18:
# line 86 "treegen.y"
{	_ap -= 1;
{ _ap [0]. _t1 = new_string (yypvt[-0]);
		}
} break;
case 19:
# line 89 "treegen.y"
{{ _ap [0]. _t1 = strcat (_ap [0]. _t1, " *");
		
	}
} break;
case 20:
# line 92 "treegen.y"
{{ _ap [0]. _t1 = strcat (_ap [0]. _t1, yypvt[-1]);
		
	}
} break;
	}
}
