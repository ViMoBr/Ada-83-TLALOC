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
 * Main program to compute dependencies between the ada sources in the input
 * and when specified, the program library.
 * The program will normally result in a dependency list on stderr,
 * and a list of compilation statements on stdout.
 * A program library can be specified (-p <program library>). Missing
 * compilation units should be found in that library, otherwise resulting in
 * an error message. When no program library is specified, it is
 * the responsibility of the user that the compiler finds the missing units
 * in the library.
 * adadep2.c is the module for library access.
 * Giving the -m <makefilename> flag, the program searches the library
 * and generates only compile statements for invalid units.
 *
 * The program generates compile statements, so a format must be specified.
 * A default format is given, but using the -c <format> flag
 * makes it possible to specify a format, e.g. -c 'ac %s'.
 * the program includes the sourcefile name i.s.o. the '%s' and a \n is
 * appended.
 * The program only (re)compiles, and generates no executables.
 * Because adaparse as well as adadep are filters all kinds of extension
 * are possible.
 */
 
#include <stdio.h>
#include "adadep.h"


int yylineno;        /* line number for the parser */
extern char yytext[];
#define NAMESIZE 14
#define LNAMESIZE 50
char compile_com[LNAMESIZE] = "ac -v ";
#define FALSE 0
#define TRUE 1
int make = FALSE;
char library[NAMESIZE] = {0};

main (argc, argv)
int argc;
char **argv;
{
    char flag;
    int argc0 = argc -1;      /* counter for non file arguments */
        
    while (argc)
    {
        argv++;
        argc--;

        if (argc0)
        {
            if (argc == 0)
                continue;
                
            if (argv[0][0] == '-')
            {
                flag = argv[0][1];
                argc0--;
                /* non argument flags */
                if (flag == 'm')
                {
                    make = TRUE;
                    continue;
                }
                /* flags with one argument */
                argc--;
                argc0--;
                argv++;
                
                if (argc == 0)
                {
                    fprintf (stderr, "No argument for flag %c\n", flag);
                    exit ();
                }
                
                switch (flag)
                {
                case 'p':
                        strncpy (library, *argv, NAMESIZE);
                        make = TRUE;
                        break;
                case 'c':
                        strncpy (compile_com, *argv, LNAMESIZE);
                        break;
                default:
                         fprintf (stderr, "Illegal flag %c\n", flag);
                         exit ();
                }                    
                continue;
            }
            /* no flag so it must be a file, open it*/
            if (freopen (*argv, "r", stdin) == NULL)
            {
                fprintf (stderr, "file %s not open\n", *argv);
                exit (1);
            }
        }
        parse ();
    }
    
/*    print_structuur ();    /* for debugging*/
    
            
/*
 * Make the dependency tree complete by visiting the library
 * when make is FALSE all sources should be recompiled, when TRUE
 * only what's necessary should be recompiled
 */
    search_library (library, make);
/*    print_structuur ();    /* for debugging*/

    if (compilation)
        gen_commands ();
    else
        fprintf (stderr, "compilation not possible\n");
}

parse ()
{
    yylineno = 1;
    return(yyparse());
}

yyerror(s)
char *s;
{
    fprintf (stderr, "%s on line %d, yytext %s\n", s, yylineno, yytext);
}
