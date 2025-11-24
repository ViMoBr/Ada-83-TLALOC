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
 *	sets
 */

bool	is_singleton (s)
ac	s;
{
	if (s == NULL)
	   return FALSE;

	if (g_d (s) == XSET)
	   return FALSE;

	return TRUE;
}

ac	first (s)
ac	s;
{
	if (s == NULL)
           return (NULL);

	if (g_d (s) != XSET)
           return s;

	s_iter_ptr (s, g_fsetelem (s));
	return g_elem (g_iter_ptr (s));
}

ac	next_elem (s)
ac	s;
{
	if (s == NULL)
           return (NULL);

	if (g_d (s) == XSET) {
	   s_iter_ptr (s, g_next (g_iter_ptr (s)));
	   if (g_iter_ptr (s) == NULL)
	      return NULL;
	   else
	      return g_elem (g_iter_ptr (s));
	}
	else
	   return NULL;
}

bool	is_empty (s)
ac	s;
{
	return first (s) == NULL;
}

static
ac	creat_elem (elem)
ac	elem;
{
	ac	e;

	e = (ac) calloc (1, sizeof (struct _setelem));
	if (e == NULL) {
	   error ("Out of space in allocating set element, fatal");
	   exit (111);
	}

	s_d (e, XSETELEM);
	s_elem (e, elem);

	return (e);
}

static
bool	is_member (elem, set)
ac	elem,
	set;
{
	ac	t;

	if (set == NULL)
	   return FALSE;

	if (g_d (set) != XSET)	/* singleton		*/
	   return set == elem;

/*	now a low level walk over the set		*/
	FORALL(t, g_fsetelem (set))
	   if (g_elem (t) == elem)
	      return TRUE;

	return FALSE;
}

ac	join (elem, s)
ac	elem,
	s;
{
	ac	save,
		t1;

	if (s == NULL)
	   return elem;

	if (is_member (elem, s))
	   return s;

	if (g_d (s) != XSET) {	/* singleton set	*/
	   save = s;
	   s = alloc (XSET);
	   s_fsetelem (s, creat_elem (save));
	   s_next (g_fsetelem (s), creat_elem (elem));
	   return s;
	}

	t1 = creat_elem (elem);
	s_next (t1, g_fsetelem (s));
	s_fsetelem (s, t1);
	return s;
}

void	del_set (s)
ac	s;
{
	ac	e,
		temp,
	 	*a_s = s;

	if (s == NULL)
	   return;

	if (g_d (s) != XSET)
	   return;

	e = g_fsetelem (s);
/*
 *	Temp: leave the "SET" node
 */
	while (e != NULL) {
	   temp = g_next (e);
	   cfree (e);
	   e = temp;
	}
}

ac	add_set (x, a)
ac	x,
	a;
{
	ac	y;

	FORSET (y, x) 
	   a = join (y, a);

	return a;
}

/*
 *	is el an element of the set s,
 *	take universals into account
 */
bool	is_element (el, s)
ac	el,
	s;
{
	ac	e;

	if (el == NULL || s == NULL)
	   return FALSE;

	el = base_type (el);

	if (g_d (s) != XSET) {	/* singleton set */
	   if (is_anytype (s))
	      return match_univ (el, s);

	   return eq_types (el, s);
	}

	FORALL (e, g_fsetelem (s)) {
	   if (eq_types (g_elem (e), el))
	      return TRUE;

	   if (is_anytype (e)) {
	      if (match_univ (el, e))
		 return TRUE;
	      }
	}

	return FALSE;
}

ac	copy (s)
ac	s;
{
	ac	e,
		temp = NULL;	/* result set	*/

	FORSET (e, s)
	   temp = join (e, temp);

	return temp;
}

/*
 *	propagating up a primary type implies undoing the
 *	strange compiler generated "sub_program" types
 */
ac	exptype_copy (s)
ac	s;
{
	ac	e,
		temp = NULL;	/* result set	*/

	FORSET (e, s)
	   if (!is_sub (e))
	      temp = join (e, temp);

	return temp;
}

