/*
 * this file is included by some run-time assembly programs
 * and by the code generator,
 * it is included indirectly via cnames.h by most of the run-time
 * C programs.
 */

/* for use in run-time C programs: */
#define    PROGRAM_ERROR	_program_error 
#define    CONSTRAINT_ERROR	_constraint_error
#define    NUMERIC_ERROR	_numeric_error
#define    TASKING_ERROR	_tasking_error
#define    STORAGE_ERROR	_storage_error

/* for use in run_time assembly programs */
#define    _PROGRAM_ERROR	__program_error
#define    _CONSTRAINT_ERROR	__constraint_error
#define    _NUMERIC_ERROR	__numeric_error
#define    _TASKING_ERROR	__tasking_error
#define    _STORAGE_ERROR	__storage_error

/* the next two depend on std.c! */
#define	     _SHORT	__short
#define	     _INTEGER	__integer
#define	     _ANY_INT	__any_integer
#define	     _LONG	__long
#define	     _FLOAT	__mach_real
#define	     _STANDARD	_XaabaaaSTANDARD
#define	     _BOOLEAN	_XaabaadBOOLEAN

/* for use in the code generator */
#define    EXC_PROGRAM		"__program_error"
#define    EXC_CONSTRAINT	"__constraint_error"
#define    EXC_NUMERIC		"__numeric_error"
#define    EXC_TASKING		"__tasking_error"
#define    EXC_STORAGE		"__storage_error"
/*
 *	for use in exception.s
 */
#define	_EXC	90
#define	_EXH	94
