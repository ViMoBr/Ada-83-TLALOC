h09211
s 00030/00013/00237
d D 1.7 86/09/11 12:08:03 konijn 7 6
c minor bug fixes
e
s 00097/00261/00153
d D 1.6 86/09/09 18:47:10 konijn 6 5
c new strategy for continuation grammar selection requires less swapping
e
s 00028/00000/00386
d D 1.5 86/09/04 18:20:13 konijn 5 4
c added debugging code
e
s 00113/00024/00273
d D 1.4 86/08/29 12:42:58 konijn 4 3
c add empty rule optimisation
e
s 00010/00001/00287
d D 1.3 86/08/28 12:01:20 konijn 3 2
c bugfixes
e
s 00002/00002/00286
d D 1.2 86/08/27 16:47:28 konijn 2 1
c oops!
e
s 00288/00000/00000
d D 1.1 86/08/27 16:12:51 konijn 1 0
c date and time created 86/08/27 16:12:51 by konijn
e
u
U
t
T
I 1
D 6
	/* %W%	%E% */
# include "prep.h"
E 6
I 6
	/* %W%	%E%	*/
E 6
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
D 6
 *	Create set A0 of rules that map a X from N to T* directly,
 *	with at most one rule per nonterminal, and L0 the set
 *	of nonterminals mapped in this way.
E 6
I 6
 *	To allow some control over the termination function to be
 *	used, we will try to use the first rule given for a nonterminal
 *	whereever possible.
E 6
 *
D 6
 *	Create set Ai of rules that map X from N to {T u Li-1}+
 *	directly, with X not in Li-1, at most one rule per nonterminal.
 *	Li is the union of Li-1 and the nonterminals mapped by Ai.
E 6
I 6
 *	A rule can be marked safe if the left hand side consists
 *	of only of nonterminals occuring as LHS in a safe rule
 *	and of terminals.
E 6
 *
D 6
 *	Keep adding sets to the union of A0..Ai until an Ai is empty.
 *	The union constructed in this way is the continuation
 *	grammar.
 *	Since we are only interrested in the union we do not actually
 *	construct the sets but only keep track of the number of items
 *	added in each iteration.
E 6
I 6
 *	Try to mark safe first rules for all nonterminals.
 *	If none such are found, try to mark a single safe rule.
 *	repeat until marking of single safe rule fails.
 *	Every nonterminal should have safe rule associated now.
E 6
 *
I 4
D 6
 * OPTIMISATION
 *	Rules of the form X -> eps are not desirable in the continuation
 *	grammar: they cause the termination function to ignore optional
 *	parts of the grammar, as in
E 6
 *
D 6
 *		module -> dcl [ BEGIN statseq ] end
 *
 *	Note that nonterminals that only generate eps do not have to
 *	be added to the set since they don't influence sorting anyway.
 *	Rules that generate only eps must only be added when their LHS
 *	is necessary in some other rule, as in
 *
 *		module -> start BEGIN block END
 *		start -> eps
 *
 *	The improved algorith is as follows:
 *
 *	Create sets as before, but do not include eps_rules.  When no
 *	more rules can be added, search for rules that could be added
 *	if only some nonterminals generating eps were added to the set.
 *	If such nonterminals exist add them and start over looking for
 *	rules, otherwise finished.
 *
E 6
E 4
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

D 6
int omzet[NPROD];
E 6
I 6
D 7
int omzet [NPROD];
E 7
I 7
int	omzet [NPROD];
E 7
E 6

D 6
/*
 *	PART I - INTERPRETATION OF PRODUCTION RULES
 */
E 6
I 6
D 7
int safe [NNONTERM];		/* true iff nonterminal has safe rule */
int used [NPROD];		/* true iff rule is marked safe */
E 7
I 7
/*
 * local & forward
 */
int	safe [NNONTERM];		/* true iff nonterminal has safe rule */
int	used [NPROD];			/* true iff rule is marked safe */
E 7
E 6

I 7
char *	format_one_rule ();

E 7
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
D 6
 * rule is of the form A -> eps.
 *
 * This holds until orden() has been called to put continuation-
 * grammar rules first.
E 6
I 6
 * grammar -- create continuation grammar and sort production rules.
E 6
 */
D 6
int
is_eps_rule (rule_index)
int	rule_index;
E 6
I 6
int grdebug = 0;
grammar()
E 6
{
D 6
	return (prdptr[rule_index][1] == -rule_index);
}
E 6
I 6
	int	i;
	int	count;
E 6

D 6
/*
 *	PART II - SET MANAGEMENT
 */
int nont[NNONTERM];
int unilimit = 0;		/* nont[0..unilimit -1] are in Li-1 */
int setlimit = 0;		/* nont[unilimit..setlimit-1] are in Li */
int used[NPROD];   		/* true if rule in union A0..Ai */

/*
 * add_rule -- add this rule to Ai
 */
add_rule (rule_index)
int	rule_index;
{
I 3
	if (setlimit == NNONTERM) {
		error ("Internal Yacc error - adding a rule to continuation");
	}
E 3
	nont[setlimit++] = lhs_of (rule_index);
	used[rule_index] = 1;
}

/*
 * add_set_to_union -- merge Ai and union A0..Ai-1, Li Li-1.
 * on exit, nonterminals from Li can be used in constructing Ai+1.
 */
add_set_to_union ()
{
	unilimit = setlimit;
}

/*
 * rule_in_union -- this rule is in continuation grammar
 */
int
rule_in_union (rule_index)
{
	return used[rule_index];
}

/*
 * nt_in_union -- this nonterminal is in Li-1, it can be used
 * in rules from Ai.
 */
int
nt_in_union (symbol)
int	symbol;
{
	int i;

	for (i = 0; i < unilimit; i++) {
		if (nont[i] == symbol) {
			return 1;
E 6
I 6
D 7
	safe[0] = 1;		/* The nonterminal $accept is allways ok */
E 7
	do {
		count = make_first_rules ();
		if (count == 0) {
			count = make_any_rules ();
E 6
		}
D 6
	}
	return 0;
}
E 6
I 6
	} while (count != 0);
E 6

D 6
/*
 * nt_in_set -- this nonterminal has been added to Li.  It
 * can not be used in rules from Ai, and it must not be added again.
 */
int
nt_in_set (symbol)
int	symbol;
{
	int i;

	for (i = unilimit; i < setlimit; i++) {
		if (nont[i] == symbol) {
			return 1;
E 6
I 6
	for (i = 1; i < nnonter; i++) {
		if (! safe[i]) {
D 7
			error ("internal error: no safe rule for %s\n",
E 7
I 7
			warning ("no error recovery possible for %s",
E 7
				symnam (i+NTBASE));
E 6
		}
	}
D 6
	return 0;
}
E 6

D 6
/*
D 4
 *	PART III - CONSTRUCTING THE CONTINUATION GRAMMAR
E 4
I 4
 *	PART III - EPSILON RULES
E 4
 */
I 4
int epstab [NNONTERM];
#define	NORULE -1
E 4

/*
D 4
 * make_first_set - construct A0, rules that generate only
 * terminals.
E 4
I 4
 * init_eps_rules - initialise table mapping nonterminals to
 * eps rules.
E 4
 */
D 4
make_first_set ()
E 4
I 4
init_eps_rules ()
E 4
{
D 4
	int	rule;
	int	bad;		/* true if rule must not be added */
	int	index;		/* index of symbol in rule */
E 4
I 4
	register int i;
E 4

D 4
	for (rule = 1; rule < nprod; rule++) {
		if (nt_in_set (lhs_of(rule))) {
			continue;
E 4
I 4
	for (i = 0; i < NNONTERM; i++) {
		epstab[i] = NORULE;
E 6
I 6
	orden ();
	if (grdebug) {
		print_rules ();
E 6
	}
D 6
	for (i = 0; i < nprod; i++) {
		if (is_eps_rule (i)) {
			epstab[lhs_of(i) - NTBASE] = i;
E 4
		}
I 3
D 4
		bad = 0;
E 3
		for (index = 1; prdptr[rule][index] != -rule; index++) {
			if (is_non_term (prdptr[rule][index])) {
				bad++;
				break;
			}
		}
		if (! bad) {
			add_rule (rule);
		}
E 4
	}
E 6
}

D 6
/*
I 4
 * eps_rule_of - given nonterminal X, return
 * a rule X -> eps
 */
E 6
int
D 6
eps_rule_of (symbol)
int	symbol;
E 6
I 6
make_first_rules ()
E 6
{
D 6
	return epstab[symbol - NTBASE];
}

/*
 *	PART IV - CONSTRUCTING THE CONTINUATION GRAMMAR
 */

/*
E 4
 * make_next_set -- given union A0..Ai-1, Li-1, create Ai, Li,
 * and add sets to continuation grammar.
 * returns number of items added.
 */
int
make_next_set ()
{
E 6
I 6
	int	i;
E 6
	int	rule;
D 6
	int	bad;		/* true if rule must not be added */
	int	index;		/* index of symbol in rule */
	int	count = 0;	/* number of items added */
E 6
I 6
	int	lhs;
	int	symbol;
	int	seen [NNONTERM];	/* true iff encountered this loop */
	int	bad;
	int	count = 0;
E 6

D 6
	for (rule = 1; rule < nprod; rule++) {
D 3
		if (nt_in_set (lhs_of(rule))
E 3
I 3
		if (nt_in_set (lhs_of (rule))
		   || nt_in_union (lhs_of (rule))
E 3
		   || is_eps_rule (rule)) {
E 6
I 6
D 7
	aryfil (seen, nnonter, 0);
E 7
I 7
	aryfil (seen, nnonter+1, 0);
E 7
	PLOOP (1, rule) {
		lhs = lhs_of (rule);
D 7
		if (seen [lhs - NTBASE])
E 7
I 7
		if (seen [lhs - NTBASE]) {
E 7
E 6
			continue;
I 7
		}
E 7
D 6
		}
E 6
I 6
		seen[lhs - NTBASE] = 1;

		if (safe[lhs - NTBASE])
			continue;

E 6
I 3
		bad = 0;
E 3
D 6
		for (index = 1; prdptr[rule][index] != -rule; index++) {
			if (is_non_term (prdptr[rule][index])
			   && (! nt_in_union (prdptr[rule][index]))) {
				bad++;
				break;
E 6
I 6
		i = 1;
		while ((symbol = prdptr[rule][i++]) > 0) {
			if (is_non_term(symbol) && (! safe[symbol - NTBASE])) {
				bad ++;
I 7
				break;
E 7
E 6
			}
		}
I 6

E 6
		if (! bad) {
D 6
			add_rule (rule);
			count++;
E 6
I 6
			safe[lhs - NTBASE] = 1;
			used[rule] = 1;
			count ++;
E 6
		}
	}
	return count;
}

D 6
/*
I 4
 * make_eps_rules  --  search rules that could be added if only
 * some eps rules were added to the grammar, and add these eps
 * rules.
 */
E 6
I 6

/* select one safe rule, need not be first for this nonterminal */
E 6
int
D 6
make_eps_rules ()
E 6
I 6
make_any_rules ()
E 6
{
D 6
	int rule;
	int count = 0;
E 6
I 6
	int	i;
	int	rule;
	int	lhs;
	int	symbol;
	int	bad;
E 6

D 6
	for (rule = 1; rule < nprod; rule++) {
		if (! nt_in_union (lhs_of (rule))) {
			count += do_one_rule (rule);
		}
	}
	return count;
}
E 6
I 6
	PLOOP (1, rule) {
		lhs = lhs_of (rule);
E 6

D 6
/*
 * do_one_rule  --  if this rule could be added to continuation
 * grammar if some eps rules were added, add corresponding eps
 * rule.
 */
int
do_one_rule (rule)
int rule;
{
	int i;
	int count = 0;
E 6
I 6
		if (safe[lhs - NTBASE])
			continue;
E 6

D 6
	for (i = 1; prdptr[rule][i] != -rule; i++) {
		if (is_non_term (prdptr[rule][i])
		   && (! nt_in_union (prdptr[rule][i]))) {
			if (eps_rule_of (prdptr[rule][i]) == NORULE) {
				return 0;
E 6
I 6
		bad = 0;
		i = 1;
		while ((symbol = prdptr[rule][i++]) > 0) {
			if (is_non_term(symbol) && (! safe[symbol-NTBASE])) {
				bad ++;
E 6
			}
		}
D 6
	}
	/* rule is OK, except for eps rules */

	for (i = 1; prdptr[rule][i] != -rule; i++) {
		if (is_non_term (prdptr[rule][i])
		   && (! nt_in_union (prdptr[rule][i]))
		   && (! nt_in_set (prdptr[rule][i]))) {
			add_rule (eps_rule_of (prdptr[rule][i]));
			count ++;
E 6
I 6
		if (! bad) {
			safe[lhs-NTBASE] = 1;
			used[rule] = 1;
			warning ("selecting non default recovery rule %s",
D 7
				writem (& prdptr[rule][1]));
E 7
I 7
				format_one_rule (rule));
E 7
			return 1;
E 6
		}
	}
D 6
	return count;
E 6
I 6
	return 0;
E 6
}

/*
E 4
D 6
 * grammar -- create continuation grammar and sort production rules.
 */
I 5
int grdebug = 0;
E 5
grammar()
{
D 4
	make_first_set ();
	add_set_to_union ();
E 4
I 4
	int count;
E 4

D 4
	while (make_next_set ()) {
E 4
I 4
	init_eps_rules ();

	do {
		count = make_next_set ();
		if (count == 0) {
			count = make_eps_rules ();
		}
E 4
		add_set_to_union ();
D 4
	}
E 4
I 4
	} while (count != 0);

E 4
	orden ();
I 5
	if (grdebug) {
		print_rules ();
	}
E 5
}


/*
E 6
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
D 6
	int tel2;   /* counter in PRDPTR[] */
	int tel3;   /* counter in DEFPROD[] */
E 6
I 6
	int p;			/* counter in PRDPTR[] */
	int q;			/* counter in DEFPROD[] */
E 6

D 6
	tel3 = 1;
	defprod[0] = prdptr[0];
	omzet[0] = 0;
E 6
I 6
	/* rule $accept -> start $end copied unchanged */
	q = 0;
	defprod[omzet[0] = q++] = prdptr[0];
E 6

D 6
	for (rule = 1; rule < nprod; rule++) {
		if (rule_in_union (rule)) {
E 6
I 6
	/* copy rules sorted to defprod, compute omzet[]  */
	PLOOP (1, rule) {
		if (used [rule]) {
E 6
			lhs = lhs_of (rule);

D 6
			defprod[tel3] = prdptr[rule];
			omzet[rule] = tel3;
			tel3++;
			for (tel2 = 1; tel2 < nprod; tel2++) {
				if (tel2 != rule  &&  lhs_of (tel2) == lhs) {
I 3
					if (rule_in_union (tel2)) {
						error ("Internal Yacc error while sorting rules");
E 6
I 6
			defprod[omzet[rule] = q++] = prdptr[rule];

			PLOOP (1, p) {
				if (p != rule  &&  lhs_of (p) == lhs) {
					if (used [p]) {
						error ("Internal Veyacc error while sorting rules");
E 6
					}
E 3
D 6
					defprod[tel3] = prdptr[tel2];
					omzet[tel2] = tel3;
					tel3++;
E 6
I 6
					defprod[omzet[p] = q++] = prdptr[p];
E 6
				}
			}
		}
	}

	omzet[nprod] = nprod;
D 2
	for (tel1 = 0; tel1 < nprod; tel1++) {
		prdptr[tel1] = defprod[tel1];
E 2
I 2
D 6
	for (rule = 0; rule < nprod; rule++) {
E 6
I 6
	PLOOP (1, rule) {
E 6
		prdptr[rule] = defprod[rule];
E 2
	}
I 5
}


print_rules ()
{
	int i;

	printf ("\nORDERED PRODUCTION RULES\n\n");
D 6
	for (i = 0;  i < nprod;  i++) {
E 6
I 6
	PLOOP (0, i) {
E 6
D 7
		print_one_rule (i);
E 7
I 7
		printf ("%s\n", format_one_rule (i));
E 7
	}
	printf ("\nEND OF RULES\n\n");
}

D 7
print_one_rule (rule)
E 7
I 7
char *
format_one_rule (rule)
E 7
int rule;
{
	int i;
I 7
	static char buf [1024];
	register char *p = buf;
	register char *q;
E 7

D 7
	printf ("%s :  ", symnam (prdptr[rule][0]));
E 7
I 7
	for (q = symnam (prdptr[rule][0]); *q; *p++ = *q++)
		;
	for (q = " : "; *q; *p++ = *q++)
		;
E 7
	for (i = 1; prdptr[rule][i] > 0; i++) {
D 7
		printf("%s ", symnam (prdptr [rule][i]));
E 7
I 7
		for (q = symnam (prdptr[rule][i]); *q; *p++ = *q++)
			;
		*p++ = ' ';
E 7
	}
D 7
	printf ("\n");
E 7
I 7
	*p = '\0';

	return buf;
E 7
E 5
}
E 1
