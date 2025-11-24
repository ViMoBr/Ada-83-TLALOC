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
 * Yacc parser for a superset of Ada
 * Its purpose is to produce the overall procedure/function/package etc
 * structure of the Ada program.
 * The output is ascii on stdout and is used for deriving a correct
 * compilation sequence of the parsed Ada programs.
 * It can also be used for any purpose which needs the overall structure
 * of Ada programs, f.e the debugger.
 *
 * Ton Biegstraaten   dutinfd!abi
 * 25-3-1987
 */

%token	IDENT
%token	SEM_COL
%token	COLON
%token	COMMA
%token	WITH
%token	USE
%token	PROCEDURE
%token	FUNCTION
%token	RETURN
%token	PACKAGE
%token	BODY
%token	TASK
%token	IS
%token	ISNEW
%token	LRP
%token	RP
%token	SEPARATE
%token	SEP_LP
%token 	DOT
%token	DECLARE
%token	BEGN
%token	END
%token	TYPE
%token	RENAMES
%token	GENERIC
%token	RECORD
%token	CASE
%token	IF
%token	LOOP
%token	SELECT
%token	DO
%{
char labelstr[50];
/*
 * For procedures or functions it is not known in advance if it is a
 * body or specification, so information is back-patched.
 * All output is kept in an array and written out after the end of each
 * library unit has been seen.
 */
char outbuf[10000] = {0}, t_out[50];
int back_patch = 0, globalf = 1, begin_unit = 1;
%}
%%
Compilation	:	CompilationUnit
		|	Compilation CompilationUnit
		;

CompilationUnit	:	ContextClause Unit =
			{
			    back_patch = 0;
                            begin_unit = 1;
			}
		;

Unit		:	LibraryUnit
		|	LibraryUnitBody
		|	Subunit
		;

ContextClause	:	/* empty */ =
			{
			    sprintf (t_out,"NC:\n");
			    strcat (outbuf, t_out);
			}
		|	WithUseList
		;

WithUseList 	:	WithUse SEM_COL 
		|	WithUseList WithUse SEM_COL 
		;

WithUse 	:	WithClause 
		|	UseClause 
		;

WithClause 	:	WITH IDENT =
			{
			    sprintf (t_out,"W: %s\n", identstr);
			    strcat (outbuf, t_out);
			}
		|	WithClause COMMA IDENT
			{
			    sprintf (t_out,"W: %s\n", identstr);
			    strcat (outbuf, t_out);
			}
		;

UseClause 	:	USE IDENT
		|	UseClause COMMA IDENT
		;

LibraryUnit 	:	SubprSpec SEM_COL =
			{
			    if (back_patch)
			    {
			        outbuf [back_patch] = 'S';
			        back_patch = 0;
			    }    	
			    sprintf (t_out,"U: SS:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		|	PackageSpec SEM_COL =
			{
			    sprintf (t_out,"U: PS:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		|	GenericSpec SEM_COL =
			{
			    sprintf (t_out,"U: GS:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		|	GenericInstan =
			{
			    sprintf (t_out,"U: GI:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		|	SubprBody =
			{
			    if (back_patch)
			    {
			        outbuf [back_patch] = 'B';
			        back_patch = 0;
			    }
			    sprintf (t_out,"U: SB:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		;

LibraryUnitBody	:	/* SubprBody alleen wanneer een spec geweest is */
			PackageBody =
			{
			    sprintf (t_out,"U: PB:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		;

Subunit		:	SEP_LP par_path RP PSTBody
		;

PSTBody		:	PackageBody =
			{
			    sprintf (t_out,"SU: PB:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		|	SubprBody =
			{
			    if (back_patch)
			    {
			        outbuf [back_patch] = 'B';
			        back_patch = 0;
			    }
			    sprintf (t_out,"SU: SB:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
 			}
		|	TaskBody =
			{
			    sprintf (t_out,"SU: TB:\n");
			    strcat (outbuf, t_out);
			    printf (outbuf);
			    outbuf[0] = 0;
			}
		;

par_path	:	IDENT =
			{
			    sprintf (t_out,"SN: %s\n", identstr);
			    strcat (outbuf, t_out);
			}
		| 	par_path DOT IDENT =
			{
			    sprintf (t_out,"SN: %s\n", identstr);
			    strcat (outbuf, t_out);
			}
		;
	
SubprName	:	PROCEDURE IDENT =
			{
			    if (begin_unit || !globalf)
			    {
			        if (back_patch == 0)
			            back_patch = strlen (outbuf) + 1;
			        sprintf (t_out,"S : %s\n", identstr);
			        strcat (outbuf, t_out);
			        begin_unit = 0;
			    }
			}
		|	FUNCTION IDENT =
			{
			    if (begin_unit || !globalf)
			    {
			        if (back_patch == 0)
			            back_patch = strlen (outbuf) + 1;
			        sprintf (t_out,"F : %s\n", identstr);
			        strcat (outbuf, t_out);
			        begin_unit = 0;
			    }
			}
		;

SubprSpec	:	SubprName
		|	SubprName LRP
		|	SubprName RETURN IDENT
		|	SubprName LRP RETURN IDENT
		;

SubprBody	:	SubprSpec IS DecltivePart Block =
		;

Block		:	BEGN SeqOfStmts EndId SEM_COL
		;

EndId		:	END
		|	END IDENT
		;

PackIdent	:	PACKAGE IDENT =
			{
			    if (begin_unit || !globalf)
			    {
			        sprintf (t_out,"PS: %s\n", identstr);
			        strcat (outbuf, t_out);
			        begin_unit = 0;
			    }
			}
		;

PackBodyIdent	:	PACKAGE BODY IDENT =
			{
			    if (begin_unit || !globalf)
			    {
			        sprintf (t_out,"PB: %s\n", identstr);
			        strcat (outbuf, t_out);
			        begin_unit = 0;
			    }
			}
		;

PackageSpec	:	PackIdent IS DecltivePart EndId
		;

PackageBody	:	PackBodyIdent IS DecltivePart Block
		|	PackBodyIdent IS DecltivePart EndId SEM_COL
		;

GenericInstan	:	SubprName ISNEW SelCompName LRP SEM_COL
		|	PackIdent ISNEW SelCompName LRP SEM_COL
		;

SelCompName	:	IDENT
		|	SelCompName DOT IDENT
		;

Generic		:	GENERIC =
			{
			    if (begin_unit || !globalf)
			    {
			        sprintf (t_out,"GN:");
			        strcat (outbuf, t_out);
				/* begin_unit hier NIET 0 zetten er volgt meer */
			    }
			}
		;

GenericSpec	:	Generic GenJunk SubprSpec
		|	Generic GenJunk PackageSpec
		;

TaskIdent	:	TASK IDENT =
			{
                            if (!globalf)
                            {
			        sprintf (t_out,"TS: %s\n", identstr);
			        strcat (outbuf, t_out);
			    }
			}
		|	TASK TYPE IDENT =
			{
                            if (!globalf)
                            {
			        sprintf (t_out,"TS: %s\n", identstr);
			        strcat (outbuf, t_out);
			    }
			}
		;

TaskSpec	:	TaskIdent IS DecltivePart EndId
		|	TaskIdent
		;

TaskBodyIdent	:	TASK BODY IDENT =
			{
                            if (!globalf || begin_unit)
                            {
			        sprintf (t_out,"TB: %s\n", identstr);
			        strcat (outbuf, t_out);
			        begin_unit = 0;
			    }
			}
		;

TaskBody	:	TaskBodyIdent IS DecltivePart Block
		;

DecltivePart	:	BasDeclItems
		|	/* Empty */
		;

BasDeclItems	:	BasDeclItem
		|	BasDeclItems BasDeclItem
		;

BasDeclItem	:	SubprSpec SEM_COL =
                        {
                            if (!globalf)
                            {
			        sprintf (t_out,"L: SS:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	TaskSpec SEM_COL =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: TS:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	PackageSpec SEM_COL =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: PS:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	GenericInstan =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: GI:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	GenericSpec SEM_COL =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: GS:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	UseClause SEM_COL
		|	Body
		|	PackIdent RENAMES  =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"R:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	SubprSpec RENAMES =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"R:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	BasJunk		/* a superset indeed */
		;

Body		: 	PackageBody =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: PB:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	SubprBody =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: SB:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	TaskBody =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: TB:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	PackBodyIdent Stub =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: PB: ST:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	TaskBodyIdent Stub =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: TB: ST:\n");
			        strcat (outbuf, t_out);
			    }
			}
		|	SubprSpec Stub =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"L: SB: ST:\n");
			        strcat (outbuf, t_out);
			    }
			}
		;

Stub		:	IS SEPARATE SEM_COL
		;

/*
 * Is no Ada anymore
 */
GenJunk		:	BasJunk
		|	GenJunk	BasJunk	
		;

BasJunk		:	RENAMES
		|	TYPE
		|	WITH PROCEDURE
		|	WITH FUNCTION IDENT RETURN IDENT SEM_COL
		|	WITH FUNCTION IDENT LRP RETURN IDENT SEM_COL
		|	ISNEW
		|	LRP
		|	RECORD SeqOfStmts END RECORD SEM_COL
		|	IDENT
		|	SEM_COL
		|	COLON =
			{
			    if (!globalf)
			    {
			        /* bewaar laaste IDENT , kan declare label zijn */
			        strcpy (labelstr, identstr);
			    }
			}
		|	COMMA
		|	DOT
		|	IS
		;


SeqOfStmts	:	sJunk
		|	SeqOfStmts sJunk
		;

Declare		:	DECLARE =
			{
			    if (!globalf)
			    {
			        sprintf (t_out,"D: ");
			        strcat (outbuf, t_out);
			        if (strcmp (identstr, labelstr) == 0)
			        {
				    sprintf (t_out,"%s\n", labelstr);
				    strcat (outbuf, t_out);
			        }
			        else
			        {
				    sprintf (t_out,"\n");
				    strcat (outbuf, t_out);
			        }
			    }
			}
		;

sJunk		:	BasJunk
		|	RETURN
		|	Declare DecltivePart Block
		|	CASE SeqOfStmts END CASE SEM_COL
		|	IF SeqOfStmts END IF SEM_COL
		|	LOOP SeqOfStmts END LOOP SEM_COL
		|	LOOP SeqOfStmts END LOOP IDENT SEM_COL
		|	SELECT SeqOfStmts END SELECT SEM_COL
		|	DO SeqOfStmts EndId SEM_COL 
		|	Block
		;

%%
#include "adaparselex.c"
