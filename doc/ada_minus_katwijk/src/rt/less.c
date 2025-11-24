#include	"../h/print.h"
#include	<stdio.h>
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"

#define		FALSE		0
#define		TRUE		1
#define		CHAR		1
#define		SHORT		2
#define		LONG		4
#define		DOUBLE		8

_less (v1, v2, d1, d2)
	TG_ADDR v1, v2;
	struct rt_any *d1, *d2;
{
	int	esize, i, n;
	TG_ADDR		e_dp;
	int		ndims;

	PRINTF (printf ("\t\t\t\t\t__less(%X,%X,%X,%X)\n",v1,v2,d1,d2));
	PRINTDESC ((d1, "d1"));
	PRINTDESC ((d2, "d2"));

#ifdef DEBUG
	if (d1 -> dtag != VD_ARR)
		run_error ("__less: array expected");

	if (XX_ARR (d1 -> ttp) -> td_ndims != 1)
		run_error ("__less: lhs not $_any_scalar");

	if (XX_ARR (d2 -> ttp) -> td_ndims != 1)
		run_error ("__less: rhs not $_any_scalar");

	if (d1 != d2)
	{ /*
	   * the subtypes must be compatible
	   */
	  if (hi_index (d1, 0) - lo_index (d1, 0) !=
	      hi_index (d2, 0) - lo_index (d2, 0))
			run_error ("__less: lhs and rhs not compatible");
	}
#endif DEBUG

	e_dp = XX_ARR (d1 -> ttp) -> td_e_cdp;

#ifdef DEBUG
	if (XX_ANY (e_dp) -> dtag != CD_BIT_H &&
	    XX_ANY (e_dp) -> dtag != CD_BIT_S)
		run_error ("__less: el_type not scalar");
#endif DEBUG

	n = hi_index (d1, 0) - lo_index (d1, 0) + 1;
	for (i = 0; i < n; i++)
	{
		switch (XD_BIT (e_dp) -> cd_bitind)
		{
		case CHAR:
			if (*(char *) v1 == *(char *) v2)
			{
				v1 += sizeof (char);
				v2 += sizeof (char);
				continue;
			}
			if (*(char *) v1 <  *(char *) v2)
				goto endtrue;
			else
				goto endfalse;

		case SHORT:
			if (*(short *) v1 == *(short *) v2)
			{
				v1 += sizeof (short);
				v2 += sizeof (short);
				continue;
			}
			if (*(short *) v1 <  *(short *) v2)
				goto endtrue;
			else
				goto endfalse;

		case LONG:
			if (*(long *) v1 == *(long *) v2)
			{
				v1 += sizeof (long);
				v2 += sizeof (long);
				continue;
			}
			if (*(long *) v1 <  *(long *) v2)
				goto endtrue;
			else
				goto endfalse;

		case DOUBLE:
			if (*(double *) v1 == *(double *) v2)
			{
				v1 += sizeof (double);
				v2 += sizeof (double);
				continue;
			}
			if (*(double *) v1 <  *(double *) v2)
				goto endtrue;
			else
				goto endfalse;
#ifdef DEBUG
		default:
			run_error ("__less: what kind of value is this: %d",
				 XD_BIT (e_dp) -> cd_bitind);
#endif DEBUG
		}
	}
	goto endfalse;

endtrue:
	PRINTF (printf ("true\t\t\t\t\tend __less.\n"));
	return TRUE;
endfalse:
	PRINTF (printf ("false\t\t\t\t\tend __less.\n"));
	return FALSE;
}
