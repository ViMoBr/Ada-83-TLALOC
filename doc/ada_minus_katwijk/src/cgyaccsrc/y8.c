/*
 * y8.c
 *
 * CGYACC module for loop detection
 *
 * July 1988
 * M.J. Landzaat, TUD
 *
 * Algorithm for loop generation taken from
 * "Collegedictaat Combinatorische Algoritmen (a149)" 
 * by A.J. van Zanten, july 1983, pp. 145-151
 *
 * The algorithm is copied as verbatim as possible,
 * so please excuse me for the Dutch words.
 *
 */



#define MAXLOOPLENGTH 100

#include "dextern"

int number_of_loops;

int looprule[NPROD];
int loopruleindex;

int nodelist[NNONTERM];
int nodelistindex;


detect_loops()
	{
	number_of_loops=0;
	preparetables();
	compute_loops();
	if (number_of_loops>0)
		fprintf(stderr,"\nWarning: %d possible loop%s detected!\n",
			number_of_loops,(number_of_loops==1)?"":"s");
	else 	fprintf(stderr,"\nNo loops detected.\n");
	}

preparetables()
	{
	/* fills arrays looprule[] with production rules which may
	   be part of a loop, and nodelist[] with nonterminals (called
	   nodes here because of the graphic interpretation) which
	   occur in the rules of looprule[].
	*/
	int prod,add;
	int *p;

	loopruleindex=0;
	nodelistindex=0;

	PLOOP(1,prod)
		{
		p=prdptr[prod];


/* determine whether this rule has a RHS with the following format:
   one nonterminal, followed by zero or more epsilon-deriving
   nonterminals. Only a rule of this format may be part of a loop. 
*/
		p++; /* first RHS symbol */
		if (nonterminal(*p))
			{
			
			p++; /* second symbol */
			while (nonterminal(*p) && pempty[*p-NTBASE]) p++;
			if (nonterminal(*p))
				add=FALSE;
			else if (terminal(*p))
				add=FALSE;
			else add=TRUE;
			}
		else add=FALSE;

/* If rule is a possible loop-rule, save it */

		if (add) 
			{
			looprule[loopruleindex++]=prod; /* save rule */
			p=prdptr[prod];
			add_node(*p++); /* add LHS to nodelist */
			add_node(*p); /* add first RHS symbol to nodelist */
			}
		
		}	

	}


terminal(i)
	{ return((i>=0) && (i<NTBASE)); }

nonterminal(i)
	{ return(i>=NTBASE); }



add_node(n)
int n;
	{
	/* add node (nonterminal) n to nodelist, if not present */
	int i=0;
	while (nodelist[i]!=n && i<nodelistindex) i++;
	if (nodelist[i]!=n) /* not found */
	nodelist[nodelistindex++]=n;
	}





int n; /* aantal knopen */
int s; /* huidige startknoop */
int bereik[NNONTERM];

int pad[MAXLOOPLENGTH];
int padindex;

compute_loops()
	{
	int v; /* loopknoop */
	int f; /* dummy result */

	n=nodelistindex;
	s=1;
	padindex=0;
	while (s < n)
		{
		bepaal_G(s);
		if (nodelistindex==0) s=n;
		else	{
			/* nabuurstructuur hoeft niet expliciet bepaald */
			for (v=s;v<=n;v++)
				{
				bereik[v]=TRUE;
				emptyb(v);
				}
			circuit(s,&f);
			s++;
			}
		}
	}
		

		
circuit(v,sukses)
int v;
int *sukses; /* boolean */
	{
	int i; /* keeps track of recursive adjacency calls */
	int w; /* hulpknoop */
	int g; /* hulpvar voor sukses op dieper niveau */

	*sukses=FALSE;
	pad[padindex++]=v; /* zet v op pad-stack */
	bereik[v]=FALSE;
	
	/* voor w element van adj(v) doe */
	
	initadj(&i);
	while (w=nextadj(v,&i))
		{
		if (w==s)
			{
			number_of_loops++;
			print_circuit();
			*sukses=TRUE;
			}
		else
			{
			if (bereik[w] && !elemb(v,w))
				{
				circuit(w,&g);
				*sukses = *sukses || g;
				}
			}
		}
	if (*sukses) rehab(v);
	else 	{
		initadj(&i);
		while (w=nextadj(v,&i)) addtob(v,w); /* add v to B(w) */
		}
	padindex--; /* haal v van pad-stack af */
	}
	


rehab(v)
int v;
	{
	int u; /* hulpknoop */

	bereik[v]=TRUE;

	for (u=s;u<=n;u++)   /* For u element of B(v) */
	if (elemb(u,v))
		{
		removefromb(u,v);  /* remove u from B(v) */
		rehab(u);
		}
	}
	
		
bepaal_G(s)
int s;
	{
	/* haal regels met knoop s-1 uit looprule[] */
	register int i,j;
	int lhs,rhs;
	int *p;
	
	if (s>1)
		{
		for (i=0;i<loopruleindex;i++)
			{
			p=prdptr[looprule[i]];
			lhs = *p++;
			rhs = *p;
			if (lhs==nodelist[s-1] || rhs==nodelist[s-1]) 
				{
				/* remove rule */
				for (j=i;j<loopruleindex-1;j++)
					looprule[j]=looprule[j+1];
				loopruleindex--;
				i--; /* check this entry again; 
				   	it's got a new rule */
				}
			}
		}
	}
	

print_circuit()
	{
	int i;
	if (number_of_loops==1)
		printf("\nLoops detected:\n");
	for (i=0;i<padindex;i++)
		printf("%s --> ",symnam(nodelist[pad[i]]) );
	/* print first nt again only to show it's really a loop */
	printf("%s\n",symnam(nodelist[pad[0]]) );
	}	
		
/* B() operaties */

int b [NNONTERM] [NWORDS(NNONTERM)];


emptyb(v)     /* B(v) := empty */
int v;
	{
	int i,j;
	NTLOOP(i)
		{
		for (j=0;j<NWORDS(NNONTERM);j++) b[i][j]=0;
		}
	}
	
addtob(v,w)  /* B(w) := B(w) + {v} */
int v,w;
	{
	SETBIT(b[w],v);
	}
	

removefromb(v,w)  /* B(w) := B(w) - {v} */
int v,w;
	{
	RESETBIT(b[w],v);
	}
	
elemb(v,w)   /* v element of B(w)? */
int v,w;
	{
	return(BIT(b[w],v));
	}
	

	
		
	
/* adjacency operaties */

initadj(i)
int *i;
	{
	*i=0;
	}


nextadj(v,i)
int v;
int *i;
	{
	/* return volgende buur door in looprule[] te kijken.
	   gebruik teller *i daarvoor
	   return 0 als er geen buur meer is 
	*/
	
	int found; /* boolean */
	int *p;
	int ret; /* temp var for returned value */
	
	found=FALSE;
	while (!found && *i<loopruleindex)
		{
		p=prdptr[looprule[*i]];
		if (*p==nodelist[v]) /* if (lhs of rule i) == v */
			{
			found=TRUE;
			/* return index of rhs */
			p++; /* points to first rhs symbol */
			/* search rhs in nodelist to obtain index */
			ret=0;
			while (nodelist[ret] != *p) ret++;
			}
		(*i)++;
		}
	if (found) return(ret); else return(0);
	}

