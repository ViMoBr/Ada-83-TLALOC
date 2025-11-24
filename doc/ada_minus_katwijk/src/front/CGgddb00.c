
/*
 * (c) copyright 1987, Delft University of Technology
 * Delft, The Netherlands
 *
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 *	J van Katwijk/W.J. Toetenel
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

bool adb_control ();


/*
 * Name:	adb_label
 *
 * Abstract:	define and create a global label.
 *
 * Description:	
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

adb_label (node, mode)
	register ac node;
	int mode;
{
	char	datatext [AIDL];
	char	label [AIDL+1];

	if (tracelevel < ADBTRACE)
		return;

	labconvert (node, datatext);
	label[0] = 'D';
	label[1] = mode == DEF_ENTRY ? 'S' : 'E';
	label[2] = '\0';
	strcat (label, datatext);
	OUT (("&%d	%s\n", ICGLOBL, label));
	OUT (("&%d	%s\n", ICDLABS, label));
}


/*
 * Name:	adb_break
 *
 * Abstract:	create a break
 *
 * Description:	a 'break' is established by calling the
 *		appropiate routine.
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

adb_break (x, line_no)
	int x;
	int line_no;
{
	if (! adb_control (x, line_no))
		return;

	if (x == NO_ADB_ACTION)
		return;

		return;


	switch (x)
	{
	case LINE:
		new_expr ();
		ASSIGN (INT);
		   P_NAME (0, INT, "_line_no");
		   ICON (line_no, INT, "");
		
		new_expr ();
		   UCALL (INT);
		      ICON (0, INT, "line_bre");

		break;

/*
	case XTASK_ENTRY:
 */
	case SUB_ENTRY:
		OUT (("&%d	sub_entr\n", ICJSR));		break;
	case SUB_EXIT:
		OUT (("&%d	sub_exit\n", ICJSR));		break;
	case PACK_ENTRY:
		OUT (("&%d	pack_ent\n", ICJSR));	break;
	case PACK_EXIT:
		OUT (("&%d	pack_exi\n", ICJSR));		break;
	DEFAULT (("adb_break: no default"));
	}
}

bool
adb_control (x, line_no)
	int x;
	int line_no;
{
	static old_x = 0;
	static old_line_no = 0;

	if (old_x == x && old_line_no == line_no)
		return FALSE;

	old_x = x;
	old_line_no = line_no;

	return TRUE;
}
