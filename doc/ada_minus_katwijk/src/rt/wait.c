
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

#include	"rt_dats.h"

/*
 *
 *	basic dispatching mechnanism
 *
 *	A task suspends itself by calling wait,
 *	for at least H time units
 *	Implementation consideration: Due to the fact that we
 *	build up a context for a task, we expect a task to come
 *	alive here for the first time. Careful for the registers
 *	DO NOT USE AN OPTIMIZER FOR THIS FUNCTION
 *
 */
void	wait (h)
int	h;
{
	register int i;
	tdp	current;

	lock ();	/* no interruptions please	*/

	if (h == 0)
	   ssig (myself, TIMER_EVENT);
	else
	if (h != INFINITE
            && h != CLOCK_TICK && clocking) /* INFINITE special	*/
		chainclock (h);

/*
 *	Here we are properly chained, let's dispatch
 */

	while (FOREVER) {
		for (i = MAX_PRIO; i >= 0; i--) {
		     if (! empty_queue (agenda (i))) {
		        current = dequeue (agenda (i));
			if (current -> info.state == ABORTED) {
				t_abort (current);
				continue;
			}

			if (current != myself) {
				/* I must be the only one left to play with,
				 * in this case swapping is only lost time
				 * let's skip it
				 */
		        	swap (current);		/* careful		*/	
							/* the calling task has	*/
							/* disappeared, next	*/
							/* instructions by other*/
			}

		        myself -> info.chrono = TIME_SLICE;
			if (myself -> info.state != COMPLETED)
				myself -> info.state = RUNNING;
		        Hard_prio (myself -> info.curr_prio);
		        high_prio = myself -> info.curr_prio;
		        unlock ();
		        return;
		     }
		}


		if ((clock_head != NULL) && clocking) {
			/* time consuming until a clock interrupt */
			pause ();
			/* we are here in a locked situation, so the clockalarm
			 * will not be serviced by clock2 (), 
			 * clockchain administration must occurr here:
			 */

			if (clock_head != NULL) {
	   			clock_head -> info.chrono -= 1;
	   			if (clock_head -> info.chrono == 0) {
	         			while (clock_head != NULL && clock_head -> info.chrono == 0) {
						register tdp t;
	         				t = clock_head;
	         				clock_head = clock_head -> clock_chain;
	         				ssig (t, TIMER_EVENT);
	      				}
				}
			}

			continue;
		}
	

		/* here we have a deadlock situation */
		printf ("DEADLOCK, program aborted");
		fflush (stdout);
		abort ();

	} /* end while (FOREVER) */

}

