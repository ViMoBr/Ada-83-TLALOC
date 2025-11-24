
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
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 *	Forward (static) declarations
 */
static	void	rangcons	();
static	void	discval	();
static	void	desc_store	();
/*
 *	DESCRIPTOR GENERATION TOOLS
 */

/*
 *	allocate global space (if needed) for a descriptor
 */
void	alloc_desc (x)
ac	x;
{
	ASSERT (x != NULL, ("alloc_desc:1"));

	if (stor_class (x) == GLOBAL) {
	   OUTDATA;
	   defexprlab (x);
	   OUTTEXT;
	}
}

/*
 *	Mark global space of a descriptor (only if global)
 */
void	dat_alloc (x, size)
ac	x;
int	size;
{
	char	datatext [AIDL];

	ASSERT (x != NULL, ("dat_alloc:1"));

	if (stor_class (x) == GLOBAL) {
	   OUTDATA;
	   setdatalab (x, datatext);
	   size = (size + 1) & ~01;	/* adjust */
	   LABELOFF (datatext, size);
	   OUTTEXT;
	}
}

/*
 *	generate an initialization (static or dynamic)
 */
void	expval_store (e, t, o)
ac	e,
	t;
int	o;
{
	if (is_static (e) && stor_class (t) == GLOBAL)
	   lit_store (ord (g_primary (e)), t, o);
	else
	{  new_expr ();
	   pre_code (e, VAL);
	   ASSIGN (LONG);
	      desc_address (t, o);
	      code (e, VAL, LONG);
	}
}

/*
 *	get the i-th discriminant in a discriminat constraint
 */
ac	discr_expr (x, i)
ac	x;
int	i;
{
	ac	disc,
		y,
		comp;

	ASSERT (x != NULL, ("discr_expr:1"));

	disc = get_discr (g_filtype (x), i);

	FORALL (y, g_aggregate (g_constraint (x))) {
	   ASSERT (g_d (y) == XCOMPASSOC, ("discr_exp:1"));

	   FORALL (comp, g_fcompchoice (y))
	      if (g_fentity (g_primary (g_frang_exp (comp))) == disc)
		return g_compexpr (y);
	}

	ASSERT (FALSE, ("discr_expr"));
}

static
void	rangcons (x, d, t, o)
ac	x,
	t;
int	d,
	o;
{
	ac	rang,	/* points to range to be moved */
		h;

	ASSERT (x != NULL && g_d (x) == XFILTER, ("rangcons:1"));

	if (g_d (g_constraint (x)) == XINDEXCONS)
	   rang = list_element (g_frange (g_constraint (x)), d);
	else	/* it better be a filter */
	   rang = g_constraint (x);

	if (g_frang_exp (rang) == NULL) {
	   if (is_static (g_rangetype (rang)))
	      lit_store (odd (d) ? loval (g_rangetype (rang)) :
                                   hival (g_rangetype (rang)),
						t, o);
	   else
	   {  new_expr ();
	      ASSIGN (LONG);
	         desc_address (t, o);
	         desc_address (g_rangetype (rang),
	                      odd (d) ?
			              LD_BIT_LO :
			              LD_BIT_HI);
	   }
	}
	else
	{  h = odd (d) ?
			g_frang_exp (rang) :
			g_next (g_frang_exp (rang));

	   if (is_act_discr (h))
	     lit_store (disc_num (g_fentity (g_primary (h))), t, o);
	   else
	     expval_store (h, t, o);
	}
}

static
void	discval (s, d, t, o)
ac	s,
	t;
int	d,
	o;
{
	ac	x;

	x = discr_expr (s, d);
	if (is_act_discr (x))
	   lit_store (disc_num (g_fentity (g_primary (x))), t, o);
	else
	   expval_store (x, t, o);
}

/*
 *	the general move routine
 *
 *	the target must be, for the time being at least,
 *	something delivering a descriptor address
 *
 *	The source may be one of several, see for yourself
 */
void	move (s, d, t, o)
ac	s,
	t;
int	d,
	o;
{
	t = base_subtype (t);
	s = base_subtype (s);

	if (s == NULL) {
	   lit_store (d, t, o);
	   return;
	}

	switch (g_d (s)) {
	   case XFILTER:
	      switch (g_d (g_constraint (s))) {
		 case XRANGE:
		    rangcons (s, d, t, o);
	    	    return;

		 case XINDEXCONS:
		    rangcons (s, d, t, o);
		    return;

		 case XDISCRCONS:
		    discval (s, d, t, o);
		    return;
	      }

	   case XSUBTYPE:
	   case XENUMTYPE:
	   case XARRAYTYPE:
	   case XRECTYPE:
	   case XACCTYPE:
	   case XINTERNAL:
	   case XTASKTYPE:
	      desc_store (s, t, o);
	      return;

	   case XINCOMPLETE:
	      desc_store (g_complete (s), t, o);
	      return;

	   case XPRIVTYPE:
	      desc_store (g_impl (s), t, o);
	      return;

	   case XEXP:
	      expval_store (s, t, o);
	      return;

	   DEFAULT (("move: %d", g_d (s)));
	}
}

/*
 *	desc_store: store address of descriptor of node
 *	in descriptor of node2 + offs
 */
static
void	desc_store (node1, node2, offs)
ac	node1,
	node2;
int	offs;
{
	char	datatext [AIDL];

	if ((stor_class (node1) == GLOBAL) &&
	    (stor_class (node2) == GLOBAL)) {
		/* write it out in assembler */
	   OUTDATA;
	   setdatalab (node2, datatext);
	   LABELOFF (datatext, offs);
	   setdatalab (node1, datatext);
	   PUT (DEF_SLONG, datatext);
	   OUTTEXT;
	}
	else
	{  new_expr ();
	   ASSIGN (P_LONG);
	      desc_address (node2, offs);
	      desc_const (node1);
	}
}

void	lab_store (labtext, node, offs)
char	*labtext;
int	offs;
ac	node;
{
	char	datatext [AIDL];

	if (stor_class (node) == GLOBAL) {
	   OUTDATA;
	   setdatalab (node, datatext);
	   LABELOFF (datatext, offs);
	   PUT (DEF_SLONG,labtext);
	   OUTTEXT;
	}
	else
	{ new_expr ();
	  ASSIGN (P_LONG);
	     desc_address (node, offs);
	     ICON (0, ADDRESS, labtext);
	}
}

/*
 *	be careful, we have to make a walk through
 *	the record components to make descriptors,
 *	if any, for the implicit subtypes and
 *	call blocks:
 */
void	do_recflds (x)
ac	x;
{
	ac	y;

	FORALL (y, g_ffield (x)) {
	   switch (g_d (y)) {
	      case XSUBTYPE:
	         sub_desc (y);
		 break;

	      case XVARIANT:
		 do_recflds (y);
		 break;

	      default:
			;
	   }
	}
}

void	desc_address (node, offs)
ac	node;
int	offs;
{
	ASSERT (node != NULL, ("desc_address:1"));

	switch (stor_class (node)) {
	   case FIXSTACK:
	      LOC_OBJECT (level_of (node), off (node) - offs, LONG);
	      break;

	   case GLOBAL:
	      GLOB_OBJECT (offs, node, LONG);
	      break;

	   DEFAULT (("desc_address: stor_class=%d", stor_class (node)));
	}
}

/*
 *	desc_const: compute the address of a descriptor
 *	(either location or type descriptor) to be used
 *	as a literal indeed.
 */
void	desc_const (node)
ac	node;
{
	switch (stor_class (node)) {
	   case FIXSTACK:
	      LOC_NAME (level_of (node), off (node), P_LONG);
	      break;

	   case GLOBAL:
	      TEXTLABCON (node);
	      break;

	   DEFAULT (("desc_const: stor_class=%d", stor_class (node)));
	}
}

void	lit_store (litval, node, offs)
ac	node;
int	litval,
	offs;
{
	char	datatext [AIDL];

	if (stor_class (node) == GLOBAL) {
	   OUTDATA;
	   setdatalab (node, datatext);
	   LABELOFF (datatext, offs);
	   PUT (DEF_LONG, litval);
	   OUTTEXT;
	}
	else
	{  new_expr ();
	   ASSIGN (LONG);
	      desc_address (node, offs);
	      ICON (litval, LONG, "");
	}
}

