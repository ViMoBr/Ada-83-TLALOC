#include	"libr.h"
#include	<signal.h>
/*
 * das command 
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
char	*prep	= PREP;
char	*front	= FRONT;
char	*back	= BACK;
char	*gen	= PC1;
char	*opt	= OPT;
char	*ass	= ASS;
char	*loader	= LOADER;
char	*tmpdir	= TMP;
char	*treedir= CURRDIR;
char	*outfile= NULL;
char	*secdir = CURRDIR;
char	*conv	= CONVERT;

bool	jflagP	= FALSE;	/* Preprocessor */
bool	jflagO	= FALSE;	/* Optimizer */
bool	jflaga	= TRUE;		/* assembler */
bool	jflagb	= TRUE;		/* backend */
bool	jflagc	= FALSE;	/* convert */
bool	jflagf	= TRUE;		/* front */
bool	jflagg	= TRUE;		/* code generator */
bool	jflagl	= TRUE;		/* loader */
bool	jflags	= TRUE;		/* startupper */

bool	flagk	= FALSE;	/* keep intermediate files */
bool	flagn	= FALSE;	/* do nothing, just show verbose list */
bool	flagv	= FALSE;	/* verbose */

LIBDESC the_library;
LUN	the_lun;	/* the allocation of LUN ! -- cannot do it local
			 * in main () because the 68K lnk instruction can
			 * only adjuste the sp by 32K and sizeof (LUN) is
			 * about 32K !!
			 */
LUN	*lun		= &the_lun;

bool	status		= TRUE;

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

		case 'D':	/* trace flag on */
			add_arglist ("-t", x_flags);
			break;

		case 'd':	/* debug flag on */
			add_arglist ("-d", x_flags);
			break;

		case 'O':	/* optimizer flag on */
			jflagO = TRUE;
			break;

		case 'P':	/* preprocessor flag on */
			jflagP = TRUE;
			break;

		case 'c':	/* no loading */
			jflags = FALSE;
			jflagl = FALSE;
			break;

		case 'j':
			flags += do_jflags (flags+1);
			/* fall through: the j flag implies the k flag */

		case 'k':	/* keep temps */
			flagk = TRUE;
			tmpdir = CURRDIR;
			if (!writeable (tmpdir))
				exit (1);
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

		strcpy (name, argv[i]);
		complete_name (name);
		if (!reachable (name))
			break;

		do_type (name);
		add_arglist (name, tocomp);
	  }
	}

	openlib (master, RW, libdesc, &status);
	if (!status)
	   error ("cannot enter library %s", master);

	/*
	 * now we start compiling the filenames
	 */

    currarg = tocomp-> _first;
    for (i = 0; i < tocomp-> alistcount; i++)
    {	currfile = currarg-> _argument;

	if (flagv)
		message ("%s:\n", currfile);

	scan_lun (currfile, libdesc, lun, &status); 
	if (!status)
	  stopping (libdesc, "%s: error in scanning", currfile);

	set_tmpnames (currfile, lun, tmpdir, flagk);

/* das preprocessor: */
	if (jflagP)
	{
	  av [0] = "dpp";
	  av [1] = currfile;
	  av [2] = prep_name (lun);
	  av [3] = NULL;

	  druk_af_arg (av, prep);
	  if (!flagn)
		if (callsys (prep, av))
		  stopping (libdesc, "%s: error in prep", currfile);
	}

	set_fnames (lun, currfile, treedir, outfile);
	set_stamps (lun);
	set_secnames (lun, secdir);

	init_complist (libdesc, lun, &status);
	if (!status)
	      stopping (libdesc, "verify status of dependent units");

	c_compute_args (lun, av, x_flags);

/* front: */
	if (jflagf)
	{ av [0] = "frontend";
	  av [1] = front_name (lun);
	  av [3] = (jflagP ? prep_name (lun) : currfile);

	  druk_af_arg (av, front);

	  if (!flagn)
	    if (callsys (front, av))
	      stopping (libdesc, "%s: error in frontend", currfile);
	}

/* backend: */
	if (jflagb)
	{ av [0] = "backend";
	  av [1] = tree_name (lun);
	  av [3] = av [2];

	  be_misary (av);		/* change order of args */

	  av [2] = pcc_name (lun);
	  av [4] = front_name (lun);

	  druk_af_arg (av, back);

	  if (!flagn)
	    if (callsys (back, av))
	      stopping (libdesc, "%s: error in backend", currfile);
	}

/* gen: */
	if (jflagg)
	{ av [0] = "gen";
	  av [1] = pcc_name (lun);
	  av [2] = (jflagO ? opt_name (lun) : ass_name (lun));
	  av [3] = NULL;

	  druk_af_arg (av, gen);

	  if (!flagn)
	    if (callsys (gen, av))
	      stopping (libdesc, "%s: error in gen", currfile);
	}

/* optim: */
	if (jflagO)
	{ av [0] = "optimizer";
	  av [1] = opt_name (lun);
	  av [2] = ass_name (lun);

	  druk_af_arg (av, opt);
	  if (!flagn)
	    if (callsys (opt, av))
	      stopping (libdesc, "%s: error in opt", currfile);
	}

/* assembler:  */
	if (jflaga)
	{ av [0] = "as";
	  av [1] = "-o";
	  av [2] = object_name(lun);
	  av [3] = ass_name (lun);
	  av [4] = NULL;

	  druk_af_arg (av, ass);

	  if (!flagn)
	    if (callsys (ass, av))
	      stopping (libdesc, "%s: error in assembler", currfile);

	}
	set_compiled (libdesc, lun);

/* loader: */
printf ("LOADER\n");
	if (is_subprogram (lun))
	{ init_loadlist (libdesc, lun, &status);
	  if (!status)
	    stopping (libdesc, "%s", "verify status of dep. units");

printf ("LOADER1\n");
	  if (jflags)
	  {
	    /* make startup routine */
	    make_start (lun);
printf ("LOADER2\n");
	    av [0] = "as";
	    av [1] = "-o";
	    av [2] = "start.o";		/* bah */
	    av [3] = "start.s";
	    av [4] = NULL;
  
	    druk_af_arg (av, ass);

	    if (!flagn)
	      if (callsys ("/bin/as", av))
	      { error ("%s: error in assembler", currfile);
	        closelib (libdesc);
	        exit (210);
	      }
	  }

	  if (jflagl)
	  {
	    l_compute_args (lun, av, libs, prefs);

	    druk_af_arg (av, loader);

	    if (!flagn)
	      if (callsys (loader, av))
	        stopping (libdesc, "%s: error in loader", currfile);
	    set_loaded (lun);
	  }
	}

/* convert: */
	if (jflagc)
	{ av [0] = "convert";
	  av [1] = outfile == NULL ? "/dev/tty" : outfile;
	  av [3] = tree_name (lun);

	  druk_af_arg (av, conv);

	  if (!flagn)
	    if (callsys (conv, av))
	      stopping (libdesc, "%s: error in treeprint", currfile);
	}

/* administrate: */
	if (!flagn)
	{ put_lun (libdesc, lun, &status);
	  if (!status)
	    stopping (libdesc, "%s: cannot update", currfile);

	  remove_tmps (lun);
	}

	currarg = currarg-> _next;		/* next file please */
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
	set_free (lun);
	remove_tmps (lun);
	signal (4, SIG_DFL);
	abort ();
	exit (-1);
}

remove_tmps (a_lun)
LUN *a_lun;
{
	if (!flagk)
	{
	   unlink (prep_name (a_lun));
	   unlink (pcc_name (a_lun));
	   unlink (opt_name (a_lun));
	   unlink (ass_name (a_lun));
	   unlink (front_name (a_lun));
	}
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

be_misary (av)
char **av;
{
		int j = 0;

		while (av [j] != 0) j++;
		av [j + 1] = 0;
		for (; j > 2; j--)
			av [j] = av [j-1];
}

make_start (lun)
LUN *lun;
{
	lunno	lluntab[2 * MAXLUN];
	int	i;

	get_lluntab (lun, lluntab);
	gen_startup (lun, lluntab);
	
	if (!flagv) return;

	/*
        printf ("lluntab is:");
        for (i = 0; lluntab[i] != 0; i++)
       	     printf (" %u", lluntab[i]);
        printf ("\n");
	*/

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

	for (i = 0; lluntab[i] != 0; i++)
	{
		if (lluntab[i+1] == 2)	/* standard is the last in the list */
			break;
		fprintf (out, "	jsr	_E%u\n", lluntab[i]);
	}

	/* now for the current lun */
	if (is_subprogram (lun)) {
		fprintf (out, "	movea.l	_S%d,a0\n", lluntab[i]);
		fprintf (out, "	jsr	(a0)\n");
	}
	else
		fprintf (out, "	jsr	_E%u\n", lluntab[i]);

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

		case 'a':	/* assembler */
			if (++count < argc)
				ass = argv [count];

			if (!execable (ass))
				exit (2);
			break;

		case 'b':	/* backend */
			if (++count < argc)
				back = argv [count];

			if (!execable (back))
				exit (3);
			break;

		case 'c':	/* convert binary tree to ascii */
		        if (++count < argc)
				conv = argv [count];

			if (!execable (conv))
		                exit (13);

			break;

		case 'g':	/* code generator */
			if (++count < argc)
				gen = argv [count];

			if (!execable (gen))
				exit (2);
			break;

		case 'f':	/* front */
			if (++count < argc)
				front = argv [count];

			if (!execable (front))
				exit (5);
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

		case 'm':	/* master file */
			if (++count < argc)
				master = argv [count];

			if (!writeable (master))
			   exit (7);
			break;

		case 'o':	/* optimizer */
			jflagO = TRUE;
			if (++count < argc)
				opt = argv [count];

			if (!execable (opt))
				exit (9);
			break;

		case 'p':	/* preprocessor */
			jflagP = TRUE;
			if (++count < argc)
				prep = argv [count];

			if (!execable (prep))
				exit (10);
			break;

		case 's':	/* sec dir specification */
			if (++count < argc)
				secdir = argv [count];

			if (!writeable (secdir))
			   exit (11);
			break;

		case 't':	/* tree dir specification */
			if (++count < argc)
				treedir = argv [count];

			if (!writeable (treedir))
			   exit (12);
			break;

		default:
			error ("das: unknown use flag\n");
		}
	}
	return count - i;
}

/* execute just .. */

int
do_jflags (flags)
char *flags;
{
	register int j;
	register count = 0;

	jflagP = FALSE;
	jflagO = FALSE;
	jflaga = FALSE;
	jflagc = FALSE;
	jflagb = FALSE;
	jflagf = FALSE;
	jflagg = FALSE;
	jflagl = FALSE;
	jflags = FALSE;

	for (j = 0; flags[j] != '\0'; j++)
	{	/* printf ("just: %s\n", &flags[j]); */
		count++;

		switch (flags[j]){
		case 'P': jflagP = TRUE; break;
		case 'O': jflagO = TRUE; break;
		case 'a': jflaga = TRUE; break;
		case 'c': jflagc = TRUE; break;
		case 'b': jflagb = TRUE; break;
		case 'f': jflagf = TRUE; break;
		case 'g': jflagg = TRUE; break;
		case 'l': jflagl = TRUE; break;
		case 's': jflags = TRUE; break;
			break;
		case 'u':	/* process uflags */
			return count - 1;
		default:
			error ("das: unknown just flag\n");
		}
	}
	return count;
}

complete_name (name)
char *name;
{
	register char *p1;

	for (p1 = name; *p1 != '\0'; p1++)
		if (*p1 == '.')
			return;

	sprintf (p1, ".ada");
}

do_type (name)
char *name;
{
	register char *p1;
	register char *p2 = NULL;
	register type = T_NOTYPE;

	for (p1 = name; *p1 != '\0'; p1++)
	{
		if (*p1 == '.')
			p2 = p1;
	}

	switch (*++p2)
	{
	case 'a':
		if (*(p2 + 1) == 'd' && *(p2 + 2)  == 'a' && p1  == p2 + 3)
			type = T_A;
		break;
	case 'f':
		if (p1 == p2 + 1)
			type = T_F;
		break;
	case 'p':
		if (p1 == p2 + 1)
			type = T_P;
		break;
	case 's':
		if (p1 == p2 + 1)
			type = T_S;
		break;
	case 'o':
		if (p1 == p2 + 1)
			type = T_O;
		break;
	}

	if (type == T_NOTYPE)
		error ("strange file extension %s", name);

	sprintf (p2, "ada");

	switch (type)
	{	/* fall through on purpose */
	case T_O: jflaga = FALSE;
	case T_S: jflagg = FALSE;
	case T_P: jflagb = FALSE;
	case T_F: jflagf = FALSE;
	case T_A: break;
	}

}

void
message (a, b, c, d, e, f)
{
	fprintf (stderr, a, b, c, d, e, f);
}
