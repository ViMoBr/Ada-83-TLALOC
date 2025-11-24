#define	NO_LAB		0

#define	MAX_AS_ID_LEN	32
#define	EXTRA_LETTER	'.'



#define	DEF_LONG	0
#define	DEF_WORD	1
#define	DEF_BYTE	2
#define	DEF_DOUBLE	3
#define	DEF_ADDR	4
#define	DEF_STRING	5
#define	DEF_SLONG	6

/*
 *	expression flags
 */

#define	NORM_EVAL	(0 << 12)
#define	LARG_EVAL	0xA000
#define	ORDR_EVAL	0xB000

#define	EMASK		0xF000

#define	ONE	1

#define	TEMP	0
#define	REF	1
#define	VAL	2


#define		DEF_ENTRY	0
#define		DEF_EXIT	1


#define	NULL_TOKEN	0

#define	NOALLOC		0
#define	GLOBAL		1
#define	PARSTACK	2
#define	FIXSTACK	3
#define	FIXDYN		4
#define	GLOBDYN		5
#define	HEAP		6
#define	GLOBUNCONS	7
#define	FIXUNCONS	8
#define	DISCALLOC	9
#define ENTRYSTACK	10
#define	THROUGH_EXPR	11

#define	AIDL	IDL + 10
#define	LINE		1
#define	SUB_ENTRY	2
#define	SUB_EXIT	3
#define	PACK_ENTRY	4
#define	PACK_EXIT	5
#define NO_ADB_ACTION	6

#define	XNOTFILLED	0
#define	XNO_TABLE	1
#define	XTYPE_TABLE	2
#define	XSUB_TABLE	3

#define	GETDESCR	010
#define	ADDRDESCR	020

#define	PAR_0	8
#define	PAR_1	12
#define	PAR_2	16
#define	PAR_3	20


#define NORMAL	0
#define INIT_SUB 1
