#
/*
 *	reading a set of library modules
 */
struct	lib_unit {
	int	lib_kind;
	struct lib_unit *next_unit;
	ac	unit;
	ac	with_list;
};

extern struct lib_unit *lib_head;

struct tree_header {
	short	tr_magic;
	long	tr_date;
	short	tr_lun;
	short	tr_nindex;
};

extern	ac	find_unit ();
extern	void	rd_standard ();
