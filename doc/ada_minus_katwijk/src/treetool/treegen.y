%attribute	record_list
%attribute	record_desc (^int)
%attribute	union_desc (^int)
%attribute	record_start (^int)
%attribute	union_start (^int)
%attribute	rec_fields   (|int)
%attribute	rec_field    (|int)
%attribute	field_type   (|int, ^pchar)
%attribute	id_list      (|int, pchar)
%attribute	init

%token	XUNION
%token	XRECORD
%token	SEMCOL
%token	IDENT
%token	STARREF
%token	COMMA
%token	LBRACK
%token	RBRACK
%token	SUB
%token	BUS
%token	NUMBER
%%
tree:	init record_list;

init:	= { init_fields ();};

record_list	: |
		record_list record_desc (^x)|
		record_list union_desc (^x);

record_desc (^x):	record_start (^x) rec_fields (|x) RBRACK opt_ident SEMCOL=
		{ printf ("/* end of record %s*/ \n", gettag ($x));
		  pop_untab ($x);
		};
union_desc (^x):
		union_start (^x) rec_fields (|x) RBRACK opt_ident SEMCOL =
		{ printf ("\n /* end of union %s */ \n", gettag ($x));
		  pop_untab ($x);
		};

opt_ident:	IDENT |
		= { $$ = NULL; };


record_start (^x):	XRECORD IDENT LBRACK =
		{ $x = new_untab ($2, XRECORD);
		};

union_start (^x):
		XUNION IDENT LBRACK =
		{ $x = new_untab ($2, XUNION);
		};

rec_fields (|x):
		rec_field (|x) |
		rec_fields (|x) rec_field (|x);

rec_field (|x):	field_type (|x, ^t) id_list (|x, t) SEMCOL =
		{ cfree ($t);
		} |
		record_start (^x1) rec_fields (|x1)
                             RBRACK opt_ident SEMCOL =
		{ if ($4 != NULL && does_exist ($4)) {
		     warning ("possible error with %s\n", $4);
		  }
		  pop_untab ($x1);
		};

id_list (|x, t):
		IDENT =
		{ if (!does_exist ($1)) {
		     pr_access ($x, $t, $1);
		     add_field ($1);
		  }
		} |
		id_list (|x, t) COMMA IDENT =
		{ if (!does_exist ($3)) {
		     pr_access ($x, $t, $3);
		     add_field ($3);
		  }
		};

field_type (|x, ^t):
		IDENT =
		{ $t = new_string ($1);
		} |
		field_type (|x, ^t) STARREF =
		{ $t = strcat ($t, " *");
		} |
		field_type (|x, ^t) SUB NUMBER BUS =
		{ $t = strcat ($t, $3);
		};
%%
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

