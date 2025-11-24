	/* @(#)files.h	1.2	86/08/18 */
	/*
	 * this file has the location of the parser, and the size of
	 * the progam desired It may also contain definitions to
	 * override various defaults: for example, WORD32 tells yacc
	 * that there are at least 32 bits per int on some systems,
	 * notably IBM, the names for the output files and tempfiles
	 * must also be changed
	 */

	/* location of the parser text file */
#ifndef	PARSER
#define	PARSER	"/usr/lib/veyaccpar"
#endif	PARSER
	/* basic size of the Yacc implementation */
# define HUGE
# define WORD32
