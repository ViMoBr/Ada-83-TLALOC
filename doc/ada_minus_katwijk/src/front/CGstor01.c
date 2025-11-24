
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
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"../h/print.h"
#include	"../h/tokens.h"
#include	"includes.h"
/*
 *	Forward (static) declarations
 */
static	void	add_dumm_decl	(); 
static	void	storage	();
static	void	stor_all	();
static	void	stats_sto	();
static	void	stat_sto  	();
static	void	sto_name	();
static	MAXADDR	sto_literal	();
static	MAXADDR	stringlit	();
static	void	elab_pack	();
static	void	entry_sub	();
/*
 *	READ AND PROCESS THE ENTIRE TREE
 *
 *	the main walking routine is stor_all, doing
 *
 *	- computation of the various storage allocation attributes,
 *	- making a pre-order walk to generate a prefix sequence
 *	  of all functions, either explicit ones or implicit ones
 *
 */

/*
 *	some local defines for pushing and popping context descriptions
 */
/***************************** global data *****************************/

ac	curr_proc	= NULL;	/* current subbody - has a static link */
ac	curr_unit	= NULL; /* current compilation unit */
ac	curr_ts		= NULL; /* current task_select construction */
int	curr_level	= 0;	/* subbody nesting.	*/

ac	curr_block	= NULL;	/* current block - has a local stacktop	*/
MAXADDR	lev_off		= 0;	/* offset within block	*/
MAXADDR	lev_maxoff	= 0;


/*
 *	is the proc structure x a mainproc?
 */
bool	mainproc (with_list, tree)
ac	with_list;
ac	tree;
{
	ac	y;

	ASSERT (tree != NULL, ("mainproc:0"));
	FORALL (y, with_list) {
	   if (g_d (y) == XSEPARATE)
	      return FALSE;
	}

	return TRUE;
}

/*
 *	Read the intermediate tree (name progn)
 *	Notice that reading of all "with-ed" units is implicitly performed
 *	by the tree reader
 *	Dispatch according to the type of the tree read and take
 *	appropriate actions
 */
int	generate_C (char * targetfilename,
                    ac     with_list,
                    ac     tree,
                    int    mainlun)
{
	s_code_context (NORMAL);
	/*
	 * The third parameter to get_tree is a dummy really
	 */
	ASSERT (tree != NULL, ("generate_C has a problem"));

	outfile = fopen  (targetfilename, "w");
	if (outfile == (FILE *)NULL) {
	   fail ((short) mainlun, 41);
	   exit (44);
	}

	init_outfile ();

/*	if (sdb_code) {
	   OUTDATA;
	   OUT (("&%d	%s\n", ICFILE, m_prog));
	   OUTTEXT;
	}
 */
	fprintf (outfile, "/*	%s		*/\n", targetfilename);
/*
 *	dispatch:
 */
	curr_unit = tree;
	curr_block = env;

	switch (g_d (tree)) {
	   case XSUB:
	      storage (tree);
	      add_dumm_decl ();
	      break;

	   case XSUBBODY:
	      curr_level = level_of (g_specif (tree));
	      storage (tree);
	      if (mainproc (with_list, tree)) {
	         entry_sub (tree);
	      }
	      break;

	   case XTASKBODY:
	      curr_level = level_of (g_specif (tree));
	      storage (tree);
	      break;

	   default:
		/* just treat it				*/
	      storage (tree);
	      elab_pack (tree);
	      break;
	}

	fclose (outfile);	/* to be changed later */
	PRINTF (("compilation unit parsed\n"));
}

/*
 *	The assembler on the micro-dutch does not allow
 *	an empty file to be assembled.
 *	Generate nonsense data for a subprogram specification
 */
static
void	add_dumm_decl () 
{
	char name [AIDL];
	int lab = new_lab ();
	sprintf (name, "_XSUBDUMMY%u",lab);
	OUTDATA;
	OUTBSS;
	OUT (("&%d	%s\n", ICGLOBL, name));
	OUT (("&%d	%s\n", ICDLABS, name));
	OUT (("&%d	%d	\n", ICSKIP, TADDRSIZE));
	OUTTEXT;
}

/*
 *	Compute the storage requirements for the list of items x
 */
static
void	storage (x)
ac	x;
{
	ac	y;

	FORALL (y, x) {
	   stor_all (y, NULL);
	}
}

/*
 *	Compute the storage requirements for the item x
 */
static
void	stor_all (x, stub)
ac	x;
ac	stub;
{
	PROC_VARS;	/* just needed some times  implies STAT, BLOCK */
	int	t1,
		t2; 
	char	*y;

	switch (g_d (x)) {
	   case XGENNODE:
	      COM (("generic %s\n", g_tag (x)));
	      return;

	   case XTASKTYPE:
	      COM (("tasktype %s\n", g_tag (x)));
	      visit_local (x);
	      storage (g_fentry (x));
	      if (stor_class (x) == GLOBAL) {
	         defgloblab (x);
	      }
	      return;

	   case XARRAYTYPE:
	      COM (("arraytype %s\n", g_tag (x)));
	      visit_local (x);
	      if (stor_class (x) == GLOBAL)
	         defgloblab (x);
	      return;

	   case XACCTYPE:
	      COM (("acctype %s\n", g_tag (x)));
	      visit_local (x);
	      if (stor_class (x) == GLOBAL)
	         defgloblab (x);
	      return;

	   case XRECTYPE:
	      COM (("rectype %s\n", g_tag (x)));
	      visit_local (x);
	      path_function (x);
	      if (stor_class (x) == GLOBAL)
	         defgloblab (x);
	      return;

	   case XNEWTYPE:
	      COM (("newtype %s\n", g_tag (x)));
	      return;

	   case XINHERIT:
	      COM (("inherited %s\n", g_tag (x)));
	      return;

	   case XINCOMPLETE:
	      COM (("%s\n", g_tag (x)));
	      visit_local (x);
	      return;

	   case XPRIVTYPE:
	      COM (("%s\n", g_tag (x)));
	      visit_local (x);
	      return;

	   case XPACKAGE:
	      COM (("%s\n", g_tag (x)));
	      storage (g_fvisitem (x));
	      return;

	   case XPRIVPART:
	      COM (("%s\n", g_tag (x)));
	      storage (g_fprivitem (x));
	      return;

	   case XSUBTYPE:
	      COM (("subtype %s\n", g_tag (x)));
	      visit_local (x);
	      sto_expr (g_parenttype (x));
	      if (g_d (g_parenttype (x)) == XFILTER && stor_class (x) == GLOBAL)
	         defgloblab (x);
	      return;

	   case XRENSUB:
	      COM (("rensub %s\n", g_tag (x)));
	      visit_local (x);
	      return;

	   case XSUB:
	      COM (("elaborate spec of sub %s\n", g_tag (x)));
	      visit_local (x);
	      return;

	   case XENTRY:
	      COM (("entry call to entry nr %d\n", g_e_num (x)));
	      visit_local (x);
	      return;

	   case XENUMTYPE:
	      COM (("enumtype %s\n", g_tag (x)));
	      visit_local (x);
	      defgloblab (x);
	      return;

	   case XSUBBODY:
	      COM (("elaborate subbody %s\n", g_tag (x)));
	      PUSH_PROC (x);
	      visit_local (x);
	      storage (g_fbodyloc (x));
	      stats_sto (g_SBB_stats (x));
	      stats_sto (g_SBB_exh (x));
	      gen_body (x);
	      POP_PROC;
	      return;

	   case XTASKBODY:
	      COM (("elaborate taskbody %s\n", g_tag (x)));
	      PUSH_PROC (x);
	      visit_local (x);
	      storage (g_fbodyloc (x));
	      stats_sto (g_task_stats (x));
	      stats_sto (g_task_exh (x));
	      gen_tbody (x);
	      POP_PROC;
	      return;

	   case XPACKBODY:
	      COM (("package body %s\n", g_tag (x)));
	      if (g_specif (x) != NULL &&
	          is_generic (g_specif (x)) )
	         return;
	      visit_local (x);
	      storage (g_fbodyloc (x));
	      stats_sto (g_PB_stats (x));
	      stats_sto (g_PB_exh (x));
	      return;

	   case XOBJECT:
	      COM (("object %s\n", g_tag (x)));
	      visit_local (x);
	      /* if it is a task, remember it */
	      s_flags (x,
                  g_flags (x) | (getflags (g_objtype (g_desc (x)))) & F_TASK);
	      if ((g_flags (x) & F_TASK) != 0) {
	         current_env_to_master (x);
	      }

	      /* Only for composite items */
	      if (expr_provides_constraints (g_objtype (g_desc (x)))) {
	         sto_expr (g_expr (g_desc (x)));
	         s_flags (x, g_flags (x) | geteflags (g_expr (g_desc (x))));	
	      }
	      else
	      {  PUSH_STAT;
	         sto_expr (g_expr (g_desc (x)));
	         s_flags (x, g_flags (x) | geteflags (g_expr (g_desc (x))));
	         POP_STAT;
	      }

	      if (stor_class (x) == GLOBAL || stor_class (x) == GLOBDYN)
	         defgloblab (x);

	      return;

	   case XCHARLIT:
	      COM (("%s\n", g_tag (x)));
	      return;

	   case XENUMLIT:
	      COM (("enumlit %s\n", g_tag (x)));
	      return;

	   case XEXCEPTION:
	      COM (("exception %s\n", g_tag (x)));
	      if (g_rnam (x) != NULL)	/* renaming, just ignore	*/
	         return;

	      OUTDATA;
	      defgloblab (x);
	      defexprlab (x);
	      /*
	       * to allow the runtime system to find out the
	       * name of the exception
	       */
	      OUT (("&%d	%s	\n", ICSTRING, g_tag (x)));
	      OUTEVEN;
	      OUTTEXT;
	      return;

	   case XRENOBJ:
	      COM (("renobj: %s\n", g_tag (x)));
	      visit_local (x);
	      return;

	   case XRENPACK:
	      COM (("renpack: %s\n", g_tag (x)));
	      return;

	   case XUSE:
	      return;

	   case XSTUB:
	      COM (("stub\n"));
	      return;

	   DEFAULT (("local: unknown type %d", g_d (x)));
	}
}

/*
 *	Compute storage requirements for statements
 */
static
void	stats_sto (x)
ac	x;
{
	ac	y;

	FORALL (y, x)
	   stat_sto (y);
}

/*
 *	Compute storage requirements for statement x
 */
static
void	stat_sto   (x)
ac	x;
{
	ac	y;
	BLOCK_VARS;	/* implies STATVARS		*/
	TS_VARS;

	if (x == NULL)
	   return;

	PUSH_STAT;
	show_storage (x);

	switch (g_d (x)) {
	   case XASSIGN:
	      COM (("assign\n"));
	      sto_expr (g_rhs (x));
	      sto_expr (g_lhs (x));
	      s_flags (x, g_flags (x) | (geteflags (g_rhs (x)),
		                              geteflags (g_lhs (x))));
	      break;

	   case XACCEPT:
	      COM (("accept\n"));
	      stats_sto (g_accept_stats (x));
/*
	      stats_sto (g_next (x));
 */
	      break;

	   case XTERMINATE:
	      COM (("terminate\n"));
	      break;

	   case XABORTSTAT:
	      COM (("abortstatement\n"));
	      sto_expr (g_abortedtask (x));
	      break;

	   case XDELAY:
	      COM (("delay\n"));
	      sto_expr (g_delay_expr (x));
	      break;

	   case XEXIT:
	      COM (("exit\n"));
	      sto_expr (g_exitcond (x));
	      break;

	   case XRETURN:
	      COM (("return\n"));
	      sto_expr (g_retexpr (x));
	      break;

	   case XSUBCALL:
	      COM (("subcall\n"));
	      sto_expr (g_subpr (x));
	      s_flags (x, geteflags (g_subpr (x)));
	      break;

	   case XRAISE:
	      COM (("raise\n"));
	      sto_expr (g_exc_task (x));
	      break;

	   case XIF:
	      COM (("if\n"));
	      FORALL (y, g_IF_items (x)) {
	         stat_sto (y);
	         s_flags (x, g_flags (x) | geteflags (g_ifcond (y)));
	      }
	      break;

	   case XIFITEM:
	      COM (("ifitem\n"));
	      sto_expr (g_ifcond (x));
	      stats_sto (g_IF_stats (x));
	      break;

	   case XCASE:
	      COM (("case\n"));
	      sto_expr (g_caseexpr (x));
	      stats_sto (g_CASE_items (x));
	      break;

	   case XWHENITEM:
	      COM (("whenitem (case)\n"));
	      stats_sto (g_WI_stats (x));
	      break;

	   case XFORBLOCK:
	      COM (("forblock\n"));
	      PUSH_BLOCK (x);
	      storage (g_looppar (x));
	      stats_sto (g_FB_stats (x));
	      POP_BLOCK;
	      break;

	   case XLOOPBLOCK:
	      COM (("loopblock\n"));
	      PUSH_BLOCK (x);
	      sto_expr (g_cond (x));
	      stats_sto (g_LPB_stats (x));
	      POP_BLOCK;
	      break;

	   case XEXHANDLER:
	      COM (("exhandler\n"));
	      stats_sto (g_EXH_items (x));
	      break;

	   case XBLOCK:
	      COM (("block\n"));
	      PUSH_BLOCK (x);
	      visit_local (x);
	      storage (g_fblockloc (x));
	      stats_sto (g_BLK_stats (x));
	      stats_sto (g_BLK_exh (x));
	      POP_BLOCK;
	      break;

	   case XTASKSELECT:
	      COM (("taskselect\n"));
	      PUSH_TS (x);
	      visit_local (x);
	      FORALL (y, g_SELECT_items (x)) {
	         sto_expr (g_fwhenchoice (y));
	         stats_sto (g_WI_stats (y));
	      }
	      POP_TS;
	      break;

	   DEFAULT (("stat_sto: %d\n", g_d (x)));
	}

	POP_STAT;
}

/*
 *	allocate space for components of an expression
 *	set the various flags
 */
void	sto_expr (x)
ac	x;
{
	ac	y;
	PROC_VARS;	/* just needed once	*/

	if (x == NULL)
	   return;
	
	show_storage (x);

	switch (g_d (x)) {
	   case XPARENTHS:
	      COM (("parenths\n"));
	      sto_expr (g_subexpr (x));
	      return;

	   case XFILTER:
	      COM (("filter\n"));
	      sto_expr (g_constraint (x));
	      s_flags (x, g_flags (x) | geteflags (g_constraint (x)));
	      return;

	   case XRANGE:
	      COM (("range\n"));
	      FORALL (y, g_frang_exp (x)) {
	         sto_expr (y);
	         s_flags (x, g_flags (x) | geteflags (y));
	      }
	      return;

	   case XINDEXCONS:
	      COM (("indexcons\n"));
	      FORALL (y, g_frange (x)) {
	         sto_expr (y);
	         s_flags (x, g_flags (x) | geteflags (y));
	      }
	      return;

	   case XDISCRCONS:
	      COM (("discrcons\n"));
	      FORALL (y, g_aggregate (x)) {
	         sto_expr (y);
	         s_flags (x, g_flags (x) | geteflags (y));
	      }
	      return;

	   case XNAMEDASS:
	      COM (("namedass\n"));
	      sto_expr (g_nexp (x));
	      s_flags (x, g_flags (x) | geteflags (g_nexp (x)));
	      return;

	   case XCOMPASSOC:
	      COM  (("component association\n"));
	      sto_expr (g_compexpr (x));
	      s_flags (x, g_flags (x) | geteflags (g_compexpr (x)));
	      return;

	   case XTHUNK:
	      COM (("thunk\n"));
	      PUSH_PROC (x);
	      sto_expr (g_thexpr (x));
	      s_flags (x, g_flags (x) | geteflags (g_thexpr (x)));
	      /*
	       * the artificial function is made in
	       * "CGstor02"recfield()
	       */
	      POP_PROC;
	      return;

	   case XSCC:
	      COM (("xscc\n"));
	      sto_expr (g_fsccexpr (x));
	      sto_expr (g_next (g_fsccexpr (x)));
	      s_flags (x, g_flags (x) | (geteflags (g_fsccexpr (x)) |
	                                 geteflags (g_next (g_fsccexpr (x)))));
	      lev_off = scc (x, lev_off);
	      return;

	   case XOBJECT:
	      COM (("object %s\n", g_tag (x)));
	      return;

	   case XRENOBJ:
	      COM (("renobject %s\n", g_tag (x)));
	      return;

	   case XENUMLIT:
	      COM (("enumlit %s\n", g_tag (x)));
	      return;

	   case XCHARLIT:
	      COM (("charlit %d\n", g_tag (x) [0]));
	      return;

	   case XLITERAL:
	      COM (("literal"));
	      lev_off = sto_literal (x, lev_off);
	      return;

	   case XNAME:
	   case XALL:
	   case XCALL:
	   case XATTRIBUTE:
	   case XENTRYCALL:
	   case XSLICE:
	   case XSELECT:
	   case XINDEXING:
	      COM (("a name construct\n"));
	      sto_name (x);
	      return;

	   case XIN:
	      COM (("in\n"));
	      sto_expr (g_inexpr (x));
	      s_flags (x, g_flags (x) | geteflags (g_inexpr (x)));
	      sto_expr (g_intype (x));
	      s_flags (x, g_flags (x) | geteflags (g_intype (x)));
	      return;

	   case XALLOCATOR:
	      COM (("allocator\n"));
	      sto_expr (g_obtype (x));
	      s_flags (x, g_flags (x) | geteflags (g_obtype (x)));
	      return;

	   case XEXP:
	      COM (("expr\n"));
	      /* dirty trick for aggregates		*/
	      if (g_d (g_primary (x)) == XAGGREGATE) {
	         lev_off = aggregate (g_primary (x), lev_off, g_exptype (x));
	         gen_aggregate (g_primary (x), g_exptype (x));
	      }
	      else {
	         sto_expr (g_primary (x));
	         s_flags (x, g_flags (x) | geteflags (g_primary (x)));
	      }
	      return;

	   case XINTERNAL:
	      return;

	   default:
	      return;		/* probably some type */
	}
}

/*
 *	sto_name: allocate the storage required for the
 *	evaluation of a name construct. Note that
 *	the elements of this computation actually start
 *	the propagation of the non-normal flags
 */
static
void	sto_name (x)
ac	x;
{
	ac	ass;

	if (x == NULL)
	   return;
	/*
	 * process the value creating subtree
	 * a singular point is the treatment of NAME
	 * NAME has, however, by convention a next field (filled 0)
	 */
	sto_name (g_next (x));

	switch (g_d (x)) {
	   case XCALL:
	      lev_off = calling (x, lev_off);
	      s_flags (x, g_flags (x) | geteflags (x));
	      FORALL (ass, g_fact (x)) {
	         sto_expr (g_nexp (ass));
	         s_flags  (x, g_flags (x) | geteflags (g_nexp (ass)));
	      }
	      return;

	   case XENTRYCALL:
	      FORALL (ass, g_fact (x)) {
	         sto_expr (g_nexp (ass));
	         s_flags (x, g_flags (x) | geteflags (g_nexp (ass)));
	      }
	      stat_sto (g_call_delay (x));
	      stats_sto (g_call_stats (x));
	      stats_sto (g_call_next (x));
	      return;

	   case XINDEXING:
	      FORALL (ass, g_farg (x)) {
	         sto_expr (ass);
	         s_flags (x, g_flags (x) | geteflags (ass));
	      }
	      return;

	   case XSELECT:
	      return;

	   case XATTRIBUTE:
	      lev_off = attributing (x, lev_off);
	      sto_expr (g_entity (x));
	      s_flags (x, g_flags (x) | geteflags (g_entity (x)));
	      return;

	   case XSLICE:
	      lev_off = slicing (x, lev_off);
	      s_flags (x, g_flags (x) | geteflags (x));
	      sto_expr (g_slrange (x));
	      s_flags (x, g_flags (x) | geteflags (g_slrange (x)));
	      return;

	   case XALL:
	      lev_off = all (x, lev_off);
	      return;

	   case XNAME:
	      return;

	   DEFAULT (("sto_name: %d\n", g_d (x)));
	}
}

/*
 *	Compute the storage requirement of a literal
 *	Generally easy, take case of floats and strings
 */
static
MAXADDR	sto_literal (x, offset)
ac	x;
MAXADDR	offset;
{
	ASSERT (x != NULL && g_d (x) == XLITERAL, ("literal"));

	switch (g_val (x) -> litkind) {
	   case S_INTLIT:
	      return offset;	/* no further actions	*/

	   case S_NULLLIT:
	      return offset;	/* no further actions		*/

	   case S_REALLIT:
	      s_LIT_Voff (x, new_lab ());	/* put literal in two	*/
	      OUTDATA;
	      deflab (g_LIT_Voff (x));
	      PUT (DEF_DOUBLE, g_val (x) -> litvalue);
	      OUTTEXT;
	      return offset;

	   case S_STRINGLIT:
	      offset = stringlit (x, offset);	/* make it addressable */
	      return offset;

	   DEFAULT (("sto_literal: unknown kind of literal %d",
				g_val (x) -> litkind) );
	}
}

static
MAXADDR	stringlit (x, offset)
ac	x;
MAXADDR	offset;
{
	ac	type;
	char	*c,
		*s;
	int	n,
		i;
	char datatext [AIDL];

	ASSERT (x != NULL, ("stringlit"));
	type = base_type (g_littype (x));
	/* the value : always global */

	s_LIT_Voff (x, new_lab ());
	s = g_val (x) -> litvalue;
	n = g_val (x) -> n;

	OUTDATA;
	deflab (g_LIT_Voff (x));
	for (i = n; i > 0; i--)
	   PUT (DEF_BYTE, *s++);

	OUTEVEN;
	OUTTEXT;

	/* the descriptor */
	ASSERT (g_d (type) == XARRAYTYPE, ("stringlit:2"));
	if (g_ARR_alloc (type) != GLOBAL) {
	   offset = incr_off (offset, sz_vdarr (ONE));
	   offset = align (offset, MAX_ALIGN);
	   s_LIT_Doff (x, offset);
	   /* the descriptor will be generated when needed */
	}
	else {
	   s_LIT_Doff (x, new_lab ());
	   OUTDATA;
	   deflab (g_LIT_Doff (x));
	   PUT (DEF_LONG, VD_ARR);
	   setdatalab (base_type (type), datatext);
	   PUT (DEF_SLONG, datatext);
	   PUT (DEF_LONG, align (n, MAX_ALIGN));
	   PUT (DEF_LONG, 1);
	   PUT (DEF_LONG, 1);
	   PUT (DEF_LONG, n);
	   OUTTEXT;
	}
	return offset;
}

/*
 *	generate elaboration code
 *	elab_pack: for packages and their bodies
 *	for  subs: entrysub
 */
static
void	elab_pack (handle)
ac	handle;
{
	char	elabname [AIDL];
	int	endlab	= new_lab ();
	int	S_lab	= new_lab ();
	int	E_lab	= new_lab ();

	sprintf (elabname, "_E%u", lun_of (handle));

	OUT (("&%d	%s\n", ICGLOBL, elabname));
	OUT (("&%d	%d	%d	%d	%s\n",	
				ICFBEG, S_lab, E_lab, FALSE, elabname));
	OUT (("[%d	%d	%d	%d	\n",
				S_lab, (lev_maxoff + C_BASE) * BPB, 7, 13));


	gen_code (handle);

	OUT (("&%d	\n", ICFEND));
	OUT (("&%d	%d	\n", ICDLABN, endlab));
	OUT (("&%d	\n", ICFEND));

	new_expr ();
	UCALL (VOID);
	   ICON (0, PF_INT, __HARDRET);

	OUT (("]\n"));
}

/*
 *	Specifying a function is elaborating its specification
 */
static
void	entry_sub (handle)
ac	handle;
{
	char entryname [AIDL];
	char datatext [AIDL];

	sprintf (entryname, "_S%u", lun_of (g_specif (handle)));

	OUTDATA;
	OUT (("&%d	%s\n", ICGLOBL, entryname));
	OUT (("&%d	%s\n", ICDLABS, entryname));

	setdatalab (g_specif (handle), datatext);
	PUT (DEF_SLONG, datatext);

	OUTTEXT;
}

/*
 *	Show (tracing) storage information
 */
void	show_storage (x)
ac	x;
{
	short	lun;
	short	ind;

/* if no visable storage alloaction
 * then do nothing
 */
	if (x == NULL)
	   return;

	if (!has_link (x))
	   return;
/* else show the particulars of the node to be storage'd
 */
	lun = lun_of (x);
	ind = index_of (x);

	return;

	if (lun > STD_LUN)
	   printf ("%4u %4u ",lun, ind);
	else
	   printf ("%9x ",x);

	printf ("%15s ", token [g_d (x)]);
	printf ("off %4d maxoff %4d",lev_off,lev_maxoff);
	if (has_tag (x))
	   printf (" %s",g_tag (x));
	else
	   printf (" no tag");
	printf ("\n");
}

