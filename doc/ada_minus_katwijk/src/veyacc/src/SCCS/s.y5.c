h36184
s 00000/00001/00098
d D 1.4 86/09/05 18:12:21 konijn 4 3
c lint
e
s 00001/00001/00098
d D 1.3 86/08/18 18:51:29 konijn 3 2
c rename includes
e
s 00001/00001/00098
d D 1.2 86/08/18 16:04:42 konijn 2 1
c added sccsid
e
s 00099/00000/00000
d D 1.1 86/08/18 16:00:55 konijn 1 0
c date and time created 86/08/18 16:00:55 by konijn
e
u
U
t
T
I 1
D 2

E 2
I 2
	/* %W%	%E%	*/
E 2
#include "prep.h"
D 3
#include "dextern"
E 3
I 3
#include "dextern.h"
E 3
/*
 * rules:
 *      definitie : attr_def symbol [ ( [[|inputdefs]^outputdefs]) ]
 *
 *      rule : lhs : alternative {|alternative} ;
 *
 *
 *      alternative : [ {member} ] [= action]
 *
 *      member : symbol [ ( [|inputlist][^outputlist]) ]
 *
 */


proc_def ()     /* process a definition */
{
	register struct att_def *curr_def;

	if (tok != ATTR_DEF)
	   return;      /* cannot happen */

	tok = gettok ();
	if (tok != IDENTIFIER)
	   error ("syntax error in attribute definition");

	curr_def = new_def (tokname);

	tok = gettok ();
	if (tok != LPAR)
	   return;

	tok = gettok ();
	if (tok == INPUT)
	   proc_intypes (curr_def);
	if (tok == OUTPUT)
	   proc_outtypes (curr_def);

	if (tok != RPAR)
	   error ("syntax error in definition for %s",
						curr_def -> nonterm);
	tok = gettok ();
	return;
}

proc_intypes (definition)
register struct att_def *definition;
{
D 4
	register int i = 0;
E 4
	if (tok != INPUT)
	   return;      /* cannot happen */

	tok = gettok ();
	while (tok == IDENTIFIER)
	{ set_input (definition, tokname);
	  tok = gettok ();
	  if (tok == RPAR)
	     return;
	  if (tok != ',')
	     error ("syntax error (missing comma) in def %s",
							definition -> nonterm);

	  tok = gettok ();
	}

	if (tok != OUTPUT)
	   error ("syntax error (missing ^) def %s",
						definition -> nonterm);

	return;
}

proc_outtypes (definition)
register struct att_def *definition;
{
	if (tok != OUTPUT)
	   return;      /* cannot happen */

	tok = gettok ();
	while (tok == IDENTIFIER)
	{
	   set_output (definition, tokname);
	   tok = gettok ();
	   if (tok == RPAR)
	      return;
	   if (tok != ',')
	      error ("syntax error (comma expected) def %s",
						definition -> nonterm);

	   tok = gettok ();
	}

	error ("syntax error, identifier expected in def for %s",
						definition -> nonterm);
	return;
}

E 1
