%START STRINGCOMING
%%

&[0-9]+[\t ]*	{
		/* detects IC codes */
		sscanf(yytext,"&%d",&yylval.ival);
		if (debuglex) printf("LEX: &%d detected\n",yylval.ival);
		switch (yylval.ival)
			{
			case 30:/* ICSTRING */
			case 37:/* ICFILE */
			case 50:/* ICFLOAT */
			case 51:/* ICDOUBLE */
				BEGIN STRINGCOMING;
				break;
			}
		return(ICCODE);
		}



<STRINGCOMING>.*\n {
		BEGIN 0;
		if (debuglex) printf("LEX: <STRINGCOMING> string detected\n");
		strcpy(yylval.sval,yytext);
		/* discard newline in yylval! */
		yylval.sval[ yyleng-1 ] = '\0';
		/* put it back on the input */
		unput('\n');
		return(STR);
		}


"-"?[0-9]+	{
		BEGIN 0;
		if (dimlistsize || bytelistsize) REJECT; 
		sscanf(yytext,"%d",&yylval.ival);
		if (debuglex) printf("LEX: NUMBER %d detected\n",yylval.ival);
		if (	yylval.ival==23 || /* andand */
			yylval.ival==24 || /* oror */
			yylval.ival==76 || /* not */
			(yylval.ival>=80 && yylval.ival<=89))  /* eq,gt etc. */
			return(CONDNUMBER);
		else 	return(NUMBER);
		   
		}


[0-9]+		{
		if (!dimlistsize) REJECT;
		sscanf(yytext,"%d",&yylval.ival);
		if (debuglex) 
			printf("LEX: DIMENSION %d detected\n",yylval.ival);
		return(DIMENSION);
		}

[0-9]+		{
		sscanf(yytext,"%d",&yylval.ival);
		if (debuglex) 
			printf("LEX: BYTE %d detected\n",yylval.ival);
		return(BYTE);
		}

"["		{
		if (debuglex) printf("LEX: [ detected\n");
		return(LBRACKET);
		}

"]"		{
		if (debuglex) printf("LEX: ] detected\n");
		return(RBRACKET);
		}

")"		{
		if (debuglex) printf("LEX: ) detected\n");
		BEGIN STRINGCOMING;
		return(RPAREN);
		}

\n"." 		{
		/* Detect DOT only on first position on a line.
		   Otherwise, it will be part of a STR. */
		if (debuglex) printf("LEX: DOT detected\n");
		return(DOT);
		}

[A-Za-z0-9".""_""/"]+ {
		strcpy(yylval.sval,yytext);
		if (debuglex) 
			printf("LEX: string detected:\"%s\"\n",yylval.sval);
		return(STR);
		}

[\n\t ]		;

