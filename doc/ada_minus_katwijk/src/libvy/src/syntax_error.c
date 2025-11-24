/*
 *	@(#)syntax_error.c	1.5	86/09/09
 *
 *	syntax_error - this function returns an error message for state
 *	q in line "line" to the user.
 *
 */
/* LINTLIBRARY */

static char buf [512];

/* ARGSUSED */
syntax_error (q, line, repair)
short	q;
int	line;
{
	sprintf (buf, "syntax error in line %d: %s\n", line, repair);
	yyerror (buf);
}
