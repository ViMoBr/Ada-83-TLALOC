#include "libr.h"
#include "DEBUG.h"

static LLIST *
llist_alloc ()
{
	LLIST *y;

	y = (LLIST *) malloc (sizeof (LLIST));

	if (y == NULL) return NULL;

	next_of (y) = NULL;
	return y;
}

bool
in_closure (lun, closure)
LUN *lun;
CNTR_LLIST *closure;
{
	LLIST *x = closure-> _first;

	while (!is_empty (x))
	{
	    if (log_id (x) == log_ident (lun))
		return TRUE;

	    x = next_of (x);
	}
	return FALSE;
}

init_closure (closure)
CNTR_LLIST *closure;
{
	closure-> _first = NULL;
	closure-> _last  = NULL;
	closure-> closurecount = 0;
}

bool
add_closure (lun, closure)
LUN *lun;
CNTR_LLIST *closure;
{
	LLIST *x;

	x = llist_alloc ();

	if (x == NULL) return FALSE;

	if (is_empty (first_of (closure)))
	   first_of (closure) = x;
	else
	   next_of (last_of (closure)) = x;
	last_of (closure) = x;

	PRINTF ("add_closure: %s\n", source_name (lun));

	closure-> closurecount++;

	cp_lun (x, lun);
	set_currentfile (x, currentfile (lun));
	return TRUE;
}

cp_lun (x, y)
char *x, *y;
{
	int i;

	for (i = 0; i < OCLSIZE; i++)
	   *x++ = *y++;
}
