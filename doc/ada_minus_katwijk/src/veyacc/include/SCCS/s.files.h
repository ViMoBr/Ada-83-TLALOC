h25625
s 00010/00006/00007
d D 1.2 86/08/18 15:59:55 konijn 2 1
c format, other default parser, add sccsid
e
s 00013/00000/00000
d D 1.1 86/08/18 15:57:23 konijn 1 0
c date and time created 86/08/18 15:57:23 by konijn
e
u
U
t
T
I 1
D 2
	/* this file has the location of the parser, and the size of the progam desired */
	/* It may also contain definitions to override various defaults: for example,
	/* WORD32 tells yacc that there are at least 32 bits per int */
	/* on some systems, notably IBM, the names for the output files and tempfiles must
	/* also be changed  */
E 2
I 2
	/* %W%	%E% */
	/*
	 * this file has the location of the parser, and the size of
	 * the progam desired It may also contain definitions to
	 * override various defaults: for example, WORD32 tells yacc
	 * that there are at least 32 bits per int on some systems,
	 * notably IBM, the names for the output files and tempfiles
	 * must also be changed
	 */
E 2

	/* location of the parser text file */
#ifndef	PARSER
D 2
#define	PARSER	"yaccpar"
E 2
I 2
#define	PARSER	"/usr/lib/veyaccpar"
E 2
#endif	PARSER
	/* basic size of the Yacc implementation */
# define HUGE
# define WORD32
E 1
