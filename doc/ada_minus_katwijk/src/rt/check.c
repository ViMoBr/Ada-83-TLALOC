#include	"../h/print.h"
#include	"cnames.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"

char *	_check (x, y, z)
struct ld_arr *x, *y;
char	*z;
{
	int	i;
	int	nform;

	if (_dtag (x) == VD_ARR) {
	   PRINTF (printf ("\t\t\t\t\t__check:\n"));
	   PRINTDESC ((x, "x"));
	   PRINTDESC ((y, "y"));
	   for (i = 0; i < _td_ndims (_ttp (x)); i ++)
	     if (hi_index (x, i) - lo_index (x, i) !=
	         hi_index (y, i) - lo_index (y, i))
			_raise (&CONSTRAINT_ERROR);
	}
	else
	if (_dtag (x) == VD_REC || _dtag (x) == DD_REC) {
	   nform = _tt_nform (_tt_sp (_ttp (x)));
	   for (i = 1; i <= nform; i++)
	       if (_vd_discr (x) [i - 1] != _vd_discr (y) [i - 1])
		  _raise (&CONSTRAINT_ERROR);
	}
	else
		;

	PRINTF (printf ("\t\t\t\t\tend __check.\n"));
	return z;
}


int	_scal_check (descr, val)
struct ld_bit *descr;
int	val;
{
	switch (descr -> dtag) {
	   case CD_BIT_H:
	   case CD_BIT_S:
			break;
	   default:
			/* do nothing */
			return val;
	}

	if (val < _cd_lo (descr) || val > _cd_hi (descr))
		_raise (&CONSTRAINT_ERROR);

	return val;
}

