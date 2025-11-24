
struct l_el {
	int lv, hv, av;
	struct l_el *forelem, *backelem, *alink;
};

typedef	struct l_el	*listlink;



#include	<stdio.h>
#include	"../h/tree.h"
#include	"../h/std.h"
#include	"../h/put_tree.h"
#include	"../h/record_man.h"
#include	"../h/reader.h"
#include	"main.h"
#include	"front.h"
#include	"../h/rec_sizes.h"
#include	"../h/print.h"
#include	"../rt/dats.h"
#include	"../h/rt_types.h"
#include	"../rt/names.h"

#include 	"./h/consts.h"
#include 	"./h/pcc.h"
#include 	"./h/machdefs.h"
#include 	"./h/macros.h"
#include 	"./h/rt_funcs.h"




extern	ac		curr_block;
extern	bool		has_to_reset;
extern	ac		curr_proc;
extern	ac		curr_unit;
extern	int		curr_level;
extern	ac		curr_block;
extern	int		curr_line;
extern	MAXADDR		lev_off;
extern	MAXADDR		lev_maxoff;
extern	int 		gl_context;
extern	int		debug;
extern	FILE		*outfile;
extern	short		text_flag;
extern	char		*m_prog;
/* includes for local header files */

struct _context {
	ac	blk;
	bool	has_handler;
	bool	is_master;
	struct	_context *previous;
};

struct _accepts {
	ac	served_entry;
	ac	current_taskselect;
	struct _accepts *prev_accept;
};

extern	struct _accepts *ast;
extern struct _context *__context; /* in CGcode00.c */

struct _status_info {
	int code_context;
	bool has_done_task_init;
	bool must_do_task_init;
}; 

extern struct _status_info status_info; /* in CGcode00.c */
#define	s_code_context(x) 	status_info.code_context = x
#define g_code_context 	  	status_info.code_context
#define s_has_done_task_init(x)	status_info.has_done_task_init = x
#define g_has_done_task_init	status_info.has_done_task_init
#define s_must_do_task_init(x)	status_info.must_do_task_init = x
#define g_must_do_task_init	status_info.must_do_task_init

#define	NOTASK		0
#define	TASK		1


extern	ac	curr_ts;	/* declared in CGstor01.c	*/

#define	STATIC	

extern	int	tracelevel;
extern	char	*sourcefile;

#define	NOTRACE	0
#define	PROCTRACE	1
#define	BLOCKTRACE	2
#define	STATEMENTTRACE	3
#define	ADBTRACE	4


