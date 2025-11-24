#include	"../h/print.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"

int	null_slice[] = { 0 };

_slice (src, d_src, d_tar, lo, hi)
	int src;
	struct ld_arr *d_src, *d_tar;
	int lo, hi;
{
	int esize  = d_src -> vd_e_size;
	int lo_src = d_src -> ld_i_x[0]. vd_i_lo;
	int hi_src = d_src -> ld_i_x[0]. vd_i_hi;

	d_tar -> dtag = d_src -> dtag;
	d_tar -> ttp  = d_src -> ttp;
	d_tar -> vd_vsize = align ((hi - lo + 1) * esize, MAX_ALIGN);
	d_tar -> vd_e_size = esize;
	d_tar -> ld_i_x[0]. vd_i_lo = lo;
	d_tar -> ld_i_x[0]. vd_i_hi = hi;

	PRINTF (printf ("\t\t\t\t\t\t__slice:\n"));
	PRINTDESC ((d_tar, "target"));
	PRINTDESC ((d_src, "source"));
	PRINTF (printf ("	src	%x\n", src));
	PRINTF (printf ("	tar	%x\n", src + (lo - lo_src) * esize));

	if (lo > hi)
	{
		PRINTF (printf ("\t\t\t\t\t\tend __slice: null_slice\n"));
		return (int) null_slice;
	}

	PRINTF (printf ("\t\t\t\t\t\tend __slice:\n"));
	return src + (lo - lo_src) * esize;
}
