#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"

printdesc (d, val)
	char *val;
	struct ld_arr *d;
{
	int i;
	switch (d -> dtag)
	{
	case VD_ARR:
		printf ("\t\t\t\t\t\tprintdesc %s:\n", val);
		printf ("desc addr: %x\n", d);
		printf ("tag	%8X\n", d -> dtag);
		printf ("ttp	%8X\n", d -> ttp);
		printf ("vsize	%8X\n", d -> vd_vsize);
		printf ("esize	%8X\n", d -> vd_e_size);
		printf ("lo	%8X\n", d -> ld_i_x[0]. vd_i_lo);
		printf ("hi	%8X\n", d -> ld_i_x[0]. vd_i_hi);
		printf ("\t\t\t\t\t\tend printdesc.\n");
		return;
	case TD_REC:
#define DESC ((int *) d)
#define TTSP ((int *) XX_REC (DESC) -> tt_sp)
printf("%8X tt_nflds  %8X dtag    \n", TTSP[0], DESC[0]);
printf("%8X tt_nform  %8X tt_sp   \n", TTSP[1], DESC[1]);
printf("%8X tt_ninits %8X tt_vsize\n", TTSP[2], DESC[2]);
printf("%8X tt_rflags %8X tt_f_edp\n", TTSP[3], DESC[3]);
printf(" \t           %8X tt_f_edp\n", TTSP[4], DESC[4]);
printf(" \t           %8X tt_f_edp\n", TTSP[5], DESC[5]);
printf(" \t           %8X tt_f_edp\n", TTSP[6], DESC[6]);
break;

case DD_REC:
case VD_REC:
#define VDESC ((int *) d)
#undef DESC
#define DESC ((int *) XD_REC (VDESC) -> ttp)
#undef TTSP
#define TTSP ((int *) XX_REC (DESC) -> tt_sp)
printf("%8X tt_nflds  %8X dtag     %8X dtag    \n",TTSP[0],DESC[0],VDESC[0]);
printf("%8X tt_nform  %8X tt_sp    %8X ttp     \n",TTSP[1],DESC[1],VDESC[1]);
printf("%8X tt_ninits %8X tt_vsize %8X vd_vsize\n",TTSP[2],DESC[2],VDESC[2]);
printf("%8X tt_rflags %8X tt_f_edp %8X vd_nflds\n",TTSP[3],DESC[3],VDESC[3]);
printf("%8X path_f    %8X tt_f_edp %8X vd_path \n",TTSP[4],DESC[4],VDESC[4]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[5],DESC[5],VDESC[5]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[6],DESC[6],VDESC[6]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[7],DESC[7],VDESC[7]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[8],DESC[8],VDESC[8]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[9],DESC[9],VDESC[9]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[10],DESC[10],VDESC[10]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[11],DESC[11],VDESC[11]);
printf("%8X tt_f_vr   %8X tt_f_edp %8X vd_discr\n",TTSP[12],DESC[12],VDESC[12]);
break;

	default:
		printf ("descaddr = %X\n", d);
		printf ("desc     = %X  %X  %X  %X\n",
		((int *)d)[0],
		((int *)d)[1],
		((int *)d)[2],
		((int *)d)[3]);
		break;
	}
}
