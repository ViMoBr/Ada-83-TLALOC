
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
 *	For further information contact:
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"

/*
 *	VARIOUS SUPPORT ROUTINES FOR STORAGE ALLOCATION
 */

/*
 *	where is the value to be found in the YY bits (bytes)
 *	of the parameter. Machine dependent.
 */
int	paramoffset (bt, stor)
int	bt,
	stor;
{
	if (stor != PARSTACK)
	   return 0;

	switch (bt) {
	   case BYTE:
	   case UCHAR:
	       return BYTE_IN_LONG;

	   case SHORT:
	      return SHORT_IN_LONG;

	   default:
	      return LONG_IN_LONG;
	}

}

/*
 *	What is the size on the actual parameter stack
 *	of an actual of type tp ?
 */
int	parameter_size (tp)
ac	tp;
{
	tp = basefilter (tp);

	if (pcc_float (tp))
	   return TFLOATSIZE;

	if (is_scalar (tp))
	   return TLONGSIZE;

	return TADDRSIZE;
}

int	val_size (t)
int	t;
{
	switch (t) {
	   case UCHAR:
	   case BYTE:
	      return TBYTESIZE;

	   case SHORT:
	      return TINTSIZE;

	   case FLOAT:
	      return TFLOATSIZE;

	   default:
	      return TADDRSIZE;
	}
}

/*
 * Declaration treewalk stack addressing computation
 * auxiliary routines
 *
 */
bool	static_or_discr (x)
ac	x;
{
	if (x == NULL)
	   return FALSE;

	if (is_static (x))
	   return TRUE;

/* finally for the sake of discriminants */
	x = g_primary (x);
	if (x == NULL)
	   return FALSE;

	if (g_d (x) != XNAME)
	   return FALSE;

	if (!is_discr (g_fentity (x)))
	   return FALSE;

	return TRUE;
}

short	getrgalloc (rp)
ac	rp;
{
	int	alloc = GLOBAL;
	ac	p;

	ASSERT (rp != NULL && g_d (rp) == XRANGE, (("getrgalloc")));

	if (g_frang_exp (rp) == NULL)
	   alloc = getbitalloc (g_rangetype (rp));
	else
	   FORALL (p, g_frang_exp (rp))
	      alloc = max (alloc, getexpalloc (p));

	return alloc;
}	/* end of getrgalloc */

short	getbrgflags (x)
ac	x;
{
	x = basefilter (x);

	ASSERT (x != NULL, ("getbrgflags"));
	if (g_d (x) != XFILTER)
	   return getflags (x);
	else
	   return getrgflags (g_constraint (x));
}

/*
 *	in spite of the name "getrgflags" what we actually mean
 *	here is get_index_constraint flags
 */
short	getrgflags (rp)
ac   rp;
{
	short	flags = 0;
	ac	p;

	ASSERT (rp != NULL && g_d (rp) == XRANGE, ("getrgflags"));

	if (g_frang_exp (rp) == NULL)
	   flags = getbrgflags (g_rangetype (rp));
	else
	   FORALL (p, g_frang_exp (rp))
	      flags |= getexpflags (p);

	return flags;
}	/* end of getrgflags */

short	getexpflags (ep)
ac	ep;
{
	short	flags = 0;

	ASSERT (ep != NULL && g_d (ep) == XEXP, ("getexpflags"));

	if (isdiscrdepexp (ep)) {
	   flags |= CSTREC;
	   return flags;
	}

	if (!static_or_discr (ep))
	   flags |= DYNREC;

	return flags;
}	/* end of exprkind */

/*
 *	get the allocation class of an expression
 *	an expression consisting of a single discriminant
 *	is an exception !!!
 */
short	getexpalloc (ep)
ac	ep;
{
	ac	x;

	ASSERT (ep != NULL && g_d (ep) == XEXP, ("getexpalloc"));

	/*
	 * only handles scalar expressions !
	 */
	if (is_static (ep))
	   return NOALLOC;

	x = g_primary (ep);
	if (x != NULL && g_d (x) == XNAME && 
	    is_discr (g_fentity (x)) )
	   return NOALLOC;

	return FIXSTACK;
}	/* end of getexpalloc */

short	getalloc (tp)
ac	tp;
{
	/*
	 * getalloc gets the alloc attribute of types and filters
	 * that have been visited (see typeref).
	 * The alloc attribute of limited-visited types and filters
	 * will be computed by getbitalloc below.
	 */
	ASSERT (tp != NULL, ("getalloc:0"));

	while (TRUE) {
	   tp = basefilter (tp);

	   if (tp == NULL)
	      return NULL;

	   switch (g_d (tp)) {
	      case XFILTER:
	         return g_FLT_alloc (tp);

	      case XINTERNAL:
	      case XENUMTYPE:
	         return GLOBAL;

	      case XTASKTYPE:
	         return g_TSKT_alloc (tp);

	      case XARRAYTYPE:
	         return g_ARR_alloc (tp);
	   
	      case XRECTYPE:
	         return g_REC_alloc (tp);

	      case XACCTYPE:
	         return g_ACC_alloc (tp);

	      case XNEWTYPE:
	         tp = g_old_type (tp);
	         break;

	      case XINCOMPLETE:
	         if (g_complete (tp) != NULL)
	            tp = g_complete (tp);
	         else
	            return FIXSTACK;	/* who knows	*/
	         break;

	      DEFAULT (("getalloc: %d", g_d (tp)));
	   }
	}
}	/* end of getalloc */

short	getbitalloc (tp)
ac	tp;
{
	ac	p,
		cp;
	int	alloc;

/*
 * compute alloc attribute of limited-visited types and filters;
 * only called
 * from acctype, range and recursively from getbitalloc itself.
 * For record and array types ignore the element and field types
 * since they do not contribute to the alloc of an access type.
 * Any constituent ranges must have been visited.
 * See 'bittyperef' etc. for more details.
 */

	if (tp == NULL)
	   return 0;

	alloc = GLOBAL;
	tp = basefilter (tp);

	ASSERT (tp != NULL, ("getbitalloc:0"));

	switch (g_d (tp)) {
	   case XNEWTYPE:
	      return getbitalloc (g_old_type (tp));

	   case XFILTER:
	      cp = g_constraint (tp);
	      switch (g_d (cp)) {
	         case XINDEXCONS:
	            FORALL (p, g_frange (cp))
		       alloc = max (alloc, getrgalloc (p));
		    break;

		 case XDISCRCONS:
		    FORALL (p, g_aggregate (cp))
		       alloc = max (alloc, getexpalloc (g_compexpr (p)));
	            break;

		 case XRANGE:
		    alloc = getrgalloc (cp);
		    break;

		 DEFAULT (("getbitalloc: %d constraint?", g_d (cp)));
	      }
	      break;

	   case XARRAYTYPE:
	      FORALL (p, g_findex (tp))
		 alloc = max (alloc, getbitalloc (g_indextype (p)));
	      break;

	   case XRECTYPE:
	      FORALL (p, g_ffield (tp)) {
	         if (g_d (p) != XOBJECT)
	            continue;
		 if (kind_of (g_desc (p)) == KDISCR)
		    alloc = max (alloc, getbitalloc (g_objtype (g_desc (p))));
	      }
	      break;

	   case XENUMTYPE:
	   case XINTERNAL:
	   case XTASKTYPE:
	   case XACCTYPE:
	      break;

	   case XINCOMPLETE:
	      if (g_complete (tp) != NULL)
 	         return getbitalloc (g_complete (tp));
	      else
	         return FIXSTACK;

	   DEFAULT (("getbitalloc: %d", g_d (tp)));
	}

	return alloc;
}	/* end of getbitalloc */

short	getflags (tp)
ac	tp;
{
	ASSERT (tp != NULL, ("getflags:0"));

	while (TRUE) {
	   tp = basefilter (tp);
	   if (tp == NULL)
	      return 0;

	   switch (g_d (tp)) {
	      case XFILTER:
	         return g_FLT_flags (tp);

	      case XENUMTYPE:
	         return al_bitval (I_ENUM);

	      case XINTERNAL:
	         return al_bitval (g_ind (tp));

	      case XTASKTYPE:
	         return g_TSKT_flags (tp);

	      case XARRAYTYPE:
	         return g_ARR_flags (tp);

	      case XRECTYPE:
	         return g_REC_flags (tp);

	      case XACCTYPE:
	         return g_ACC_flags (tp);

	      case XNEWTYPE:
	         return getflags (g_old_type (tp));

	      case XINCOMPLETE:
	         if (g_complete (tp) != NULL)
	            return getflags (g_complete (tp));
	         else
	            return 0;

	      DEFAULT (("getflags: %d", g_d (tp)));
	   }
	}
}	/* end of getflags */

short	geteflags (x)
ac	x;
{
	if (x == NULL)
	   return 0;

	return g_flags (x) & EMASK;
}

/*
 *	Isvisited determines wether the attributes of a node have been
 *	computed. This is true if
 *	-	the node does not belong to the curren subbody, or
 *	-	it has been visited.
 */
bool	ISVISITED (locp)
ac	locp;
{
	return locp == NULL
	       || g_d (locp) == XINTERNAL
	       || (TEST (locp, VISITED) == VISITED);
}

bool	ISBUSY (locp)
ac	locp;
{
	return locp != NULL && (TEST (locp, BUSY) == BUSY);
}

bool	SETBUSY (locp)
ac	locp;
{
	ASSERT (locp != NULL, ("in setbusy"));
	ASSERT (TEST (locp, (VISITED|BUSY)) == 0, ("in SETBUSY"));

	SET (locp, BUSY);
}

bool	SETVISITED (locp)
ac	locp;
{
	ASSERT (locp != NULL, ("in SETVISITED"));
	ASSERT (TEST (locp, (BUSY|VISITED)) == BUSY, ("in setvisited"));

	UNSET (locp, BUSY);
	SET (locp, VISITED);
}

MAXADDR	align (off, a)
MAXADDR	off;
short	a;	/* only F_ALIGN field! */
{
	return  (off + a) & ~a;
}

ac	enclsub (x)
ac	x;
{
	if (!is_enclosed (x)) {
	   return NULL;
	}

	x = g_enclunit (x);
	while (x != NULL && g_d (x) != XSUBBODY && g_d (x) != XTASKBODY) {
	   x = g_enclunit (x);
	}

	return x;
}

/*
 * calculate number of actuals required to constrain tp.
 * If a type (called from "acctype"),
 * it is the number of formals of the type;
 * since getnform can also be called for non-visited types
 * (see "acctype"), it must be able to deduce the number
 * of formals in that case too.
 */
short	getnform (tp)
ac	tp;
{
	ac	p,
		cp,
		q;
	int	nform;

	nform = 0;
	tp = basefilter (tp);

	ASSERT (tp != NULL, ("getnform:0"));

	switch (g_d (tp)) {
	   case XNEWTYPE:
	      return getnform (g_old_type (tp));

	   case XARRAYTYPE:
	      /* called from "acctype" */
	      if (ISVISITED (tp))
	         return  2 * g_ARR_ndims (tp);
	      FORALL (p, g_findex (tp))
		 nform += 2;
	      return nform;

	   case XRECTYPE:
	      /* called from "acctype" */
	      if (ISVISITED (tp))
	         return g_REC_forms (tp);
	      FORALL (p, g_ffield (tp)) {
		 if (g_d (p) != XOBJECT)
		    continue;
		 if (kind_of (g_desc (p)) == KDISCR)
		    nform++;
	      }
	      return nform;

	   case XACCTYPE:
	      /* called from "acctype" */
	      if (ISVISITED (tp))
		  return g_ACC_nform (tp);

		/*
		 * This point can only be reached when
		 * getnform is called by acctype and by acctype
		 * a filter has been found that is referenced
		 * by the access type.
		 * Infinit recursion cannot happen now,
		 * since recursive type dependence of only
		 * access types implies that the access type
		 * has no formals, and thus cannot carry
		 * a filter (if the input DAS tree is correct).
		 */
	      return getnform (g_actype (tp));

	   case XENUMTYPE:
	   case XINTERNAL:
	   case XTASKTYPE:
	   case XFILTER:
	      return 0;

	   case XINCOMPLETE:
	      FORALL (p, g_fidiscr (tp))
		   nform ++;
	      return nform;

	   DEFAULT (("getnform: %d", g_d (tp)));
	}
}	/* end of getnform */

