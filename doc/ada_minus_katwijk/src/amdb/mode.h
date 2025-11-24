#

/*
 *	definitions for debugger command mode's
 */

/*
 *	MODE definitions
 */

#define MAINMODE	0
#define RUNMODE		1
#define TRACEMODE	2
#define BREAKMODE	3
#define DELETEMODE	4
#define PRINTMODE	5

/*
 *	mode descriptor
 */

struct mode_descr {
	char	*mode_name;
	int	 mode_flag;
};

typedef struct mode_descr MODE;

/*
 *	extern definitions
 */

extern	MODE	*c_mode;	/* current mode pointer */

extern  int	size_display;	/* size of output region (17 or 19 lines) */
