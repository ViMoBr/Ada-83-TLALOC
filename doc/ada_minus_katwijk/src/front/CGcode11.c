
/*
 * (c) copyright 1986, Delft University of Technology
 * Delft, The Netherlands
 *
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 * For further information contact
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 * SUPPORT ROUTINES FOR TASKING FACILITIES (CODE WALK)
 */

/* ASYNCHRONE is also defined in the interface to dats */

#define ASYNCHRONE	1

void	task_init (c, x)
struct _context *c;
ac	x;
{
	/* start the clock */
	new_expr ();
	CALL (VOID);
	    ICON (0, PF_INT, _SET_MOD);
	    ICON (ASYNCHRONE, LONG, "");

	s_must_do_task_init (FALSE);
}

void	new_mas (x)
ac	x;
{
	int	sc;

 	sc = T_stor_class (x);
	new_expr ();
	switch (sc) {
	   case GLOBAL:
	    	CALL (VOID);
		   ICON (0, PF_INT, _NEW_MAS);
	    	   G_MNAME (x);
		break;

	   case FIXSTACK:
	    	CALL (LONG);
		   ICON (0, PF_INT, _NEW_MAS);
	    	   LOC_NAME (curr_level, Moff (x), LONG);
		break;

	   DEFAULT (("new_master : storclass = %d\n", sc));
	}
	/* initialise the master chain, by resetting it to NULL */
	new_expr ();
	ASSIGN (P_LONG);
	   M_CHAIN (x, VAL);
	   ICON (0, P_LONG, "");
}

int	Moff (x)
register ac x;
{
	/* for each construct that may act as master, return the
	 * offset of the master in the current stack 
	 */
	ASSERT (x != NULL, ("Moff:1"));

	switch (g_d (x)) {
	   case XSUBBODY:
		return g_SBB_Moff (x);

	   case XBLOCK:
		return g_BLK_Moff (x);

	   case XTASKBODY:
		return g_TSB_Moff (x);

	   case XPACKBODY:
		return g_PB_Moff (x);

	   case XPACKAGE:
		return g_PS_Moff (x);

	   DEFAULT (("Moff: %d\n", g_d (x)));
	}
}

int	MCoff (x)
ac	x;
{
	/* for each construct that may act as master, return the
	 * offset of the masterchain in the current activation record 
	 */
	ASSERT (x != NULL, ("MCof:1"));

	switch (g_d (x)) {
	   case XSUBBODY:
		return g_SBB_MCoff (x);

	   case XBLOCK:
		return g_BLK_MCoff (x);

	   case XTASKBODY:
		return g_TSB_MCoff (x);

	   case XPACKAGE:
		return g_PS_MCoff (x);

	   case XPACKBODY:
		return g_PB_MCoff (x);

	   DEFAULT (("MCoff: %d\n", g_d (x)));
	}
}

void	M_CHAIN (x, val)
ac	x;
int	val;
{
	/* generates code for accessing the master_chain 
	 * as a lefthandside or as a righthandside, depending
	 * on the value of val (VAL) or (REF)
	 *
	 * -- Packages : Only global packages can act as
	 *	         master, here we have global, containing
	 *		 the wanted information.
	 */

	int	sc;

	ASSERT (x != NULL && g_d (x) != XALLOCATOR, ("xxxx"));

	sc = T_stor_class (x);
	switch (g_d (x)) {
	   case XLOOPBLOCK:
	   case XFORBLOCK:
		M_CHAIN (g_enclunit (x), val);
		return;

	   case XSUBBODY:
	   case XTASKBODY:
	   case XPACKBODY:
	   case XPACKAGE:
	   case XBLOCK:
		if (!is_master (x)) {
		   M_CHAIN (g_enclunit (x), val);
		   return;
		}
		switch (sc) {
		   case GLOBAL:
	    		G_MCNAME (x, val);
			break;

		   case FIXSTACK:
			if (val == VAL)
	    		   LOC_OBJECT (curr_level, MCoff (x), LONG);
			else
			   LOC_NAME (curr_level, MCoff (x), P_LONG);
			break;

		   DEFAULT (("strange sc in M_CHAIN: %d\n", sc));
		}
		break;

	   DEFAULT (("No master in MCHAIN"));
	}
}

void	MASTER (x, val)
ac	x;
int	val;
{
	/* generates code indicating the master
	 * depending on the environment
	 * -- Packages : Only global packages can act as
	 *	         master, here we have a global, containing
	 *		 the wanted information.
	 * -- Allocators :
	 * -- All the other :
	 *		 We have a local addressed via Moff
	 * the parameter 'x' is either a master structure or if not,
	 * we locate the master via __context
	 */

	int	sc;
	char	mastername [AIDL];

	ASSERT (x != NULL, ("MASTER:1"));

	if (g_enclunit (x) == NULL) {
	   /* level 0 packages */
	   sprintf (mastername, _STD_MASTER);
	   if (val == REF)
	       P_NAME (0, ADDRESS, mastername);
	   else
	       ICON (0, ADDRESS, mastername);
	   return;
	}
	
	switch (g_d (x)) {
	   case XLOOPBLOCK:
	   case XFORBLOCK:
	   case XPACKBODY:
	   case XPACKAGE:
		MASTER (g_enclunit (x), val);
		return;

	   case XSUBBODY:
	   case XTASKBODY:
	   case XBLOCK:
		if (!is_master (x)) {
		   MASTER (g_enclunit (x), val);
		   return;
		}

		sc = T_stor_class (x);
		ASSERT (Moff (x) != 0, 
			("Master : Moff = 0\n"));
		switch (sc) {
		   case GLOBAL:
	    		G_MNAME (x, val);
			break;

		   case FIXSTACK:
			if (val == VAL)
	    		   LOC_OBJECT (level_of (x), Moff (x), LONG);
			else
			   LOC_NAME (level_of (x), Moff (x), P_LONG)	;
			break;

		   DEFAULT (("strange sc in MASTER: %d\n",sc));
		}
		break;

	   DEFAULT (("No master %d in MASTER\n", g_d (x)));
	}
}

void	G_MOBJECT (x)
ac	x;
{
	char	mastername [AIDL];

	sprintf (mastername, "_MA%u", Moff (x));
	P_NAME (0, ADDRESS, mastername);
}

void	G_MNAME (x, val)
ac	x;
int	val;
{
	char	mastername [AIDL];

	sprintf (mastername, "_MA%u", Moff (x));
	if (val == REF)
	   P_NAME (0, ADDRESS, mastername);
	else
	   ICON (0, ADDRESS, mastername);
}

void	G_MCNAME (x, val)
ac	x;
int	val;
{
	char	mastername [AIDL];

	sprintf (mastername, "_MC%u", MCoff (x));
	if (val == VAL)
	   P_NAME (0, ADDRESS, mastername);
	else
	   ICON (0, ADDRESS, mastername);
}

int	non_triv_master (x)
ac	x;
{
	return (Moff (x));
}

