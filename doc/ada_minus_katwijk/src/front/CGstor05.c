
/*
 * (c) copyright 1986, Delft University of Technology
 * Delft, The Netherlands
 *
 *
 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 *	For further information contact
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 *	NUMERICS and some supporting routines
 *
 *	Forward (static) declarations
 */
static	bool	privconstraint	();
static	ac	dis		();
static	ac	priv		();
static	ac	matching	();

/*
 *	During the computation of sizes in compile time, we
 *	want to access structures and contexts. One of
 *	these contexts is formed by the following structure
 *	which, highly machine dependent, appears within the
 *	parameters of the call chain
 */
struct env	{
	struct env	*prevenp;
	ac		cp;
};

#define	ENV	struct env

/*
 *	get the static range belong to x
 */
/*
ac	stat_range (x)
ac	x;
{
	while (TRUE) {
	   ASSERT (x != NULL, ("stat_range:0"));
	
	   if (g_d (x) == XENUMTYPE)
	      return x;

	   if (g_d (x) == XSUBTYPE)
	      x = g_parenttype (x);
	   else
	   if (g_d (x) == XFILTER)
	      if (is_static (x))
	         return g_constraint (x);
	      else
	         return root_type (g_filtype (x));
	   else
	   if (g_d (x) == XNEWTYPE)
	      x = g_old_type (x);
	   else
	   if (is_integer (x))
	      return x;
	   else
	     x = root_type (x);
	}
} 
*/

/*
 *	some strange routines for relational operations
 *	on value representations in static expressions
 *
long	ord (x)
ac	x;
{
	ac	y;
	char	*s;

	while (TRUE) {
	   if (x == NULL)
	      return 0;

	   switch (g_d (x)) {
	      case XEXP:
	         x = g_primary (x);
	         break;

	      case XNAME:
	         x = g_fentity (x);
	         break;

	      case XOBJECT:
	         x = g_expr (g_desc (x));
	         break;

	      case XENUMLIT:
	      case XCHARLIT:
	         return g_enuml_ord (x);

	      case XLITERAL:
	         s = g_val (x) -> litvalue;

	         switch (g_val (x) -> litkind) {
	            case S_INTLIT:
	               return (long) atoi (s);

	         DEFAULT (("ord: strange XLITTERAL"));
	         }

	      DEFAULT (("strange ord %d\n", g_d (x)));
	   }
	}
}

long	low_int (x)
ac	x;
{
	x = root_type (x);

	ASSERT (x != NULL, ("low_int:1"));

	if (x == std_short)
	   return (char) -127;

	if (x == std_integer)
	   return (short) -32767;

	if (x == std_long)
	   return (long) -2147483648;

	if (g_d (x) == XNEWTYPE)
	   return loval (g_old_type (x));

	return (long) -2147483648;
}

long	high_int (x)
ac	x;
{
	x = root_type (x);

	ASSERT (x != NULL, ("high_int:1"));

	if (x == std_short)
	   return (char) 127;

	if (x == std_integer)
	   return (short) 32767;

	if (x == std_long)
	   return 2147483648;

	if (g_d (x) == XNEWTYPE)
	   return hival (g_old_type (x));

	return 2147483648;
}
*/
long	loval (x)
ac	x;
{
	ASSERT (x != NULL, ("loval:1"));

	if (is_integer (x))
	   return low_int (x);

	if (g_d (x) == XENUMTYPE)
	   return 0;

	if (g_d (x) == XFILTER || g_d (x) == XSUBTYPE)
	   return loval (stat_range (x));

	ASSERT (g_d (x) == XRANGE, ("loval no range %d", g_d (x)));

	if (g_frang_exp (x) == NULL)
	   return loval (stat_range (g_rangetype (x)));

	ASSERT (is_static (x), ("not a static range"));

	return ord (g_primary (g_frang_exp (x)));
}

long	hival (x)
ac	x;
{
	ac	tmp1;

	ASSERT (x != NULL, ("hival:1"));

	if (is_integer (x))
	   return high_int (x);

	if (g_d (x) == XENUMTYPE)
	   return (int) g_nenums (x) - 1;

	if (g_d (x) == XFILTER || g_d (x) == XSUBTYPE)
	   return hival (stat_range (x));

	tmp1 = g_frang_exp (x);

	if (tmp1 == NULL)
	   return hival (stat_range (g_rangetype (x)));

	if (g_next (tmp1) != NULL)
	   return getvalue (g_next (tmp1));
	else
	   return getvalue (tmp1);
}

/*
 *	Check a value being in a range
 */
bool	chk_val (val, subtind)
int	val;
ac	subtind;
{
	return loval (subtind) <= val && val <= hival (subtind);
}

long	getvalue (ep)
ac	ep;
{
	ac	pp;
	long	val;

	while (TRUE) {
   	   ASSERT (ep != NULL && g_d (ep) == XEXP, ("getvalue"));
	   ASSERT (is_static (ep), ("get_value:2"));

	   pp = g_primary (ep);

	   switch (g_d (pp)) {
	      case XENUMLIT:
	      case XCHARLIT:
	      case XLITERAL:
	         return ord (pp);

	      case XOBJECT:
	         ep = g_expr (g_desc (pp));
	         break;

	      case XNAME:
	         switch (g_d (g_fentity (pp))) {
		    case XENUMLIT:
		    case XCHARLIT:
		    case XLITERAL:
		       return ord (g_fentity (pp));

		    case XOBJECT:
		       ep = g_expr (g_desc (g_fentity (pp)));
	               break;

		    DEFAULT (("getvalue name %d\n", g_d (g_fentity (pp))));
	         }
	         break;

	      case XEXP:
	         ep = pp;
	         break;

	      DEFAULT (("getvalue: %d\n", g_d (pp)));
	   }
	}
}	/* end of getvalue */

bool	isinchoices (val, fvarchp)
long	val;
ac	fvarchp;
{
	ac	p;

	ASSERT ((fvarchp != NULL && g_d (fvarchp) == XRANGE), ("isinchoices"));

	FORALL (p, fvarchp)
	   /* one varchoice just is a range */
	   if (is_inrange (val, p))
	      return TRUE;

	return FALSE;
}	/* end of isinchoices */

bool	is_inrange (val, p)
long	val;
ac	p;
{
	if (is_others (p))
	   return TRUE;

	return loval (p) <= val && val <= hival (p);
}

bool	isinbittype (val, tp)
long	val;
ac	tp;
{
	tp = basefilter (tp);

	ASSERT (tp != NULL && is_scalar (tp), ("isinbittype"));

	return g_d (tp) != XFILTER || is_inrange (val, g_constraint (tp)) ;
}	/* end of isinbittype */

MAXADDR	rg_length (lo, hi)
long	lo, hi;
{
	return hi - lo + 1;
}

/*
 *	getpar: first some local support routines
 *	A problem might occur when the constraint we are
 *	examining is a constraint on a private type.
 *	and the discriminant is given within the record type
 */
static
bool	privconstraint (x)
ac	x;
{
	ac	y,
		t;

	ASSERT (x != NULL, ("privconstr NULL"));
	ASSERT (g_d (x) == XDISCRCONS, ("privconstr %d", g_d (x)));

	y = g_aggregate (x);
	t = g_fcompchoice (y);

	if (t != NULL)
	   t = g_frang_exp (t);

	if (t != NULL)
	   t = g_primary (t);

	if (t != NULL)
	   t = g_fentity (t);

	ASSERT (t != NULL && is_discr (t), ("privconstr_2"));

	return g_d (g_enclunit (t)) == XPRIVTYPE;
}

static
ac	dis (privt, cnt)
ac	privt;
int	cnt;
{
	ac	y;

	FORALL (y, g_fpdiscr (privt)) {
	   if (cnt -- == 0)
	      return y;
	}

	ASSERT (FALSE, ("dis: %s", g_tag (privt)));
}

static
ac	priv (discrcons)
ac	discrcons;
{
	ac	t,
		y;

	ASSERT (discrcons != NULL && g_d (discrcons) == XDISCRCONS,
							("priv"));

	t = g_aggregate (discrcons);

	if (t != NULL)
	   t = g_fcompchoice (t);

	if (t != NULL)
	   t = g_frang_exp (t);

	if (t != NULL)
	   t = g_primary (t);

	ASSERT (t != NULL, ("priv:2"));

	y = t;

	ASSERT (g_d (y) == XNAME, ("Priv_3"));

	return g_enclunit (g_fentity (y));
}

static
ac	matching (disc, privt)
ac	disc,
	privt;
{
	ac	x,
		rect;
	int	cnt = 0;

	rect = g_enclunit (disc);

	FORALL (x, g_ffield (rect)) {
	   if (disc == x)
              return dis (privt, cnt);
	   cnt ++;
	}

	ASSERT (FALSE, ("matching %s not found", g_tag (disc)));
}

long	getpar (discrp, envp)
ac	discrp;
ENV	*envp;
{
	ac	p,
		q,
		recp;

	ASSERT ((discrp != NULL &&
                  g_d (discrp) == XOBJECT), ("getpar1"));
	ASSERT (kind_of (g_desc (discrp)) == KDISCR, ("getpar2"));
	ASSERT (envp != NULL, ("getpar: envp == NULL"));

	recp = g_enclunit (discrp);

	ASSERT (recp != NULL, ("getpar:4"));

/*
 *	If the constraint is on a private type and the object
 *	under consideration is the record belonging to
 *	the private type, find the matching discriminant in the
 *	record type
 */
	if (privconstraint (envp -> cp) &&
		  g_d (recp) == XRECTYPE)
	   return getpar (matching (discrp, priv (envp -> cp)), envp);


	/*
	 * return actual value given for discriminant pointed
	 * at by discrp from the enclosing discriminant constraint.
	 *
	 * assume named normalization of discriminant constraint.
	 */
	FORALL (q, g_aggregate (envp -> cp)) {
	   ASSERT ((q != NULL && g_d (q) == XCOMPASSOC), ("getpar"));

	   p = g_fcompchoice (q);

	   if (p != NULL)
	      p = g_frang_exp (p);

	   if (p != NULL)
	      p = g_primary (p);

	   ASSERT (p != NULL && g_d  (p) == XNAME, ("getpar01"));

	   p = g_fentity (p);
	   if (g_d (p) == XOBJECT && kind_of (g_desc (p)) == KDISCR)
	      if (p == discrp)
		 break;
	}

	/*
	 * q now points to component association corresponding to discrp
	 */
	ASSERT (q != NULL, ("getpar: cannot find actual value discriminant"));

	if (isdiscrdepexp (g_compexpr (q)))
	   return getpar (g_fentity (g_primary (g_compexpr (q))),
							envp -> prevenp);
	else
	/* must be static ! */
	   return getvalue (g_compexpr (q));

}	/* end of getpar */

/*
 * tp must be a filter or a type as returned by basetype.
 *
 * getvalsize computes the size of the type construct pointed at by
 * tp in the environment pointed at by envp; if tp points to a filter
 * it assumes that the value size wanted is not available from
 * the FLT_valsize field of the filter.
 * Its brother routine 'sz_val' (called with the same kinds of
 * arguments) also computes the size of a value of the type construct
 * pointed at, but uses the FLT_valsize field if possible (i.e. if tp
 * points to a filter of which the constraints does not depend
 * on discriminant values); otherwise is calls getvalsize.
 *
 * getvalsize can be called by filter (to compute the FLT_valsize
 * field of a NEW filter, envp then is NULL), or by sz_val
 * (the value size is not directly available and must be computed,
 * tp may be a discriminant dependent filter,
 * or a record type without discriminants, a scalar or an access type).
 *
 * in all cases the type construct pointed at must be static
 * (i.e. have a staticly computable value size)
 */
MAXADDR	getvalsize (tp, envp)
ac	tp;
ENV	*envp;
{
	ac	btp,
		cp;

	ASSERT (isoptfilter (tp) && (getflags (tp) & DYNREC) == 0,
							("getvalsize"));

	if (g_d (tp) == XFILTER) {
	   ASSERT ((g_FLT_flags (tp) & CSTREC) == 0 || envp != NULL,
							("getvalsize1"));

	   btp = root_type (g_filtype (tp));	/* for selecting */
	   cp = g_constraint (tp);
	}
	else
	{  btp = tp;
	   cp = NULL;
	}

	switch (g_d (btp)) {
	   case XINTERNAL:
	      return sz_bitval (g_ind (btp));

	   case XENUMTYPE:
	      return sz_bitval (I_ENUM);

	   case XACCTYPE:
	      return TADDRSIZE;

	   case XTASKTYPE:
	      return TADDRSIZE;

	   case XARRAYTYPE:
	      return sz_arrval (btp, envp, cp);

	   case XRECTYPE:
	      return sz_recval (btp, envp, cp);

	   DEFAULT (("getvalsize %d", g_d (btp)));
	}
}	/* end of getvalsize */

MAXADDR	sz_val (tp, envp)
ac	tp;
ENV	*envp;
{
	tp = basefilter (tp);

	ASSERT (tp != NULL, ("sz_val:0"));

	if (g_d (tp) == XFILTER) {
	   ASSERT ((g_FLT_flags (tp) & DYNREC) == 0 , ("sz_val"));

	   if ((g_FLT_flags (tp) & CSTREC) == 0)
	      return g_FLT_valsize (tp);
	   /*
	    * now the filter is discriminant dependent;
	    * the actual discriminant values must be available
	    * via envp.
	    * Call getvalsize to do the job.
	    */
	   return getvalsize (tp, envp);
	}
	/*
	 * if tp is not a filter, it must be a not-unconstrained type
	 * i.e. a type that does not need a constraint before it
	 * can be used to compute the size of a value of it.
	 * Getvalsize is called with envp==NULL to force
	 * that actual discriminant values cannot be fetched from
	 * the environment.
	 */
	return getvalsize (tp, NULL);
}	/* end of sz_val */

/*
 *	get the size of a bitval
 */
MAXADDR	sz_bitval (bitind)
short	bitind;
{
	switch (bitind) {
	   case I_ENUM:
	      return TBYTESIZE;

	   case I_SHORT:
	      return TBYTESIZE;

	   case I_INTEGER:
	      return TINTSIZE;

	   case I_LONG:
	      return TLONGSIZE;

	   case I_UNIV:
	      return TLONGSIZE;

	   case I_STD_REAL:
	      return TFLOATSIZE;

	   DEFAULT (("sz_bitval: %o ?", bitind));
	}
}	/* end of sz_bitval */

/*
 *	Get the alignment requirement of a bitval
 */
MAXADDR	al_bitval (bitind)
short	bitind;
{
	switch (bitind) {
	   case I_ENUM:
	   case I_SHORT:
	      return byte_ALIGN;

	   default:
	      return word_ALIGN;
	}
}	/* end of al_bitval */

/*
 * 	Compute in compile-time the size of an array-object
 *	cp is a constraint to be used
 *	arrp is the arraytype
 *	env is the usual list of items
 */
MAXADDR	sz_arrval (arrp, envp, cp)
ac	arrp;
ENV	*envp;
ac	cp;
{
	int	nelems;
	ac	rp,
		lop,
		hip;
	long	lo,
		hi;
	MAXADDR	esz, aesz;

	ASSERT ((cp != NULL && g_d (cp) == XINDEXCONS) , ("sz_arrval"));
	ASSERT (arrp != NULL && g_d (arrp) == XARRAYTYPE, ("sz_arrval:2"));

	nelems = 1;
	FORALL (rp, g_frange (cp)) {
	   if (g_frang_exp (rp) != NULL) {
	      lop = g_frang_exp (rp);
	      hip = g_next (lop);
	
	      lo = isdiscrdepexp (lop) ?
	         getpar (g_fentity (g_primary (lop)), envp):
	         getvalue (lop);
	      hi = isdiscrdepexp (hip) ?
	         getpar (g_fentity (g_primary (hip)), envp) :
	         getvalue (hip);
	   }
	   else
	   {  lo = loval (g_rangetype (rp));
	      hi = hival (g_rangetype (rp));
	   }

	   nelems = nelems * rg_length (lo, hi);
	}

	esz = sz_val (g_elemtype (arrp), envp);
	aesz = align (esz, getflags (g_elemtype (arrp)) & F_ALIGN);

	if (nelems > 0)
	   return (aesz * nelems) - (aesz - esz);
	else
	   return 0;
}	/* end of sz_arrval */

/*
 *	Compute the size of a record object
 */
MAXADDR	sz_recval (recp, envp, cp)
ac	recp;
ENV	*envp;
ac	cp;
{
	MAXADDR	sz;
	ac	p,
		tp;

	ASSERT ((cp == NULL || g_d (cp) == XDISCRCONS) , ("sz_recval"));
	/*
	 * note that here a new pair (envp, cp) is put together;
	 * pass therefore '&envp' as address of the pair
	 * to the called routines instead of the old envp.
	 * In this way a chain of pairs is made to search through
	 * when discriminant constraints themselves reference
	 * discriminants for which values were given in an
	 * enclosing discriminant constraint.
	 */
	sz = 0;
	recp = root_type (recp);

	ASSERT (g_d (recp) == XRECTYPE, ("sz_recval: no record"));

	FORALL (p, g_ffield (recp)) {
	   if (g_d (p) == XVARIANT)
	       break;

	   if (g_d (p) != XOBJECT)
	      continue;

	   if (kind_of (g_desc (p)) == KDISCR)
	      continue;

	   tp = g_objtype (g_desc (p));
	   sz = align (sz, getflags (tp) & F_ALIGN);
	   sz += sz_val (tp, &envp);
	}

	if (g_fvariant (recp) == NULL)
	   return sz;

	return sz_varval (g_fvariant (recp),
			 getpar (g_comp (g_dis (recp)), &envp), sz, &envp);
}	/* end of sz_recval */

/*
 *	Similar for the variants (Similar ?)
 */
MAXADDR	sz_varval (fvarp, cval, sz, envp)
ac	fvarp;
long	cval;
MAXADDR	sz;
ENV	*envp;
{
	ac	varp,
		p,
		tp;

	FORALL (varp, fvarp)
	   if (isinchoices (cval, g_varchoice (varp)))
	      break;

	ASSERT (varp != NULL, ("sz_varval: no choice with discr value"));

	FORALL (p, g_ffield (varp)) { 
	   if (g_d (p) == XVARIANT)
	      break;

	   if (g_d (p) != XOBJECT)	/* it can happen, does not it */
	      continue;

	   tp = g_objtype (g_desc (p));
	   sz += sz_val (tp, envp);
	   sz = align (sz, getflags (tp) & F_ALIGN);
	}

	if (g_fvariant (varp)  == NULL)
	   return sz;

	return sz_varval (g_fvariant (varp),
		  getpar (g_comp (g_dis (varp)), envp), sz, envp);
}

/*
 * compute the size of the descriptor space
 * needed to implement the filter ftp.
 * Note that a range constraint on an access type
 * is impossible.
 *
 *	get the size of a value descriptor
 */
MAXADDR	getvdsize (ftp)
ac	ftp;
{
	ac	btp;

	btp = root_type (ftp);

	ASSERT (btp != NULL, ("getvdsize:0"));

	switch (g_d (btp)) {
	   case XINTERNAL:
	   case XENUMTYPE:
	      return sz_cdbit (CD_BIT_S, 0);

	   case XARRAYTYPE:
	      return g_ARR_vdsize (btp);

	   case XRECTYPE:
	      return g_REC_vdsize (btp);

	   case XACCTYPE:
	      return sz_cdacc (g_ACC_nform (btp));

	   DEFAULT (("getvdsize %d", g_d (btp)));
	}
}

/*
 * the following routines return the (parametrized) sizes
 * of various runtime constructs;
 * In the file rt_types.h the structure declarations can be found.
 */
MAXADDR	sz_cb (nform)
short	nform;
{
	return sizeof (struct cb) + (nform - 1) * sizeof (struct cb_par);
}

MAXADDR	sz_cdbit (ttag, bitind)
int	ttag;
short	bitind;
{
	return ttag == CD_BIT_S || bitind == I_ENUM ?
			sizeof (struct ld_bit) :
			sizeof (struct ld_bit) - sizeof (struct ld_range);
}

MAXADDR	sz_tdarr (ndims)
short	ndims;
{
	return sizeof (struct tt_arr) + (ndims -1) * TADDRSIZE;
}

MAXADDR	sz_tdtask ()
{
	return (sizeof (struct tt_tsk));
}

MAXADDR	sz_tdacc (nform)
short	nform;
{
	return sizeof (struct tt_acc) + (nform - 1) * TADDRSIZE;
}

MAXADDR	sz_tdrec (nform, nflds, ninits, flags)
short	nform,
	nflds,
	ninits,
	flags;
{
	MAXADDR	size;

	size = sizeof (struct tt_rec) + (nform+nflds-1) * TADDRSIZE;
	if ((flags & (DYNREC|CSTREC)) == DYNREC)
	   size += nflds * TLONGSIZE;

	size += ninits * sizeof (struct tt_i) + TADDRSIZE;
	return size;
}

MAXADDR	sz_tdsrec (nflds, flags)
short	nflds,
	flags;
{
	MAXADDR	size;

	size = sizeof (struct tt_srec);
	if ((flags & VARREC) == VARREC)
	   size += (nflds - 1) * sizeof (struct tt_vr);
	else
	   size -= TLONGSIZE + sizeof (struct tt_vr);

	return size;
}

MAXADDR	sz_vdarr (ndims)
short	ndims;
{
	return sizeof (struct ld_arr) + (ndims-1) * sizeof (struct ld_arri);
}

MAXADDR	sz_cdacc (nform)
short	nform;
{
	return sizeof (struct ld_acc) + (nform-1) * TLONGSIZE;
}

MAXADDR	sz_vdrec (nform, nflds, flags)
short	nform,
	nflds,
	flags;
{
	MAXADDR	size;

	size = sizeof (struct ld_rec) + (nform - 1) * TLONGSIZE;
	if ((flags & CSTREC) == CSTREC)
	   size += nflds * TLONGSIZE;

	return size;
}

