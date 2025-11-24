#include	"../h/print.h"
#include	"unix.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"dats.h"
#include	"cnames.h"

/*
 *	Ada- runtime routines, used for processing type
 *	information
 *
 */

_rec_init (addr)
int	addr;
{
	int	nform,
		nflds,
		maxpath,
		path,
		offset,
		i,
		offaddr;
	/* although the value of flags is a TG_byte value,
	 * flags should be an appropriate integer otherwise
	 * we may (will) have extension problems
	 */
	int	flags;
	int	tdsp, f_cbp;

	flags = _tt_rflags (_tt_sp (addr)) & F_KIND;
	nform = _tt_nform (_tt_sp (addr));
	nflds = _tt_nflds (_tt_sp (addr));

	if (flags != A_REC && flags != E_REC && flags != F_REC)
		return;


	/* for records of kinds E and F the tt_off table
	 * must be initialized.
	 * for records of kinds A and E the tt_vsize field
	 * is indispensable
	 */

	maxpath = (flags == F_REC && nflds != 0 ? hipath (tdsp, 0) : 1);
	offaddr = (int) & (_tt_f_edp (addr) [nform + nflds + 1]);

	for (path = 1; path <= maxpath; path ++)
	{
	   offset = 0;
	   for (i = 0; i < nflds; i ++)
	   {
	      if (flags == F_REC)
	         if (path < lopath (tdsp, i))
	            break;	/* remaining i can be skipped,
		                 * j >= i path < lopath (tdsp, j)
	                         */
	         else
	         if (path > hipath (tdsp, i))
	                        /* path outside range for field
			         * it can thus be skipped
	                         */
	            continue;

	      if (flags != F_REC || path == lopath (tdsp, i))
	         {
	            offset = align (offset,
					al_val (_tt_f_edp (addr) [i + nform]));
	            if (flags != A_REC)
	               _tt_f_off (offaddr) [i] = offset;

		    offset = offset + sz_val (_tt_f_edp (addr) [i + nform]);
	         }
	      else
	         /* field in previous path, offset has already
	            been stored
	          */
	         offset = _tt_f_off (offaddr) [i];
	   }

	}
	_tt_vsize (addr) = offset;	/* A and E kinds */
}

/*
 *	sz_val (vdp) returns the size in TG_bytes needed to represent
 *	a value corresponding to the given value descriptor
 */
int sz_val (vdp)
char *vdp;
{
	return i_fldvd (NULL, NULL, vdp);
}

int sz_bitval (x)
int x;
{
	return x;
}

int al_bitval (x)
int x;
{
	return x - 1;
}

/*
 *	al_val (tp) returns the alignment factor necessary
 *	for a value of the type corresponding to the
 *	value or type descriptor tp
 */
TG_long
al_val (tp)
register RT_ANY tp;
{
	switch (_dtag (tp))
	{
	case CB:
		return al_val (_ttp (tp));

	case CD_BIT_H:
	case CD_BIT_S:
		return al_bitval (_cd_bitind (tp));

	case VD_ARR:
		tp = XX_ANY (_ttp (tp));

	case TD_ARR:
		return _td_aflags (tp) & F_ALIGN;

	case DD_REC:
	case VD_REC:
		tp = XX_ANY (_ttp (tp));

	case TD_REC:
		return _tt_rflags (_tt_sp (tp)) & F_ALIGN;

	case TD_ACC:
	case CD_ACC:
	case TD_TSK:
		return ADDR_ALIGN;

#ifdef DEBUG
	default:
		run_error ("al_val: unknown type structure");
#endif DEBUG
	}
}


/*
 * align (addr, af) returns the first address starting from
 * addr that satisfies the alignment factor af.
 * The alignment factor shows which address bits must be zero.
 */
int align (addr, af)
char *addr;
TG_byte af;
{
	return ((int)addr + (int)af ) & ~(unsigned)af;
}

/*
 * env is a structure used for the simulation of a calling
 * stack for call block evaluation.
 * The stack is implemented as a backwards linked list through
 * env_prevp fields where each env contains a local env_elmp
 * pointing to the current stack element
 * Such an element is of type union env_elm and is
 * either a call block (cb_par) or an array vd_par of MAXTYPE
 * parameters; such an array element can only appear
 * at the bottom of the stack (env_prevp == NULL),
 * where the parameters all have actual values.
 */

union env_elm {
	struct	cb	callblock_pars;
	struct	ld_rec	actuals;
};

struct env {
	struct env	*env_prevp;
	union env_elm	*env_elmp;
};


#define	ENV	struct	env

/*
 * getpar (envp, index) evaluates the index-th parameter of the
 * environment. A routine on the main level, asking for the
 * initialization of a descriptor, does not have an explicit call
 * block, but a pointer to a ld_rec descriptor.
 * The case is signalled by a NULL env_prevp pointer
 * If the call block signals a dependency on a parant's
 * parameter, that parameter is fetched through a recursive
 * call of getpar in the previous environment.
 */

static int getpar (envp, index)
register ENV *envp;
register int index;
{
	register struct cb * cbp;

	if (envp -> env_prevp == (struct env *) NULL)
	   return envp -> env_elmp -> actuals. vd_discr [index];

	cbp = XX_CB (&envp -> env_elmp -> callblock_pars);
	if (_cb_tag (cbp, index) == CB_VALUE)
	   return _cb_val (cbp, index);

	else
	/* it must be a PARPAR */
	return getpar (envp -> env_prevp, _cb_val (cbp, index));
}

/*
 * i_valdc is the internal, recursive version of valdc
 * it merely dispatches to the right i_...vd
 * It is called with a constrainable type structure in type_dp
 * and a NEW env structure pair, (envp, cbp)
 *
 * The parameter specifications are the same as for val_dc
 * except for a parameter pointer rather than the parameters
 * themselves.
 */
static int i_valdc (addr, type_dp, envp, cbp)
char *addr;
register RT_ANY type_dp;
ENV *envp;
char *cbp;
{
	register ENV **newenvp;

	newenvp = &envp;
	switch (_dtag (type_dp))
	{
	   case TD_ARR:
		return i_arrvd (addr, type_dp, newenvp);

	   case TD_REC:
		return i_recvd (addr, type_dp, newenvp);

	   case TD_ACC:
		return i_acccd (addr, type_dp, newenvp);

#ifdef DEBUG
	   default:
		run_error ("i_valdc: constrainable type expected");
#endif DEBUG
	}
}

/*
 * i_fldvd (addr, envp, p) interprets the constrained type structure
 * pointed at by p, and computes the total size if a value
 * corresponding to the associated value descriptor would be allocated.
 * To this end, if p really points to a call block, value descriptors
 * are recursively initialized from it in the descriptor space
 * pointed at by addr.
 *	- addr points to the space where the descriptors are wanted,
 *	- envp indicates the current environment, see getpar
 *	- p points to the runtime structure for which a value
 *	- descriptor is desired.
 */
static int i_fldvd (addr, envp, p)
char *addr;
ENV *envp;
register RT_ANY p;
{
	switch (_dtag (p))
	{
	   case CD_BIT_H:
	   case CD_BIT_S:
		return sz_bitval (_cd_bitind (p));

	   case TD_ACC:
	   case CD_ACC:
	   case TD_TSK:
		return sizeof (char *);

	   case VD_ARR:
	   case DD_REC:
	   case VD_REC:
		return _vd_vsize (p);

	   case TD_REC:
		return _tt_vsize (p);

	   case CB:
		return i_valdc (addr, _ttp (p), envp, p);

#ifdef DEBUG
	   default:
		run_error ("i_fldvd: constrained type expected");
#endif DEBUG
	}
}

/*
 * i_arrvd (addr, type_dp, envp) initializes an array value descriptor,
 * the actual values for the descriptors are fetched from the
 * caller's environment by means of getpar
 */
static int i_arrvd (addr, type_dp, envp)
	int	addr;
	int	type_dp;
	ENV *envp;
{
	register int i;

	int ndims, length;
	int nelems = 1;
	int esz;

	_dtag (addr) = VD_ARR;
	_ttp (addr) = (TG_ADDR) type_dp;

	ndims = _td_ndims (type_dp);
	for (i = 0; i < ndims; i ++)
	{
	    lo_index (addr, i) = getpar (envp, i * 2);
	    PRINTF (printf ("param.lo[%d]=%d in i_arrvd\n", i, lo_index (addr, i)));

	    hi_index (addr, i) = getpar (envp, i * 2 + 1);
	    PRINTF (printf ("param.hi[%d]=%d in i_arrvd\n", i, hi_index (addr, i)));

	    length = index_rg (lo_index (addr, i),
	    	           hi_index (addr, i),
	    	           _td_ixrp (type_dp) [i]);
	    PRINTF (printf ("computed array length in i_arrvd %d\n", length));

	    nelems *= length;
	}

	esz = i_fldvd (addr + _cb_vdoff (_td_e_cdp (type_dp)),
					envp, _td_e_cdp (type_dp));
	_vd_e_size (addr) = align (esz, al_val (_td_e_cdp (type_dp)));

	if (length != 0)
	   _vd_vsize (addr)= nelems * _vd_e_size (addr) -
			      			_vd_e_size (addr) + esz;
	else
	   _vd_vsize (addr) = 0;

	_vd_vsize (addr) = align (_vd_vsize (addr), MAX_ALIGN);
	return _vd_vsize (addr);
}


/*
 * i_recvd (addr, type_dp, envp) initializes a record value descriptor
 * recursively
 */
static int i_recvd (addr, type_dp, envp)
register struct ld_rec *addr;
struct tt_rec *type_dp;
ENV *envp;
{
	register struct tt_srec *tdsp;
	struct ld_oftable *offaddr;
	struct cb *cbp;
	register int i;

	int nform, tdnflds, tdflags, vdnflds, path;
	int offset;

	addr -> dtag = VD_REC;
	addr -> ttp = (TG_ADDR) type_dp;

	tdsp = XX_SREC (type_dp -> tt_sp);
	nform = tdsp -> tt_nform;
	tdnflds = tdsp -> tt_nflds;
	tdflags = tdsp -> tt_rflags;	/* stond "type_dp -> ..." */

	offset = 0;
	vdnflds = 0;
	offaddr = XD_OFTABLE (&addr -> vd_discr [nform]);

	for (i = 0; i < nform; i ++)
	{
	   addr -> vd_discr [i] = getpar (envp, i);
	   if (XX_ANY (type_dp -> tt_f_edp [i]) -> dtag == CD_BIT_S)
	      chk_rg_elmt (addr -> vd_discr [i], type_dp -> tt_f_edp [i]);
	}

/*
	if (tdflags & VARREC)
 */
	if (tdsp -> path_f != NULL)
	   path = (int) (* (tdsp -> path_f)) (&addr -> vd_discr [0]);

	PRINTF (printf ("computed path = %d\n", path));
	for (i = 0; i < tdnflds; i ++)
	{
/*
	   if (!(tdflags & VARREC) ||
 */
	   if (!(tdsp -> path_f != NULL) ||
	        (lopath (tdsp, i) <= path && path <= hipath (tdsp, i)))
	      { cbp = XX_CB (type_dp -> tt_f_edp [i + nform]);
	        offset = align (offset, al_val (cbp));
	        if (tdflags & CSTREC)
		   {
	           offaddr -> ld_off [vdnflds] = offset;

		   PRINTF (printf ("ld_off [%d] = %d\n", vdnflds, offset));
		   }

	        offset += i_fldvd ((int)addr + (cbp -> cb_vdoff), envp, cbp);
	        vdnflds ++;
	      }
	}

	addr -> vd_nflds = vdnflds;
	addr -> vd_path  = path;
	addr -> vd_vsize = offset;

	PRINTF (printf ("valsize = %d\n", addr -> vd_vsize));

	return offset;
}

/*
 * i_acccd (addr, type_dp, envp) will be provided for later
 */
int i_acccd (x, y, z)
int x, y, z;
{
}


/*
 *	__dc_check (x)
 *
 *	initializes a discriminant constraint, a record vd.
 */
_dc_check (addr)
register struct ld_rec *addr;
{
	register struct tt_srec *tdsp;
	register struct tt_rec *type_dp;
	struct ld_oftable *offaddr;
	struct cb *cbp;
	register int i;
	ENV	my_env;

	int nform, tdnflds, tdflags, vdnflds, path;
	int offset;

	my_env. env_prevp = (struct env *) NULL;
	my_env. env_elmp = (union env_elm *) addr;
	type_dp  = XX_REC (addr -> ttp);
	tdsp = XX_SREC (type_dp  -> tt_sp);
	nform = tdsp -> tt_nform;
	tdnflds = tdsp -> tt_nflds;
	tdflags = tdsp -> tt_rflags;

	offset = 0;
	vdnflds = 0;
	offaddr = XD_OFTABLE (&addr -> vd_discr [nform]);

	for (i = 0; i < nform; i ++)
	   if (XD_BIT (type_dp -> tt_f_edp [i]) -> dtag == CD_BIT_S)
	      chk_rg_elmt (addr -> vd_discr [i], type_dp -> tt_f_edp [i]);

/*
	if (tdflags & VARREC)
 */
	if (tdsp -> path_f != NULL)
	   path = (int) (*(tdsp -> path_f))(&addr -> vd_discr [0]);

	PRINTF (printf ("computed path = %d\n", path));

	for (i =0; i < tdnflds; i ++)
	{
/*
	    if (!(tdflags & VARREC) ||
 */
	    if (!(tdsp -> path_f != NULL) ||
	         (lopath (tdsp, i) <= path && path <= hipath (tdsp, i)))
	       {
	         cbp = XX_CB (type_dp -> tt_f_edp [i + nform]);
	         offset = align (offset, al_val (cbp));
	         if (tdflags & CSTREC)
		    {
		    PRINTF (printf ("ld_off [%d] = %d\n", i, offset));

	            offaddr -> ld_off [vdnflds] = offset;
		    }

	         offset += i_fldvd ((int) addr + (cbp -> cb_vdoff),
				    &my_env, cbp);
	         vdnflds ++;
	       }
	}

	addr -> vd_nflds	= vdnflds;
	addr -> vd_path		= path;
	addr -> vd_vsize	= align (offset, al_val (type_dp));

	PRINTF (printf ("valsize = %d\n", addr -> vd_vsize));

	return offset;
}

/*
 * index_rg (lo, hi, rp) checks the length of the range lo..hi
 * and checks if lo and hi are in the range pointed to by rp
 */
int index_rg (lo, hi, rp)
register int lo, hi;
register struct ld_bit *rp;
{
	int length;

	length = rg_length (lo, hi);
	if (length < 0)
		_raise (&CONSTRAINT_ERROR);

	if (rp -> dtag == CD_BIT_S)
	   { chk_rg_elmt (lo, rp); chk_rg_elmt (hi, rp); }

	return length;
}

int rg_length (lo, hi)
int lo, hi;
{
	return hi - (lo - 1);
}

chk_rg_elmt (val, rp)
register int val;
register struct ld_bit *rp;
{
	if (rp -> ld_r. cd_lo > val || val > rp -> ld_r. cd_hi)
		_raise (&CONSTRAINT_ERROR);
}
_rangecheck (val, desc)
register int val;	/* may be a TG_byte */
register struct ld_bit *desc;
{
	if (desc -> dtag == CD_BIT_H)
	   return;		/* always correct */

	if (desc -> cd_bitind == 1)
	   val &= 0377;		/* enumlit */

	chk_rg_elmt (val, desc);
}

_rc_check (desc1, desc2)
register struct ld_bit *desc1, *desc2;
{
	if (desc2 -> dtag == CD_BIT_H)
	   return;

	_rangecheck (desc1 -> ld_r. cd_lo, desc2);
	_rangecheck (desc1 -> ld_r. cd_hi, desc2);
}

_ic_check (d)
register struct ld_arr *d;
{
	register int i;
	register int numofel;
	register int elsize;

	numofel = 1;
	for (i = 0; i < XX_ARR (d -> ttp) -> td_ndims; i++)
	{
	   PRINTF (printf ("lowerbound = %d\n", d -> ld_i_x [i]. vd_i_lo));
	   PRINTF (printf ("upperbound = %d\n", d -> ld_i_x [i]. vd_i_hi));

	   numofel *= (int)d -> ld_i_x [i]. vd_i_hi
		    - (int)d -> ld_i_x [i]. vd_i_lo
	            + 1;

	   if (numofel < 0)
			_raise (&CONSTRAINT_ERROR);

	   _rangecheck (d -> ld_i_x [i]. vd_i_lo,
			XX_ARR (d -> ttp) -> td_ixrp [i]);
	   _rangecheck (d -> ld_i_x [i]. vd_i_hi,
			XX_ARR (d -> ttp) -> td_ixrp [i]);
	}

	elsize = sz_val (XX_ARR (d -> ttp) -> td_e_cdp);
	d -> vd_e_size = elsize;
	d -> vd_e_size= elsize;
	d -> vd_vsize = numofel * align (elsize,
					al_val (XX_ARR (d -> ttp) -> td_e_cdp));

	PRINTF (printf ("computed elsize %d bytes\n", elsize));
	PRINTF (printf ("number of elements %d\n", numofel));
	PRINTF (printf ("computed valsize %d bytes\n", d -> vd_vsize));
}


_ac_check (d)
	register struct ld_acc *d;
{
	/* As far as I can see, ac_check has nothing to
	 * check. Code to generate a call to this run_time routine
	 * is created, so if there should be anything checkable
	 * all there is to do would be writing this body.
	 * 13/7 Toet.
	 */
}
/* the next are the functions for the allocator structures */

/* due to a silent death of cc -O -X -c -DTG_68000 rt_decl.c
 * the defines for TWORDSIZE and TADDRSIZE
 * this has to be solved ... (27/7/toet)
 */

/* 26/9/85 
#define TWORDSIZE	2
#define TADDRSIZE	4
 */


/*
 *	notice (again ?) that storage allocation is distinguished
 *	between simple PASCAL like handling and complex Ada handling.
 *
 *	The structure in all cases:
 *
 *		flag_field (for identification in al_free)
 * value    ->  first word of value
 *	        ....
 *	        last word of value
 *
 * or
 *
 *		flag_field (for identification in al_free)
 * value ->	pointer to descriptor
 *	        first word of value
 *		....
 *		last word of value
 *
 * Further notice that if the accessed object should be a task,
 * this task must be created, activated before the runtime support
 * routine ais finished.
 * To avoid a mixup with other existing masterchains, we introduce
 * here a local masterchain.
 */
TG_ADDR	alloc_1 (m, descr)
RT_ANY	descr;
struct _master * m;
{
	char	*tup;
	int	valsize;
	tdp  l_chain_p = (tdp) NULL;

	l_chain_p	= (tdp) NULL;
	valsize = sz_val (descr) + 1 * TADDRSIZE;
	tup = (char *)malloc (valsize);

	XD_TUP (tup) -> some_flag = 0;	/* no local descriptor */

	if (has_inits_somewhere (descr))
	   r_init ((char *) (tup + 1 * TADDRSIZE), descr, m, &l_chain_p);

	if (l_chain_p != (tdp) NULL)
		/* there are tasks !  */
		activate (l_chain_p,0);

	return ((TG_ADDR) tup) + TADDRSIZE;
}

TG_ADDR	alloc_1a (m, descr, val)
RT_ANY	descr;
struct _master * m;
char	*val;
{
	char	*tup;
	int	valsize;
	int	i;

	valsize = sz_val (descr) + 1 * TADDRSIZE;
	tup = (char *)malloc (valsize);

	XD_TUP (tup) -> some_flag = 0;	/* no local descriptor */

	for (i = 0; i < valsize; i ++)
	   tup [TADDRSIZE + i] = val [i];

	return ((TG_ADDR) tup) + TADDRSIZE;
}

TG_ADDR	alloc_2 (m, descr, size)
RT_ANY	descr;
int size;
struct _master * m;
{
	char	*tup;
	int	valsize;
	int	i;
	char	*h;
	tdp  l_chain_p = (tdp) NULL;

	l_chain_p = (tdp)NULL;
	valsize = sz_val (descr) + 2 * TADDRSIZE;
	tup =  (char *) malloc (valsize);
	/* copy descriptor to a suitable place on the heap */
	h = (char *)malloc (size);
	for (i = 0; i < size; i ++)
	    h [i] = ((char *)descr) [i];
	XD_TUP (tup) -> descr = (TG_ADDR) h;
	XD_TUP (tup) -> some_flag = (TG_long) 1;

	if (has_inits_somewhere (descr))
		r_init ((char *)(tup + 2 * TADDRSIZE), descr, m, &l_chain_p);

	if (l_chain_p != (tdp) NULL)
		/* there are tasks !  */
		activate (l_chain_p,0);

	return  ((TG_ADDR) tup + TADDRSIZE);
}

/* Mark, as contr_vals is a table of undecided length, here
 * the master and the master chain are the FIRST parameters
 */

TG_ADDR	alloc_3 (m, descr, size, count, constr_vals)
struct _master * m;
RT_ANY	descr;
int	size;
int	count;
int	constr_vals;
{
	char	*tup;
	int	valsize;
	char	*h;

	tdp  l_chain_p = (tdp) NULL;
	l_chain_p = (tdp) NULL;
	/* here descr is the address of the base type descriptor of
	 * the filter accompaning the allocator.
	 * we first make the descriptor for the constraints in the filter,
	 * then resume the actions of alloc_2.
	 */
		
	h = (char *) malloc (size);
	mdesc (descr, h, count, &constr_vals);
	valsize = sz_val (XX_ANY (h)) + 2 * TADDRSIZE;
	tup =  (char *) malloc (valsize);
	XD_TUP (tup) -> descr = (TG_ADDR) h;
	XD_TUP (tup) -> some_flag = (TG_long) 1;

	if (has_inits_somewhere (descr))
		r_init ((char *)(tup + 2 * TADDRSIZE), descr, m, &l_chain_p);

	if (l_chain_p != (tdp) NULL)
		/* there are tasks !  */
		activate (l_chain_p,0);

	return  ((TG_ADDR) tup + TADDRSIZE);
}

TG_ADDR	alloc_4 (m, val, descr, size)
struct _master * m;
char	*val;
char	*descr;
int	size;
{
	char	*tup;
	int	valsize;
	char	*h;
	int	i;
	/* here descr is the address of the base type descriptor of
	 * the filter accompaning the allocator.
	 * we first make the descriptor for the constraints in the filter,
	 * then resume the actions of alloc_2.
	 */
	h = (char *) malloc (size);
	
	for (i = 0; i < size; i ++)
	   h [i] = descr [i];

	valsize = sz_val (XX_ANY (h)) + 2 * TADDRSIZE;
	tup =  (char *) malloc (valsize);
	XD_TUP (tup) -> descr = (TG_ADDR) h;
	XD_TUP (tup) -> some_flag = (TG_long) 1;

	for (i = 0; i < valsize; i ++)
	   tup [2 * TADDRSIZE + i] = val [i];

	return  ((TG_ADDR) tup + TADDRSIZE);
}


mdesc (base_type, ndesc, count, constr_vals)
	RT_ANY base_type;
	RT_ANY ndesc;
	int count;
	int constr_vals [];
{
	int i,j;

	ndesc -> dtag = get_dtag (base_type);
	ndesc -> ttp  = (TG_ADDR) base_type;

	switch (ndesc -> dtag) {

	case VD_ARR:
		{
		  _vd_e_size (ndesc) = 0;
		  _vd_vsize (ndesc) = 0;
		  for (i=0,j=0; i < XX_ARR (base_type) -> td_ndims; i++) {
			lo_index (ndesc, i) = constr_vals [j++];
			hi_index (ndesc, i) = constr_vals [j++];
			count -= 2;
			if (count < 0)
				run_error ("mdesc: too few constraints with filter\n");
		  }
		  if (count > 0)
			run_error ("mdesc: too many constraints with filter\n");
		  _ic_check (ndesc);
		  break;
		}

	case VD_REC:
		{ struct tt_srec *tdsp;
		  struct tt_rec *type_dp;

		  type_dp = XX_REC (ndesc -> ttp);
		  tdsp = XX_SREC (type_dp -> tt_sp);

		  for (i=0, j=0; i < tdsp -> tt_nform; i++) {
			XD_REC (ndesc) -> vd_discr [i] = constr_vals [j++];
			--count;
			if (count < 0)
				run_error ("mdesc: too few constraints with filter\n");
		  }
		  if (count > 0)
			run_error ("mdesc: too many constraints with filter\n");
		  _dc_check (ndesc);
		  break;
		}

	case CD_BIT_S:
	case CD_ACC:
	case CB:
		run_error ("mdesc: filter descriptor yet to be provided!\n");
		break;
	}
}

get_dtag (ttp)
	RT_ANY ttp;
{
	switch (ttp -> dtag) {

	case TD_ARR:
		return VD_ARR;
	case TD_REC:
		return VD_REC;
	case TD_ACC:
		return CD_ACC;
	case CD_BIT_S :
		return CD_BIT_S;
	case TD_TSK:
		return TD_TSK;
	default:
		run_error ("get_dtag : constrainable type expected\n");
	}
}




/* some global variables */

char *st_link = NULL;

/* some defines */

#define	 IS_INITIALISED	(i_ind = get_init_ind (i,intable,nints)) != -1

r_init (t_addr,descr,m,m_chain_p)
	register char * t_addr;
	RT_ANY descr;
	struct _master * m;
	tdp *m_chain_p;
{
	switch (descr -> dtag) {

	case CD_ACC:
	case TD_ACC:
		/* keep it simple, access value's 'll be zero'd
		 */
		* (int *) t_addr = (int) 0;
		return;

	case VD_ARR:
		do_arr (t_addr,descr,m,m_chain_p);
		return;

	case DD_REC:
	case VD_REC:
	case TD_REC:
		do_rec (t_addr,descr,m,m_chain_p);
		return;
	case TD_TSK:
		do_tsk (t_addr,descr,m,m_chain_p);
		return;

	default:
		run_error ("r_init: initialised type %d of wrong kind",
								descr -> dtag);
	}
}

do_rec (t_addr,descr,m,m_chain_p)
	register char * t_addr;
	RT_ANY descr;
	struct _master * m;
	tdp *m_chain_p;
{
	int	i;
	char	*dest;
	char	*t_descr;
	int	nform;
	int	nflds;
	int	flags;
	int	path;
	int 	nints;
	int	i_ind;
	RT_ANY	fld_descr;
	int	fld_offset = 0;
	struct tt_srec *tdsp;
	struct tt_rec *td;
	struct tt_oftable *offaddr;
	struct tt_intable *intable;

	
	/* initialisation part */

	if (descr -> dtag == VD_REC || _dtag (descr) == DD_REC)
	{
	   td   = XX_REC (descr -> ttp);
	   tdsp = XX_SREC (td -> tt_sp);
	   flags = tdsp -> tt_rflags & F_KIND;
	   nints = tdsp -> tt_ninits;
	   nform = tdsp -> tt_nform;
	   nflds = tdsp -> tt_nflds;
	   path = XD_REC (descr) -> vd_path;
	   if (has_off_table (flags,descr))
		offaddr = XX_OFTABLE (& XD_REC (descr) -> vd_discr [nform]);
	   intable = XX_INTABLE (& td -> tt_f_edp [nform + nflds]);
	}
	else
	{
	   if (descr -> dtag == TD_REC)
	   {
		tdsp = XX_SREC (XX_REC (descr) -> tt_sp);
		td  = XX_REC (descr);
		flags = tdsp -> tt_rflags & F_KIND;
		nints = tdsp -> tt_ninits;
		nform = tdsp -> tt_nform;
		nflds = tdsp -> tt_nflds;
		path = -1;
		if (has_off_table (flags,descr))
		{
		   offaddr = XX_OFTABLE (& XX_REC (descr)
				-> tt_f_edp [nform + nflds + 1]);
		   intable = XX_INTABLE (& td -> tt_f_edp
						[nform + nflds * 2 + 1]);
		}
		else
		   intable = XX_INTABLE (& td -> tt_f_edp [ nform + nflds]);
	   }
	   else
		run_error ("do_rec: initialised object of wrong type");
	}
	/* and now for:
	 * (if there is a path) ? fields in the path : all fields
	 *  - search (recursively) for initialised fields,
	 *  - compute its address,
	 *  - call the assigning sub routine.
	 */

	st_link = (char *) intable -> st_link;

	for (i = nform; i < nform + nflds; i++)
	{
		if ((descr -> dtag == VD_REC || _dtag (descr) == DD_REC)
		     && (has_path (tdsp,path)))
			if (path < lopath (tdsp, i) || path > hipath (tdsp, i))
				continue;

		fld_offset = ((has_off_table (flags,descr))
			     ? offaddr -> tt_f_off [i-1]
			     : get_off (descr -> dtag,i,td,path));

		/* first search for inits somewhere */

		fld_descr = XX_ANY (td -> tt_f_edp [i]);
		if (fld_descr -> dtag == CB) {
			t_descr =   (char *) descr +
				    XX_CB (td -> tt_f_edp [i]) -> cb_vdoff;
			fld_descr = XX_ANY (t_descr);
		}


		/* now do the init expression itself
		 * (if there is any)
		 */

		if (IS_INITIALISED) {
			dest = t_addr + fld_offset;

			PRINTF (printf ("dest = %x\n",dest));

			if ((_dtag (descr) == VD_REC || _dtag (descr) == DD_REC)
			      && (XX_ANY (td -> tt_f_edp[i]) -> dtag == CB))
			    t_descr = (char *) descr + 
				       XX_CB (td -> tt_f_edp[i]) -> cb_vdoff;
			else
			    t_descr = (char *) td -> tt_f_edp[i];

			PRINTF (printf ("descr = %x\n",t_descr));

			( * (intable -> tt_init [i_ind] . init_sub))
					(st_link,
					 t_descr,
					 dest,
					 descr);
			continue;
		}

		/* if no explicit init, try implicit ones
		 */
		if (has_inits_somewhere (fld_descr)) {
			dest = t_addr + fld_offset;
			r_init (dest,fld_descr,m,m_chain_p);
		}

	}
}
			
get_off (tag,i,td,path)
	int tag;
	int i;
	struct tt_rec *td;
	int path;
{
	register int fld_cnt;
	register int off = 0;
	register struct tt_srec *tdsp;

	tdsp = XX_SREC (td -> tt_sp);
	for (fld_cnt = tdsp -> tt_nform; fld_cnt < i; fld_cnt++) {
		if ((tag == VD_REC || tag == DD_REC) &&
		    (tdsp -> path_f != 0) &&
			(path < lopath (tdsp, i) || path > hipath (tdsp, i)))
			continue;

		off += sz_val (td -> tt_f_edp [fld_cnt]);
		off = align (off, al_val (td -> tt_f_edp [fld_cnt]));
	}

	off = align (off, al_val (td -> tt_f_edp [fld_cnt]));
	return off;
}

do_arr (t_addr,t_descr,m,m_chain_p)
	char *t_addr;
	RT_ANY t_descr;
	struct _master * m;
	tdp *m_chain_p;
{
	RT_ANY ar_edp;
	struct ld_arr *ar_vdp;
	int elsize,elcnt,dims,ind;
	char *dest;

	ar_vdp = XD_ARR (t_descr);
	ar_edp = XX_ANY (XX_ARR (ar_vdp -> ttp) -> td_e_cdp);

	elsize = ar_vdp -> vd_e_size;
	elcnt  = 0;
	for (dims = 0; dims < XX_ARR (ar_vdp -> ttp) -> td_ndims; dims++ )
		for (ind  = ar_vdp -> ld_i_x [dims].vd_i_lo;
		     ind <= ar_vdp -> ld_i_x [dims].vd_i_hi;
		     ind ++) {
			dest = t_addr + elsize * elcnt ++;
			r_init (dest,ar_edp,m,m_chain_p);
		}
}

has_inits_somewhere (descr)
	register RT_ANY descr;
{
	switch (descr -> dtag) {
	case VD_ARR:
		return (XX_ARR (XD_ARR (descr) -> ttp) -> td_aflags & F_RINIT);
	case DD_REC:
	case VD_REC:
		return (XX_SREC (XX_REC (XD_REC (descr) -> ttp) -> tt_sp) -> tt_rflags & F_RINIT);
	case TD_REC:
		return (XX_SREC (XX_REC (descr) -> tt_sp) -> tt_rflags & F_RINIT);
	case CD_BIT_H:
	case CD_BIT_S:
		return FALSE;
	case TD_ACC:
	case CD_ACC:
	case TD_TSK:
		return TRUE;

	default:
		return FALSE;
	}
}

get_init_ind (i,intable,nints)
	register int i;
	register struct tt_intable *intable;
	register int nints;
{
	int cnt;
	if (nints == 0) 
		/* no initialised fields */
		return -1;

	for (cnt = 0; cnt < nints; cnt ++) {
		if (intable -> tt_init [cnt].i_index == i)
			return (cnt);
	}
	return -1;
}

has_path (tdsp,path)
	register struct tt_srec *tdsp;
	register int path;
{
	if (path <= 0) return FALSE;
	if ((tdsp -> tt_rflags & VARREC) == 0) return FALSE;
	/* due to a bug in the field path */
	/* sometimes path gets very large (is no path anyway) */
	if (path > 100) return FALSE;
	
	return TRUE;
}

has_off_table (flags,type)
	int flags;
	RT_ANY type;
{
	switch (type -> dtag) {

	case DD_REC:
	case VD_REC:
		return (flags & (DYNREC|CSTREC));

	case TD_REC:
		return (flags & (DYNREC));

	}
}
/* unco_de makes a dexcriptor for an unconstrained object */

TG_ADDR
unco_de (des, dis)
	struct tt_rec	*des;
	TG_long		dis;
{
	struct ld_rec	*d;
	TG_long		*a_dis;
	int i;
	a_dis = &dis;

	d = malloc (cdvsize (des));
	d -> dtag = DD_REC;
	d -> ttp  = des;

	for (i = 1; i <= ndiscr (des); i++)
		d -> vd_discr [i - 1] = a_dis [- (i - 1)];
	_dc_check (d);
	return d;
}

/* unco_va allocates a piece of storage for unconstrained object */

unco_va (des)
	struct ld_rec *des;
{
	char *v;

	v = malloc (_vd_vsize (des));
	if (v == NULL)
		_raise (&STORAGE_ERROR);
	return v;
}

do_tsk (t_addr, descr, m, m_chain_p)
	tdp *t_addr;
	RT_ANY descr;
	struct _master * m;
	tdp  *m_chain_p;
{
	tdp result;

	result = create_td (&t_addr, descr, m, m_chain_p);
	* t_addr = (tdp) result;
}
