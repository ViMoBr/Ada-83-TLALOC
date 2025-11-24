#include <stdio.h>
#include "consts.h"
#include "macros.h"

typedef unsigned short lunno;

struct unit_desc {
	char		_filename [FNAMESIZE];	/* path to unixfile */
	long 		_stamp;			/* time stamp */
};

/*
 *	the structure of a library descriptor:
 */

struct libdesc {
	char	_libname [FNAMESIZE];
	int 	_mode;
	int	_mfp;				/* FILE pointer to masterfile */
};

typedef struct libdesc LIBDESC;

/*
 *	the structure of an individual lun:
 */


struct oc_lun {
	lunno		_plunno;		/* physical lun ident */
	unsigned short	_llunno;		/* logical lun ident */
	short		_flags;			/* for whatever */
	lunno		_csv [MAXLIST];		/* context specification */
	short		_csc;			/* context spec. count */
	short		_stc;			/* stub count */
	char		_unit_name [UNAMESIZE];	/* library name  */

	struct _fnames {
		struct	unit_desc source, tree, object, exec, secs;
	} _names;
};

#define	OCLSIZE	sizeof (struct oc_lun)
typedef struct oc_lun OC_LUN;

struct _closure {
	struct _lunlist *_first;
	struct _lunlist *_last;
	int closurecount;
};

typedef struct _closure  CNTR_LLIST;

struct tmp_names {
	char prep_naam	[FNAMESIZE];
	char frnt_naam	[FNAMESIZE];
	char pcc__naam	[FNAMESIZE];
	char opt__naam	[FNAMESIZE];
	char ass__naam	[FNAMESIZE];
};

struct ic_lun {
	OC_LUN	real_lun;

	char currfile [FNAMESIZE];

	CNTR_LLIST  closure;

	struct tmp_names temps;
};

#define	ICLSIZE	sizeof (struct ic_lun)
typedef	struct ic_lun	LUN;

/*
 * the structure of an lunlist:
 */

struct _lunlist {
	OC_LUN		_unit; 		/* lun in list */

	char currfile [FNAMESIZE];

	struct _lunlist *_next;		/* next element in list */
};

typedef struct _lunlist LLIST;



/* structure of the argument list.
 * this package implements a dynamic list
 *
 * see arglist.c
 */

struct _cntr_alist {
	struct _arglist *_first;
	struct _arglist *_last;
	int alistcount;
};

typedef struct _cntr_alist  CNTR_ALIST;


struct _arglist {
	char *_argument;
	struct _arglist *_next;		/* next element in list */
};

typedef struct _arglist ALIST;
