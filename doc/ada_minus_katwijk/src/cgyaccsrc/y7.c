#include "dextern"
#include "prep.h"

extern struct stack_elem *search_stck();

extern int nstate;

extern int t;

int trst[3*NPROD];
int nxttrst=1;

int rsi[NSTATES];

int rst[3*NPROD];
int nxtrst=1;

		
putarray()
{
	int a, i;
	struct func_def * rule;
	
	/* first yyrst table */
	fprintf(ftable,"short yyrst[]={\n\t0,");
	for (i = 1; rst[i] >= 0; i++)
	{
		fprintf(ftable,"%d, ",rst[i]);
		if (!((i+1) % 12))
			fprintf(ftable,"\n\t");
	}
	fprintf(ftable,"0\n};\n\n");

	/* now yyrsi table */
	fprintf(ftable,"short yyrsi[]={\n\t");
	for (i = 0; i <	nstate; i++)
	{
		fprintf(ftable,"%d, ",-rsi[i]); /* Note the minus-sign!!! */
						/* This should speed up   */
						/* the parser a little... */
		if (!((i+1) % 12))
			fprintf(ftable,"\n\t");
	}
	fprintf(ftable,"0\n};\n\n");
}

int not_in(p)
int p;
	/* check if production p not already in current reduction set */
{
	int i;

	i = nxtrst-1;
	while( i > 0 && rst[i])
	{
		if (rst[i--] == p)
			return(0);
	}
	return(1);
}

int nrst = 0;
int defprd=0;
int crstat=0;

new_rst(state)
int state;
{
	/* start a new rst entry */
	/* put the current rst index in the rsi array */
	/* place in rsi index is state		      */
	
	defprd = nrst = 0;
	if (rsi[state])
		error("state conflict in attribute grammar state is %d",
								    state);
	else
		rsi[state] = nxtrst;
	crstat = state;
}


put_rst(prodnr, k)
int prodnr,k;
{
	/* put the entry for production prodnr in the rst array */
	/* data is found in trst array				*/

	int p;

	if (!defprd) /* if no production without predicate present */
	{
	 	if (not_in(prodnr))   /* add it to the reduction set */
		{
			/* Insert according to cost */
			p = nxtrst-1;
			while (	(cost[rst[p]] > cost[prodnr]) &&
				(rst[p] != 0) && (p > 0) )
				{
				rst[p+1]=rst[p]; /* shove it */
				--p;
				}
			rst[p+1]=prodnr;
			nxtrst++;
			nrst++;
			levprd[prodnr] |= REDFLAG;
			if (!has_predicate[prodnr])
				defprd = prodnr;
		}
	}
	else if (prodnr != defprd)
	{
		if (has_predicate[prodnr])
		{ 
			if (not_in(prodnr))
			{ 
				/* Insert according to cost,
				   start looking BELOW the default rule  */
				/* first move up default production rule */
				rst[nxtrst]=rst[nxtrst-1];
				p = nxtrst-2;  /* instead of nxtrst-1 */
				while (	(cost[rst[p]] > cost[prodnr]) &&
					(rst[p] != 0) && (p>0) )
					{
					rst[p+1]=rst[p]; /* shove it */
					--p;
					}
				rst[p+1]=prodnr;
				nxtrst++;
				nrst++;
				levprd[prodnr] |= REDFLAG;
			}
		}
		else /* more than one rule without a predicate part, so 
			we can't decide which to choose */
		{
			if (foutput != NULL)
			fprintf(foutput,
			"\n%d: reduce/reduce conflict (red'ns %d and %d) on %s",
				crstat, prodnr, defprd, symnam(k));
			++zzrrconf;
		}
	}
}

cl_rst(state)
int state;
{
	/* if only one rule in state then put rule number in rsi array
	 * this way the parser doesn't execute a function
	 */

	if (nrst == 1)
		rsi[state] = -rst[--nxtrst];
	else if (!nrst)
		rsi[state] = 0;
	else
		rst[nxtrst++] = 0;
}

prreduce(state)
int state;
{
	int i;

	if (!rsi[state])
		return;
	if (rsi[state] < 0)
	{
		fprintf(foutput,"\n\t. reduce %3d", -rsi[state]);
		if (has_predicate[-rsi[state]])
			{
			if (cost[-rsi[state]]==1000000)
			fprintf(foutput,",          "); else
			fprintf(foutput,", cost %3d,",cost[-rsi[state]]);
			fprintf(foutput," IF %s",predicatetext[-rsi[state]]);
			}
		fprintf(foutput,"\n\n");

		return;
	}
	i = rsi[state];
	while(rst[i])
	{
		fprintf(foutput,"\n\t. reduce %3d", rst[i]);
		if (has_predicate[rst[i]])
			{
			if (cost[rst[i]]==1000000)
			fprintf(foutput,",          "); else
			fprintf(foutput,", cost %3d,",cost[rst[i]]);
			fprintf(foutput," IF %s",predicatetext[rst[i]]);
			}
		i++;
		if(!rst[i]) fprintf(foutput,"\n\n");
	}
}


