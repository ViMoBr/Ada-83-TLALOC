	/* @(#)y7.c	1.7	86/09/11	*/
# include "dextern.h"

/*
 *	Y7.C  -- creating the continuation grammar.
 *
 *	Grammar() will sort the input grammar such that for each
 *	nonterminal the corresponding continuation rule occurs
 *	first in the array prdptr.  Before sorting, rule input rule
 *	i is pointed to by prdptr[i], after sorting it is pointed
 *	to by prdptr[omzet[i]].
 *
 * METHOD
 *	In "Methods for the Automatic Construction of Error Correcting
 *	Parsers", J. Roehrich, Acta Informatica, Vol 13, 1980.
 *	pp 115-139,  the proofs for this method are given.
 *
 *	Let T be the set of terminals, N the set of nonterminals,
 *	and V their union.
 *	The continuation grammar F can be constructed by any method
 *	assuring that for no X from N there are a,b from V*
 *	with X ->F+ aXb.
 *
 * IMPLEMENTATION
 *	To allow some control over the termination function to be
 *	used, we will try to use the first rule given for a nonterminal
 *	whereever possible.
 *
 *	A rule can be marked safe if the left hand side consists
 *	of only of nonterminals occuring as LHS in a safe rule
 *	and of terminals.
 *
 *	Try to mark safe first rules for all nonterminals.
 *	If none such are found, try to mark a single safe rule.
 *	repeat until marking of single safe rule fails.
 *	Every nonterminal should have safe rule associated now.
 *
 *
 * REPRESENTATION
 *	Yacc traditionally keeps data in the following format:
 *	Rule i is pointed to by prdptr[i].  This points in the
 *	array mem[], starting with the LHS, followed by terminals
 *	and nonterminals from the RHS.  The rule is terminated by
 *	an item -i.  Symbols are nonterminal if the corresponding
 *	number is more than NTBASE.  Rules are numbered 1..nprod-1.
 *	Rule 0 is an added rule producing the start symbol.
 *
 *	If used[x] is true, rule x has been selected for the
 *	continuation grammar: x is in union A0..Ai.
 *	If for some i in 0..unilimit-1 nont[i] = X, a rule for X is
 *	in the continuation grammar: X is in Li-1.
 *	If for i in unilimit..setlimit-1 nont[i] = X, a rule for X is
 *	in the set Ai under construction.
 *
 */

int	omzet [NPROD];

/*
 * local & forward
 */
int	safe [NNONTERM];		/* true iff nonterminal has safe rule */
int	used [NPROD];			/* true iff rule is marked safe */

char *	format_one_rule ();

/*
 * leading non-terminal of production rule,
 * the A in A -> a.
 */
lhs_of (rule_index)
int	rule_index;
{
	return prdptr[rule_index][0];
}

/*
 * true if symbol is not a terminal
 */
int
is_non_term (symbol)
int	symbol;
{
	return symbol > NTBASE;
}

/*
 * grammar -- create continuation grammar and sort production rules.
 */
int grdebug = 0;
grammar()
{
	int	i;
	int	count;

	do {
		count = make_first_rules ();
		if (count == 0) {
			count = make_any_rules ();
		}
	} while (count != 0);

	for (i = 1; i < nnonter; i++) {
		if (! safe[i]) {
			warning ("no error recovery possible for %s",
				symnam (i+NTBASE));
		}
	}

	orden ();
	if (grdebug) {
		print_rules ();
	}
}

int
make_first_rules ()
{
	int	i;
	int	rule;
	int	lhs;
	int	symbol;
	int	seen [NNONTERM];	/* true iff encountered this loop */
	int	bad;
	int	count = 0;

	aryfil (seen, nnonter+1, 0);
	PLOOP (1, rule) {
		lhs = lhs_of (rule);
		if (seen [lhs - NTBASE]) {
			continue;
		}
		seen[lhs - NTBASE] = 1;

		if (safe[lhs - NTBASE])
			continue;

		bad = 0;
		i = 1;
		while ((symbol = prdptr[rule][i++]) > 0) {
			if (is_non_term(symbol) && (! safe[symbol - NTBASE])) {
				bad ++;
				break;
			}
		}

		if (! bad) {
			safe[lhs - NTBASE] = 1;
			used[rule] = 1;
			count ++;
		}
	}
	return count;
}


/* select one safe rule, need not be first for this nonterminal */
int
make_any_rules ()
{
	int	i;
	int	rule;
	int	lhs;
	int	symbol;
	int	bad;

	PLOOP (1, rule) {
		lhs = lhs_of (rule);

		if (safe[lhs - NTBASE])
			continue;

		bad = 0;
		i = 1;
		while ((symbol = prdptr[rule][i++]) > 0) {
			if (is_non_term(symbol) && (! safe[symbol-NTBASE])) {
				bad ++;
			}
		}
		if (! bad) {
			safe[lhs-NTBASE] = 1;
			used[rule] = 1;
			warning ("selecting non default recovery rule %s",
				format_one_rule (rule));
			return 1;
		}
	}
	return 0;
}

/*
 * orden - prdptr kept rules in input order.  After sorting,
 * for each nonterminal A, the rule A -> x from the continuation
 * grammar occurs first in prdptr, followed by all other rules
 * A -> y in input order.
 * Also, after sorting, original rule i is kept in prdptr[omzet[i]].
 */
orden()
{
	int *defprod[NPROD];	/* pointers to sorted productions */
	int rule;
	int lhs;		/* of current rule */
	int p;			/* counter in PRDPTR[] */
	int q;			/* counter in DEFPROD[] */

	/* rule $accept -> start $end copied unchanged */
	q = 0;
	defprod[omzet[0] = q++] = prdptr[0];

	/* copy rules sorted to defprod, compute omzet[]  */
	PLOOP (1, rule) {
		if (used [rule]) {
			lhs = lhs_of (rule);

			defprod[omzet[rule] = q++] = prdptr[rule];

			PLOOP (1, p) {
				if (p != rule  &&  lhs_of (p) == lhs) {
					if (used [p]) {
						error ("Internal Veyacc error while sorting rules");
					}
					defprod[omzet[p] = q++] = prdptr[p];
				}
			}
		}
	}

	omzet[nprod] = nprod;
	PLOOP (1, rule) {
		prdptr[rule] = defprod[rule];
	}
}


print_rules ()
{
	int i;

	printf ("\nORDERED PRODUCTION RULES\n\n");
	PLOOP (0, i) {
		printf ("%s\n", format_one_rule (i));
	}
	printf ("\nEND OF RULES\n\n");
}

char *
format_one_rule (rule)
int rule;
{
	int i;
	static char buf [1024];
	register char *p = buf;
	register char *q;

	for (q = symnam (prdptr[rule][0]); *q; *p++ = *q++)
		;
	for (q = " : "; *q; *p++ = *q++)
		;
	for (i = 1; prdptr[rule][i] > 0; i++) {
		for (q = symnam (prdptr[rule][i]); *q; *p++ = *q++)
			;
		*p++ = ' ';
	}
	*p = '\0';

	return buf;
}
