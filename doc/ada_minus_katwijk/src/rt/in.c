#include	"../h/print.h"
#include	"cnames.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"../h/print.h"
#include	"unix.h"

_incomp (x, y)
	register struct ld_arr *x, *y;
{
	register int i;
	register int nform;
	PRINTF (printf ("\t\t\t\t\t__in:\n"));
	PRINTDESC ((x, "x"));
	PRINTDESC ((y, "y"));
printf ("__in: deze functie is niet getest!!!\n");
	if (_dtag (x) == VD_ARR)
	{
	    for (i = 0; i < _td_ndims (x); i++)
		if        (hi_index (x, i) - lo_index (x, i) !=
			   hi_index (y, i) - lo_index (y, i))
			goto endfalse;
	    goto endtrue;
		
	}
	if (_dtag (x) == VD_REC || _dtag (x) == DD_REC)
	{
		nform = _tt_nform (_tt_sp (_ttp (x)));
		for (i = 1; i <= nform; i++)
		{
			if (_vd_discr (x) [i - 1] !=  _vd_discr (y) [i - 1])
				goto endfalse;
		}
		goto endtrue;
	}
	run_error ("__in: not implemented in rt: %d", _dtag (x));
endtrue:
	PRINTF (printf ("\t\t\t\t\tend __in.\n"));
	return TRUE;
endfalse:
	PRINTF (printf ("\t\t\t\t\tend __in.\n"));
	return FALSE;
}

int
_inscal (descr, val)
register struct ld_bit *descr;
register int val;
{
	if (val < _cd_lo (descr) || val > _cd_hi (descr))
		return FALSE;
	return TRUE;
}
