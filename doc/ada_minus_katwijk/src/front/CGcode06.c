
/*
 * (c) copyright 1986, 1987, 1988, Delft University of Technology
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

#include	"includes.h"


/*
 * Name:	parcheck_code
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

void	parcheck_code (left, right, ctype)
ac	left,
	right;
int	ctype;
{
	if (no_paramcheck (left, right))
	   code (right, VAL, ctype);
	else
	{  CALL (ADDRESS);
	      ICON (0, PF_ADDR, __CHECK);
	      PARCOM ();
	         PARCOM ();
	            DESCRIPTOR (left);
	            DESCRIPTOR (right);
	         code (right, VAL, ctype);
	}
}

void	as_ch_code (left, right, ctype)
ac	left,
	right;
int	ctype;
{
	if (!as_chk (left, right))
	   code (right, VAL, ctype);
	else
	{  CALL (ADDRESS);
	      ICON (0, PF_ADDR, __CHECK);
	      PARCOM ();
	         PARCOM ();
	            DESCRIPTOR (left);
	            DESCRIPTOR (right);
	         code (right, VAL, ctype);
	}
}

/*
 * Name:	rang_expr
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

void	rang_expr (rang, d)
ac	rang;
int	d;
{
	ac	h;

	if (g_frang_exp (rang) == NULL) {
	   if (is_static (g_rangetype (rang)))
	        ICON (odd (d) ? loval (g_rangetype (rang)) :
				hival (g_rangetype (rang)), LONG, "" );
	   else
	      desc_address (g_rangetype (rang),
		 odd (d) ?
		    LD_BIT_LO :
		    LD_BIT_HI );
	}
	else
	{  h = odd (d) ?
		 g_frang_exp (rang) :
		 g_next (g_frang_exp (rang));

	   code (h, VAL, LONG);
	}
}

/*
 * Name:	sm_ch_code
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

void	sm_ch_code (target, source, ctype)
ac	target,
	source;
int	ctype;
{
	ac	td,
		sd,
		r;

	if (get_type (target) == get_type (source)) {
	   code (source, VAL, ctype);
	   return;
	}

	td = get_type (target);
	sd = get_type (source);

	if (comp_ranges (sd, td)) {
	   code (source, VAL, ctype);
	   return;
	}

	r = g_constraint (basefilter (td));

	if (is_static (source) && is_static (td))
	   if (is_inrange (getvalue (source), r)) {
	      code (source, VAL, ctype);
	      return;
	   }

	CALL (pcc_type_of (target));
	   ICON (0, PF_INT, __SCAL_CHECK);
	   PARCOM ();
	      DESCRIPTOR (target);
	      code (source, VAL, LONG);
}

/*
 * Name:	subscripts
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

void	subscripts (x)
ac	x;
{
	while (x != NULL) {
	   code (x, VAL, LONG);
	   x = g_next (x);
	}
}

/*
 * Name:	pop and push
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

void	pop (n)
int	n;
{
	ASS_PLUS (ADDRESS);
	   REG (SP_DYN, ADDRESS);
	   ICON (n, LONG, "");
}

short	push (b, type)
int	b,
	type;
{
	short	conv = FALSE;

	switch (type) {
	   case FLOAT:
	   case LONG:
		break;

	   case ADDRESS:
		break;

	   default:
		conv = TRUE;
		type = LONG;
	}

	if (b) {
	    ASSIGN (type);
	       DEREF (type);
		  ASS_MIN (pointer_type_of (type));
	}
	else
		ASS_MIN (ADDRESS);

		     REG (SP_DYN, ADDRESS);
		     ICON (pcc_size (type), LONG, "");
	if (b & conv)
		 SCONV (type);

	return pcc_size (type);
}


/*
 * Name:	get_nr_of_constr (fil)
 *
 * Abstract:	inspects the 'constraint subtree of 'fil'
 *		an determines the number of constraint values.
 *
 * Description:	dispatches on the kind of constraint, being
 *		- range_constraint
 *		- index_constraint
 *		- discriminant_constraint
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

int	get_nr_of_constr (fil)
ac	fil;
{
	int	count = 0;
	ac	cp;

	ASSERT (fil != NULL && g_d (fil) == XFILTER, ("get_nr:1"));
	switch (g_d (g_constraint (fil))) {
	   case XRANGE:
		count += 2;
		break;

	   case XINDEXCONS:
		ASSERT (g_d (root_type (g_filtype (fil))) == XARRAYTYPE, ("get_nr:2"));
		count = 2 * g_ARR_ndims (root_type (g_filtype (fil)));
		break;

	   case XDISCRCONS:
		FORALL (cp, g_aggregate (g_constraint (fil))) 
		   count ++;
		break;

	   DEFAULT (("get_nr_:3"));
	}

	return count;
}


/*
 * Name:	constraint_code
 *
 * Abstract:	generate code for all the constraint values of 
 *		a filter
 *
 * Description:	inspects the constraint subtree an generates code
 *		for all constraint values encountered.
 *
 * Externals:	
 *
 * Calls:	
 *
 * Macros:	
 *
 */

void	constraint_code (fil)
ac	fil;
{
	ac	ep;
	
	switch (g_d (g_constraint (fil))) {
	   case XRANGE:
	       ep = g_constraint (fil);
	       if (g_frang_exp (ep) == NULL) {
	          desc_address (g_rangetype (ep), LD_BIT_LO);
		  desc_address (g_rangetype (ep), LD_BIT_HI);
	       }
	       else
	       {  code (g_frang_exp (ep), VAL, LONG);
		  code (g_next (g_frang_exp (ep)), VAL, LONG);
	       }
	       break;

	   case XINDEXCONS:
	       FORALL (ep, g_frange (g_constraint (fil))) {
		  if (g_frang_exp (ep) == NULL) {
		     desc_address (g_rangetype (ep), LD_BIT_LO);
		     desc_address (g_rangetype (ep), LD_BIT_HI);
	          }
	          else
		  {  code (g_frang_exp (ep), VAL, LONG);
		     code (g_next (g_frang_exp (ep)), VAL, LONG);
		  }
	       }
	       break;

	   case XDISCRCONS:
	       FORALL (ep, g_aggregate (g_constraint (fil)))
		 code (g_compexpr (ep), VAL, LONG);	
	       break;

	   DEFAULT (("constraint_code:1"));
	}
}

