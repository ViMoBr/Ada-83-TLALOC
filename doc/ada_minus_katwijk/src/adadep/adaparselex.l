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
  * Adjusted scanner from Ada frontend
  *
  * Ton Biegstraaten dutinfd!abi 24-3-1987
  */

 /*	class definitions	*/

digit		[0-9]
letter		[a-zA-Z]
TAB		[ \t\n]
%{
char identstr[50];
%}
%%
%{
int resw_index;
%}
\014			;

[iI][sS]{TAB}+[nN][eE][wW]{TAB}		return (ISNEW);

[sS][eE][pP][aA][rR][aA][tT][eE]{TAB}*"("	return (SEP_LP);

{letter}+		{
			    if ( (resw_index = srch_resw (yytext)) >= 0)
			    {
				yylval = resw_index;
				return resw_index;
			    }
			    else
			    {
				copylower (identstr, yytext);
				return (IDENT);
			    }
			}

"$"("_"?({letter}|{digit}))*		{copylower (identstr, yytext); return (IDENT); }

{letter}("_"?({letter}|{digit}))*	{copylower (identstr, yytext); return (IDENT); }

"("					{ skipuntrp();return (LRP); }

")"					{ return RP;}


";"					{ return (SEM_COL); }

":"					{ return COLON;}

","					{ return (COMMA); }

"."					{ return (DOT); }

'[^\t\n]'				{ yylval = yytext [1] & 0377; }

"--".*			;

{TAB}			;

"\n"			;

\".*\"					{copylower (identstr, yytext); return IDENT; }
.					{copylower (identstr, yytext); return IDENT; }
%%
/*
 *	USER TABLES AND ROUTINES
 */

#include <ctype.h>

static	int resw_index ;
struct resword {
	char *stringrep;
	int  res_value;
}  res_word [] = {
	"with",		WITH,
	"use",		USE,
	"body",		BODY,
	"function",	FUNCTION,
	"return",	RETURN,
	"package",	PACKAGE,
	"procedure",	PROCEDURE,
	"is",		IS,
	"declare",	DECLARE,
	"separate",	SEPARATE,
	"task",		TASK,
	"begin",	BEGN,
	"end",		END,
	"type",		TYPE,
	"renames",	RENAMES,
	"generic",	GENERIC,
	"record",	RECORD,
	"case",		CASE,
	"if",		IF,
	"loop",		LOOP,
	"select",	SELECT,
	"do",		DO,
	NULL,		0
};

srch_resw (text)
register char * text;
{
	register int i;
	register char ctext[50];

	copylower(ctext,text);
	for (i = 0; res_word [i]. stringrep != NULL; i++)
	   if (!strcmp (res_word [i].stringrep, ctext))
	      return res_word [i]. res_value;
	
	return -1;
}

/*
 * skip until right parenthesis 
 */
skipuntrp()
{
    int noflp = 1;
    char c;

    while (noflp)
    {
	c = input();
	if (c == '"')				/* string */
	{
	    do
		c = input();
	    while (c != '"');
	    continue;
	}
	if (c == '-' && (c = input()) == '-')	/* comment */
	{
	    while (input() != '\n');
	    continue;
	}
	if (c == '(') noflp++;
	if (c == ')') noflp--;
    }
}

copylower (s1, s2)
char *s1, *s2;
{
    while (*s2)
	*s1++ = isupper (*s2) ? _tolower (*s2++) : *s2++;
    *s1 = '\0';
}
