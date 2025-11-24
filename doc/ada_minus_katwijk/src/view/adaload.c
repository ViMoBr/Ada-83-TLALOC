#include	"libr.h"
#include	<signal.h>
/*
 * dasload command 
 */

/*
 *	Defaults:
 */
extern	void	message ();

#define T_NOTYPE	0
#define T_A		1
#define T_F		2
#define T_P		3
#define T_S		4
#define T_O		5

char	*sstartup	= SSTARTUP;
char	*startup	= STARTUP;
char	*dasexit	= DASEXIT;
char	*daslib		= DASLIB;
char	*t_standard	= T_STANDARD;
char	*o_standard	= O_STANDARD;
char	*b_standard	= B_STANDARD;

char	*master	= LIBRARY;
char	*loader	= LOADER;
char	*tmpdir	= TMP;
char	*ass	= ASS;
char	*treedir= CURRDIR;
char	*outfile= NULL;

bool	flagn	= FALSE;	/* do nothing, just show verbose list */
bool	flagv	= FALSE;	/* verbose */

LIBDESC the_library;

bool	status		= TRUE;
LUN	the_lun, *t_lun = &the_lun;

main (argc, argv)
int argc;
char **argv;
{
	LIBDESC	*libdesc	= &the_library;

	CNTR_ALIST	the_libs;
	CNTR_ALIST	the_prefs;
	CNTR_ALIST	the_tocomp;
	CNTR_ALIST	the_flags;
	CNTR_ALIST	*libs   = &the_libs;
	CNTR_ALIST	*prefs  = &the_prefs;
	CNTR_ALIST	*tocomp = &the_tocomp;
	CNTR_ALIST	*x_flags= &the_flags;
	ALIST *currarg;
	char  *currfile;

	char	*av [2 * MAXLUN];
	char	*flags;

	int 	i 		= 0;

	init_arglist (libs);
	init_arglist (prefs);
	init_arglist (tocomp);
	init_arglist (x_flags);

	set_signals ();			/* clean up before leaving */

	while (++i < argc)
	{
	  if (*argv [i] == '-')
	  {  flags = argv [i];

	     while (*++flags)
	     {  /* printf ("main2:	%s\n", flags); */
		switch (*flags) {
		default:
			fprintf (stderr, "unknown option %c\n", *flags);
			break;

		case '0':	/* ? */
			if (++i < argc)
				add_arglist (argv [i], prefs);

			if (!readable (argv [i]))
				exit (12);
			break;

		case 'l':	/* link library with program */
			if (++i < argc)
				add_arglist (argv [i], libs);

			if (!readable (argv [i]))
				exit (6);
			break;

		case 'n':	/* no execution, just list actions */
			flagn = TRUE;
			flagv = TRUE;
			break;

		case 'o':	/* put executable into specified file */
			if (++i < argc)
				outfile = argv [i];

			if (!writeable (CURRDIR))
				exit (8);
			break;

		case 't':
			sstartup = TASKSTARTUP;
			break;

		case 'u':
			{ register int n;

			  n = do_use_spec (i, argc, argv, flags+1);
			  i += n;
			  flags += n;
			}
			 break;

		case 'v':	/* verbose */
			flagv = TRUE;
			break;
		}
	     }
	  }
	  else
	  {	char name[200];

		/* unit name, not unix filename */
		strcpy (name, argv[i]);
		uppercase (name);	/* Unit name always uppercase */
		add_arglist (name, tocomp);
	  }
	}

	get_libdesc (libdesc, &status);
	if (!status)
	   error ("cannot enter library %s", library_name (libdesc));


    currarg = tocomp-> _first;
    for (i = 0; i < tocomp -> alistcount; i++)
    {
    	currfile = currarg-> _argument;

	if (flagv)
		message ("%s:\n", currfile);

	get_lun (libdesc, currfile, t_lun, &status); 
	if (!status)
	  stopping (libdesc, "Cannot find unit %s", currfile);


/* loader: */
	if (is_subprogram (t_lun))
	{ 
	    init_loadlist (libdesc, t_lun, &status);
	    if (!status)
		stopping (libdesc, "%s", "verify status of dep. units");

	    /* make startup routine */
	    make_start (t_lun);
	    av [0] = "as";
	    av [1] = "-o";
	    av [2] = "start.o";
	    av [3] = "start.s";
	    av [4] = NULL;
  
	    druk_af_arg (av, ass);

	    if (!flagn)
	      if (callsys ("/bin/as", av))
	      { error ("%s: error in assembler", currfile);
	        closelib (libdesc);
	        exit (210);
	      }

	    if (outfile)
		strncpy (exec_name (t_lun), outfile, FNAMESIZE);
	    else
		setname (exec_name (t_lun), CURRDIR, currfile, E_EXEC);
	    l_compute_args (t_lun, av, libs, prefs);

	    druk_af_arg (av, loader);

	    if (!flagn)
	      if (callsys (loader, av))
	        stopping (libdesc, "%s: error in loader", currfile);
	    set_loaded (t_lun);
	}

/* administrate: */
	if (!flagn)
	{ put_lun (libdesc, t_lun, &status);
	  if (!status)
	    stopping (libdesc, "%s: cannot update", currfile);

	}

	currarg = currarg-> _next;		/* next unit please */
    }

	closelib (libdesc);
	exit (0);
}

stopping (lib, s, t)
char *s, *t;
LIBDESC *lib;
{
	closelib (lib);
	error (s, t);
}

error (s, t)
char *s, *t;
{
	fprintf (stderr, s, t);
	fprintf (stderr, "\n");
	set_free (t_lun);
	signal (4, SIG_DFL);
	abort ();
	exit (-1);
}

druk_af_arg (args, pass)
char **args;
char *pass;
{
	register int i;

	if (flagv)
	{
		message ("%s ", pass);

		for (i = 1; args [i] != NULL; i++)
			message ("%s ", args [i]);

		message ("\n");
	}
}

int opruimen ();
static opr1() { signal (1, SIG_IGN); opruimen (1); }
static opr2() { signal (2, SIG_IGN); opruimen (2); }
static opr3() { signal (3, SIG_IGN); opruimen (3); }
static opr4() { signal (4, SIG_IGN); opruimen (4); }
static opr5() { signal (5, SIG_IGN); opruimen (5); }
static opr6() { signal (6, SIG_IGN); opruimen (6); }
static opr7() { signal (7, SIG_IGN); opruimen (7); }
static opr8() { signal (8, SIG_IGN); opruimen (8); }
static opr9() { signal (9, SIG_IGN); opruimen (9); }
static opr10() { signal (10, SIG_IGN); opruimen (10); }
static opr11() { signal (11, SIG_IGN); opruimen (11); }
static opr12() { signal (12, SIG_IGN); opruimen (12); }
static opr13() { signal (13, SIG_IGN); opruimen (13); }
static opr14() { signal (14, SIG_IGN); opruimen (14); }
static opr15() { signal (15, SIG_IGN); opruimen (15); }
static opr16() { signal (16, SIG_IGN); opruimen (16); }
static (*opruim[])() = {
	opr1,opr2 ,opr3 ,opr4 ,opr5 ,opr6 ,opr7 ,opr8,
	opr9,opr10,opr11,opr12,opr13,opr14,opr15,opr16
	};
static int (*sigs[16]) ();
set_signals ()
{
	int i;

	for (i = 1; i < 16; i++)
		if ((sigs[i-1] = signal (i, SIG_IGN)) != SIG_IGN)
			signal (i, opruim[i-1]);
}

dfl_signals ()
{
	int i;

	for (i = 1; i < 16; i++)
		signal (i, sigs[i-1]);
}

extern int childpid;
opruimen (n)
int n;
{
	killpid (childpid);
	error ("signal %d ...", n);
}

make_start (lun)
LUN *lun;
{
	lunno	lluntab[2 * MAXLUN];
	int	i;

	get_lluntab (lun, lluntab);
	gen_startup (lun, lluntab);
	
	if (!flagv) return;

        printf ("lluntab is:");
        for (i = 0; lluntab[i] != 0; i++)
       	     printf (" %u", lluntab[i]);
        printf ("\n");

}

gen_startup (lun, lluntab)
LUN *lun;
lunno lluntab[];
{
	FILE	*in, *out;
	int	i;
	char	*av[2*MAXLUN];

	if ((in = fopen (sstartup, "r")) == NULL)
		error ("cannot open %s\n", sstartup);

	if ((out = fopen ("start.s", "w")) == NULL)
		error ("cannot create start.s\n");

	if (flagv)
		message ("cp %s start.s; ", sstartup);

	copyfile (lun, in, out);
	fclose (in);

	/* not for standard */
	for (i = 0; lluntab [i] != 0 && lluntab [i] != 2; i ++)
		fprintf (out, "	jsr	_E%u\n", lluntab[i]);

	/* now for the current lun */
	fprintf (out, "	movea.l	_S%d,a0\n", log_ident (lun));
	fprintf (out, "	jsr	(a0)\n");

	fprintf (out, "	jmp	_exit\n");

	fclose (out);
}

copyfile (lun, in, out)
	FILE	*in, *out;
{
	int	n;
	char	buf[512];

	while ((n = fread (buf, 1, 512, in)) != NULL)
	   if (fwrite (buf, 1, n, out) != n)
		error ("write error on start.s\n");
}

int
do_use_spec (i, argc, argv, flags)
int i, argc;
char *argv[];
char *flags;
{
	register int count = 1;
	register int j;

	count = i;

	for (j = 0; flags[j] != '\0'; j++)
	{	/* printf ("use: %s\n", flags); */

		switch (flags[j]){
		case 'L':	/* daslib.a specification */
			if (++count < argc)
				daslib = argv [count];

			if (!readable (dasexit))
				exit (2);
			break;

		case 'S':	/* startup dasrt0.s */
			if (++count < argc)
				sstartup = argv [count];

			if (!readable (sstartup))
				exit (2);
			break;

		case 'X':	/* dasexit.o specification */
			if (++count < argc)
				dasexit = argv [count];

			if (!readable (dasexit))
				exit (2);
			break;

		case 'i':	/* tmp dir specification */
			if (++count < argc)
				tmpdir = argv [count];

			if (!writeable(tmpdir))
			   exit (5);
			break;

		case 'j':	/* process jflags */
			return count - 1;

		case 'l':	/* loader */
			if (++count < argc)
				loader = argv [count];

			if (!execable (loader))
				exit (4);
			break;

		default:
			error ("adaload: unknown use flag\n");
		}
	}
	return count - i;
}

void
message (a, b, c, d, e, f)
{
	fprintf (stderr, a, b, c, d, e, f);
}
