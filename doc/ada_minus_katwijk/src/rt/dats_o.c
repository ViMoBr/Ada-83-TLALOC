
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
 *	Hans Toetenel
 *	Department of Computer Science
 *	Delft University of Technology
 *	julianalaan 132
 *	2628 BL Delft The Netherlands.
 *
 */

#include	<signal.h>
#include	<stdio.h>
#include	"../h/unix.h"
#include	"../h/dats.h"

#ifndef STAND_ALONE
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#endif



/**************************** constant definitions *********************/
#define	FOREVER		1
#define	OFF	0
#define ON	1

/*
 *	task states
 */

#define	CREATED			0
#define	RUNNING			1
#define	TERM_AT			2
#define	TERMI			3
#define	COMPLETED		4
#define TERM_ON_CREATION	5
#define	SHURE_TERM_AT		6
#define	NOWHERE			7
#define IN_AGENDA		8
#define	ENGAGED			9

/*
 *	events
 */

#define	TIMER_EVENT		01
#define	TERM_EVENT		02
#define	ENDRDV_EVENT		04
#define	TASKERR_EVENT		010
#define	ACTIV_EVENT		020
#define	TO_BE_ENGAGED		040
#define	KILL_EVENT		0100

#define ALL	01|02|04|010|020|040|0100
#define NONE	0

#define CLOCK_TICK	-1
#define	TIME_SLICE	1

#define	MAX_NEST	3
#define	MAX_PRIO	8

#ifdef TTRACE
#define	CREATE_TD		 0
#define	ACTIVATE		 1
#define	NEW_MASTER		 2
#define	LEAVE_MASTER		 3
#define	TERMINATE		 4
#define	LOCK			 5
#define	UNLOCK			 6
#define	QUEUE			 7
#define	DEQUEUE			 8
#define	CHAIN			 9
#define	DECHAIN			10
#define	REMOVE			11
#define	DECHNCLOCK		12
#define	WAIT			13
#define	SSIG			14
#define	CHECK_TERM		15
#define	CALL_RDV		16
#define	SET_ALTDESC		17
#define	START_RDV		18
#define	SET_PRIORITY		19
#define	END_RDV			20
#define	CLOCK			21
#define	CLOCK2			22
#define	RESTART			23
#define	MAIN_TD			24
#define	CHECK_ACTIVATE		25
#endif

/**************************** macro definitions ************************/

#define	ASSERT(x,y)	if (!(x)) { lock (); printf y;		\
				unlock ();			\
				fflush (stdout);abort (); }
#define	CRAISE(x)	{printf ("raised %s\n",			\
		(x== 0 ? "Storage error" 		        \
		       : (x==1 ? "Tasking error"		\
			       : "Program error"))		\
						); abort ();}

#define	agenda(i)		&(_agenda [i])
#define	empty_queue(x)		((x)-> first == (tdp)NULL)
#define is_in_agenda(x)		(x -> info.situation == IN_AGENDA)
#define set_in_agenda(x)	x -> info.situation = IN_AGENDA
#define set_out_agenda(x)	x -> info.situation = NOWHERE
#define in_engaged(x)		(x -> info.situation == ENGAGED)
#define set_engaged(x)		x -> info.situation = ENGAGED
#define set_unengaged(x)	x -> info.situation = NOWHERE
#define	set_sigs(x,y)		x -> info.waited_for = y
#define set_my_sigs(y)		set_sigs (myself,y)
#define	set_sig(x,y)		x -> info.waited_for |= y
#define reset_sig(x,y)		if (waiting_for (x,y)) x -> info.waited_for -= y
#define i_am_waiting_for(x)	(myself -> info.waited_for & x)
#define waiting_for(x,y)	(x -> info.waited_for & y)

#define	i_push(x, v)	*(-- ((tdp)x) -> context. sp) = (long) (v)

/**************************** external functions ***********************/

extern void            chain           (); /* dats.c  (t,c) */
extern void            check_activate  (); /* dats.c  (t) */
extern void            check_terminate (); /* dats.c  (t) */
extern void            clock           (); /* dats.c  () */
extern void            clock2          (); /* dats.c  (old_task) */
extern tdp             dechain         (); /* dats.c  (c) */
extern void            dechnclock      (); /* dats.c  (t) */
extern tdp             dequeue         (); /* dats.c  (c) */
extern void            get_rescheduled (); /* dats.c  () */
extern                 Hard_prio       (); /* dats.c  () */
extern                 HW_lock         (); /* dats.c  () */
extern                 HW_unlock       (); /* dats.c  () */
extern                 pull            (); /* dats.c  () */
extern                 push            (); /* dats.c  (prio) */
extern void            queue           (); /* dats.c  (t,c) */
extern void            remove          (); /* dats.c  (x) */
extern void            restart         (); /* dats.c  (x) */
extern void            set_priority    (); /* dats.c  (p) */
extern void            ssig            (); /* dats.c  (t,code) */
extern int	       swap            (); /* swap.s  (current) */
extern tdp             task_alloc      (); /* dats.c  (t) */
extern void            task_free       (); /* dats.c  (task) */
extern void            unlock          (); /* dats.c  () */
extern void            wait            (); /* dats.c  (h) */


/**************************** structure definitions ********************/

struct _status {
	long	d_reg [8];	/* d registers		*/
	long	*a_reg [7];	/* a registers		*/
	long	*sp;		/* stack pointer	*/
	long	*pc;
};



typedef	struct _status	status;

struct alt_descr {
	long	e_code;
	long	alt_data;
};

typedef struct _link link;

struct _link {
	tdp	first, last;
};


struct _log {
	byte 	curr_prio;
	byte 	lock_level;
	byte 	state;
	byte	situation;
	byte 	activ_error;
	byte	selected_alt;
	byte	rdv_depth;
	byte	chrono;
	byte	entry_nr;
	byte 	activ_cnt;
	short	waited_for;
	short 	activ_event;
};
typedef	struct _log log;

struct td {
	TTDP		tasktype;
    	status		context;
	tdp*		taskobj;
	log		info;
    	tdp		activ_chain;	
    	link		chain;	
    	tdp		clock_chain;
    	tdp		master_chain;
    	tdp		my_father;
    	master_p	master;
    	tdp		eng_head;
    	tdp		eng_tail;
    	long		*parlist;
    	tdp		rdv_stack [MAX_NEST];
#ifdef TTRACE
    	int 		l_acc [100];
#endif
	/* down from here the stack of this task runs	*/
    	long  		st_data  [1];
};




/************** static taskdescriptor for first task *******************/

extern	struct td td_main;

struct tt_tsk ttd_main = {	20,
			 0,
		         0,
		(long *) 0,
		(long *) 0 };


struct td td_main = {
	/* pointer to tasktype 	*/	& ttd_main,
	/* context	d0	*/	(long)	 0,
	/*		d1	*/	(long)	 0,
	/*		d2	*/	(long)	 0,
	/*		d3	*/	(long)	 0,
	/*		d4	*/	(long)	 0,
	/*		d5	*/	(long)	 0,
	/*		d6	*/	(long)	 0,
	/*		d7	*/	(long)	 0,
	/*		a0	*/	(long *) 0,
	/*		a1	*/	(long *) 0,
	/*		a2	*/	(long *) 0,
	/*		a3	*/	(long *) 0,
	/*		a4	*/	(long *) 0,
	/*		a5	*/	(long *) 0,
	/*		a6	*/	(long *) 0,
	/*		a7	*/	(long *) 0,
	/*		pc	*/	(long *) 0,
	/* pointer to taskobject*/	(tdp *)  0,
	/* curr_prio		*/		 0,
	/* lock_level		*/		 0,
	/* state		*/		 0,
	/* situation		*/		 7,
	/* activ_error		*/		 0,
	/* selected alt		*/		 0,
	/* rdv_depth		*/		 0,
	/* chrono		*/	(byte)	 1,
	/* entry_nr		*/		 0,
	/* activ_cnt		*/		 0,
	/* waited_for		*/		 0,
	/* activ event		*/		 0,

	/* activ chain		*/	(tdp)	 0,
	/* chain	first	*/	(tdp)	 0,
	/* chain	last	*/	(tdp)	 0,
	/* clock chain		*/	(tdp)	 0,
	/* master chain		*/	(tdp)	 0,
	/* my_father		*/	(tdp) 	 0,
	/* master		*/ (master_p)	 0,
	/* eng_head		*/	(tdp)	 0,
	/* eng_tail		*/	(tdp)	 0,
	/* parlist		*/	(long *) 0,
	/* rdv stack	00	*/	(tdp)	 0,
	/* rdv stack	01	*/	(tdp)	 0,
	/* rdv stack	02	*/	(tdp)	 0,
#ifdef TTRACE
	/* ==== ONLY FOR DEBUGGING PURPOSES =====*/
	/* l_acc  10 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  20 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  30 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  40 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  50 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  60 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  70 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  80 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc  90 	*/     0,0,0,0,0,0,0,0,0,0,
	/* l_acc 100 	*/     0,0,0,0,0,0,0,0,0,0,
#endif
	/* stack data	*/			 0  };


/***************** hardware dependent stuff ***************************/

Hard_prio ()
{
}

HW_lock ()
{
}

HW_unlock ()
{
}

/* 18 augustus 1987 :
 * Due to some very misty reasons, our clock will not fuctionate
 * any more with the new Unix kernel on the Micro Dutch. 
 * The kernel gets very irritated with alarm calls and
 * Global storaga used for tasks.
 * 
 * Solution: make a great stacksegment, together with some private
 * allocating and disallocating routines.
 * Huge   : 1048576	(1024 * 1024)
 * Large  :  524288	( 512 * 1024)
 * Medium :  131072	( 128 * 1024)
 * Small  :   65536	(  64 * 1024)
 */
#define	_HUGE	1048576
#define _LARGE	524288
#define _MEDIUM	131072
#define _SMALL	65536

#define	_UNIV_STACK_SIZE	_MEDIUM

long _univ_stack_seg_storage [_UNIV_STACK_SIZE];
long *_univ_stack_seg_top    = & _univ_stack_seg_storage [_UNIV_STACK_SIZE];
long *_univ_stack_seg_bottom = & _univ_stack_seg_storage [0];

tdp
t_alloc (amount)
	int amount;
{
	register long *x;
	char * res;
	ASSERT (amount != 0, ("stack storage amount 0\n")); 
	res = _univ_stack_seg_bottom;
/*
	printf ("amount  = %d\n", amount);
	printf ("bottom  = %x %d\n", _univ_stack_seg_bottom, _univ_stack_seg_bottom);
	printf ("top     = %x %d\n", _univ_stack_seg_top, _univ_stack_seg_top);
 */

	if ((_univ_stack_seg_bottom += amount) > _univ_stack_seg_top) {
		printf ("Out of stack space for tasks, call a guru!\n");
		exit (1);
	}
	for (x = res; x <= _univ_stack_seg_bottom; x ++)
	    *x = (char)0;
	return (tdp) res;
}

t_free () 
/* is yet not used, all allocated memory is kept for future uses
 */
{}

/************************ priority stack datatype *********************/

#define	MAX_STACK	020

struct _prio_s {
	int top;
	int data [MAX_STACK];
} prio_stack = {-1,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

push (prio)
int prio;
{
	ASSERT (++ prio_stack.top < MAX_STACK, ("prio_stack overflow !\n"));
	prio_stack.data [prio_stack.top] = prio;
}

pull ()
{
	ASSERT (prio_stack.top > -1, ("try to pop from empty prio_stack"));
	return (prio_stack.data [prio_stack.top--]);
}



/*
 *
 *	D E L F T   A D A   T A S K I N G  S U P E R V I S O R
 *
 *
 */

tdp	clock_head;
int	high_prio	= 0;
int	was_clock	= FALSE;	/* to remember a clock tick	*/
link	_agenda [MAX_PRIO + 1];
	
tdp myself = &td_main;

int clocking	= 0;
int time_slice;

#ifdef TTRACE
tdp	exa_stack [1000];
int	exa_i = 1;
long high_mem;
long histo [1000];
long s_histo [1000];
int task_count = 0;
long stack_use = 0;
long lsu;
int tick_nr;
extern	int tracing;
extern	int simple_tracing;
extern  int swap_tracing;
extern  int trace_dump;
extern	int clock_tracing;
extern	int wait_tracing;
extern	int tick_tracing;
#define	LINK_TRACE	0
#endif

/* mode setter
 * ==========
 *
 * DATS works with two modes, synchrone or asynchone
 *
 * the user may select which mode it is to be
 */

void
set_mode (x)
	int x;
{

	clocking = OFF;

/*
	if (x == SYNCHRONE)
		clocking = OFF;
	else {
		clocking = ON;
		restart (clock);
	}
 */
}

/*
 *	create a task object, take as a parameter the master,
 *	a chain header and a task type descriptor
 */
tdp
create_td (task_obj, t, m, c)
	tdp * task_obj;
	TTDP t;
	master_p m;
	tdp	*c;	/* user provided activation chain header	*/
{
	register int i;
	register tdp	h;
	int stor_size;
	long *a6;

#ifdef TTRACE
	int T_result = s_trace (1,"create_td",CREATE_TD,
				"task_obj",2,task_obj,
				"t", 2, t,
				"m", 1, m,
				"c", 2, *c,
				0);
#endif
	/* locking is required here, altough the granularity may	*/
	/* be somewhat smaller. The idea is to have malloc locked	*/

#ifdef TTRACE
	++task_count;
#endif
	lock ();
	h = task_alloc (t);
#ifdef TTRACE
	exa_stack [exa_i++] = h; 
#endif
	if (h == (tdp) NULL)
	   { unlock ();
#ifdef TTRACE
	     lock ();
	     printf ("high_memory is %d %x\n",high_mem, high_mem);
	     fflush (stdout);
	     i = 0;
	     while (histo [i] != 0)
		printf ("tick = %d tasks = %d\n", i, histo [i++]);
#endif
	     CRAISE (STORAGE_ERROR);
	     exit (1);
	   }
	unlock ();

	/* we got the space, now we are going to initialize it	*/
	h -> taskobj = task_obj;
	/* first set up a stack and a pc			*/
	h -> context. pc = t -> addr;
	h -> context. sp = &(h -> st_data [t -> storsize/ sizeof (int)]);
	h -> tasktype	 = t;
	h -> my_father    = myself;

	/* the son does not has a master entered	*/
	h -> master  = (master_p) 0xFFFF;

	h -> info.rdv_depth = -1;
	/* link in the newly created task in the chain of its master	*/

	h -> master_chain = m -> children;
	m -> slave_cnt ++;
	m -> children = h;

	h -> activ_chain = *c;	/* chain to activate	*/
	*c               = h;

	h -> info.curr_prio   = h ->  tasktype -> prio;

	h -> chain. first	= NULL;
	h -> chain. last	= NULL;

	h -> info.waited_for = NONE;

	set_unengaged (h);

/*
 *	We fake an environment here such that on scheduling
 *	the task, it seems that it had called wait itself
 *	Obviously, the following sequence of statements is highly
 *	target dependent, the stack should look like:
 *
 *	static_link		to access the outer worlds
 *	return address		not used, make it zero
 *	base			not used here, make it zero
 *	dummy			parameter for "wait"
 *	addr			return address for wait is actual start
 *	address former base	base of gefaked stackframe of wait
 *	0			some dummies
 *	0			
 *
 *	Take care that, on exit from wait an unlock is executed,
 *	so increase the local info.lock_level cnt
 */
	h -> info.lock_level ++;
	i_push (h, h ->  tasktype -> st_link);
	i_push (h, 0);
	i_push (h, 0);
	a6 = h -> context.sp;
	i_push (h, t);		/* parameter for start_t */
	i_push (h, 0);
	i_push (h, h ->  tasktype -> addr);
	i_push (h, a6);
	a6 = h -> context.sp;
	h -> context . a_reg [6] = a6;
	for (i = 1; i <= 20; i ++)
		i_push (h, 0);

#ifdef TTRACE
	if (tracing) {
		dump_mtd (h);
	}
	e_trace (1,"create_td");
#endif
	return h;
}

/*
 *	The function of activate is twofold, first notice
 *	the father that the elaboration of the declarative
 *	part of the master of the current thread of control
 *	is completed (second parameter = TRUE),
 *	second, activate all children in the chain x
 */
void
activate (x, f)
register tdp x;
int f;
{
	register tdp c;

#ifdef TTRACE
	int T_result = s_trace (1,"activate",ACTIVATE,
				"x", 2, x,
				"f", 1, f,
				0);
#endif
	if (f) {
	   lock ();
	   myself -> my_father -> info.activ_cnt --;
	   ssig (myself -> my_father, ACTIV_EVENT);
	   unlock ();
	}


	if (x == NULL) {	/* nothing to do really		*/
#ifdef TTRACE
		e_trace (1,"activate");
#endif
	   	return;
	}

	myself -> info.activ_error              = 0;

/*
 *	We start the tasks to get activated by chaining them
 *	in the run-queue (various priorities)
 */
	/* prevent intruders here		*/
	lock ();

	for (c = x; c != NULL; c = c -> activ_chain) {
	      queue (c, agenda (c -> info.curr_prio));
	      myself -> info.activ_cnt ++;
	}



/*
 *	Believe it or not, I'm ready for action
 *	This state will be checked at the terminate procedure
 */
	myself -> info.state = RUNNING;	/* now I'm going	*/

	set_sigs (myself, ACTIV_EVENT|TERM_EVENT|TASKERR_EVENT);
	while (myself -> info.activ_cnt) {
		wait (INFINITE);
		if (myself -> info.activ_event == TASKERR_EVENT)
			myself -> info.activ_error++;
	}
	set_sigs (myself, NONE);
	unlock ();
	/* when we are here, we know for sure that all our children
	 * have been activated
	 */

	if (myself -> info.activ_error)
		CRAISE (13);
#ifdef TTRACE
	e_trace (1,"activate");
#endif
	return;
}

void
new_master (m)
	master_p m;
{
#ifdef TTRACE
	int T_result = s_trace (1,"new_master",NEW_MASTER,
				"m",2,m,
				0);
#endif

	m -> prev_master = myself -> master;
	myself -> master = m;
	m -> slave_cnt = 0;
	m -> children = (tdp) NULL;

#ifdef TTRACE
	e_trace (1,"new_master");
#endif
	
}

/*
 *	A master can only be left when all dependent tasks
 *	have terminated. On entry the task state will
 *	be made completed, on exit the state is made
 *	READY again.
 */
void
leave_master ()
{
#ifdef TTRACE
	int T_result = s_trace (1,"leave_master",LEAVE_MASTER,
				0);
#endif
	register tdp c;
	int	old_state	= myself -> info.state;

	lock ();
	myself -> info.state = COMPLETED;
	set_sigs (myself, TERM_EVENT|TASKERR_EVENT);
	while (myself -> master -> slave_cnt > 0) {
		wait (INFINITE);
	}
	set_sigs (myself, NONE);

	/* when we are here, we know for sure that all our children
	 * have terminated or are terminatable. We send them a signal
	 * so they can take appropriate actions
	 */

	c = myself -> master -> children;
	while (c != NULL)
	   { ssig (c, KILL_EVENT);
	     c = c -> master_chain;
	   }
	myself -> master = myself -> master -> prev_master;
	myself -> info.state = old_state;
	unlock ();
#ifdef TTRACE
	e_trace (1,"leave_master");
#endif
}

/*
 *	It is really simple, all dependent tasks did go already
 */
void
terminate ()
{
#ifdef TTRACE
	int T_result = s_trace (1,"terminate",TERMINATE,
				0);
#endif
	register tdp t;
	lock (); /* I want to be the only one accessing my father */
	if (myself -> info.state == CREATED) {
		myself -> my_father -> info.activ_error ++;
		myself -> my_father -> info.activ_cnt --;
	}

	/* all tasks that are waiting for an evening out with	*/
	/* the current one will be punished for dating a	*/
	/* terminating task					*/
	while (myself -> eng_head != NULL) {
		t = dechain (myself);
	        ssig (t, TASKERR_EVENT);
	}

	unlock ();
	myself -> info.state = SHURE_TERM_AT;
	if (myself -> my_father != NULL) {
		check_terminate (myself -> my_father);
		set_sigs (myself,KILL_EVENT);
		wait (INFINITE);	/* wait for my fathers dead blow */
		set_sigs (myself, NONE);
		myself -> info.state = TERMI;
		task_free (myself); 	/* free dynamic data */
#ifdef TTRACE
		--task_count;
#endif
		wait (INFINITE);	/* I am gone forever */
		ASSERT (TRUE,("task rising from the grave in terminate\n"));
	}
	else {
		/* main task */
#ifdef TTRACE
		e_trace (1,"terminate");
#endif
		return;
	}
}

bool
Terminated (t)
register tdp t;
{
	if ( t != NULL)
	   return t -> info.state == TERMI;

	return TRUE;
}

_genabort (a_t)
register tdp *a_t;
{
	printf ("Love to kill a task (%X)\n", *a_t);
}
bool
Callable (t)
register tdp t;
{
	return t != (tdp) NULL;
}

int	Count (t, e)
register tdp t;
int	e;
{
	register tdp a;
	register int res = 0;
	ASSERT (t != NULL && e != 0, ("Count:1"));
}

_delay (d)
long d;
{
	printf ("Delaying for %d seconds\n", d);
}

void
zombie ()
{
	fprintf (stderr, "Task raising from the grave !\n");
	exit (1);
}


/*
 *************** lock unlock ********************************
 */

void
lock () {
#ifdef TTRACE
	int T_result = s_trace (1,"lock",LOCK,
				0);
#endif
	myself -> info.lock_level ++;
#ifdef TTRACE
	e_trace (1,"lock");
#endif
}

void
unlock ()
{
#ifdef TTRACE
	int T_result = s_trace (1,"unlock",UNLOCK,
				0);
#endif
	myself -> info.lock_level --;
	ASSERT (myself -> info.lock_level >= 0, ("lock error"));

	if (myself -> info.lock_level == 0 && was_clock) {
	   was_clock = FALSE;
	   clock2 (myself);
	}
	if (myself -> info.lock_level == 0)
	   { HW_unlock ();
	     if (myself -> info.curr_prio < high_prio) 
	        get_rescheduled ();
	   }
#ifdef TTRACE
	e_trace (1,"unlock");
#endif
}

/*
 ************** queue/ dequeue *********************************
 */

void
queue (t, c)
register tdp t;
register link *c;
{
#ifdef TTRACE
	int T_result = s_trace (LINK_TRACE,"queue",QUEUE,
				"t", 2, t,
				"c", 2, c,
				0,
				0);
#endif
	lock ();
	 /* if the element is already in the agenda, then do nothing */
	ASSERT (!is_in_agenda (t),("QUEUE ERROR\n"));

	/* empty queue : */
	 if (c -> first == c -> last && c -> first == NULL) {
		c -> first = c -> last = t;
		t -> chain.first = (tdp) NULL;
		t -> chain.last  = (tdp) NULL;
	}
	else {
		/* at least one element in the queue :
		 * put it after it
		 */
		(c -> last) -> chain.last = t;
		t -> chain.first = c -> last;
		t -> chain.last  = (tdp) NULL;
		c -> last = t;
	}
	set_in_agenda (t);
	unlock ();
#ifdef TTRACE
	e_trace (LINK_TRACE,"queue");
#endif
}

tdp
dequeue (c)
link	*c;
{
#ifdef TTRACE
	int T_result = s_trace (LINK_TRACE,"dequeue",DEQUEUE,
				"c", 2, c,
				0);
#endif
	tdp	t;

	lock ();
	t = c -> first;
	ASSERT (t != NULL, ("DEQUEUE ERROR"));

	c -> first = c -> first -> chain. last;
	if (c -> first != NULL)
	   c -> first -> chain. first = (tdp)NULL;
	else
	   c -> last = NULL;

	set_out_agenda (t);
	unlock ();
#ifdef TTRACE
	r_trace (LINK_TRACE,"dequeue", "result = ",2,t);
#endif
	return t;
}

/*
 ************** chain/ dechain *********************************
 */

void
chain (t, c)
register tdp t;
register tdp c;
{
#ifdef TTRACE
	int T_result = s_trace (LINK_TRACE,"chain",CHAIN,
				"t", 2, t,
				"c", 2, c,
				0,
				0);
#endif
	lock ();
	 /* if the element is already engaged, then do nothing */
	ASSERT (!in_engaged (t), ("Element %x already engaged",t));

	/* empty queue : */
	if (c -> eng_tail == (tdp) NULL) {
		c -> eng_tail = t;
		c -> eng_head = t;
		t -> chain.first = c;
		t -> chain.last  = (tdp) NULL;
	}
	else {
		/* at least one element in the queue :
		 * put it after it
		 */
		c -> eng_tail -> chain.last = t;
		t -> chain.first = c -> eng_tail;
		t -> chain.last  = (tdp) NULL;
		c -> eng_tail = t;
	}
	set_engaged (t);
	unlock ();
#ifdef TTRACE
	e_trace (LINK_TRACE,"chain");
#endif
}

tdp
dechain (c)
register tdp	c;
{
#ifdef TTRACE
	int T_result = s_trace (LINK_TRACE,"dechain",DECHAIN,
				"c", 2, c,
				0);
#endif
	tdp	t;


	lock ();
	t = c -> eng_head;
	ASSERT (t != NULL, ("DECHAIN ERROR"));
	c -> eng_head = c -> eng_head -> chain. last;
	if (c -> eng_head == NULL) 
	   	c -> eng_tail = NULL;
	else
		c -> eng_head -> chain.first = c;

	set_unengaged (t);
	t -> chain . first = (tdp) NULL;
	t -> chain . last  = (tdp) NULL;
	unlock ();
#ifdef TTRACE
	r_trace (LINK_TRACE,"dechain", "result = ",2,t);
#endif
	return t;
}


void
remove (x)
tdp	x;
{
	register link *c;
#ifdef TTRACE
	int T_result = s_trace (LINK_TRACE,"remove",REMOVE,
				"x", 2, x,
				0);
#endif
	ASSERT (x != NULL, ("REMOVE ERROR"));
	c = & (x -> chain);
	lock ();
	/* get the element x  out of an engaged chain */
/*
 *	ASSERT (in_engaged (x), ("Try to remove unengaged task %x\n",x));
 */
	if (c -> first -> eng_head == x)
		dechain (c -> first);
	else {
		c -> first -> chain.last = c -> last;
		if (c -> last != (tdp) NULL)
			c -> last -> chain.first = c -> first;
	  	else {
			/* re-adjust the eng_tail of the bearer of this
			 * rdv chain,
			 * so first find the bearer, and then adjust
			 * the eng_tail.
			 */
			register tdp f;
			register link *l;
			f = c -> first;
			l = &(f -> chain);
			while (l -> first -> eng_head != f) {
				f = l -> first;
				l = &(f -> chain);
			}
			/* now l -> first is the bearer,
			 * let's adjust the eng_tail.
			 */
			l -> first -> eng_tail = c -> first;
		}
		set_unengaged (x);
		x -> chain . first = (tdp) NULL;
		x -> chain . last  = (tdp) NULL;
	}
	unlock ();
#ifdef TTRACE
	e_trace (LINK_TRACE,"remove");
#endif
}

void
dechnclock (t)
tdp t;
/*
 *	Search for a given task at the clock queue and remove it
 */
{
#ifdef TTRACE
	int T_result = s_trace (1,"dechnclock",DECHNCLOCK,
				"t", 2, t,
				0);
#endif
	tdp	c;


	lock ();
	if (clock_head == t)
	   clock_head = t -> clock_chain;
	else
	{ c = clock_head;
	  while (1) {
	     if (c -> clock_chain == t) {
	        c = c -> clock_chain;
	        break;
	     }
	     c = c -> clock_chain;
	}

	}
	if (t -> clock_chain != NULL)
	   t -> clock_chain -> info.chrono += t -> info.chrono;
	unlock ();
#ifdef TTRACE
	e_trace (1,"dechnclock");
#endif
}

/*
 *************Signal/Wait*******************************
 *
 *	basic dispatching mechnanism
 *
 *	A task suspends itself by calling wait,
 *	for at least H time units
 *
 */
void
wait (h)
int h;
{
#ifdef TTRACE
	int T_result = s_trace (1,"wait",WAIT,
				"h", 1, h,
				0);
#endif
	int accu;
	register int i;
	tdp	current;
#ifdef TTRACE
	static int swap_id = 0;
#endif

	lock ();	/* no interruptions please	*/

	if (h == 0)
	   ssig (myself, TIMER_EVENT);
	else
	if (h != INFINITE && h != CLOCK_TICK)	/* INFINITE special	*/
	   {
	     set_sig (myself,TIMER_EVENT);
	     if (clock_head == NULL)
	        { clock_head = myself;
	          myself -> clock_chain = NULL;
	          myself -> info.chrono      = h;
	        }
	     else
	     if (clock_head -> info.chrono > h)
	        { myself -> clock_chain = clock_head;
	          clock_head = myself;
	          myself -> info.chrono      = h;
	          myself -> clock_chain -> info.chrono -= h;
	        }
	     else
	     {  current = clock_head;
	        accu    = 0;
	        while (current -> clock_chain != NULL &&
	                     accu + current -> clock_chain -> info.chrono <= h)
	        {
	           accu = accu + current -> clock_chain -> info.chrono;
	           current = current -> clock_chain;
	        }
	        myself -> info.chrono = h - accu;
	        current -> clock_chain -> info.chrono =
	                   current -> clock_chain -> info.chrono - myself -> info.chrono;
	        myself -> clock_chain = current -> clock_chain;
	        current -> clock_chain = myself;
	     }
	}

/*
 *	Here we are properly chained, let's dispatch
 */

	for (i = MAX_PRIO; i >= 0; i--) {
	     if (! empty_queue (agenda (i))) {
	        current = dequeue (agenda (i));
		if (current != myself) {
			/* I must be the only one left to play with,
			 * in this case swapping is only lost time
			 * let's skip it
			 */
#ifdef TTRACE
			swap_id++;
			if (swap_tracing) {
				printf ("\nswap nr %d  to be started ...\n",swap_id);
				printf ("myself = %x\ncurrent = %x\n",myself,current);
				fflush (stdout);
				queue_dump (agenda (i));
				fflush (stdout);
				fflush (stdout);
			}
#endif
	        	swap (current);		/* careful		*/	
						/* the calling task has	*/
						/* disappeared, next	*/
						/* instructions by other*/
#ifdef TTRACE
			if (swap_tracing) {
				printf ("swap nr %d ended ... new proces active now\n",swap_id);
				fflush (stdout);
				fflush (stdout);
			}
#endif
		}
	        myself -> info.chrono = TIME_SLICE;
		if (myself -> info.state != COMPLETED)
			myself -> info.state = RUNNING;
	        Hard_prio (myself -> info.curr_prio);
	        high_prio = myself -> info.curr_prio;
	        unlock ();
#ifdef TTRACE
	e_trace (1,"wait");
#endif
	        return;
	     }
	}

#ifdef TTRACE
	e_trace (1,"wait 1");
#endif
	ASSERT (FALSE, ("\nCannot find task to dispatch\n"));
	fflush (stdout);
}

void
ssig (t, code)
tdp t;
int code;
{
#ifdef TTRACE
	int T_result = s_trace (0,"ssig",SSIG,
				"t", 2, t,
				"code", 1, code,
				0);
#endif
	int i;
	ASSERT (t != NULL, ("SSIG ERROR\n"));
	if (! waiting_for (t,code)) {
#ifdef TTRACE
		e_trace (0,"ssig");
#endif
		return;
	}

	lock ();
	switch (t -> info.situation) {
	case ENGAGED:
		ASSERT (waiting_for (t,ENDRDV_EVENT),("Engaged task not waiting for end_rdv %x\n",t));
		remove (t);
		/* fall through , after removal I am nowhere */
	case NOWHERE:
		t -> info.activ_event = code;
		if (t -> info.curr_prio > high_prio)
			high_prio = t -> info.curr_prio;
		queue (t, agenda (t -> info.curr_prio));
		break;
	case IN_AGENDA:
		/* discard the signal... the target task is already in
		 * the agenda
		 */
		break;
	}

	unlock ();
#ifdef TTRACE
	e_trace (0,"ssig");
#endif
}

/*
 *	Check whether or not my parent is willing to terminate
 */
void
check_terminate (t)
tdp	t;
{
#ifdef TTRACE
	int T_result = s_trace (1,"check_term",CHECK_TERM,
				"t", 2, t,
				0);
#endif

	if (t == NULL) {
#ifdef TTRACE
	e_trace (1,"check_term");
#endif
	   return;
	}
	lock ();
	if (myself -> master != (master_p) 0xFFFF)
		/* coming from terminate I may have lost a master, i.e.
		 * if I was only dependent of one master, this dependence
		 * is removed by the call to leave_master before this call
		 * Therefore the if test
		 */
		ASSERT (myself -> master -> slave_cnt == 0,("check_termi : children error\n"));
	/* tell daddy I am no longer active */
	t -> master -> slave_cnt --;
	switch (t -> info.state) {
	case CREATED:
	case RUNNING:
	   	break;
	case COMPLETED:
	   	/* again another child less for this task */
	   	ssig (t, TERM_EVENT);
		break;
	case TERM_AT:
	     	if (t -> master -> slave_cnt == 0) {
		/* the father has become shure terminatable, check if his
		 * father changes also
		 */
			t -> info.state = SHURE_TERM_AT;
		  	check_terminate (t -> my_father);
		}
		break;
	default:
	  	ASSERT (FALSE, ("\nin check termination"));
	}
	unlock ();
#ifdef TTRACE
	e_trace (1,"check_terminate");
#endif
}

void
check_activate (t)
tdp	t;
{
#ifdef TTRACE
	int T_result = s_trace (1,"check_activ",CHECK_ACTIV,
				"t", 2, t,
				0);
#endif

	if (t == NULL) {
#ifdef TTRACE
	e_trace (1,"check_activate");
#endif
	   return;
	}

	lock ();
	/* tell my daddy I am active again */
	t -> master -> slave_cnt ++;

	switch (t -> info.state) {
	case CREATED:
	case RUNNING:
	case COMPLETED:
	case TERM_AT:
		break;
	case SHURE_TERM_AT:
		/* t changes from shure_terminatable to terminatable,
		 * check if the father changes also
		 */
		 t -> info.state = TERM_AT;
		 check_activate (t -> my_father);
		 break;
	default:
	  	ASSERT (FALSE, ("\nstate %d for tdp %x in check activation", t -> info.state, t));
	}
	unlock ();

#ifdef TTRACE
	e_trace (1,"check_activate");
#endif
}

bool
call_rdv (t, e, h, p)
tdp t;
int e;
int h;
int	p;		/* first entry  parameter */
{
#ifdef TTRACE
	int T_result = s_trace (0,"call_rdv",CALL_RDV,
				"t", 2, t,
				"e", 1, e,
				"h", 1, h,
				"p", 2, p,
				0);
#endif
	if (! Callable (t))
		CRAISE (11);
	lock ();	
	myself -> parlist = &p;
	myself -> info.entry_nr = e;
	chain (myself, t);
	ssig (t, TO_BE_ENGAGED);

	/* the event TIMER_EVENT will be set in wait, if h != INFINITE */
	set_sigs (myself,ENDRDV_EVENT|TASKERR_EVENT);
	wait (h);
	switch (myself -> info.activ_event) {
		case TASKERR_EVENT:
			CRAISE (12);
			break;
		}
#ifdef TTRACE
	r_trace (0,"call_rdv", "result = ", 1, myself -> info.activ_event == ENDRDV_EVENT);
#endif
	unlock ();
	set_sigs (myself, NONE);
	return myself  -> info.activ_event == ENDRDV_EVENT;
}

/*
 *	The procedure START_RDV, as described in "het verhaal"
 *	is implemented as a function with some extra OUT parameters
 *
 *	The function result determines the selected alternative,
 *	The first parameter indicates the number of alternatives,
 *	the second parameter, a pointer, has in case of a
 *	rendezvous, a pointer to the partner in the rendezvous,
 *	the third parameter is a pointer to the parameter area of
 *	the calling task
 *	the remaining parameters form together the alt_descriptor.
 */
int
start_rdv (n, a_t1, pp, altdescr)
int n;
tdp	*a_t1;
long	**pp;
int altdescr;
{
#ifdef TTRACE
	int T_result = s_trace (0,"start_rdv",START_RDV,
				"n", 1, n,
				"a_t1", 2, a_t1,
				"pp", 2, pp,
				0);
#endif
	struct	alt_descr *p = (struct alt_descr *) &altdescr;
	int term	= FALSE;
	register int i;
	register int e;
	register int delay	= INFINITE;
	int alt_kind	= CLOSED_ALT;
	long e_d = 0;
	tdp caller;

	/* find out if there is an TERMINATE or DELAY alternative 
	 * or an open ACCEPT_ALT
	 */
	for (i = 0; i < n; i ++) {
		switch (p [i].e_code) {
		case TERM_ALT:
			alt_kind |= TERM_ALT;
			break;
		case DELAY_ALT:
	       		if (delay > p [i]. alt_data) {
				delay = p [i]. alt_data;
	            		myself -> info.selected_alt = i;
				alt_kind |= DELAY_ALT;
		  	}
			break;
		case ACCEPT_ALT:
			alt_kind |= ACCEPT_ALT;
			e = p [i].alt_data;
			e_d |= 1 << (e-1);
			break;
		}
	}
	if (alt_kind == CLOSED_ALT)
		CRAISE (PROGRAM_ERROR);

	lock ();
	while (FOREVER) {
		/* find out if there is a caller for an open accept */

		caller = myself -> eng_head;
		while (caller != (tdp) NULL) {
			if (e_d & ( 1 << (caller -> info.entry_nr-1))) {
		  		myself -> rdv_stack [++myself -> info.rdv_depth] = caller;
		    		*a_t1 = caller;
		    		*pp = caller -> parlist;
		    		if (waiting_for (caller,TIMER_EVENT))
	               			dechnclock (caller);
 		    		set_priority (caller -> info.curr_prio);
		    		unlock ();
				/* re-find the altdesc entry nr */
				for (i=0;i<n;i++)
					if (caller -> info.entry_nr == p[i].alt_data) {
#ifdef TTRACE
		    		r_trace (1,"start_rdv", "result = ",1, i);
#endif

		    				return i+1;	/* selected alternative		*/
		    			}
			}
/*
			printf ("caller was %x\n", caller);
 */
			caller = caller -> chain.last;
/*
			printf ("caller is %x\n", caller);
 */
		}

		/* there is nobody to be engaged with currently,
		 * so let's wait to see what will happen
		 */

		if (alt_kind & DELAY_ALT)  {
			set_sigs (myself,TO_BE_ENGAGED|TIMER_EVENT|TASKERR_EVENT);
			wait (delay);
			switch (myself -> info.activ_event) {
			case TIMER_EVENT:
				unlock ();
#ifdef TTRACE
		    		r_trace (1,"start_rdv", "result = ",1, myself -> info.selected_alt);
#endif
				return myself -> info.selected_alt;
			case TASKERR_EVENT:
				/* don't know yet */
				return FALSE;
			case TO_BE_ENGAGED:
				break;
			default:
				ASSERT (FALSE,("Got strange event in start_rdv\n"));
			}
			set_sigs (myself,NONE);
		}
		else {
	   		myself -> info.state = TERM_AT;
	   		if (myself -> master -> slave_cnt == 0) {
	      			myself -> info.state = SHURE_TERM_AT;
	      			check_terminate (myself -> my_father);
	   		}
			set_sigs (myself,TO_BE_ENGAGED|KILL_EVENT|TASKERR_EVENT);
			wait (INFINITE);
			switch (myself -> info.activ_event) {
			case TASKERR_EVENT:
				/* don't know yet */
				return FALSE;
			case KILL_EVENT:
				myself -> info.state = TERMI;
				wait (INFINITE);
				ASSERT (TRUE,("In start_rdv: reentered from killed state\n"));
				break;
			case TO_BE_ENGAGED:
				check_activate (myself -> my_father);
				break;
			default:
				ASSERT (FALSE,("Got strange event in start_rdv\n"));
			}
			set_sigs (myself,NONE);
	   	} /* end else part */
	} /* end while FOREVER */
}

void
set_priority (p)
int p;
{
#ifdef TTRACE
	int T_result = s_trace (1,"set_priority",SET_PRIORITY,
				"p", 1, p,
				0);
#endif
	push (myself -> info.curr_prio);
	if (myself -> info.curr_prio < p) {
	   myself -> info.curr_prio = p;
	   Hard_prio (p);
	}
#ifdef TTRACE
	e_trace (1,"set_priority");
#endif
}

void
end_rdv (ex)
int	ex;
{
#ifdef TTRACE
	int T_result = s_trace (0,"end_rdv",END_RDV,
				0);
#endif
	register tdp t;
	lock ();
	t = myself -> rdv_stack [myself -> info.rdv_depth --];
	ssig (t, ENDRDV_EVENT);
	myself -> info.curr_prio = pull ();
	Hard_prio (myself -> info.curr_prio);
	unlock ();
#ifdef TTRACE
	e_trace (0,"end_rdv");
#endif
}


/*
 *************Time manager*****************************
 */

void
clock ()
{
#ifdef TTRACE
	int T_result = s_trace (1,"clock",CLOCK,
				0);
	histo [tick_nr++] = task_count;
#endif
	if (myself -> info.lock_level > 0)
	   { restart (clock);
	     was_clock = TRUE;
#ifdef TTRACE
	e_trace (1,"clock");
#endif
	     return;
	   }
	clock2 (myself);	/* handle the clock here	*/
#ifdef TTRACE
	e_trace (1,"clock");
#endif
}


#ifdef TTRACE
static int time = 0;
#endif

void
clock2 (old_task)
tdp old_task;
{
#ifdef TTRACE
	int T_result = s_trace (1,"clock2",CLOCK2,
				"old_task", 2, old_task,
				0);
#endif
	tdp	t;

#ifdef TTRACE
	if (tick_tracing)
		printf (" *** %2d *** ",++time);
#endif

	if (clock_head != NULL) {
	   clock_head -> info.chrono -= 1;
	   if (clock_head -> info.chrono == 0) {
	      lock ();
	      while (1) {
	         t = clock_head;
	         clock_head = clock_head -> clock_chain;
	         ssig (t, TIMER_EVENT);
	         if (clock_head == NULL || clock_head -> info.chrono != 0)
	            break;
	      }
	      unlock ();
	      restart (clock);
	      get_rescheduled ();
	   }
	}

	old_task -> info.chrono -= 1;
#ifdef TTRACE
	if (clock_tracing) {
		fflush (stdout);
		printf ("\ncl2 : chrono : %d\n",old_task -> info.chrono);
	}
#endif
	if (old_task -> info.chrono <= 0) {
#ifdef TTRACE
	if (clock_tracing) {
		printf ("cl2 : %x signalled\n",old_task);
		fflush (stdout);
	}
#endif
	   restart (clock);
	   get_rescheduled ();
	}
#ifdef TTRACE
	e_trace (1,"clock2");
#endif
}



void
restart (x)
int	(*x)();
{
#ifdef TTRACE
	int T_result = s_trace (1,"restart",RESTART,
				"x", 2, x,
				0);
#endif
#ifdef STAND_ALONE
	time_slice = 1;
#endif
	if (clocking) {
		alarm (time_slice);
		signal (SIGALRM, x);
	}
#ifdef TTRACE
	e_trace (1,"restart");
#endif
}


void
get_rescheduled ()
{
	/* myself will be re-queued, and swapped out */
	queue (myself, agenda (myself -> info.curr_prio));
	wait (CLOCK_TICK);
}

#define MAX_POOL 	1000
/* STAT_PART : the number of longs in the static part of the task_descr. */
#define STAT_PART	40
tdp dyn_pool [MAX_POOL];
int top_pool = -1;
tdp
task_alloc (t)
	TTDP t;
{
	int i = 0;
	tdp task;
	long *p;
	int storsize = sizeof (struct td) + t -> storsize;

	if (top_pool < 0) {
		task = (tdp) t_alloc (storsize);
#ifdef TTRACE
		if (high_mem < (long) task)
			high_mem = (long) task;
#endif
		if (task == 0)
			return 0;
	}
	else
		task = dyn_pool [top_pool--];

	p = (long *) task;
	for (i=0; i<STAT_PART; i++) *p++ = 0;
	task -> info.state = CREATED;
	return task;
}

void
task_free (task)
	tdp task;
{
	lock ();
	/*
         * 	* (task -> taskobj) = (tdp) NULL;
	 */
	if (top_pool == MAX_POOL)
		free (task);
	else
		dyn_pool [++top_pool] = task;
	unlock ();
}

#ifdef TTRACE

/**************************** trace facilities *******************/

int trace_lev = 0;
int tracing;
int simple_tracing;
int swap_tracing;
int selective_tracing;
int trace_dump;
int clock_tracing;
int wait_tracing;
int tick_tracing;
int task_tracing;
int counting;



#define	MAXFUNC	100
int g_acc [MAXFUNC];

struct par_elem {
	char	 *pname;
	int 	 ptype;
	union 	pvalue {
		char c_val;
		int  i_val;
		int * p_val;
	} pval;
};

FILE *tr_file = stdout;
FILE *tr_dump;

TR_init ()
{
	FILE *tr_kind;
	char tmp;
	int silent = 0;
	int i;
	exa_stack [0] = &td_main;
	tr_kind = fopen ("TRACE","r");
	if (tr_kind == (FILE *) NULL) {
		return;
	}

	/* first char is duration (0-9) of time_slice */
	tmp = getc (tr_kind);
	time_slice = tmp - '0';

	tmp = getc (tr_kind);
	trace_dump = tmp - '0';
	silent += tmp - '0';
	if (trace_dump !=  0) {
		printf ("trace_dump active now ...\n");
		tr_dump = fopen ("TRACE_OUT","w");
		if (tr_dump == (FILE *) NULL) {
			fprintf (stderr, "Cannot open trace file TRACE_OUT\n");
			exit (1);
		}
	}
	tmp = getc (tr_kind);
	tracing = tmp - '0';
	silent += tmp - '0';
	if (tracing) 
		printf ("tracing active now ... \n ");

	tmp = getc (tr_kind);
	simple_tracing = tmp - '0';
	silent += tmp - '0';
	if (simple_tracing) 
		printf ("simple_tracing active now ... \n ");

	tmp = getc (tr_kind);
	swap_tracing = tmp - '0';
	silent += tmp - '0';
	if (swap_tracing) 
		printf ("swap_tracing active now ... \n ");

	tmp = getc (tr_kind);
	selective_tracing = tmp - '0';
	silent += tmp - '0';
	if (selective_tracing) 
		printf ("selective_tracing active now ... \n ");

	tmp = getc (tr_kind);
	clock_tracing = tmp - '0';
	silent += tmp - '0';
	if (clock_tracing) 
		printf ("clock_tracing active now ... \n ");

	tmp = getc (tr_kind);
	wait_tracing = tmp - '0';
	silent += tmp - '0';
	if (wait_tracing) 
		printf ("wait_tracing active now ... \n ");

	tmp = getc (tr_kind);
	tick_tracing = tmp - '0';
	silent += tmp - '0';
	if (tick_tracing) 
		printf ("tick_tracing active now ... \n ");

	tmp = getc (tr_kind);
	task_tracing = tmp - '0';
	silent += tmp - '0';
	if (task_tracing) 
		printf ("task_tracing active now ... \n ");

	tmp = getc (tr_kind);
	counting = tmp - '0';
	silent += tmp - '0';
	if (counting)  {
		printf ("counting active now ... \n ");
		for (i=0; i< MAXFUNC; i++)
			g_acc [i] = 0;
	}

	if (silent != 0)
		printf ("time_slice = %d second(s)\n",time_slice);
}

s_trace (sel,f_name,f_ind,par_list)
	int sel;
	char * f_name;
	int f_ind;
	int par_list;
{
	struct par_elem *params = (struct par_elem *) &par_list;

	++trace_lev;

	if (counting) {
		++ g_acc [f_ind];
#ifdef TTRACE
		if (myself != NULL)
			++ myself -> l_acc [f_ind];
#endif
	}

	if (! simple_tracing)
		if (! selective_tracing)
			return;
	if (selective_tracing && sel == 1)
		return;	

	TR_lev(trace_lev);
	fprintf (tr_file," %s ",f_name);
	while (params -> pname != (char *) NULL) {
		fprintf (tr_file," %s = ",params -> pname);
		TR_val (params);
		TR_action (params);
		++params;
	}
	fprintf (tr_file,"\n");
	fflush (tr_file);
}

TR_lev (level)
	int level;
{
	int i;
	if (myself -> info.lock_level > 0)
		fprintf (tr_file,"L ");
	else
		fprintf (tr_file,"U ");
	for (i=0; i< level; i++)  {	
		fprintf (tr_file,"-");
	}
	fprintf (tr_file," %3d ",level);
	fflush (tr_file);
}

TR_val (param)
	struct par_elem *param;
{
	switch (param -> ptype) {
	case 0	: fprintf (tr_file,"%c",param -> pval.c_val);
		  break;
	case 1	: fprintf (tr_file,"%d",param -> pval.i_val);
		  break;
	case 2	: fprintf (tr_file,"%x",param -> pval.p_val);
		  break;
	default :
		  break;
	}
}

TR_action (param)
	struct par_elem *param;
{
	switch (param -> ptype) {
	case 0	: 
	case 1	: 
		  break;
	case 2	: 
		  break;
	}
}

e_trace (sel,f_name)
	int sel;
	char * f_name;
{
	-- trace_lev;

	if (! simple_tracing)
		if (! selective_tracing)
			return;

	if (selective_tracing && sel == 1)
		return;

	TR_lev (trace_lev + 1);
	fprintf (tr_file," %s end\n", f_name);
	fflush (tr_file);
}

r_trace (sel,f_name,par_list)
	int sel;
	char * f_name;
	int par_list;
{
	struct par_elem *res =  (struct par_elem *) &par_list;
	-- trace_lev;

	if (! simple_tracing)
		if (! selective_tracing)
			return;

	if (selective_tracing && sel == 1)
		return;

	TR_lev (trace_lev + 1);
	fprintf (tr_file," %s end ", f_name);
	TR_val (res);
	fprintf (tr_file,"\n");
	fflush (tr_file);
}

dump_mtd (x)
	tdp x;
{
	int i;
	printf ("============ dump mtd : %x ===================\n",x);
	printf ("tasktype	: %x\n",x -> tasktype);
	printf ("status		:\n");
		for (i=0;i<8;i++) {
			printf ("d%1d %8x	",i,x -> context.d_reg[i]);
			if (i == 3)
				printf ("\n");
		}
		printf ("\n");
		for (i=0;i<8;i++) {
			printf ("a%1d %8x	",i,x -> context.a_reg[i]);
			if (i == 3)
				printf ("\n");
		}
		printf ("\n");
		printf ("pc = %x\n",x -> context.pc);
	printf ("state		: %d\n",x -> info.state);
	printf ("curr_pri	: %d\n",x -> info.curr_pri);
	printf ("lock_level	: %d\n",x -> info.lock_level);
	printf ("chrono		: %d\n",x -> info.chrono);
	printf ("activ_chain	: %x\n",x -> activ_chain);
	printf ("chain		:\n");
	printf ("	first	: %x\n",x -> chain.first);
	printf ("	last	: %x\n",x -> chain.last);
	printf ("clock_chain	: %x\n",x -> clock_chain);
	printf ("master_chain	: %x\n",x -> master_chain);
	printf ("my_father	: %x\n",x -> my_father);
	printf ("activ_cnt	: %d\n",x -> info.activ_cnt);
	printf ("active_error	: %d\n",x -> info.activ_error);
	printf ("master		: %x\n",x -> master);
	printf ("activ_event	: %d\n",x -> info.activ_event);
	printf ("waited for 	: ");
	for (i=1;i<1024; i=i*2) {
		if (waiting_for (x,i))
			printf (" 1");
		else
			printf (" 0");
	}
	printf ("\n");
	printf ("parlist		: %x\n",x -> parlist);
	printf ("selected alt	: %x\n",x -> info.selected_alt);
	printf ("rvd_stack 	: ");
	i = 0;
	if (x -> info.rdv_depth < 0 || x -> info.rdv_depth > MAX_NEST) {
		printf ("Empty rdv stack\n");
	}
	else {
		while (i <= x -> info.rdv_depth)
			printf (" %x",x -> rdv_stack [i++]);
		printf ("\n");
	}
	printf ("============ dump mtd : %x end  ==============\n",x);
	printf ("\f");
}

queue_dump (lnk)
	tdp *lnk;
{
	tdp x = *lnk;
	printf ("\nqueue is now : ");
	if (x == (tdp) NULL) {
		printf ("empty\n");
		fflush (stdout);
		return;
	}
	printf (" %x",x);
	while (x -> chain.last != (tdp) NULL) {
		x = x -> chain.last;
		printf (" %x",x);
	}
	printf ("\n");
	fflush (stdout);
}


Lprintf(fmt, args)
char *fmt;
{
	if (!task_tracing)
		return;

	lock ();
	if (myself -> info.lock_level - 1) 
		putchar ('L');
	else 
		putchar ('U');
	putchar (' ');

	_doprnt(fmt, &args, stdout);
	fflush (stdout);
	unlock ();
	return(ferror(stdout)? EOF: 0);
}


dump_all ()
{
	/* give a post mortal dump of all task descriptors on dying time */
	int i;
	tdp curr;
	printf ("\n\n\nPost mortal dump task descriptors:\n\n");
	for (i=0; i<exa_i; i++) 
		printf ("%x ",exa_stack [i]);
	printf ("\n");
	for (i=0; i<exa_i; i++) {
		curr = exa_stack [i];
		if (curr -> info.state != TERMI)
			dump_mtd (curr);
		else
			printf ("%x is terminated\n", curr);
		fflush (stdout);
	}
}


give_acc (x)
	int x [];
{
	if (!counting)
		return;

	lock ();
	printf ("\n\n");
	printf ("CREATE_TD 		%d\n", x [00]);
	printf ("ACTIVATE 		%d\n", x [01]);
	printf ("NEW_MASTER 		%d\n", x [02]);
	printf ("LEAVE_MASTER 		%d\n", x [03]);
	printf ("TERMINATE 		%d\n", x [04]);
	printf ("LOCK	 		%d\n", x [05]);
	printf ("UNLOCK 			%d\n", x [06]);
	printf ("QUEUE 			%d\n", x [07]);
	printf ("DEQUEUE 		%d\n", x [08]);
	printf ("CHAIN 			%d\n", x [09]);
	printf ("DECHAIN 		%d\n", x [10]);
	printf ("REMOVE 			%d\n", x [11]);
	printf ("DECHNCLOCK 		%d\n", x [12]);
	printf ("WAIT 			%d\n", x [13]);
	printf ("SSIG 			%d\n", x [14]);
	printf ("CHECK_TERMINATE		%d\n", x [15]);
	printf ("CHECK_ACTIVATE		%d\n", x [25]);
	printf ("CALL_RDV 		%d\n", x [16]);
	printf ("SET_ALTDESC 		%d\n", x [17]);
	printf ("START_RDV 		%d\n", x [18]);
	printf ("SET_PRIORITY 		%d\n", x [19]);
	printf ("END_RDV 		%d\n", x [20]);
	printf ("CLOCK 			%d\n", x [21]);
	printf ("CLOCK2 			%d\n", x [22]);
	printf ("RESTART 		%d\n", x [23]);
	printf ("MAIN_TD 		%d\n", x [24]);
	printf ("\n\n");
	fflush (stdout);
	unlock ();
}

show_histo ()
{
	int i;

	i=0;
	while (histo [i] != 0) {
		printf ("tick : %4d   nr of tasks : %4d\n",i,histo [i]);
		++i;
	}
}

#define INDENT	for (i=0;i<level;i++) putchar ('\t')
show_children (m, level)
	struct _master *m;
	int level;
{
	int i;
	int cnt = 0;
	tdp x;
	INDENT; printf ("master : %x\n",m);
	INDENT; printf ("	slave_cnt : %d\n",m -> slave_cnt);
	INDENT; printf ("	prev_mast : %x\n",m -> prev_master);

	/* for all children show  the wanted information */
	x = m -> children;
	while (x != (tdp) NULL) {
		dump_mtd (x);
		x = x -> master_chain;
	}
	if (x -> master -> children != (tdp) NULL)
		show_children (x -> master, level+1);
}
#endif
