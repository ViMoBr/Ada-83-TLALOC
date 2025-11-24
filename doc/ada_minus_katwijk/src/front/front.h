#
/*
 *	front.h
 *
 *	Common pass1 constants and definitions
 *
 */

#define	MAKSIZE	100
#define	COMP_EXPR	1
#define	COMP_ASSOC	2
#define	COMP_OTHERS	3

#define	PAR_EXPR	1
#define	PPP_NAME	2

#define S_AND_THEN	(-1)
#define S_OR_ELSE	(-2)

#define	CH_LIT		(0)
#define	ID_OPSYM	(2)

extern	char *inter_file;
#define	selkind(x)	(g_flags (x) & 02)
extern	FILE *yyin;

struct	resword {
char	*stringrep;
int	res_value;
};

extern	struct resword	res_word [];

#define	MAX_RESW	62	/*bah, bah bah	*/
/*
 *	for aggregate visiting
 */
#define	set_visited(x)	(s_flags (x, g_flags (x) | 010))
#define	is_visited(x)	(g_flags (x) & 010)
#define	unvisit(x)	(s_flags (x, g_flags (x) & ~010))

typedef struct _linkelem *p_link;

struct _linkelem {
	p_link forward, backwards;
	ac data;
} ;
#define	A_TYPE		01
#define	A_SUBTYPES	02
#define	A_OBJECT	04


#define	TRIPSIZE	sizeof (TRIP)
#define	MAXPARS	16

#define	is_body(x)	(g_d (x) == XTASKBODY \
                        || g_d (x) == XSUBBODY \
			|| g_d (x) == XPACKBODY)
/*
 *	1A02.c defines:
 */
extern	char	*string_to_tag	();
extern	char	*mk_tag		();
extern	char	std_oper	();
extern	char	*chk_char	();
extern	bool	dyadic		();
extern	bool	monadic		();
extern	bool	eq_tags		();
extern	char	*tag_of		();
extern	int	srch_attr	();
extern	int	srch_resw	();
extern	void	in_antag	();
extern	char	*gen_tag	();
extern	bool	is_and_then	();
extern	char	*char_tag	();
extern	char	*mk_chartag	();
extern	bool	is_NOT_EQ	();
extern	void	IInit		();
extern	void	do_pragma_0	();
extern	void	do_pragma_1	();
extern	void	do_pragma_2	();
extern	void	do_pragma_3	();
/*
 *	1A03.c defines:
 */
extern	void	component_ordering	();
extern	bool	param_order	();
extern	void	set_indices	();
extern	ac	conv_array	();
extern	void	withprocess	();
extern	ac	static_range	();
extern	ac	get_loop	();
extern	void	intro_ex_h	();
extern	bool	is_in_ex_h	();
extern	ac	mak_delay	();
extern	ac	mak_inf_delay	();
extern	void	CHECK_OPTIDENT	();
extern	ac	call_std_function	();
extern	void	NO_DISCRS	();
extern	ac	IS_SCALAR	();
extern	ac	packspec	();
extern	void	ch_funpars	();
extern	char	*mak_nam		();
extern	bool	sep_pb		();
extern	bool	sep_sub		();
extern	bool	sep_tb		();
extern	void	chk_exceptions	();
extern	ac	STATIC_EXPR	();
extern	ac	chk_varname	();
extern	void	on_intro	();
extern	void	off_intro	();
extern	int	acceptable	();

/*
 *	1A04.c defines:
 */
extern	ac	bu_name		();
extern	ac	td_proc		();
extern	ac	td_name		();
extern	ac	td_n_name	();
extern	ac	td_n_nm		();
extern	ac	td_n_attrib	();
extern	ac	SOLVE_EXPR	();
extern	ac	solve_expr	();
extern	ac	td_assign	();

/*
 *
 *	1A05.c defines:
 */
extern	ac	bu_expr		();
extern	ac	td_expr		();

/*
 *
 *	1A06.c defines:
 */
extern	ac	SOLVE_FILTER	();
extern	ac	TD_FILTER	();
extern	ac	td_filter	();
extern	ac	td_discr	();
extern	ac	td_indexcons	();
extern	ac	bu_filter	();
extern	bool	is_tpconv	();
extern	ac	td_range	();
/*
 *	1A07.c defines:
 */
extern	ac	next_def	();
extern	ac	get_locallist	();
extern	bool	eq_subs		();
extern	bool	eq2_subs	();
extern	ac	FIND_RENAMEDSUBS	();
extern	ac	FIND_SUBSPEC	();
extern	ac	FIND_PACKSPEC	();
extern	ac	FIND_TASKSPEC	();
extern	ac	FIND_ENTRY	();
extern	ac	get_pbstub	();
extern	ac	get_tbstub	();
extern	ac	get_sstub	();
extern	bool	need_entering	();
extern	bool	does_hide	();
extern	bool	donotlike	();
extern	bool	skip		();
extern	void	open_U		();
extern	void	p_proc		();
extern	char	*procname	();
/*
 *
 *	1A08.c defines:
 */
extern	void	INTRODUCE	();
extern	void	introduce	();
extern	ac	NEWSCOPE	();
extern	ac	new_env		();
extern	void	DELSCOPE	();
extern	void	restore_env	();
extern	void	LIST_INTRO	();
extern	void	LIST_CHECK	();
extern	void	SUBDECL		();
extern	void	OBJDECL		();
extern	void	PREDECL		();
extern	void	POSTDECL	();
extern	bool	enum_check	();
extern	void	DECL_CHECK	();
extern	ac	decl_tagstat	();
extern	void	inherit		();
/*
 *
 *	1A09.c defines:
 */
extern	ac	encl_rectype	();
extern	ac	act_list	();
extern	void	l_insert	();
extern	void	rem_list	();
extern	p_link	new_list	();
extern	bool	verif_domain	();
extern	void	CHECK_VARIANT	();
extern	ac	agg_field	(); 
extern	ac	rec_agg		();
extern	bool	unco_arr	();
extern	ac	arr_agg		();
/*
 *	1A10.c defines
 */
extern	ac	smallest_int	();
extern	long	low_int		();
extern	long	high_int	();
extern	char	valofchar	();
extern	ac	cp_value	();
extern	ac	stat_range	();
extern	long	ord		();
extern	int	small_val	();
extern	int	larg_val	();
extern	bool	in_range	();
extern	ac	repl_func	();
extern	ac	try_attrib	();
extern	void	coerce_filter	();
extern	ac	try_scc		();
/*
 *	1A11 defines
 */
extern	ac	nalloc		();
extern	ac	mk_abort	();
extern	ac	mk_component	();
extern	ac	mk_charlit	();
extern	ac	mk_sbody	();
extern	ac	mk_pbody	();
extern	ac	mk_tbody	();
extern	ac	mk_task	();
extern	ac	mk_tselect	();
extern	ac	mk_accept	();
extern	ac	mk_with	();
extern	ac	mk_subtype	();
extern	ac	mk_filter	();
extern	ac	mk_assign	();
extern	ac	mk_use	();
extern	ac	mk_stub	();
extern	ac	mk_package	();
extern	ac	mk_prpart	();
extern	ac	mk_exception	();
extern	ac	mk_object	();
extern	ac	mk_acctype	();
extern	ac	mk_recnode	();
extern	ac	mk_privtype	();
extern	ac	mk_generic	();
extern	ac	mk_genpartype	();
extern	ac	mk_incomplete	();
extern	ac	mk_enum	();
extern	ac	mk_enlit	();
extern	ac	mk_array	();
extern	ac	mk_rsel	();
extern	ac	mk_varnode	();
extern	ac	mk_dcons	();
extern	ac	mk_sub	();
extern	ac	mk_entry	();
extern	ac	mk_ecall	();
extern	ac	mk_renobj	();
extern	ac	mk_renpack	();
extern	ac	mk_aggnode	();
extern	ac	mk_in	();
extern	ac	mk_literal	();
extern	ac	mk_alloc	();
extern	ac	mk_attr	();
extern	ac	mk_namass	();
extern	ac	mk_whenitem	();
extern	ac	mk_if	();
extern	ac	mk_ifitem	();
extern	ac	mk_block	();
extern	ac	mx_name		();
extern	ac	mk_loopblock	();
extern	ac	mk_forblock	();
extern	ac	mk_icons	();
extern	ac	mk_exit	();
extern	ac	mk_return	();
extern	ac	mk_parexpr	();
extern	ac	mk_raise	();
extern	ac	mk_newtype	();
extern	ac	mk_separate	();
extern	ac	mk_index	();
extern	ac	mk_thunk	();
extern	ac	mk_rensub	();
extern	ac	mx_all		();
extern	ac	mk_all		();
extern	ac	mk_sbcall	();
extern	ac	mk_case		();
extern	ac	mk_range	();
extern	ac	mk_first	();
extern	ac	mk_last		();
extern	ac	mk_expr		();
extern	ac	mk_desc		();
extern	ac	mk_andthen	();
extern	ac	mk_select	();
extern	ac	mx_typeconv	();
extern	ac	mx_ecall	();
extern	ac	mk_call	();
extern	ac	mk_slice	();
extern	ac	mx_call		();
extern	ac	mk_delay	();
extern	ac	mk_unresrec	();
extern	ac	mx_slice	();
extern	ac	mk_arrselect	();
extern	ac	mk_applied	();
extern	ac	mk_unchar	();
extern	ac	mk_subcall	();
extern	ac	mk_foruse	();
/*
 *	1A12 defines
 */
extern	void	sc_int		();
extern	void	sc_real		();
extern	void	sc_b_int	();
extern	void	sc_b_real	();
extern	int	sc_strlen	();
/*
 *	1A13 defines
 */
extern	ac	get_triple	();
extern	ac	reduce_triples	();
extern	ac	red_tripset	();
extern	void	pr_tripels	();
extern	void	del_tripels	();
extern	ac	eff_rettype	();
extern	ac	cat_trips	();
extern	ac	chk_sub	();
extern	ac	pl_call	();

/*
 *	1A14 defines:
 */
extern	bool	is_singleton	();
extern	ac	first		();
extern	ac	next_elem	();
extern	bool	is_empty	();
extern	ac	join		();
extern	void	del_set		();
extern	ac	add_set		();
extern	bool	is_element	();
extern	ac	copy		();
extern	ac	exptype_copy	();
/*
 *	1A15 defines
 */
extern	bool	is_private_constant	();
extern	bool	is_local_private	();
extern	bool	is_sizeable 	();
extern	bool	is_accesstype 	();
extern	bool	has_eq_and_ass 	();
extern	bool	is_assignable 	();
extern	bool	has_slicing 	();
extern	bool	has_selection 	();
extern	bool	has_indexing 	();
extern	bool	has_calling 	();
extern	bool	has_indexconstraint 	();
extern	bool	has_discriminantconstraint 	();
extern	bool	is_scalar 	();
extern	bool	is_float 	();
extern	bool	is_numerical 	();
extern	bool	is_basetype 	();
extern	bool	has_type 	();
extern	bool	is_type 	();
extern	bool	is_object 	();
extern	bool	is_enumlit 	();
extern	bool	is_charlit 	();
extern	bool	is_sub 		();
extern	bool	is_sttype 	();
extern	bool	is_paramless 	();
extern	bool	is_entype 	();
extern	bool	is_strtype	();
extern	bool	is_someinteger 	();
extern	bool	is_bool_vect 	();
extern	bool	is_sc_vector 	();
extern	bool	is_anytype 	();
extern	bool	is_call 	();
extern	bool	is_others 	();
extern	bool	is_derived 	();
extern	bool	is_stringlit 	();
extern	bool	is_stringtype 	();
extern	bool	is_object_or_value 	();
extern	bool	is_tpname 	();
extern	bool	is_name 	();
extern	bool	is_ecall 	();
extern	bool	is_positional 	();
extern	bool	is_loop 	();
/*
 *	1A16 defines
 */
extern	bool	eq_types	();
extern	bool	sub_equal	();
extern	bool	ch_select	();
extern	bool	chk_slice	();
extern	bool	chk_index	();
extern	bool	in_spec		();
extern	bool	chk_typeconv	();
extern	bool	td_tpconv	();
extern	bool	match_univ	();
extern	void	no_eq_and_ass_in	();
extern	bool	may_have_aggregate	();
extern	void	chk_6_7_5	();
extern	void	chk_6_7_4	();
extern	ac	chk_task	();
extern	bool	is_taskobject	();
extern	bool	is_subprogram	();
extern	bool	has_defaults	();
extern	ac	rettype		();
/*
 *	1A17 defines:
 */
extern	ac	add_new		();
extern	ac	td_reduce	();
extern	ac	reduce		();
extern	ac	propagate	();
extern	ac	type_of		();
extern	ac	types_of	();
extern	ac	base_type	();
extern	ac	bsf_type	();
extern	ac	rootfilter	();
extern	ac	CONST_TYPE	();
extern	bool	arr_typesmatching	();
extern	ac	select		();
extern	ac	c_object	();
extern	void	insert_all	();
extern	ac	get_formal	();
extern	ac	get_pformal	();
extern	ac	res_pparam	();
extern	ac	res_param	();
extern	void	set_sttype	();
extern	ac	en_type		();
extern	ac	fenum_of	();
extern	ac	f_formal	();
extern	ac	get_indextype	();
extern	ac	restypes	();
extern	ac	get_arraytype	();
extern	ac	get_slicetypes	();
extern	ac	get_selecttype	();
extern	ac	dereftype	();
extern	ac	do_deref	();
extern	bool	is_constant	();
extern	ac	repl_name	();
extern	ac	get_loop	();
extern	ac	sub_name	();
extern	ac	simple_name	();
extern	ac	get_exc		();
extern	ac	c_typename	();
extern	ac	type_name	();
extern	ac	pack_name	();
extern	ac	st_range	();
extern	ac	get_name_from_expr	();
/*
 *	1A18 defines
 */
extern	ac	instantiate	();
extern	ac	find_ops	();
/*
 *	1A19 defines
 */
extern	void	i_open_scopes	();
extern	int	new_lev		();
extern	void	del_lev		();
extern	bool	being_used	();
extern	int	get_scope	();
extern	void	new_scope	();
extern	void	del_scope	();
extern	void	add_def		();
extern	void	ad_defs		();
extern	ac	loc_iterate	();
extern	ac	loc_char	();
extern	ac	loc_lookup	();
extern	void	new_use		();
extern	ac	encl_sub	();
extern	ac	encl_loop	();
extern	ac	encl_taskbody	();
extern	ac	open_scopes	();
extern	bool	is_openscope	();
extern	ac	look_id		();
extern	ac	look_char	();
extern	void	new_start	();
/*
 *	1A20 defines
 */
extern	ac	cp_tree		();
extern	ac	expand		();
#
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
extern	char	*Get_Ccode	();
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
extern	char	*name_of_ctype	();
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

extern	bool	sdb_code;
