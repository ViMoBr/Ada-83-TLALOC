#
#include "../h/rt_defs.h"
#include "../h/rt_types.h"

#define NULL 0
/* performs unchecked deallocation */

deallocate (tup)
	register char *tup;
{
	tup = tup - TADDRSIZE;	/* ???? */
	if (XD_TUP (tup) -> some_flag)
	   cfree ((char *) XD_TUP (tup) -> descr);

	cfree ((char *) tup);
	tup = (char *)NULL;
}
