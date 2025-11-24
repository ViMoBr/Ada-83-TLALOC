	/* @(#)y8.c	1.2	86/09/11	*/
# include "dextern.h"

/*
 *	Y8.C  -- choose termination function
 *
 *	get_termfu () - given state in WSETS, and default action,
 *	return a token that will cause the first item from the
 *	itemset to be selected.
 *
 * REPRESENTATION
 *  --	OUTPUT() generates state info and closure for kernel of state i.
 *  --	Items and lookahead for state i are kept in WSETS.
 *  --	TEMP1[] has action as a function of lookahead for state i.
 *	The format of temp1:  an action is a goto (positive state
 *	number) or a reduce, (negative rule number).  The action for
 *	lookahead token i is in temp1[i], the action for nonterminal j
 *	is in temp1 [ntokens + j - NTBASE].
 *  --	During wract() state i, LASTRED gets the default reduction.
 *	(a positive number).  Reduction 0 means shift error token
 *	or do default reduction.  This token is passed as argument.
 *  --	static int * PYIELD[] is an array of pointers to RHS of rules.
 *	PRES[i] points to the first pointer in pyield for nonterminal i.
 *	The first item added in the closure for nonterminal i will be
 *	pres[i][0]
 *
 * METHOD
 *	We consider four cases (where alpha is string, a is a terminal,
 *	and B a nonterminal)  The second case is not sufficiently handled
 *	In the work of M. Groeneveld.
 *
 *  --	First item is A -> alpha . a beta
 *	termination function is a.
 *  --	First item is A -> alpha . B beta
 *	Search for a terminal that causes B to be produced.
 *  --	First item is A -> alpha . the default reduction
 *	termination function is 0, to cause default action.
 *  --	First item is A -> alpha . not default reduction
 *	Search in temp1[] for terminal that causes this reduction.
 *
 *	In the case A -> alpha . B beta, a rule for B is added to
 *	the closure.  This is one of
 *
 *		B -> . a gamma			(choose a)
 *		B -> . C gamma			(search recursive for C)
 *		B -> . <null>			(reduction case)
 *
 *
 */
int tfdebug = 0;

int
get_termfu (lastred)
int	lastred;
{
	int	c;
	int	result = 0;

	c = *(wsets->pitem);
	if (c < 0) {
		/* reduction */
		result = red_case (-c, lastred);
		}

	else if (c < NTBASE) {
		/* shift */
		result = c;
		}

	else {
		/* goto on nonterminal */
		result = goto_case (c - NTBASE, lastred);
		}

	if (tfdebug && foutput) {
		fprintf (foutput, "MYTERM\t%s for %s\n",
			symnam (result), writem (wsets->pitem));
		}
	return result;
	}

/*
 * return token that will force reduction according
 * to rule number r.
 */
int
red_case (r, lastred)
int	r;
int	lastred;
{
	int	token;
	int	result = -1;

	if (r == lastred) {
		/* default reduction */
		result = 0;
		}
	else {
		/* lookahead reduction */
		TLOOP (token) {
 			/*ACEEVK870825-spr108-lookahead reduction failed(ada)*/
 			if (temp1[token] == -r) {
  				result = token;
  				break;
  				}
  			}
 		}
 	if (result == -1) {
 		error ("internal error - red_case");
  		}
  	return result;
  	}
/*
 * return token that will force given nonterminal to be constructed
 */
int
goto_case (nont, lastred)
int	nont;
int	lastred;
{
	int *	item;
	int	first;
	int	result;

	item = pres [nont][0];
	first = item [0];

	if (first < 0) {
		result = red_case (-first, lastred);
		}
	else if (first > NTBASE) {
		result = goto_case (first - NTBASE, lastred);
		}
	else {
		/* first item for this LHS starts with terminal */
		result = first;
		}
	return result;
	}
