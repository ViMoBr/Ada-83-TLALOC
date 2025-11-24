
digit		[0-9]
letter		[a-zA-Z_]
ext_letter	({letter}|{digit}|_)
TAB		[ \t\n]
integer		({digit}("_"?{digit})*)
%%
%{
static	char	*resword;
%}

\#.*			;

{integer}		{ yylval = mk_tag (yytext, yyleng);
			  return NUMBER;
			}

"struct"		{ return XRECORD; }

"union"			{ return XUNION;  }

{letter}{ext_letter}*	{ yylval = mk_tag (yytext, yyleng);
		          return IDENT;
			}

"\*"			{ return STARREF; }

";"			{ return (SEMCOL); }

","			{ return COMMA; }

"{"			{ return LBRACK; }

"}"			{ return RBRACK; }

"["			{ return SUB; }

"]"			{ return BUS; }

"/*".*"*/"		;

{TAB}			;

"\n"			line_no++;

%%
