#
/*
 *	specification of exported functions
 */
/*
 *	CGcode00.c defines:
 */
extern	void	gen_code ();
extern	void	gen_body ();
extern	void	gen_tbody ();
extern	void	stats_code ();
/*
 *	CGcode01.c defines
 */
extern	void	gen_assign	();
extern	void	gen_cond	();
extern	void	gen_init	();
extern	void	pop_env	();
extern	void	gen_subcall	();
extern	void	gen_typeinit	();
extern	void	gen_taskselect	();
extern	void	gen_abort	();
extern	void	gen_delay	();
/*
 *	CGcode02.c defines:
 */
extern	void	pre_code	();
extern	void	nam_pre_code	();
extern	void	call_pre_code	();
extern	void	scc_pre_code	();
extern	void	agg_pre_code	();
extern	void	code		();
/*
 *	CGcode03.c defines:
 */
extern	void	tconv_code	();
extern	void	lit_code	();
extern	void	exp_code	();
extern	void	in_code		();
extern	void	obj_code	();
extern	void	allo_code	();
extern	void	scc_code	();
/*
 *	CGcode04.c defines:
 */
extern	void	nelemcode	();
/*
 *	CGcode05.c defines:
 */
extern	bool	as_Ccall	();
extern	int	Get_Ccode	();
extern	void	do_Ccall	();
extern	void	hard_call	();
/*
 *	CGcode06.c defines:
 */
extern	void	parcheck_code	();
extern	void	as_ch_code	();
extern	void	rang_expr	();
extern	void	sm_ch_code	();
extern	void	subscripts	();
extern	void	pop		();
extern	short	push		();
extern	int	get_nr_of_constr	();
extern	void	constraint_code	();
/*
 *	CGcode07.c defines
 */
extern	void	allocate	();
extern	void	list_name	();
/*
 *	CGcode08.c defines
 */
extern	void	case_list	();
extern	listlink	new_cell	();
extern	void	insert	();
extern	void	rlist	();
extern	void	casecomp	();
/*
 *	CGcode09.c defines
 */
extern	void	gen_aggregate	();
extern	void	make_in_sub	();
/*
 *	CGcode10.c defines:
 */
extern	void	v_ranges	();
extern	void	cg_exception	();
extern	int	low_path	();
extern	int	high_path	();
extern	bool	is_act_discr	();
extern	bool	is_discdep	();
extern	ac	discrdescnode	();
extern	void	Xcrement	();
extern	int	obj_size	();
extern	bool	need_check	();
/*
 *	CGcode11.c defines:
 */
extern	void	task_init	();
extern	void	new_mas		();
extern	int	Moff		();
extern	int	MCoff		();
extern	void	M_CHAIN		();
extern	void	MASTER		();
extern	void	G_MOBJECT	();
extern	void	G_MNAME		();
extern	void	G_MCNAME	();
extern	int	non_triv_master	();
/*
 *	CGdesc00.c defines:
 */
extern	void	path_function	();
extern	void	enum_desc	();
extern	void	task_desc	();
extern	void	arr_desc	();
extern	void	rec_desc	();
extern	void	acc_desc	();
extern	void	sub_desc	();
/*
 *	CGdesc01 defines:
 */
extern	void	alloc_desc	();
extern	void	dat_alloc	();
extern	void	expval_store	();
extern	ac	discr_expr	();
extern	void	move	();
extern	void	lab_store	();
extern	void	do_recflds	();
extern	void	desc_address	();
extern	void	desc_const	();
extern	void	lit_store	();
/*
 *	CGdesc02.c defines:
 */
void	elemdesc	();
void	str_desc	();
void	DESCRIPTOR	();
void	mak_addressable	();
/*
 *	CGgpcc00.c defines:
 */
extern	void	printout	();
extern	void	init_outfile	();
extern	void	new_expr	();
extern	void	labconvert	();
extern	void	setdatalab	();
extern	void	deflab	();
extern	void	defdatalab	();
extern	void	textlab	();
extern	void	setexprlab	();
extern	void	defexprlab	();
extern	void	defgloblab	();
extern	void	TEXTLABCON	();
extern	void	PAR_OBJECT	();
extern	void	PAR_NAME	();
extern	void	ENTRY_PAR	();
extern	void	DYN_OBJECT	();
extern	void	LOC_OBJECT	();
extern	void	LOC_NAME	();
extern	void	get_stlink	();
extern	void	GLOB_OBJECT	();
extern	void	GLOB_NAME	();
extern	void	LNAME	();
extern	void	LICON	();
extern	void	P_BINARY	();
extern	void	P_TRINARY	();
extern	void	P_UNARY	();
extern	void	P_REG	();
extern	void	P_NAME	();
extern	void	P_CONST	();
extern	void	genjump	();
extern	void	pcc_deref	();
extern	int	pcc_size	();
extern	void	le	();
extern	void	ge	();
extern	void	sconv	();
extern	int	pcc_type_of	();
extern	void	PUT	();
extern	void	glob_init	();
extern	void	comment	();
extern	int	pointer_type_of	();
extern	short	max	();
extern	int	new_lab		();
/*
 *	CGmain00.c defines:
 */
extern	FILE	*yyin;
extern	FILE	*treefile;
extern	FILE	*outfile;
extern	int	tracelevel;
extern	int	sdb_code;

extern	int	line_no;

extern	char	*treename;
extern	char	*outname;
extern	char	*sourcefile;
extern	char	*m_prog;
extern	short	mainlun;
extern	void	sys_error	();
/*
 *	CGpred00.c defines:
 */
extern	bool	known_descriptor	();
extern	bool	isdiscrdepexp	();
extern	bool	is_table	();
extern	bool	is_composite	();
extern	bool	othersarray	();
extern	bool	is_ncomp	();
extern	bool	disc_dep	();
extern	bool	is_integer	();
extern	bool	is_scalar	();
extern	bool	pcc_float	();
extern	bool	is_small	();
extern	bool	is_stringlit	();
extern	bool	is_nulllit	();
extern	bool	is_reallit	();
extern	bool	is_basetype	();
extern	bool	istype		();
extern	bool	isoptfilter	();
extern	bool	is_recagg	();
extern	bool	has_call_block	();
extern	bool	is_lev_one	();
extern	bool	is_dollarname	();
extern	bool	is_unco	();
extern	bool	unco_value	();
extern	bool	alloc_1_value	();
extern	bool	is_typconv	();
extern	bool	check_needed	();
/*
 *	CGpred01.c defines:
 */
extern	bool	is_binary	();
extern	bool	is_inline	();
extern	bool	no_paramcheck	();
extern	bool	is_unc	();
extern	bool	as_chk	();
extern	bool	comp_ranges	();
extern	bool	eq_arrays	();
extern	bool	eq_records	();
extern	bool	throughcallblock	();
extern	bool	hasstatsize	();
extern	bool	nodescr_aggr	();
extern	bool	unco_agg	();

/*
 *	CGstor01.c defines:
 */
extern	bool	mainproc	();
extern	int	yyparse		();
extern	void	sto_expr	();
extern	void	show_storage	();
/*
 *	CGstor02.c defines:
 */
extern	MAXADDR	typeconv	();
extern	MAXADDR	aggregate	();
extern	MAXADDR	all		();
extern	MAXADDR	calling		();
extern	MAXADDR	taskselect	();
extern	MAXADDR entry		();
extern	MAXADDR	scc		();
extern	MAXADDR	slicing		();
extern	MAXADDR	attributing	();
extern	MAXADDR	subbody		();
extern	MAXADDR	taskbody	();
extern	MAXADDR	object		();
extern	MAXADDR	renobj		();
extern	MAXADDR	rectype		();
extern	MAXADDR	tasktype	();
extern	MAXADDR	arrtype		();
extern	MAXADDR	acctype		();
extern	MAXADDR	filter		();
extern	MAXADDR	subprogram	();
extern	MAXADDR	block		();
extern	MAXADDR	rensub		();
/*
 *	CGstor03.c defines:
 */
extern	MAXADDR	visit_local	();
extern	MAXADDR	incr_off	();
extern	MAXADDR	typeref		();
extern	MAXADDR	bittyperef	();
extern	MAXADDR	bitlocal	();
extern	MAXADDR	optfilter	();
extern	MAXADDR	optbitfilter	();
extern	MAXADDR	bitfilter	();
extern	MAXADDR	bitrange	();
extern	void	sav_stack	();
/*
 *	CGstor04.c defines:
 */
extern	int	paramoffset	();
extern	int	parameter_size	();
extern	int	val_size	();
extern	bool	static_or_discr	();
extern	short	getrgalloc	();
extern	short	getbrgflags	();
extern	short	getrgflags	();
extern	short	getexpflags	();
extern	short	getexpalloc	();
extern	short	getalloc	();
extern	short	getbitalloc	();
extern	short	getflags	();
extern	short	geteflags	();
extern	bool	ISVISITED	();
extern	bool	ISBUSY		();
extern	bool	SETBUSY		();
extern	bool	SETVISITED	();
extern	MAXADDR	align		();
extern	ac	enclsub		();
extern	short	getnform	();
/*
 *	CGstor05.c defines:
 */
extern	ac	stat_range	();
extern	long	ord		();
extern	long	low_int		();
extern	long	high_int	();
extern	long	loval		();
extern	long	hival		();
extern	bool	chk_val		();
extern	long	getvalue	();
extern	bool	isinchoices	();
extern	bool	is_inrange	();
extern	bool	isinbittype	();
extern	MAXADDR	rg_length	();
extern	long	getpar		();
extern	MAXADDR	getvalsize	();
extern	MAXADDR	sz_val		();
extern	MAXADDR	sz_bitval	();
extern	MAXADDR	al_bitval	();
extern	MAXADDR	sz_arrval	();
extern	MAXADDR	sz_recval	();
extern	MAXADDR	sz_varval	();
extern	MAXADDR	getvdsize	();
extern	MAXADDR	sz_cb		();
extern	MAXADDR	sz_cdbit	();
extern	MAXADDR	sz_tdarr	();
extern	MAXADDR	sz_tdtask	();
extern	MAXADDR	sz_tdacc	();
extern	MAXADDR	sz_tdrec	();
extern	MAXADDR	sz_tdsrec	();
extern	MAXADDR	sz_vdarr	();
extern	MAXADDR	sz_cdacc	();
extern	MAXADDR	sz_vdrec	();
/*
 *	CGstor06.c defines:
 */
extern	ac	list_element	();
extern	int	filkind		();
extern	int	stor_class	();
extern	int	off		();
extern	int	level_of	();
extern	ac	surrounding_block	();
extern	int	get_stacktop	();
extern	int	cboffset	();
extern	bool	has_Voff	();
extern	MAXADDR	Voff		();
extern	bool	has_Doff	();
extern	MAXADDR	Doff		();
extern	ac	get_type	();
extern	ac	get_discr	();
extern	ac	root_type	();
extern	ac	base_subtype	();
extern	ac	basefilter	();
extern	ac	bf_type		();
extern	int	disc_num	();
/*
 *	CGstor07.c defines:
 */
extern	bool	is_master	();
extern	bool	has_tasks	();
extern	MAXADDR	alloc_master	();
extern	int	T_stor_class	();
extern	MAXADDR	current_env_to_master	();
/*
 *	CGtrac00.c defines:
 */
extern	void	genstattrace	();
extern	void	genproctrace	();
extern	void	sdb_proc	();
extern	void	sdb_block	();
extern	void	sdb_end		();
extern	void	sdb_procend	();

extern	int		sdb_code;
