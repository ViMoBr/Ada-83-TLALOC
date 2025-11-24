
digit		[0-9]
ext_digit	({digit}|[a-fA-F])
letter		[a-zA-Z]
TAB		[ \t\n]
integer		({digit}("_"?{digit})*)
ext_integer	({ext_digit}("_"?{ext_digit})*)
exp		([eE][+-]?{integer})
pos_exp		([eE][+]?{integer})

%%
%{
static int resw_index;
static int attr_index;
%}
{integer}#{ext_integer}#{pos_exp}?	{
			  int length;
			  char num_string [256];

			  sc_b_int (yytext, num_string);
			  length = sc_strlen (num_string);
			  yylval. p_char = (char *)alloc_lit (S_INTLIT, num_string, length);
			  return T_INT_LIT;
			}

{integer}#{ext_integer}\.{ext_integer}#{exp}?	{ 
			  int length;
			  char num_string [256];

			  sc_b_real (yytext, num_string);
			  length = sc_strlen (num_string);
			  yylval. p_char = (char *) alloc_lit (S_REALLIT, num_string, length);
			  return T_REAL_LIT;
			}

{integer}{pos_exp}?	{
			  int length;
			  char num_string [256];

			  sc_int (yytext, num_string);
			  length = sc_strlen (num_string);
			  yylval. p_char = (char *) alloc_lit (S_INTLIT, num_string, length);
			  return T_INT_LIT;
			}

{integer}\.{integer}{exp}?		{
			  int length;
			  char num_string [256];

			  sc_real (yytext, num_string);
			  length = sc_strlen (num_string);
			  yylval. p_char = (char *) alloc_lit (S_REALLIT, num_string, length);
			  return T_REAL_LIT;
			}

{letter}+		{
			  if ( (resw_index = srch_resw (yytext)) >= 0)
			     { yylval. f_int = resw_index;
			       return (resw_index);
			     }
			  else
			     { yylval. p_char =(char *)mk_tag (yytext, yyleng);
			       return (T_IDENT);
			     }
			}

"$"("_"?({letter}|{digit}))*		{
			  yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_IDENT);
			}

{letter}("_"?({letter}|{digit}))*	{
			  yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_IDENT);
			}


"="			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_RELOP);
			}

"/="			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_RELOP);
			}

"<"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_RELOP);
			}

">"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_RELOP);
			}

"<="			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_RELOP);
			}

">="			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_RELOP);
			}

"+"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_PLUS);
			}

"-"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_MINUS);
			}

"&"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_AMP);
			}

"*"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_MULT);
			}

"/"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_DIV);
			}

"**"			{ yylval. p_char =(char *)mk_tag (yytext, yyleng);
			  return (T_EXP);
			}

"|"			{ return (T_BAR); }

":="			{ return (T_AS); }

";"			{ return (T_SEM_COL); }

":"			{ return (T_COLON); }

"."			{ return (T_DOT); }

","			{ return (T_COMMA); }

"'"			{ return (T_QUOTE); }

".."			{ return (T_DD); }

"("			{ return (T_LP); }

")"			{ return (T_RP); }

"=>"			{ return (T_ARROW); }

"<<"			{ return (T_LS); }

">>"			{ return (T_LF); }

"<>"			{ return (T_BOX); }

\"([^\"\n]|(\"\"))*\"	{ if (yyleng > MAX_STR)
			     { scan_error ("string too long");
			       yyleng = MAX_STR;
			     }
/*
 *	Note that stringquotes are deleted here
 */
			 yylval. p_char =
			      (char *) alloc_lit (S_STRINGLIT, &yytext[1], yyleng - 2);
			  return (T_CHAR_STRING);
			}

'.'			{
			  yylval. f_int = (int) yytext [1];
			  return (T_CHAR_LIT);
			}
'\\{digit}{digit}{digit}'	{ yytext [5] = '\0';
			  yylval. f_int = ((int) (yytext [2]) - '0') * 64 +
			           (yytext [3] - '0') * 8 +
				    yytext [4] - '0';
			  return T_CHAR_LIT;
			}

"--".*			;

"\n"			yylineno++;

{TAB}			;


.			;
%%
/*
 *	USER TABLES AND ROUTINES
 */

struct	resword	res_word [] = {
	"ABORT",	T_ABORT,
	"ABS",		T_ABS,
	"ACCEPT",	T_ACCEPT,
	"ACCESS",	T_ACCESS,
	"ALL",		T_ALL,
	"AND",		T_AND,
	"ARRAY",	T_ARRAY,
	"AT",		T_AT,
	"BEGIN",	T_BEGIN,
	"BODY",		T_BODY,
	"CASE",		T_CASE,
	"CONSTANT",	T_CONSTANT,
	"DECLARE",	T_DECLARE,
	"DELAY",	T_DELAY,
	"DELTA",	T_DELTA,
	"DIGITS",	T_DIGITS,
	"DO",		T_DO,
	"ELSE",		T_ELSE,
	"ELSIF",	T_ELSIF,
	"END",		T_END,
	"ENTRY",	T_ENTRY,
	"EXCEPTION",	T_EXCEPTION,
	"EXIT",		T_EXIT,
	"FOR",		T_FOR,
	"FUNCTION",	T_FUNCTION,
	"GENERIC",	T_GENERIC,
	"GOTO",		T_GOTO,
	"IF",		T_IF,
	"IN",		T_IN,
	"IS",		T_IS,
	"LIMITED",	T_LIMITED,
	"LOOP",		T_LOOP,
	"MOD",		T_MOD,
	"NEW",		T_NEW,
	"NOT",		T_NOT,
	"NULL",		T_NULL,
	"OF",		T_OF,
	"OR",		T_OR,
	"OTHERS",	T_OTHERS,
	"OUT",		T_OUT,
	"PACKAGE",	T_PACKAGE,
	"PRAGMA",	T_PRAGMA,
	"PRIVATE",	T_PRIVATE,
	"PROCEDURE",	T_PROCEDURE,
	"RAISE",	T_RAISE,
	"RANGE",	T_RANGE,
	"RECORD",	T_RECORD,
	"REM",		T_REM,
	"RENAMES",	T_RENAMES,
	"RETURN",	T_RETURN,
	"REVERSE",	T_REVERSE,
	"SELECT",	T_SELECT,
	"SEPARATE",	T_SEPARATE,
	"SUBTYPE",	T_SUBTYPE,
	"TASK",		T_TASK,
	"TERMINATE",	T_TERMINATE,
	"THEN",		T_THEN,
	"TYPE",		T_TYPE,
	"USE",		T_USE,
	"WHEN",		T_WHEN,
	"WHILE",	T_WHILE,
	"WITH",		T_WITH,
	"XOR",		T_XOR
};

static	int resw_index ;
static	int attr_index;
extern	FILE *yyin;
