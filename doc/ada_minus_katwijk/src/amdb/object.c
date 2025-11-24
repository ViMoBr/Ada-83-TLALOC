#

/*
 *	routines to print runtime info
 */

/*
 *	include files
 */

#include "debug.h"
#include "mode.h"
#include "context.h"

/*
 *	print command and mode
 */

printmode()
{
	mode(PRINTMODE);
	for (;;) {
		switch ( command() ) {
			case 'a' :
				pr_counts();
				break;
			case 'b' :
				set( BREAK);
				if (quitflg)
					return;
				mode(PRINTMODE);
				break;
			case 'c' :
				pr_context();
				break;
			case 'd' :
				set( MY_DELETE );
				if (quitflg)
					return;
				mode(PRINTMODE);
				break;
		        case 12	 :
			       clrdisplay ();
			       break;
			case 'e' :
			case 4   :
				bye();
			case 'h' :
				help();
				break;
			case 'l' :
				pr_history();
				break;
			case 'm' :
				toggle();
				break;
			case 'q' :
				quitflg = TRUE;
				return;
			case 's' :
				pr_stack();
				break;
			case 't' :
				set( TRACE );
				if (quitflg)
					return;
				mode(PRINTMODE);
				break;
			case '\n' :
				return;
			default :
				illegal();
		}
	}
}

/*
 *	pr_counts() displays the number of calls of each body.
 */

pr_counts()
{
	ccommand("all");
	clrdisplay();
	pr_calls (bodylist .b_ldown);
	savecrs();
}

pr_calls(body)
BODY_P body;
{
	if (body) {
		if (body->b_calls) {
			pr_name(body);
			fprintf(stdout,"-> %d",body->b_calls);
			newline();
		}
		pr_calls(body->b_ldown);
		pr_calls(body->b_lnext);
	}
}

clr_counts()
{
	clr_calls (bodylist .b_ldown);
}

clr_calls(body)
BODY_P body;
{
	if (body) {
		body->b_calls = 0;
		clr_calls(body->b_ldown);
		clr_calls(body->b_lnext);
	}
}
