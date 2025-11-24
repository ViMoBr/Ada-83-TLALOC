#include	"cnames.h"
#include	"../h/print.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"

char
_scccode (val1,val2,desc1,desc2, kind)
	char *val1, *val2;
	struct ld_arr *desc1, *desc2;
	int kind;
{
	register int n1,n2;
	int result1;
	int result2;
	int i;

	n1 = realsize (desc1);
	n2 = realsize (desc2);

	PRINTF (printf ("\t\t\t\t\t\tscccode:realsize1=%d\n", n1));
	PRINTF (printf ("\t\t\t\t\t\tscccode:realsize2=%d\n", n2));
	PRINTDESC ((desc1, "desc1"));
	PRINTDESC ((desc2, "desc2"));
	PRINTF (printf ("val1address = 0x%X\n", val1));
	PRINTF (printf ("val2address = 0x%X\n", val2));

	if (kind == SCC_AND)
		result1 = result2 = 1;
	else
		result1 = result2 = 0;

	while (n1-- > 0) {
		if (kind == SCC_AND)
			result1 &= *val1++;
		else
			result1 |= *val1++;
	}

	if (kind == SCC_AND && ! result1)
		return ((char) 0); /* false exit */

	if (kind == SCC_OR && result1)
		return ((char) 1); /* true exit */

	/* now the first scc expr causes an evaluation of the
	 * second scc expr
	 */

	if (realsize (desc1) != n2) {
		/* incompatible sizes : raise a constraint error
		 */
	   _raise (&CONSTRAINT_ERROR);
	}

	/* check if the arrays are compatible */

	for (i = 0; i < _td_ndims (_ttp (desc1)); i ++)
	    if (hi_index (desc1, i) - lo_index (desc1, i) !=
	        hi_index (desc2, i) - lo_index (desc2, i))
			_raise (&CONSTRAINT_ERROR);


	while (n2-- > 0) {
		if (kind == SCC_AND)
			result2 &= *val2++;
		else
			result2 |= *val2++;
	}

	return ((char) result2);
}
