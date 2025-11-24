/* 
 *
 * grinc.h
 *
 * Should be included in gr.y (so it will be in cgy.tab.c) and grinc.c
 *
 * Type definitions, external declarations,
 * macros, functions with strange types
 *
 */





# define TRUE  1
# define FALSE 0

/*********************************************************/
/* This is a declaration for gr.l, the LEX specification */
/*********************************************************/

extern int debuglex;

/**************************/
/* The rest is for CGYACC */
/**************************/

	typedef char stringtype[80];


	enum nodetypetype	{ /* adressing modes */
				immediate,
				absolute,
				dreg,
				areg,
				fpreg,
				aregind,
				aregind_with_displacement,
				aregind_with_index,
				postinc,
				predec,
				/* special nodes */
				cmnode,
				stargnode,
				dummynode
				} ;

	struct nodeattrtype {
	
			/* Always defined: */

			int type;	/* as defined in the IC */	    
			enum nodetypetype nodetype;
					/* Code generator's typing */
			int address;	/* boolean; TRUE if this node is
					   an address, FALSE if it denotes
					   the contents of an address */
			int bitfld;	/* boolean; true if this node is
					   a bitfield */
			stringtype s;	/* assembler text representing 
			                   result of this node */

			/* defined when bitfld=true: */
		
			stringtype bfs;	/* holds text for bitfield
					   instructions */
			                   
			/* Defined when nodetype=areg or dreg or fpreg: */

			int regnr;  

			/* Defined when nodetype=immediate: */

			stringtype nameonly;	/* same as s, but without # */
			int value;
			int valueknown;	/* boolean */
			
			/* Defined when nodetype=aregind or
					nodetype=aregind with offset or
					nodetype=aregind with index */
			int offsetknown; /* boolean */
			stringtype offsets; /* in case it's a label */
			int offset; /* when it's known */
			int baseregnr; /* always address register */
			int indexregnr; /* data or address register */
			char indexregtype; /* 'd' or 'a' */
			} ;
			
	typedef struct nodeattrtype nodeattr;

extern	char *languagename[10];
			

extern	int languagenumber;	/* 1=C,2=F77,3=PASCAL,4=SPL,5=COBOL,6=ADA */
extern	int fendlabel;		/* numeric label of end of function */
extern	int endlabel;		/* numeric label of end of some construct */
extern	int dimlistsize;	/* icdim expects a variable # of arguments */
extern	int bytelistsize;	/* icbytes expects a variable # of arguments */
extern	int profile;		/* boolean flag for generating profiling code
					(not implemented) */
extern	stringtype fname;	/* name of function */
extern	stringtype s;		/* temporary var */
extern	int newlabel;		/* back-end generated numeric labels */
extern	int l,l1,l2;		/* numeric labels for nice constructs */
extern	int funclinklabel;	/*     "	"	"	"    */
extern	int funcstartlabel;	/*     "	"	"	"    */
extern	int defaultlabel;	/* label of default part of switch statement */
extern	int autosize;		/* number of bytes on stack for automatic 
				   variables */
extern	int framesize;		/* total number of bytes of frame */
extern	int areghi;		/* highest free address register */
extern	int a,a1,a2;		/* temporary address registers */
extern	int dreghi;		/* highest free data register */
extern	int d,d1,d2;		/* temporary data register */
extern	int dr,dq;		/* temp remainder,quotient register pair */
extern	int dsrc,ddest;		/* temporary data registers */
extern	int fpreghi;		/* highest free floating point register */
extern	int fp;			/* temporary float register */
extern	int floatused;		/* boolean */
extern	int c;			/* temporary for "constant" values */
extern	int savesize;		/* # of bytes occupied by arguments */

#define ISTACKSIZE 100
extern	char instruction_stack[ISTACKSIZE][80]; 
				/* ISTACKSIZE instructions, 80 chars/instr */
extern	int isp;		/* instruction stack pointer 
				   isp == # of instructions on stack */
# define STARGBUFSIZE 30
extern	char starg_buffer[STARGBUFSIZE][80];
extern	int starg_buffer_top;	/* points to next free instruction in
				   starg_buffer */

extern	int exchanged;		/* boolean; indicates whether the two
				   operands to a CMP instruction were
				   exchanged. This affects GT, LT etc. */

/**** Register stuff ****/

	enum reginfotype { free, scratch, regvar };
extern	enum reginfotype dreginfo[8], areginfo[6], fpreginfo[8];
extern	int savedreg[8], saveareg[6], savefpreg[8];  /* boolean */

/**** Functions with strange types ****/

nodeattr initnodeattr();

nodeattr make_dreg_node();

nodeattr make_areg_node();

nodeattr make_fpreg_node();

nodeattr make_dummy_node();

char *stypesize();

char *snodesize();

char *snodesize2();
