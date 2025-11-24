/*	
 *	routines to print library listings
 */

/*
 *	include files
 */

#include "debug.h"
#include "context.h"
#include "mode.h"

#define get_flags(x) x -> real_lun._flags & ~KIND_M


/*
 *	with command
 */

with()
{
	CNTR_LLIST *closure = &(proglun -> closure);
	register LLIST *i = first_of (closure);
	char *full_unit_name();
	int status;
	int j;

	ccommand("with");
	clrdisplay();

	for (j = 0; j < proglun -> closure. closurecount; j++)
	{
		fprintf (stdout, "%-20s", full_unit_name (i, &status));
		i = next_of (i);
	}
}

cat()
{
	bool status;
	char source[20];
	char *unit_name,*extension;
	int  ext;
	LUN unit;
	LUN parent;

	if (c_mode -> mode_flag == TRUE)
	    clrmenu ();
	ccommand("cat");
	for (;;) {
		prompt("enter unit ");
		unit_name = inline();
		resetcrs ();
		if (! *unit_name)
		    break;
		copyn(source,unit_name,20);
		get_lun(library,source,&unit,&status);
 		if ( status == FALSE )
		{
			sysdb_error ("unit %s not in library", source);
			continue;
		}
		if ( !fcat ( source_name ( (&unit)),1))
			sysdb_error("cannot open %s",source);
	}
        if (c_mode -> mode_flag == TRUE)
	    menu (c_mode -> mode_name);
}

/*
 *	list command
 */

listsub (lun, prefix, pointer, status)
char *prefix, *pointer;
LUN *lun;
bool *status;
{
	lowercase (name_of (lun));
	if (*prefix == '\0')
	   printf ("%s\n", name_of (lun));
	else
	   printf ("%s.%s\n", prefix, name_of (lun));
	return FALSE;
}

list()
{
	bool status;
	LUN		unit;
	ccommand("list");
	clrdisplay();
	rec_list (library, listsub, NULL, &status);
}

