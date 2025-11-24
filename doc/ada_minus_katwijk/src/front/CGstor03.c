
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
 *XXX	SPACE ALLOCATION FOR OBJECTS
 */

MAXADDR	visit_local (locp)
ac	locp;
{
	ASSERT (locp != NULL, ("visit_local"));

	if (ISVISITED (locp))
            return lev_off;

	SETBUSY (locp);

	switch (g_d (locp)) {
	   case XSUB:
		lev_off = subprogram (locp, lev_off);
		break;

	   case XACCEPT:
		break;

	   case XENTRY:
		lev_off = entry (locp, lev_off);
		break;

	   case XTASKTYPE:
		lev_off = tasktype (locp, lev_off);
		break;

	   case XTASKBODY:
		lev_off = taskbody (locp, lev_off);
		break;

	   case XSUBBODY:
		lev_off = subbody (locp, lev_off);
		break;

	   case XPACKBODY:
		break;

	   case XBLOCK:
		lev_off = block (locp, lev_off);
		break;

	   case XTASKSELECT:
		lev_off = taskselect (locp, lev_off);
		break;

	   case XOBJECT:
		lev_off = object (locp, lev_off);
		break;

	   case XRENOBJ:
		lev_off = renobj (locp, lev_off);
		break;

	   case XRENSUB:
		lev_off = rensub (locp, lev_off);
		break;

	   case XENUMTYPE:
		break;

	   case XRECTYPE:
		lev_off = rectype (locp, lev_off);
		break;

	   case XARRAYTYPE:
		lev_off = arrtype (locp, lev_off);
		break;

	   case XACCTYPE:
		lev_off = acctype (locp, lev_off);
		break;

	   case XINCOMPLETE:
		lev_off = typeref (g_complete (locp), lev_off);
		break;

	   case XPRIVTYPE:
		lev_off = typeref (g_impl (locp), lev_off);
	        break;

	   case XSUBTYPE:
		lev_off = optfilter (g_parenttype (locp), lev_off);
		break;

	   case XNEWTYPE:
		lev_off = typeref (g_old_type (locp), lev_off);
		break;

	   case XEXCEPTION:
		break;

	   case XINTERNAL:
		return lev_off;

	   DEFAULT (("visit_local: node %s\n", g_d (locp) ));
	}

	if (g_d (locp) == XACCTYPE && ISVISITED (locp)) {
	   /* is set visited in typeref;
	    * don't do it a second time.
	    */
	}
	else
	   SETVISITED (locp);

	return lev_off;
}	/* end of visit_local */

MAXADDR	incr_off (offset, amount)
MAXADDR	offset;
int	amount;
{
	offset += amount;
	lev_maxoff = max (offset, lev_maxoff);

	return offset;
}	/* end of incr_off */

/*	typeref.
 * 
 * verifies that the (sub)type pointed at by tp has been visited;
 * if not, it causes it to be visited before returning.
 * Care has been taken not to get into infinite recursion (because
 * a visit may cause a call to typeref again).
 * 
 * Typeref is called from two contexts:
 * 1. acctype ():	Acctype will only call typeref if the accessed
 * 		type is an access type (and thus can be visited
 * 		without harm); on recursive (access) type dependence
 * 		stop the recursion by allocating the ultimate
 * 		global access type descriptor.
 * 2. others:	The type referenced can be any type which must
 * 		have been visited before return to the caller;
 * 		if it is not an access type and it is busy (=
 * 		being visited) after all, it must be the case
 * 		that there is a recursive type dependence without
 * 		any intermediate access type, which is an error.
 * The "busy stack" of locals being visited always has the following
 * structure:
 * 	{ structured_type }*  { access_type }*  { scalar_type }*
 * where the top is on the right. Growing the stack stops for a
 * non-access type local when there is nothing to visit anymore,
 * for an access type when the referenced filter references an(other)
 * access type (and thus the current access type will use that access
 * type's representation), for a scalar type (visited from bittyperef
 * from an access type) when the type chain ends, or in any case
 * when a busy local must be visited again.
 */
MAXADDR	typeref (tp, off)
ac	tp;
MAXADDR	off;
{
	if (tp == NULL)
	   return off;

	ASSERT (is_typemark (tp), ("typeref"));
	/*
	 * ISVISITED (tp) is TRUE if tp is not in current list of locals
	 * or tp has been visited;
	 * update: isvisited is true iff it has been visited. 
	 * note that declarations in package specifications are considered
	 * to belong to the list of locals the package belongs to.
	 */
	if (ISVISITED (tp))
	   return off;
	/*
	 * must be a local (sub)type declaration
	 * which has not yet been visited
	 * but may be being visited (= busy) now;
	 * then take care for recursive type dependence.
	 */

	if (ISBUSY (tp))  {
	   tp = basefilter (tp);
	   if (g_d (tp) == XACCTYPE) {
		s_ACC_alloc (tp, GLOBAL);
	        s_ACC_nform (tp, 0);
   	        SETVISITED (tp);		/* !!!!! */
	   }
	   else
	       ASSERT (FALSE, ("recursice type dependence"));
	}
	else
	{  /*
	    * if typeref is called from acctype, tp must
	    * also be an access type and thus local (tp)
	    * causes acctype (tp) to be called;
	    * otherwise tp can be any type.
	    */
	    off = visit_local (tp);
	}

	return off;
}	/* end of typeref */

/*
 * bittyperef ensures that scalar types
 * referenced whereever from the type structure
 * pointed at by tp, will have been visited on return.
 * It is called when it is certain that the
 * type is scalar, or from 'acctype' when
 * there is danger for infinite recursion due
 * to legal recursive type dependence with
 * an intermediate access type.
 * Then the visit of the referenced structured type
 * is skipped, and only the types/filters
 * of the parameters (indices/discriminants) are visited,
 * since their information is necessary for the alloc
 * attribute of the access type.
 */
MAXADDR	bittyperef (tp, off)
ac	tp;
MAXADDR	off;
{
	if (tp == NULL)
	   return off;

	ASSERT (is_typemark (tp), ("bittyperef"));

	if (ISVISITED (tp))
	   return off;

	off = bitlocal (tp, off);

	return off;
}	/* end of bittyperef */

MAXADDR	bitlocal (tp, off)
ac	tp;
MAXADDR	off;
{
	ac	p;
/*
 * only visit relevant scalar types in the
 * typestructure pointed at by tp.
 * (see 'bittyperef').
 */
	if (tp == NULL)
	   return off;

	switch (g_d (tp)) {
	   case XRECTYPE:
		/*
		 * only visit the types of the disciminants
		 */
		FORALL (p, g_ffield (tp))
		    if (kind_of (g_desc (p)) == KDISCR)
			/* multiple visit is harmless,
			 * since only bittyperef is called
			 */
			off = optbitfilter (g_objtype (g_desc (p)), off);
		break;

	   case XARRAYTYPE:
		/*
		 * only visit the types of the indices
		 */
		FORALL (p, g_findex (tp))
		    off = bittyperef (g_indextype (p), off);
		break;

	   case XTASKTYPE:
		break;

	   case XENUMTYPE:
		break;

	   case XINCOMPLETE:
		off = bittyperef (g_complete (tp), off);
		break;

	   case XPRIVTYPE:
		off = bittyperef (g_impl (tp), off);
		break;

	   case XSUBTYPE:
		off = optbitfilter (g_parenttype (tp), off);
		break;

	   case XNEWTYPE:
		break;

	   DEFAULT (("bitlocal: %d", g_d (tp)));
	}

	if (is_scalar (tp)) {
	/*
	 * bittyperef must have visited the subconstruct
	 * so this construct has been visited too.
	 */
	   SETBUSY (tp);
	   SETVISITED (tp);
	}

	return off;
}	/* end of bitlocal */

/*
 * type:		filter |
 * 		INDIRECT M ;
 */
MAXADDR	optfilter (tp, off)
ac	tp;
MAXADDR	off;
{
	ASSERT (tp != NULL && isoptfilter (tp), ("optfilter"));

	if (g_d (tp) == XFILTER)
	   off = filter (tp, off);
	else
	   off = typeref (tp, off);

	return off;
}	/* end of optfilter */

MAXADDR	optbitfilter (tp, off)
ac	tp;
MAXADDR	off;
{
	ASSERT (tp != NULL && isoptfilter (tp), ("optbitfilter"));

	if (g_d (tp) == XFILTER)
	   off = bitfilter (tp, off);
	else
	   off = bittyperef (tp, off);
	
	return off;
}	/* end of optbitfilter */

MAXADDR	bitfilter (ftp, off)
ac	ftp;
MAXADDR	off;
{
	ac	cp,
		p;

	ASSERT (ftp != NULL &&  g_d (ftp) == XFILTER, ("bitfilter"));
	/*
	 * limited filter visiting; only the values
	 * of the constraint are relevant since they
	 * are inspected later by getbitalloc.
	 * For more comments see 'bittyperef' and 'bitlocal'.
	 */

	cp = g_constraint (ftp);
	switch (g_d (cp)) {
	   case XINDEXCONS:
	      FORALL (p, g_frange (cp))
	         off = bitrange (p, off);
	      break;

	   case XDISCRCONS:
	      FORALL (p, g_aggregate (cp))
		 off = bittyperef (g_exptype (g_compexpr (p)), off);
	      break;

	   case XRANGE:
	      off = bittyperef (g_filtype (ftp), off);
	      off = bitrange (cp, off);
	      break;

	   DEFAULT (("bitfilter: %d", g_d (cp)));
	}

	return off;
}	/* end of bitfilter */

MAXADDR	bitrange (rp, off)
ac	rp;
MAXADDR	off;
{
	ASSERT (rp != NULL && g_d (rp) == XRANGE, ("range"));

	if (g_rangetype (rp) != NULL)
	/*
	 * may have been subtype indication, i.e. with typemark
	 */
	   off = bittyperef (g_rangetype (rp), off);

	return off;
}	/* end of range */

/*
 * due to dynamic aggregates in a artificial subroutine
 * for default initialisations in rectypes.
 * Now we do not have a curr_proc or curr_bloc to save
 * our stacktop. We do know that we are in a sub although ...
 * and we have a global boolean to tell us where we are.
 */
void	sav_stack (x)
ac	x;
{
	x = surrounding_block (x);

	if (curr_proc == NULL) {
	   char datatext [AIDL];
	   setdatalab (x, datatext);
	   OUT (("&%d	4	%s\n",ICCOMM, datatext));
	}

	new_expr ();
	ASSIGN (ADDRESS);
	   if (curr_proc == NULL)
	      GLOB_OBJECT (0, x, ADDRESS);
	   else
	      LOC_OBJECT (curr_level, get_stacktop (x), ADDRESS);
	   REG (SP_DYN, ADDRESS);
}

