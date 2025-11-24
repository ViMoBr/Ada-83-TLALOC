#
/*
 *	definitions for context bookkeeping 
*/

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

#define MAXCALLS	10

#define EXTRA_LETTER	'.'

/*
 *	structures for context
 */

/*
 *	body descriptor
 */

struct b_descr {
	long		b_start;
	long		b_end;
	int		b_event[POSSIBLE];
	struct b_descr *b_lup;		/* level access */
	struct b_descr *b_ldown;
	struct b_descr *b_lnext;
	struct b_descr *b_aup;		/* adres access */
	struct b_descr *b_adown;
	struct b_descr *b_anext;
	LLIST	       *b_bodylun;
	LLIST          *b_speclun;
	int	       *b_treeel;	/* pointer naar tree element */
	int		b_calls;
};

typedef struct b_descr	BODY;
typedef BODY		*BODY_P;
extern BODY bodylist;
extern LUN *proglun;
extern BODY_P st_current;


#define unitname(x) (x -> _unit._unit_name)
#define source_file(x) (x -> _unit. _names. source. _filename)
#define secs_file(x) (x -> _unit. _names. secs. _filename)
#define ll_flags(x)    (x -> _unit._flags)
#define has_secs(x) (!access (secs_file(x), RABLE) && *secs_file (x) != 0)


/*
 *	subprogram call descriptor
 */

struct call_block {
	struct call_block *c_prev;
	struct b_descr    *c_body;
};

typedef struct call_block *CALL;

/*
 *	block for call_blocks
 */

struct block {
	struct block		*f_block;
	struct block		*b_block;
	struct call_block	calls[MAXCALLS];
};

typedef struct block	BLOCK;


/*
 *	extern declarations
 */

extern	BODY_P		cur_body;

