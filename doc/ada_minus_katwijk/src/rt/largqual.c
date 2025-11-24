#include	"cnames.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"

/* this simple routine is a product of TOET's imagination */

char *
largqual (d1,c,d2)
	RT_ANY	d1;
	char	*c;
	RT_ANY	d2;
{
	int	i;
	int	nform;

	if (d1 -> dtag != d2 -> dtag)
	    _raise (&CONSTRAINT_ERROR);

	if (d1 -> dtag == VD_ARR)
	{
	    if (_vd_vsize (d1) != _vd_vsize (d2))
		_raise (&CONSTRAINT_ERROR);

	    for (i = 0; i < (int) _td_ndims (_ttp (d1)); i++) 
		if (lo_index (d1, i) != lo_index (d2, i))
		    _raise (&CONSTRAINT_ERROR);
		if (hi_index (d1, i) != hi_index (d2, i))
		    _raise (&CONSTRAINT_ERROR);
	}
	else if (_dtag (d1) == VD_REC || _dtag (d1) == DD_REC)
	{
	    nform = _tt_nform (_tt_sp (_ttp (d1)));
	    for (i = 0; i <= nform; i++)
		if (_vd_discr (d1)[i-1] != _vd_discr (d2)[i-1])
		    _raise (&CONSTRAINT_ERROR);
	}
	return c;
}
