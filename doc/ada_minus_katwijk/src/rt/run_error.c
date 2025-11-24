#include	<stdio.h>

run_error (a, b, c)
{
	fprintf (stderr, "Run time error: ");
	fprintf (stderr, a, b, c);
	fprintf (stderr, "\n... aborting\n");
	_cleanup ();
	abort ();
}
