
/*
 * (c) copyright 1988, Delft University of Technology
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
/*
 *	Definitions are shared with wait.c
 */
#include	"rt_dats.h"

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
	/*	exc		*/		 0,
	/*	exh		*/		 0,

	/* activ chain		*/	(tdp)	 0,
	/* chain	first	*/	(tdp)	 0,
	/* chain	last	*/	(tdp)	 0,
	/* clock chain		*/	(tdp)	 0,
	/* master chain		*/	(tdp)	 0,
	/* my_father		*/	(tdp) 	 0,
	/* my_foster	  	*/ (master_p)	 0,
	/* master		*/ (master_p)	 0,
	/* eng_head		*/	(tdp)	 0,
	/* eng_tail		*/	(tdp)	 0,
	/* parlist		*/	(long *) 0,
	/* rdv stack	00	*/	(tdp)	 0,
	/* rdv stack	01	*/	(tdp)	 0,
	/* rdv stack	02	*/	(tdp)	 0,
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
 * Due to some very unclear reasons, our clock will not fuctionate
 * any more with the new Unix kernel on the Micro Dutch. 
 * The UNIX kernel cannot handle alarm (or other) system calls
 * when the stacktop is in a non-stacktop segment
 * Global storage used for tasks.
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

extern long *_univ_stack_seg_top;
extern long *_univ_stack_seg_bottom;

tdp
t_alloc (amount)
	int amount;
{
	register long *x;
	char * res;
	ASSERT (amount != 0, ("stack storage amount 0\n")); 
	res = (char *) _univ_stack_seg_bottom;

	amount = (2 * amount + 1) / 2;

/*
	if ((_univ_stack_seg_bottom += amount) > _univ_stack_seg_top) {
		_raise (&_storage_error);
		exit (1);
	}
	for (x = (long *) res; x <= _univ_stack_seg_bottom; x ++)
	    *x = (long) 0;
 */
	x = malloc (amount);
	if (x == 0) {
	   _raise (&_storage_error);
	}

	return (tdp) x;
}

t_free (p)
register tdp	p;
{
	cfree (p);
}


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

int clocking	= 1;
int time_slice  = 1;


/* mode setter
 * ==========
 *
 * DATS works with two modes, synchrone or asynchone
 *
 * the user may select which mode it is to be
 */

extern	void	start_t	();
void
set_mode (x)
	int x;
{
/*
	if (x == SYNCHRONE)
		clocking = OFF;
	else {
		clocking = ON;
		restart (clock);
	}
 */
	clocking = OFF;
}

/*
 *	create a task object, take as a parameter the master,
 *	a chain header and a task type descriptor
 */


/* starting a task goes as follows (28/8/1097)
 * - on processing the declarative part in which a task type is
 *   present a descriptor for the tasktype is created, the start_address
 *   of the task is recorded in the descriptor. 
 * - Initially the start_address is set to a error routine, on elaborating
 *   the body the start_address of the body is recorded in place of the
 *   error routine.
 * - In the surrounding stackframe of the first call to the task, as depicted
 *   below the address of a rt routine start_t is recorded. This routine
 *   jumps to the start_address found in the descriptor, either the
 *   errorroutine or the real address.
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

	/* locking is required here, altough the granularity may	*/
	/* be somewhat smaller. The idea is to have malloc locked	*/

/*
	printf ("creat_td %x %x %x %x\n", task_obj, t, m, c);
 */
	lock ();
	h = task_alloc (t);
	if (h == (tdp) NULL) {
	   unlock ();
	   _raise (&_storage_error);
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

	/* record master dependency */
	h -> my_foster	  = m;

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
	i_push (h, start_t);
	i_push (h, a6);
	a6 = h -> context.sp;
	h -> context . a_reg [6] = a6;
	for (i = 1; i <= 20; i ++)
		i_push (h, 0);

	return h;
}

/*
 *	The function of activate is twofold, first notice
 *	the father that the elaboration of the declarative
 *	part of the master of the current thread of control
 *	is completed (second parameter = TRUE),
 *	second, activate all children in the chain x
 */
void	activate (x, f)
register tdp x;
int	f;
{
	register tdp c;

	if (f) {
	   lock ();
	   myself -> my_father -> info.activ_cnt --;
	   ssig (myself -> my_father, ACTIV_EVENT);
	   unlock ();
	}

	if (x == NULL) {	/* nothing to do really		*/
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

	myself -> info.state = RUNNING;	/* now I'm going	*/

	set_sigs (myself, ACTIV_EVENT|TERM_EVENT|TASKERR_EVENT);
	while (myself -> info.activ_cnt) {
		wait (INFINITE);
		if (myself -> info.activ_event == TASKERR_EVENT)
			myself -> info.activ_error++;
	}

	set_sigs (myself, NONE);
	unlock ();
	/* when we are here, we know for sure that all the children
	 * have been activated
	 */

	if (myself -> info.activ_error)
	   _raise (&_tasking_error);

	return;
}

void	new_master (m)
master_p m;
{
	m -> prev_master = myself -> master;
	myself -> master = m;
	m -> slave_cnt = 0;
	m -> children = (tdp) NULL;
	m -> encl_task = myself;
}

/*
 *	A master can only be left when all dependent tasks
 *	have terminated. On entry the task state will
 *	be made completed, on exit the state is made
 *	READY again.
 */
void	leave_master ()
{
	register	tdp c;
	int	old_state	= myself -> info.state;

	lock ();
	myself -> info.state = COMPLETED;
	set_sigs (myself, TERM_EVENT|TASKERR_EVENT);


	while (myself -> master -> slave_cnt > 0) 
		wait (INFINITE);

	set_sigs (myself, NONE);

	/* when we are here, we know for sure that all our children
	 * have terminated or are terminatable. We send them a signal
	 * so they can take appropriate actions
	 */

	c = myself -> master -> children;
	while (c != NULL) {
	   ssig (c, KILL_EVENT);
	   c = c -> master_chain;
	}

	myself -> master = myself -> master -> prev_master;
	myself -> info.state = old_state;

	unlock ();
}

/*
 *	It is really simple, all dependent tasks did go already
 */
void	terminate ()
{
	register tdp t;

/*
	printf ("Terminating %x\n", myself);
 */
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

/*
	printf ("terminate : target %x\n", myself); 
 */
	unlock ();
	myself -> info.state = FINISHED;

	if (myself -> my_foster != NULL) {
	   check_terminate (myself -> my_foster);
	   set_sigs (myself,KILL_EVENT);

	   wait (INFINITE);	/* wait for my foster's dead blow */

	   set_sigs (myself, NONE);
	   task_free (myself); 	/* free dynamic data */
	   wait (INFINITE);	/* I am gone forever */
	   ASSERT (TRUE,("task rising from the grave in terminate\n"));
	}
	else {
		/* main task */
		return;
	}
}

bool	Terminated (t)
register tdp t;
{
	if (t == NULL
            || t -> info. state == FINISHED
	    || t -> info. state == ABORTED)
	   return  TRUE;

	return FALSE;
}

void	_genabort (a_t)
register tdp * a_t;
{
	register tdp victim = * a_t;
	register tdp t;

	/* general idea:
	 * - mark the complete tree of tasks under the victim as
	 *   being aborted,
	 * - mark the victim as such,
	 * - tell the victim's father (if there is any) about the
	 *   passing of victim
	 * - let the dispatcher find out if an aborted task is about to
	 *   be swapped in, if so let it destruct it (give away the storage
	 *   etc.)
	 */

	lock ();
	if (victim -> master != (master_p) 0xFFFF) 
		victim -> my_foster -> slave_cnt --;
	ASSERT (victim -> my_foster != NULL, ("try to abort the main task\n"));
	victim -> my_foster -> slave_cnt --;


	/* kill all dependent tasks */
	genocide (victim);
	unlock ();

	victim -> info.state = ABORTED;
}

static
void	genocide (victim)
register tdp victim;
{
	register master_p curr_master;
	register tdp c;

	curr_master = victim -> master;

	/* we must perform genocide on all descendents of the victim */
	while (curr_master != (master_p) 0xFFFF)
	{ /* for all masters do */
		c = curr_master -> children;
		while (c != (tdp) NULL) 
		{ /* for all children do */
			register tdp  x;
			genocide (c);
			/* all children of c have departed, now c */
			ASSERT (c -> info.state != CREATED, ("abort a creating task\n"));
			c -> info.state = ABORTED;
			x  = c;
			c = c -> master_chain;
			/* unlink the nextchild link */
			x -> master_chain = (tdp) NULL;
		}
		/* remove the linked children */
		curr_master -> children = (tdp) NULL;
		curr_master -> slave_cnt = 0;
		curr_master = victim -> master -> prev_master;
	}
}


bool	Callable (t)
register tdp t;
{
	if (t == (tdp) NULL)
	   return FALSE;

/*
	printf ("Checking for callable %d\n", t -> tasktype -> dtag);
	printf ("t -> info. state = %d\n", t -> info. state);
	if (t -> info.state == FINISHED) {
	   printf ("State = %X\\n", t);
	}
 */
	switch (t -> info.state) {
	   case FINISHED:
	   case COMPLETED:
	   case ABORTED:
		return FALSE;

	   default:
		return TRUE;
	}
}

int	Count (e, t)
int	e;
register tdp t;
{
	register tdp a;
	register int res = 0;
	register tdp caller;

	ASSERT (e != 0, ("Count:1"));

	caller = t -> eng_head;
	if (!Callable (t))
		_raise (&_tasking_error);

	while (caller != (tdp) NULL) {
	   if (caller -> info.entry_nr == e) ++res;
	   caller = caller -> chain.last;
	}

	return res;
}


void	_delay (d)
long	d;
{
	if (clocking) {
		chainclock (d);
		wait (INFINITE);
	}
	else
		wait (0);
}

void	zombie ()
{
	fprintf (stderr, "Task raising from the grave !\n");
	exit (1);
}


/*
 *************** lock unlock ********************************
 */

void
lock () {
	myself -> info.lock_level ++;
}

void
unlock ()
{
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
}

/*
 ************** queue/ dequeue *********************************
 */

void	queue (t, c)
register tdp t;
register link *c;
{
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
}

tdp	dequeue (c)
link	*c;
{
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
}

tdp
dechain (c)
register tdp	c;
{
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
	return t;
}


void
remove (x)
tdp	x;
{
	register link *c;
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
}


/* clock chain management *****************************************************/

void
chainclock (d)
	register long d;
{
     long accu;
     register tdp current;

     set_sig (myself,TIMER_EVENT);
     if (clock_head == NULL)
        { clock_head = myself;
          myself -> clock_chain = NULL;
          myself -> info.chrono = d;
        }
     else
     if (clock_head -> info.chrono > d)
        { myself -> clock_chain = clock_head;
          clock_head = myself;
          myself -> info.chrono      = d;
          myself -> clock_chain -> info.chrono -= d;
        }
     else
     {  current = clock_head;
        accu    = 0;
        while (current -> clock_chain != NULL &&
                     accu + current -> clock_chain -> info.chrono <= d)
        {
           accu = accu + current -> clock_chain -> info.chrono;
           current = current -> clock_chain;
        }
        myself -> info.chrono = d - accu;
        current -> clock_chain -> info.chrono =
                  current -> clock_chain -> info.chrono - myself -> info.chrono;
        myself -> clock_chain = current -> clock_chain;
        current -> clock_chain = myself;
     }
}

void
dechnclock (t)
tdp t;
/*
 *	Search for a given task at the clock queue and remove it
 */
{
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
}


t_abort (victim)
	register tdp victim;
{

	/* we know the here the children links are removed, (done in genocide),
	 * the agenda link, chain.first chain.last, is unlinked by the
	 * dechain operation,
	 * remains the resetting of the following links etc.:
	 * - pointer to task_object, signalling the callability of the task,
	 * - engaged chains.
	 */

	/* all tasks that are waiting for an evening out wit
	 * the victim will be punished for dating a aborting task 
	 */
	while (victim -> eng_head != NULL) {
		register tdp t;
		t = dechain (victim);
	        ssig (t, TASKERR_EVENT);
	}

	* (victim -> taskobj) = (tdp) NULL;

	task_free (victim);

}

void	ssig (t, code)
tdp	t;
int	code;
{
	int	i;

	ASSERT (t != NULL, ("SSIG ERROR\n"));

	if (! waiting_for (t,code)) {
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
}

/*
 *	Check whether or not my parent is willing to terminate
 */
void	check_terminate (m)
master_p	m;
{
	register tdp t;

	if (m == EMPTY) {
	   return;
	}


	t = m -> encl_task;
	if (t == NULL) {
	   printf ("%x has a 0 task as enclosing task\n", m);
	   printf ("prevmaster = %x\n", m -> prev_master);
	   printf ("slavecount = %d\n", m -> slave_cnt);
	   printf ("children   = %x\n", m -> children);
	   abort ();
	}

	lock ();
	if (myself -> master != EMPTY)
		ASSERT (myself -> master -> slave_cnt == 0,
			("check_termi : children error\n"));

	/* tell daddy I am no longer active */
/*
	printf ("	check_termi : master %x in %x\n", m, t);
*/

	m -> slave_cnt --;

	switch (t -> info.state) {
	   case COMPLETED:
	   	/* again another child less for this task */
	   	ssig (t, TERM_EVENT);
		break;

	   case TERM_AT:
	     	if (t -> master -> slave_cnt == 0) {
		/* the father has become shure terminatable, check if his
		 * father changes also
		 */
			t -> info.state = TERMI;

		  	check_terminate (t -> my_foster);
		}
		break;

	   default:
	  	break; /* do nothing interesting */
	}

	unlock ();
}

void	check_activate (m)
master_p	m;
{
	register tdp t;

	if (m == NULL) {
	   return;
	}

	t = m -> encl_task;
	lock ();
	/* tell my daddy I am active again */
	m -> slave_cnt ++;
	switch (t -> info.state) {
	case TERMI:
		/* t changes from shure_terminatable to terminatable,
		 * check if the father changes also
		 */
		 t -> info.state = TERM_AT;
		 check_activate (t -> my_foster);
		 break;

	default:
	  	break; /* do nothing */
	}

	unlock ();

}

bool
call_rdv (t, e, h, p)
tdp t;
int e;
int h;
int	p;		/* first entry  parameter */
{
	if (! Callable (t))
		_raise (&_tasking_error);
	lock ();	
	myself -> parlist = &p;
	myself -> info.entry_nr = e;
	chain (myself, t);
	ssig (t, TO_BE_ENGAGED);
	/* the event TIMER_EVENT will be set in wait, if h != INFINITE */
	set_sigs (myself,ENDRDV_EVENT|TASKERR_EVENT | GOTEXCEPTION);
	wait (h);
	unlock ();
	set_sig (myself, NONE);
	switch (myself -> info.activ_event) {
		case TASKERR_EVENT:
			_raise (&_tasking_error);
			/* no return		*/
			break;
		case GOTEXCEPTION:
			_raise (myself -> _exc);
			/* no return	*/
			break;
		case TIMER_EVENT:
			return 0;	/* no engagement	*/

		case ENDRDV_EVENT:
			return 1;

		default:
			ASSERT (FALSE, ("Hier mag ik niet komen"));
		}
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
int	n;
tdp	*a_t1;
long	**pp;
int	altdescr;
{
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
	            		myself -> info.selected_alt = i+1;
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
	   _raise (&_program_error);
/*
	printf ("start_rdv: encountered accept (%d) en delay (%d) en termi (%d)\n",
                            alt_kind & ACCEPT_ALT,
			    alt_kind & DELAY_ALT,
			    alt_kind & TERM_ALT);
 */
	lock ();
	while (FOREVER) {
		/* find out if there is a caller for an open accept */

		caller = myself -> eng_head;
		while (caller != (tdp) NULL) {
			if (e_d & ( 1 << (caller -> info.entry_nr-1))) {
		  		myself -> rdv_stack [++myself -> info.rdv_depth] = caller;
		    		*a_t1 = caller;
		    		*pp = caller -> parlist;
		    		if (waiting_for (caller, TIMER_EVENT))
	               			dechnclock (caller);

 		    		set_priority (caller -> info.curr_prio);
		    		unlock ();
				/* re-find the altdesc entry nr */
				for (i=0;i<n;i++)
					if (caller -> info.entry_nr == p[i].alt_data) {

		    				return i+1;	/* selected alternative		*/
		    			}
			}

			caller = caller -> chain.last;
		}

		/* there is nobody to be engaged with currently,
		 * so let's wait to see what will happen
	         */
		 if (! (alt_kind & TERM_ALT)) {
			set_sigs (myself,TO_BE_ENGAGED|TIMER_EVENT|TASKERR_EVENT);
			wait (delay);
			switch (myself -> info.activ_event) {
			case TIMER_EVENT:
				unlock ();
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
			if (myself -> master != EMPTY) {
	   			if (myself -> master -> slave_cnt == 0) {
	      				myself -> info.state = TERMI;
	      				check_terminate (myself -> my_foster);
	   			}
			}
			else {
				myself -> info.state = TERMI;
				check_terminate (myself -> my_foster);
			}

			set_sigs (myself,TO_BE_ENGAGED|KILL_EVENT|TASKERR_EVENT);
			wait (INFINITE);
			switch (myself -> info.activ_event) {
			   case TASKERR_EVENT:
				/* don't know yet */
				return FALSE;

			   case KILL_EVENT:
			{
				register tdp c = myself -> master -> children;
				myself -> info.state = TERMI;
				/* propagate the kill signal to any non killed
				 * children */
				while (c != (tdp) NULL) {
					ssig (c,KILL_EVENT);
					c = c -> master_chain;
				}

				myself -> info. state = FINISHED;
				set_sigs (myself, NONE);
				task_free (myself);
				wait (INFINITE);
				ASSERT (TRUE,("In start_rdv: reentered from killed state\n"));
			}
				break;

			case TO_BE_ENGAGED:
				check_activate (myself -> my_foster);
				break;

			default:
				ASSERT (FALSE,("Got strange event in start_rdv\n"));
			}

			set_sigs (myself,NONE);
	   	} /* end else part */
	} /* end while FOREVER */
}

void	set_priority (p)
int	p;
{
	push (myself -> info.curr_prio);
	if (myself -> info.curr_prio < p) {
	   myself -> info.curr_prio = p;
	   Hard_prio (p);
	}
}

void
end_rdv (ex)
int	ex;
{
	register tdp t;
	lock ();
	t = myself -> rdv_stack [myself -> info.rdv_depth --];
	if (ex == 0) {	/* everything is well		*/
	   ssig (t, ENDRDV_EVENT);
	}
	else {
		t_raise (t, ex);
	}
	myself -> info.curr_prio = pull ();
	Hard_prio (myself -> info.curr_prio);
	unlock ();
	if (ex != 0) {
	   _raise (ex);
	}
}

/*
 *	raise the exception e in the task t
 */
t_raise (t, e)
tdp	t;
int	e;
{
	ASSERT (t != NULL, ("Cannot raise exception in null task"));
	t -> _exc = (long *) e;
	ssig (t, GOTEXCEPTION);
}

_t_raise (t, e)
tdp	t;
int	e;
{
	if (t == NULL)
	   return;

	t -> _exc = (long *) e;
	
	printf ("Doe hier een remote raise\n");
}
/*
 *************Time manager*****************************
 */

void
clock ()
{
	if (myself -> info.lock_level > 0)
	   { restart (clock);
	     was_clock = TRUE;
	     return;
	   }
	clock2 (myself);	/* handle the clock here	*/
}



void
clock2 (old_task)
tdp old_task;
{
	tdp	t;


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
	if (old_task -> info.chrono <= 0) {
	   restart (clock);
	   get_rescheduled ();
	}
}



void
restart (x)
int	(*x)();
{
	if (clocking) {
		alarm (time_slice);
		signal (SIGALRM, x);
	}
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


tdp	task_alloc (t)
TTDP t;
{
	int i = 0;
	tdp task;
	long *p;
/*	int storsize = sizeof (struct td) + t -> storsize * sizeof (int); */
	int storsize = sizeof (struct td) + 4096 * sizeof (int);

	if (top_pool < 0) {
		task = (tdp) t_alloc (storsize);
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

void	task_free (task)
tdp	task;
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

