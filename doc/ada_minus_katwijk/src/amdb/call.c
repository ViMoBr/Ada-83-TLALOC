#

/*
 *	routines controlling context of subprogram or package bodies
 */

/*
 *	include files
 */

#include "debug.h"
#include "context.h"
#include "ptrace.h"

/*
 *	definitions
 */

#define		MAXFREE		3
#define		MAXHISTORY	15

/*
 *	structures
 */

static BLOCK		xxx;
static BODY_P		call_history[MAXHISTORY];

static BLOCK		*cur_block;
static BLOCK		*first_block = &xxx;
static BLOCK		*last_block  = &xxx;

/*
 *	scalars
 */

int		nr_stacked;
int		last_stacked;

int		nr_allocated;
int		nr_blocks;
struct call_block start_call = { 0, &bodylist};
CALL		active = &start_call;

int *pc();

/*
 *	pr_stack() gives a history of subroutine calls
 */

pr_stack()
{
	register struct call_block *body;
	register short lines = 2;
	char	c;

	ccommand("stack");
	resetcrs();
	fprintf(stderr,"\n\nSubprogram calls :\n\n");
	for (body=active;body;body=body->c_prev) {
		if (lines == (24 - size_display)) {
			rev_video("MORE");
			c = fgetc(stdin);
			clrline(24);
			if (c == 'q')
				return;
			lines = 0;
		}
		lines++;
		pr_name(body->c_body);
		newline();
	}
	newline();
	savecrs();
}

/*
 *	body_entry() is called on entry of a subprogram or package body.
 */

body_entry(event)
int event;
{
	 struct call_block *call;

/*
fprintf ( stderr, "in body_entry");
*/

	switch ( action(event) ) {
		case BREAK :
			breakflg = TRUE;
		case TRACE :
			switch (event) {
			  case SUB_ENTRY :
				fprintf(stdout,"\ncall of subprogram ");
				break;
			  case PACK_ENTRY :
				fprintf(stdout,"elaborating package ");
			}
			pr_name(cur_body);
			newline();
		case MY_DELETE :
			if (!stepflg)
				set_break(cur_body->b_event[LINES]);
			if (!breakflg && !intflg)
				proceed(CONTINUE);
			break;
	}
	push_call();
	mark_call();
}


/*
 *	body_exit() is called on exit of a subprogram or package body.
 */

body_exit(event)
int event;
{
	struct call_block *x;

	switch ( action(event) ) {
		case BREAK :
			breakflg=TRUE;
		case TRACE :
			switch (event) {
			  case SUB_EXIT :
				fprintf(stdout,"\nexit of subprogram ");
				break;
			  case PACK_EXIT :
				fprintf(stdout,"elaborated package ");
			}
			pr_name(cur_body);
			newline();
		case MY_DELETE :
			if ((x = active -> c_prev))
				if (!stepflg)
					set_break (x -> c_body -> b_event[LINES]);
			if (!breakflg && !intflg)
				proceed(CONTINUE);
			break;
 	}

	pop_call();
}

action(event)
int event;
{
	if (stepflg)
		if (--nr_steps == 0) {
			stepflg = FALSE;
			return ( BREAK );
		}
		else {
			if ((event == SUB_ENTRY) || (event == PACK_ENTRY))
				set_break(BREAK);
			return ( MY_DELETE );
		}
	else
		return (cur_body->b_event[CALLS]);
}


clr_stack()
{
	while (last_block != first_block) {
		last_block = last_block->b_block;
		free(last_block->f_block);
	}
	nr_allocated = 0;
	first_block->f_block = 0;
	cur_block = first_block;
	nr_blocks = 1;
	active = &start_call;

	last_stacked = -1;
	nr_stacked = 0;
}

push_call()
{
	CALL		call;

	if (nr_allocated == MAXCALLS)
		new_block();
	call = &cur_block -> calls[nr_allocated++];
	call->c_prev = active;
	call->c_body = cur_body;
	active = call;
}

pop_call()
{
	if (nr_allocated == 0)
		free_block();
	nr_allocated--;
	active = active -> c_prev;
}

new_block()
{
	if (cur_block->f_block == 0)
		alloc_block();
	nr_blocks--;
	cur_block = cur_block->f_block;
	nr_allocated = 0;
}

free_block()
{
	cur_block = cur_block->b_block;
	if (nr_blocks == MAXFREE)
		dealloc_block();
	nr_blocks++;
	nr_allocated = MAXCALLS;
}
alloc_block()
{
	last_block->f_block = (struct block *)malloc(sizeof(struct block));
	last_block->f_block->b_block = last_block;
	last_block = last_block->f_block;
	last_block->f_block = 0;
	nr_blocks++;
}

dealloc_block()
{
	last_block = last_block->b_block;
	free(last_block->f_block);
	last_block->f_block = 0;
	nr_blocks--;
}

mark_call()
{
	cur_body->b_calls++;
	last_stacked = (last_stacked + 1) % MAXHISTORY;
	nr_stacked = (nr_stacked == MAXHISTORY ? MAXHISTORY : nr_stacked + 1);
	call_history[last_stacked] = cur_body;
}

pr_history()
{
	int 	i,j;

	ccommand("last");
	resetcrs();
	newline();
	fprintf(stderr,"last %d calls (most recent first) :",MAXHISTORY);
	newline();newline();
	for (i = 0;i < nr_stacked;i++) {
		j = last_stacked -i;
		j = (j < 0 ? MAXHISTORY + j : j);
		pr_name(call_history[j]);
		newline();
	}
	savecrs();
}
