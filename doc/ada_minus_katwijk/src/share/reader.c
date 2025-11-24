#
/*
 * (c) copyright 1986, 1987, 1988, Delft University of Technology
 * Delft, The Netherlands
 *
 * This software remains the property of the Delft University
 * of Technology. It is part of the Delft Ada Subset compiler
 *
 * Permission to use, sell, duplicate or disclose the software
 * must be obtained, in writing, from the Delft University
 * of Technology.
 *
 * For further information contact:
 *
 *	Jan van Katwijk
 *	Department of Mathematics and Computer Science
 *	Delft University of Technology
 *	132 Julianalaan Delft, The Netherlands
 */

#include	<stdio.h>
#include	"../h/print.h"
#include	"../h/tree.h"
#include	"../h/std.h"
#include	"../h/record_man.h"
#include	"../h/reader.h"
#include	"../h/view.h"
/*
 *	Forward (static) declarations:
 */
extern	short	mainlun;


static	ac	list_of		();
static	bool	tag_eq		();
static	struct lib_unit *find_unit	();
static	bool	is_genericpackage	();
static	int	tree_lex	();
static	ac	get_local	();
static	ac	subtype_ind	();
static	ac	constr		();
static	ac	expr		();
static	ac	opt_except	();
static	ac	exc_handler	();
static	ac	statement	();
static	ac	ifitem		();
static	ac	whenitem	();
static	ac	index		();

/*
 *	Our magic word:
 */
#define	MAGIC	(((('j' << 4) + ('a')) << 4) + 'n')

/*
 *	Recursive descent parser for DAS trees.
 *
 *	This simplified parser assumes that the input
 *	is error-free. No guarantee is given that
 *	in case of non-error free input anything sensible
 *	is done.
 */

/*
 *	statics.
 *	Note that there is a single reader both for
 *	reading in the precompiled units, the "with"
 *	units as well as the unit to compile
 *
 */
int	tree_symb;
ac	tree_val;
static	ac	subtree;
struct	lib_unit lib_start;
struct	lib_unit *lib_head	= &lib_start;
struct	lib_unit *lib_list	= &lib_start;


#define	SKIP_MARK(x)	\
{	\
	ASSERT (tree_symb == XMARK, x);	\
	tree_symb = tree_lex (f);	\
}

/*
 *	Here the real stuff begins
 */

static
ac	list_of (x, y)
ac	(*x)();
FILE	*y;
{
	ac	t,
		z,
		a;

	t = (*x)(y);
	if (t == NULL)
	   return NULL;

	z = t;
	while (z != NULL) {
	    s_next (z, (*x)(y));
	    z = g_next (z);
	}

	return t;
}

static
bool	tag_eq (x, y)
char	*x,
	*y;
{
	while (*x == *y)	
	  if (*x == EOS)
	     return TRUE;
	  else
	     x ++, y ++;

	return FALSE;
}

void	ini_liblist ()
{
	lib_list = &lib_start;
	lib_list -> next_unit = NULL;
	lib_list -> unit = NULL;
	lib_list -> with_list = NULL;
	lib_list -> lib_kind = 0;
}

static
struct lib_unit *find_unit (t, k)
char	*t;
int	k;
{
	struct lib_unit *l = lib_head -> next_unit;

	while (l != NULL)
	   if (tag_eq (t, g_tag (l -> unit)) && l -> lib_kind == k)
	      return l;
	   else
	      l = l -> next_unit;

	return NULL;
}

void	writ_tree (f_name, w_list, treepntr, lun)
char	*f_name;
ac	w_list,
	treepntr;
short	lun;
{
	ac	x;
	struct tree_header curr_tree;
	FILE	*yyout;

	curr_tree. tr_magic = MAGIC;
	curr_tree. tr_lun   = lun;
	curr_tree. tr_nindex= nindex (lun);

	yyout = fopen (f_name, "w");
	if (yyout == NULL)
	   sys_error ("cannot open %s, fatal", f_name);

	fwrite (&curr_tree, sizeof (struct tree_header), 1, yyout);
/*
 *	Now for the with list
 */
	if (lun != STD_LUN) {
	   FORALL (x, w_list) {
	      put_rec (yyout, x);
	      put_mark (yyout);
	   }

	   put_mark (yyout);
	   put_mark (yyout);
	}
/*
 *	Now for the real tree
 */
	put_list (yyout, treepntr);

	fclose (yyout);
}

void	rd_standard ()
{
	char	*f1,
		t[100];
	int	status = TRUE;

	f1 = f_name ("STD_PS", SPEC, &status);

	if (!status) {
	   fail ((short) mainlun, status);
	   fprintf (stderr, "Cannot open package standard\n");
	   fflush (stdout);
	   exit (112);
	}

	strcpy (t, f1);
	get_tree (NULL, t, SPEC);
}

static
bool	is_genericpackage (p)
struct lib_unit *p;
{
	if (p == NULL)
           return FALSE;

	if (g_d (p -> unit) != XGENNODE)
	   return FALSE;

	return TRUE;
}

struct lib_unit *read_tree (s, k)
char	*s;
int	k;
{
	struct lib_unit *t;
	char	*ss,
		tt[ 100];
	int	status	= TRUE;
	struct lib_unit *temp;
/*
 *	First check whether or not the unit is already
 *	there
 */
	t = find_unit (s, k);
	if (t != NULL) {
	   return t;
	}

	ss = f_name (s, k, &status);
	if (!status) {
	   return NULL;
	}

	strcpy (tt, ss);
	temp = get_tree (-1, tt, k);


	if (is_genericpackage (temp))
	   read_tree (s, XBODY);  /* linking to the spec is automatically */

	return temp;
}

/*
 *	LIBRARY NOT USED AS YET
 */
struct lib_unit *get_tree (libr, f_name, k)
char	*libr;
char	*f_name;
int	k;
{
	FILE	*inpfile;
	ac	subtree;
	struct	tree_header curr_tree;
	short	lun;

	inpfile = fopen (f_name, "r");
	if (inpfile == NULL) {
	   fprintf (stderr,
                  "Seem to have a problem with %s, cannot recover\n", f_name);
	   fflush (stdout);
	   abort ();
	}

	if (fread (&curr_tree, sizeof (struct tree_header), 1, inpfile) == 0) {
	   fprintf (stderr, "Cannot read from %s\n", f_name);
	   fflush (stdout);
	   abort ();
	}

	if (curr_tree. tr_magic != MAGIC) {
	   fprintf (stderr, "Illegal file format %s\n", f_name);
	   exit (112);
	}

	lun = curr_tree. tr_lun;
	next_lun (lun, curr_tree. tr_nindex);
/*
 *	Here we really go
 */
	tree_symb = tree_lex (inpfile);
	/*
	 * Handling lun 2 is a special case, in particular
	 * for initialization
	 */
	if (lun == STD_LUN && lun != mainlun) {
	   while ((subtree = get_local (inpfile)) != NULL)
	      stan_link (subtree);
	   fclose (inpfile);
	   return NULL;
	}
	else
	{ struct lib_unit *cu =
	               (struct lib_unit *)l_alloc (sizeof (struct lib_unit));
	  if (cu == NULL) {
	       sys_error ("Memory problem %s, fatal\n", f_name);
	  }

	  if (mainlun != STD_LUN)
	      cu -> with_list = with_units (inpfile);
	  else
	     cu -> with_list = NULL;

	  subtree = list_of (get_local, inpfile);
	  if (subtree == NULL)
	      sys_error ("Empty tree %s, fatal\n", f_name);

	  cu -> unit = subtree;
	  cu -> lib_kind = k;

	  lib_list -> next_unit = cu;
	  lib_list = cu;
	}

	fclose (inpfile);

	return lib_list;
}

ac	with_units (f)
FILE	*f;
{
	ac	x,
		tt;
	int	s;
	struct	lib_unit *t;

	if (tree_symb == -1)
	   return NULL;

	x = tree_val;
	switch (g_d (x)) {
	   case XWITH:
	      tree_symb = tree_lex (f);
	      s = tree_symb;
	      tt = tree_val;

	      t = read_tree (g_tag (x), SPEC);
	      if (t == NULL) {
		 fprintf (stderr, "Cannot read tree of %s\n", g_tag (x));
		 fflush (stdout);
		 exit (33);
	      }

	      s_withunit (x, t -> unit);
	      tree_symb = s;
	      tree_val = tt;
	      break;


	   case XSEPARATE:
	      tree_symb = tree_lex (f);
	      s = tree_symb;
	      tt = tree_val;

	      t = read_tree (g_tag (x), XBODY);
	      s_septree (x, t);
	      tree_symb = s;
	      tree_val = tt;
	      break;

	   case XUSE:
	      tree_symb = tree_lex (f);
	      break;

	   default:
	      ASSERT (tree_symb == XMARK, ("w_units: MARK expected"));

	      tree_symb = tree_lex (f);
	      ASSERT (tree_symb == XMARK, ("w_units (2): MARK expected"));

	      tree_symb = tree_lex (f);
	      return NULL;
	}

	ASSERT (tree_symb == XMARK, ("wu_units: MARK expected"));
	tree_symb = tree_lex (f);
	s_next (x, with_units (f));
	return x;
}

static
int	tree_lex (f)
FILE	*f;
{
	int	x;

	tree_val = get_rec (f);
	if (tree_val == NULL)
	   return -1;

	x = g_d (tree_val);
	return x;
}

/*
 *
 */
static
ac	get_local (f)
FILE	*f;
{
	ac	x,
		y,
		z;

	if (tree_symb == -1)
	   return NULL;

	PRINTF ((printf ("in get_local with %d %s\n",
                                  g_d (tree_val), g_tag (tree_val)) ));
	x = tree_val;
	switch (g_d (x)) {
	   case XARRAYTYPE:
		tree_symb = tree_lex (f);
		s_findex (x, list_of (index, f));
		goto skip_mark;

	   case XACCTYPE:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XRECTYPE:
		tree_symb = tree_lex (f);
		s_ffield (x, list_of (get_local, f));
		s_dis (x, expr (f));
		goto skip_mark;

	   case XVARIANT:
		tree_symb = tree_lex (f);
		s_varchoice (x, list_of (constr, f));
		s_ffield (x, list_of (get_local, f));
		s_dis (x, expr (f));
		goto skip_mark;

	   case XNEWTYPE:
		tree_symb = tree_lex (f);
		s_enlits (x, list_of (get_local, f));
		goto skip_mark;

	   case XSUBTYPE:
		tree_symb = tree_lex (f);
		s_parenttype (x, subtype_ind (f));
		goto skip_mark;

	   case XRENSUB:
	   case XENTRY:
		tree_symb = tree_lex (f);
		s_fformal (x, list_of (get_local, f));
		if (g_d (x) == XRENSUB)
		   s_subname (x, expr (f));
		goto skip_mark;
	   case XSUB:
		tree_symb = tree_lex (f);
		s_fformal (x, list_of (get_local, f));
		s_sub_default (x, expr (f));
		goto skip_mark;


	   case XENUMTYPE:
		tree_symb = tree_lex (f);
		s_fenumlit (x, list_of (get_local, f));
		goto skip_mark;

	   case XPACKAGE:
		tree_symb = tree_lex (f);
		s_fvisitem (x, list_of (get_local, f));
		goto skip_mark;

	   case XGENNODE:
		tree_symb = tree_lex (f);
		s_genpars (x, list_of (get_local, f));
		SKIP_MARK (("gennode"));
		s_genunit (x, get_local (f));
		goto skip_mark;

	   case XGENPARTYPE:
		tree_symb = tree_lex (f);
		goto skip_mark;


	   case XTASKTYPE:
		tree_symb = tree_lex (f);
		s_fentry (x, list_of (get_local, f));
		goto skip_mark;

	   case XPRIVPART:
		tree_symb = tree_lex (f);
		s_fprivitem (x, list_of (get_local, f));
		goto skip_mark;

	   case XINCOMPLETE:
		tree_symb = tree_lex (f);
		s_fidiscr (x, list_of (get_local, f));
		goto skip_mark;

	   case XPRIVTYPE:
		tree_symb = tree_lex (f);
		s_fpdiscr (x, list_of (get_local, f));
		goto skip_mark;

	   case XINHERIT:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XTRIPLE:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XPACKBODY:
		tree_symb = tree_lex (f);
		s_fbodyloc (x, list_of (get_local, f));
		s_PB_stats (x, list_of (statement, f));
		s_PB_exh (x, opt_except (f));
		s_pack_body (g_specif (x), x);
		goto skip_mark;

	   case XSUBBODY:
		tree_symb = tree_lex (f);
		s_fbodyloc (x, list_of (get_local, f));
		s_SBB_stats (x, list_of (statement, f));
		s_SBB_exh (x, opt_except (f));
		goto skip_mark;

	case XTASKBODY:
		tree_symb = tree_lex (f);
		s_fbodyloc (x, list_of (get_local, f));
		s_task_stats (x, list_of (statement, f));
		s_task_exh (x, opt_except (f));
		goto skip_mark;

	   case XOBJDESC:
		tree_symb = tree_lex (f);
		s_expr (x, expr (f));
		goto skip_mark;

	   case XOBJECT:
		tree_symb = tree_lex (f);
		s_desc (x, get_local (f));
		goto skip_mark;

	   case XSEPARATE:
	   case XENUMLIT:
	   case XCHARLIT:
	   case XSTUB:
	   case XUSE:
	   case XEXCEPTION:
	   case XRENPACK:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XRENOBJ:
		tree_symb = tree_lex (f);
		s_name (x, expr (f));
		goto skip_mark;

	   default:
		return NULL;
	}

skip_mark:
	SKIP_MARK (("local %d %s\n", g_d (x), g_tag (x)));
	return x;
}

static
ac	subtype_ind (f)
FILE	*f;
{
	ac	x,
		y;

	x = tree_val;
	switch (tree_symb) {
	   case XFILTER:
		tree_symb = tree_lex (f);
		s_constraint (x, constr (f));
		SKIP_MARK (("subtype indication"));
		return x;

	   case XINDIRECT:
		tree_symb = tree_lex (f);
		y = g_indir (x);
		delete_rec (&x);
		SKIP_MARK (("indirect"));
		return y;

	   default:
	       return expr (f);
	}
}

static
ac	constr (f)
FILE	*f;
{
	ac	x;

	x = tree_val;
	switch (tree_symb) {
	   case XRANGE:
		tree_symb = tree_lex (f);
		s_frang_exp (x, list_of (expr, f));
		goto skip_mark;

	   case XINDEXCONS:
		tree_symb = tree_lex (f);
		s_frange (x, list_of (constr, f));
		goto skip_mark;

	   case XDISCRCONS:
		tree_symb = tree_lex (f);
		s_aggregate (x, list_of (expr, f));
		goto skip_mark;

	   default:
		return expr (f);
	}

skip_mark:
	SKIP_MARK (("constr on %d (%d)", g_d (x), tree_symb));
	return x;
}

static
ac	expr (f)
FILE *f;
{
	ac	x;

	x = tree_val;
	switch (tree_symb) {
	   case XEXP:
		tree_symb = tree_lex (f);
		s_primary (x, expr (f));
		goto skip_mark;

	   case XENTRYCALL:
		tree_symb = tree_lex (f);
		s_fact (x, list_of (expr, f));
		SKIP_MARK (("entry call"));
		s_next (x, expr (f));
		s_call_delay (x, statement (f));
		s_call_next (x, list_of (statement, f));
		SKIP_MARK (("entrycall:2"));
		s_call_stats (x, list_of (statement, f));
		goto skip_mark;

	   case XCOMPASSOC:
		tree_symb = tree_lex (f);
	        s_fcompchoice (x, list_of (constr, f));
		SKIP_MARK (("bla bla"));
		s_compexpr    (x, expr (f));
		goto skip_mark;

	   case XINDIRECT:
		x = g_indir (x);
		delete_rec (&tree_val);
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XSELECT:
	   case XALL:
		tree_symb = tree_lex (f);
		s_next (x, expr (f));
		goto skip_mark;

	   case XLITERAL:
	   case XDISCR:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XNAME:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XINDEXING:
		tree_symb = tree_lex (f);
		s_farg (x, list_of (expr, f));
		SKIP_MARK (("indexing (tree reader)"));
		s_next (x, expr (f));
		goto skip_mark;

	   case XSLICE:
		tree_symb = tree_lex (f);
		s_slrange (x, constr (f));
		SKIP_MARK (("slicing (tree reader)"));
		s_next (x, expr (f));
		goto skip_mark;

	   case XATTRIBUTE:
		tree_symb = tree_lex (f);
		s_entity (x, expr (f));
		SKIP_MARK (("attribute (reader)"));
		s_next (x, expr (f));
		goto skip_mark;

	   case XCALL:
		tree_symb = tree_lex (f);
		s_fact (x, list_of (expr, f));
		SKIP_MARK (("call reader"));
		s_next (x, expr (f));
		goto skip_mark;

	   case XNAMEDASS:
		tree_symb = tree_lex (f);
		s_nexp (x, expr (f));
		goto skip_mark;

	   case XAGGREGATE:
		tree_symb = tree_lex (f);
		s_aggtype (x, subtype_ind (f));
		s_fcompas (x, list_of (expr, f));
		goto skip_mark;

	   case XALLOCATOR:
		tree_symb = tree_lex (f);
		s_obtype (x, subtype_ind (f));
		goto skip_mark;

	   case XTYPECONV:
		tree_symb = tree_lex (f);
		s_convexpr (x, expr (f));
		goto skip_mark;

	   case XPARENTHS:
		tree_symb = tree_lex (f);
		s_subexpr (x, expr (f));
		goto skip_mark;

	   case XIN:
		tree_symb = tree_lex (f);
		s_intype (x, subtype_ind (f));
		s_inexpr (x, expr (f));
		goto skip_mark;

	   case XSCC:
		tree_symb = tree_lex (f);
		s_fsccexpr (x, list_of (expr, f));
		goto skip_mark;

	   case XTHUNK:
		tree_symb = tree_lex (f);
		s_thexpr (x, expr (f));
		goto skip_mark;

	   case XTRIPLE:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   default:
		return NULL;
	}

skip_mark:
	SKIP_MARK (("expr %d", tree_symb));
	return x;
}

static
ac	opt_except (f)
FILE *f;
{
	ac	x;

	if (tree_symb == XEXHANDLER) {
	   x = tree_val;
	   tree_symb = tree_lex (f);
	   s_EXH_items (x, list_of (exc_handler, f));
	   SKIP_MARK (("opt_except"));
	   return x;
	}
	return NULL;
}

static
ac	exc_handler (f)
FILE *f;
{
	ac	x;

	if (tree_symb != XWHENITEM)
	   return NULL;

	x = tree_val;
	tree_symb = tree_lex (f);
	s_fwhenchoice (x, list_of (constr, f));
	s_WI_stats (x, list_of (statement, f));
	SKIP_MARK (("exc_handler"));
	return x;
}

static
ac	statement (f)
FILE *f;
{
	ac	x;

	x = tree_val;
	switch (tree_symb) {
	   case XASSIGN:
		tree_symb = tree_lex (f);
		s_lhs (x, expr (f));
		s_rhs (x, expr (f));
		goto skip_mark;

	   case XEXIT:
		tree_symb = tree_lex (f);
		s_exitcond (x, expr (f));
		goto skip_mark;

	   case XRETURN:
		tree_symb = tree_lex (f);
		s_retexpr (x, expr (f));
		goto skip_mark;

	   case XSUBCALL:
		tree_symb = tree_lex (f);
		s_subpr (x, expr (f));
		goto skip_mark;

	   case XDELAY:
		tree_symb = tree_lex (f);
		s_delay_expr (x, expr (f));
		goto skip_mark;

	   case XABORTSTAT:
		tree_symb = tree_lex (f);
		s_abortedtask (x, expr (f));
		goto skip_mark;

	   case XRAISE:
		tree_symb = tree_lex (f);
		s_exc_task (x, expr (f));
		goto skip_mark;

	   case XCASE:
		tree_symb = tree_lex (f);
		s_caseexpr (x, expr (f));
		s_CASE_items (x, list_of (whenitem, f));
		goto skip_mark;

	   case XTERMINATE:
		tree_symb = tree_lex (f);
		goto skip_mark;

	   case XTASKSELECT:
		tree_symb = tree_lex (f);
		s_SELECT_items (x, list_of (whenitem, f));
		goto skip_mark;

	   case XIF:
		tree_symb = tree_lex (f);
		s_IF_items (x, list_of (ifitem, f));
		goto skip_mark;

	   case XFORBLOCK:
		tree_symb = tree_lex (f);
		s_looppar (x, list_of (get_local, f));
		s_FB_stats (x, list_of (statement, f));
		goto skip_mark;

	   case XFORUSE:
		tree_symb = tree_lex (f);
		s_useexpr (x, expr (f));
		goto skip_mark;

	   case XLOOPBLOCK:
		tree_symb = tree_lex (f);
		s_cond (x, expr (f));
		s_LPB_stats (x, list_of (statement, f));
		goto skip_mark;

	   case XBLOCK:
		tree_symb = tree_lex (f);
		s_fblockloc (x, list_of (get_local, f));
		s_BLK_stats (x, list_of (statement, f));
		s_BLK_exh   (x, opt_except (f));
		goto skip_mark;

	   case XACCEPT:
		tree_symb = tree_lex (f);
		s_accept_stats (x, list_of (statement, f));
		SKIP_MARK (("accept"));
		goto skip_mark;

	   default:
		return NULL;
	}

skip_mark:
	SKIP_MARK (("statement %d", g_d (x)));
	return x;
}

static
ac	ifitem (f)
FILE *f;
{
	ac	x;

	x = tree_val;
	if (tree_symb != XIFITEM)
	   return NULL;

	tree_symb = tree_lex (f);
	s_ifcond (x, expr (f));
	s_IF_stats (x, list_of (statement, f));
	SKIP_MARK (("ifitem"));
	return x;
}

static
ac	whenitem (f)
FILE *f;
{
	ac	x;

	x = tree_val;
	if (tree_symb != XWHENITEM)
	   return NULL;

	tree_symb = tree_lex (f);
	s_fwhenchoice (x, list_of (constr, f));
	s_WI_stats (x, list_of (statement, f));
	SKIP_MARK (("whenitem %d", tree_symb));

	return x;
}

static
ac	index (f)
FILE *f;
{
	ac	x;

	x = tree_val;
	if (tree_symb != XINDEX)
	   return NULL;

	tree_symb = tree_lex (f);
	SKIP_MARK (("index"));
	return x;
}

