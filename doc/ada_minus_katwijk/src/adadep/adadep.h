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
 * headerfile for  ada makefile generator
 * 
 * abi@dutinfd
 * 16-12-86
 * 12-1-88
 *
 */

#include "libr.h"
int nflags;

#define NO_CHANGE 0
/* kinds */
#undef PB
#undef PS
#undef SB
#undef SU
#define SS 1
#define PS 2
#define TS 4
#define BODY 8
#define SB (SS | BODY)
#define PB (PS | BODY)
#define TB (TS | BODY)
/* next flags can be ored with previous */
#define SU 0x10
#define GI 0x20
#define GNRC 0x40

/* general flags */
/* actual text has been seen*/
#define UNIT_TEXT 0x80
/* to avoid circularity when visiting lists */
#define VISITED 0x100
/* set up when a compilation statement for a sourcefile is generated */
#undef COMPILED
#define COMPILED 0x200
/* set if compilation is not necessary */
#define COMP_VALID 0x400
/* set during following of dofirst paths in do_compile to avoid cycles */
#define IN_PATH 0x800
/* mark a unit or sourcefile as having source from library */
#define SOURCE_IN_LIB 0x1000

/*
 * compilation unit node structures,
 * the list and the data are separated
 * a list has an empty structure at the front
 */

struct unode_list
{
    struct unode_list *ul_next;
    struct unode *ul_node;
};

struct unode
{
    struct unode_list u_context;
    struct unode_list u_stubs;
    struct unode *u_spec;
    char u_name[FNAMESIZE];
    char u_sname[FNAMESIZE];
    int u_flags;
} *curunit, *lastunit;

char sfname[];		/* name of source file */

/*
 * A library module can be added(adadep2.c).
 * If so all units must be available, if not, missing units
 * are assumed to be found in the library
 */
int compilation;	/* set FALSE when compilation not possible */

extern char compile_com[];	/* contains compile command with %s for the
					source file name */
/*
 * Next to a list structure for the compilation units, there has to be
 * a structure for the sourcefiles too. They are the ones
 * that must be compiled
 *
 * the list and the data are separated, and every list has an empty structure
 * at the front.
 */
 
struct sf_list
{
    struct sf_list *sl_next;
    struct sf_node *sl_node;
};

struct sf_node
{
    struct sf_list sf_dofirst;
    char sf_name[FNAMESIZE];
    int sf_flags;
};
