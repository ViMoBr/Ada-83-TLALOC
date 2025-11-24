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
 * Information about the software in general, and also about licensing
 * can be obtained from:
 *	Jan van Katwijk
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"includes.h"
/*
 *	Forward (static) declarations
 */
static	unsigned char	hf	();
static	void	h_i		();
static	void	p_table		();
static	void	dum_lev		();
static	void	slp_lev		();
static	void	revive		();
static	void	let_sleep	();
static	void	del_defs	();
static	void	p_down		();
static	void	p_up		();
static	void	x_def		();
static	void	axx_defs	();
static	ac	chain_of	();
static	ac	next_chain	();
static	ac	def_func	();
static	void	loc_s		();
static	void	init_autom	();
static	void	autom		();
static	void	a_join		();
static	ac	sc_eqe		();
static	ac	sc_eq		();
/*
 *	I M P L E M E N T I N G  V I S I B I L I T Y
 *
 *	A description of the ideas and algorithms behind the
 *	implementation can be found in:
 *
 *	pages 91 ..  of Ada- compiler book
 *	J van Katwijk
 *	Department of Mathematics and Computer Science
 *	PhD thesis, 1987
 */

#define	ASS1(x, y)	if (!(x)) { printf y; p_table("Crash: "); abort ();}
#define	set_curr(x)	{ __scopes. sc_cur = x; }
#define	get_curr()	(__scopes. sc_cur)

#define	MAXNEST		50
#define	MAXSYMBOLS	1000
/*
 *	Hashing, keep it simple
 */
#define	HS	256

static	short ht [HS];

static
unsigned char	hf (s)
char	*s;
{
	short	c;

	if (s == NULL)
	   return 1;

	if (s [1] == 0)
	   return s [0] & (HS - 1);

	if (s [2] == 0)
	   return (s [1] & 017) + (s [0] & 0150);

	return ((s [0] & 0140) + (s [1] & 0150) + (s [0] & 017)) & 0127;
}

static
void	h_i ()
{
	int	i;

	for (i = 0; i <= HS - 1; i ++)
	    ht [i] = -1;
}

/*
 *	Symbol table elements
 */

#define	IN_OPENSCOPES	01
#define	IMPORTED	02
#define	DUMMY		010
#define	UNLINKED	020


struct	symb_element {
		ac	def_list;
		short	next_symelem;
		char	hide_count;
		char	vis_flags;
		char	env_unit;
		unsigned char hv;
} symbol [MAXSYMBOLS];


struct scope {
	ac	sc_pnt;
	short	sc_index;
	short	sc_flags;
	short	sc_loctop;
};

/*
 *	One of the complications we meet here is that
 *	the top of the scope stack does not necessarily
 *	indicates the current open scope.
 */
struct scope_stack {
	struct scope scope [MAXNEST];
	short	xx_top;		/* symbol table top	*/
	short	sc_top;
	short	sc_cur;		/* current environment		*/
	ac	sc_env;
};

static struct scope_stack __scopes;


/*
 *	Initialize the structures
 */
void	i_open_scopes ()
{
	__scopes. sc_top = 0;
	__scopes. sc_cur = 0;
	__scopes. xx_top   = 0;
	h_i ();
	set_curr (new_lev (NULL, IN_OPENSCOPES));
}

/*
 *	printing the name tables, just in case an assertion fails
 */
static
void	p_table (s)
char	*s;
{
	int	i,
		j;

	j = get_scope (std);
	if (j == -1)
	   j = 0;		/* the lowest one		*/
	else
	   j = __scopes. scope [j]. sc_loctop - 1;

	printf ("P_TABLE, reason %s \n\n\n", s);
	printf ("xx_top = %d,\t sc_top = %d,\t sc_cur = %d\n",
	               __scopes. xx_top, __scopes. sc_top, __scopes. sc_cur);
	for (i = __scopes. sc_top - 1; i >= 1; i --)
	    printf ("Scope %s,\tsc_index = %d,\tsc_flags = %d,\tsc_loctop = %d\n",
		        g_tag (__scopes. scope [i]. sc_pnt),
		        __scopes. scope [i]. sc_index,
		        __scopes. scope [i]. sc_flags,
			__scopes. scope [i]. sc_loctop);

	for (i = __scopes. xx_top - 1; i >= j; i --) {
	    printf ("Namelist %d,\ttag = %s,\thv = %d,\thide_count = %d,\tflags = %d\n",
		        i,
		        g_tag (symbol [i]. def_list),
		        symbol [i]. hv,
		        symbol [i]. hide_count,
		        symbol [i]. vis_flags);
	}
}

/*
 */
static
void	dum_lev (x, f)
ac	x;
int	f;
{
	int	i;

	PRINTF ((printf ("dum_lev: %s\n", g_tag (x)) ));
	i = get_scope (x);

	ASS1 (i != -1, ("cannot dumlev %s\n", g_tag (x)) );
	ASS1 (__scopes. sc_top <= MAXNEST, ("TABLE OVERFLOW"));

	PRINTF ((printf ("top = %d\n", __scopes. sc_top) ));
	__scopes. scope [__scopes. sc_top] = __scopes. scope [i];
	__scopes. scope [__scopes. sc_top]. sc_flags = DUMMY;
	__scopes. sc_top ++;
}

/*
 *	create a new level
 */
int	new_lev (x, f)
ac	x;
int	f;
{
	struct scope *y;

	if (x != NULL)
	   PRINTF ((printf ("new_lev: %s\n", g_tag (x))));

	ASS1 (__scopes. sc_top < MAXNEST, ("block table overflow"));

	PRINTF ((printf ("top = %d\n", __scopes. sc_top) ));
	y = & __scopes. scope [__scopes. sc_top];

	y -> sc_pnt = x;
	y -> sc_index = __scopes. xx_top;
	y -> sc_loctop = __scopes. xx_top;
	y -> sc_flags = f;
	__scopes. sc_top ++;

	return __scopes. sc_top - 1;
}

/*
 *
 */
void	del_lev (x)
ac	x;
{
	int	i,
		j,
		tmp;

	if (x == NULL)
	   return;

	i = get_scope (x);

	ASSERT (i != -1, ("inconsistent scope table"));

	PRINTF ((printf ("del_lev: %s\n", g_tag (x)) ));

	ASS1 (__scopes. sc_top > 0, ("underflow in scope table"));

/*
 *	Notice that the scope we are looking for is not necessarily the
 *	topmost one. If we find a scope above the one we are
 *	looking for, we apply the del_defs definitions
 */
	for (j = __scopes. sc_top - 1; j >= 0; j --) {
	   del_defs (__scopes. scope [i]. sc_pnt, UNLINKED);

	   if (j == i) {	/* that's the one we were looking for	*/
	      __scopes. xx_top = __scopes. scope [i]. sc_index;
	      __scopes. sc_top = i;
	      return;
	   }
	}

	ASSERT (FALSE, ("del_lev is fout"));
}

/*
 *
 */
static
void	slp_lev (x)
ac	x;
{
	int	i,
		j;

	if (x == NULL)
	   return;

	PRINTF ((printf ("slp_lev: %s\n", g_tag (x)) ));
	ASS1 (__scopes. sc_top > 0, ("table underflow in scope stack"));

	j = get_scope (x);
	ASSERT (j != -1, ("inconsistent scope table"));

	for (i = __scopes. sc_top - 1; i >= 0; i--) {
	   let_sleep (__scopes. scope [i]. sc_pnt, UNLINKED);

	   if (i == j)	/* that's the one		*/
	      return;
	}
}

/*
 *	Wake up the elements on the namelist that belong to x
 */
static
void	revive (x, f)
ac	x;
int	f;
{
	int	t,
		a,
		b,
		i;

	if (x == NULL)
	   return;

	PRINTF ((printf ("reviving %s\n", g_tag (x)) ));

	t = get_scope (x);
	ASSERT (t != -1, ("cannot find scope %s\n", g_tag (x)));

	if (__scopes. scope [t]. sc_flags == f)
	   return;	/* was already done		*/

	__scopes. scope [t]. sc_flags = f;

	for (i = __scopes. scope [t]. sc_index;
	     i <= __scopes. scope [t]. sc_loctop - 1; i ++) {
	   if (symbol [i]. env_unit != t)
	      continue;

	   symbol [i]. next_symelem = ht [symbol [i]. hv];
	   ht [symbol [i]. hv] = i;
	   symbol [i]. vis_flags = f;
	   p_down (i);
	}
}

/*
 *	the elements of x are unlinked and made asleep
 */
static
void	let_sleep (x, f)
ac	x;
int	f;
{
	int	i,
		t,
		h;

	if (x == NULL)
	   return;

	PRINTF ((printf ("let_sleep: %s\n", g_tag (x)) ));

	t = get_scope (x);
	ASS1 (t != -1, ("Cannot find scope %s\n", g_tag (x)));

	if (__scopes. scope [t]. sc_flags == f)
	   return;	/* already done			*/

	__scopes. scope [t]. sc_flags = f;
	for (i = __scopes. scope [t]. sc_index;
	     i <= __scopes. scope [t]. sc_loctop - 1; i ++) {
	   if (symbol [i]. env_unit != t)
	      continue;

	   if (symbol [i]. vis_flags & UNLINKED)
	      continue;

	   h = symbol [i]. hv;		/* operational hash value	*/

	   while (ht [h] != i) {
	      p_up (ht [h]);
	      symbol [ht [h]]. vis_flags = UNLINKED;
	      symbol [ht [h]]. hide_count = 0;
	      ht [h] = symbol [ht [h]]. next_symelem;
	   }

	   p_up (i);
	   symbol [i]. vis_flags = UNLINKED;
	   symbol [i]. hide_count = 0;
	   ht [symbol [i]. hv] = symbol [i]. next_symelem;
	}
}


/*
 *	delete the definitions from x from the symbol table
 */
static
void	del_defs (x, f)
ac	x;
int	f;
{
	PRINTF ((printf ("del_defs: %s\n", g_tag (x)) ));
	let_sleep (x, f);
}

/*
 *	check to see whether or not x is being used somewhere
 */
bool	being_used (x)
ac	x;
{
	int	i;

	if (x == NULL)
	   return FALSE;

	for (i = __scopes. sc_top - 1; i > 0; i --)
	   if ((__scopes. scope [i]. sc_pnt == x) &&
	       (__scopes. scope [i]. sc_flags & IMPORTED) )
	    return TRUE;
	return FALSE;
}

/*
 *	get a scope description for x
 */
int	get_scope (x)
ac	x;
{
	int	i;

	for (i = __scopes. sc_top - 1; i >= 0; i --)
	   if (__scopes. scope [i]. sc_flags == DUMMY)
	      continue;
	   else
	   if (__scopes. scope [i]. sc_pnt == x)
	      return i;

	return -1;
}

/*
 *	open a new scope. Implement the visibility
 *	of packages here
 *	Distinguish between several possibilities:
 *	- no corresponding specification: a problem
 *	- a generic specification
 *	  - if the elements of the package are on the list somewhere
 *	    use these, otherwise
 *	  - read the elements in the list
 *	- a notmal specification
 *	  - if somehwere, use them
 *	  - read them in 
 *	The last case appears e.g. when we are compiling a
 *	compilation unit consisting of a package body
 *	(same remarks apply to e.g. task body)
 *	The tree oof the specification is read, it has
 *	to be put on the namelist somewhere
 *
 */
void	new_scope (x)
ac	x;
{
	int	sav;
	ac	y;

	switch (g_d (x)) {
	   case XPACKBODY:
		if (g_specif (x) == NULL)
		   warning ("Body without proper specification");
		else
		if (is_generic (g_specif (x))) {
		   if (get_scope (g_specif (x)) == -1) {
		      set_curr (new_lev (g_enclunit (g_specif (x)),
		                                       IN_OPENSCOPES));
		      ad_defs (g_genpars (g_enclunit (g_specif (x))),
							get_curr ());
		      set_curr (new_lev (g_specif (x), IN_OPENSCOPES));
		      ad_defs (g_fvisitem (g_specif (x)), get_curr ());
		      set_curr (new_lev (g_priv (g_specif (x)), IN_OPENSCOPES));
		      ad_defs (g_fprivitem (g_priv (g_specif (x))), get_curr ());
		   }
		   else
		   { revive (g_enclunit (g_specif (x)), IN_OPENSCOPES);
		     revive (g_specif   (x), IN_OPENSCOPES);
		     revive (g_priv (g_specif (x)), IN_OPENSCOPES);
		   }
		   set_curr (new_lev (x, IN_OPENSCOPES));
		   break;
		}

	        if (being_used (g_specif (x))) {
		   set_curr (new_lev (g_specif (x), IN_OPENSCOPES));
                   for (y = get_locallist (g_specif (x));
                       y != NULL && g_d (y) != XPRIVPART;
		       y = next_def (y) )
		     if (has_tag (y))
		        add_def (y);

		   revive (g_priv (g_specif (x)), IN_OPENSCOPES);
	        }
	        else
		if (get_scope (g_specif (x)) == -1) {
		   set_curr (new_lev (g_specif (x), IN_OPENSCOPES));
		   ad_defs (get_locallist (g_specif (x)), get_curr ());
		   set_curr (new_lev (g_priv (g_specif (x)), IN_OPENSCOPES));
		   ad_defs (get_locallist (g_priv (g_specif (x))),
					                get_curr ());
		}
		else
		{  revive (g_specif (x), IN_OPENSCOPES);
		   revive (g_priv (g_specif (x)), IN_OPENSCOPES);
		}
		set_curr (new_lev (x, IN_OPENSCOPES));

/*
 *	Temporary patch, purpose: to have packages
 *	that are used within the package also visible in the
 *	coresponding body:
 */
		for (y = get_locallist (g_specif (x));
		     y != NULL;
		     y = g_next (y))
		   if (g_d (y) == XUSE)
		      new_use (g_packname (y));

		break;

	case XSUBBODY:
	case XACCEPT:
		ad_defs (g_fformal (g_specif (x)),
			      new_lev (g_specif (x), IN_OPENSCOPES));
	        set_curr (new_lev (x, IN_OPENSCOPES));
		break;

	case XTASKBODY:
	        if (get_scope (g_specif (x)) ==  -1) {
		   set_curr (new_lev (g_specif (x), IN_OPENSCOPES));
		   ad_defs (get_locallist (g_specif (x)), get_curr ());
		}
		else
		   revive (g_specif (x), IN_OPENSCOPES);

		set_curr (new_lev (x, IN_OPENSCOPES));
		break;

	default:
		set_curr (new_lev (x, IN_OPENSCOPES));
		break;
	}
}

/*
 *	exit from a scope defining construction
 */
void	del_scope (x)
ac	x;
{
	switch (g_d (x)) {
	case XPACKBODY:
		del_lev (x);
		set_curr (get_scope (g_enclunit (x)));
		let_sleep (g_priv (g_specif (x)), UNLINKED);
		if (being_used (g_specif (x)))
		   del_lev (g_specif (x));
		else
		{ let_sleep (g_specif (x), UNLINKED);
		  if (is_generic (g_specif (x)))
		     let_sleep (g_enclunit (g_specif (x)));
		}
/*
		p_table ("after putting babies asleep");
 */
		break;

	case XSUBBODY:
	case XACCEPT:
/*
		p_table ("at exit of task/sub-body");
 */
		del_lev (x);
		set_curr (get_scope (g_enclunit (x)));
/*
		p_table ("after exit sub-taskbody, before specs");
 */
		del_lev (g_specif (x));
/*
		p_table ("after exit specs");
 */
		break;

	case XTASKBODY:
		del_lev (x);
		set_curr (get_scope (g_enclunit (x)));
		let_sleep (g_specif (x), UNLINKED);
		break;

	case XPRIVPART:
		slp_lev (x);
		set_curr (get_scope (g_enclunit (x)));
		break;		/* do not throw them away	*/

	case XPACKAGE:
	case XTASKTYPE:
		slp_lev (x);
		set_curr (get_scope (g_enclunit (x)));
		break;

	case XGENNODE:
		let_sleep (x, UNLINKED);
		set_curr (get_scope (g_enclunit (x)));
		break;

	default:
		del_lev (x);
		set_curr (get_scope (g_enclunit (x)));
		break;
	}
}

/*
 *	The i-th element of the symbol table is
 *	just entered. Check
 *	what declarations have to
 *	be made invisible
 *
 */
static
void	p_down (i)
int	i;
{
	int	h;
	ac	x = symbol [i]. def_list;

	if (symbol [i]. vis_flags & IN_OPENSCOPES) {
	   for (i = symbol [i]. next_symelem; i != -1;
	        i = symbol [i]. next_symelem )
	       if (eq_tags (g_tag (x), g_tag (symbol [i]. def_list)) &&
		   does_hide (x, symbol [i]. def_list) )
	           symbol [i]. hide_count ++;
	   }
	else	/* f & IMPORTED = TRUE			*/
	{
	  for (h = symbol [i]. next_symelem; h != -1;
	       h = symbol [h]. next_symelem )
	  {  if (!eq_tags (g_tag (x), g_tag (symbol [h]. def_list)))
	        continue;

	     if ((symbol [h]. vis_flags & IN_OPENSCOPES) &&
	         does_hide (x, symbol [h]. def_list) )

	        { /* symbol [i] can never be visible		*/
		  /* unlink the symbol from the chain		*/
		  symbol [i]. vis_flags = UNLINKED;
		  ht [symbol [i]. hv] = symbol [i]. next_symelem;
	          return;
		}
	     else
	     { if ((symbol [h]. vis_flags & IMPORTED) &&
	           donotlike (x, symbol [h]. def_list) )
		  { /* strange trick: increment the hide count	*/
		    /* of the h component, take value over	*/
		    symbol [h]. hide_count ++;
		    symbol [i]. hide_count = symbol [h]. hide_count;
		  }

	     }
	  }
	}

}

/*
 *	make declarations visible again
 *	unpop a declaration
 */
static
void	p_up (i)
int	i;
{
	ac	x;

	x = symbol [i]. def_list;
	i = symbol [i]. next_symelem;

	if (symbol [i]. vis_flags & IN_OPENSCOPES)
	   while (i != -1) {
	     if (eq_tags (g_tag (x), g_tag (symbol [i]. def_list)) &&
	        does_hide (x, symbol [i]. def_list) )
	           symbol [i]. hide_count --;
	     i = symbol [i]. next_symelem;
	   }
	else	/* it's imported		*/
	while (i != -1) {
	   if ((symbol [i]. vis_flags & IMPORTED) &&
	       donotlike (x, symbol [i]. def_list) ) {
	      symbol [i]. hide_count --;
	      return;
	   }
	   i = symbol [i]. next_symelem;
	}
}

/*
 *	add a definition to the current scope
 */
void	add_def (d)
ac	d;
{
	x_def (d, IN_OPENSCOPES, get_curr ());
}

void	ad_defs (x, y)
ac	x;
int	y;
{
	axx_defs (x, IN_OPENSCOPES, y);
}


static
void	x_def (d, f, l)
ac	d;
int	f,
	l;
{
	int	i,
		h;
	unsigned char hv;
	struct symb_element *x;

	ASS1 (has_tag (d), ("no tag for %d node", g_d (d)));

	if (!need_entering (d))
	   return;

	hv = hf (g_tag (d));

	x = & symbol [__scopes. xx_top];

	x -> hide_count = 0;
	x -> def_list   = d;
	x -> hv         = hv;
	x -> vis_flags  = f;
	x -> next_symelem = ht [hv];
	x -> env_unit   = l;
	ht [hv] = __scopes. xx_top;
	p_down (ht [hv]);
	__scopes. scope [l]. sc_loctop = ++ __scopes. xx_top;
}

static
void	axx_defs (x, f, y)
ac	x;
int	f,
	y;
{
	while (x != NULL) {
	   if (has_tag (x))
		x_def (x, f, y);

	   x = next_def (x);
	}
}

/*
 *	implementing the lookup
 */
static
ac	chain_of (node, t)
ac	node;
char	*t;
{
	ac	a;

	a = get_locallist (node);
	while (a != NULL) {
	   if (has_tag (a) && eq_tags (g_tag (a), t))
	      return a;
	   a = next_def (a);
	}

	return NULL;
}

static
ac	next_chain (node, t)
ac	node;
ac	t;
{
	ac	a;

	if (node == NULL)
	   return NULL;

	while ((node = next_def (node)) != NULL)
	   if (has_tag (node) && eq_tags (g_tag (node), t))
	      return node;

	return NULL;
}

static
ac	def_func (env, t, func, x)
ac	env;
char	*t;
int	(*func)();
ac	x;
{
	int	i,
		a,
		b;
	short	h;
	ac	y;

	PRINTF ((printf ("in def_func with %s in %s\n", t, g_tag (env)) ));
	i = get_scope (env);

	ASS1 (i != -1, ("cannot find scope %s\n", g_tag (env)));

	a = __scopes. scope [i]. sc_loctop - 1;
	b = __scopes. scope [i]. sc_index;

	h = ht [hf (t)];
	PRINTF ((printf ("top = %d, bodem = %d, index = %d = %d\n", a, b, h) ));

	while (h != -1) {
	  if (h < b)
	     return NULL;

	  if (i == symbol [h]. env_unit) {
	     PRINTF ((printf ("index for hash is %d\n", h) ));
	     if (a >= h)
	        if (eq_tags (t, g_tag (symbol [h]. def_list)))
	           if (x != symbol [h]. def_list &&
	                    (*func)(x, symbol [h]. def_list))
	              return symbol [h]. def_list;
	  }
	  h = symbol [h]. next_symelem;
	}

	return NULL;
}

/*
 *	iterate over the locals of the current environment
 *	apply the function func to the elements of the locallist
 *	
 */
ac	loc_iterate (t, func, x)
char	*t;
int	(*func)();
ac	x;
{
	ac	y;

	switch (g_d (env)) {
	   case XPACKBODY:
		y = def_func (env, t, func, x);
		if (y != NULL)
		   return y;

		y = def_func (g_specif (env), t, func, x);
		if (y != NULL)
		   return y;

		y = def_func (g_priv (g_specif (env)), t, func, x);
		return y;

	   case XSUBBODY:
	   case XTASKBODY:
		y = def_func (env, t, func, x);
		if (y != NULL)
		   return y;
		y = def_func (g_specif (env), t, func, x);
		return y;

	   case XPRIVPART:
		y = def_func (g_enclunit (env), t, func, x);
		if (y != NULL)
		   return y;

		y = def_func (env, t, func, x);
		return y;

	   case XVARIANT:
		y = def_func (encl_rectype (env), t, func, x);
		return y;

	   default:
		y = def_func (env, t, func, x);
		return y;
	}
}

/*
 *	Looking in a local context.
 *
 *	The following steps are taken:
 *	Since we never return a body, we have to
 *	look in the set, passed as unit, to an
 *	environment indicating the closest surrounding
 *	open scope with the environment as its specification
 *	If we do not find such an open scope, well than its
 *	easy, just walk through the locals
 *	apply the function func to the locals to see whether
 *	or not they have to be taken in the set
 */
static
void	loc_s (a_set, func, env, t)
ac	*a_set,
	env;
char	*t;
int	(*func)();
{
	int	i,
		j,
		a,
		b;
	unsigned char hv;
	ac	y;

	i = get_scope (env);
	if (i == -1) {	/* not yet entered, sorry	*/
	   y = chain_of (env, t);
	   while (y != NULL) {
	      if (!skip (y))
	         (*func) (a_set, y);
	      y = next_chain (y, t);
	   }

	return;
	}

	a = __scopes. scope [i]. sc_loctop - 1;
	b = __scopes. scope [i]. sc_index;
	hv = hf (t);
	for (j = a; j >= b; j --) {
	   if (hv == symbol [j]. hv && symbol [j]. env_unit == i)
	      if (eq_tags (t, g_tag (symbol [j]. def_list)))
	         if (!skip (symbol [j]. def_list))
	            (*func)(a_set, symbol [j]. def_list);
	}
}


/*
 *	A driving automaton
 *	compute on the fly the hiding of elements
 */
static int au_st;

static
void	init_autom ()
{
	au_st = 0;
}

static
void	autom (a_set, def)
ac	*a_set,
	def;
{
	if (def == NULL || g_d (def) == XCHARLIT)
	   return;

	switch (au_st) {
	   case 0:
		*a_set = join (def, *a_set);
		switch (g_d (def)) {
		   case XSUB:
		   case XENTRY:
		   case XRENSUB:
		   case XENUMLIT:
		   case XINHERIT:
			au_st = 1;
			return;

		   default:
			au_st = 2;
		}
		return;

	   case 2:
		return;

	   case 1:
		switch (g_d (def)) {
		   case XSUB:
		   case XENTRY:
		   case XRENSUB:
		   case XENUMLIT:
		   case XINHERIT:
			*a_set = join (def, *a_set);
			return;

		   default:
			au_st = 2;
			return;
		}

	}
}

static
void	a_join (a, b)
ac	a,
	*b;
{
	if (is_charlit (a))
	   *b = join (a, *b);
}

/*
 *	the user interface: loc_xxx
 */
ac	loc_char (unit, t)
ac	unit;
char	*t;
{
	ac	set = NULL;

	switch (g_d (unit)) {
	   case XPACKBODY:
		loc_s (&set, a_join, unit, t);
		loc_s (&set, a_join, g_specif (unit), t);
		loc_s (&set, a_join, g_priv (g_specif (unit)), t);
		return set;

	   default:
		loc_s (&set, a_join, unit, t);
		return set;
	}
}

/*
 *	... and the other one, loc_lookup
 */
ac	loc_lookup (unit, t)
ac	unit;
char	*t;
{
	ac	set = NULL;

	init_autom ();
	switch (g_d (unit)) {
	   case XPACKBODY:
		loc_s (&set, autom, unit, t);
		loc_s (&set, autom, g_specif (unit), t);
		loc_s (&set, autom, g_priv (g_specif (unit)), t);
		return set;

	   case XSUBBODY:
	   case XTASKBODY:
		loc_s (&set, autom, unit, t);
		loc_s (&set, autom, g_specif (unit), t);
		return set;

	   default:
		loc_s (&set, autom, unit, t);
		return set;
	}
}

/*
 *	use clause processing
 */
void	new_use (x)
ac	x;
{
	int	i;
	ac	y,
		z;
	short	sav,
		c;

	if (x == NULL)
	   return;

	if (being_used (x))
	   return;

	i = get_scope (x);

	if (i == -1)
	   { sav = get_curr ();
	     set_curr (new_lev (x, IMPORTED));
	     c = get_curr ();
	     axx_defs (get_locallist (x), IMPORTED, c);
	     set_curr (sav);
	     return;
	   }

	if (__scopes. scope [i]. sc_flags & IN_OPENSCOPES)
	   return;

	ASS1 (__scopes. scope [i]. sc_flags & UNLINKED,
		          ("import of woken up %s\n", g_tag (x)) );

	revive (x, IMPORTED);
	if (i < get_curr ())	/* to be able to reset	*/
	   dum_lev (x, DUMMY);
}

/*
 *	find the enclosing subprogram body
 */
ac	encl_sub ()
{
	int	i;
	ac	a;

	for (i = __scopes. sc_top - 1; i >= 0; i --) {
	   if (__scopes. scope [i]. sc_flags != IN_OPENSCOPES)
	      continue;
	   a = __scopes. scope [i]. sc_pnt;
	   if (g_d (a) == XSUBBODY || g_d (a) == XACCEPT)
	      return a;

	}

	return NULL;
}

/*
 *	find the enclosing loop construct
 */
ac	encl_loop ()
{
	int	i;
	ac	a;

	for (i = __scopes. sc_top - 1; i >= 0; i --) {
	   if (__scopes. scope [i]. sc_flags != IN_OPENSCOPES)
	      continue;

	   a = __scopes. scope [i]. sc_pnt;

	   if (g_d (a) == XLOOPBLOCK || g_d (a) == XFORBLOCK)
	      return a;


	   if (g_d (a) == XPACKBODY)
	      return NULL;

	   if (g_d (a) == XSUBBODY)
	      return NULL;

	   if (g_d (a) == XTASKBODY)
	      return NULL;
	}

	return NULL;
}

/*
 *	find the enclosing task body
 */
ac	encl_taskbody ()
{
	int	i;
	ac	a;

	for (i = __scopes. sc_top - 1; i >= 0; i --) {
	   if (__scopes. scope [i]. sc_flags != IN_OPENSCOPES)
	      continue;

	   a = __scopes. scope [i]. sc_pnt;
	   switch (g_d (a)) {
	      case XTASKBODY:
	         return a;

	      case XSUBBODY:
	      case XPACKBODY:
	      case XPACKAGE:
	      case XBLOCK:
		 return NULL;

	      default:
		 continue;
	   }
	}

	return NULL;
}

/*
 *	find, in a set of environments the closest "open_scope"
 *	do all transformations from PB -> PS etc.
 *	Such that the set makers do not have to bother
 */
static
ac	sc_eqe (x, y)
ac	x,
	y;
{
	if (x == y)
	   return x;

	if (y == NULL)
	   return NULL;

	ASSERT (x != NULL, ("sc_eqe:1"));

	switch (g_d (x)) {
	   case XPACKAGE:
	      if (g_d (y) == XPACKBODY && g_specif (y) == x)
	         return y;
	      else
	         return NULL;

	   case XSUB:
	      if (g_d (y) == XSUBBODY && x == g_specif (y))
	         return y;
	      else
	         return NULL;

	   case XTAGSTAT:
	      if (g_t_stat (x) == y)
	         return y;
	      else
	         return NULL;

	   case XTASKTYPE:
	      if (g_d (y) == XTASKBODY && x == g_specif (y))
	         return y;
	      else
	         return NULL;

	   case XPRIVTYPE:
	      return sc_eqe (g_impl (x), y);

	   case XINCOMPLETE:
	      return sc_eqe (g_complete (x), y);

	   default:
	      return NULL;
	}
}

static
ac	sc_eq (set, y)
ac	set,
	y;
{
	ac	a,
		x;

	x = first (set);
	while (x != NULL) {
	   a = sc_eqe (x, y);

	   if (a != NULL)
	      return a;

	   x = next_elem (set);
	}

	return NULL;
}

ac	open_scopes (set)
ac	set;
{
	int	i;
	ac	a;

	for (i = __scopes. sc_top - 1; i >= 0; i --) {
	    if (__scopes. scope [i]. sc_flags != IN_OPENSCOPES)
	       continue;

	    a = sc_eq (set, __scopes. scope [i]. sc_pnt);

	    if (a != NULL)
	       return a;
	}

	return NULL;
}


/*
 *	is t an open scope ?
 */
bool	is_openscope (t)
ac	t;
{
	int	i = get_scope (t);

	if (i == -1 ||
	    __scopes. scope [i]. sc_flags != IN_OPENSCOPES)
	   return FALSE;

	return TRUE;
}

/*
 *	Finally the lookup with some hashing scheme
 */
ac	look_id (t)
char	*t;
{
	int	i,
		state = 0;
	ac	def,
		a,
		set = NULL;

	PRINTF ((printf ("in look_id, searching for %s\n", t) ));
	for (i = ht [hf (t)]; i != -1; i = symbol [i]. next_symelem) {
	   PRINTF ((printf ("hash_value %d, index %d\n", hf (t), i) ));
	   def = symbol [i]. def_list;

	   if (symbol [i]. hide_count != 0)	/* is_hidden	*/
	      continue;

	   if (skip (def))
	       continue;

	   if (is_charlit (def))
	      continue;

	   if (!has_tag (def))
	      continue;

	   if (!eq_tags (g_tag (def), t))
	      continue;

	   set = join (def, set);
	}

	return set;
}

/*
 *	look for a character literal
 */
ac	look_char (t)
char	*t;
{
	ac	a,
		def,
		set = NULL;
	int	i;

	PRINTF ((printf ("in look_char with %s\n", t) ));
	for (i = ht [hf (t)]; i != -1; i = symbol [i]. next_symelem) {
	   def = symbol [i]. def_list;

	   if (!is_charlit (def))
	      continue;

	   PRINTF ((printf ("lookchar %s hv = %d i = %d\n",
			        g_tag (def), symbol [i]. hv, i) ));

	   if (eq_tags (t, g_tag (def)))
	      set = join (def, set);
	}

	return set;
}

void	new_start ()
{
	add_def (std);	/* make standard visible	*/
	new_scope (std);
	ad_defs (g_fvisitem (std), get_curr ());
	std_string = look_id ("STRING");
}

