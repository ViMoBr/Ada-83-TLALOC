/*
 * routines voor het printen van gegevens uit de master file
 */

#include "libr.h"
#include <sys/types.h>
#include <sys/stat.h>

char *daslib = DASLIB;
char *b_standard = B_STANDARD;
char *dasexit = DASEXIT;

dfl_signals()
{
}

LIBDESC	libstore;
LIBDESC *library = &libstore;

struct lun_list
{
	char l_full_name[FNAMESIZE];
	LUN l_lun;
	struct lun_list *l_nlun;
} start_llist = { "", {0}, 0};

struct lun_list *next_llist = &start_llist;
struct lun_list **start_ptr;

#define LLIST_ITER(p) for (p = start_llist .l_nlun; p; p = p -> l_nlun)

short status;

main(argc, argv)
int argc;
char **argv;
{
	bool status;
	char *master = ".master";

	if (argc > 1)
	    if (argc == 2)
		master = argv[1];
	    else
	    {
		fprintf (stderr, "too many arguments\n");
		exit (1);
	    }

	openlib (master, R, library, &status);
	if (status == FALSE)
	{
		fprintf (stderr, "cannot open library: %s\n", master);
		exit (1);
	}
	/*
	 * Maak een lijst van bij lunnrs behorende unit namen
	 */
	lees_luns (library);

	/*
	 * Druk alle logische lun nrs af
	 */
	printf ("Logische lunnrs :\n");
	LLIST_ITER (next_llist)
	     printf ("%d ", log_ident ((&next_llist -> l_lun)));
	putchar ('\n');

	/*
	 * Druk alle entries in de master file af
	 */
	LLIST_ITER (next_llist)
	{
	     printf ("\nVolledige unit naam: %s\n", next_llist -> l_full_name);
	     printlun (&next_llist -> l_lun);
	}
}

/*
 * Print alle luns uit de master file
 */

leessub (lun, prefix, pointer, status)
char *prefix;
struct lun_list **pointer;
LUN *lun;
bool *status;
{
	int i;
	char *p1, *p2;
	(*pointer) -> l_nlun = (struct lun_list*) malloc (sizeof (struct lun_list));
	*pointer = (*pointer) -> l_nlun;
	/* copieer lun naar lun_llist structuur*/
	(**pointer) .l_lun = *lun;

	if (*prefix == '\0')
	    sprintf ((*pointer) -> l_full_name, "%s\n", name_of (lun));
	else
	    sprintf ((*pointer) -> l_full_name, "%s.%s\n", prefix, name_of (lun));
	(*pointer) -> l_nlun = 0;
	return FALSE;
}

lees_luns (library)
LIBDESC *library;
{
	bool status;
	*start_ptr = &start_llist;
	rec_list (library, leessub, start_ptr, &status);
}
/*
 * Lun_of_nr geeft een pointer naar de lun terug waarvan het nr
 * meegegeven wordt.
 */

struct lun_list *
llof_nr (lunno)
short lunno;
{
	struct lun_list *ll;
	LLIST_ITER (ll)
	{
	      if (phy_ident ((&ll -> l_lun)) == lunno &&
		  strcmp (".master", ll -> l_lun  .currfile) == 0)
		  return ll;
	}
	fprintf (stderr, "physical lun nr. %s not found", lunno);
	exit (1);
}

/*
 * Lun_of_name geeft een pointer naar de lun terug waarvan de naam
 * meegegeven wordt.
 */

struct lun_list *
llof_name (name)
char *name;
{
	struct lun_list *ll;
	LLIST_ITER (ll)
	{
	      if (strcmp (name_of ((&ll -> l_lun)), name) == 0)
		  return ll;
	}
}

/*
 * Deze routine ontvangt een ICLUN en druk deze af op stdout
 */

printlun (lun)
LUN *lun;
{
	int i;
	struct lun_list *ll;
	short flags;
	char *sufstr;

	status = TRUE;

	printf ("Physical lun identification: %d\n", phy_ident (lun));
	printf ("Logical  lun identification: %d\n", log_ident (lun));
	flags = lun -> real_lun ._flags;
	if (flags & BODY)
	    sufstr = "Body";
	else
	    sufstr = "Specification";
	if (flags & PS)
	    printf ("  Package %s\n", sufstr);
	if (flags & SS)
	    printf ("  Subprogram %s\n", sufstr);
	if (flags & TS)
	    printf ("  Task %s\n", sufstr);
	if (flags & GI)
	    printf ("  Generic Instantiation\n");
	if (flags & GNRC)
	    printf ("  Generic Specification\n");
	if (flags & SU)
	    printf ("  Secondairy unit\n");
	if (flags & COMPILED)
	    printf ("  Compiled\n");
	if (flags & LOADED)
	    printf ("  Loaded\n");
	if (flags & VRIJ)
	    printf ("  Vrij\n");
	flags &= ~(BODY|SS|TS|PS|GNRC|GI|SU|COMPILED|LOADED|VRIJ);
	if (flags)
	    printf ("Unknown flags : %x\n", lun -> real_lun ._flags);
	if (wcount (lun))
	{
	    printf ("Context specification:\n");
	    for (i = 0; i < wcount (lun); i++)
	         printf ("    %s\n", name_of ((&llof_nr (wlist (lun, i)) -> l_lun)));
	}
	printf ("Unit naam   : %s\n", name_of (lun));
	printf ("source name : %s \t%s", source_name (lun), ctime (&source_stamp (lun)));
	print_time (source_name (lun));
	if (is_compiled (lun))
	{
	    printf ("tree name : %s \t%s", tree_name (lun), ctime (&tree_stamp (lun)));
	    print_time (tree_name (lun));
	    printf ("object name : %s \t%s", object_name (lun), ctime (&object_stamp (lun)));
	    print_time (object_name (lun));
	}
	if (is_loaded (lun))
	{
	    printf ("exec name : %s \t%s", exec_name (lun), ctime (&exec_stamp (lun)));
	    print_time (exec_name (lun));
	    if (status == TRUE)
		verify_lun (&lun);
	}
	if (has_secondaries (lun))
	{
	    printf ("secs name : %s \t%s", secondaries (lun), ctime (&secs_stamp (lun)));
	    print_time (secondaries (lun));
	}
	printf ("curr file   : %s\n", lun -> currfile);
	if (status == FALSE)
	    printf ("Lun contains invalid data\n");
}

/*
 * printtime drukt de tijd van laatste verandering af van de file naam
 * welke als argument meegegeven wordt
 * wanneer de file niet meer bestaat wordt een passende boodschap gegeven
 */
print_time (s)
char *s;
{
	struct stat buf;
	if (stat (s, &buf) == -1)
	{
	    status = FALSE;
	    printf ("\tfile does not exist\n");
	}
	else
	    printf ("\ttime stamp of unix file \t%s", ctime (&buf .st_mtime));
}

/*
 * Verify_lun checks consistency of an executable
 */

verify_lun (lun)
LUN *lun;
{
}
