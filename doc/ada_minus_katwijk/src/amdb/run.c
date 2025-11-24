/*
 *	routines for controlling a process during runtime
 */

/*
#define DEBUG
*/

#define MAX_ARGS 20
#define ARG_SPACE 256

/*
 *	include files
 */

#include "debug.h"
#include "ptrace.h"
#include "context.h"
#include "mode.h"
#include <signal.h>
#include <ctype.h>

/*
 *	structures
 */

struct db_syms db_syms[] =
{
	{ ""}
};
/*
 * Index values for db_syms structure
 */

struct deb_symbol breaks[] = {

	{	"line_no",	LINE_BREAK	},
	{	"line_break",	LINE_BREAK	},
	{	"sub_entry",	SUB_ENTRY	},
	{	"sub_exit",	SUB_EXIT	},
	{	"pack_entry",	PACK_ENTRY	},
	{	"pack_exit",	PACK_EXIT	},
	{	"_db_except",	EXCEPTION	},
	{	"",		NO_EVENT	}
};


struct tim_buf {	/* time buffer */
	long p_u_t;
	long p_s_t;
	long c_p_t;
	long c_u_t;
} proctim[2];




/*
 *	scalars/pointers
 */

int			pid;		/* process id of running process */
int			lineflag;
int			breakflg;	
int			contextflg;
int			stepflg;
bool			status;
long			nr_steps;

struct deb_symbol	*break_point;

BODY_P			cur_body;
BODY_P			prev_cur_body;
CALL			active;

/*
 *	RUN command and mode
 */

run(r_mode)
{
	rmprompt();
	mode(RUNMODE);
	execute(r_mode);
	do
		main_loop();
	while (!leavemode());
}

execute(mode)
int mode;
{
	if (mode==STEP)  {
		stepflg=TRUE;
		set_break(BREAK);
	}
	else {
		stepflg=FALSE;
		if (pid && (cur_body != &bodylist) && cur_body)
			set_break(cur_body->b_event[LINES]);
	}
	start(&x);
}

/*
 *	main_loop() waits for an event, depending on the event and the
 *	user requests it prints some status indications and returns
 */

main_loop()
{
	int event;

	if (dowait(&pid)) {
		event=find_event();
		if (event==NO_EVENT) {
			state("aborted    ");
			ptrace(STOP,pid,0,0);
			return;
		}
		do_break(event);
		if ((!breakflg) && (!intflg)) 
			return;
		savecrs();
		if (breakflg) {
			state("break      ");
			intflg=FALSE;	/* just in case */
			breakflg=FALSE;
		}
		else {
			state("interrupted");
			intflg=FALSE;
		}
	}
	in_body(cur_body);
	runcommand();
}


/*
 * enter arguments for execution
 */

char **
args (s)
char *s;
{
    static char *argp[MAX_ARGS], arg_space[ARG_SPACE];
    char *data;
    short i, j, len;

    j = 0;
    argp[0] = s;	/* voeg filenaam toe als eerste argument */
    for (i = 1; i < MAX_ARGS; i++)
    {
	prompt ("argument ");
	printf ("%d :", i);
	data = inline ();
	if (*data == '\0')
	    break;
	len = strlen (data) + 1;
	if (len + j >= ARG_SPACE)
	{
	    sysdb_error ("argument space exhausted");
	    break;
	}
	strcpy (&arg_space[j], data);
	argp[i] = &arg_space[j];
	j += len;
    }
    settty ();
    argp[i] = '\0';
    return argp;
}


/*
 *	start a program 
 */

start(unit)
LUN *unit;
{
	contextflg = FALSE;
	if (pid) {	/* continue program */
		proceed(RESET);
		return TRUE;
	}

	/* fork and execl process */

	note_time();
	clr_stack();
	clr_counts();
	prepare(breaks);
	sym_addrs (db_syms);
	closefile();
	if ((pid=fork())==0) {
		ptrace(STRACE,0,0,0);
		signal(SIGINT,SIG_IGN);
		execv (exec_name (unit), args (exec_name (unit)));
		exit(100);
	}
	/* set some flags */
	lineflag=TRUE;
	intflg=FALSE;
	breakflg = FALSE;
	cur_body = &bodylist;
	entrywait (&pid,breaks);
	openfile (exec_name (unit));
	return TRUE;
}

/*
 *	execute commands in run mode
 */

runcommand()
{
	for (;;) {
		switch(command()) {
			case 'a' :	/* after */
				if (after()) {
					execute(STEP);
					return;
				}
				break;
			case 'b' : 	/* break */
				set(BREAK);
				if (quitflg)
					return;
				mode(RUNMODE);
				break;
			case 'c' :
				rmprompt();
				nr_steps = 1;
				execute(STEP);
				contextflg = TRUE;
				return;
			case 'd' :	/* delete trace/break points */
				set(MY_DELETE);
				 if (quitflg)
					return;
				mode(RUNMODE);
				break;
			case 'e' :	/* exit */
			case 4   :      /* control-d */
				bye();
				break;
			case 12  :
				clrdisplay ();
				break;

			case 'h' : 	/* help */
				help();
				break;
			case 'k' : 	/* kill */
				kill();
				break;
			case 'm' :	/* menu */
				toggle();
				break;
			case 'p' :	/* print */
				printmode();
				if (quitflg)
					return;
				mode(RUNMODE);
				break;
			case 'q' :	/* quit */
				quitflg=TRUE;
				return;
			case 'r' :	/* run */
				rmprompt();
				execute(CONTINUE);
				return;
			case 's' : 	/* step */
				rmprompt();
				nr_steps=1;
				execute(STEP);
				return;
			case 't' :	/* trace */
				set(TRACE);
				if (quitflg)
					return;
				mode(RUNMODE);
				break;
			case '\n' :	/* return */
				returnflg=TRUE;
				return;
			default  : 	/* illegal */
				illegal();
				break;
		}
	}
}


/*
 *	KILL command
 */

kill()
{
	if (pid) {
		ptrace(STOP,pid,0,0);
		dowait(&pid);
		pid=0;
		state("killed     ");
	}
}


/*
 *	proceed with the program by stepping through the breakpoint
 *	or continue, depending on the parameter.
 */

proceed(this_far)
int this_far;
{
	register union address *upc;

	switch(this_far) {
		case STEP :
			upc= &break_point->deb_address;
			ptrace(WRINS,pid,upc->whole,(short) break_point->deb_ins);
			ptrace(STEP,pid,(int *) 1,0);
			dowait(&pid);
			ptrace(WRINS,pid,upc->whole,(short) BPTRAP);
			break;
		case RESET :
			state("running    ");
			clrfrom(2,40);
			resetcrs();	/* and fall through */
		case CONTINUE :
			resettty();
			ptrace(CONTINUE,pid,(int *) 1,0);
			break;
	}
}



/*
 * 	pc() returns the program counter
 */

int *pc()
{
	union address upc;
	long userpc = USERPC;


	upc.byte.low=(short) ptrace(RDREG,pid,userpc,0);
	upc.byte.high=(short) ptrace(RDREG,pid,userpc - 2,0);
	return( (int *)upc.whole);
}

/*
 *	set_break() sets the line_break if possible
 */

set_break(at)
int at;
{
	if (!pid || (cur_body == &bodylist))
		return;
	if (((at != MY_DELETE) && (lineflag != MY_DELETE)) 
		|| ((at == MY_DELETE) && (lineflag == MY_DELETE)))
		return;
	set_line(at);
}

set_line(at)
int at;
{
	short mach_code;

	mach_code=(at != MY_DELETE? (short) BPTRAP : (short) breaks[1].deb_ins);
	ptrace(WRINS,pid,breaks[1].deb_address,(short) mach_code);
	lineflag=at;
}

/*
 *	line_no() will return the executed line number
 */

line_no()
{
	return ptrace (RDDATA, pid, breaks[0].deb_address .whole, 0);
}

/*
 * pt_integ returns 32 bits value on addr of the traced proces
 */

pt_integ (addr)
int addr;
{
	union address line;	/* dirty way to access an integer */

	line.byte.low=(short)  ptrace(RDDATA,pid, addr + 2,0);
	line.byte.high=(short) ptrace(RDDATA,pid, addr,0);
#ifdef DEBUG
	fprintf (stderr, "address(o) %o int val: %d (x) %x\n", addr, line.whole, line.whole);
#endif
	return(line.whole);
}


/*
 * 	find out which event/breakpoint occurred
 */

find_event()
{
	register int *brk;

	brk=pc();
	for (break_point=breaks;*break_point->deb_name;break_point++)
		if ( (int *)break_point->deb_address.whole==brk)
			break;
	return(break_point->deb_event);
}


/*
 *	do_break() will call the necessary routines to store
 *	and to report the associated event.
 */

do_break(event)
int event;
{
	/* always step through this breakpoint */
	proceed(STEP);
	
	/*
	 * check for each break in which body it occurs,because not only
	 * explicit changes are possible.
	 */
	prev_cur_body = cur_body;
	tree_search (pc ());
	switch(event) {
		case LINE_BREAK :
			line_break();
			break;
		case SUB_ENTRY :
		case PACK_ENTRY :
			body_entry(event);
			break;
		case SUB_EXIT :
		case PACK_EXIT :
			body_exit(event);
			break;
		case EXCEPTION :
			exception();
			break;
	}
}



/*
 *	exception() handler
 */

exception()
{
	switch (prev_cur_body->b_event[EXPNS]) {
		case BREAK :
			breakflg=TRUE;
		case TRACE :
			printf ("\nexception raised in ");
			pr_name (prev_cur_body);
			printf ("\nhandler invoked in ");
			pr_name (cur_body);
			newline();
		case MY_DELETE :
			if (!breakflg)
				proceed(CONTINUE);
			break;
	}
	/*
	 *look for last occurrence of cur_body in the call structure
	 */
	while (1)
	{
	  if (cur_body == active -> c_body)
	      break;
	  pop_call ();
	}
}

/*
 *	dowait returns TRUE if and only if the signal 
 *	indicates a breakpoint.
 */

dowait(pid)
int *pid;
{
	int	signal;
	int	pcs;
	int 	status;

	if (!*pid)
		return FALSE;
	while ((pcs=wait(&status)) != *pid)
		;


	if ((status & 0177400) == 100) {
		*pid=0;
		sysdb_error("cannot start program");
		return FALSE;
	}
	signal=status & 0377;
	if (signal & 0200) {
		state("core dump  ");
		*pid=0;
		return FALSE;
	}

	switch (signal) {
		case 0177 :
			return TRUE;
		case    0 :
			pr_time();
			lineclose();
			state("terminated ");	/* and fall through */
		default :
			*pid=0;
			return FALSE;
	}
}




/*
 *	EXIT command
 */

bye()
{
	restore();
	display(1);
	resettty();
	closelib(library, &status);
	cls();
	exit(0);
}



/*
 *	AFTER command
 */

after()
{
	register char *c;

	nr_steps=0;
	if (c_mode -> mode_flag == TRUE)
	    clrmenu ();
	ccommand("after");
	for (;;)
	{
	    prompt("enter number ");
	    c=inline();
	    resetcrs ();
	    if (! *c) 
	        break;
	    while (*c)
	    	if (isdigit(*c)) 
	    	    nr_steps= 10*nr_steps + (*c++ - '0');
	    	else 
		{
	            sysdb_error("not a correct number,");
		    nr_steps = 0;
	    	    break;
	    	}
	    if (nr_steps != 0)
		break;
	}
        if (c_mode -> mode_flag == TRUE)
	    menu (c_mode -> mode_name);
	if (nr_steps == 0)
	    return FALSE;
	return TRUE;
}

/*
 *	get process times
 */

note_time()
{
	times(&proctim[0]);
}


/*
 *	print run and control time 
 */

pr_time()
{
	register int minutes,seconds;
	long int t_time;

	/* get times first */

	times(&proctim[1]);

	/* print runtime of debugged process */

	t_time=proctim[1].c_p_t+proctim[1].c_u_t;
	t_time -= (proctim[0].c_p_t+proctim[0].c_u_t);
	minutes=t_time/3000;
	t_time=t_time%3000;
	seconds=t_time/50;
	t_time=(t_time%50)/2;
	printf ("\n\nrun time %d minutes, %d seconds, %d centiseconds",
			minutes,
			seconds,
			(int) t_time);
	savecrs();
}
