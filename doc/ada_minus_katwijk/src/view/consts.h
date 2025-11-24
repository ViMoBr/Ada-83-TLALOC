
/*
 *	a number of constants used throughout the packages
 */
#define	LIBRARY		".master"
#define	PREP		"/lib/cpp"
#define	FRONT		"/home/adacomp/src/front/ada_front"
#define	BACK		"/home/adacomp/src/cg/ada_cg"
#define	PC1		"/bin/cp"
#define	OPT		"/bin/cp"
#define	ASS		"/bin/as"
#define LOADER		"/bin/ld"
#define DASLOAD		"/home/adacomp/lib/dasload"
#define	SSTARTUP	"/home/adacomp/lib/dasrt0.s"
#define	TASKSTARTUP	"/home/adacomp/lib/dastaskrt0.s"
#define	STARTUP		"/home/adacomp/lib/dasrt0.o"
#define	DASEXIT		"/home/adacomp/lib/dasexit.o"
#define	DASLIB		"/home/adacomp/lib/daslib.a"
#define	LIBM		"-lm"
#define LIBC		"-lc"
#define U_STANDARD	"std_ps"
#define	T_STANDARD	"/home/adacomp/lib/std_ps.t"
#define	O_STANDARD	"/home/adacomp/lib/std_ps.o"
#define	B_STANDARD	"/home/adacomp/lib/std_ps.o"
#define AR		"/usr/bin/ar"
#define	CONVERT		"/home/adacomp/lib/convert"

#define OBJDIR          "adaobjects"
#define ASDIR           "adaass"
#define TREEDIR         "adatrees"

#define	TMP		"/tmp"
#define	CURRDIR		"."

#define MINTIME 	0		/* time' firt */
#define MAXTIME 	2147483647	/* time' last */
#ifndef DDB_TREE
#define	MAXLUN		256		/* max luns in the closure */
#endif
#define	MAXLIST		10		/* max luns in context spec */
#define	FNAMESIZE	100		/* max unix file name size */
#define	UNAMESIZE	20		/* max unit name size */

#define FALSE	0
#define TRUE	1

#ifndef DDB_TREE
typedef int bool;
#endif
/*
 *  different "kinds" of library units: (body, spec, subprogram, subunit)
 */

#define SS		1
#define PS		2
#define TS		4
#define BODY		8
#define SB		(SS | BODY)
#define PB		(PS | BODY)
#define TB		(TS | BODY)

/* The next flags can be ored with the previous */
#define SU		0x10
#define GI		0x20
#define GNRC		0x40

/*
 * differnet "states" of library units: (invalid, compiled, loaded)
 */

#define COMPILED	0x80
#define LOADED		0x100

#define VRIJ		0x200



#define UNLCK	0666
#define LOCK	0444
#define EXISTS	0
#define RMODE	4

#define C_READWRITE	0666

#define O_READ		0
#define O_WRITE   	1
#define O_READWRITE	2

#define R	O_READ
#define W	O_WRITE
#define RW	O_READWRITE

/* extensions */
#define E_TREE		't'
#define E_OBJECT 	'o'
#define E_PREP		'i'
#define E_PCC		'p'
#define E_AS		's'
#define E_OPT		'O'
#define E_FRONT		'f'
#define E_EXEC		'x'

#define	LOW_LUN		4

extern	bool	yflagP;	/* Preprocessor */
extern	bool	yflagO;	/* Optimizer */
extern	bool	yflaga;	/* assembler */
extern	bool	yflagb;	/* backend */
extern	bool	yflagc;	/* convert */
extern	bool	yflagf;	/* front */
extern	bool	yflagg;	/* code generator */
extern	bool	yflagl;	/* loader */

extern	bool	flagk;	/* keep intermediate files */
extern	bool	flagn;	/* do nothing, just show verbose list */

extern	char	*daslib;
extern	char	*dasexit;
extern	char	*b_standard;
extern	char	*t_standard;
extern	char	*startup;
