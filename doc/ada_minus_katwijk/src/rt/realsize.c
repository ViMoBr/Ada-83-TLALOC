#include	"../h/print.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"

#define		CHAR		1
#define		SHORT		2
#define		LONG		4
#define		DOUBLE		8

realsize (d)
	struct ld_arr *d;
{
	int numofel = 1;
	int i;

	switch (d -> dtag)
	{
	case VD_ARR:
		for (i = 0; i < XX_ARR (d -> ttp) -> td_ndims; i++)
		{
		   numofel *= (int)d -> ld_i_x [i]. vd_i_hi
			    - (int)d -> ld_i_x [i]. vd_i_lo
		            + 1;
		   if (numofel <= 0)
			return 0;
		}

		PRINTF (printf ("realsize: %d\n", numofel * (int) d -> vd_e_size));

		return numofel * (int) d -> vd_e_size;

	case TD_REC:
		return XX_REC (d) -> tt_vsize;

	case VD_REC:
	case DD_REC:
		return XD_REC (d) -> vd_vsize;

	case CD_BIT_H:
	case CD_BIT_S:
		switch (XD_BIT (d) -> cd_bitind)
		{
		case CHAR:
			return sizeof (char);

		case SHORT:
			return sizeof (short);

		case LONG:
			return sizeof (long);

		case DOUBLE:
			return sizeof (double);
#ifdef DEBUG
		default:
			run_error ("_real_size: dtag = %d", d -> dtag);
#endif DEBUG
		}

#ifdef DEBUG
	default:
		run_error ("_real_size: dtag = %d", d -> dtag);
#endif DEBUG
	}
}
