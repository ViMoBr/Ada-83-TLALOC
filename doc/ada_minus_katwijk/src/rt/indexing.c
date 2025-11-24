#include	"../h/print.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"

/*
 *	indexing is called in all cases where
 *	- something has to be checked anyhow,
 *	- more dimensional arrays
 *
 *	it computes the offset within the array object
 *	given the indexvalues and the array subtype
 *	descriptor
 */

char *_indexing (desc, v0)
register struct ld_arr *desc;
int v0;
{
	register int *index;
	register int dims;
	int offset;
	int i;
	register struct ld_arri *h;
	PRINTF (printf ("\t\t\t\t\t__indexing:\n"));
#ifdef DEBUG
	if (_dtag (desc) != VD_ARR)
	   run_error ("__indexing: non array:dtag=%d", _dtag (desc));
#endif DEBUG

	dims = _td_ndims (_ttp (desc));
	/*dims = XX_ARR (desc -> ttp) -> td_ndims;*/
	index = &v0;

#ifdef PRINT
	PRINTF (printf ("dims of array %d\n", dims));

	for (i = 1; i <= dims; i ++)
	     PRINTF (printf ("\t index (%d) = %d\n", i, index [i - 1]));
#endif PRINT

	/* initialize */
	indcheck (index [0], &desc -> ld_i_x [0]);

	offset = index [0] - desc -> ld_i_x [0]. vd_i_lo;
	for (i = 2; i <= dims; i ++)
	{
	    h = &desc -> ld_i_x [i - 1];
	    indcheck (index [i - 1], h);
	    offset = offset * 
		  (h -> vd_i_hi - h -> vd_i_lo + 1) +
		  index [i - 1] - h -> vd_i_lo;
	}

	PRINTF (printf ("indexing: offset = %d, elsize = %d\n",
				offset, desc -> vd_e_size));
	offset *= desc -> vd_e_size;

	PRINTF (printf ("indexing: computed offset = %d\n", offset));
	PRINTF (printf ("\t\t\t\t\tend __indexing.\n"));
	return (char *) offset;
}

