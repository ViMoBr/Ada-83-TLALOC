
/*  ---------------------------------------------------------------------
 *
 * -- RCS PART --
 *
 * $Author$
 *
 * $Date$
 *
 * $Locker$
 *
 * $Log$
 * 
 * $Source$
 * $State$
 *
 * ------ END RCS PART --
 */

/*
static char rcsid [] = "$Header$";
 */

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
 * For further information contact
 *
 *	Hans Toetenel
 *	Department of Computer Science
 *	Programming Languages Lab.
 *	Delft University of Technology
 *	julianalaan 132 
 *	2628 BL Delft
 *	The Netherlands.
 *
 */

/**************************** type definitions *************************/

/* This tasking runtime kernel can be configurated to work stand_alone,
 * i.e. without the Ada runtime environment,
 * to use dats stand_alone, two types must be defined that otherwise
 * are defined in the runtime system.
 * To create a stand_alone version, use the STAND_ALONE switch.
 * cc -c ... -DSTAND_ALONE ... dats.c
 */

#ifdef STAND_ALONE
typedef	int		void;
/* otherwise defined in unix.h */
#endif

typedef struct _master	master;
typedef master *	master_p;
typedef struct td *	tdp;

#ifdef	STAND_ALONE
typedef struct tt_tsk *	TTDP;
#endif

/**************************** exceptions       *************************/

#ifdef STAND_ALONE
#define	STORAGE_ERROR	0
#define	TASKING_ERROR	1
#define PROGRAM_ERROR	2
#else
#include	"../rt/cnames.h"
#endif

/**************************** select descriptor ************************/

#define CLOSED_ALT	00
#define	ACCEPT_ALT	01
#define	DELAY_ALT	02
#define	TERM_ALT	04

#define	INFINITE	((unsigned)65000)

/**************************** dats modes       ************************/

#define	SYNCHRONE	0
#define ASYNCHRONE	1

/**************************** structures       *************************/

struct _master {
	tdp			children;
	tdp 			encl_task;
	struct _master *	prev_master;
	int			slave_cnt;
};


#ifdef STAND_ALONE
struct tt_tsk {
	long	dtag;
	long	prio;
	long	storsize;
	long	*addr;
	long	*st_link;
};
#endif

/**************************** vital offsets    ************************/

/*
#define	_EXC	(sizeof (TTDP) + sizeof (status) + sizeof (tdp	*) + sizeof (log))
#define	_EXH	(sizeof (long) + _EXC)
 */
#define	_EXC	90
#define	_EXH	94

/**************************** user interface   *************************/


extern void            activate        (); /* dats.c  (x,f) */
extern bool            Callable        (); /* dats.c  (t) */
extern bool            call_rdv        (); /* dats.c  (t,e,h,p) */
extern tdp             create_td       (); /* dats.c  (task_obj,t,m,c) */
extern void            end_rdv         (); /* dats.c  () */
extern void            leave_master    (); /* dats.c  () */
extern void            lock            (); /* dats.c  () */
extern void            new_master      (); /* dats.c  (m) */
extern void	       set_mode        (); /* dats.c  (x) */
extern int             start_rdv       (); /* dats.c  (n,a_t1,pp,altdescr) */
extern void            terminate       (); /* dats.c  () */
extern bool            Terminated      (); /* dats.c  (t) */
extern void            unlock          (); /* dats.c  () */
extern void	       zombie	       (); /* dats.c  () */
