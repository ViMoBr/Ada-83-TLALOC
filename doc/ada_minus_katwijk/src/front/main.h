#
/*
 *	Main.c
 */
extern	void	libv_init	();
extern	void	cat_to		();
extern	char	*tmpvec		();
extern	char	*add_tmpvec	();
extern	void	s_add		();
extern	void	s_d_add		();
extern	void	d_add		();
extern	void	init_tempfile	();
extern	void	print_names	();
extern	void	error		();
extern	void	sys_error	();
extern	void	warning		();
extern	void	proc_tree	();
extern	void	do_backend	();
extern	void	say_start	();
extern	void	new_s		();
extern	void	old_s		();

extern	int	errors;
extern	int	verbose;
extern	char	*m_prog;
extern	short	mainlun;
/*
 *	Importing:
 */
extern	int	yylineno;		/* Imported from lex scanner */
extern	char	*t_name		();
extern	char	*a_name		();
extern	char	*o_name		();
extern	char	*strrchr	();

