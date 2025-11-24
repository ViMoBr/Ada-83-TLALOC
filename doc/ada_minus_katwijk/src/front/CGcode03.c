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
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"
/*
 *	Forward (static) declarations
 */
/* (none)	*/

#define	low_expr(x)	rang_expr (x, 1)
#define	high_expr(x)	rang_expr (x, 2)


/*
 * Name:	tconv_code
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
void	tconv_code (node, val, ctype)
ac	node;
int	val,
	ctype;
{
	if (is_small (g_newtype (node))) { 
	/* always convert to ctype, macroscopic types are correct	*/
           if (ctype != pcc_type_of (g_convexpr (node))) {
/*	      SCONV (ctype);
 */
	      fprintf (outfile, "(%s)", name_of_ctype (ctype));
	      ctype = pcc_type_of (g_convexpr (node));
	   }
           code (g_convexpr (node), val, ctype);
	}
	else
	    /* not yet implemented, ignore conversion */
	    code (g_convexpr (node), val, ctype);
}

/*
 * Name:	lit_code
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
void	lit_code (node,val, ctype)
ac	node;
int	val,
	ctype;
{
	if (is_stringlit (node)) {
	/* if the string needs a LOCAL descriptor, it is not yet
	 * present, so generate it now ...
	 */

	   if (g_ARR_alloc (root_type (g_littype (node))) != GLOBAL) {
	      COMMA ();
		 ASSIGN (LONG);
		    LOC_OBJECT (curr_level, g_LIT_Doff (node), LONG);
		    ICON (VD_ARR, LONG, "");
		 COMMA ();
		    ASSIGN (P_LONG);
		       LOC_OBJECT (curr_level, g_LIT_Doff (node) + LD_ARR_TTP, P_LONG);
		       desc_const (root_type (g_littype (node)));
		    COMMA ();
		       ASSIGN (LONG);
		          LOC_OBJECT (curr_level, g_LIT_Doff (node) + VD_SIZE, LONG);
		          ICON (align (g_val (node) -> n, MAX_ALIGN), LONG, "");
		       COMMA ();
			  ASSIGN (LONG);
		   	     LOC_OBJECT (curr_level, g_LIT_Doff (node) + LD_ARR_ESIZE, LONG);
		   	     ICON (1, LONG, "");
			  COMMA ();
			     ASSIGN (LONG);
		   	        LOC_OBJECT (curr_level,
				       g_LIT_Doff (node) + LD_ARR_I_X, LONG);
		   	        ICON (1, LONG, "");
			     COMMA ();
			        ASSIGN (LONG);
		   	           LOC_OBJECT (curr_level,
                                               g_LIT_Doff (node) + (LD_ARR_I_X + LO_LD_ARR_SIZE), LONG);
		   	           ICON (g_val (node) -> n, LONG, "");
		}

		LICON (g_LIT_Voff (node));
		return;
	}

	if (is_nulllit (node)) {
	   ICON (NULL_TOKEN,
                 pointer_type_of (pcc_type_of (g_littype (node))),"");
	   return;
	}
	if (is_reallit (node)) {
	   LNAME (pcc_type_of (node), g_LIT_Voff (node));
	   return;
	}
	switch (ctype) {
	   case LONG:
		ICON (ord (node), LONG, "");
		break;

	   case INT:
		ICON (ord (node), INT, "");
		break;

	   case BYTE:
		ICON (ord (node), BYTE, "");
		break;

	   default:
		ICON (ord (node), LONG, "");
		break;
	}
}

/*
 * Name:	exp_code
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
void	exp_code (node, val, ctype)
ac	node;
int	val,
	ctype;
{
	if (is_qualif (node) &&
            (!is_basetype (g_exptype (node)))) {
	   if (is_scalar (g_exptype (node))) {
	      CALL (pcc_type_of (node));
		 ICON (0, PF_INT, __SCAL_CHECK);
		    PARCOM ();
		       DESCRIPTOR (node);
		       code (g_primary (node), VAL,LONG);
	   }
	   else
	   {  CALL (ADDRESS);
		 ICON (0, ADDRESS, _LARGQUAL);
		 PARCOM ();
		    PARCOM ();
		       DESCRIPTOR (node);
		       code (g_primary (node), VAL,LONG);
		    DESCRIPTOR (g_primary (node));
	   }
	}
	else
	   code (g_primary (node), VAL, ctype);
}

/*
 * Name:	in_code
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
void	in_code (node, val, ctype)
ac	node;
int	val,
	ctype;
{
	ac	t;

	if (!is_in (node))
	   NOT (INT);

	if (is_basetype (g_intype (node))) {
	   COMMA ();
	      code (g_inexpr (node), VAL, ctype);
	      ICON (TRUE, INT, "");
	}
	else
	   if (is_filter ( ((ac)g_intype (node)))) {
	      if (is_scalar (root_type (g_intype (node)))) {
	         t = g_constraint (g_intype (node));
	         if (g_frang_exp (t) == NULL) {
		    CALL (INT);
		       ICON (0, PF_INT, __INSCALAR);
		       PARCOM ();
			  DESCRIPTOR (g_rangetype (t));
		          code (g_inexpr (node), VAL,ctype);
	         }
		 else
	         {
	            ANDAND (INT);
	               LE (INT);
		          code (g_frang_exp (t), VAL, ctype);
			  code (g_inexpr (node), VAL, ctype);
		       LE (INT);
		          code (g_inexpr (node), VAL,ctype);
			  code (g_next (g_frang_exp (t)) == NULL ?
				g_frang_exp (t) :
				g_next (g_frang_exp (t)), VAL, ctype);
	         }
	      }
	      else
	      {   printf ("in with filter not yet implemented\n");
	       ICON (TRUE, INT, "");
	      }
	   }
	   else
	      if (basefilter (g_intype (node))
				== basefilter (g_inexpr (node))) {
		 COMMA ();
		    FORCE (pcc_type_of (g_inexpr (node)));
	               code (g_inexpr (node), VAL,ctype);
		    ICON (TRUE, INT, "");
	      }
	      else
		 if (is_small (g_intype (node))) {
		    CALL (INT);
		       ICON (0, PF_INT, __INSCALAR);
		       PARCOM ();
		          DESCRIPTOR (g_intype (node));
			  code (g_inexpr (node), VAL,ctype);
		 }
		 else
		 {  CALL (INT);
		       ICON (0, PF_INT, __INCOMP);
		       PARCOM ();
		          PARCOM ();
		             DESCRIPTOR (g_intype (node));
			     code (g_inexpr (node), VAL,ctype);
		          DESCRIPTOR (node);
		 }
}

/*
 * Name:	obj_code
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
void	obj_code (node, val, ctype)
ac	node;
int	val,
	ctype;
{
	int	type;

	if (node == NULL)
	   return;

	type = pcc_type_of (node);

	if (ctype != type) {
	   SCONV (ctype);
	   ctype = type;
	}

	if (is_small (node)) {
	   if (stor_class (node) == GLOBAL) {
	   /*
	    * Special case: PCC does not accept
	    * DEREF GLOB_NAME
	    */
	      if (val == VAL)
		 GLOB_OBJECT (0, node, type);
	      else
		 GLOB_NAME   (0, node);
	      return;
	   }
	   if (stor_class (node ) == DISCALLOC && type != LONG) {
	   /* get an integer or byte out of a long ! */
	      SCONV (type);
	      DEREF (LONG);
	   }
	   else
	      pcc_deref (node, val);

	}

	switch (stor_class (node)) {
	   case NOALLOC:
		sys_error ("code: no_alloc");

	   case DISCALLOC:
		/* if we are generating code for an initialising
		 * expression and the object is an discriminant
	 	 * then the value of the discr is found by 
		 * & vd_rec + obj_offset
		 * vd_rec is the third parameter of the art. subroutine
		 *
		 * A global structure  keeps trace of the
		 * context inwhich we are generating this code. 
		 * This context is either INIT_SUB, or NORMAL
		 */
		if (g_code_context  == INIT_SUB) {
		   PLUS (P_LONG);
		      PAR_OBJECT (level_of (node) + 1, PAR_3, P_LONG);
		      ICON (off (node), LONG, "");
		}
		else
		   sys_error ("access to discr outside init");

		break;

	   case GLOBUNCONS:
		/* never a small value */
	        GLOB_OBJECT (TADDRSIZE, node, ADDRESS);
		break;

	   case FIXUNCONS:
		LOC_OBJECT (level_of (node),
/* beware of the - */
				off (node) - TADDRSIZE, type);
		break;

	   case GLOBAL:
		GLOB_NAME (0, node);
		break;

	   case PARSTACK:
		if (!is_small (node))
		   DEREF (type);
		PAR_NAME (level_of (node) + 1, off (node),
                           pointer_type_of (type));
		break;

	   case ENTRYSTACK:
		if (!is_small (node))
		   DEREF (type);
		ENTRY_PAR (node, pointer_type_of (type));
		break;

	   case FIXSTACK:
		LOC_NAME (level_of (node), off (node), pointer_type_of (type));
		break;

	   case FIXDYN:
		LOC_OBJECT (level_of (node), off (node), type);
		break;

	   case GLOBDYN:
		GLOB_OBJECT (0, node, ADDRESS);
		break;

	   DEFAULT (("obj_code: offset"));
	}
}

/*
 * Name:	allo_code
 *
 * Abstract:	
 *
 * Description:	
 * 		let a runtime routine take care of the actions,
 * 		the result of the call is the address of the
 * 		heap value. Notice that there is a difference 
 *		between the simple
 * 		PASCAL case where the pointer returned
 *		is the value address
 * 		and the more complex case where the pointer
 *		is a doublet address.
 * Tasks as accessed object:
 *		We must activate tasks as accessed object inmediately,
 *		independent of the environment. We initiate a new
 *		masterchain (see rt_decl.c) , which is passed for activation
 *		after the creation of the task descriptor. The runtime
 *		routine needs only information who is master.
 *		A slight complication is the initialization with
 *		an aggregate.
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */
static
void	allo_1_code (node)
ac	node;
{
	ac	actype	= g_actype (root_type (g_altype (node)));
	bool	has_t	=
		has_tasks (getflags (root_type (get_type (g_obtype (node)))));

	if (g_d (g_obtype (node)) == XEXP) {	/* initializing	*/
	   CALL (ADDRESS);
	      ICON (0, ADDRESS, _ALLOC_1A);
	      PARCOM ();
	         PARCOM ();
	            if (has_t)
	               MASTER (g_enclunit (g_altype (node)), REF);
	            else
	               ICON (0, LONG, "");
		       DESCRIPTOR (g_obtype (node));
		       code (g_obtype (node), VAL, ADDRESS);
	}
	else
	{  CALL (ADDRESS);
	      ICON (0, ADDRESS, _ALLOC_1);
	      PARCOM ();
	         if (has_t)
	            MASTER (g_enclunit (g_altype (node)), REF);
	         else
	            ICON (0, LONG, "");

	            DESCRIPTOR (g_obtype (node));
	}
}

static
void	allo_2_code (node, has_t)
ac	node;
bool	has_t;
{
	ASSERT (is_basetype (g_obtype (node)), ("allo_2_code:1"));

	if (is_unco (g_obtype (node))) {
	 sys_error ("Allocators for unconstrained objects not supported");
	}

	CALL (ADDRESS);
	   ICON (0, ADDRESS, _ALLOC_2);
	   PARCOM ();
	      PARCOM ();
	         if (has_t)
	            MASTER (g_enclunit (g_altype (node)), REF);
	         else
	            ICON (0, LONG, "");
	         DESCRIPTOR (g_obtype (node));
	      ICON (getvdsize (g_obtype (node)), LONG, "");
}

static
void	allo_3_code (node, has_t)
ac	node;
bool	has_t;
{
	ac	fil;
	int	constr_cnt;
	int	i;

	fil = g_obtype (node);
	constr_cnt = get_nr_of_constr (fil);

	CALL (ADDRESS);
	   ICON (0, ADDRESS, _ALLOC_3);
	   PARCOM ();
	      PARCOM ();
	         PARCOM ();
	            PARCOM ();
		    /* if there are n constraint values
		     * then generate n-1 PARCOM'S
		     */
		       for (i = 1; i < constr_cnt; ++i)
			  PARCOM ();

		       if (has_t)
			  MASTER (g_enclunit (g_altype (node)), REF);
		       else
			  ICON (0, LONG, "");
		       DESCRIPTOR (g_filtype (fil));
		       ICON (getvdsize (fil), LONG, "");
		    ICON (constr_cnt, LONG, "");
		    /* generate code for all the constraints
		     */
		 constraint_code (fil);
}

static
void	allo_4_code (node, has_t)
ac	node;
bool	has_t;
{
	if (has_t)
	   printf (" Watch out: Don't understand how to to make a task init");

	CALL (ADDRESS);
	   ICON (0, ADDRESS, _ALLOC_4);
	   PARCOM ();
	      PARCOM ();
	         PARCOM ();
	         if (has_t)
	            MASTER (g_enclunit (root_type (g_altype (node))), REF);
	         else
	            ICON (0, LONG, "");
	            code (g_obtype (node), VAL, ADDRESS);
	         DESCRIPTOR (g_obtype (node));
	      ICON (getvdsize (get_type (g_obtype (node))), LONG, "");
}

void	allo_code (node, val, ctype)
ac	node;
int	val,
	ctype;
{
	ac	tt,
		actype;
	bool	has_t	= FALSE;

	ASSERT (node != NULL && g_d (node) == XALLOCATOR, ("allo_code:1"));
	ASSERT (g_altype (node) != NULL, ("allo_code:2"));

	actype = root_type (g_altype (node));
	ASSERT (g_d (actype) == XACCTYPE, ("alloc_code:3"));

	actype = g_actype (actype);
	if (g_d (g_obtype (node)) == XEXP)
	   tt = get_type (g_obtype (node));
	else
	   tt = g_obtype (node);
	has_t = has_tasks (getflags (root_type (tt)));

	if (alloc_1_value (actype))
	   /* as in PASCAL, keep it simple */
	   allo_1_code (node);
	else
	if (is_typemark (g_obtype (node)))
	   allo_2_code (node, has_t);
	else
	if (g_d (g_obtype (node)) == XFILTER)
	   allo_3_code (node, has_t);
	else
	if (g_d (g_obtype (node)) == XEXP) /* an init	*/
	   allo_4_code (node, has_t);
	else
	   ASSERT (FALSE, ("allo_code:4"));
}

void	scc_code (node, val, ctype)
ac	node;
int	val,
	ctype;
{
	/*
	 * if the type of the first scc expression is small,
	 * we generate an inline scc construct,
	 * else a runtime routine does the work.
	 */
	 if (is_small (g_fsccexpr (node))) {
	    if (g_andthen (node))
	       ANDAND (ctype);
	    else
	       OROR (ctype);
		
	    code (g_fsccexpr (node), val, ctype);
	    code (g_next (g_fsccexpr (node)), val, ctype);
	 }
	 else
	 {  CALL (UCHAR);
	      ICON (0, PF_UCHAR, __SCCCOMP);
	      PARCOM ();
	         PARCOM ();
		    PARCOM ();
		       PARCOM ();
			  code (g_fsccexpr (node), val, ctype);
			  code (g_next (g_fsccexpr (node)), val, ctype);
		       DESCRIPTOR (g_fsccexpr (node));
		    DESCRIPTOR (g_next (g_fsccexpr (node)));
		 if (g_andthen (node))
		     ICON (SCC_AND, LONG, "");
		  else
		     ICON (SCC_OR, LONG, "");
	 }
}

