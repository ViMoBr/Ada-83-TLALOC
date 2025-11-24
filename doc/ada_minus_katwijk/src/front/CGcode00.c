
/*
 * (c) copyright 1986/87/88, Delft University of Technology
 * Delft, The Netherlands
 *
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada- Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 *	For further information contact
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */



/*
 * File:	CGcode00.c
 * 
 * Description:	CGcode00.c is the main code generator.
 *
 */

#include	"includes.h"

struct _status_info status_info; /* in CGcode00.c */
int	curr_line		= 0;	/* supports the notion of current line	*/
struct	_context	*__context = NULL;
struct	_accepts	*ast       = NULL;

/*
 *	Forward declarations for statics:
 */
static	void	g_code		();
static	void	elab_code	();
static	void	task_elab_code	();
static	void	pb_elabcode	();
static	void	stat_code	();
static	void	ifitem_code	();

/*
 *	To deal with the stupidity of sdb, it has
 *	to be recorded whether or not we are inside
 *	a (target) function or procedure
 */
bool	in_body = FALSE;

static int	retlab;	/* return address of current procedure */
/* Function Header Declarations */


/*
 * Name:	gen_code
 *
 * Abstract:	top level code generation driver.
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
void	gen_code (x)
ac	x;
{
	ac	y;

	FORALL (y, x)
		g_code (y);
}


/*
 * Name:	g_code
 *
 * Abstract:	main tree walker - dispacher - for code generation
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

static
void	g_code (x)
ac	x;
{
	char datatext [AIDL];	/* for generating names		*/
	struct _context hulp;	/* for maintaining context stacks	*/
				/* just some scratch variables		*/
	int	endlab,
	    	first_hlab,
           	templab;
	ac	y;

	/* generate sdb linenumbers for missing lines		*/
	if (sdb_code && in_body) {
	   while (g_lineno (x) > curr_line) {
	      if (curr_line > 0)
	         OUT (("#%d	%d	\n", curr_line, curr_line));
	      curr_line ++;
	   }
	   curr_line = g_lineno (x);
	}

	/* dispatch the kind of item to be translated		*/
	switch (g_d (x)) {
	   case XINCOMPLETE:
	   case XRENSUB:
	   case XCHARLIT:
	   case XPRIVTYPE:
	   case XRENPACK:
	   case XUSE:
	   case XENUMLIT:
	   case XINHERIT:
	   case XNEWTYPE:
	      return;
		
	   case XPRIVPART:
	      /* translate a private part by translating the	*
	       * elements it contains
	       */
	      gen_code (g_fprivitem (x));
	      return;

	   case XPACKAGE:
	      /* translate a package in stages:			*
	       * allocate a local block descriptor,		*
	       * generate sdb and stack-save code,		*
	       * generate code for the "locals"			*
	       * and generate "end" code			*
	       */
	      if (tracelevel > BLOCKTRACE)
		 genproctrace ("Entry package", m_prog,
                                  x, g_lineno (x));

	      hulp. previous = __context;
	      hulp. blk      = x;
	      hulp. is_master = FALSE;
	      hulp. has_handler = FALSE;
	      __context = &hulp;

/*
 *	Generate code to save the stacktop and
 *	generate code for the local declarations
 */
	      sav_stack (x);
	      gen_code (g_fvisitem (x));

	      if (tracelevel >= BLOCKTRACE)
		 genproctrace ("Package exit", m_prog, x, g_lineno (x));

	      __context = __context -> previous;
	      return;

	   case XSUBBODY:
	      /* is we meet a subprogram here, code for its body is	*
	       * already translated. All that is to be done is to	*
	       * generate elaboration code			        *
	       */
	      elab_code (g_specif (x));
	      return;

	   case XTASKBODY:
	      /* if we meet a taskbody here, code for its body		*
	       * is already generated. Elaboration code is still to 	*
	       * be done though						*
	       */
	      task_elab_code (x);
	      return;

	   case XARRAYTYPE:
	      arr_desc (x);
	      return;

	   case XTASKTYPE:
	      task_desc (x);
	      return;

	   case XACCTYPE:
	      acc_desc (x);
	      return;

	   case XRECTYPE:
	      rec_desc (x);
	      return;

	   case XSUBTYPE:
	      sub_desc (x);
	      return;

	   case XENUMTYPE:
	      enum_desc (x);
	      return;

	   case XSUB:
	      /*
	       * Generate code for the specification		*
	       * If it's a C-specification, no code		*
	       * If it's a level-one specification, no code	*
	       */
	      if (is_dollarname (g_tag (x)) || is_as_C (x))
	         return;		/* C_entry */

	      if (is_lev_one (x))
		 return;		/* No elaboration */

	      setdatalab (x, datatext);

              new_expr ();
	      pre_code (x);
	      ASSIGN (ADDRESS);
		 code (x, VAL, ADDRESS);
		 ICON (0, ADDRESS, __ERROR);
	      return;

	   case XPACKBODY:
		/* If we meet a package body here, code
		 * for its elaboration is generated
		 */
	      pb_elabcode (x);
	      return;

	   case XRENOBJ:
	      if (g_ROBJ_alloc (x) != NOALLOC) {
		 list_name (x);
		 new_expr ();
		 ASSIGN (ADDRESS);
		    LOC_OBJECT (curr_level, g_ROBJ_offset (x), ADDRESS);
		    code (g_name (x), REF, ADDRESS);
	      }
	      break;

	   case XOBJECT:
	      if (g_OBJ_alloc (x) != NOALLOC) {
		 if (g_OBJ_alloc (x) != GLOBAL)
		    list_name (x);

	         if (expr_provides_constraints (g_objtype (g_desc (x)))) {
	            ASSERT (g_expr (g_desc (x)) != NULL, ("dddd"));
		    allocate (x);
	            gen_2init (x);
		    sav_stack (x);
		    return; /* do not have the stack reset before saving it */
		 }
		 else
		 {  allocate (x);
		    if (g_expr (g_desc (x)) != NULL)
		       gen_init (x);
		    else
		       if ((getflags (g_objtype (g_desc (x))) & F_RINIT) != 0)
		          gen_typeinit (x);
		}
	      }
	      else
	      if (g_object_spec (x) != NULL) {
	         printf ("Found: an object to be inited\\n");
	         gen_init (x);
	      }

	      break;

	   case XEXCEPTION:
	      return;

	   case XSTUB:
	      /* As with other procedures, stubs are only		*
	       * interesting with level /= 0				*
	       */
	      if (curr_level != 0)
		 elab_code (g_stub_spec (x));
	      return;

	   case XGENNODE:
	      return;		/* at least for now	*/

	   DEFAULT (("g_code: unknown type %d", g_d (x)));
	}

	if ((g_flags (x) & LARG_EVAL) == LARG_EVAL) {
	   xxx_stack (__context -> blk);
	}
}


/*
 *	generate elaboration code for sub's
 */
static
void	elab_code (y)
ac	y;
{
	ASSERT (y != NULL, ("elab_code:1"));

	if (g_d (y) == XSUB) {		/* e.g. TASK OR PACKAGE */

	   if (!is_lev_one (y)) {
/*
 *	Do not bother for global routines and functions
 */
	      new_expr ();
	      ASSIGN (ADDRESS);
	         code (y , VAL, ADDRESS);
	         TEXTLABCON (y);
	   }
	}
	else
	if (g_d (y) == XTASKTYPE) {

	   new_expr ();
	   ASSIGN (ADDRESS);
	      desc_address (y, TT_TSK_ADDR);
	      TEXTLABCON (y);
	}
/*
 *	else Package body, do not bother
 */
}

/*
 *	Generate elaboration code for tasks
 */
static
void	task_elab_code (y)
ac	y;
{
	ac	x;

	ASSERT (y != NULL, ("task_elab_code"));
	x = g_specif (y);
	ASSERT (x != NULL, ("task_elab_code:2"));

	new_expr ();
	ASSIGN (ADDRESS);
	   desc_address (x, TT_TSK_ADDR);
	   TEXTLABCON (x);
}

/*
 *	Name:	pb_elabcode
 *
 *	Abstract:	Generate elaboration code for
 *			package body x
 */
static
void	pb_elabcode (x)
ac	x;
{
	struct _context hulp;
	int	endlab,
		first_hlab,
		templab;

	static char datatext [AIDL];
	ac	y;

	if (g_specif (x) != NULL && is_generic (g_specif (x)))
	   return;

	if (tracelevel > BLOCKTRACE)
	   genproctrace ("Entry package body", m_prog,
	                 x, g_lineno (x));


	sdb_block (x);
/*
 *	Assume a new context, save old context in local structure
 */
	hulp. previous = __context;
	hulp. blk      = x;
	hulp. is_master = FALSE;
	hulp. has_handler = FALSE;
	
	__context = &hulp;

	/* if this compilation unit contains tasks,
	 * and it is the first master,
	 * then the initialisation code for the tasking must be
	 */
	if (g_must_do_task_init == TRUE) 
	    task_init (__context, x);

	/* If this contruction is a non-triv master,
	 * get an master-indication from DATS
	 */

	if (non_triv_master (x))
	   new_mas (x);
	sav_stack (x);

	/* Generate code for the locals		*/
	gen_code (g_fbodyloc (x));

	/* Exception handler initialization code			*/
	if (g_PB_exh (x) != NULL) {
	   first_hlab = new_lab ();
	   textlab (first_hlab, datatext);
	   PUSH_H (datatext);
	}

	/* Declarations are done, establish stack top loc		*/
	sav_stack (x);

	/* Generate code for the statements of the body		*/
	stats_code (g_PB_stats (x));
	/* and jump - if no handler - to endlab			*/

	endlab = new_lab ();
	if (g_PB_exh (x) != NULL) {
	   POP_H;		/* get rid of handler here		*/
	   genjump (endlab);

	   /*
	    * code for the handlers:
	    */
	   FORALL (y, g_EXH_items (g_PB_exh (x))) {
	      deflab (first_hlab);
	      cg_exception (y, first_hlab = new_lab ());
	      stats_code (g_WI_stats (y));
	      genjump (endlab);
	   }
	}
	/*
	 * This is the end of the package body
	 * generate an "end" label
	 */
	deflab (endlab);
	sdb_end ();

	if (tracelevel >= BLOCKTRACE)
	   genproctrace ("Exit packbody", m_prog, x, g_lineno (x));
	__context = __context -> previous;
}

/*
 * Name:	gen_body
 *
 * Abstract:	generate code for the body of a procedure
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
void	gen_body (x)
ac	x;
{
	struct _context hulp;
	char	datatext [AIDL];
	bool	old_inbody = in_body;
	int	frame_size,
		first_hlab,
		fnr	= new_lab ();
	ac	y,
	   	rettype;


	hulp. previous = __context;
	hulp. blk      = x;
	hulp. is_master = FALSE;
	hulp. has_handler = FALSE;
	__context = &hulp;

	ASSERT (g_specif (x) != NULL, ("gen_body:1"));
	ASSERT (g_d (g_specif (x)) == XSUB, ("gen_body:2"));

	rettype = g_rettype (g_specif (x));
	retlab		= new_lab ();
	frame_size = max (lev_off, lev_maxoff);

	setdatalab (g_specif (x), datatext);
	OUT (("&%d	%s\n", ICGLOBL, datatext));
	OUT (("&%d	%d	%d	%d	%s\n",	
				ICFBEG, fnr, retlab, FALSE, datatext));
	
	sdb_proc (x, datatext); in_body = TRUE;
	OUT (("[%d	%d	%d	%d	\n",
				fnr, frame_size * BPB, 7, 13));

	if (tracelevel >= PROCTRACE)
	      genproctrace ("Procedure entry ", m_prog,
	                     __context -> blk, g_lineno (x));

	/* If this contruction is a non-triv master,
	 * get an master-indication from DATS
	 */

	if (non_triv_master (x)) {
	      __context -> is_master = TRUE;
	      new_mas (x);
	      PUSH_H (__PROC_H);
	}

	sav_stack (x);
	gen_code (g_fbodyloc (x));

	if (g_must_do_task_init == TRUE) 
	   task_init (__context, x);

	if (non_triv_master (x)) {
	   ASSERT (MCoff (x) != 0, ("No MCHAIN offset\n"));
	   new_expr ();
	   CALL (VOID);
	      ICON (0, PF_INT, _ACTIVAT);
	      PARCOM ();
		 M_CHAIN (x, VAL);
		 ICON (0, LONG, "");
	}

	if (g_SBB_exh (x) != NULL) {
	      first_hlab = new_lab ();
	      textlab (first_hlab, datatext);
	      PUSH_H (datatext);
	      __context -> has_handler = TRUE;
	      sav_stack (x);
	}

	stats_code (g_SBB_stats (x));

	if (rettype != notype)
	   RAISE (EXC_PROGRAM);
	else
	if (g_SBB_exh (x) != NULL) {
	   POP_H;
	   __context -> has_handler = FALSE;
	}
	   genjump (retlab);

	if (g_SBB_exh (x) != NULL) {
	   FORALL (y, g_EXH_items (g_SBB_exh (x))) {
	      deflab (first_hlab);
	      cg_exception (y, first_hlab = new_lab ());
	      stats_code (g_WI_stats (y));
	      genjump (retlab);
	   }
	
	   deflab (first_hlab);
	   JUMP (__RERAISE);
	}

	deflab (retlab);
	if (__context -> is_master) {
	      new_expr ();
	      UCALL (VOID);
	         ICON (0, PF_INT, _LEAVE_M);
	      __context -> is_master = FALSE;
	      POP_H;
	}

	if (tracelevel >= PROCTRACE)
	   genproctrace ("Exit procedure ", m_prog, __context -> blk,
	                 g_lineno (x));

	if (rettype != notype) {
	   new_expr ();
	   FORCE (pcc_type_of (rettype));
	      LOC_OBJECT (curr_level,
	                  g_SBB_valoff (x), pcc_type_of (rettype));
	}

	retlab = new_lab ();
	OUT (("&%d	%d	\n", ICDLABN, retlab));
	OUT (("&%d	\n", ICFEND));
	
	if (is_composite (rettype)) {
	   new_expr ();
	   UCALL (VOID);
	      ICON (0, PF_INT, __HARDRET);
	}
	
	sdb_procend ();
	OUT (("]\n"));

	__context = __context -> previous;

	in_body = old_inbody;
}


/*
 * Name:	gen_task_body
 *
 * Abstract:	generate code for the body of a task
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

void	gen_tbody (x)
ac	x;
{
	bool	old_inbody	= in_body;
	int	fnr		= new_lab ();
	int 	first_hlab	= new_lab ();
	ac	y;
	struct _context hulp;
	char	datatext [AIDL];

	hulp. previous = __context;
	hulp. blk      = x;
	hulp. is_master = FALSE;
	hulp. has_handler = FALSE;
	__context = &hulp;
	retlab		= new_lab ();

	setdatalab (g_specif (x), datatext);

	OUT (("&%d	%s\n", ICGLOBL, datatext));
	OUT (("&%d	%d	%d	%d	%s\n",
			ICFBEG, fnr, retlab, FALSE, datatext));

	sdb_proc (x, datatext); in_body = TRUE;
	OUT (("[%d	%d	%d	%d	\n",
			fnr, max (lev_off, lev_maxoff) * 8, 7, 13));

	PUSH_H (_TASK_H);

	sav_stack (x);

	/* If this contruction is a non-triv master,
	 * get an master-indication from DATS
	 */

	if (non_triv_master (x)) {
	   __context -> is_master = TRUE;
	   new_mas (x);
	}

	gen_code (g_fbodyloc (x));

	if (g_must_do_task_init == TRUE) 
	   task_init (__context, x);


	/* if my declarative part has any active components,
	 * let's give them a kick
	 */
	if (non_triv_master (x)) {
	   ASSERT (MCoff (x) != 0, ("No MCHAIN offset\n"));
	   new_expr ();
	   CALL (VOID);
	      ICON (0, PF_INT, _ACTIVAT);
	      PARCOM ();
	         M_CHAIN (x, VAL);
		 ICON (1, LONG, "");
	}
	else
	{
	/* tell daddy we are active */
	new_expr ();
	CALL (VOID);
	   ICON (0, PF_INT, _ACTIVAT);
	   PARCOM ();
	      ICON (0, LONG, "");
	      ICON (1, LONG, "");
	}

	if (g_task_exh (x) != NULL) {
	   first_hlab = new_lab ();
	   textlab (first_hlab,datatext);
	   PUSH_H (datatext);
	   sav_stack (x);
	   __context -> has_handler = TRUE;
	}

	stats_code (g_task_stats (x));

	if (g_task_exh (x) != NULL) {	/* get rid of handler	*/
	   POP_H;
	   __context -> has_handler = FALSE;
	}
	deflab (retlab);
	if (non_triv_master (x)) {
	   new_expr ();
	   UCALL (VOID);
	      ICON (0, PF_INT, _LEAVE_M);
	      __context -> is_master = FALSE;
	}
	/* get rid of automatically inserted handler	*/
	POP_H;
        new_expr ();
	   UCALL (VOID);
	       ICON (0, PF_INT, _TERMINA);

	/* check if the task that just has gone to its grave stays there */
	new_expr ();
	   UCALL (VOID);
	      ICON (0, PF_INT, _ZOMBIE);
	 
	if (g_task_exh (x) != NULL) {
	   FORALL (y, g_EXH_items (g_task_exh (x))) {
	      deflab (first_hlab);
	      cg_exception (y, first_hlab = new_lab ());
	      stats_code (g_WI_stats (y));
	      genjump (retlab);
	   }
	
	   deflab (first_hlab);
	/* No reraise, the handler takes care		*/
	
	}
	OUT (("&%d	%d	\n", ICDLABN, new_lab ()));
	OUT (("&%d	\n", ICFEND));
	OUT (("]\n"));

	__context = __context -> previous;
	in_body = old_inbody;
}

/*
 * Name:	stats_code, stat_code
 *
 * Abstract:	
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

void	stats_code (x)
ac	x;
{
	ac	y;

	FORALL (y, x)
		stat_code (y);
}

/*
 *	Generate code for a single statement
 *	Most are straightforward
 *	Some of them are generated in separate functions
 *	Others are "in-line"
 */
static
void	stat_code (x)
ac	x;
{
	int	temp,
		t1,
		t2,
		t3;
	int type;
        ac  rettype, y, t, list, anchor;
	struct _context hulp;
	bool up;
	char datatext [AIDL];	/* name generation		*/

	if (sdb_code && in_body) {
	   while (g_lineno (x) > curr_line) {
	      if (curr_line > 0)
	         OUT (("&%d	%d	\n", ICLN, curr_line));
	      curr_line ++;
	   }
	   curr_line = g_lineno (x);
	}

	switch (g_d (x)) {
	   case XTASKSELECT:
	      gen_taskselect (x);
	      s_flags (x, g_flags (x) | LARG_EVAL);
	      goto end_stat;

	   case XDELAY:
	      gen_delay (x);
	      goto end_stat;

	   case XASSIGN:
	      gen_assign (x);
	      goto end_stat;

	   case XABORTSTAT:
	      gen_abort (x);
	      goto end_stat;

	   case XEXIT:
	      /*
	       * Code to exit a loop:
	       * evaluate the conditional expression (if any)
	       * pop the -compile-time- maintained environment
	       * to the right level of loop and jump
	       */
	      temp = new_lab ();
	      if (g_exitcond (x) != NULL)
	         gen_cond (g_exitcond (x), temp);

	      pop_env (g_loopid (x), __context);
	      xxx_stack (g_enclunit (g_loopid (x)));
	      genjump (g_d (g_loopid (x)) == XFORBLOCK ?
	      	    g_FB_lab (g_loopid (x)) :
	      	    g_LPB_lab (g_loopid (x)));

	      deflab  (temp);
	      return;

	   case XRETURN:
	      if (g_retexpr (x) != NULL) {
	          rettype = g_rettype (g_specif (g_enclsub (x)));
	          type = pcc_type_of (rettype);

	          new_expr ();
	          pre_code (g_retexpr (x));
	          mak_addressable (g_retexpr (x));
	          if (unco_value (rettype)) {
	             COMMA ();
	                ASSIGN (P_LONG);
	                   DEREF (P_LONG);
	                      DEREF (P_LONG);
	                         PAR_NAME (curr_level,
	                            g_SUBS_retoff (g_specif (g_enclsub (x))),
	                                            P_LONG);
	                DESCRIPTOR (g_retexpr (x));
	          }

	          ASSIGN (type);
	             LOC_OBJECT (curr_level,
	                            g_SBB_valoff (g_enclsub (x)), type);
	             if (is_small (g_retexpr (x)))
	                sm_ch_code (rettype, g_retexpr (x),
	      				pcc_type_of (rettype));
	             else
	                as_ch_code (rettype, g_retexpr (x),
	      				pcc_type_of (rettype));
	      }

	      pop_env (g_enclsub (x), __context);
	      genjump (retlab);
	      return;

	   case XSUBCALL:
	      gen_subcall (x);
	      goto end_stat;

	   case XRAISE:
	      new_expr ();
	      if (g_exception (x) == NULL) {
	         UCALL (VOID);
	            ICON (0, PF_INT, __RERAISE);
	      }
	      else
	      if (g_exc_task (x) == NULL) {
	         CALL (VOID);
	            ICON (0, PF_INT, __CRAISE);
	            code (g_exception (x), ADDRESS);
	      }
	      else
	      {  CALL (VOID);
	            ICON (0, PF_INT, __DRAISE);
	            PARCOM ();
	               code (g_exception (x), ADDRESS);
	               code (g_exc_task  (x), ADDRESS);
	      }
	      return;

	   case XIF:
	      temp = new_lab ();
	      FORALL (y, g_IF_items (x))
	      	ifitem_code (y, temp);

	      deflab (temp);
	      goto end_stat;

	   case XCASE:
	      t1	 = new_lab ();
	      t2         = new_lab ();
	      temp	 = new_lab ();

	      case_list (&list, &anchor);

	      new_expr ();
	      pre_code (t);
	      FORCE (LONG);
	         code (g_caseexpr (x), VAL, LONG);

	      genjump (temp);

	      FORALL (y, g_CASE_items (x)) {
	         t3 = new_lab ();
	         FORALL (t, g_fwhenchoice (y))
	            if (is_others (t))
                       t3 = t2;
	            else
	               insert (&list, &anchor,
                               new_cell (loval (t), hival (t), t3) );
	         deflab (t3);
	         stats_code (g_WI_stats (y));
	         genjump (t1);
	      }

	      deflab (temp);
	      t = g_caseexpr (x);
	      casecomp (loval (g_exptype (t)),
                          hival (g_exptype (t)),
                          &list, &anchor, t2);
	      deflab (t1);
	      rlist (anchor);
	      
	      goto end_stat;

	   case XFORBLOCK:
              t1 = new_lab ();
	      t2 = new_lab ();
	      hulp. previous = __context;

	      __context = &hulp;
	      __context -> blk = x;
	      __context -> has_handler = FALSE;
	      __context -> is_master   = FALSE;

	      if (tracelevel >= BLOCKTRACE)
	         genproctrace ("Entry in For-block", m_prog,
	                         x, g_lineno (x));

	      s_FB_lab (x, t2);
	      type = pcc_type_of (g_looppar (x));
	      gen_code (g_looppar (x));

	      y = g_looppar (x);

	      while (g_d (y) != XOBJECT)
	      	y = g_next (y);

	      up = is_forwards (x);

	      new_expr ();
	      ASSIGN (type);
	         code (y, VAL, type);
	         SCONV (type);
	            desc_address (g_objtype (g_desc (y)),
                                  (up ? LD_BIT_LO : LD_BIT_HI));

	      deflab (t1);	/* "while"label */

	      new_expr ();
	      CBRANCH ();
	          if (up)
	      	     le (type);
	          else
	      	     ge (type);
	          code (y, VAL, type);

	          SCONV (type);
	             desc_address (g_objtype (g_desc (y)),
                                   (up ? LD_BIT_HI : LD_BIT_LO));
	          ICON (t2, ADDRESS, "");

	      stats_code (g_FB_stats (x));

	      Xcrement (y, t1, up);

	      genjump (t1);
	      deflab (t2);

	      if (tracelevel >= BLOCKTRACE)
	         genproctrace ("Exit from FOR-block", m_prog,
	                          x, g_lineno (x));
	      __context = __context -> previous;
	      goto end_stat;

	   case XLOOPBLOCK:
	      if (tracelevel >= BLOCKTRACE)
	         genproctrace ("Entry in [While]-loop", m_prog,
	                        x, g_lineno (x));
	      t1 = new_lab ();
	      t2 = new_lab ();

	      hulp. previous = __context;
	      __context      = &hulp;
	      __context -> blk = x;
	      __context -> has_handler = FALSE;
	      __context -> is_master   = FALSE;

	      s_LPB_lab (x, t2);
	      deflab (t1);

	      if (g_cond (x) != NULL)
	         gen_cond (g_cond (x), t2);

	      stats_code (g_LPB_stats (x));
	      genjump (t1);
	      deflab (t2);

	      if (tracelevel >= BLOCKTRACE)
	         genproctrace ("Exit from [while]-loop", m_prog,
	                          x, g_lineno (x));

	      __context = __context -> previous;
	      goto end_stat;

	   case XBLOCK:
	      sdb_block (x);
	      t2 = new_lab ();		/* End of block-code	*/

	      hulp. previous = __context;
	      __context      = &hulp;

	      __context -> blk = x;
	      __context -> has_handler = FALSE;
	      __context -> is_master   = FALSE;

	      /*
	       * If the block is a non-trivial master, then add
	       * a compiler-generated handler.
	       */
	      if (non_triv_master (x)) {
	         PUSH_H (_BLOCK_H);
	         new_mas (x);
	         __context -> is_master = TRUE;
	      }

	      if (tracelevel >= BLOCKTRACE)
	         genproctrace ("Entry in block ", m_prog,
	                          x, g_lineno (x));
	      sav_stack (x);

	      gen_code (g_fblockloc (x));

	      if (non_triv_master (x)) {
	      	ASSERT (MCoff (x) != 0, ("No MCHAIN offset\n"));
	      	new_expr ();
	        CALL (VOID);
	           ICON (0, PF_INT, _ACTIVAT);
	           PARCOM ();
	              M_CHAIN (x, VAL);
	              ICON (0, LONG, "");
	      }

	      if (g_BLK_exh (x) != NULL) {
	         temp = new_lab ();
		 t1 = new_lab ();
	         textlab (temp, datatext);
	         PUSH_H (datatext);
	         sav_stack (x);

	         __context -> has_handler = TRUE;
	      }

	      stats_code (g_BLK_stats (x));
	      if (g_BLK_exh (x) != NULL) {
	         POP_H;
	         __context -> has_handler = FALSE;
	      }

	      genjump (t2);

	      if (g_BLK_exh (x) != NULL) {
	         FORALL (y, g_EXH_items (g_BLK_exh (x))) {
	            deflab (temp);
	            cg_exception (y, temp = new_lab ());
	            stats_code (g_WI_stats (y));
	            genjump (t1);
	         }

	         deflab (temp);
	      }
	      deflab (t2);
	      if (tracelevel >= BLOCKTRACE)
	         genproctrace ("Exit from block", m_prog,
	                          x, g_lineno (x));
	      if (__context -> is_master) {
	         new_expr ();
	         UCALL (VOID);
	            ICON (0, PF_INT, _LEAVE_M);
	         POP_H;
	      }

	      deflab (t1);
	      sdb_end ();
	      xxx_stack (__context -> blk);

	      __context = __context -> previous;
	      return;

	  default:
	      ASSERT (FALSE, ("Attempt to generate code for %d\n",
	      			g_d (x)));
	}

end_stat:
	if ((g_flags (x) & LARG_EVAL) == LARG_EVAL)
	      xxx_stack (__context -> blk);
}


/*
 * Name		if_item_code
 *
 * Abstract:	
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

static
void	ifitem_code (x, endlab)
ac	x;
int	endlab;
{
	int	t;

	ASSERT (g_d (x) == XIFITEM, ("ifitem_code"));

	if (g_ifcond (x) == NULL) {
	   stats_code (g_IF_stats (x));
	   genjump (endlab);
	}
	else
	{ gen_cond (g_ifcond (x), t = new_lab ());
	  stats_code (g_IF_stats (x));
	  genjump (endlab);
	  deflab (t);
	}
}

