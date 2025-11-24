/*
 * (c) copyright 1986, Delft University of Technology
 * Delft, The Netherlands
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 * For further information contact
 *	Jan van Katwijk
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 */

#include	<stdio.h>
#include	"../h/tree.h"
#include	"../h/std.h"
#include	"../h/put_tree.h"
#include	"../h/record_man.h"
#include	"../h/reader.h"
#include	"../h/rec_sizes.h"
/*
 *	Forward (static) declarations
 */
static	bool	not_to_be_put	();
static	void	put_indir	();
static	void	put_type	();

static
bool	not_to_be_put(pnt)
register ac pnt;
{
	switch (g_d (pnt)) {
	   case XOBJDESC:
	   case XOBJECT:
	   case XMARK:
	   case XINTERNAL:
	      return TRUE;

	   default:
	      return FALSE;
	}
}

static
void	put_indir (f, x)
FILE *f;
ac	x;
{
	ac	y;

	y = alloc (XINDIRECT);
	s_indir (y, x);
	put_rec (f, y);
	put_mark (f);

	delete_rec (&y);
}

static
void	put_type (f, x)
FILE	*f;
ac	x;
{
	ac	y;

	if (x == NULL)
	   return;

	if (g_d (x) == XFILTER || g_d (x) == XEXP)
	   put_tree (f, x);
	else
	   put_indir (f, x);
}

void	put_list (f, pnt)
FILE	*f;
ac	pnt;
{
	ac	t;

	FORALL (t, pnt) {
	   put_tree (f, t);
	}
}

void	put_tree (f, pnt)
FILE	*f;
ac	pnt;
{
	ac	x,
		y;

	if (pnt == NULL)
	   return;

	if (g_d (pnt) == XTAGSTAT)
	   return;

	put_rec (f, pnt);

	switch (g_d (pnt)) {
		case XABORTSTAT:
			put_tree (f, g_abortedtask (pnt));
			break;

		case XACCTYPE:
			break;


		case XAGGREGATE:
			put_type (f, g_aggtype (pnt));
			put_list (f, g_fcompas (pnt));
			goto X_mark;

		case XALL:
			put_tree (f, g_next (pnt));
			goto X_mark;

		case XALLOCATOR:
			put_type (f, g_obtype (pnt));
			goto X_mark;

		case XARRAYTYPE:
			put_list (f, g_findex (pnt));
			break;

		case XASSIGN:
			put_tree (f, g_lhs (pnt));
			put_tree (f, g_rhs (pnt));
			break;

		case XATTRIBUTE:
			put_tree (f, g_entity (pnt));
			put_mark (f);
			put_tree (f, g_next (pnt));
			goto X_mark;

		case XBLOCK:
			put_list (f, g_fblockloc (pnt));
			put_list (f, g_BLK_stats (pnt));
			put_tree (f, g_BLK_exh (pnt));
			break;

		case XSUBBODY:
			put_list (f, g_fbodyloc (pnt));
			put_list (f, g_SBB_stats (pnt));
			put_tree (f, g_SBB_exh (pnt));
			break;

		case XPACKBODY:
			put_list (f, g_fbodyloc (pnt));
			put_list (f, g_PB_stats (pnt));
			put_tree (f, g_PB_exh (pnt));
			break;

		case XCALL:
			put_list (f, g_fact (pnt));
			put_mark (f);
			put_tree (f, g_next (pnt));
			goto X_mark;

		case XENTRYCALL:
			put_list (f, g_fact (pnt));
			put_mark (f);
			put_tree (f, g_next (pnt));
			put_tree (f, g_call_delay (pnt));
			put_list (f, g_call_next  (pnt));
			put_mark (f);
			put_list (f, g_call_stats (pnt));
			goto X_mark;

		case XCASE:
			put_tree (f, g_caseexpr (pnt));
			put_list (f, g_CASE_items (pnt));
			break;

		case XCHARLIT:
			break;

		case XCOMPASSOC:
			put_list (f, g_fcompchoice (pnt));
			put_mark (f);
			put_tree (f, g_compexpr (pnt));
			break;

		case XDISCR:
			goto X_mark;

		case XDISCRCONS:
			put_list (f, g_aggregate (pnt));
			goto X_mark;

		case XENUMLIT:
			break;

		case XENUMTYPE:
			put_list (f, g_fenumlit (pnt));
			break;

		case XEXCEPTION:
			break;

		case XEXHANDLER:
			put_list (f, g_EXH_items (pnt));
			break;

		case XEXIT:
			put_tree (f, g_exitcond (pnt));
			break;

		case XEXP:
			put_tree (f, g_primary (pnt));
			break;

		case XFILTER:
			put_tree (f, g_constraint (pnt));
			goto X_mark;

		case XFORBLOCK:
			put_list (f, g_looppar (pnt));
			put_list (f, g_FB_stats (pnt));
			break;

		case XFORUSE:
			put_tree (f, g_useexpr (pnt));
			break;

		case XGOTO:
			goto X_mark;

		case XIF:
			put_list (f, g_IF_items (pnt));
			break;

		case XIFITEM:
			put_tree (f, g_ifcond (pnt));
			put_list (f, g_IF_stats (pnt));
			break;

		case XIN:
			put_type (f, g_intype (pnt));
			put_tree (f, g_inexpr (pnt));
			goto X_mark;

		case XINCOMPLETE:
			put_list (f, g_fidiscr (pnt));
			break;

		case XINDEX:
			break;

		case XINDEXCONS:
			put_list (f, g_frange (pnt));
			goto X_mark;

		case XINDEXING:
			put_list (f, g_farg (pnt));
			put_mark (f);
			put_tree (f, g_next (pnt));
			goto X_mark;

		case XINHERIT:
			break;

		case XINTERNAL:
			break;

		case XLITERAL:
			goto X_mark;

		case XLOOPBLOCK:
			put_tree (f, g_cond (pnt));
			put_list (f, g_looplocals (pnt));
			put_list (f, g_LPB_stats (pnt));
			break;

		case XMARK:
			break;

		case XNAME:
			goto X_mark;

		case XNAMEDASS:
			put_tree (f, g_nexp (pnt));
			break;

		case XNEWTYPE:
			put_list (f, g_enlits (pnt));
			break;

		case XOBJDESC:
			put_tree (f, g_expr (pnt));
			break;

		case XOBJECT:
		        put_tree (f, g_desc (pnt));
			break;

		case XPACKAGE:
			put_list (f, g_fvisitem (pnt));
			break;

		case XGENNODE:
			put_list (f, g_genpars (pnt));
			put_mark (f);	/* one extra	*/
			put_tree (f, g_genunit (pnt));
			break;

		case XGENPARTYPE:
			break;

		case XTASKTYPE:
			put_list (f, g_fentry (pnt));
			break;

		case XENTRY:
			put_list (f, g_fformal (pnt));
			break;

		case XTASKBODY:
			put_list (f, g_fbodyloc (pnt));
			put_list (f, g_task_stats (pnt));
			put_tree (f, g_task_exh (pnt));
			break;

		case XACCEPT:
			put_list (f, g_accept_stats (pnt));
			put_mark (f);
			break;

		case XDELAY:
			put_tree (f, g_delay_expr (pnt));
			break;

		case XTERMINATE:
			break;

		case XTASKSELECT:
			put_list (f, g_SELECT_items (pnt));
			break;

		case XPARENTHS:
			put_tree (f, g_subexpr (pnt));
			goto X_mark;

		case XPRIVPART:
			put_list (f, g_fprivitem (pnt));
			break;

		case XPRIVTYPE:
			put_list (f, g_fpdiscr (pnt));
			break;

		case XRAISE:
			put_tree (f, g_exc_task (pnt));
			break;

		case XRANGE:
			put_list (f, g_frang_exp (pnt));
			break;

		case XRECTYPE:
			put_list (f, g_ffield (pnt));
			put_tree (f, g_dis (pnt));
			break;

		case XRENOBJ:
			put_tree (f, g_name (pnt));
			break;

		case XRENPACK:
			break;

		case XRENSUB:
			put_list (f, g_fformal (pnt));
			put_tree (f, g_subname (pnt));
			break;

		case XRETURN:
			put_tree (f, g_retexpr (pnt));
			break;

		case XSCC:
			put_list (f, g_fsccexpr (pnt));
			goto X_mark;

		case XSELECT:
			put_tree (f, g_next (pnt));
			goto X_mark;

		case XSEPARATE:
			break;

		case XSLICE:
			put_tree (f, g_slrange (pnt));
			put_mark (f);
			put_tree (f, g_next (pnt));
			goto X_mark;

		case XSTUB:
			break;

		case XSUB:
			put_list (f, g_fformal (pnt));
			put_tree (f, g_sub_default (pnt));
			break;

		case XSUBCALL:
			put_tree (f, g_subpr (pnt));
			break;

		case XSUBTYPE:
			put_type (f, g_parenttype (pnt));
			break;

		case XTAGSTAT:
			break;

		case XTHUNK:
			put_tree (f, g_thexpr (pnt));
			goto X_mark;

		case XTRIPLE:
			break;

		case XTYPECONV:
			put_tree (f, g_convexpr (pnt));
			goto X_mark;

		case XUSE:
			break;

		case XVARIANT:
			put_list (f, g_varchoice (pnt));
			put_list (f, g_ffield (pnt));
			put_tree (f, g_dis (pnt));
			break;

		case XWHENITEM:
			put_list (f, g_fwhenchoice (pnt));
			put_list (f, g_WI_stats (pnt));
			break;

		DEFAULT (("do not what tree this is %d \n", g_d (pnt)));
		
X_mark:
			put_mark (f);
			return;
		}

		put_mark (f);
}

void	del_tree (x)
ac	x;
{
}

