#
/*
*	TRACE and BREAK command file
*/

/*
#define DEBUG
*/

/*
 *	include files
 */

#include "debug.h"
#include "mode.h"
#include "context.h"
#include <ctype.h>

BODY_P first_body(), next_body();
char *body_name();

/*
 * 	general TRACE/BREAK/DELETE command and mode
 */

set(these)
int these;
{
	int who_am_i;

	mode((who_am_i = these));
	for (;;) {
		switch (command()) {
			case 'a' :	/* after */
				after();
				break;
			case 'b' :	/* break */
				if (who_am_i == BREAK)
					continue;
				mode ((who_am_i = BREAK));
				break;
			case 'c':
				ccommand("calls");
				report(these,CALLS);
				break;
			case 'd' :	/* delete */
				if (who_am_i == MY_DELETE)
					continue;
				mode((who_am_i = MY_DELETE));
				break;
			case 'e' :	/* exceptions */
				ccommand("exceptions");
				report(these,EXPNS);
				break;
			case 'h' :	/* help */
				help();
				break;
			case 'l':
				ccommand("lines");
				report(these,LINES);
				break;
			case 'm' :  	/* menu */
				toggle();
				break;
			case 'q' :	/* quit */
				if (cur_body != &bodylist)
					set_break(cur_body->b_event[LINES]);
				quitflg=TRUE;
				return TRUE;
			case 's' :
				if (who_am_i != BREAK) {
					illegal();
					break;
				}
				ccommand("show");
				report(SHOW,LINES);
				break;
			case 't' :	/* trace */
				if (who_am_i == TRACE)
					continue;
				mode((who_am_i = TRACE));
				break;
			case 'u' :	/* use */
				use_unit();
				break;
			case 'w'  : 	/* with */
				with();
				break;
			case '\n' :     /* return */
				if (cur_body != &bodylist)
					set_break(cur_body->b_event[LINES]);
				return TRUE;
			case 4   :	/* control-d */
				bye();
				break;

			case 12	 :
				clrdisplay ();
				break;

			default:
				illegal();
				break;
		}
	}
	
}


/*
 *	report() sets trace or breakpoints at subprogram 
 *	calls or package body elaborations
 */

report(this,event)
int this,event;
{
	register char *name,*save,last;
	register BODY_P body;
		 int	i;

	if (c_mode -> mode_flag == TRUE)
	    clrmenu ();
	for (;;) {
		prompt("enter name ");
		name=inline();
		resetcrs ();
		if (*name=='\0')	/* leave */
			break;

		/* do some simple syntax checking */
		if (*name == '.') {
			sysdb_error("unit name missing before . ");
			continue;
		}
		for (save=name;*save;save++)
			;
		if (*(--save) == '.') {
			sysdb_error("body name missing after . ");
			continue;
		}
		mark_unit(name,this,event);
#ifdef DEBUG
for (body = first_body (&bodylist); body; body = next_body (body))
{
    fprintf (stderr, "name %s c %d l %d e %d\n", body_name (body), body -> b_event[CALLS], body -> b_event[LINES], body -> b_event[EXPNS]);
}
#endif
	}
        if (c_mode -> mode_flag == TRUE)
	    menu (c_mode -> mode_name);
}

/*
 *	mark_unit() will determine which unit should be noted
 */

mark_unit(name,this,event)
register this,event;
register char *name;
{
	register BODY_P body;
	char last,*save;
	int  i, status, clun;

#ifdef DEBUG
fprintf (stderr, "mark_unit name %s\n", name);
#endif
	for (save=name;(*save != '.') && *save;save++)
			;
	last = *save; *save='\0';

	/* test for special symbols ( ! , # , ? or \*) */
	if (equal(name,"!")) {
		body=st_current;
		goto mark;
	}
	if (equal(name,"#")) {
		if (cur_body != &bodylist)
		{
		   body = cur_body;
		   while (body -> b_lup != &bodylist &&
			  body -> b_lup -> b_bodylun == cur_body -> b_bodylun)	/* seach for top level of library unit */
			 body = body -> b_lup;
#ifdef DEBUG
fprintf (stderr, " # name %s\n", body_name (body));
#endif
		}
		else {
			sysdb_error("# not allowed now ");
			return ;
		}
		goto mark;
	}
	if (equal(name,"$")) {
		if (cur_body != &bodylist)
			body=cur_body;
		else {
			sysdb_error("$ not allowed now ");
			return;
		}
		goto mark;
	}
	if (equal(name,"*")) {
		if (last) {
			sysdb_error("names after * not allowed ");
			return;
		}
		mark_tree (&bodylist, this,event);
		/* reset top level,because it is outside any body */
		bodylist.b_event[event] = MY_DELETE;
		return;
	}

	/* no special unit name */
	for (body = bodylist.b_ldown; body; body = body -> b_lnext)
	    if (equal (name, body_name (body)))
	       break;
	if (body == 0)
	{
		sysdb_error("body %s not with program ",name);
		return;
	}

	mark :
		if (last == 0)
		    body -> b_event[event] = this;
		else {
			status = FALSE;
			mark_bodies (body, ++save, this, event, &status);
		}
}

/*
 *	mark_bodies() searches the tree with root body for the body
 *	with name "subname" and notes the event in the body and its subtree.
 */

mark_bodies (body, subname, this, event, status)
register BODY_P body;
register char *subname;
register int this,event,*status;
{
	char *save,hold[50],*reset;

#ifdef DEBUG
fprintf (stderr, "mark_bodies: subname %s bodyname %s\n", subname, body_name (body));
#endif
	/* period in subname */
	reset = subname;
	save = hold;
	while ((*reset != '.') && *reset)
		*save++ = *reset++;
	*save = '\0';

	if (*reset == '.') {	/* yes, period */
		for (body=body->b_ldown;body;body=body->b_lnext) 
			if (equal (body_name (body), hold)) {
				mark_bodies (body, ++reset, this, event, status);
				*status = TRUE;
				return;
			}
	}
	else {
		if (equal(hold,"*")) {
			mark_tree (body, this, event);
			body->b_event[event] = this;
			*status = TRUE;
			return;
		}
		for (body=body->b_ldown;body;body=body->b_lnext)
			if (equal (hold, body_name (body)))
			{
			    body->b_event[event]=this;
			    *status = TRUE;
			    return;
			}
	}
	if (!*status)
		sysdb_error("cannot find name part %s of specified name",subname);
}


/*
 *	mark_tree() recursively marks the subtree with root body.
 */

mark_tree(body,this,event)
register BODY_P body;
register int this,event;
{
#ifdef DEBUG
fprintf (stderr, "mark tree body %s\n", body_name (body));
#endif
	body -> b_event[event] = this;
	body = body -> b_ldown;
	for (body = first_body (body); body; body = next_body (body))
	{
	    body->b_event[event]=this;
	}
}


