
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
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 * File:	CGcode01.c
 * 
 * Description:	CGcode01 contains the drivers for expression
 *		codegeneration called by "stat" and "local" 
 *
 *		These drivers typically start a new expression.
 *
 *
 */
/* Data definitions */

#include	"includes.h"

/*
 *	Forward (static) declarations:
 */
static	void	 assign_code ();		/* do a assign */


void	gen_assign (node)
ac	node;
{
	ASSERT (node != NULL, ("assign:1"));
	ASSERT (g_d (node) == XASSIGN, ("assign:2"));

	new_expr ();
	   assign_code (g_lhs (node), g_rhs (node));
}

void	gen_cond (ex, f)
ac	ex;
int	f;
{
	new_expr ();
	pre_code (ex);
/*
	CBRANCH ();
	   code (ex, VAL, NOTYPE);
	   ICON (f, LONG, "");
*/
	fprintf (outfile, "\n;	if (");
	code    (ex, VAL, NOTYPE);
	fprintf (outfile, ") goto L%d;\n", f);
}

/*
 * Name:	gen_init
 *
 * Abstract:	perform a initiating assign
 *
 * Description:	an object is initialised upon declaration
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
void	gen_init (node)
ac	node;
{
	ac	t;

	ASSERT (node != NULL, ("gen_init:1"));
	ASSERT (g_d (node) == XOBJECT, ("gen_init:2"));

	if (g_object_spec (node) != NULL)
	   t = g_object_spec (node);
	else
	   t = node;

	new_expr ();
	   assign_code (t, g_expr (g_desc (node)));
}

void	gen_2init (node)
ac	node;
{
	ac	left,
		right;

	ASSERT (node != NULL, ("gen_2init:1"));
	ASSERT (g_d (node) == XOBJECT, ("gen_2init:2"));

	left = node;
	right = g_expr (g_desc (node));
	
	new_expr ();
	if (unco_agg (right))
	   s_context (g_primary (right), left);

	pre_code (left);
	pre_code (right);

	ASSIGN (pcc_type_of (right));
	   code (left, REF, pcc_type_of (right));
	   code (right, REF, pcc_type_of (right));

	new_expr ();
	ASSIGN (ADDRESS);
	   DESCRIPTOR (left);
	   DESCRIPTOR (right);
}

/*
 * Name:	pop_env
 * Abstract:	generate code to undo handlers and so on
 *		up to the level of a given construct
 *
 * Description:	is called from "stat_code"
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
void	pop_env (x, y)
ac	x;
struct _context *y;
{
	for (; y != NULL && y -> blk != x; y = y -> previous) {
	   if (y -> has_handler) {
              fprintf (outfile, "\n; %s ()\n", __HRESTORE);
	   }

	   if (y -> is_master) {
              fprintf (outfile, "\n; %s ()\n", _LEAVE_M);
              fprintf (outfile, "\n; %s ()\n", __HRESTORE);
	   }

	   if (x == y -> blk)
	      break;
	}
}

/*
 * Name:	gen_subcall
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
void	gen_subcall (node)
ac	node;
{
	ac	call;

	if (node == NULL)
	   return;

	ASSERT (g_d (node) == XSUBCALL, ("gen_subcall"));
	call = g_subpr (node);

	ASSERT (g_d (call) == XCALL || g_d (call) == XENTRYCALL,
					        ("gen_subcall:2"));

	new_expr ();
	pre_code (call);
	nelemcode (call, VAL, NOTYPE);
}

/*
 * Name:	gen_typeinit
 *
 * Abstract:	initialise an object with the expr given in a type definition
 *
 * Description:	by means of a runtime support routine
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
void	gen_typeinit (obj)
ac	obj;
{
	ASSERT (obj != NULL, ("gen_typeinit:1"));
	ASSERT (g_desc (obj) != NULL, ("gen_typeinit:2"));
	ASSERT (g_objtype (g_desc (obj)) != NULL, ("gen_typeinit:3"));

	/*
	 * If the object has some implicit (or explicit)
	 * access type objects, r_init will start them
	 */
	if (has_tasks (getflags (g_objtype (g_desc (obj))))) {
	   new_expr ();
	      pre_code (obj);
	      CALL (VOID);
	         ICON (0, ADDRESS, _R_INIT);
	         PARCOM ();
	            PARCOM ();
	               PARCOM ();
	                  code (obj, REF, pcc_type_of (obj));
	                  DESCRIPTOR (obj);
		    MASTER (g_enclunit (obj), REF);
		 M_CHAIN (g_enclunit (obj), REF);
	}
	else
	{  new_expr ();
	   pre_code (obj);
	   CALL (VOID);
	      ICON (0, ADDRESS, _R_INIT);
	      PARCOM ();
	         PARCOM ();
	            PARCOM ();
	               code (obj, REF, pcc_type_of (obj));
	               DESCRIPTOR (obj);
                       
	            ICON (0, LONG, "");
	         ICON (0, LONG, "");
	}
}


/*
 * Name:	assign_code
 *
 * Abstract:	perform an assign
 *
 * Description:	lhs := rhs
 * check whether the right side is an others aggregate
 * for a unconstraint type,
 * if so change the aggtype to the type of the left side
 * to create a context for the aggregate 
 * Recognise a number of different cases
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
static
void	assign_code (left, right)
ac	left,
	right;
{
	int	n;

	if (unco_agg (right))
	   s_context (g_primary (right), left);

	pre_code (left);
	pre_code (right);

	if (is_small (right)) {
/*	   ASSIGN (pcc_type_of (right));
	      code (left, VAL, pcc_type_of (right));
	      sm_ch_code (left, right, pcc_type_of (right));
 */
	   fprintf (outfile, "\n;	");
	   code (left, VAL, pcc_type_of (right));
	   fprintf (outfile, " = ");
	   sm_ch_code (left, right, pcc_type_of (right));
	   return;
	}

	/*
	 * Assignment of unconstrained record object
	 */
	if (g_d (left) == XNAME && is_unco (g_fentity (left))) {
	   /* keep it simple, let someone else do the work */
	   ASSIGN (ADDRESS);
	      code (left, VAL, ADDRESS);
	      CALL (ADDRESS);
	         ICON (0, ADDRESS, _UNCO_AS);
	         PARCOM ();
	            PARCOM ();
		       PARCOM ();
		          DESCRIPTOR (left);
		          DESCRIPTOR (right);
		       code (left, VAL, ADDRESS);	/* only for disposing */
		    code (right, VAL, ADDRESS);

	    return;
	}

	/*
	 *	Try to map simple assignments into
	 *	STASS-like structures
	 */
	if ((get_type (left) == get_type (right)) &&
	    hasstatsize (get_type (left)) ) {
	      n = obj_size (get_type (left));
	      if ((n % 2 == 0) && n < 200) { /* arbitrary */
		  n = n * 8;	/* size in bits */
		  COMMA ();		 /* for non void stasssigns  --| */
		     STASSIGN (UCHAR, n);				    /* | */
								    /* | */
		     /* especially for the STASS operator, */          /* | */
	             /* an extra deref */				    /* | */
		  	DEREF (ADDRESS);          		    /* | */
		     	   code (left, VAL, ADDRESS);		    /* | */
		      code (right, VAL, ADDRESS);		    /* | */
		      ICON (0, INT, "");	/* only for ACE backend  <-----| */
	          return;
	      }
	  }
/*
 *	Otherwise, generate code for
 *	checking the constraints and assigning the value
 */
	CALL (VOID);
	  ICON (0, PF_INT, __ASSIGN);
	  PARCOM ();
	     PARCOM ();
	        DESCRIPTOR (left);
	        as_ch_code (left, right, NOTYPE);
	     code (left, VAL, ADDRESS);
}


/*
 * Name:	gen_taskselect
 *
 * Abstract:	generates code for a complete task select construction
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

void	gen_taskselect (ts)
ac	ts;
{
	int	switchlab	= new_lab ();
	int	endlab		= new_lab ();
	int	defaultlab;		/* dit is zeker fout	*/
	int	elem_lab	= new_lab ();
	int	start_lab	= elem_lab;
	int	i,
		j,
		attr,
		sel;

	ac	stat,
		x;

	struct _accepts hulp;

	/* remember the current task_select node,
	 * this information is used when accessing entry call
	 * parameters via ENTRY_PAR in CGgpcc00.c
	 */
	curr_ts = ts;

	/* General Description 
	 * -------------------
	 *
	 * First code for the call to start_rdv,
	 * followed by code for the switch statement implementing
	 * the bodies of the alternatives.
	 */

	new_expr ();
/*
	FORCE (LONG);
	    CALL (VOID);
 */
	CALL (LONG);
	   ICON (0, PF_INT, _START_R);
	   PARCOM (); /* number of alternatives in the selective
		       * wait structure
		       */
	      PARCOM (); /* out parameter resulting in the address
			  * of the caller
			  */
		 PARCOM (); /* out param resulting in the address
			     * of the actuals of the call
			     */
		 for (i = 1; i <= 2 * g_SEL_count (ts) - 1; i ++)
		    PARCOM (); /* For each alternative we need 2 params,
			       * a tuple consisting of a alternative description
			       * and a data element.
			       * there is still one parameter-entry free,
			       * so we need
			       * 2 * (#number of alt's) - 1 PARCOMS.
			       */
	               ICON (g_SEL_count (ts), LONG, "");

	               if (level_of (ts) == 0)
		          GLOB_NAME (0, g_SEL_caller (ts));
	               else
		          LOC_NAME (curr_level, g_SEL_caller (ts), ADDRESS);

		       if (level_of (ts) == 0)
		          GLOB_NAME (0, g_SEL_actuals (ts));
		       else
		          LOC_NAME (curr_level, g_SEL_actuals (ts), ADDRESS);

		
		       FORALL (x, g_SELECT_items (ts)) {
		         stat = g_WI_stats (x);
		      /* find out what kind of alternative it is */

		         switch (g_d (stat)) {
			     case XACCEPT:
				sel = ACCEPT_ALT;
				attr = g_entry_nr (g_specif (stat));
				break;

			     case XDELAY:
				sel = DELAY_ALT;
				break;

			     case XTERMINATE:
				sel = TERM_ALT;
				attr = INFINITE;
				break;

			    DEFAULT (("task_sel:1"));
		         }

		   /* First element of tuple : the kind of the alternative */

			  if (g_fwhenchoice (x)) {
				QUEST (LONG);
				   code (g_fwhenchoice (x), VAL, LONG);
				COLON (LONG);
				   ICON (sel, LONG, "");
				   ICON (CLOSED_ALT, LONG, "");
			   } 
			   else 
				ICON (sel, LONG, "");


		    /* Second element of tuple : data,
		     * 		if ACCEPT_ALT : entry number,
		     *		if DELAY_ALT  : time to delay,
		     *		if TERM_ALT   : INFINITE
		     */
			    if (g_d (stat) == XDELAY) {
/*
			       printf ("delay expr %x\n", g_delay_expr (stat));
 */
			       code (g_delay_expr (stat), VAL, LONG);
			    }
			    else
			    {  ICON (attr, LONG, "");
/*
			       printf ("attr element %d\n", attr);
 */
			    }


		} /* end of FORALL */

	/* and now the body of the selective wait :
	 * a switch statement where each case element implements
	 * a body of an alternative
	 */

	genjump (switchlab);

	FORALL (x, g_SELECT_items (ts)) {
	   stat = g_WI_stats (x);
	   deflab (elem_lab);

	   switch (g_d (stat)) {
	      case XTERMINATE:
		 break;

	      case XDELAY:
	         stats_code (g_next (stat));
		 break;

	      case XACCEPT:
		   hulp. prev_accept = ast;
		   ast          = &hulp;
		   hulp. current_taskselect = ts;
		   hulp. served_entry = stat;
		   if (g_accept_stats (stat) != NULL) {
		      PUSH_H (_ACCEPT_H);
		      sav_stack (stat);
		      stats_code (g_accept_stats (stat));
		      POP_H;
		      sav_stack (stat);
		   }
		   new_expr ();
		   CALL (VOID);
		      ICON (0, PF_INT, _END_RDV);
		      ICON (0, LONG, "");

		   ast = hulp. prev_accept;
		   stats_code (g_next (stat));
		   break;

	      DEFAULT (("Wat maak je me nu"));
	   }
		
	   genjump (endlab);
	   elem_lab = new_lab ();
	}
	/* default case : */
	defaultlab = elem_lab;
		deflab (defaultlab);
/*
		runerror ("Entered defaultcase in selective wain\n");
 */
	genjump (endlab);
	/* jumptable implementing the switch */
	deflab (switchlab);

	OUT (("&%d	%d	\n", ICSWTCH, g_SEL_count (ts)));
	for (i=1; i <= g_SEL_count (ts); i ++)
	     OUT (("&%d	%d	%d	\n", ICSWENT, start_lab ++, i));

	OUT (("&%d	\n", ICSWEND));
	deflab (endlab);
}

void	gen_abort (x)
ac	x;
{
	ac	y;

	ASSERT (x != NULL && g_d (x) == XABORTSTAT, ("gen_abort:1"));

	y = g_abortedtask (x);

	ASSERT (y != NULL, ("gen_abort:2"));

	new_expr ();
	pre_code (y);
	CALL (VOID);
	   ICON (0, PF_INT, __GENABORT);
	   code (y, VAL, ADDRESS);
}

/*
 *	gen_delay
 */
void	gen_delay (x)
ac	x;
{
	new_expr ();
	pre_code (g_delay_expr (x));
        printf ("\n; %s", _DELAY);
        printf ("(");
	   code (g_delay_expr (x), VAL);
	printf (")");
}

