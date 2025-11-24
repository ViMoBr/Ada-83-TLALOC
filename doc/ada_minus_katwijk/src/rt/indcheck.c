#include	"../h/print.h"
#include	"cnames.h"

indcheck (val, c)
	register int val;
	register struct {
		int lo;
		int hi;
	} *c;
{
	if (val < c -> lo || val > c -> hi)
	{
		PRINTF (printf (" %d not in %d .. %d\n",
			val, c -> lo, c -> hi));
		_raise (&CONSTRAINT_ERROR);
	}
}

