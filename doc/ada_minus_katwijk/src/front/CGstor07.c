
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
 *	For further information contact
 *      Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 *XXX	TASKING SUPPORT ROUTINES
 *
 *	Forward (static) declarations
 */
static	void	set_Moff	();
static	void	set_MCoff	();

bool	is_master (x)
ac	x;
{
	ASSERT (x != NULL, ("is_master:1"));

	switch (g_d (x)) {
	   case XSUBBODY:
	   case XPACKBODY:
	   case XTASKBODY:
	   case XBLOCK:
	   case XPACKAGE:
	      return (g_flags (x) & F_MASTER) != 0;

	   DEFAULT (("is_master: strange master %d\n", g_d (x)));
	}
}

bool	has_tasks (flags)
int	flags;
{
	return (flags & F_TASK) != 0;
}

MAXADDR	alloc_master (x, off)
ac	x;
MAXADDR off;
{
	int	lab;
	char	name [AIDL];

	/* assign storage class in master environments */
	int	st = T_stor_class (x);

	if (Moff (x))
	   return off;

	/* mark the node as master (to be used in code walk) */
	s_flags (x, (g_flags (x) | F_MASTER));
	switch (st) {
	   case GLOBAL:
	      lab = new_lab ();
	      set_Moff (lab, x);
	      sprintf (name, "_MA%u",lab);
	      OUTDATA;
	      OUTBSS;
	      OUT (("&%d	%s\n", ICGLOBL, name));
	      OUT (("&%d	%s\n", ICDLABS, name));
	      OUT (("&%d	%d	\n", ICSKIP, TMASTERSIZE));
	      OUTTEXT;

	      lab = new_lab ();
	      set_MCoff (lab,x);
	      sprintf (name, "_MC%u",lab);
	      OUTDATA;
	      OUTBSS;
	      OUT (("&%d	%s\n", ICGLOBL, name));
	      OUT (("&%d	%s\n", ICDLABS, name));
	      OUT (("&%d	%d	\n", ICSKIP, TADDRSIZE));
	      OUTTEXT;
	      break;

	   case FIXSTACK:
	      /* dirty allocation */
	      off = align (off, MAX_ALIGN);
	      off += TMASTERSIZE;
	      set_Moff (off, x);
	      off += TADDRSIZE;
	      set_MCoff (off, x);
	      break;

	   DEFAULT (("alloc_master: strange storage_class : %d\n", st));
	}

	return off;
}

static
void	set_Moff (off, x)
int	off;
ac	x;
{
	/* for each construct that may act as master, return the
	 * offset of the master in the current stack 
	 */
	switch (g_d (x)) {
	   case XSUBBODY:
		s_SBB_Moff (x, off);
		break;

	   case XBLOCK:
		s_BLK_Moff (x, off);
		break;

	   case XTASKBODY:
		s_TSB_Moff (x, off);
		break;

	   case XPACKBODY:
		s_PB_Moff (x, off);
		break;

	   case XPACKAGE:
		s_PS_Moff (x, off);
		break;

	   DEFAULT (("set_Moff: %d\n", g_d (x) ));
	}
}

static
void	set_MCoff (off, x)
int	off;
ac	x;
{
	/* for each construct that may act as master, return the
	 * offset of the masterchain in the current activation record 
	 */
	switch (g_d (x)) {
	   case XSUBBODY:
		s_SBB_MCoff (x, off);
		break;

	   case XBLOCK:
		s_BLK_MCoff (x, off);
		break;

	   case XTASKBODY:
		s_TSB_MCoff (x, off);
		break;

	   case XPACKAGE:
		s_PS_MCoff (x, off);
		break;

	   case XPACKBODY:
		s_PB_MCoff (x, off);
		break;

	   DEFAULT (("MCoff: %d\n", g_d (x)));
	}
}

int	T_stor_class (x)
ac	x;
{
	while (TRUE) {
	   ASSERT (x != NULL, ("T_stor_class:0"));

	   switch (g_d (x)) {
	      case XBLOCK:
	      case XPACKAGE:
	      case XPACKBODY:
	      case XLOOPBLOCK:
	      case XFORBLOCK:
	      case XACCEPT:
	         x = g_enclunit (x);
                 break;

	      case XTASKBODY:
	      case XSUBBODY:
		 return FIXSTACK;

	      default:
		 return stor_class (x);
	   }
	}
}

MAXADDR	current_env_to_master (x, off)
ac	x;
MAXADDR	off;
{
	ASSERT (x != NULL, ("current_env_to_master:1"));

	while (TRUE) {
	   if (x == NULL)
	      return off;

	   switch (g_d (x)) {
	      case XSUBBODY:
	      case XTASKBODY:
	      case XBLOCK:
		 off = alloc_master (x, off);
		 s_flags (x, (g_flags (x) | F_MASTER));
		 return off;

	      default:
                 x = g_enclunit (x);
	         break;
	   }
	}
}

