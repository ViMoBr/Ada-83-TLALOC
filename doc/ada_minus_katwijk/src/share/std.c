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
 *	Department of Mathematics and Informatics
 *	Delft University of Technology
 *	Julianalaan 132 Delft The Netherlands.
 *
 */

#include	"../h/tree.h"
#include	"../h/std.h"

/* P A C K A G E   S T A N D A R D  */

/***********************************************************************/
/* W A R N I N G    W A R N I N G    W A R N I N G    W A R N I N G    */
/***********************************************************************/

/* This file contains the compile-time representation of
 * the first machine dependent piece of package STANDARD.
 * It contains only data (records).
 * The file is constructed by hand entirely.
 * Be extremely careful when changing anything of this file.
 * Take care especially of the following points:
 *   1. the global variable "prev" (see globls.c) must initially
 *      be set to the last record of the local list of the package standard
 *   2. all locals of this local list must be linked.
 */


extern struct _package STD;
extern struct _enumtype STD_boolean;
extern struct _internal STD_mach_int;
extern struct _internal STD_short_int;
extern struct _internal STD_long_int;
extern struct _internal	STD_inttypes;
extern struct _internal STD_univ;
extern struct _internal STD_notype;
extern struct _internal STD_type;
extern struct _internal STD_bl_vect;
extern struct _internal STD_aggregate;
extern struct _internal STD_access_type;
extern struct _internal STD_scalar_vector;
extern struct _internal STD_string_type;
extern struct _internal STD_real;
extern struct _internal STD_enum;

struct _package STD =
	{XPACKAGE, 0,	/* flags	*/
	 -1,	/* weird lineno */
	 NULL,
	 0,	/* current index */
	"STANDARD",
	 NULL,
	 &STD_boolean,
	 NULL,
	 NULL
	} ;

/*type boolean is (false,true) */

struct _enumlit STD_true =
	{XENUMLIT, 0,
	 -1,	/* weird lineno */
	 NULL,
	 2,
	"TRUE",
	 &STD_boolean,
	 1
	} ;
struct _enumlit STD_false =
	{XENUMLIT, 0,
	 -1,	/* weird lineno */
	 &STD_true,
	 1,
	"FALSE",
	 &STD_boolean,
	 0
	} ;
struct _enumtype STD_boolean =
	{XENUMTYPE, 040,
	 -1,	/* weird lineno */
	 &STD_mach_int,
	 3,
	"BOOLEAN",
	 &STD,
	NULL,
	 &STD_false,
	2
	} ;
struct _internal STD_mach_int =
	{XINTERNAL, 040,
	 -1,	/* weird lineno */
	 &STD_short_int,
	 0,
	 "$_integer",
	NULL,
	NULL,
	I_INTEGER
	} ;

struct _internal STD_short_int =
	{XINTERNAL, 040,	-1,
	 &STD_long_int,
	 0,
	 "$_short",
	NULL,
	NULL,
	 I_SHORT
	};

struct _internal STD_long_int =
	{XINTERNAL, 040,	-1,
	 &STD_univ,
	 0,
	 "$_long",
	NULL,
	NULL,
	 I_LONG
	};
struct _internal STD_univ =
	{XINTERNAL, 040,	-1,
	 &STD_inttypes,
	 0,
	 "$_any_int",
	NULL,
	NULL,
	 I_UNIV
	};
struct _internal STD_inttypes =
	{XINTERNAL, 040,	-1,
	 &STD_notype,
	 0,
	 "$_inttypes",
	NULL,
	NULL,
	 I_INTTYPES
	};

struct _internal STD_notype =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 &STD_type,
	 0,
	 "$_notype",
	NULL,
	NULL,
	 I_NO_TYPE
	} ;
struct _internal STD_type =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 &STD_bl_vect,
	 0,
	 "$_any_type",
	NULL,
	NULL,
	 I_ANY_TYPE
	} ;
struct _internal STD_bl_vect =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 &STD_aggregate,
	 0,
	 "$_bool_vector",
	NULL,
	NULL,
	 I_ANY_BOOL_VECTOR
	} ;
struct _internal STD_aggregate =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 &STD_access_type,
	 0,
	 "$_any_aggregate",
	NULL,
	NULL,
	 I_ANY_AGGREGATE
	} ;
struct _internal STD_access_type =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 &STD_scalar_vector,
	 0,
	 "$_any_access",
	NULL,
	NULL,
	 I_ANY_ACCESS_TYPE
	} ;
struct _internal STD_scalar_vector =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 &STD_real,
	 0,
	 "$_any_scalar",
	NULL,
	NULL,
	 I_ANY_SCALAR_VECTOR
	} ;
struct _internal STD_real =
	{XINTERNAL, 040,
	 -1,	/* weird lineno */
	 &STD_enum,
	 0,
	 "$_mach_real",
	NULL,
	NULL,
	I_STD_REAL
	};
struct _internal STD_enum =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 &STD_string_type,
	 0,
	 "$_enum",
	NULL,
	NULL,
	 I_ENUM
	};

struct _internal STD_string_type =
	{XINTERNAL, 0,
	 -1,	/* weird lineno */
	 NULL,
	 0,
	 "$_any_string",
	NULL,
	NULL,
	 I_ANY_STRING_TYPE
} ;


ac	std_boolean	= &STD_boolean;
ac	std_real	= &STD_real;
ac	std_integer	= &STD_mach_int;
ac	std_short	= &STD_short_int;
ac	std_long	= &STD_long_int;
ac	std_univ	= &STD_univ;
ac	std		= &STD;
ac	notype		= &STD_notype;	
ac	any_type	= &STD_type;
ac	any_bool_vect	= &STD_bl_vect;
ac	any_aggregate	= & STD_aggregate;
ac	any_access_type	= &STD_access_type;
ac	any_scalar_vector	= &STD_scalar_vector;
ac	any_string_type	= &STD_string_type;
ac	any_enumtype	= &STD_enum;
ac	std_true	= &STD_true;
ac	std_false	= &STD_false;

ac	st_table [] =
	{
		&STD,
		&STD_true,
		&STD_false,
		&STD_boolean,
		&STD_mach_int,
		&STD_short_int,
		&STD_long_int,
		&STD_univ,
		&STD_notype,
		&STD_type,
		&STD_bl_vect,
		&STD_aggregate,
		&STD_access_type,
		&STD_scalar_vector,
		&STD_real,
		&STD_enum,
		&STD_string_type,
		NULL
	};

ac	def_prev	= &STD_enum;
ac	prev		= &STD_enum;
ac	env		= &STD;
ac	def_env 	= &STD;
ac	std_string 	= NULL;

void	stan_link (x)
ac x;
{
	s_next (prev, x);
	prev = x;
}


