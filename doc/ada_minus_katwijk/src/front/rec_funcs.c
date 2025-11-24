#
#include	"includes.h"
#include	"y.tab.h"

extern	FILE *yyin;
extern	int yylineno;

int	yylino ()
{
	return yylineno;
}


short rr_skip (s, i)
short	s,
	i;
{
	if (s == T_END)
	   return i * 100;
	else
	return 10 * i;
}

short rr_insert (s, i)
short	s,
	i;
{
	return 10 * i;
}

short rr_bonus (sym, pos)
short	sym,
	pos;
{
	return pos * pos;
}

char	*creat_val (s)
short	s;
{
	switch (s) {
	case T_INT_LIT:
		return (char *)alloc_lit (S_INTLIT, "00", 2);

	case T_IDENT:
		return mk_tag ("$errorid$", 10);

	case T_RELOP:
		return mk_tag ("=", 2);

	case T_PLUS:
		return mk_tag ("+", 2);

	case T_MINUS:
		return mk_tag ("-", 2);

	case T_MULT:
		return mk_tag ("*", 2);

	case T_DIV:
		return mk_tag ("/", 2);

	case T_AMP:
		return mk_tag ("&", 2);

	case T_EXP:
		return mk_tag ("**", 3);

	case T_CHAR_LIT:
		return 'a';

	case T_CHAR_STRING:
		return (char *)alloc_lit (S_STRINGLIT, "$$$error$$$", 12);

	default:
		return NULL;
	}
}

char *lex_symbol [] = {
"abort",
"abs",
"accept",
"access",
"all",
"and",
"array",
"at",
"p_begin",
"body",
"case",
"constant",
"declare",
"delay",
"delta",
"digits",
"do",
"else",
"elsif",
"end",
"entry",
"exception",
"exit",
"for",
"function",
"generic",
"goto",
"if",
"in",
"is",
"limited",
"loop",
"mod",
"new",
"not",
"nullk",
"of",
"or",
"others",
"out",
"package",
"pragma",
"private",
"procedure",
"raise",
"range",
"record",
"rem",
"renames",
"return",
"reverse",
"select",
"separate",
"subtype",
"task",
"terminate",
"then",
"type",
"use",
"when",
"while",
"with",
"xor",
"char_lit",
"char_string",
"a relational operator",
"an identifier",
"an integer literal",
"a real or floating literal",
"*",
"/",
"+",
"-",
"&",
"<>",
"exp",
"|",
":=",
":",
".",
",",
"'",
"..",
"(",
")",
"->",
";",
"<<",
">>" };
char	*rr_token (n)
short	n;
{
	return lex_symbol [n - T_ABORT];
}

del_symbol (s)
char	*s;
{
	/* keep it simple: */
}

user_exit (s)
char	*s;
{
	printf (s);
	abort ();
}

#ifdef RRTRACE
#define	CCOUNT	300
#define	MARGE	10

rr_usermess (ff)
FILE *ff;
{
	long	x = ftell (yyin);
	char	c;
	int	i;
	long	m = x > CCOUNT ? CCOUNT : x;

	fseek (yyin, -m, 1);
	for (i = 0; i <= m + MARGE; i ++) {
		c = fgetc (yyin);
		fputc (c, ff);

		if (feof (yyin))
		   break;

	}

	fseek (yyin, x, 0);
}


#endif RRTRACE
