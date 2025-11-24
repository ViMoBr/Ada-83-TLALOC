#include <libr.h>


/*
 *	definitions
 */

#define equal(s1,s2)	!strcmp(s1,s2)
#define copyn(s1,s2,n)	strncpy(s1,s2,n)

#define FIRST_LUN	2	/* first used lun in masterfile */
#define SYMLN		50	/* maximum length of symbol name */

/*
 *	event definitions
 */

#define NO_EVENT	0
#define LINE_BREAK	1
#define SUB_ENTRY	2
#define SUB_EXIT	3
#define PACK_ENTRY	4
#define PACK_EXIT	5
#define EXCEPTION	6



/* 
 *	TRACE/BREAK/DELETE command definitions
 */

#define SHOW		1
#define TRACE		2
#define BREAK		3
#define MY_DELETE		4
#define CALLS		0
#define LINES		1
#define EXPNS		2	/* exceptions */
#define POSSIBLE	3


/*
 *	external definitions
 */

extern int		size_display;
extern int		nr_steps;
extern int		breakflg;
extern int		contextflg;
extern int		stepflg;
extern int		pid;
extern int		intflg;
extern int		breakflg;
extern int 		stepflg;
extern long		nr_steps;

extern char		*inline();
extern char		command();

extern LIBDESC		*library;
extern short		main_lun;
extern int		quitflg;
extern int 		returnflg;
extern LUN		x;

