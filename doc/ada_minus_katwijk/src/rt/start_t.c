#include	"../h/print.h"
#include	<stdio.h>
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"

#define		FALSE		0
#define		TRUE		1
#define		CHAR		1
#define		SHORT		2
#define		LONG		4
#define		DOUBLE		8

static int install_clock = 1;

#define ASYNCHRONE	1
struct _ttype {
	long tag;
	long pri;
	int stsize;
	int (*task) ();
	long *stlink;
};
typedef struct _ttype *ttp;

start_t (t_desk)
	TTDP t_desk;
{
	ttp p;
	p = (ttp) t_desk;
	if (install_clock) {
		set_mode (ASYNCHRONE);
		install_clock = 0;
	}
	(p -> task) (p -> stlink);
	run_error ("_start_t : task returned over its dead point\n");
}
extern int error_t ();

error_t ()
{
	/* error start routine for tasks,
	 * will be executed if the body of a task is elaborated
	 * AFTER the actual activation of a taskobject
	 */

	printf ("Activation of task before elabration of body\n");
	_raise (&TASKING_ERROR);
}
