#include	"../h/print.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"

_assign (tardesc, src, tar)
	struct ld_arr *tardesc;
	char *src, *tar;
{
	register int n;
	n = realsize (tardesc);
	PRINTF (printf ("\t\t\t\t\t\tassign:realsize=%d\n", n));
	PRINTDESC ((tardesc, "target"));
	PRINTF (printf ("srcaddress = 0x%X\n", src));
	PRINTF (printf ("taraddress = 0x%X\n", tar));
	if (tar <= src)
	{	while (n-- > 0)
		{
			*tar++ = *src++;
		}
	}
	else
	{	tar += n;
		src += n;
		while (n-- > 0)
		{
			*--tar = *--src;
		}
	}

	PRINTF (printf ("\t\t\t\t\t\tend assign.\n"));
}
