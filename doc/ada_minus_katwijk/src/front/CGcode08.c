
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
static	listlink	l_elem	();
static	void	linkvoor	();
static	void	linkna	();
static	void	split	();
static	void	complete	();
static	void	comp_caslist	();
static	void	jumptable	();
static	void	isinrange	();
static	void	notinrange	();
static	void	casinrange	();
static	listlink	largest_element	();
static	int	caskind	();
/*
 *	CODE GENERATION FOR CASE STATEMENT
 */

#define	SMALL	00
#define	LARGE	01
#define	SMSIZE	50

#define	f_elem(x)	(x)
#define n_elem(x)	(x -> forelem)
#define lrval(x)	(x -> lv)
#define	hrval(x)	(x -> hv)
#define	attribval(x)	(x -> av)

/*
 */
void	case_list (a_list, a_anchor)
char	**a_list,
	**a_anchor;
{
	*a_list = NULL;
	*a_anchor = NULL;
}

static
listlink	l_elem (list)
listlink	list;
{
	listlink x = f_elem (list);

	if (x == NULL)
           return NULL;

	while (x -> forelem != NULL)
	   x = x -> forelem;

	return x;
}

static
void	linkvoor (a_list, cell, position)
listlink	*a_list,
	cell,
	position;
{
	if (position -> backelem == NULL) {
	   cell -> forelem = position;
	   cell -> backelem = NULL;
	   position -> backelem = cell;
	   *a_list = cell;
	}
	else
	{ cell -> forelem = position;
	  position -> backelem -> forelem = cell;
	  cell -> backelem = position -> backelem;
	  position -> backelem = cell;
	}
}

static
void	linkna (a_list, cell, position)
listlink *a_list,
	cell,
	position;
{
	if (position -> forelem == NULL) {
	   position -> forelem = cell;
	   cell -> backelem = position;
	   cell -> forelem = NULL;
	}
	else
	{ cell -> forelem = position -> forelem;
	  cell -> backelem = position;
	  position -> forelem -> backelem = cell;
	  position -> forelem = cell;
	}
}

static
void	split (a_list, cell, leftl, rightl)
listlink *a_list,
	cell,
	*leftl,
	*rightl;
{
	if (cell == *a_list) {
	   *a_list = NULL;
	   *leftl  = NULL;
	}
	else
	{ cell -> backelem -> forelem = NULL;
	  cell -> backelem = NULL;
	  *leftl = *a_list;
	}

	*rightl = cell -> forelem;
	if (cell -> forelem != NULL)
	   cell -> forelem -> backelem = NULL;
	cell -> forelem = NULL;
}

listlink	new_cell (lval, hval, attval)
int	lval,
	hval,
	attval;
{
	listlink t = (listlink)calloc (1, sizeof (struct l_el));

	t -> lv = lval;
	t -> hv = hval;
	t -> av = attval;

	return t;
}

void	insert (a_list, a_anchor, cell)
listlink *a_list,
	*a_anchor,
	cell;
{
	listlink x;

	cell -> alink = *a_anchor;
	*a_anchor = cell;

	if (*a_list == NULL) {
	   *a_list = cell;
	   return;
	}

	x = f_elem (*a_list);

	while (x != NULL) {
	   if (hrval (cell) < lrval (x)) {
	      linkvoor (a_list, cell, x);
	      return;
	   }

	   x = n_elem (x);
	}

	linkna (a_list, cell, l_elem (*a_list));
}

void	rlist (anchor)
listlink anchor;
{
	listlink t;

	while (anchor != NULL) {
	   t = anchor;
	   anchor = anchor -> alink;
  	   cfree (t);
	}
}

static
void	complete (lval, hval, attrval, a_list, a_anchor)
int	lval,
	hval,
	attrval;
listlink *a_list,
	*a_anchor;
{
	listlink x,
		t;

	if (*a_list == NULL)
	   insert (a_list, a_anchor, new_cell (lval, hval, attrval));
	else
	{   if (lrval (f_elem (*a_list)) != lval)
	       insert (a_list, a_anchor,
			    new_cell (lval, lrval (f_elem (*a_list)) -1, attrval));

	    if (hrval (l_elem (*a_list)) != hval)
	       insert (a_list, a_anchor,
			    new_cell (hrval (l_elem (*a_list)) + 1, hval, attrval));

	    x = f_elem (*a_list);
	    while (n_elem (x) != NULL) {
	       if (hrval (x) + 1 != lrval (n_elem (x)))
	          insert (a_list, a_anchor,
			    new_cell (hrval (x) + 1, lrval (n_elem (x)) - 1,
								attrval));

	       x = n_elem (x);
	    }
	}
}

void	casecomp (low, high, a_list, a_anchor, deflab)
int	low,
	high;
char	**a_list,
	**a_anchor;
int	deflab;
{
	complete (low, high, deflab, a_list, a_anchor);
	comp_caslist (low, high, a_list);
}

static
void	comp_caslist (low, high, a_list)
int	low,
	high;
listlink *a_list;
{
	listlink x,
		*left,
		*right;
	int	t;

	if (*a_list == NULL)
	   return;

	if (caskind (*a_list) == SMALL) {
	   notinrange (low, high, lrval (f_elem (*a_list)),
			     hrval (l_elem (*a_list)), t = new_lab ());
	   jumptable (a_list);
	   deflab (t);
	}
	else
	{ listlink x = largest_element (a_list);
	  split (a_list, x, &left, &right);

	  isinrange (low, high, lrval (x), hrval (x), attribval (x));
	  comp_caslist (low, high, &left);
	  comp_caslist (low, high, &right);
	}
}

static
void	jumptable (a_list)
listlink *a_list;
{
	int	t,
		j,
		count = 0;
	listlink x;

	for (x = f_elem (*a_list); x != NULL; x = n_elem (x))
	  for (j = lrval (x); j <= hrval (x); j++)
	     ++count;

	OUT (("&%d	%d	\n", ICSWTCH, count));

	for (x = f_elem (*a_list); x != NULL; x = n_elem (x)) {
	   int i = attribval (x);
	   for (j = lrval (x); j <= hrval (x); j++)
	      OUT (("&%d	%d	%d	\n", ICSWENT, i, j));
	}

	OUT (("&%d	\n", ICSWEND));
}

static
void	isinrange (low, high, l, h, lab)
int	low,
	high,
	l,
	h,
	lab;
{
	casinrange (TRUE, low, high, l, h, lab);
}

static
void	notinrange (low, high, l, h, lab)
int	low,
	high,
	l,
	h,
	lab;
{
	casinrange (FALSE, low, high, l, h, lab);
}

static
void	casinrange (waar, low, high, l, h, truelab)
int	waar,
	low,
	high,
	l,
	h,
	truelab;
{
	if (l == low && h == high) {
	   if (waar)
	      genjump (truelab);
	   return;
	}

	new_expr ();
	CBRANCH ();
	if (waar)
	   NOT (LONG);

	if (l == h) {
	   EQ (LONG);
	     REG (0, LONG);
	     ICON (h, LONG, "");
	} else
	if (l == low) {
	   GT (LONG);
	     ICON (h, LONG, "");
	     REG (0, LONG);
	}
	else
	if (high == h) {
	   GT (LONG);
	     REG (0, LONG);
	     ICON (l, LONG, "");
	}
	else
	{ NOT (LONG);
	     OROR (LONG);
	        GT (LONG);
	           ICON (l, LONG, "");
	           REG (0, LONG);
	        GT (LONG);
	           REG (0, LONG);
	           ICON (h, LONG, "");
	}

	ICON (truelab, INT, "");
}

static
listlink	largest_element (a_list)
listlink *a_list;
{
	unsigned long max;
	listlink maxcell,
		currcell;

	currcell = f_elem (*a_list);
	maxcell = currcell;
	max = ((unsigned) hrval (maxcell)) - ((unsigned) lrval (maxcell)) + 1;

	while (currcell != NULL) {
	   if (((unsigned) hrval (currcell)) -
				((unsigned) lrval (currcell)) + 1 > max) {
	      maxcell = currcell;
	      max = ((unsigned) hrval (currcell)) -
					((unsigned) lrval (currcell)) + 1;
	   }
	   currcell = n_elem (currcell);
	}

	return maxcell;
}

static
int	caskind (list)
listlink list;
{
	listlink x;

	if (list == NULL)
           return SMALL;

	x = largest_element (&list);
	if (((unsigned) hrval (x)) - ((unsigned) lrval (x)) > SMSIZE)
	   return LARGE;

	return SMALL;
}

