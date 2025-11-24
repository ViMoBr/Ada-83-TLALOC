/*	The tree nodes, ddefined as a union	*/
union tree_element {
struct _acctype {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	actype;
	short	ACC_alloc;
	MAXADDR	ACC_offset;
	short	ACC_nform;
	short	ACC_flags;
} _acctype;

struct _aggregate {	/* kind of aggregate in flags */
	discr d;	short flags;	short	lineno;
	ac	aggtype,
	   fcompas;
	ac	context;
	short	AGG_flags;
	short	AGG_alloc;
	MAXADDR	AGG_Doff,
		AGG_Voff;
	short	AGG_tablab;
	MAXADDR	AGG_offset;
	short	AGG_index;
} _aggregate;

struct _all {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	types;
	MAXADDR	ALL_Doff,
		ALL_Voff;
} _all;

struct _allocator {	/* obtype is inclusive constrashorts */
	discr d;	short flags;	short	lineno;
	ac	altype,
	   obtype;
	MAXADDR ALLO_Doff,
		ALLO_Toff;
} _allocator;

struct _arraytype {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	elemtype;
	ac	findex;
	short	ARR_alloc;
	short	ARR_flags;
	short	ARR_offset;
	short	ARR_vdsize;
	short	ARR_ndims;
} _arraytype;

struct _assign {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	lhs,
	   rhs;
} _assign;

struct _attribute {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	types;
	ac	entity;
	short	attr_value;
	MAXADDR	ATTR_Doff;
} _attribute;

struct	_entrycall {
	discr	d;	short	flags;	short	lineno;
	ac	next;
	ac	types;
	ac	fact;
	short	e_num;
	ac	e_entry;	/* entry to be called	*/
	ac	call_delay;	/* delay		*/
	ac	call_stats;	/* "else" or "delay" stats	*/
	ac	call_next;	/* then part		*/
} _entrycall;

struct _block {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	fblockloc;
	ac	BLK_stats;
	ac	BLK_exh;
	MAXADDR	BLK_SToff;
	MAXADDR	BLK_Moff;
	MAXADDR	BLK_MCoff;
} _block;

struct _call {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	types;
	ac	fact;
	MAXADDR CALL_Doff;
	MAXADDR CALL_Voff;
} _call;

struct _callthunk {
	discr d;	short flags;	short	lineno;
	ac	thunk;
} _callthunk;

struct _case {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	caseexpr;
	ac	CASE_items;
	MAXADDR	CASE_Voff;
} _case;

struct _taskselect {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	SELECT_items;
	short	SEL_actuals;
	short	SEL_caller;
	short	SEL_count;
} _taskselect;

struct _charlit {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	short	enuml_ord;
} _charlit ;

struct _compassoc {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	fcompchoice,
		compexpr;
	short 	CPA_exprlab;
} _compassoc;

struct _discr {
	discr d;	short flags;	short	lineno;
	ac	comp;
} _discr;

struct _discrcons {
	discr d;	short flags;	short	lineno;
	ac	aggregate;
} _discrcons;

struct _enumlit {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	short	enuml_ord;
} _enumlit;

struct _enumtype {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	fenumlit;
	short	nenums;
} _enumtype;

struct _exception {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	rnam;
} _exception;

struct _exhandler {
	discr d;	short flags;	short	lineno;
	ac	EXH_items;
} _exhandler;

struct _exit {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	loopid,
		exitcond;
} _exit;

struct _exp {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	exptype,
		primary;
} _exp;

struct _filter {
	discr d;	short flags;	short	lineno;
	ac	next;	/*dummy */
	short	prev;
	ac	filtype,
		constraint;
	short	FLT_alloc;
	short	FLT_flags;
	MAXADDR	FLT_offset,
		FLT_valsize,
		FLT_vdoffset;
} _filter;

struct _forblock {	/* direction of iteration in flags */
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	looppar;
	ac	FB_stats;
	short	FB_lab;
} _forblock;

struct _gennode {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	genpars;
	ac	gendum;
	ac	genunit;
} _gennode;

struct _genpartype {
	discr	d;	short	flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	short	genkind;
} _genpartype;

struct _goto {
	discr d;	short flags;	short	lineno;
	ac	lab;
} _goto;

struct _if {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	IF_items;
} _if;

struct	_delay {
	discr	d;	short	flags;	short	lineno;
	ac	next;
	ac	delay_expr;
} _delay;

struct _terminate {
	discr	d;	short	flags;	short	lineno;
	ac	next;
} _terminate;

struct _foruse {
	discr	d;	short	flags;	short	lineno;
	ac	next;
	short	prev;
	ac	forused;
	ac	useexpr;
} _foruse;

struct _abortstat {
	discr	d;	short	flags;	short	lineno;
	ac	next;
	ac	abortedtask;
} _abortstat;

struct _ifitem {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	ifcond;
	ac	IF_stats;
} _ifitem;

struct _in {		/* not in in flags	*/
	discr d;	short flags;	short	lineno;
	ac	inexpr,
		intype;
} _in;

struct _incomplete {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	complete,
		fidiscr;
} _incomplete;

struct _index {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	indextype;
} _index;

struct _indexcons {
	discr d;	short flags;	short	lineno;
	ac	frange;
} _indexcons;

struct _indexing {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	types;
	ac	entity;
	ac	farg;
} _indexing;

struct _indirect {
	discr d;	short flags;	short	lineno;
	ac	indir;
} _indirect;

struct _internal {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	xxx2;	/* dummy		*/
	ac	type_spec;
	byte	ind;
} _internal;

struct _labdef {
	discr d;	short flags;	short	lineno;
	ac	labeldecl;
} _labdef;

struct _literal {
	discr d;	short flags;	short	lineno;
	ac	littype;
	lit_ptr val;
	MAXADDR	LIT_Voff;
	MAXADDR	LIT_Doff;
} _literal;

struct _loopblock {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	looplocals;
	ac	cond;
	ac	LPB_stats;
	short	LPB_lab;
} _loopblock;

struct _mark {
	discr d;	short flags;	short	lineno;

} _mark;

struct _newtype {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	old_type;
	short	mark;
	ac	enlits;
} _newtype;

struct _inherit {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	xxyy;		/* plain dummy	*/
	ac	old_type;
	ac	inh_type;
	ac	inh_oper;
	short	is_hidden;
} _inherit;

struct _name {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	types;
	ac	fentity,
	   foperation;
} _name;

struct _namedass {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	parname,
	   nexp;
} _namedass;

struct _objdesc {	/* object kind in flags	*/
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	ac	objtype,
	   expr;
} _objdesc;

struct _object {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	object_spec;
	ac	desc;
	short	OBJ_alloc;
	MAXADDR	OBJ_offset;
	MAXADDR OBJ_descoff;
} _object;

struct _package {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	fvisitem;
	ac	priv;
	ac	pack_body;
	MAXADDR	PS_Moff;
	MAXADDR	PS_MCoff;
} _package;

struct _tasktype {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	fentry;
	ac	taskbody;
	short	TSKT_alloc;
	MAXADDR	TSKT_offset;
	short	TSKT_flags;
} _tasktype;

struct _packbody {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	specif,
	   fbodyloc;
	ac	PB_stats;
	ac	PB_exh;
	MAXADDR	PBDY_SToff;
	MAXADDR	PB_Moff;
	MAXADDR	PB_MCoff;
} _packbody;

struct _parenths {
	discr d;	short flags;	short	lineno;
	ac	subexpr;
} _parenths;

struct _privpart {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;	/* i.e. the package specification */
	ac	fprivitem;
} _privpart;

struct _privtype {	/* limited flag in flags	*/
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	fpdiscr,
	   impl;
} _privtype;

struct _raise {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	exception;	/* indirect */
	ac	exc_task;
} _raise;

struct _range {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	rangetype,
	   frang_exp;
} _range;

struct _rectype {
	discr d;	short flags;	short	lineno;
	ac	next;
	short prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	ffield,
	   fvariant,
	   dis;
	short	REC_alloc;
	short	REC_flags;
	MAXADDR	REC_offset;
	short	REC_forms;
	short	REC_vdsize;
	short	REC_nflds,
		REC_ninits,
		REC_npaths,
		REC_maxpfld,
		REC_vsize;
	short	REC_pathf;
} _rectype;

struct _renobj {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	rentype,
	   name;
	short	ROBJ_alloc;
	MAXADDR	ROBJ_offset;
} _renobj;

struct _renpack {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	renname;
} _renpack;

struct _rensub {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	fformal, rettype;
	ac	subname;
} _rensub;

struct _return {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	enclsub,
	   retexpr;
} _return;

struct _scc {
	discr d;	short flags;	short	lineno;
	bool andthen;
	ac	fsccexpr;
	MAXADDR SCC_Voff;
} _scc;

struct _select {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	types;
	ac	entity;
} _select;

struct _set {
	discr d;	short flags;	short	lineno;
	ac	fsetelem,
		iter_ptr;
} _set;

struct	_separate {
	discr d;	short	flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;		
	ac	stub;
	ac	septree;
} _separate;

struct _setelem {	/* code in flags */
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	elem;
} _setelem;

struct _slice {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	types;
	ac	slrange;
	MAXADDR SLI_Doff;
} _slice;

struct	_stub {
	discr	d; short	flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;		
	ac	enclunit;
	ac	stub_spec;
} _stub;

struct _stringlit {
	/* see dutinfa!docs/stringlit */
	discr d;	short flags;	short	lineno;
	ac	littype;
	lit_ptr	val;
	MAXADDR LIT_Voff;
	MAXADDR LIT_Doff;
} _stringlit;

struct _sub {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	fformal;
	ac	rettype;
	ac	body_imp;
	ac	sub_default;
	MAXADDR	SUBS_retoff;
	short	SUBS_alloc;
	MAXADDR	SUBS_offset;
} _sub;

struct _entry {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	fformal;
	ac	rettype;
	short	entry_nr;
	ac	ENTR_all;
	short	ENTR_off;
} _entry;

struct _subbody {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	specif,
	   fbodyloc;
	ac	SBB_stats;
	ac	SBB_exh;
	short	SBB_level;
	MAXADDR	SBB_valoff;	/* return value		*/
	MAXADDR	SBB_Moff;	/* master offset	*/
	MAXADDR	SBB_MCoff;
} _subbody;

struct _taskbody {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	specif,
	   fbodyloc;
	ac	task_stats;
	ac	task_exh;
	MAXADDR	TSB_Moff;	/* master offset	*/
	MAXADDR	TSB_MCoff;
	short	TSB_level;
} _taskbody;

struct _accept {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;	/* a dummy, really	*/
	ac	enclunit;
	ac	specif;
	ac	accept_stats;
} _accept;

struct _subcall {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	subpr;
} _subcall;

struct _subtype {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	enclunit;
	ac	type_spec;
	ac	parenttype;
} _subtype;

struct _tagstat {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	t_stat;
} _tagstat;

struct _thunk {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	ac	thexpr;
	short	TH_exprlab;
	short	TH_levlab;
} _thunk;

struct _typeconv {
	discr d;	short flags;	short	lineno;
	ac	newtype,
	   convexpr;
	MAXADDR	TCON_Doff;
} _typeconv;

struct _use {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	packname;
} _use;

struct	_unresrec {
	discr d;	short flags;	short	lineno;
	ac	next;
	char	*ident;
} _unresrec;

struct	_unreschar {
	discr	d;	short	flags;	short	lineno;
	ac	next;
	char	*ident;
} _unreschar;

struct _variant {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;	/* dummy	*/
	ac	enclunit;
	ac	xxxx;	/* dummy	*/
	ac	ffield,
	   fvariant,
	   dis,
	   varchoice;
	short	VAR_ffld,
		VAR_fpath,
		VAR_fqfld;
} _variant;

struct _whenitem {
	discr d;	short flags;	short	lineno;
	ac	next;
	ac	fwhenchoice;
	ac	WI_stats;
} _whenitem;

struct _with {
	discr d;	short flags;	short	lineno;
	ac	next;
	short	prev;
	char	*tag;
	ac	withunit;
} _with;

struct _qualif {
	discr d;	short flags;	short	lineno;
	ac	qualtype;
	ac	qualexpr;
} _qualif;

struct _triple {
	discr d;	short flags; short	lineno;
	ac	next;
	ac	tripsub;
	ac	triptype;
	ac	tripdtype;
	ac	tripnext;
	ac	tripmark;
} _triple;

};
/* end of union sluithaak */
