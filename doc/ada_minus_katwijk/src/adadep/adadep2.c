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
 * System dependent file for use with adadep
 * In this file routines are included that use the program library
 * for completing the sourcefile dependencies of the unodelist structure
 *
 * Ton Biegstraaten, dutinfd!abi 24-3-87
 */

/*#define DEBUG
/**/
#include "adadep.h"
#include "DEBUG.h"

extern struct unode_list unit_list, *p_unit_list, *p_curwlist;
extern struct sf_list sf_list;
int compilation = TRUE;

/*
 * search_library will try to complete de dependency tree. It will follow
 * units without sources in the library and adds them to the unit list.
 * It's assumed that all units without source are from one source without
 * a name.
 * make is TRUE will only generate the minimum necessary compile statements
 * make is FALSE will generate compile statements for al sources
 */
search_library (libname, make)
char *libname;
bool make;
{
    register struct unode_list *unl;
    register struct unode *unp;
    LIBDESC ld, *ldesc = &ld;
    LUN ll, *xlun = &ll;
    bool status = TRUE;
    register int i;
        
    set_pl_name (libname);
    get_libdesc (ldesc, &status);
    if (status == FALSE)
    {
        fprintf (stderr, "library not found\n");
        exit (1);
    }
    
    for (unl = unit_list. ul_next; unl; unl = unl -> ul_next)
    {
        unp = unl -> ul_node;
        PRINTF ("1unit %s sourcefile %s\n", unp -> u_name, unp -> u_sname);

        /*
         * a subpr spec without source is due to a body and can be omitted
         * when all sources are scanned
         */
        if (unp -> u_flags & SS && unp -> u_sname[0] == '\0')
        {
            extract (unp);
            /* don't free unp, because pointers to it still exists*/
            continue;
        }
        
        /* alleen bij make of geen source de library bezoeken*/
        if (make || unp -> u_sname[0] == '\0')
        {
            status = TRUE;
            get_lun (ldesc, unp -> u_name, xlun, &status);
            if (status == TRUE)
                t_init_complist (ldesc, xlun, &status);
            PRINTF ("2unit %s sourcefile %s\n", unp -> u_name, unp -> u_sname);
            if (status == TRUE)
            {
                if (unp -> u_sname[0])
                {
                    PRINTF ("time tree %d time sname %d\n", tree_stamp (xlun), time_of (unp -> u_sname));
                    if (tree_stamp (xlun) > time_of (unp -> u_sname))
                    {
                        PRINTF ("Unit %s is valid\n", unp -> u_name);
                        unp -> u_flags |= COMP_VALID;
                    }
                }
                else
                {
                   /*
                    * cun wel in library, maar geen source meegegeven.
                    * Source uit lib alleen voor de naam gebruiken.
                    * Ga ervan uit dat de cun geldig is en neem de context info
                    * over in de tree, dat doet het front ook.
                    * Alleen de parent info van separate units is wat moeilijk
                    * Dit is echter al verwerkt en er komen dus alleen package
                    * specificaties bij
                    */

                    PRINTF ("Library unit has source %s\n", source_name (xlun));
                    strncpy (unp -> u_sname, source_name (xlun), FNAMESIZE);
                    if (give_sfptr (&sf_list, unp) == NULL)
                    {
                        PRINTF ("lib source  %s added to list\n",
                           unp -> u_sname);
                        add_sfunit (unp -> u_sname);
                    }
                    
                    p_curwlist = &(unp -> u_context);
                    for (i = 0; i < wcount (xlun); i++)
                    {
                        LUN nl, *xnl = &nl;
                        
                        if (get_plun (library_name (ldesc), wlist (xlun, i), xnl) == FALSE)
                        {
                            fprintf (stderr, "Library error; Invalid context for unit %s\n",
                                 unp -> u_name);
                            compilation = FALSE;
                            continue;
                        }
                        PRINTF ("context unit %s\n", name_of (xnl));
                        /* voeg toe aan unode list */
                        add_wlist (name_of (xnl));
                    }                    
                    
                    PRINTF ("no source of unit %s, library is valid\n", 
                        unp -> u_name);
                    unp -> u_flags |= COMP_VALID;
                }
            }
            else
            {
                PRINTF ("3unit %s sourcefile %s\n", unp -> u_name, unp -> u_sname);
                if (unp -> u_sname[0] == 0 && (unp -> u_flags & SS) == FALSE)
                {
                    fprintf (stderr, "unit %s not in library, and no source available\n", unp -> u_name);
                    compilation = FALSE;
                }
            }
        }
    }
}
