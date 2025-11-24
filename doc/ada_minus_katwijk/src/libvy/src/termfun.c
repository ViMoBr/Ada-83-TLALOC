/*
 *	@(#)termfun.c	1.1	86/08/18
 *
 *	Veyacc default termination function.
 */
/* LINTLIBRARY */

extern	short	termi [];

short
termfun (state)
short	state;
{
	return termi [state];
}
