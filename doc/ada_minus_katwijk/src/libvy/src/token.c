/*
 *	@(#)token.c	1.3	86/09/09
 *
 *	Token.c -- given an yychar and yylval, reconstruct
 *	a plausible token string.
 */
/* LINTLIBRARY */

#include <ctype.h>

/* ARGSUSED */
char *
rr_token (lchar, lval)
int	lchar;
int	lval;		/* should be YYSTYPE */
{
	static char buf [12];

	if (isprint (lchar)) {
		sprintf (buf, "%c", lchar);
	}
	else {
		sprintf (buf, "<%d>", lchar);
	}
	return buf;
}
