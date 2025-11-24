#define	OUT(s)		printout s
#ifdef COMMENT
#define	COM(x)		comment x
#else
#define	COM(x)
#endif COMMENT

#define	is_varrec(x)	((g_REC_flags (x) & VARREC) & g_REC_npaths (x) > 1)

/* Defines to push and pop environments.
 * A push should be done before visiting the locals of a block.
 * Pushing a subbody implies pushing a block.
 *
 * a statement is defined as the lifetime of a temp
 *
 */

#define	STAT_VARS 	MAXADDR	old_off

#define	TS_VARS		ac old_ts

#define	BLOCK_VARS 	STAT_VARS; ac old_block

#define	PROC_VARS	BLOCK_VARS; \
				MAXADDR old_maxoff; \
				ac old_proc

#define	PUSH_STAT	old_off = lev_off

#define	POP_STAT	lev_off = old_off

#define 	PUSH_TS(x)	\
			old_ts = curr_ts, \
			curr_ts = x

#define	POP_TS 		curr_ts = old_ts

#define	PUSH_BLOCK(x)	\
	 		old_off = lev_off, \
			old_block = curr_block, \
			curr_block = x

#define	POP_BLOCK	\
			lev_maxoff = max (lev_off, lev_maxoff),	\
			lev_off = old_off,	\
			curr_block = old_block

#define	PUSH_PROC(x)	\
	 		PUSH_BLOCK (x), \
			old_maxoff = lev_maxoff, \
			curr_level ++, \
			old_proc = curr_proc, \
			curr_proc = x

#define	POP_PROC	\
	 		POP_BLOCK, \
			lev_maxoff = old_maxoff, \
			curr_level --, \
			curr_proc = old_proc
	

#define	set_computed(x)	(s_flags (x, g_flags (x) | 0200))
#define	is_computed(x)	(g_flags (x) & 0200)

#define	is_filter(x)	(g_d (x) == XFILTER)


#define	VISITED		0x100
#define	BUSY		0x200

#define	SET(x,y)	s_flags (x, g_flags (x) | (y))
#define	UNSET(x,y)	s_flags (x, g_flags (x) & ~(y))
#define	TEST(x,y)	(g_flags (x) & (y))

#define	is_arec(x)	((g_REC_flags (x) & F_KIND) == A_REC)
#define	is_brec(x)	((g_REC_flags (x) & F_KIND) == B_REC)
#define	is_crec(x)	((g_REC_flags (x) & F_KIND) == C_REC)

#define	is_drec(x)	((g_REC_flags (x) & F_KIND) == D_REC)
#define	is_erec(x)	((g_REC_flags (x) & F_KIND) == E_REC)
#define	is_frec(x)	((g_REC_flags (x) & F_KIND) == F_REC)

#define	odd(x)		(x & 01)
#define	not_yet_processed(x)	((g_flags (x) & 010000) == 0)
#define	set_yet_processed(x)	(s_flags (x, (g_flags (x) | 010000)))

#define	is_variant(x)	(g_d (x) == XVARIANT)
#define	has_init(x)	(g_expr (g_desc (x)) != NULL)

#define	PUSH_H(x)	new_expr ();	\
	CALL (VOID);	\
		ICON (0, PF_INT, __HINIT);	\
		ICON (0, ADDRESS, x)

#define	POP_H	new_expr ();	\
	UCALL (VOID);	\
	   ICON (0, PF_INT, __HRESTORE)
