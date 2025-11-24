#
#define	MARKSIZE	2
#define	MAXLUN		30
#define	MAX_INCORE	5000
#define	INDENT 2
extern	short	col;
/*
 * record operations
 *
 *
 *	record_man.h  record_manager
 */
extern	void	tree_init	();
extern	void	open_rec	();
extern	void	close_rec	();
extern	ac	l_alloc	();
extern	ac	alloc_lit	();
extern	void	lit_io	();
extern	ac	get_rec	();
extern	void	put_rec	();
extern	void	put_mark	();
extern	void	new_lun	();
extern	void	next_lun	();
extern	short	nindex	();
extern	ac	old_alloc	();
extern	ac	alloc	();
extern	void	delete_rec	();
extern	void	del_rec	();
extern	void	del_tag	();
extern	short	lun_of	();
extern	short	index_of	();
extern	void	std_init	();
extern	void	p_init	();
extern	void	rec_io	();
extern	void	set_to	();

extern	short	mainlun;


