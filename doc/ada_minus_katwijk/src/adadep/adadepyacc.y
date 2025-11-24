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
 * parser for output of adaparse,
 * uses adadeplex.l as scanner
 * parser recognizes full intermediate structure
 * change actions for each other purpose
 *
 * Ton Biegstraaten dutinfd!abi  24-3-87
 */

%token NOCONTEXT
%token WITH
%token LOCAL
%token UNIT
%token SUBPRSPEC
%token PACKSPEC
%token GENERICSPEC
%token GENERICINSTAN
%token SUBPRBODY
%token PACKBODY
%token TASKBODY
%token PARNAME
%token PROCEDURE
%token FUNCTION
%token RENAME
%token DECLARE
%token SUBUNIT
%token GENERIC
%token TASKSPEC
%token STUB
%token SOURCEFILE
%token IDENT

%{
#include "adadep.h"
char sfname[FNAMESIZE];
%}

%%
Compilation	:	CompilationUnit
		|	Compilation CompilationUnit
		;

CompilationUnit	:	SourceFileInd ContextClause Unit
		;

SourceFileInd	:	SOURCEFILE ident =	/* source file name */
			{
			    strcpy (sfname, $2);
			    add_sfunit (sfname);
			}
		|	/* EMPTY */
		;

ContextClause	:	NOCONTEXT =
			{
			    new_unit ();
			}
		|	WithUnits
		;

WithUnits	:	WITH ident =
			{
			    new_unit ();
			    add_wlist ($2);
			}
		|	WithUnits WITH ident =
			{
			    add_wlist ($3);
			}
		;

ident		:	IDENT = $$ = (int) identstr;
		;

Unit		:	StartUnit LocalUnits EndUnit
		|	StartUnit EndUnit
		;

Spec		:	FUNCTION = nflags = NO_CHANGE; /* back patching only
							  on global level */
		|	PROCEDURE = nflags = NO_CHANGE;
		|	SUBPRBODY = nflags = SB;
		|	SUBPRSPEC = nflags = SS;
		|	PACKSPEC = nflags = PS;
		|	TASKSPEC = nflags = TS;
		;

Body		:	PACKBODY = nflags = PB;
		|	TASKBODY = nflags = TB;
		;

StartUnit	:	Spec ident = add_uname ( $2, nflags);
		|	GENERIC Spec ident = add_uname ($3, nflags | GNRC);
		|	Body ident = add_uname ($2, nflags);
		|	FullParName Spec ident = add_uname ($3, nflags | SU);
		|	FullParName Body ident = add_uname ($3, nflags | SU);
		;

LStartUnit	:	Spec ident = $$ = $2;
		|	GENERIC Spec ident = $$ = $3;
		|	GENERICINSTAN ident = $$ = $2;
		|	Body ident = $$ = $2;
		;

FullParName 	:	ParName
		|	FullParName ParName
		;

ParName 	:	PARNAME ident = add_parlist ($2);
		;

		/*
		 * for generics and local procedures info is known afterwards
		 * and kinds should be adjusted.
		 * In other cases it does not matter
		 */
EndUnit		:	UNIT UnitKind = adj_kind ($2);
		|	SUBUNIT UnitKind = adj_kind ($2);
		;

UnitKind	:	SUBPRSPEC = $$ = SS;
		|	PACKSPEC = $$ = NO_CHANGE;
		|	GENERICSPEC = $$ = NO_CHANGE;
		|	GENERICINSTAN = $$ = GI;
		|	SUBPRBODY = $$ = SB;
		|	PACKBODY = $$ = PB;
		|	TASKBODY = $$ = TB;
		|	TASKSPEC = $$ = NO_CHANGE;
		;

LocalUnits	:	LocalUnit
		|	LocalUnits LocalUnit
		;

LocalUnit	:	LStartUnit LocalUnits EndLocalUnit
		|	LStartUnit EndLocalUnit = stub_spec ($1, $2);
		|	DECLARE
		;

EndLocalUnit	:	LOCAL UnitKind = $$ = NO_CHANGE;
		|	LOCAL UnitKind STUB = $$ = $2 | SU;
		|	RENAME = $$ = NO_CHANGE;
		|	DECLARE ident = $$ = NO_CHANGE;
		;
%%
#include "adadeplex.c"

