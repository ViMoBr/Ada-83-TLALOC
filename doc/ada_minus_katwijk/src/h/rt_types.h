/*
 * implementations of descriptors used in execution time
 * The layouts of the descriptors are based on the
 * formats given in "Descriptors for DAS".
 * (this file is used by cg_sizes.c to allocate space)
 */


/* define a pointer to run time structs */
struct rt_any {
	TG_long		dtag;
	TG_ADDR		ttp;
};
typedef struct rt_any	*RT_ANY;
#define	XX_ANY(x)	((struct rt_any *) x)

/* type template for task type */

#define XX_TSK(x)	((struct tt_tsk *) x)
struct tt_tsk {
	TG_long	dtag;		/* usual tag			*/
	TG_long	prio;		/* priority			*/
	TG_long	storsize;	/* default storage size		*/
	TG_ADDR	addr;		/* start address		*/
	TG_ADDR	st_link;	/* st_link of environment 	*/
};

typedef struct tt_tsk	*TTDP;
#define	XX_TTDP(x)	((struct tt_tsk *) x)

#define	TT_TSK_DTAG		0 * TLONGSIZE
#define	TT_TSK_PRIO		1 * TLONGSIZE
#define TT_TSK_MEMSIZE		2 * TLONGSIZE
#define TT_TSK_ADDR		3 * TLONGSIZE
#define TT_TSK_ST_LINK		4 * TLONGSIZE


/* location descriptor for scalar type */

#define	XD_BIT(x)	((struct ld_bit *) x)
struct ld_bit {
	TG_long		dtag;
	TG_long		cd_bitind;
	struct ld_range {
		TG_long		cd_lo;
		TG_long		cd_hi;
	} ld_r;
};
#define	LD_BIT_DTAG		0 * TLONGSIZE
#define	LD_BIT_BITIND		1 * TLONGSIZE
#define	LD_BIT_LO		2 * TLONGSIZE
#define	LD_BIT_HI		3 * TLONGSIZE


/* type template for array type */

#define	XX_ARR(x)	((struct tt_arr *) x)
struct tt_arr {
	TG_long		dtag;
	TG_long		td_ndims;
	TG_long		td_aflags;
	TG_ADDR		td_e_cdp;
	TG_ADDR		td_ixrp[DYNAMIC];	/* ndims */
};
#define	TT_ARR_DTAG		0 * TLONGSIZE
#define	TT_ARR_NDIMS		1 * TLONGSIZE
#define	TT_ARR_AFLAGS		2 * TLONGSIZE
#define	TT_ARR_E_CDP		3 * TLONGSIZE
#define	TT_ARR_IXRP		3 * TLONGSIZE + TADDRSIZE


/* location descriptor for array type */

#define	XD_ARR(x)	((struct ld_arr *) x)
struct ld_arr {
	TG_long		dtag;
	TG_ADDR		ttp;
	TG_long		vd_vsize;
	TG_long		vd_e_size;
	struct ld_arri {
		TG_long	vd_i_lo;
		TG_long vd_i_hi;
	} ld_i_x[DYNAMIC];	/* ndims */
};
#define	LD_ARR_DTAG		0 * TLONGSIZE
#define	LD_ARR_TTP		1 * TLONGSIZE
#define	VD_SIZE			(1 * TLONGSIZE + TADDRSIZE)
#define	LD_ARR_ESIZE		(2 * TLONGSIZE + TADDRSIZE)
#define	LD_ARR_I_X		(3 * TLONGSIZE + TADDRSIZE)
#define	LO_LD_ARR_SIZE		TLONGSIZE
#define	HI_LD_ARR		TLONGSIZE
#define	I_X_LD_ARR_SIZE		2 * TLONGSIZE


/* type template (static part) for record type */

#define	XX_SREC(x)	((struct tt_srec *) x)
struct tt_srec {
	TG_long		tt_nflds;
	TG_long		tt_nform;
	TG_long		tt_ninits;
	TG_long		tt_rflags;
	TG_long		tt_vdsize;
	TG_ADDR		(*path_f)();
	struct tt_vr {
		TG_byte		tt_vr_lo;
		TG_byte		tt_vr_hi;
	} tt_f_vr[DYNAMIC];
};
#define	SREC_NFLDS		0
#define	SREC_NFORM		1 * TLONGSIZE
#define	SREC_NINITS		2 * TLONGSIZE
#define	SREC_RFLAGS		3 * TLONGSIZE
#define	SREC_VDSIZE		4 * TLONGSIZE
#define	SREC_PATH_F		5 * TLONGSIZE
#define	SREC_F_VR		(5 * TLONGSIZE + TADDRSIZE)
#define	LO_SREC_SIZE		TBYTESIZE
#define	HI_SREC_SIZE		TBYTESIZE
#define	F_VR_SREC_SIZE		2 * TBYTESIZE

/* type template for record type (dynamic part) */

#define	XX_REC(x)	((struct tt_rec *) x)
struct tt_rec {
	TG_long		dtag;
	TG_ADDR		tt_sp;
	TG_long		tt_vsize;
	TG_ADDR		tt_f_edp[DYNAMIC];	/* nform + nflds */
};
#define	TT_REC_DTAG		0
#define	TT_REC_SP		1 * TLONGSIZE
#define	TT_REC_VSIZE		(1 * TLONGSIZE + TADDRSIZE)
#define	TT_REC_F_EDP		(2 * TLONGSIZE + TADDRSIZE)
#define	F_EDP_TT_REC_SIZE	TADDRSIZE

#define	XX_OFTABLE(x)	((struct tt_oftable *) x)
struct tt_oftable {
	TG_long		tt_f_off[DYNAMIC];	/* nflds */
};
#define	TT_F_OFF_SIZE	TLONGSIZE


#define	XX_INTABLE(x)	((struct tt_intable *) x)
struct tt_intable {
	TG_ADDR		st_link;
	struct tt_i {
		TG_long		i_index;
		TG_ADDR		(*init_sub) ();
	} tt_init[DYNAMIC];	/* ninits */
};
#define	I_INDEX_INTABLE_SIZE	TLONGSIZE
#define	I_VP_INTABLE_SIZE	TADDRSIZE
#define	TT_INIT_SIZE		TLONGSIZE + TADDRSIZE


/* location descriptor for record type objects */

#define	XD_REC(x)	((struct ld_rec *) x)

struct ld_rec {
	TG_long		dtag;
	TG_ADDR		ttp;
	TG_long		vd_vsize;
	TG_long		vd_nflds;
	TG_long		vd_path;
	TG_long		vd_discr[DYNAMIC];	/* nform */
};
#define	LD_REC_DTAG		0
#define	LD_REC_TTP		TLONGSIZE
#define	LD_REC_NFLDS		2 * TLONGSIZE + TADDRSIZE
#define	LD_REC_PATH		3 * TLONGSIZE + TADDRSIZE
#define	LD_RECDISCR		4 * TLONGSIZE + TADDRSIZE
#define	VD_DISCR_LD_REC_SIZE	TLONGSIZE

#define	XD_OFTABLE(x)	((struct ld_oftable *) x)
struct ld_oftable {
	/* only if offset table is needed: */
	TG_long		ld_off[DYNAMIC];	/* nflds */
};
#define	LD_OFT_LD_OFF		0
#define	LD_OFF_OFTABLE_SIZE	TLONGSIZE



/* type template for access type */

#define	XX_ACC(x)	((struct tt_acc *) x)
struct tt_acc{
	TG_long		dtag;
	TG_long		tt_nform;
	TG_ADDR		tt_cdp[DYNAMIC];	/* nform */
};
#define	TT_ACC_DTAG		0
#define	TT_ACC_NFORM		1 * TLONGSIZE
#define	TT_ACC_CDP		2 * TLONGSIZE
#define	CDP_TT_ACC_SIZE		TADDRSIZE

/* location descriptor for access type object */

#define	XD_ACC(x)	((struct ld_acc *) x)
struct ld_acc {
	TG_long		dtag;
	TG_ADDR		ttp;
	TG_long		ld_cons[DYNAMIC];
};
#define	LD_ACC_DTAG		0
#define	LD_ACC_TTP		TLONGSIZE
#define	LD_ACC_CONS		(TLONGSIZE + TADDRSIZE)
#define	CONS_LD_ACC_SIZE	TLONGSIZE


/* call block */

#define	XX_CB(x)	((struct cb *) x)
struct cb {
	TG_long		dtag;
	TG_ADDR		ttp;
	TG_long		cb_vdoff;
	struct cb_par {
		TG_long		cb_tag;
		TG_long		cb_val;
	} cb_act[DYNAMIC];	/* nform */
#define	CB_DTAG			0
#define	CB_TTP			1 * TLONGSIZE
#define	CB_VDOFF		1 * TLONGSIZE + TADDRSIZE
#define	CB_ACT			2 * TLONGSIZE + TADDRSIZE
#define	TAG_CB_SIZE		TLONGSIZE
#define	VAL_CB_SIZE		TLONGSIZE
#define	CB_ACT_SIZE		2 * TLONGSIZE
};

/* heap descriptor */

#define	XD_HEAP(x)		((struct ld_heap *) x)
struct ld_heap {
	TG_long		dtag;
	TG_ADDR		vdp;
};

#define	LDHEAP_DTAG		0
#define	LDHEAP_VDP		TLONGSIZE

/* BE CAREFUL !!!
 * the next runtime structure has NO dtag, it is the
 * tuple belonging to an allocator. It is not a descriptor !
 */

struct rt_tuple {
	TG_long		some_flag;
	TG_ADDR		descr;
	TG_long		rt_val [DYNAMIC];
};
#define	XD_TUP(x)		((struct rt_tuple *) x)

typedef	struct rt_tuple	*RT_TUPLE;

#define	_dtag(x)	XX_ANY (x) -> dtag
#define	_ttp(x)		XX_ANY (x) -> ttp
#define	_cd_bitind(x)	XD_BIT (x) -> cd_bitind
#define	_ld_r(x)	XD_BIT (x) -> ld_r
#define	_cd_lo(x)	XD_BIT (x) -> ld_r.cd_lo
#define	_cd_hi(x)	XD_BIT (x) -> ld_r.cd_hi
#define	_td_ndims(x)	XX_ARR (x) -> td_ndims
#define	_td_aflags(x)	XX_ARR (x) -> td_aflags
#define	_td_e_cdp(x)	XX_ARR (x) -> td_e_cdp
#define	_td_ixrp(x)	XX_ARR (x) -> td_ixrp
#define	_vd_vsize(x)	XD_ARR (x) -> vd_vsize
#define _vd_e_size(x)	XD_ARR (x) -> vd_e_size
#define	_ld_i_x(x)	XD_ARR (x) -> ld_i_x
#define	lo_index(x,i)	XD_ARR (x) -> ld_i_x[i].vd_i_lo
#define	hi_index(x,i)	XD_ARR (x) -> ld_i_x[i].vd_i_hi
#define	_tt_nflds(x)	XX_SREC(x) -> tt_nflds
#define	_tt_nform(x)	XX_SREC(x) -> tt_nform
#define	_tt_ninits(x)	XX_SREC(x) -> tt_ninits
#define	_tt_rflags(x)	XX_SREC(x) -> tt_rflags
#define	_path_f(x)	XX_SREC(x) -> path_f
#define	_tt_f_vr(x)	XX_SREC(x) -> tt_f_vr
#define	lopath(x,i)	XX_SREC(x) -> tt_f_vr[i].tt_vr_lo
#define	hipath(x,i)	XX_SREC(x) -> tt_f_vr[i].tt_vr_hi
#define	_tt_sp(x)	XX_REC (x) -> tt_sp
#define	_tt_vsize(x)	XX_REC (x) -> tt_vsize
#define	_tt_f_edp(x)	XX_REC (x) -> tt_f_edp
#define	_tt_f_off(x)	XX_OFTABLE (x) -> tt_f_off
#define	_st_link(x)	XX_INTABLE (x) -> st_link
#define	_tt_init(x)	XX_INTABLE (x) -> tt_init
#define	_i_index(x,i)	XX_INTABLE (x) -> tt_init[i].i_index
#define	_init_sub(x,i)	XX_INTABLE (x) -> tt_init[i].init_sub
#define	_vd_nflds(x)	XD_REC (x) -> vd_nflds
#define	_vd_path(x)	XD_REC (x) -> vd_path
#define	_vd_discr(x)	XD_REC (x) -> vd_discr
#define	_ld_off(x)	XD_OFTABLE -> ld_off
#define	_tt_cdp(x)	XX_ACC (x) -> tt_cdp
#define	_ld_cons(x)	XD_ACC (x) -> ld_cons
#define	_cb_vdoff(x)	XX_CB  (x) -> cb_vdoff
#define	_cb_act(x)	XX_CB  (x) -> cb_act
#define	_cb_tag(x,i)	XX_CB  (x) -> cb_act[i].cb_tag
#define	_cb_val(x,i)	XX_CB  (x) -> cb_act[i].cb_val
#define	_vdp(x)		XD_HEAP(x) -> vdp
#define	_al_descr(x)	XD_TUP (x) -> al_descr
#define	_al_value(x)	XD_TUP (x) -> al_value
#define cdvsize(x)	XX_SREC (XX_REC (x) -> tt_sp) -> tt_vdsize
#define ndiscr(x)	XX_SREC(XX_REC(x)->tt_sp)->tt_nform
