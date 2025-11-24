#include "libr.h"

char *
str_alloc (s)
char *s;
{
	register n;
	register char *p = s;

	for (n = 0; *p++ != '\0'; n++);

	p = (char *) malloc (n);
	strcpy (p, s);

	return p;
}

static ALIST *
llist_alloc ()
{
	ALIST *y;

	y = (ALIST *) malloc (sizeof (ALIST));

	if (y == NULL) return NULL;

	y-> _next = NULL;
	return y;
}

bool
in_arglist (name, list)
char *name;
CNTR_ALIST *list;
{
	ALIST *x = list-> _first;

	while (x-> _next != NULL)
	{   if (!strcmp (name, x-> _argument))
		return TRUE;

	    x = x-> _next;
	}
	return FALSE;
}

init_arglist (arglist)
CNTR_ALIST *arglist;
{
	arglist-> _first = NULL;
	arglist-> _last  = NULL;
	arglist-> alistcount = 0;
}

bool
add_arglist (name, arglist)
char *name;
CNTR_ALIST *arglist;
{
	ALIST *x;

	x = llist_alloc ();

	if (x == NULL) return FALSE;

	if (arglist-> _first == NULL)
	   arglist-> _first = x;
	else
	   arglist-> _last-> _next = x;
	
	arglist-> _last = x;

	x-> _argument = str_alloc (name);
	arglist-> alistcount++;

	return TRUE;
}
