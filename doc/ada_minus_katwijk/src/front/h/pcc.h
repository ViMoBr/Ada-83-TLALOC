/* PCC types */

/* MARK !
 * when changed, also change CGgpcc00.c :
 * pointer_type_of ()
 */

#define NOTYPE		 0
#define	CHAR		 2
#define BYTE		 2
#define	SHORT		 3
#define	VOID		 4
#define	INT		 3
#define	LONG		 4
#define	FLOAT		 7
#define	DOUBLE		 7
#define	UBYTE		14
#define	UCHAR		14
#define	USHORT		15
#define	UNSIGNED	15
#define	ULONG		17
#define	ADDRESS		24

#define	P_CHAR		22
#define P_BYTE		22
#define	P_SHORT		23
#define	P_INT		23
#define	P_LONG		24
#define	P_FLOAT		27
#define	P_DOUBLE	27
#define	P_UBYTE		34
#define	P_UCHAR		34
#define	P_USHORT	35
#define	P_UNSIGNED	35
#define	P_ULONG		37

/* COMPLEX TYPES
 *
 * PF_INT  = PTR ( FTN ( INT))
 * PF_UCHAR= PTR ( FTN ( UCHAR))
 * PF_ADDR = PTR ( FTN ( PTR (INT)))
 */

#define PF_INT	224
#define PF_UCHAR 234
#define PF_ADDR	624

/* IC nodes */

#define	ICEVEN		1
#define	ICTEXT		2
#define	ICDATA		3
#define	ICBSS		4
#define	ICLONG		5
#define	ICWORD		6
#define	ICBYTE		7
#define	ICBYTES		8
#define	ICDLABN		9
#define	ICDLABS		10
#define	ICJLABN		11
#define	ICJLABS		12
#define	ICFBEG		13
#define	ICFEND		14
#define	ICSKIP		16
#define	ICCOMM		17
#define	ICINIT		18
#define	ICSWTCH		19
#define	ICSWDEF		20
#define	ICSWENT		21
#define	ICSWEND		22
#define	ICCOM		23
#define	ICGLOBL		24
#define	ICJFEND		25
#define	ICNEQU		26
#define	ICSEQU		27
#define	ICVERS		28
#define	ICADDR		29
#define	ICSTRING	30
#define	ICLANGUAGE	33
#define	ICNOP		34
#define	ICJSR		35
#define	ICRTS		36
#define	ICFILE		37
#define	ICLN		38
#define	ICDEF		39
#define	ICENDEF		40
#define	ICVAL		41
#define	ICTYPE		42
#define	ICSCL		43
#define	ICTAG		44
#define	ICLINE		45
#define	ICSIZE		46
#define	ICDIM		47
#define	ICSYMV		48
#define	ICFLOAT		50
#define	ICDOUBLE	51

#define	ARSAV(fn, fnr, elab, proflag, locsize, datareg, addreg)	\
		OUT (("&%d	%d	%d	%d	%s\n",		\
				ICFBEG, fnr, elab, proflag, fn)),	\
		OUT (("[%d	%d	%d	%d	\n",		\
				fnr, locsize * 8, datareg, addreg))

#define	DASSAV(fn, fnr, elab, proflag, locsize, datareg, addreg)	\
		OUT (("&%d	%s\n", ICGLOBL, fn)),			\
		OUT (("&%d	%d	%d	%d	%s\n",		\
				ICFBEG, fnr, elab, proflag, fn)),	\
		OUT (("[%d	%d	%d	%d	\n",		\
				fnr, locsize * 8, datareg, addreg))

#define	DASRET(elab,adb_action,adb_line_no)				\
		OUT (("&%d	%d	\n", ICDLABN, elab)),		\
		adb_break (adb_action, adb_line_no),			\
		OUT (("&%d	\n", ICFEND)),				\
		OUT (("]\n"))


#define	RAISE(exc)							\
		new_expr (),						\
		CALL (VOID),						\
		   ICON (0, ADDRESS, "__raise"),				\
		   ICON (0, ADDRESS, exc)


#define	HARDRET(elab, adb_action, adb_line_no)		\
		OUT (("&%d	\n", ICFEND)),				\
		OUT (("&%d	%d	\n", ICDLABN, elab)),		\
		OUT (("&%d	\n", ICFEND)),				\
		new_expr (),						\
		UCALL (VOID),						\
		ICON (0, PF_INT, __HARDRET),				\
		OUT (("]\n"))

#define	COMVAR(str,dec)	OUT (("&%d	%d	%s\n", ICCOMM, dec, str))
#define	JMP_EXIT	OUT (("&%d	_exit\n", ICJLABS))
#define	OUTLAB(str)	OUT (("&%d	%s\n", ICDLABS, str))
#define	JUMP(str)	OUT (("&%d	%s\n", ICJLABS, str))
#define	C_BASE		32
#define	OUTTEXT		text_flag = TRUE
#define	OUTDATA		text_flag = FALSE
#define	OUTBSS		OUT (("&%d	\n", ICBSS))
#define	OUTEVEN		OUT (("&%d	2	\n", ICEVEN))
#define LABELOFF(x,y)	OUT (("&%d	.	%s+%d	\n",ICSEQU,x,y))
#define TESTBYTE(x)	OUT ((")	tst.b	0(sp)\n"))
# define	REG(x,y)	P_REG (x,y)
# define	NAME(x,y)	P_NAME (x,ADDRESS,y)
# define	INIT(x)		P_UNARY (110, x)
# define	ICON(x, y, z)	P_CONST (x, y, z)
# define	NO_OP		0
# define	SCONV(x)	P_UNARY (104, x)
# define	DEREF(x)	P_UNARY ( 13, x)
# define	GOTO()		P_UNARY ( 37, 4)
# define	UCALL(x)	P_UNARY ( 72, x)
# define	NOT(x)		P_UNARY ( 76, x)
# define	CBRANCH()	P_BINARY (109, 4)
# define	FORCE(x)	P_UNARY (108, x)
# define	INIT(x)		P_UNARY (110, x)
# define	QUEST(x)	P_BINARY ( 21, x)
# define	COLON(x)	P_BINARY ( 22, x)
# define	AND(x)		P_BINARY ( 14, x)
# define	ANDAND(x)	P_BINARY ( 23, x)
# define	OR(x)		P_BINARY ( 17, x)
# define	OROR(x)		P_BINARY ( 24, x)
# define	MUL(x)		P_BINARY ( 11, x)
# define	PLUS(x)		P_BINARY ( 6, x)
# define	MINUS(x)	P_BINARY ( 8, x)
# define	COMMA()		P_BINARY (59, 4)
# define	PARCOM()	P_BINARY (56, 4)
# define	CALL(x)		P_BINARY (70, x)
# define	ASSIGN(x)	P_BINARY (58, x)
# define	INCR(x)		P_BINARY (78, x)
# define	DECR(x)		P_BINARY (79, x)
# define	EQ(x)		P_BINARY (80, x)
# define	NE(x)		P_BINARY (81, x)
# define	LE(x)		P_BINARY (82, x)
# define	LT(x)		P_BINARY (83, x)
# define	GE(x)		P_BINARY (84, x)
# define	GT(x)		P_BINARY (85, x)
# define	ULE(x)		P_BINARY (86, x)
# define	ULT(x)		P_BINARY (87, x)
# define	UGE(x)		P_BINARY (88, x)
# define	UGT(x)		P_BINARY (89, x)
# define	ASS_MIN(x)	P_BINARY ( 9, x)
# define	ASS_PLUS(x)	P_BINARY ( 7, x)
# define	STASSIGN(t, n)	P_TRINARY (98, t, n)

