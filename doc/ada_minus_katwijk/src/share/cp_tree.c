/*
 * (c) copyright 1986, Delft University of Technology
 * Delft, The Netherlands
 *

 * This software remains the property of the Delft University of Tech.
 * The software is a part of the Delft Ada Subset Compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University of Tech.
 *
 * For further information contact
 *	Jan van Katwijk
 *	Department of Mathemetics and Informatics
 *	Delft University of Technology
 *	julianalaan 132 Delft The Netherlands.
 *
 */

#include	<stdio.h>
#include	"../h/unix.h"
#include	"../h/rt_defs.h"
#include	"../h/tree.h"
#include	"../h/std.h"
#include	"../h/record_man.h"
#include	"../h/rec_sizes.h"
#include	"../h/main.h"

#include	"../front/front.h"
/*
 *	Tree copy routine.
 *
 *	Enter a tree and get a copy of it as a result
 *
 *	First version: ONLY EXPRESSIONS
 *
 *	Later versions will be used to support generic instantiation
 */

ac	cp_tree ();
ac	cp_node ();
ac	cp_attr ();
ac	cp_list ();

ac cp_tree (pnt)
register ac pnt;
{
	register ac x, y;

	if (pnt == NULL)
	   return NULL;

	x = cp_node (pnt);

	/* now for the structural information	*/

	switch (pnt -> d) {
		case XAGGREGATE:
			x -> aggtype = cp_attr (pnt -> aggtype);
			x -> fcompas = cp_list (pnt -> fcompas);
			break;

		case XALL:
			s_next (x, cp_tree (g_next (pnt)));
			break;

		case XALLOCATOR:
			x -> obtype = cp_attr (pnt -> obtype);
			break;

		case XASSIGN:
			x -> lhs = cp_attr (pnt -> lhs);
			x -> rhs = cp_tree (pnt -> rhs);
			break;

		case XATTRIBUTE:
			x -> entity = cp_tree (pnt -> entity);
			s_next (x, cp_tree (g_next (pnt)));
			break;

		case XCALL:
			x -> fact = cp_list (pnt -> fact);
			s_next (x, cp_tree (g_fact (pnt)));
			break;

		case XCOMPASSOC:
			x -> fcompchoice = cp_list (pnt -> fcompchoice);
			x -> compexpr = cp_tree (pnt -> compexpr);
			break;

		case XDISCRCONS:
			x -> aggregate = cp_tree (pnt -> aggregate);
			break;

		case XEXP:
			x -> primary = cp_attr (pnt -> primary);
			break;

		case XFILTER:
			x -> constraint = cp_tree (pnt -> constraint);
			break;

		case XIN:
			x -> intype = cp_attr (pnt -> intype);
			x -> inexpr = cp_tree (pnt -> inexpr);
			break;

		case XINDEXCONS:
			x -> frange = cp_attr (pnt -> frange);
			break;

		case XINDEXING:
			x -> farg = cp_list (pnt -> farg);
			s_next (x, cp_tree (g_farg (pnt)));
			break;

		case XINTERNAL:
			break;

		case XLITERAL:
			break;

		case XMARK:
			break;

		case XNAME:
			break;

		case XNAMEDASS:
			x -> nexp = cp_attr (pnt -> nexp);
			break;

		case XNEWTYPE:
			break;

		case XPARENTHS:
			x -> subexpr = cp_list (pnt -> subexpr);
			break;

		case XRANGE:
			s_frang_exp (x, cp_list (g_frang_exp (pnt)));
			break;

		case XSCC:
			x -> fsccexpr = cp_list (pnt -> fsccexpr);
			break;

		case XSELECT:
			s_next (x, cp_tree (g_next (pnt)));
			break;


		case XSLICE:
			x -> slrange = cp_attr (pnt -> slrange);
			x -> next    = cp_tree (pnt -> next);
			break;

/*
		case XSUBCALL:
			x -> factual = cp_list (pnt -> factual);
			break;
 */

		case XTHUNK:
			x -> thexpr = cp_attr (pnt -> thexpr);
			break;

		case XTYPECONV:
			x -> convexpr = cp_attr (pnt -> convexpr);
			break;

		case XOBJDESC:
			x -> expr = cp_tree (pnt -> expr);
			break;

		DEFAULT (("illegal node in cp_tree %d\n", pnt -> d));
	}
	return x;
}

ac
cp_node (node)
register ac node;
{
	register short d;
	register ac *x;

	ASSERT (node != NULL, ("cp_node: try to copy an empty node"));

	d = node -> d;

	x = alloc (d);
	switch (d) {
	case XAGGREGATE:
		(*x)._aggregate = (*node)._aggregate;
		break;

	case XALL:
		(*x)._all = (*node)._all;
		break;

	case XALLOCATOR:
		(*x)._allocator = (*node)._allocator;
		break;

	case XARRAYTYPE:
		(*x)._arraytype = (*node)._arraytype;
		break;

	case XASSIGN:
		(*x)._assign = (*node)._assign;
		break;

	case XATTRIBUTE:
		(*x)._attribute = (*node)._attribute;
		break;

	case XBLOCK:
		(*x)._block = (*node)._block;
		break;

	case XCALL:
		(*x)._call = (*node)._call;
		break;

	case XCASE:
		(*x)._case = (*node)._case;
		break;

	case XCHARLIT:
		(*x)._charlit = (*node)._charlit;
		break;

	case XCOMPASSOC:
		(*x)._compassoc = (*node)._compassoc;
		break;

	case XDISCR:
		(*x)._discr = (*node)._discr;
		break;

	case XDISCRCONS:
		(*x)._discrcons = (*node)._discrcons;
		break;

	case XENUMLIT:
		(*x)._enumlit = (*node)._enumlit;
		break;

	case XENUMTYPE:
		(*x)._enumtype = (*node)._enumtype;
		break;

	case XEXHANDLER:
		(*x)._exhandler = (*node)._exhandler;
		break;

	case XEXIT:
		(*x)._exit = (*node)._exit;
		break;

	case XEXCEPTION:
		(*x)._exception = (*node)._exception;
		break;

	case XEXP:
		(*x)._exp = (*node)._exp;
		break;

	case XFILTER:
		(*x)._filter = (*node)._filter;
		break;

	case XFORBLOCK:
		(*x)._forblock = (*node)._forblock;
		break;

	case XIF:
		(*x)._if = (*node)._if;
		break;

	case XIFITEM:
		(*x)._ifitem = (*node)._ifitem;
		break;

	case XIN:
		(*x)._in = (*node)._in;
		break;

	case XINCOMPLETE:
		(*x)._incomplete = (*node)._incomplete;
		break;

	case XINDEX:
		(*x)._index = (*node)._index;
		break;

	case XINDEXCONS:
		(*x)._indexcons = (*node)._indexcons;
		break;

	case XINDEXING:
		(*x)._indexing = (*node)._indexing;
		break;

	case XINDIRECT:
		(*x)._indirect = (*node)._indirect;
		break;

	case XINTERNAL:
		(*x)._internal = (*node)._internal;
		break;

	case XLITERAL:
		(*x)._literal = (*node)._literal;
		break;

	case XLOOPBLOCK:
		(*x)._loopblock = (*node)._loopblock;
		break;

	case XMARK:
		(*x)._mark = (*node)._mark;
		break;


	case XNAME:
		(*x)._name = (*node)._name;
		break;

	case XNAMEDASS:
		(*x)._namedass = (*node)._namedass;
		break;

	case XOBJDESC:
		(*x)._objdesc = (*node)._objdesc;
		break;

	case XOBJECT:
		(*x)._object = (*node)._object;
		break;

	case XPACKAGE:
		(*x)._package = (*node)._package;
		break;

	case XPACKBODY:
		(*x)._packbody = (*node)._packbody;
		break;

	case XPARENTHS:
		(*x)._parenths = (*node)._parenths;
		break;

	case XPRIVPART:
		(*x)._privpart = (*node)._privpart;
		break;

	case XPRIVTYPE:
		(*x)._privtype = (*node)._privtype;
		break;

	case XRAISE:
		(*x)._raise = (*node)._raise;
		break;

	case XRANGE:
		(*x)._range = (*node)._range;
		break;

	case XRECTYPE:
		(*x)._rectype = (*node)._rectype;
		break;

	case XRENOBJ:
		(*x)._renobj = (*node)._renobj;
		break;

	case XRENPACK:
		(*x)._renpack = (*node)._renpack;
		break;

	case XRENSUB:
		(*x)._rensub = (*node)._rensub;
		break;

	case XRETURN:
		(*x)._return = (*node)._return;
		break;

	case XSCC:
		(*x)._scc = (*node)._scc;
		break;

	case XSELECT:
		(*x)._select = (*node)._select;
		break;

	case XSEPARATE:
		(*x)._separate = (*node)._separate;
		break;

	case XSLICE:
		(*x)._slice = (*node)._slice;
		break;

	case XSTUB:
		(*x)._stub = (*node)._stub;
		break;

	case XSUB:
		(*x)._sub = (*node)._sub;
		break;

	case XSUBBODY:
		(*x)._subbody = (*node)._subbody;
		break;

	case XSUBCALL:
		(*x)._subcall = (*node)._subcall;
		break;

	case XSUBTYPE:
		(*x)._subtype = (*node)._subtype;
		break;

	case XNEWTYPE:
		(*x)._newtype = (*node)._newtype;
		break;

	case XTHUNK:
		(*x)._thunk = (*node)._thunk;
		break;

	case XTYPECONV:
		(*x)._typeconv = (*node)._typeconv;
		break;

	case XTAGSTAT:
		(*x)._tagstat = (*node)._tagstat;
		break;

	case XUSE:
		(*x)._use = (*node)._use;
		break;


	case XVARIANT:
		(*x)._variant = (*node)._variant;
		break;

	case XWHENITEM:
		(*x)._whenitem = (*node)._whenitem;
		break;

	case XWITH:
		(*x)._with = (*node)._with;
		break;

	DEFAULT (("strange record kind: %d\n", d));
	}

	return x;		/*	!!!	*/
}

ac
cp_attr (node)
register ac *node;
{
	switch (node -> d)
	{
	case XENUMLIT:
	case XFILTER:
	case XINTERNAL:
	case XLITERAL:
	case XOBJDESC:
	case XOBJECT:
	case XRANGE:
	case XSUB:
		return node;
		break;
	default:
		return cp_tree (node);
		break;
	}
}

ac
cp_list (node)
register ac *node;
{
	register ac *x;

	if (node == NULL)
	   return NULL;
	x = cp_tree (node);
	x -> next = cp_list (node -> next);
	return x;
}
