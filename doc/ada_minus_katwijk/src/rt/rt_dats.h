
/*
 * (c) copyright 1987, Delft University of Technology
 * Delft, The Netherlands
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 *	For further information contact
 *	Jan van Katwijk
 *	Faculty of Computer Science
 *	Delft University of Technology
 *	Julianalaan 132
 *	2628 BL Delft The Netherlands.
 *
 */

#include	<signal.h>
#include	<stdio.h>
#include	"unix.h"
#include	"dats.h"

#ifndef STAND_ALONE
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#endif

extern	int	_tasking_error;
extern	int	_storage_error;
extern	int	_program_error;

/**************************** constant definitions *********************/
#define	FOREVER		1
#define	OFF	0
#define ON	1
#define EMPTY	(master_p) 0xFFFF

/*
 *	task states
 */

#define	CREATED			0
#define	RUNNING			1
#define	TERM_AT			2
#define	TERMI			3
#define	COMPLETED		4
#define	FINISHED		5

#define	NOWHERE			7
#define IN_AGENDA		8
#define	ENGAGED			9
#define ABORTED			10

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
#define	GOTEXCEPTION		0200

#define ALL	01|02|04|010|020|040|0100|0200
#define NONE	0

#define CLOCK_TICK	-1
#define	TIME_SLICE	1

#define	MAX_NEST	3
#define	MAX_PRIO	8


/**************************** macro definitions ************************/

#define	ASSERT(x,y)	if (!(x)) { lock (); printf y;		\
				unlock ();			\
				fflush (stdout);abort (); }
#ifdef STANDALONE
#define	CRAISE(x)	{printf ("raised %s\n",			\
		(x== 0 ? "Storage error" 		        \
		       : (x==1 ? "Tasking error"		\
			       : "Program error"))		\
						); abort ();}
#endif

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
extern void	       chainclock      (); /* dats.c  (d) */
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
static	void		genocide	();

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
	long		*_exc;
	long		*_exh;
    	tdp		activ_chain;	
    	link		chain;	
    	tdp		clock_chain;
    	tdp		master_chain;
    	tdp		my_father;
	master_p	my_foster;
    	master_p	master;
    	tdp		eng_head;
    	tdp		eng_tail;
    	long		*parlist;
    	tdp		rdv_stack [MAX_NEST];
	/* down from here the stack of this task runs	*/
    	long  		st_data  [1];
};




/************** static taskdescriptor for first task *******************/

extern	struct td td_main;


extern	tdp	clock_head;
extern	int	high_prio;
extern	int	was_clock;	/* to remember a clock tick	*/
extern	link	_agenda [];
	
extern	tdp myself;

extern	int clocking;
extern	int time_slice;

