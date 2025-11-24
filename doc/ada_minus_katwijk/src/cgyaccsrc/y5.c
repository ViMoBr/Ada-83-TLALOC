
#include "prep.h"
#include "dextern"
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
	register int i = 0;
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

