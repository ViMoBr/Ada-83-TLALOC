/*
 *	@(#)yyerror.c	1.1	86/08/18
 *
 *	yyerror
 *
 */
/* LINTLIBRARY */
#include <stdio.h>

yyerror (s)
char *	s;
{
	fprintf (stderr, "%s\n", s);
}
