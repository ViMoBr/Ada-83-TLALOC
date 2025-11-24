/*
 * (c) copyright 1987, Delft University of Technology
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
static	ac	bu_applied	();
static	ac	bu_slice	();
static	ac	bu_select	();
static	ac	bu_indexcall	();
static	ac	bu_call		();
static	ac	bu_all		();
static	ac	bu_attr		();
static	ac	td_n_select	();
static	ac	td_n_slice	();
static	ac	td_n_indexcall	();
static	ac	td_n_all	();
static	ac	td_typeconv	();
static	ac	td_call		();
static	ac	td_slice	();
static	ac	td_n_indexing	();
static	ac	m_actl		();
static	ac	td_n_call	();
static	char	*name_tag	();
/*
 *	Type resolution in name constructs
 *	Functions in this module perform the bu_... and td_...
 *	functions required for type checking in names
 *
 *	major functions:
 *	bu_name (node) bottom up name processing
 *	td_proc (node, ct)
 *	td_name (node, ct) and
 *	td_n_name for top-down name processing
 */

/*
 *	bu_name
 *	The general bu_name routine
 *	It dispatches over the various bu_... functions
 */
ac	bu_name (node)
ac	node;
{
	ac	t1,
		t2;

	s_flags (node, g_flags (node) | BUWALK);

	switch (g_d (node)) {
	   case XSLICE:
		return bu_slice (node, g_next (node));

	   case XSELECT:
		return bu_select (node, g_next (node));

	   case XINDEXING:
		return bu_indexcall (node, g_next (node));

	   case XCALL:
		return bu_call (node, g_next (node));

	   case XATTRIBUTE:
		return bu_attr (node, g_next (node));

	   case XALL:
		return bu_all  (node, g_next (node));

	   case XNAME:
		return bu_applied (node);

	   DEFAULT (("bu_name: illegal operation"));
	}
}

/*
 *	bu_applied
 *
 *	Do the bottom-up walk through an applied occurrence of an
 *	identifier
 */
static
ac	bu_applied (node)
ac	node;
{
	ac	s	= NULL;
	ac	temp	= NULL;
	ac	t1;

	if (node == NULL)
	   return NULL;

	t1 = g_fentity (node);
	ASSERT (g_d (t1) == XUNRESREC || g_d (t1) == XUNRESCHAR,
						("Error in bu_applied"));
	if (g_d (t1) == XUNRESREC)
	   s = look_id (g_ident (t1));
	else
	   s = look_char (g_ident (t1));

	if (is_empty (s)) {
	   error ("cannot find %s", g_ident (t1));
	   return NULL;
	}

	s_fentity (node, s);

	FORSET (t1, s) {
	   if (is_sub (t1) && is_paramless (t1)) {
	      temp = add_set (restypes (t1), temp);
	   }

	   temp = add_set (type_of (t1), temp);
	}

	s_types (node, temp);
	s_flags (node, g_flags (node) | BUWALK);
	return node;
}

/*
 *	bu_slice:	called from bu_name with a slice node
 *	function:	verify the set of types of the "next"
 *			node, reduce this set and find result types
 */
static
ac	bu_slice (n1, n2)
ac	n1,
	n2;
{
	ac	t1,
		t2;
	ac	temp1	= NULL;	/* slice types		*/
	ac	temp2	= NULL;	/* element types	*/

	if (n1 == NULL || n2 == NULL)
	   return NULL;

	ASSERT (g_d (n1) == XSLICE, ("just to be sure: XSLICE"));

	n2 = bu_name (n2);	/* left subtree		*/
	if (n2 == NULL)
	   return NULL;

	s_next (n1, n2);
	t1 = g_slrange (n1);
	if (g_next (t1) != NULL) {
	   error ("Slicing construction (%s) has too many arguments",
						name_tag (n2) );
	   return NULL;
	}

	s_slrange (n1, bu_expr (t1));
	FORSET (t1, g_types (n2)) {
	   if (has_slicing (t1)) {
	      temp1 = add_set (t1, temp1);
	      temp2 = add_set (t1, temp2);
	   }
	}

	del_set (g_types (n2));
	s_types (n2, temp1);
	s_types (n1, temp2);
	return n1;
}

/*
 *	bu_select,
 *	the bottom-up walker through a selection
 *	n1 is the node, n2 the "next" node
 */
static
ac	bu_select (n1, n2)
ac	n1,
	n2;
{
	ac	t1,
		t2,
		t4;

	ac	temp1 = NULL;	/* set		*/
	ac	temp2 = NULL;	/* set		*/
	ac	temp3 = NULL;

	if (n1 == NULL || n2 == NULL)
	   return NULL;

	ASSERT (g_d (n1) == XSELECT, ("checking XSELECT"));
	n2 = bu_name (n2);
	if (n2 == NULL)	{		/* real error	*/
	   return NULL;
	}

	s_next (n1, n2);

	FORSET (t1, g_types (n2)) {
	   if (has_selection (t1)) {
	      t2 = select (t1, g_entity (n1), selkind (n1));

	      if (t2 != NULL) {
	         temp1 = add_set (t1, temp1);

		 FORSET (t4, t2) {
	            temp2 = add_set (t4, temp2);
	            temp3 = add_set (type_of (t4), temp3);
	            if (is_sub (t4) && is_paramless (t4)) {
	               temp3 = add_set (restypes (t4), temp3);
		    }
	        }
	      }
	   }
	}

	if (is_empty (temp3)) {
	   error ("Impossible to select %s\n", g_entity (n1));
	   return NULL;
	}

	del_set (g_types (n1));

	s_types (n1, temp3);
	s_entity (n1, temp2);
	s_types (n2, temp1);

	return n1;
}

/*
 *	bu_indexcall
 *
 *	At parsing time no difference can be made between
 *	a call, an indexing and so on.
 *	Take this into account
 */
static
ac	bu_indexcall (n1, n2)
ac	n1,
	n2;
{
	ac	t1;
	TRIP	*t2;
	char	*hulptag;
	ac	temp1	= NULL;	/* set		*/
	ac	temp2	= NULL;	/* set		*/

	if (n1 == NULL || n2 == NULL)
	   return NULL;

	ASSERT (g_d (n1) == XINDEXING, ("just to be sure XINDEXING"));

	n2 = bu_name (n2);	/* left subtree		*/
	if (n2 == NULL)
	   return NULL;

	hulptag = name_tag (n2);
	s_next (n1, n2);
	FORALL (t1, g_farg (n1))
	   bu_expr (t1);

	FORSET (t1, g_types (n2)) {
	   if (has_indexing (t1)) {
	      if (chk_slice (t1, g_farg (n1)) ||
	         (chk_typeconv (n2, t1, g_farg (n1)))) {
	         temp1 = add_set (t1, temp1);
		 temp2 = add_set (t1, temp2);
	      }
	      else
	      if (chk_index (t1, g_farg (n1))) {
	         temp1 = add_set (t1, temp1);
	         temp2 = add_set (g_elemtype (get_arraytype (t1)), temp2);
	      }
	   }
	   else
	   if (has_calling (t1)) {
	      t2 = chk_sub (t1, g_farg (n1));	/* triple set	*/
	      if (t2 != NULL) {
	         temp1 = add_set (t2, temp1);
	         temp2 = add_set (restypes (t2), temp2);
	      }
	   }

	   else
	   { if (chk_typeconv (n2, t1, g_farg (n1))) {
	        temp1 = add_set (t1, temp1);
	        temp2 = add_set (t1, temp2);
	     }
	   }

	}

	del_set (g_types (n2));
	if (is_empty (temp2)) {
	   error ("No objects (%s) left on which indexing may be applied",
							hulptag);
	   return NULL;
	}
	s_types (n1, temp2);
	s_types (n2, temp1);

	return n1;
}

/*
 *	bu_call
 *
 *	is called in those cases where it is clear
 *	that we deal with a function call
 */
static
ac	bu_call (n1, n2)
ac	n1,
	n2;
{
	ac	t1;
	TRIP	*t2;
	ac	temp1	= NULL;	/* set		*/
	ac	temp2	= NULL;	/* set		*/
	char	*hulptag;

	if (n1 == NULL || n2 == NULL)
	   return NULL;

	ASSERT (g_d (n1) == XCALL, ("just to be sure: CALLING"));

	hulptag = name_tag (n2);
	n2 = bu_name (n2);
	if (n2 == NULL)
	   return NULL;
	s_next (n1, n2);

	FORALL (t1, g_fact (n1))
	   bu_expr (t1);		/* parameters	*/

	FORSET (t1, g_types (n2)) {
	   if (has_calling (t1)) {
	      t2 = chk_sub (t1, g_fact (n1));
	      if (t2 != NULL) {
	         temp1 = add_set (t2, temp1);
	         temp2 = add_set (restypes (t2), temp2);
	      }
	   }
	}

	del_set (g_types (n2));
	if (is_empty (temp1)) {
	   error ("No objects (%s) left that can be called\n", hulptag);
	   return NULL;
	}
	s_types (n1, temp2);		/* result types		*/
	s_types (n2, temp1);		/* callees		*/

	return n1;
}

/*
 *	bu_all
 *	the dereferencing
 */
static
ac	bu_all (n1, n2)
ac	n1,
	n2;
{
	ac	t1,
		t2;
	ac	temp1	= NULL;
	ac	temp2	= NULL;

	if (n1 == NULL || n2 == NULL)
	   return NULL;

	ASSERT (g_d (n1) == XALL, ("checking ALL"));

	n2 = bu_name (n2);	/* left subtree walk		*/
	if (n2 == NULL)		/* serious error		*/
	   return NULL;
	s_next (n1, n2);

	FORSET (t1, g_types (n2)) {
	   t2 = dereftype (t1);
	   if (t2 == NULL)
	      continue;

	   temp1 = add_set (t1, temp1);
	   temp2 = add_set (do_deref (t2), temp2);
	}

	del_set (g_types (n2));
	if (is_empty (temp1)) {
	   error ("No dereferencable types in name (%s) left", name_tag (n2));
	   return NULL;
	}

	s_types (n2, temp1);	/* to be dereferenced		*/
	s_types (n1, temp2);	/* result types			*/
	return n1;
}

/*
 *	bu_attr
 *
 *	bottom up handling of attributes
 */
static
ac	bu_attr (n1, n2)
ac	n1,
	n2;
{
	ac	t1,
		t2;
	ac	temp1	= NULL;	/* set		*/
	ac	temp2	= NULL;
	int	iv;
	int	attr_value;			/* attribute value	*/
	char	*hulptag;

	if (n1 == NULL || n2 == NULL)
	   return NULL;

	ASSERT (g_d (n1) == XATTRIBUTE, ("to be sure: ATTRIB"));

	hulptag = name_tag (n2);
	n2 = bu_name (n2);
	if (n2 == NULL)
	   return NULL;
	s_next (n1, n2);

	s_entity (n1, bu_expr (g_entity (n1)));
	attr_value = g_attr_value (n1);

	switch (attr_value) {
	case A_TERMINATED:
	case A_CALLABLE:
		if (g_entity (n1) != NULL) {
		   error ("Illegal parameter at TERMINATED/CALLABLE/STORAGE attribute");
		   return NULL;
		}
		 
		s_types (n1, std_boolean);
		return n1;

	case A_WIDTH:
		if (g_entity (n1) != NULL) {
		   error ("Illegal parameter (%s) at WIDTH atribute", hulptag);
		   return NULL;
		}
		s_types (n1, std_univ);
		return n1;

	case A_COUNT:
		if (g_entity (n1) != NULL) {
		   error ("Illegal parameter at COUNT attribute %s", hulptag);
		   return NULL;
		}
		s_types (n1, std_univ);
		return n1;

	case A_RANGE:
		FORSET (t1, g_types (g_next (n1))) {
		   if (is_scalar (t1))
		      temp1 = add_set (t1, temp1);
		   else
		   if (has_indexing (t1))
		      temp1 = add_set (get_indextype (get_arraytype (t1), 1), temp1);
		}
		s_types (n1, temp1);
		return n1;

	case A_POS:
		s_types (n1, std_univ);
		if (g_entity (n1) == NULL) {
		   error ("Attribute POS needs argument");
		   return NULL;
		}
		return n1;

	case A_PRED:
	case A_SUCC:
	case A_VAL:
		if (g_entity (n1) == NULL) {
		   error ("Attribute %s needs argument",
		         attr_value == A_PRED ? "PRED" :
		         attr_value == A_SUCC  ? "SUCC"  :
		         "VAL"
		   );
		   return NULL;
		}
		FORSET (t1, g_types (n2)) {
		   if (is_scalar (t1)) {
		      temp1 = add_set (t1, temp1);
		      temp2 = add_set (t1, temp2);
		   }
		}

		del_set (g_types (n2));
		s_types (n1, temp2);	/* result types		*/
		s_types (n2, temp1);	/* source types		*/
		return n1;

	case A_IMAGE:
		s_types (n1, std_string);
		if (g_entity (n1) == NULL) {
		   error ("Need expression as IMAGE parameter (%s)", hulptag);
		   return NULL;
		}
		return n1;

	case A_STORAGE_SIZE:
		s_types (n1, std_univ);
		if (g_entity (n1) != NULL) {
		   error ("No parameter allowed for STORAGE_SIZE attribute (%s)",
								hulptag);
		}
		s_entity (n1, NULL);
		return n1;

	case A_VALUE:
		if (g_entity (n1) == NULL) {
		   error ("Parameter missing in VALUE attribute %s", hulptag);
		   return NULL;
		}
		FORSET (t1, g_types (n2)) {
		   if (is_scalar (t1)) {
		      temp1 = add_set (t1, temp2);
		      temp2 = add_set (t1, temp2);
		   }
		}
		del_set (g_types (n2));
		s_types (n1, temp1);
		s_types (n2, temp2);
		return n1;

	case A_ADDRESS:
	case A_SIZE:
		if (g_entity (n1) != NULL) {
		   error ("Illegal parameter at ADDRESS attribute");
		   return NULL;
		}
		s_types (n1, std_univ);
		return n1;

	case A_FIRST:
	case A_LAST:
	case A_LENGTH:
		if (g_entity (n1) == NULL)
		   iv = 1;		/* default value	*/
		else
	        { s_entity (n1, solve_expr (g_entity (n1), std_univ));
		  if (g_entity (n1) == NULL)
		     return NULL;
		  if (!is_static (g_entity (n1))) {
		     error ("Expression in attribute for %s non static", hulptag);
		     iv = 1;
		  }
		  else
		     iv = ord (g_primary (g_entity (n1)));
		}

		if (g_entity (n1) == NULL) {
		   ac tt = mk_expr (std_univ, cp_value (1, std_univ));
		   set_static (tt);
		   s_entity (n1, tt);
		}
		FORSET (t1, g_types (n2)) {
		   if (is_scalar (t1)) {
		      temp1 = add_set (t1, temp1);	/*	*/
		      if (attr_value == A_LENGTH)
		         temp2 = add_set (std_integer, temp2);
		      else
		         temp2 = add_set (t1, temp2);
		   }
		   if (has_indexing (t1)) {
		      ac h;
		      h = get_indextype (get_arraytype (t1), iv);
		      if (h != NULL) {
		         temp1 = add_set (t1, temp1);
		         if (attr_value == A_LENGTH)
		            temp2 = add_set (std_integer, temp2);
		         else
		            temp2 = add_set (h, temp2);
		      }
		   }
		}

		del_set (g_types (n2));
		s_types (n1, temp2);		/* result types	*/
		s_types (n2, temp1);		/* attributable types	*/

		if (is_empty (temp1)) {
		   error ("No types left on attributing %s", hulptag);
		   return NULL;
		}
		return n1;

	DEFAULT (("unsupported attribute"));
	}
}

/*
 *	Called for a procedure statement
 */
ac	td_proc (node)
ac	node;
{
	ac	t1,
		t2,
		t3;
	ac	temp = NULL;	/* result types	*/
	char*	errorname = "no_name";

	if (node == NULL)
	   return NULL;

	ASSERT (is_name (node), ("td_proc %d\n", g_d (node)));

	if (g_fentity (node) != NULL)
	   errorname = tag_of (g_fentity (node));

	FORSET (t1, g_types (node)) {
	   if (t1 == notype)
	      temp = add_set (t1, temp);
/*
	   else
	   if (is_sub (t1) && is_paramless (t1) && restypes (t1) == notype)
	      temp = add_set (t1, temp);
 */
	}

	if (!is_singleton (temp)) {
	   error ("Cannot identify %s as procedure", errorname);
	   print_names (temp);
	   return NULL;
	}

	del_set (g_types (node));
	s_types (node, temp);

	t1 = td_n_name (node);
	if (t1 == NULL)
	   return NULL;

	/* make it into a proc	*/
	t1 = pl_call (t1);
	if (g_d (t1) == XENTRYCALL) {
	   t3 = g_next (t1);
	   if (g_d (t3) == XSELECT) {	/* to be reduced	*/
	      s_e_entry (t1, g_entity (t3));
	      s_next    (t1, g_next (t3));
	      return t1;
	   }
	}

	if (g_d (t1) == XSELECT) {	/* paramless entrycall	*/
	   t3 = nalloc (XENTRYCALL);
	   s_next     (t3, g_next (t1));
	   s_e_entry  (t3, g_entity (t1));
	   return t3;
	}

	return t1;
}

/*
 *	td_name
 *	top-down reduce a name tree, taking contexttype ct into
 *	account
 */
ac	td_name (node, ct)
ac	node,
	ct;
{
	if (node == NULL)
	   return NULL;

	ASSERT (g_flags (node) & BUWALK, ("td_name: buwalk forgotten"));
	ASSERT (is_singleton (ct), ("td_name: ct not singleton"));

	s_types (node, propagate (ct, g_types (node)));
	if (!is_singleton (g_types (node))) {
	   error ("name type (%s) not unique", name_tag (node));
	   print_names (g_types (node));
	   return NULL;
	}

	node = td_n_name (node);
	if (node == NULL)
	   return NULL;

	return pl_call (node);
}

/*
 *	The real top-down name walker
 *	dispatch the right routine for the top-down
 *	processing of the construct
 *
 */
ac	td_n_name (node)
ac	node;
{
	if (node == NULL)
	   return NULL;

	switch (g_d (node)) {
	   case XNAME:
	        return td_n_nm (node);

	   case XSELECT:
		return td_n_select (node);

	   case XSLICE:
		return td_n_slice (node);

	   case XINDEXING:
		return td_n_indexcall	(node);
	
	   case XALL:
		return td_n_all	(node);

	   case XTYPECONV:
		error ("hidden type conversion to %s", tag_of (g_types (node)));
		return NULL;

	   case XATTRIBUTE:
		return td_n_attrib (node, NULL);

	   case XCALL:
	   case XENTRYCALL:
		return td_call (node);

	   DEFAULT (("Niet ondersteunde name (%d) operatie\n", g_d (node) ));
	}
}

/*
 *	top-down processing of a single identifier
 */
ac	td_n_nm (node)
ac	node;
{
	ac	t1;
	ac	temp	= NULL;

	char	*hulptag;

	ASSERT (node != NULL && g_d (node) == XNAME, ("td_n_nm"));

	hulptag = name_tag (node);

	FORSET (t1, g_fentity (node)) {
	   if (eq_types (type_of (t1), g_types (node)))
	      temp = add_set (t1, temp);
	   else
	   if (g_d (g_types (node)) == XTRIPLE) {
	      ASSERT (is_sub (t1), ("Ik weet het ook niet"));
	      if (sub_equal (t1, g_types (node)))
	         temp = add_set (t1, temp);
	   }
	   else
	   if (is_paramless (t1) &&
	       eq_types (restypes (t1), g_types (node))) {
	      temp = add_set (t1, temp);
	   }
	}

	if (temp == NULL) {
	   error ("Cannot find appropriate %s", hulptag);
	   return NULL;
	}

	if (!is_singleton (temp)) {
	   error ("Cannot identify %s (more than one solution)", hulptag);
	   print_names (temp);
	   return NULL;
	}

	s_fentity (node, temp);
	return node;
}

/*
 *	td_n_select
 *	In this particular case we may choose between
 *	a record component selection and a unit selection
 *	In case of the latter, take away the whole subtree
 *	and build a new leaf.
 */
static
ac	td_n_select (node)
ac	node;
{
	ac	t1,
		t2,
		t3;
	ac	temp	= NULL;	/* result type set	*/
	char	*hulptag;		/* for error messages	*/

	if (node == NULL)		/* should not happen though	*/
	   return NULL;

/*
 *	Reduce the set of entities, with respect to the result types
 */
	ASSERT (g_types (node) != NULL, ("td_n_indexing:1"));

	hulptag = tag_of (first (g_entity (node)));

	FORSET (t1, g_entity (node)) {
	   if (is_sub (t1)) {
	      if (eq_types (restypes (t1), g_types (node)))
	         temp = add_set (t1, temp);
	   }

	   if (eq_types (type_of (t1), g_types (node)))
	      temp = add_set (t1, temp);
	   else
	   if (is_anytype (type_of (t1)) &&
		        match_univ (g_types (node), type_of (t1))) {
	      temp = add_set (t1, temp);
	   }
	}
/*
	if (!is_singleton (temp)) {
	   error ("Cannot uniquely identify in selecting %s", hulptag);
	   print_names (temp);
	   return NULL;
	}
*/
	s_entity (node, temp);
	temp = NULL;

/*
 *	We know now not only the result type, but also
 *	the entity that is selected
 */

	FORSET (t1, g_types (g_next (node))) {
	   if (ch_select (t1, g_entity (node), selkind (node))) {
	      temp = add_set (t1, temp);
	   }
	}

	if (temp == NULL) {
	   error ("cannot identify a type consistent %s in selection", hulptag);
	   return NULL;
	}

	if (!is_singleton (temp)) {
	   error ("cannot uniquely identify a %s in selection", hulptag);
	   print_names (temp);
	   return NULL;
	}

	s_types (g_next (node), temp);
	temp = NULL;

	t3 = td_n_name (g_next (node));	/* left subtree first	*/
	if (t3 == NULL)	{		/* It shouldnot be, ..	*/
	   return NULL;
	}

	t3 = pl_call (t3);

	/* Pas op: Er zijn gevallen te verzinnen waarbij de set
	 * entities niet singleton is. (Task entries en zo)
	 * Reduceer dat hier!!!
	 */
	FORSET (t1, g_entity (node)) {
	   if (ch_select (g_types (t3), t1, selkind (node)))
	      t2 = t1;
	}

	if (t2 == NULL) {
	   error ("Sorry, no valid %s is left in type checking selection",
							hulptag);
	   return NULL;
	}

	del_set (g_entity (node));
	s_entity (node, t2);
/*
 *	check that the left subtree is something reasonable,
 *	i.e. no type name
 */
	switch (g_d (t2)) {
	   case XOBJECT:
		if (is_discr (t2) || is_recfield (t2)) {
		   if (!is_object_or_value (t3)) {
		      error ("Cannot select (%s) from non-value\n", tag_of (t2));
		      return NULL;
		   }

		   insert_all (node, t3);
		   return node;
		}
		t1 = mx_name (t2, g_types (node));
		return t1;	/* unit selection		*/

	   case XENTRY:
		if (!is_object_or_value (t3)) {
		   error ("Cannot select (%s) from non-value\n", tag_of (t2));
		   return NULL;
		}

	        insert_all (node, t3);
		return node;

	   default:
		t1 = mx_name (t2, g_types (node));
		return t1;
	}
}

/*
 *	td_n_slice
 *	The operator is (syntactically) known to be a slice
 */
static
ac	td_n_slice (node)
ac	node;
{
	ac	t1,
		t2;
	ac	temp	= NULL;	/* set		*/

	char	*hulptag;

	if (node == NULL)
	   return NULL;

	ASSERT (is_singleton (g_types (node)), ("td_n_slice:1"));

/*
 *	The resulting type should be the base type
 *	since it is this type the slice is from
 */
	s_types (node, base_type (g_types (node)));
	hulptag = name_tag (node);

	if (g_next (node) == NULL)
	   return NULL;

	FORSET (t1, g_types (g_next (node))) {
	   if (eq_types (base_type (get_slicetypes (t1)), g_types (node)))
	      temp = add_set (t1, temp);
	}

	if (temp == NULL) {
	   error ("No valid slice types left (%s)", hulptag);
	   return NULL;
	}

	if (!is_singleton (temp)) {
	   error ("More than a single slicetype left %s",
                                               tag_of (base_type (first(temp))));
	   print_names (temp);
	   return NULL;
	}

	s_types (g_next (node), temp);
	t2 = g_slrange (node);
	if (t2 == NULL)
	   return NULL;

	t1 = propagate (get_indextype (g_types (node), 1), g_rangetype (t2));
	if (t1 == NULL) {
	   error ("Slice type %s and range type in slice incompatible",
				        tag_of (g_types (node)) );
	   return NULL;
	}

	s_rangetype (t2, t1);
	s_slrange   (node, td_range (t2));
	insert_all (node, pl_call (td_n_name (g_next (node))));

	if (!is_object_or_value (g_next (node)))
	   error ("Cannot take slice from non-value/object %s", hulptag);

	return node;
}

/*
 *	td_n_indexcall
 *	rewrite the tree freely
 */
static
ac	td_n_indexcall (node)
ac	node;
{
	ac	t1,
		t2,
		t3,
		t4;
	ac	temp = NULL;
	char	*hulptag;

	hulptag = name_tag (node);
	t1 = g_next (node);	/* just a simplification	*/

	if (t1 == NULL)
	   return NULL;

	t4 = g_types (node);	/* return type			*/
	FORSET (t2, g_types (t1)) {

	   t3 = get_arraytype (t2);
	   if (t3 != NULL) {
	      if (td_reduce (t4, g_elemtype (get_arraytype (t3))) != NULL) {
	         temp = add_set (t2, temp);
		 continue;
	      }
	   }

	   t3 = (ac)get_triple (t2);
	   if (t3 != NULL) {
	      if (td_reduce (t4, restypes (t3)) != NULL) {
	         temp = add_set (t2, temp);
		 continue;
	      }
	   }

	   /* Slice or type conversion ?	*/
	   if (td_tpconv (t1, t2, t4) ||
	       (td_reduce (t4, get_slicetypes (t2)) != NULL)) {
	      temp = add_set (t2, temp);
	   }
	}

	if (!is_singleton (temp)) {
	   temp = (ac)reduce_triples (temp);
	}

	if (temp == NULL) {
	   error ("No calling/indexing object left (%s)", hulptag);
	   return NULL;
	}

	if (!is_singleton (temp)) {
	   error ("Cannot uniqely identify object (%s) in calling/indexing",
							hulptag);
	   print_names (temp);
	   return NULL;
	}

	del_set (g_types (t1));
	s_types (t1, temp);
	t1 = td_n_name (t1);
	if (t1 == NULL)
	   return NULL;

/*
 *	Now for the final decision:
 */
	if (is_call (t1)) {
	   t2 = mx_call (t4, g_farg (node));
	   s_next (t2, t1);
	   t2 = td_n_call (t2);
	   return t2;
	}

	if (is_ecall (t1)) {
	   t2 = mx_ecall (notype, g_farg (node));
	   s_next (t2, t1);
	   t2 = td_n_call (t2);
	   del_rec (node);
	   return t2;
	}

	/* it better be an indexing, type conversion or a slice	*/
	if (base_type (temp) == base_type (t4) ||
	    (get_slicetypes (temp) != NULL &&
	     get_slicetypes (temp) == get_slicetypes(t4)) ) {
	   t1 = td_name (t1, temp);	/* implies pl_call */
	   if (is_tpconv (t1)) {
	      t2 = mx_typeconv (t4, g_farg (node));
	      t2 = td_typeconv (t2);
	      return t2;
	   }
	   else
	   { t2 = mx_slice (t4, g_farg (node));
	     s_next (t2, t1);
	     t2 = td_slice (t2);
	     del_rec (node);
	     return t2;
	   }
	}
	else
	{ s_next (node, t1);
	  t2 = td_n_indexing (node);
	  del_rec (node);
	  return t2;
	}
}

/*
 *	td_n_all
 */
static
ac	td_n_all (node)
ac	node;
{
	ac	t1;
	ac	temp = NULL;
	ac	t2;
	char	*hulptag;

	hulptag = name_tag (node);
	if (g_types (node) == NULL) {
	   error ("No derefencable types left (%s)", hulptag);
	   return NULL;
	}

	if (!is_singleton (g_types (node))) {
	   error ("No unique dereferencable type left %s",
				tag_of (first (g_types (node))) );
	   print_names (g_types (node));
	   return NULL;
	}

	FORSET (t1, g_types (g_next (node))) {
	   if (eq_types (do_deref (t1), g_types (node)))
	      temp = add_set (t1, temp);
	}

	del_set (g_types (g_next (node)));
	s_types (g_next (node), temp);

	t2 = pl_call (td_n_name (g_next (node)));
	if (t2 == NULL)
	   return NULL;
	s_next (node, t2);
	return node;
}

/*
 *	td_typeconv
 */
static
ac	td_typeconv (x)
ac	x;
{
	ac	y;

	if (x == NULL)
	   return NULL;

	y = g_convexpr (x);
	if (!is_singleton (type_of (y))) {
	   error ("Cannot properly type check expression in type conv");
	   return NULL;
	}

	y = td_expr (y);
	if (y == NULL)
	   return NULL;

	return x;
}

/*
 *	td_n_attrib
 *	make a top-down walk through an attribute node
 *	(NOT static; functions in other modules call it directly)
 */
ac	td_n_attrib (node, n2)
ac	node;
ac	n2;
{
	ac	t1,
		t2,
		t3;
	bool	stat_range = FALSE;
	int	iv;
	ac	temp	= NULL;	/* set		*/
	char	*hulptag;

	if (node == NULL)
	   return NULL;

	ASSERT (g_d (node) == XATTRIBUTE, ("td_n_attribute %d", g_d (node)));

	if (g_next (node) == NULL)
	   return NULL;

	hulptag = name_tag (node);
	switch (g_attr_value (node)) {
	   case A_COUNT:
		FORSET (t2, g_types (g_next (node))) {
		   if (g_d (t2) == XENTRY || g_d (t2) == XRENSUB) {
		      temp = add_set (t2, temp);
		   }
		}
		if (temp == NULL) {
		   error ("Cannot solve COUNT attribute");
		   return NULL;
		}
		s_types (g_next (node), temp);
		t1 = td_n_name (g_next (node));
		t1 = pl_call (t1);
		if (t1 == NULL)
		   return NULL;
		if (g_d (t1) != XSELECT) {
		   error ("Error in COUNT attribute");
		   return NULL;
		}
		if (g_d (g_types (t1)) != XENTRY) {
		   error ("Error in COUNT attribute %s", tag_of (t1));
		   return NULL;
		}
		s_next (node, t1);
		return node;

	   case A_TERMINATED:
	   case A_CALLABLE:
	   case A_STORAGE_SIZE:
		t1 = pl_call (td_n_name (g_next (node)));
		if (t1 == NULL)
		   return NULL;

		if (g_d (base_type (g_types (t1))) != XTASKTYPE) {
		   error ("Error in TERMINATE/CALLABLE/STORAGE_SIZE atribute");
		   return NULL;
		}

		s_next (node, t1);
		return node;

	   case A_RANGE:
		FORSET (t2, g_types (g_next (node))) {
		   if (is_scalar (t2)) {
		      if (eq_types (t2, g_types (node))) {
		         temp = add_set (t2, temp);
		      }
		   }
		   else
		   if (has_indexing (t2)) {
		      if (eq_types (get_indextype (get_arraytype (t2), 1),
		                         g_types (node))) {
		         temp = add_set (t2, temp);
		      }
		   }
		}

		s_types (g_next (node), temp);
		t1 = td_n_name (g_next (node));
		t1 = pl_call (t1);
		if (t1 == NULL) {
		   error ("Illegal case of range attributing");
		   return NULL;
		}

		ASSERT (n2 != NULL && g_d (n2) == XRANGE, ("td_n_attr:2"));
		t2 = cp_tree (g_next (node));
		if (has_indexing (g_types (node))) {
		   t1 = get_indextype (get_arraytype (t1), 1);
		   s_rangetype (n2, t1);
		   s_frang_exp (n2, mk_first (g_next (node), t1));
		   s_next      (g_frang_exp (n2),
						   mk_last (t2, t1));
		   return st_range (n2);	/* make it static	*/
		}

		t1 = g_types (node);
		if (!is_scalar (t1)) {
		   error ("Erroneous attempt to take range");
		   return mk_range (NULL, NULL, NULL);
		}
		s_rangetype (n2, t1);
		s_frang_exp (n2, mk_first (g_next (node), t1));
		s_next      (g_frang_exp  (n2),
						mk_last (t2, t1));
		return st_range (n2);

	   case A_PRED:
	   case A_SUCC:
		del_set (g_types (g_next (node)));
		s_types (g_next (node), g_types (node));
		s_entity (node, solve_expr (g_entity (node), g_types (node)));
		break;

	   case A_IMAGE:
		s_next (node, pl_call (td_n_name (g_next (node))));
		if (!type_name (g_next (node))) {
		   error ("Cannot solve IMAGE attribute");
		   return NULL;
		}

		s_entity (node, solve_expr (g_entity (node), g_types (g_next (node))));
		break;

	   case A_WIDTH:
		s_next (node, pl_call (td_n_name (g_next (node))));
		if (type_name (g_next (node)) == NULL) {
		   return NULL;
		}

		break;

	   case A_VALUE:
		s_next (node, pl_call (td_n_name (g_next (node))));
		if (type_name (g_next (node)) == NULL) {
		   error ("type error: VALUE");
		   return NULL;
		}

		s_entity (node, solve_expr (g_entity (node), std_string));
		break;

	   case A_ADDRESS:
		s_next (node, pl_call (td_n_name (g_next (node))));
		if (g_next (node) == NULL)
		   return NULL;
		break;

	   case A_LENGTH:
	   case A_FIRST:
	   case A_LAST:
/*
 *	First: reduce the set of types in the "next" node
 *	Second, solve the left subtree
 */
		iv = ord (g_primary (g_entity (node)));
		FORSET (t1, g_types (g_next (node))) {
		   if (g_attr_value (node) == A_LENGTH) {
		      temp = add_set (t1, temp);
		   }
		   else
		   if (is_scalar (t1)) {
		      if (eq_types (t1, g_types (node)))
		         temp = add_set (t1, temp);
		   }
		   else
		   if (has_indexing (t1)) {
		      if (eq_types (get_indextype (t1, iv), g_types (node)))
		         temp = add_set (t1, temp);
		   }
		}

		if (!is_singleton (temp)) {
		   error ("Cannot solve FIRST/LAST/LENGTH attribute");
		   return NULL;
		}

		del_set (g_types (g_next (node)));
		s_types (g_next (node), temp);
		s_next (node, pl_call (td_n_name (g_next (node))));
		if (is_scalar (g_types (g_next (node)))) {
		   type_name (g_next (node));	/* he checks	*/
		}
		break;

	   case A_SIZE:
		s_next (node, pl_call (td_n_name (g_next (node))));
		if (g_next (node) == NULL)
		   return NULL;
		if (!is_sizeable (g_next (node))) {
		   error ("Trying to compute size of NON-object");
		   return NULL;
		}

		break;

	   case A_POS:
		s_next (node, pl_call (td_n_name (g_next (node))));
		if (g_next (node) == NULL)
		   return NULL;

		if (type_name (g_next (node)) == NULL)
		   return NULL;
		s_entity (node, solve_expr (g_entity (node),
					g_types (g_next (node))));
		break;

	   case A_VAL:
		s_types (g_next (node), g_types (node));
		s_next (node, pl_call (td_n_name (g_next (node))));
		s_entity (node, td_expr (g_entity (node)));
		if (type_name (g_next (node)) == NULL)
		   return NULL;

		break;

	   DEFAULT (("Unsupported attribute"));
	}

	return try_attrib (node);
}

/*
 *	td_call
 *	top-down processing for a construct of which it is
 *	known that it is a call or entrycall a priori
 */
static
ac	td_call (node)
ac	node;
{
	ac	t1;
	ac	t2;
	ac	temp	= NULL;

	FORSET (t1, g_types (g_next (node))) {
	   t2 = (ac) get_triple (t1);
	   if (t2 != NULL) {
	      t2 = (ac) red_tripset (t2, g_types (node));
	      if (t2 != NULL)
	         temp = add_set (t2, temp);
	   }
	}

	if (!is_singleton (temp)) {
	   temp = (ac) reduce_triples (temp);
	}

	if (!is_singleton (temp)) {
	   error ("Cannot solve calling for %s", name_tag (node));
	   print_names (temp);
	   return NULL;
	}

	del_set (g_types (g_next (node)));
	s_types (g_next  (node), temp);

	t1 = td_n_name (g_next (node));
	if (t1 == NULL) {
	   return NULL;
	}

	s_next (node, t1);
	return td_n_call (node);
}

/*
 *	td_slice
 */
static
ac	td_slice (node)
ac	node;
{
	ac	t1,
		t2,
		t3;
	ac	t4,
		t5,
		t6;
	ac	temp = NULL;	/* result types		*/

	if (node == NULL)
	   return NULL;

	ASSERT (is_singleton (g_types (node)), ("Result types (slice) not unique"));

/*
 *	Be sure to make the resulting array type the base type
 */
	s_types (node, base_type (g_types (node)));
	if (g_next (node) == NULL)
	   return NULL;
	t2 = get_slicetypes (g_types (g_next (node)));

	ASSERT (t2 != NULL, ("td_slice"));

	t5 = g_slrange (node);
	if (t5 == NULL)
	   return NULL;

	if (g_d (t5) != XRANGE) {	/* It better be a type name then	*/
	   ASSERT (g_d (t5) == XEXP, ("Range in slice %d", g_d (t5)));
	   t6 = g_primary (t5);
	   if (!is_name (t6)) {
	      error ("Error in slice argument");
	      return NULL;
	   }

	   t6 = type_name (td_n_name (t6));
	   if (t6 == NULL)
	      return NULL;

	   t6 = mk_range (t6, NULL, NULL);
	   s_slrange (node, t6);
	}

	t1 = propagate (get_indextype (t2, 1), g_rangetype (g_slrange (node)));
	if (t1 == NULL) {
	   error ("cannot find proper slice type");
	   return NULL;
	}

	s_rangetype (g_slrange (node), t1);
	s_slrange (node, td_range (g_slrange (node)));
	insert_all (node, pl_call (g_next (node)));
	if (!is_object_or_value (g_next (node))) {
	   error ("Cannot take a slice from non-value/object\n");
	   return NULL;
	}

	return node;
}

/*
 *	td_n_indexing
 */
static
ac	td_n_indexing (node)
ac	node;
{
	ac	t1,
		t2,
		t3,
		t4;
	int	dim	= 0;

	if (node == NULL)
	   return NULL;

	ASSERT (g_d (node) == XINDEXING, ("td_n_indexing"));

	t4 = td_n_name (g_next (node));	/* left sub tree		*/
	if (t4 == NULL)
	   return NULL;

	t4 = pl_call (t4);
	t1 = g_types (g_next (node));
	t1 = get_arraytype (t1);

	ASSERT (t1 != NULL, ("td_n_indexing: 2"));

	FORALL (t2, g_farg (node)) {
	   dim ++;
	   t3 = get_indextype (t1, dim);

	   ASSERT (t3 != NULL, ("only valid arrays expected"));
	   if (!solve_expr (t2, t3)) {
	      error ("indexing: error in index type");
	      return NULL;
	   }
	}

	insert_all (node, t4);
	if (!is_object_or_value (g_next (node))) {
	   error ("Cannot index in non-value/object\n");
	   return NULL;
	}
	return node;
}

static
ac	m_actl (l)
ac	l;
{
	ac	t,
		n;

	if (l == NULL)
	   return NULL;

	n = g_next (l);
	if (g_d (l) != XNAMEDASS) {
	   s_next (l, NULL);
	   l = mk_namass (NULL, l);
	}

	s_next (l, m_actl (n));
	return l;
}

static
ac	td_n_call (node)
ac	node;
{
	ac	t,
		t1,
		t2,
		t3;
	ac	temp,
		form,
		act,
		type;

	int	pos = 0;

	if (node == NULL)
	   return NULL;

	ASSERT (g_d (node) == XCALL || g_d (node) == XENTRYCALL, ("td_n_call"));

	s_fact (node, m_actl (g_fact (node)));
	t1 = g_next (node);	/* caller			*/

	if (t1 == NULL)
	   return NULL;		/* cannot happen		*/

	s_types (t1, red_tripset (g_types (t1), g_types (node)));
	pr_tripels (g_types (t1));

	t3 = g_types (t1);
	FORALL (act, g_fact (node)) {
	   if (is_positional (act)) {
	      pos ++;
	      form = get_pformal (t3, pos);
	      s_parname (act, form);
	   }
	   else
	   { form = get_formal (t3, g_parname (act));
	     del_tag (g_parname (act));
	     s_parname (act, form);
	   }

	   type = type_of (form);

	/* t1 is a CALL-like node, since the function has parameters
	 * we take over the type of the specified subprogram
	 * This, somewhat strange behaviour is essential in case
	 * in a function call an actual universal type is used
	 * to indicate the actual parameter type and a formal
	 * universal type is used for the formal parameter.
	 * The type with which the actual parameter is to be solved
	 * is then the resulting function type
	 */
	   if (is_anytype (type) && type == rettype (t1))
	      type = g_types (node);
	   else
	   if (eq_types (g_triptype (t3), type))
	      type = g_tripdtype (t3);

	   if (!solve_expr (g_nexp (act), type)) {
	      error ("error in actual parameter for %s", tag_of (form));
	      return NULL;
	   }
	}

	/* make actuals nice and complete		*/

	/*
	 * If the node is an entry call, be sure that what is
	 * called is a reasonable object
	 */
	if (g_d (node) == XENTRYCALL)
	   if (!is_taskobject (g_next (node)))
	      error ("Calling entry rather than task_object. entry %s",
					g_tag (g_e_entry (node)));

	if (g_d (node) == XCALL)
	   if (!is_subprogram (g_next (node)))
	      error ("called entity is not suitable subprogram %s",
				        name_tag (g_next (node)) );
	/*
	 * Nevertheless, carry on
	 */
	s_fact (node, act_list (f_formal (t3),
					g_fact (node) ));

	/* replace the triple in the left subtree node	*/
	/* by the type it stands for			*/
	if (g_d (t3) == XTRIPLE) {
	   s_types (t1, g_tripsub (t3));
	}

	/* Finally, compute the function		*/
	t2 = repl_func (node);
	return t2;
}


/*
 *	given a name construction n, get a decent tag
 *	Only used for error messages
 *	Just a local function
 */
static
char	*name_tag (n)
ac	n;
{	while (TRUE) {
	   if (n == NULL)
	      return "no tag";

	   if (has_tag (n))
	      return tag_of (n);

	   switch (g_d (n)) {
	      case XALL:
	      case XSELECT:
	      case XATTRIBUTE:
	      case XCALL:
	      case XENTRYCALL:
	      case XINDEXING:
	         n = g_next (n);
	         break;

	      case XNAME:
	         n = g_fentity (n);
		 if (g_d (n) == XSET)
	            n = first (n);
	         break;

	      default:
	         return "no tag";
	   }
	}
}

/*
 *	Solve expression (high-level call)
 */
ac	SOLVE_EXPR (e, t, s)
ac	e;
ac	t;
char	*s;
{
	if (e == NULL) {
	   return NULL;
	}

	e = solve_expr (e, t);
	if (e == NULL) {
	   error (s);
	   return NULL;
	}
	return e;
}


/*
 *	solve_expr (x, y)
 *	try to solve expression x in context y
 */

ac	solve_expr (e, ct)
ac	e;
ac	ct;
{
	ac	t1,
	        t2;

	if (e == NULL)
	   return NULL;

	if (ct == NULL) {	/* and e != NULL		*/
	   error ("Cannot solve expr in empty context	");
	   return NULL;
	}

	s_exptype (e, td_reduce (ct, g_exptype (e)));
	if (g_exptype (e) == NULL) {
	   error ("type error in expression");
	   return NULL;
	}

	if (!is_singleton (g_exptype (e))) {
	   error ("expression type not unique");
	   print_names (g_exptype (e));
	   return NULL;
	}

	if (is_anytype (g_exptype (e)) && !is_anytype (ct)) {
	   s_exptype (e, ct);	/* Actually, a compatibility check	*/
	}

	return td_expr (e);
}

/*
 *	td_assign
 */
ac	td_assign (x)
ac	x;
{
	ac	lhs;
	ac	rhs;

	char *hulptag;

	if (x == NULL)
	   return NULL;
	ASSERT (g_d (x) == XASSIGN, ("checking XASSIGN"));

	lhs = g_lhs (x);
	rhs = g_rhs (x);

	if (lhs == NULL) {
	   error ("Error in left hand side assignment");
	   return NULL;
	}

	if (rhs == NULL) {
	   error ("Error in right hand side assignment");
	   return NULL;
	}

	ASSERT (g_d (rhs) == XEXP, ("assign rhs XEXPR"));
	ASSERT (is_name (lhs), ("assign lhs"));

	hulptag = name_tag (lhs);

	if (is_anytype (g_exptype (rhs))) { 	/* actual anytype	*/
	   ac t = reduce (g_exptype (rhs), g_types (lhs));
	   if (is_someinteger (t))
	      s_exptype (rhs, base_type (t));
	   else
	     s_exptype (rhs, t);
	}
	else
	   s_exptype (rhs, propagate (g_types (lhs), g_exptype (rhs)));

	if (g_exptype (rhs) == NULL) {
	   ac lhs_type = base_type (first (g_types (lhs)));
	   error ("Incompatible left/right hand sides in assign (%s lhs type)",
                                                   tag_of (lhs_type));
	   return NULL;
	}
	if (!is_singleton (g_exptype (rhs))) {
	   error ("Ambiguous types in assignment (a.o %s)",
		             tag_of (base_type (first (g_exptype (rhs)))));
	   print_names (g_exptype (rhs));
	   return NULL;
	}

	rhs = td_expr (rhs);
	if (rhs == NULL)
	   return NULL;
	lhs = td_name (lhs, g_exptype (rhs));
	if (lhs == NULL)
	   return NULL;

	if (!is_assignable (lhs)) {
	   error ("Attempt to assign to non-assignable type/object (%s)\n",
                   hulptag);
	   return NULL;
	}
	s_lhs (x, lhs);
	s_rhs (x, rhs);

	return x;
}

