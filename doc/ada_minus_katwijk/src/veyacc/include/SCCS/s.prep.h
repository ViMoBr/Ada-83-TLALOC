h00328
s 00092/00000/00000
d D 1.1 86/09/05 16:29:22 konijn 1 0
c date and time created 86/09/05 16:29:22 by konijn
e
u
U
t
T
I 1
	/*	%W%	%E%	*/
/*
 *	common structures, definitions and so on
 */


/*
 *
 *	J van Katwijk
 *	Delft University of Technology,
 *	Department of Mathematics,
 *	132 Julianalaan
 *	Delft, The Netherlands
 *
 *	See for a functional description:
 *
 *	SIGPLAN NOTICES
 *	October 1983, 18 (10) pp 12 .. 16
 */
#define	TRUE	1
#define	FALSE	0

#define	MAXATTR	30
#define	PAR_SIZ	15
#define	TAGSIZE	4000
#define MAXDEF	30		/* I donot know */
#define	NONTERM	400		/* include .../dextern?? */
#define	WSTACKSIZE	50	/* arbitrary choice	*/
#define	OUTSTACKSIZE	40	/* idem			*/


#define	FATAL	030
#define	WARNING	040

#define	AS_LOCAL	010
#define	AS_STACK	020
#define	LOC_STRING	"_L%dL_"

struct type_elem {
	int un_number;		/* union field number */
	char *type_name;	/* type to be united  */
};

struct param {
	int par_no;
	int direction;	/* INPUT or OUTPUT */
	struct type_elem *par_desc;
};

struct att_def {
	int i_par, o_par;
	struct param attributes [MAXATTR];
	char *nonterm;
	char hasdefinition;
};

struct stack_elem {
	char par_name [PAR_SIZ];	/* keep it simple */
	struct type_elem *par_def;
	struct {
		char how_to_access;
		int ac_offset;
		int ac_lab;
	} access;		/* for access function */
};

/*
 *	some token definitions
 */
#define	ENDFILE	0
#define	COLON	1
#define	SEMI	2
#define	BAR	3
#define	INPUT	3	/* oh yes !!! */
#define	EQ_SYMB	4
#define	IDENTIFIER	257
#define	LCURL	12
#define	ATTR_DEF	16
#define	COMMA	17
#define	LPAR	18
#define	RPAR	19
#define	OUTPUT	20


extern	int	tok; 
extern	char	tokname[];
extern	char	*infile;
extern		error ();

extern	struct att_def *lookup ();
extern	struct att_def *new_def ();

E 1
