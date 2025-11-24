#include	<stdio.h>
#include	"../h/print.h"
#include	"unix.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"

#define		CHAR		1
#define		SHORT		2
#define		LONG		4
#define		DOUBLE		8

_equal (v1, v2, d1, d2)
	TG_ADDR v1, v2;
	struct rt_any *d1, *d2;
{

	PRINTF (printf ("\t\t\t\t\t__equal(%X,%X,%X,%X)\n",v1,v2,d1,d2));
	PRINTDESC ((d1, "d1"));
	PRINTDESC ((d2, "d2"));

	switch (d1 -> dtag)
	{
	case VD_ARR:
	{	int	esize, i, n;
		TG_ADDR		e_dp;
		int		ndims;
		struct ld_arri	*i1;
		struct ld_arri	*i2;

		i1 = XD_ARR (d1) -> ld_i_x;
		ndims = XX_ARR (d1 -> ttp) -> td_ndims;

		if (d1 != d2)
		{ /*
		   * if the subtypes are not compatible,
		   * the values are certainly not equal
		   */
		  i2 = XD_ARR (d2) -> ld_i_x;
		  for (i = 0; i < ndims; i++)
		    if (i1 [i].vd_i_hi - i1 [i].vd_i_lo !=
		        i2 [i].vd_i_hi - i2 [i].vd_i_lo)
				goto endfalse;
		}
		for (n = 1, i = 0; i < ndims; i++)
			n *= i1 [i] .vd_i_hi - i1 [i] . vd_i_lo + 1;
		esize = XD_ARR (d1) -> vd_e_size;
		e_dp = XX_ARR (d1 -> ttp) -> td_e_cdp;

		PRINTF (printf ("__equal: VD_ARR, esize: %d, ", esize));
		PRINTF (printf ("number of elements: %d, ", n));
		PRINTF (printf ("el_tag: %d\n", XX_ANY (e_dp) -> dtag));

		while (n--)
		{
			if (!_equal (v1, v2, e_dp, e_dp))
				goto endfalse;
			v1 += esize;
			v2 += esize;
		}
		goto endtrue;
	}

	case TD_REC:
	  { struct tt_srec	*tdsp;
	    int			flags;
	    int			nform;
	    int			nflds;
	    int			path;
	    int			off;
	    int			i;
	    TG_ADDR		*descs;
	    struct tt_oftable	*offaddr;

		tdsp  = XX_SREC (XX_REC (d1) -> tt_sp);
		flags = tdsp -> tt_rflags & F_KIND;
		nform = tdsp -> tt_nform;
		nflds = tdsp -> tt_nflds;
		path  = -1;

		nflds = _tt_nflds (_tt_sp (d1));
		off   = 0;
		descs = _tt_f_edp (d1);

		if (flags & (DYNREC | VARREC))
		{
			offaddr = XX_OFTABLE (& descs [nform + nflds +1]);
			off = offaddr -> tt_f_off [0];
		}
		else
			for (i = 0; i < nform; i++)
				off += realsize (descs [i]);

		for (i = nform; i < nform + nflds; i++)
		for (i = 0; i < nflds; i++)
		{  
			off = align (off, al_val (descs[i]));
			v1 += off; v2 += off;
			if (!_equal (v1, v2, descs [i], descs [i]))
				goto endfalse;
			if (flags & DYNREC)
				off = offaddr -> tt_f_off [i];
			else
				off = realsize (descs [i]);
			off = realsize (descs [i]);
		}
		goto endtrue;
	}

	case VD_REC:
	case DD_REC:
		PRINTF (printf ("\t\t\t\t\tend __equal\n"));
		PRINTF (printf ("[DV]D_REC\n"));
	{
		int	i, off, path, nflds, nform, flags;
		struct tt_rec		*td;
		struct tt_srec		*tdsp;
		struct tt_oftable	*offaddr;
		TG_ADDR			*descs;

		td    = _ttp (d1);
		tdsp  = _tt_sp (td);
		flags = _tt_rflags (tdsp) & F_KIND;
		nform = _tt_nform (tdsp);
		nflds = _tt_nflds (tdsp);
		path  = _vd_path (d1);
		if (has_off_table (flags, d1))
			offaddr = XX_OFTABLE (& XD_REC (d1) -> vd_discr[nform]);
		descs = _tt_f_edp (td);

		for (i = nform; i < nform + nflds; i++)
		{
			if (has_path (tdsp, path))
				if (path < lopath (tdsp, i) ||
				    path > hipath (tdsp, i))
					continue;
			off = has_off_table (flags, d1)
			      ?	offaddr -> tt_f_off[i - 1]
			      :	align (get_off (VD_REC, i, td, path),
				       al_val (descs[i]));
			if (!_equal (v1 + off, v2 + off, descs [i], descs [i]))
				goto endfalse;
		}
		goto endtrue;
	}

	case CD_BIT_H:
	case CD_BIT_S:
		switch (XD_BIT (d1) -> cd_bitind)
		{
		case CHAR:
			if (*(char *) v1 != *(char *) v2)
				goto endfalse;
			else
				goto endtrue;

		case SHORT:
			if (*(short *) v1 != *(short *) v2)
				goto endfalse;
			else
				goto endtrue;

		case LONG:
			if (*(long *) v1 != *(long *) v2)
				goto endfalse;
			else
				goto endtrue;

		case DOUBLE:
			if (*(double *) v1 != *(double *) v2)
				goto endfalse;
			else
				goto endtrue;
#ifdef DEBUG
		default:
			run_error ("__equal: what kind of value is this: %d",
				 XD_BIT (d1) -> cd_bitind);
#endif DEBUG
		}

#ifdef DEBUG
	default:
		run_error ("__equal: dtag = %d", d1 -> dtag);
#endif DEBUG
	}

endtrue:
	PRINTF (printf ("true\t\t\t\t\tend __equal.\n"));
	return TRUE;
endfalse:
	PRINTF (printf ("false\t\t\t\t\tend __equal.\n"));
	return FALSE;
}
