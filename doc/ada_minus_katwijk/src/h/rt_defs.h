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

/*
 * fundamental definitions of constants and types during runtime
 */



/*
 * there are three fundamental machine value sizes
 *
 *	char	1 byte long:	integer range -2**7..2**7-1  (*)
 *				or unsigned range 0..2**8-1
 *	word	2 bytes long:	integer range -2**15..2**15-1  (*)
 *				or unsigned range 0..2**16-1
 *	long	4 bytes long:	integer range -2**31..2**31-1  (*)
 *				or unsigned range 0..2**32-1
 *
 * to stay compatible with other machines where bytes are treated
 * as unsigned quantities often, one must only use the 0..2**7-1
 * range of values of a byte.
 *
 * unsigned words can be made by prefixing 'word' with 'unsigned'
 */

#define	word	int

/*
 * The basic target machine type are defined here;
 * These definitions are target dependent
 *
 */

typedef char	TG_byte;
typedef int	TG_word;
typedef char   *TG_ADDR;
typedef long	TG_long;
typedef float	TG_float;

/*---------------*/


/*
 * assumption:	indices can be represented by words
 */
typedef	word	INDEX;
typedef INDEX	*INDEXP;
/*
 *	Offsets in a parameter
 */
#define	BYTE_IN_LONG	3
#define	SHORT_IN_LONG	2
#define	LONG_IN_LONG	0

#define	TBYTESIZE	1
#define	TWORDSIZE	2
#define	TINTSIZE	2
#define	TLONGSIZE	4
#define	TADDRSIZE	4
#define	TFLOATSIZE	8


#ifdef EM
#define	SToff_BASE	(1 * TADDRSIZE)
#define	SToff_2BASE	(SToff_BASE + TADDRSIZE)
#define	EXH_DESCR_SIZE	(3 * TADDRSIZE)
#define	PARBASE		0
#define	LINK_OFFSET	0 * TADDRSIZE
#define	FRAMBASE	SToff_2BASE + TADDRSIZE
#else
#define	SToff_BASE	2 * TADDRSIZE
#define	SToff_2BASE	(SToff_BASE + TADDRSIZE)
#define	EXH_DESCR_SIZE	(3 * TADDRSIZE)
#define	PARBASE		3 * TADDRSIZE
#define	LINK_OFFSET	2 * TADDRSIZE
#define	FRAMBASE	SToff_BASE + TADDRSIZE
#endif EM

#define	NREGS	10	/* a2-a5 en d2 - d7	*/

/*
 * assumption:	byte is the smallest addressable unit in memory
 */
typedef char	*ADDR;
typedef ADDR	*ADDRP;

/*
 * main stacktop offset
 */
/*
 * the largest type (currently) supported by the implementation is word:
 */
typedef word	MAXTYPE;
typedef MAXTYPE *MAXTYPEP;

/*
 * assumption: offsets in records and sizes of arrays and records
 * cannot be larger than maximum number of addressable bytes
 * on the 68000 it is even somewhat limted.
 */
#ifdef TG_PDP11
typedef unsigned TG_word	MAXADDR;
#else
typedef unsigned short		MAXADDR;
#endif TG_PDP11
typedef MAXADDR *MAXADDRP;

/*
 * dynamic arrays cannot be declared in C
 */
#define	DYNAMIC	1

/*
 * tags for runtime constructs
 */
#define	CB	1
#define	CD_BIT_H 2
#define	CD_BIT_S 3
#define	TD_ARR	4
#define	VD_ARR	5
#define	TD_REC	6
#define	VD_REC	7
#define	TD_ACC	8
#define	CD_ACC	9
#define	DD_REC 10

#define	CB_VALUE 11
#define	CB_PARPAR 12
#define	VD_HEAP	13

#define TD_TSK	14

/* A master struct (see dats.h) is 12 bytes long:
 *	4 : 1 pointer to a task (tdp) (it's first child)
 *	4 : 1 pointer to a task (its enclosing task)
 *	4 : 1 pointer to the previous master (if there is any)
 *	4 : 1 integer giving the number of children
 */
#define TMASTERSIZE	16



/*
 * flags are used to remember various attributes of lower level constructs
 *
 * these attributes include:
 *	kind (of a record):	F_KIND = (DYNREC | CSTREC | VARREC)
 *	recurs. init ind  :	F_RINIT
 *	alignment	  :	F_ALIGN = (ALIGN16| ALIGN8| ALIGN4| ALIGN2)
 *	tasktype ind.     :	F_TASK
 *	master indication :	F_MASTER
 * these flags are packed in a datastructure  called "flags"
 */

#define	F_ALIGN		017
#define	F_RINIT		020
#define	F_KIND		0340
#define	F_MASTER	02000
#define F_TASK		04000

#define	ALIGN2	01
#define	ALIGN4	03
#define	ALIGN8	07
#define	ALIGN16	017

/*
 * the alignment factors are such that if 'a' is the
 * necessary alignment factor, and 'off' is the unaligned
 * address (or size),
 *		( (off + a) & ~a )
 * will express the aligned address (size).
 */

/*
 * The alignment may be target machine dependent;
 * when cg1 is used for a different target machine,
 * the definitions of the alignment factors may be changed.
 *
 * on the PDP11 alignment will be as follows:
 */
#define	byte_ALIGN	0
#define	word_ALIGN	ALIGN2
#define	long_ALIGN	ALIGN2
#define	ADDR_ALIGN	ALIGN2
#define	MAX_ALIGN	ALIGN2

/*-----------------*/


#define	VARREC	040
#define	CSTREC	0100
#define	DYNREC	0200

#define	UNCONS_REC	020000
/*
 * the codes of the record kinds are composed of the codes
 * for these three represented attributes
 */
#define	A_REC	(0	| 0	| 0	)
#define	B_REC	(0	| 0	| VARREC)
#define	C_REC	(0	| CSTREC| 0	)
#define	D_REC	(0	| CSTREC| VARREC)
#define	E_REC	(DYNREC | 0	| 0	)
#define	F_REC	(DYNREC	| 0	| VARREC)
#define	G_REC	(DYNREC	| CSTREC| 0	)
#define	H_REC	(DYNREC	| CSTREC| VARREC)

#define	EX_DESC		0
#define	EX_NONDESC	1
#define	NO_ARRACC	0
#define	ARRACC		1

#define	SCC_AND		0
#define SCC_OR		1
