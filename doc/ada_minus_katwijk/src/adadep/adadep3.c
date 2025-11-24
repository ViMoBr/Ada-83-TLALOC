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
 * In this file routines are included that build from the unode
 * list a sourcefile dependency list and checks that each unit has
 * the correct sequence for compilation
 * Depending on the flags a makefile is or commands are generated.
 *
 * Ton Biegstraaten , dutinfd!abi 24-3-87
 */

#include <stdio.h> 
#include "adadep.h"


/*#define DEBUG
/**/
#ifdef DEBUG
#define PRINTF printf
#undef stderr
#define stderr stdout
#else
#define PRINTF dummy
static dummy ()
{
}
#endif
/*
 * sf_list is the head of the source file list,
 * cursfnode is de actuele datanode 
 */
struct sf_list sf_list, *p_sf_list = &sf_list;
struct sf_node *cursfnode, *give_sfptr();
extern struct unode_list unit_list;

/*
 * gen_commands : output of program is a sequence of compilation statement
 * on standard out, which should be piped to a shell
 */
gen_commands ()
{
    register struct sf_node *p_sf;
    register struct sf_list *p_sl;
    register struct sf_node *p_sf1;
    register struct sf_list *p_sl1;

    int compiled = 0;
    
    bc_src_list ();

    /*
     * continue only if compilation might be succesfull
     */
     
    if (compilation == FALSE)
    {
        fprintf (stderr, "compilation not possible\n");
        exit (1);
    }
             
    /*
     * this for loop can be omitted, it only gives detailed information
     * of dependencies to the user
     */

    for (p_sl =  sf_list .sl_next; p_sl; p_sl = p_sl -> sl_next)
    {
        p_sf = p_sl -> sl_node;
        if (p_sf -> sf_flags & UNIT_TEXT)
        {
            fprintf (stderr, "Source file %s", p_sf -> sf_name);
            if (p_sf -> sf_flags & COMP_VALID)
                fprintf (stderr, " will not be compiled\n");
            else
                fprintf (stderr, " will be compiled\n");
            
            for (p_sl1 = p_sf -> sf_dofirst .sl_next; p_sl1; p_sl1 = p_sl1 -> sl_next)
            {
                p_sf1 = p_sl1 -> sl_node;
                fprintf (stderr, "    Depends on %s\n", p_sf1 -> sf_name);
            }
        }
    }
    /*
     * determine the compilation sequence and give compile statements on
     * stdout
    */
    for (p_sl =  sf_list .sl_next; p_sl; p_sl = p_sl -> sl_next)
    {
        p_sf = p_sl -> sl_node;
        compiled |= do_compile (p_sf);
    }
    if (compiled)
      putchar ('\n');
}
/*
 * do_compile receives a source node. For each node in the do_first list
 * it calls itself. When no do_first list is available, de calls descends
 * until a unit is found that should be recompiled. From then on all units
 * must be recompiled
 */
static int ever_compiled = 0;

do_compile (p_sf)
register struct sf_node *p_sf;
{
    register struct sf_node *p_sfn;
    register struct sf_list *p_sl;
    int should_compile;
    
    PRINTF ("do_compile file %s\n", p_sf -> sf_name);
    if (p_sf -> sf_flags & VISITED)
        if (p_sf -> sf_flags & COMPILED)
            return TRUE;
        else
            return FALSE;
    
    /* check if source file is already in the path */
    if (p_sf -> sf_flags & IN_PATH)
    {
        fprintf (stderr, "source %s is cyclic dependent on itself\n",
            p_sf -> sf_name);
        exit (1);
    }
    else
        p_sf ->sf_flags |= IN_PATH;
        
    should_compile = FALSE;
    for (p_sl =  p_sf -> sf_dofirst .sl_next; p_sl; p_sl = p_sl -> sl_next)
    {
        p_sfn = p_sl -> sl_node;
        should_compile |= do_compile (p_sfn);
        PRINTF ("    do_com: name %s shld comp %d\n", p_sfn -> sf_name, should_compile);
    }
    
    
    if (should_compile || (p_sf -> sf_flags & COMP_VALID) == FALSE) {
        if (p_sf -> sf_flags & UNIT_TEXT) {
	   if (!ever_compiled) {
	      printf (compile_com);
	      ever_compiled = TRUE;
	   }
           printf (" %s", p_sf -> sf_name);
           p_sf -> sf_flags |= COMPILED;
           should_compile = TRUE;
        }
        else
        {   printf ("Refuse to use source %s out of library for compilation\n",
                                    p_sf -> sf_name);
            exit (1);
        }
    }
    else
    {   if (p_sf -> sf_flags & UNIT_TEXT)
            printf ("# compilation of %s not necessary\n", p_sf -> sf_name);
    }
    p_sf -> sf_flags |= VISITED;
    p_sf -> sf_flags &= ~IN_PATH;
    
    return should_compile;
}

/*
 * bc_src_list : build source list and check internal consistency of
 * each source file
 */
bc_src_list ()
{
    register struct unode_list *ulp;
    int i;
    register struct unode *up;
    register struct sf_list *p_sl ;
    register struct sf_node *p_sf, *p_sf1, *cp_sf;

    p_sl = sf_list .sl_next;
    p_sf = p_sl -> sl_node;
    
    for (ulp = unit_list .ul_next; ulp; ulp = ulp -> ul_next)
    {
        up = ulp -> ul_node;
        /* library units are not in sourcefile order */
        if ((up -> u_flags & UNIT_TEXT) == FALSE)
            cp_sf = give_sfptr (&sf_list, up);
        else
        {
            PRINTF ("1node sf %s current sf %s\n", up -> u_sname, p_sf -> sf_name);
            if (strcmp (up -> u_sname, p_sf -> sf_name) != 0)
            {
                /* take next source file */
                p_sl = p_sl -> sl_next;
                p_sf = p_sl -> sl_node;
                PRINTF ("2node sf %s current sf %s\n", up -> u_sname, p_sf -> sf_name);
                if (strcmp (up -> u_sname, p_sf -> sf_name) != 0)
                {
                    /* error in node sequence */
                    fprintf (stderr, "system error: unodes not in sourcefile order\n");
                    exit ();
                }
            }
            cp_sf = p_sf;
        }

        /* mark a source file as actual source, not from library */
        cp_sf -> sf_flags |= (up -> u_flags & UNIT_TEXT);

        /* When at least 1 unit of a source file is invalid, the file
           should be recompiled
          */
        if ((up -> u_flags & COMP_VALID) == FALSE)
        {
            PRINTF ("bc_sfl:sf %s Unit %s is invalid\n", cp_sf -> sf_name, up -> u_name);
            cp_sf -> sf_flags &= ~COMP_VALID;
        }
        else
            PRINTF ("bc_sfl:sf %s Unit %s is valid\n", cp_sf -> sf_name, up -> u_name);
            
        if (up -> u_context .ul_next)
            dofirst (up, up -> u_context .ul_next, cp_sf);

        if (up -> u_spec && 
           ((up -> u_spec -> u_flags & (SS | UNIT_TEXT)) == (SS | UNIT_TEXT) ||
           (up -> u_spec -> u_flags & SS) == FALSE))
            dofst_un (up, up -> u_spec, cp_sf);
            
        up -> u_flags |= VISITED;

        /* this is the only place one can see when a unit in the library
           is invalid
           */
        if ((cp_sf -> sf_flags & (UNIT_TEXT | COMP_VALID)) == FALSE)
        {
            fprintf (stderr, "Unit %s from library becomes invalid, compilation not possible\n",
                up -> u_name);
            compilation = FALSE;
        }
    }
}
/*
 * dofirst adds the names of the source files of the unodelist to the
 * s_dofirst list
 */
dofirst (up, p_ul, p_sf)
register struct unode *up;
register struct unode_list *p_ul;
register struct sf_node *p_sf;
{
    register struct unode *p_un;
    
    for (; p_ul; p_ul = p_ul -> ul_next)
    {
        p_un = p_ul -> ul_node;
        dofst_un (up, p_un, p_sf);
    }
}

/*
 * dofst_un does the work for dofirst, it is also used separately
 * for adding the specification of a body
 */
dofst_un (up, p_un, p_sf)
register struct unode *up;
register struct unode *p_un;
register struct sf_node *p_sf;
{
    register struct sf_node *p_sf1;

    PRINTF ("dofst_un uname %s\n", p_un -> u_name);
    
    
    /* When at least 1 unit of a source file is invalid, the file
       should be recompiled
      */
    if ((p_un -> u_flags & COMP_VALID) == FALSE)
    {
        PRINTF ("dofst:sf %s Unit %s is invalid\n", p_sf -> sf_name, p_un -> u_name);
        p_sf -> sf_flags &= ~COMP_VALID;
    }
    else
        PRINTF ("dofst:sf %s Unit %s is valid\n", p_sf -> sf_name, p_un -> u_name);

    p_sf1 = give_sfptr (&sf_list, p_un);
    if (p_sf1 != NULL)
    {
        PRINTF ("Sourcename %s ptr %x\n", p_un -> u_sname, p_sf1);
        if (p_sf == p_sf1) /* units in same source file */
        {
            /*
             * when two nodes are in the same source file, the node on which
             * the other depends, should have been seen first, and must be
             * visited already
             */
            if ((p_un -> u_flags & VISITED) == FALSE &&
                 p_sf -> sf_flags & UNIT_TEXT)
            {
                fprintf (stderr, "In source file %s unit %s has forward reference to unit %s\n",
                     p_sf -> sf_name, up -> u_name, p_un -> u_name);
                compilation = FALSE;
            }
            else
                return;
        }

        add_dofirst (&p_sf -> sf_dofirst, p_sf1);
    }
}

/* 
 * give_sfptr returns the sourcefile pointer of the sourcefile name
 */
struct sf_node *
give_sfptr (p_sl, p_un)
register struct sf_list *p_sl;
register struct unode *p_un;
{
    register struct sf_node *p_sf;
    register char *s_name, *u_name;
    
    s_name = p_un -> u_sname;
    u_name = p_un -> u_name;

    for (p_sl = p_sl -> sl_next; p_sl; p_sl = p_sl -> sl_next)
    {
        p_sf = p_sl -> sl_node;
        PRINTF ("give_sfptr naam %s\n", p_sf -> sf_name);
        if (strcmp (s_name, p_sf -> sf_name) == 0)
            return p_sf;
    }

    return NULL;
}

/*
 * add_dofirst : add the argument in the sf list when new
 */
add_dofirst (p_sl, p_sf)
register struct sf_list *p_sl;
register struct sf_node *p_sf;
{
    register struct sf_node *p_sf1;
    register struct sf_list *p_slold = p_sl;
    
    for (p_sl = p_sl -> sl_next; p_sl; p_sl = p_sl -> sl_next)
    {
        p_sf1 = p_sl -> sl_node;
        if (strcmp (p_sf1 -> sf_name, p_sf -> sf_name) == 0)
            return;
        p_slold = p_sl;
    }
    /* add new sourcefile name */
    p_slold -> sl_next =  (struct sf_list *) mem_for (sizeof (struct sf_list));
    p_sl = p_slold -> sl_next;
    p_sl -> sl_next = NULL;
    p_sl -> sl_node = p_sf;
}
