#include	"unix.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"../h/print.h"

static bool
compatible (d1, d2)
	struct ld_rec *d1, *d2;
{
	int nform;
	int i;

	nform = XX_SREC (XX_REC (XD_REC (d1) -> ttp) -> tt_sp) -> tt_nform;
	for (i = 0; i <= nform; i++)
	    if (XD_REC (d1) -> vd_discr[i-1] != XD_REC (d2) -> vd_discr[i-1])
		return FALSE;
	
}
static
_cp_desc (from, to)
	char *from, *to;
{
	int i;

/*
 *	just copy the descriptor, EXCEPT for
 *	- the tag, should remain the same
 *	- the ttp, no need to
 */
/*
	for (i = VD_SIZE; i <= cdvsize (XX_REC (from -> ttp)); i++)
		to [i] = from [i];
 */
}

unco_as (dleft, dright, vleft, vright)
	struct ld_rec	*dleft, *dright;
	char *vleft, *vright;
{
	if (_dtag (dleft) == VD_REC)
	{
		_assign (dleft, _check (dleft, dright, vright), vleft);
		return vleft;
	}
	if (dleft == dright || compatible (dleft, dright))
	{
		_assign (dleft, vright, vleft);
		return vleft;
	}

	if (_vd_vsize (dleft) >= _vd_vsize (dright))
	{
		_cp_desc (dright, dleft);
		_assign (dleft, vright, vleft);
		return vleft;
	}

	cfree (vleft);
	vleft = (char *)malloc (_vd_vsize (dright));
	_cp_desc (dright, dleft);
	_assign (dleft, vright, vleft);
	return vleft;
}
