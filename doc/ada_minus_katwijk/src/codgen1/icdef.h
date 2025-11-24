/*
  icdef.h
  kode definities voor pcc
  19880625/wjvg
*/

#define UNDEF    0x0
#define FARG     0x1
#define CHAR     0x2
#define SHORT    0x3
#define INT      0x4
#define LONG     0x5
#define FLOAT    0x6
#define DOUBLE   0x7
#define STRTY    0x8
#define UNIONTY  0x9
#define ENUMTY   0xa
#define MOETY    0xb
#define UCHAR    0xc
#define USHORT   0xd
#define UNSIGNED 0xe
#define ULONG    0xf

/* type modifiers */
#define PTR      0x10
#define FTN      0x20
#define ARY      0x30

/*type packing constants*/
#define TMASK  0x30
#define BTMASK 0x0f
#define TSHIFT 2

/*macros*/
#define MODTYPE(x,y)   (x)=((x)&(~BTMASK))|(y)  /* set basic type of x to y */
#define BTYPE(x)       ((x)&BTMASK)             /* basic type of x */
#define ISUNSIGNED(x)  ((x)<=ULONG&&(x)>=UCHAR)
#define UNSIGNABLE(x)  ((x)<=LONG&&(x)>=CHAR)
#define ENUNSIGN(x)    ((x)+(UNSIGNED-INT))
#define DEUNSIGN(x)    ((x)+(INT-UNSIGNED))
#define ISPTR(x)       (((x)&TMASK)==PTR)
#define ISFTN(x)       (((x)&TMASK)==FTN)        /* is x a function type */
#define ISARY(x)       (((x)&TMASK)==ARY)        /* is x an array type */

/*define KODES (DECIMAAL)*/
#define ERROR      1
#define NAME       2
#define ICON       4
#define FCON       5
#define PLUS       6
#define MINUS      8
#define MUL       11
#define AND       14
#define OR        17
#define ER        19
#define QUEST     21
#define COLON     22
#define ANDAND    23
#define OROR      24

/*reserved words etc.*/
#define TYPE      33
#define CLASS     34
#define STRUCT    35
#define RETURN    36
#define GOTO      37
#define IF        38
#define ELSE      39
#define SWITCH    40
#define BREAK     41
#define CONTINUE  42
#define WHILE     43
#define DO        44
#define FOR       45
#define DEFAULT   46
#define CASE      47
#define SIZEOF    48
#define ENUM      49

/*little symbols*/
#define LP        50
#define RP        51
#define LC        52
#define RC        53
#define LB        54
#define RB        55
#define CM        56
#define SM        57
#define ASSIGN    58

/*left over tree building operators*/
#define COMOP     59
#define DIV       60
#define MOD       62
#define LS        64
#define RS        66
#define DOT       68
#define STREF     69
#define CALL      70
#define FORTCALL  73
#define NOT       76
#define COMPL     77
#define INCR      78
#define DECR      79
#define EQ        80
#define NE        81
#define LE        82
#define LT        83
#define GE        84
#define GT        85
#define ULE       86
#define ULT       87
#define UGE       88
#define UGT       89
#define ARS       93
#define REG       94
#define OREG      95
#define STASG     98
#define STARG     99
#define STCALL   100

/*some conversion operators*/
#define FLD      103
#define SCONV    104
#define PCONV    105

/*special node operators*/
#define FORCE    108
#define CBRANCH  109
#define INIT     110
#define CAST     111

/*toegevoegd door bob, jaap en maarten*/
#define REVCALL  120
#define REVSTCAL 121
#define REVCM    122
#define REVMINUS 123
#define REVDIV   124
#define REVMOD   125
#define REVLS    126
#define REVRS    127
#define REVARS   128
#define REVCBRAN 129

#define ASG        1+
#define UNY        2+

/*IC CODES (DECIMAL)*/
#define ICALIGN    1
#define ICTEXT     2
#define ICDATA     3
#define ICBSS      4
#define ICLONG     5
#define ICWORD     6
#define ICBYTE     7
#define ICBYTES    8
#define ICDLABN    9
#define ICDLABS   10
#define ICJLABN   11
#define ICJLABS   12
#define ICFBEG    13
#define ICFEND    14
#define ICSKIP    16
#define ICCOMM    17
#define ICINIT    18
#define ICSWTCH   19
#define ICSWDEF   20
#define ICSWENT   21
#define ICSWEND   22
#define ICCOM     23
#define ICGLOBL   24
#define ICJFEND   25
#define ICNEQU    26
#define ICSEQU    27
#define ICVERS    28
#define ICADDR    29
#define ICSTRING  30
#define ICLANGUA  33
#define ICNOP     34
#define ICJSR     35
#define ICRTS     36
#define ICFILE    37
#define ICLN      38
#define ICDEF     39
#define ICENDEF   40
#define ICVAL     41
#define ICTYPE    42
#define ICSCL     43
#define ICTAG     44
#define ICLINE    45
#define ICSIZE    46
#define ICDIM     47
#define ICVALS    48
#define ICHEX     49
#define ICFLOAT   50
#define ICDOUBLE  51

#define ICPOINT  290
#define ICLB     291
#define ICRB     292
#define ICRP     293

/*end*/
