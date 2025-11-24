# include "stdio.h"
# define U(x) x
# define NLSTATE yyprevious=YYNEWLINE
# define BEGIN yybgin = yysvec + 1 +
# define INITIAL 0
# define YYLERR yysvec
# define YYSTATE (yyestate-yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,yyout)
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
# define unput(c) {yytchar= (c);if(yytchar=='\n')yylineno--;*yysptr++=yytchar;}
# define yymore() (yymorfg=1)
# define ECHO fprintf(yyout, "%s",yytext)
# define REJECT { nstr = yyreject(); goto yyfussy;}
int yyleng; extern char yytext[];
int yymorfg;
extern char *yysptr, yysbuf[];
int yytchar;
FILE *yyin = {stdin}, *yyout = {stdout};
extern int yylineno;
struct yysvf { 
	struct yywork *yystoff;
	struct yysvf *yyother;
	int *yystops;};
struct yysvf *yyestate;
extern struct yysvf yysvec[], *yybgin;
# define STRINGCOMING 2
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:
{
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
break;
case 2:
{
		BEGIN 0;
		if (debuglex) printf("LEX: <STRINGCOMING> string detected\n");
		strcpy(yylval.sval,yytext);
		/* discard newline in yylval! */
		yylval.sval[ yyleng-1 ] = '\0';
		/* put it back on the input */
		unput('\n');
		return(STR);
		}
break;
case 3:
{
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
break;
case 4:
	{
		if (!dimlistsize) REJECT;
		sscanf(yytext,"%d",&yylval.ival);
		if (debuglex) 
			printf("LEX: DIMENSION %d detected\n",yylval.ival);
		return(DIMENSION);
		}
break;
case 5:
	{
		sscanf(yytext,"%d",&yylval.ival);
		if (debuglex) 
			printf("LEX: BYTE %d detected\n",yylval.ival);
		return(BYTE);
		}
break;
case 6:
	{
		if (debuglex) printf("LEX: [ detected\n");
		return(LBRACKET);
		}
break;
case 7:
	{
		if (debuglex) printf("LEX: ] detected\n");
		return(RBRACKET);
		}
break;
case 8:
	{
		if (debuglex) printf("LEX: ) detected\n");
		BEGIN STRINGCOMING;
		return(RPAREN);
		}
break;
case 9:
		{
		/* Detect DOT only on first position on a line.
		   Otherwise, it will be part of a STR. */
		if (debuglex) printf("LEX: DOT detected\n");
		return(DOT);
		}
break;
case 10:
{
		strcpy(yylval.sval,yytext);
		if (debuglex) 
			printf("LEX: string detected:\"%s\"\n",yylval.sval);
		return(STR);
		}
break;
case 11:
	;
break;
case -1:
break;
default:
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */
int yyvstop[] = {
0,

11,
0,

11,
0,

10,
0,

8,
0,

3,
4,
5,
10,
0,

6,
0,

7,
0,

11,
0,

2,
11,
0,

10,
0,

8,
0,

3,
4,
5,
10,
0,

6,
0,

7,
0,

9,
0,

1,
0,

3,
0,

2,
0,

1,
0,

3,
0,

1,
0,

1,
0,
0};
# define YYTYPE char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	1,0,	1,0,	
1,0,	1,0,	1,0,	1,0,	
1,0,	1,0,	1,5,	1,6,	
1,0,	1,0,	1,0,	1,0,	
1,0,	1,0,	1,0,	1,0,	
1,0,	1,0,	1,0,	1,0,	
1,0,	1,0,	1,0,	1,0,	
1,0,	1,0,	1,0,	1,0,	
1,0,	28,31,	1,0,	1,7,	
1,0,	1,0,	1,0,	1,8,	
1,0,	1,0,	1,9,	1,0,	
1,0,	1,0,	1,10,	31,31,	
0,0,	1,11,	25,30,	4,18,	
0,0,	17,17,	4,19,	0,0,	
6,24,	21,17,	4,20,	1,0,	
1,0,	1,0,	1,0,	1,0,	
1,0,	1,0,	14,14,	17,17,	
18,28,	20,29,	3,14,	21,21,	
28,28,	25,30,	14,14,	14,27,	
29,29,	30,30,	3,15,	3,16,	
8,25,	8,25,	8,25,	8,25,	
8,25,	8,25,	8,25,	8,25,	
8,25,	8,25,	0,0,	0,0,	
1,12,	1,0,	1,13,	1,0,	
0,0,	1,0,	0,0,	14,14,	
30,30,	0,0,	0,0,	3,17,	
4,22,	0,0,	4,23,	3,18,	
0,0,	0,0,	3,19,	0,0,	
0,0,	14,14,	3,20,	0,0,	
0,0,	3,21,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
1,0,	1,0,	1,0,	1,0,	
1,0,	2,0,	2,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
2,0,	0,0,	0,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
3,22,	2,0,	3,23,	2,0,	
2,0,	2,0,	2,8,	2,0,	
2,0,	2,9,	2,0,	2,0,	
2,0,	2,10,	10,26,	10,26,	
10,26,	10,26,	10,26,	10,26,	
10,26,	10,26,	10,26,	10,26,	
0,0,	0,0,	2,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
2,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	2,12,	
2,0,	2,13,	2,0,	0,0,	
2,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	2,0,	
2,0,	2,0,	2,0,	2,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,7,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
7,0,	0,0,	0,0,	7,7,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	7,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	7,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	7,0,	7,0,	
7,0,	7,0,	0,0,	7,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	7,0,	7,0,	
7,0,	7,0,	7,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
0,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	11,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
11,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	11,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	11,0,	11,0,	11,0,	
11,0,	0,0,	11,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	11,0,	11,0,	11,0,	
11,0,	11,0,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
yycrank+-1,	0,		0,	
yycrank+-128,	yysvec+1,	0,	
yycrank+-69,	0,		0,	
yycrank+-13,	yysvec+3,	0,	
yycrank+0,	0,		yyvstop+1,
yycrank+10,	0,		yyvstop+3,
yycrank+-255,	0,		yyvstop+5,
yycrank+32,	0,		0,	
yycrank+0,	0,		yyvstop+7,
yycrank+126,	0,		0,	
yycrank+-382,	yysvec+1,	yyvstop+9,
yycrank+0,	0,		yyvstop+14,
yycrank+0,	0,		yyvstop+16,
yycrank+-65,	0,		0,	
yycrank+0,	yysvec+14,	yyvstop+18,
yycrank+0,	yysvec+6,	yyvstop+20,
yycrank+-19,	yysvec+14,	yyvstop+23,
yycrank+-20,	yysvec+14,	0,	
yycrank+0,	yysvec+14,	yyvstop+25,
yycrank+-21,	yysvec+14,	0,	
yycrank+-23,	yysvec+14,	yyvstop+27,
yycrank+0,	yysvec+14,	yyvstop+32,
yycrank+0,	yysvec+14,	yyvstop+34,
yycrank+0,	0,		yyvstop+36,
yycrank+41,	yysvec+8,	yyvstop+38,
yycrank+0,	yysvec+10,	yyvstop+40,
yycrank+0,	0,		yyvstop+42,
yycrank+-24,	yysvec+14,	yyvstop+44,
yycrank+-28,	yysvec+14,	yyvstop+46,
yycrank+68,	0,		yyvstop+48,
yycrank+-38,	yysvec+14,	yyvstop+50,
0,	0,	0};
struct yywork *yytop = yycrank+509;
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,'"' ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,'"' ,'"' ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,
'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,
'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,
'"' ,'"' ,'"' ,01  ,01  ,01  ,01  ,'"' ,
01  ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,
'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,
'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,'"' ,
'"' ,'"' ,'"' ,01  ,01  ,01  ,01  ,01  ,
0};
char yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
char _Module_Version[] = "\0@\0@\0@\0@\0@\0@\0@@(#) 87.2 Module: languages, Part: ncform. ACE (c)";
char _Host_Version[] = "@(#) Host: dutch, Target: gmx-mc68020-complibr.DESCR-\
		\n@(#) Date: Sat Aug 22 13:59:20 1987";
# define	VUFIX1		true
/*
 *	Because  the  program  generated by LEX contained
 *	two bad pointer comparisons,  causing wild memory
 *	references, and random matches if it is misplaced
 *	in  core,  the  casts  leading to these disasters
 *	were removed by Marcel Dekker VU Sep 1980.
 *	Because   this   may   lead  to  some  other  bad
 *	comparisons,  the  pointers  are first reduced to
 *	the integers they have to be.
 */


int yylineno =1;
# define YYU(x) x
# define NLSTATE yyprevious=YYNEWLINE
char yytext[YYLMAX];
struct yysvf *yylstate [YYLMAX], **yylsp, **yyolsp;
char yysbuf[YYLMAX];
char *yysptr = yysbuf;
int *yyfnd;
extern struct yysvf *yyestate;
int yyprevious = YYNEWLINE;
# ifdef LEXDEBUG
	int debug;
# endif

yylook(){
	register struct yysvf *yystate, **lsp;
	register struct yywork *yyt;
	struct yysvf *yyz;
	int yych, yyfirst;
	struct yywork *yyr;
	char *yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	yyfirst=1;
	if (!yymorfg)
		yylastch = yytext;
	else {
		yymorfg=0;
		yylastch = yytext+yyleng;
		}
	for(;;){
		lsp = yylstate;
		yyestate = yystate = yybgin;
		if (yyprevious==YYNEWLINE) yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(yyout,"state %d\n",yystate-yysvec-1);
# endif
			yyt = yystate->yystoff;
			if(yyt == yycrank && !yyfirst){  /* may not be any transitions */
				yyz = yystate->yyother;
				if(yyz == 0)break;
				if(yyz->yystoff == yycrank)break;
				}
			*yylastch++ = yych = input();
			yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"char ");
				allprint(yych);
				putchar('\n');
				}
# endif
			yyr = yyt;
# ifndef VUFIX1
			if ( (int)yyt > (int)yycrank){
# else
			/* Now the casts are harmless: both are */
			/* (converted to) the appropriate int.  */
			if ((int) (yyt - yycrank) > (int) 0) {
# endif
				yyt = yyr + yych;
				if (yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
# ifndef VUFIX1
			else if((int)yyt < (int)yycrank) {		/* r < yycrank */
# else
			else if((yyt - yycrank) < 0) {		/* r < yycrank */
# endif
				yyt = yyr = yycrank+(yycrank-yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"compressed state\n");
# endif
				yyt = yyt + yych;
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				yyt = yyr + YYU(yymatch[yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"try fall back character ");
					allprint(YYU(yymatch[yych]));
					putchar('\n');
					}
# endif
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transition */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
			if ((yystate = yystate->yyother) && (yyt= yystate->yystoff) != yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"fall back to state %d\n",yystate-yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"state %d char ",yystate-yysvec-1);
				allprint(yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(yyout,"stopped at %d with ",*(lsp-1)-yysvec-1);
			allprint(yych);
			putchar('\n');
			}
# endif
		while (lsp-- > yylstate){
			*yylastch-- = 0;
			if (*lsp != 0 && (yyfnd= (*lsp)->yystops) && *yyfnd > 0){
				yyolsp = lsp;
				if(yyextra[*yyfnd]){		/* must backup */
					while(yyback((*lsp)->yystops,-*yyfnd) != 1 && lsp > yylstate){
						lsp--;
						unput(*yylastch--);
						}
					}
				yyprevious = YYU(*yylastch);
				yylsp = lsp;
				yyleng = yylastch-yytext+1;
				yytext[yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"\nmatch ");
					sprint(yytext);
					fprintf(yyout," action %d\n",*yyfnd);
					}
# endif
				return(*yyfnd++);
				}
			unput(*yylastch);
			}
		if (yytext[0] == 0  /* && feof(yyin) */)
			{
			yysptr=yysbuf;
			return(0);
			}
		yyprevious = yytext[0] = input();
		if (yyprevious>0)
			output(yyprevious);
		yylastch=yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
yyback(p, m)
	int *p;
{
if (p==0) return(0);
while (*p)
	{
	if (*p++ == m)
		return(1);
	}
return(0);
}
	/* the following are only used in the lex library */
yyinput(){
	return(input());
	}
yyoutput(c)
  int c; {
	output(c);
	}
yyunput(c)
   int c; {
	unput(c);
	}
