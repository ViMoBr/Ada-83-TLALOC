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
  * scanner for recognizing the output of adaparse
  *
  * Ton Biegstraaten dutinfd!abi   24-3-87
  */

 /*	class definitions	*/

digit		[0-9]
letter		[a-zA-Z]
TAB		[ \t\n]
%{
char identstr[50];
%}
%%
NC:		return NOCONTEXT;
W:		return WITH;
U:		return UNIT;
L:		return LOCAL;
PS:		return PACKSPEC;
GS:		return GENERICSPEC;
GI:		return GENERICINSTAN;
PB:		return PACKBODY;
TB:		return TASKBODY;
SN:		return PARNAME;
SS:		|
FS:		return SUBPRSPEC;
SB:		|
FB:		return SUBPRBODY;
"S :"		return PROCEDURE;
"F :"		return FUNCTION;
R:		return RENAME;
D:		return DECLARE;
SU:		return SUBUNIT;
GN:		return GENERIC;
TS:		return TASKSPEC;
ST:		return STUB;
SF:		return SOURCEFILE;

"$"("_"?({letter}|{digit}|"/"|"."|"-"))*	{strcpy (identstr, yytext); return (IDENT); }

({letter}|"/"|".")("_"?({letter}|{digit}|"/"|"."|"-"))*  {strcpy (identstr, yytext); return (IDENT); }

{TAB}			;

"\n"			;

\".*\"				{strcpy (identstr, yytext); return IDENT; }
.				{strcpy (identstr, yytext); return IDENT; }
%%
