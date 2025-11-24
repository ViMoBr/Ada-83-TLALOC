#include <stdio.h>
#include <signal.h>
#include "libr.h"

bool get_archname ();
int childpid = 2;

killpid (x)
int x;
{
#ifdef SIGKIL
 	kill (x, SIGKIL);
#else
 	kill (x, SIGKILL);
#endif SIGKIL
}

/*
 * in callsys a call to dfl_signals is added
 * dfl_signals (file: das.c) set the signals in the original state,
 * i.e. the state at the start of the parent process
 * note that kapse.o is no longer self supporting,
 * it needs at least a definition of dfl_signals()
 */

callsys(f,v)
char f[],*v[];
{
	int status;

	fflush (stdout);
	fflush (stderr);

	if ((childpid = fork()) == 0)
	{	dfl_signals ();
		execv(f,v);
		fprintf (stderr, "Sorry, can't find %s\n",f);
		return (100);
	}
	else
	    if (childpid == -1)
	    {   fprintf (stderr, "Try again\n");
		return(100);
	    }

	while (childpid != wait(&status));

	if ((childpid = (status & 0377)) != 0)
	{
   	   if (childpid % 128 != SIGINT)
	      	switch (childpid % 128)
	      	{
		case SIGHUP:
			fprintf (stderr, "%s: hangup\n", f);
			break;
		case SIGQUIT:
			fprintf (stderr, "%s: quit\n", f);
			break;
		case SIGILL:
			fprintf (stderr, "%s: illegal instruction\n", f);
			break;
	      	case SIGBUS:
			fprintf (stderr, "%s: bus error\n", f);
			break;
		case SIGTRAP:
			fprintf (stderr, "%s: trace trap\n", f);
			break;
#ifdef SIGKIL
		case SIGKIL:
#else
		case SIGKILL:
			fprintf (stderr, "%s: killed\n", f);
			break;
#endif SIGKIL
#ifdef SIGADR
	      	case SIGADR:
			fprintf (stderr, "%s: address error\n", f);
			break;
#endif SIGADR
#ifdef SIGSYS
	      	case SIGSYS:
			fprintf (stderr, "%s: bad system call\n", f);
			break;
#endif SIGSYS
#ifdef SIGPIPE
	      	case SIGPIPE:
			fprintf (stderr, "%s: broken pipe\n", f);
			break;
#endif SIGPIPE
#ifdef SIGALRM
	      	case SIGALRM:
			fprintf (stderr, "%s: alarm clock\n", f);
			break;
#endif SIGALRM
#ifdef SIGTERM
	      	case SIGTERM:
			fprintf (stderr, "%s: chatchable termination\n", f);
			break;
#endif SIGTERM
	      	default:
			fprintf (stderr, "%s: fatal error. signo: %d\n",
							   f,childpid % 128);
	      	}
   	   return(101);
	}
	childpid = 2;
	return ((status & ~0377) >> 8);
}



ch_access (s, mode)
char *s;
int mode;
{
	if (!access (s, mode))
		return TRUE;

	fprintf (stderr, "cannot ");
	switch (mode){
	case RABLE:
		fprintf (stderr, "read from ");
		break;
	case WABLE:
		fprintf (stderr, "write on ");
		break;
	case EABLE:
		fprintf (stderr, "execute ");
		break;
	case AABLE:
		fprintf (stderr, "access ");
	}
	fprintf (stderr, "%s\n", s);

	return FALSE;
}

ins_arcv (lun)
LUN *lun;
{
	char *av [5];
	char archfile [FNAMESIZE];

	if (!get_archname (lun, archfile))
	   return;

	av [0] = "ar";
	av [1] = "r";
	av [2] = archfile;
	av [3] = object_name (lun);
	av [4] = 0;

	callsys (AR, av);
}

extr_arcv (lun)
LUN *lun;
{
	char *av [5];
	char archfile [FNAMESIZE];

	if (!get_archname (lun, archfile))
	   return;

	if (access (archfile, RABLE))
	   return;

	av [0] = "ar";
	av [1] = "d";
	av [2] = archfile;
	av [3] = object_name (lun);
	av [4] = 0;

	callsys (AR, av);
}

bool
get_archname (lun, name)
LUN *lun;
char *name;
{
	LUN h;
	LUN *header = &h;

	if (!master_header (currentfile (lun), header))
	    return FALSE;

	strncpy (name, archivefile (header), FNAMESIZE);
	return TRUE;
}

#include <sys/types.h>
#include <sys/stat.h>

long
time_of (file)
char *file;
{
	struct stat b;
	struct stat *buf = &b;

	if (access (file, AABLE))
	   return ((long) ((long)MAXTIME - 2));
	else
	{  stat (file, buf);
	   return ((long) (abs ((int) buf-> st_mtime)));
	}
}

ino_of (file)
char *file;
{
	struct stat b;
	struct stat *buf = &b;

	if (access (file, AABLE))
	   return (MAXTIME - 2);
	else
	{  stat (file, buf);
	   return ((int) buf-> st_ino);
	}
}
