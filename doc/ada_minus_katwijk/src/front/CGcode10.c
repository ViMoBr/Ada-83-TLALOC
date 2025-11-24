
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
static	void	cg_ex2		();

/*
 *	v_ranges
 *
 *	generate code for checking a discriminant
 *	against a set of ranges
 *	x: range to be checked against
 *	y: function to generate the access to the value to be checked
 *	z: parameter for y
 */
void	v_ranges (x, y, z)
ac	x;
int	(*y)(),
	z;
{
	int	hv,
		lv;

	if (x == NULL)
	   return;

	if (g_next (x) != NULL) {
	   OROR (INT);
	      v_ranges (g_next (x), y, z);
	}

	lv = loval (x);
	hv = hival (x);

	if (lv == hv) {
	   EQ (INT);
	      (*y)(z);
	      ICON (lv, INT, "");
	}
	else {
	      ANDAND (INT);
	         LE (INT);
	            ICON (lv, INT, "");
	            (*y)(z);
	         LE (INT);
	            (*y)(z);
	            ICON (hv, INT, "");
	}
}

/*
 *	Generate dispatching code for exception handler
 */
static
void	cg_ex2 (x)
ac	x;
{
	if (x == NULL)
	   return;

	if (g_next (x) != NULL) {
	   OROR (INT);
	     cg_ex2 (g_next (x));
	}

	EQ (INT);
	   code (g_primary (g_frang_exp (x)), REF, NOTYPE);
	   DEREF (INT);
	      PLUS (ADDRESS);
	         NAME (0, MYSELF);
	         ICON (_EXC, INT, "");
}

void	cg_exception (node, label)
ac	node;
int	label;
{
	ASSERT (node != NULL && g_d (node) == XWHENITEM, ("cg_exc:11"));

	if (g_frang_exp (g_fwhenchoice (node)) == NULL)
	   return;

	new_expr ();
	CBRANCH ();
	  cg_ex2 (g_fwhenchoice (node));
	  ICON (label, INT, "");
}

/*
 *	Get the low- and the high path from a component
 */
int	low_path (x)
ac	x;
{
	return (int)g_VAR_fpath (g_enclunit (x));
}

int	high_path (x)
ac	x;
{
	x = g_enclunit (x);
	while (g_d (x) != XRECTYPE) {
	   if (g_next (x) != NULL)
	      return (int)g_VAR_fpath (g_next (x)) - 1;
	   x = g_enclunit (x);
	}

	return (int)g_REC_npaths (x);
}

/*
 *	given an expression, check to see
 *	whether or not it consists solely
 *	of a discriminant.
 */
bool	is_act_discr (x)
ac	x;
{
	ac	y;

	if (x == NULL)
	   return FALSE;

	ASSERT (g_d (x) == XEXP, ("is_act_discr"));

	y = g_primary (x);

	if (g_d (y) != XNAME)
	   return FALSE;

	y = g_fentity (y);
	if (g_d (y) != XOBJECT)
	   return FALSE;

	return is_discr (y);
}

/*
 *	is_discdep:
 *	Is a discriminat dependent on a discriminat appearing
 *	in the constraint expressions?
 */
bool	is_discdep (x, i)
ac	x;
int	i;
{
	ac	t;

	ASSERT (x != NULL && g_d (x) == XFILTER, ("is_discdep:1"));

	switch (g_d (g_constraint (x))) {
	   case XRANGE:
	      return FALSE;		/* for sure */

	   case XINDEXCONS:
	      t = list_element (g_frange (g_constraint (x)), i);
	      if (g_frang_exp (t) == NULL)
	         return FALSE;

	      return is_act_discr (odd (i) ?
	      	g_frang_exp (t) :
	      	g_next (g_frang_exp (t)) );

	   case XDISCRCONS:
	      t = discr_expr (x, i);
	      return is_act_discr (t);
	}
}

/*
 *	Get from discriminantconstraint x the i-th
 *	discriminant type
 */
ac	discrdescnode (x, i)
ac	x;
int	i;
{
	ac	y;

	ASSERT (x != NULL, ("discrdescnode:1"));

	switch (g_d (x)) {
	   case XRECTYPE:
	   case XINCOMPLETE:
	   case XPRIVTYPE:
	      y = get_discr (x, i);
	      ASSERT (y != NULL, ("discrdescnode: NULL"));
	      return g_objtype (g_desc (y));

	   case XARRAYTYPE:
	      y = g_findex (x);
	      while ((i = i - 2) > 0 && y != NULL)
		 y = g_next (y);

	      ASSERT (y != NULL, ("discrdescnode: NULL 2"));
	      return g_indextype (y);

	   DEFAULT (("discrdescnode: illegal node %d", g_d (x)));
	}
}

/*
 *	Set stacktop location, i.e. generate
 *	code for it
 */
void	xxx_stack (x)		/* set_stack is used in viewlib	*/
ac	x;
{
	ASSERT (x != NULL, ("xxx_stack"));

	x = surrounding_block (x);
	new_expr ();
	ASSIGN (ADDRESS);
	   REG (SP_DYN, ADDRESS);
	   if (curr_proc == NULL)
	      GLOB_OBJECT (0, x, ADDRESS);
	   else
	      LOC_OBJECT (curr_level, get_stacktop (x), ADDRESS);
}

/*
 *	Generate code to increment (decrement) a loop
 */
void	Xcrement (x, y, dir)
ac	x;
int	y;
bool	dir;
{
	int	type;

	type = pcc_type_of (x);
	new_expr ();
	if (dir)
	   INCR (type);
	else
  	   DECR (type);

	   code (x, VAL, type);
	   ICON (1, type, "");

	  genjump (y);
}

/*
 *	compute the compile-time knoewn amount of
 *	storage for an object
 */
int	obj_size (type)
ac	type;
{
	type = basefilter (type);

	if (type == NULL)
	   return 0;

	switch (g_d (type)) {
	   case XTASKTYPE:
	      return TADDRSIZE;
 
	   case XRECTYPE:
	      return g_REC_vsize (type);

	   case XACCTYPE:
	      return TADDRSIZE;

	   case XFILTER:
	      return g_FLT_valsize (type);

	   case XENUMTYPE:
	      return TBYTESIZE;

	   case XINTERNAL:
	      switch (g_ind (type)) {
	         case I_ANY_ACCESS_TYPE:
	            return TADDRSIZE;

	         case I_STD_REAL:
	            return TFLOATSIZE;

	         case I_ENUM:
	            return TBYTESIZE;

	         case I_INTEGER:
	            return TWORDSIZE;

	         case I_LONG:
	            return TLONGSIZE;

	         case I_SHORT:
	            return TBYTESIZE;

	         case I_UNIV:
	            return TLONGSIZE;

	         DEFAULT (("cannot find size of internal"));
		}

	DEFAULT (("error in obj_size: %d", g_d (type)));
	}
}

/*
 *	Check to see whether or not it is necessary to generate
 *	a check for the selection of a component in a variant
 *	record
 */
bool	need_check (st, comp)
ac	st,
	comp;
{
	ASSERT (comp != NULL, ("need_check:1"));

	return root_type (st) != g_enclunit (comp);
}

