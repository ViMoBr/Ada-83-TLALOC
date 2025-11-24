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
 * main program for adaparse
 * The program accepts stdin but the result is useless for generating
 * compilation commands(adadep) because the sourcefile is unknown.
 * A superset of Ada is accepted and the structure of the input is placed
 * on stdout.
 *
 * Ton Biegstraaten, dutinfd!abi 24-3-87
 */
#include <stdio.h>

char source_name[100];
int yylineno;
extern char yytext[];
extern int globalf;

main (argc, argv)
int argc;
char **argv;
{
    argv++;
    if (argc-- == 1)
    {
	printf ("SF: -\n");
	parse ();
    }
    else
    while (argc--)
    {
        if ((*argv)[0] == '-')
        {
            switch ((*argv)[1])
            {
            case 'l':
                globalf = 0;
                break;
            
            default:
                fprintf (stderr, "illegal flag %c\n", (*argv)[1]);
                exit (1);
            }
            if (argc == 0)
            {
	        printf ("SF: -\n");
        	parse ();
        	break;
            }
        }
        else
        {
	    if (freopen (*argv, "r", stdin) == NULL)
	    {
	        fprintf (stderr, "file %s not open\n", *argv);
	        exit (1);
	    }
	    printf ("SF: %s\n", *argv);
	    strcpy (source_name, *argv);
	    parse ();
        }
	argv++;
    }
}

parse ()
{
    yylineno = 1;
    return(yyparse());
}

yyerror(s)
char *s;
{
    fprintf (stderr, "%s: %s on line %d, text is `%s'\n", source_name, s, yylineno, yytext);
}
