/*
 * file contains routines for updating the library
 */
#include "libr.h"
/*#define DEBUG*/
#include "DEBUG.h"
#include "cungen.h"

#define SF 1
#define WU 2
#define KD 3
#define SC 4
#define ST 5

struct KindTab
{
    char *k_string;
    int k_kind;
} KindTab[] =
{
    "SS", SS,
    "PS", PS,
    "TS", TS,
    "SB", SB,
    "PB", PB,
    "TB", TB,
    "SUS", SB | SU,
    "SUP", SU | PB,
    "SUT", SU | TB,
    "GPS", GNRC | PS,
    "GPB", GNRC | PB,
    "GSS", GNRC | SS,
    0,0
};
extern short ccun;
extern LUN newlun, *lun;
extern LIBDESC *ldesc;
extern LUN *nlun;
char prefix[];
char lib_name[];
char src_name[FNAMESIZE] = {'\0'}, *p_src_name = src_name;

typedef int boolean;

void
update_lib (string, status)
char *string;
boolean *status;
{
    char *s = string;
    char file_name[FNAMESIZE];
    char *u_name , *cunno, *w_name, *kind;
    char *scname = "";
    char *w_list[MAXLIST], **wilist = w_list;
    int kind_flag, st_cnt = 0;
    LUN alun, *xlun = &alun;

    PRINTF ("string is %s\n", string);
    w_list[0] = NULL;
    stcount(nlun) = 0;
    while (*s != '\0')
    {
	if (*s == ':')
	{
	    *s++ = '\0';
	    if (kind_flag == 1)
	    {
		kind_flag++;
		u_name = s;
		continue;
	    }
	    else if (kind_flag == 2)
	    {
		kind_flag = 0;
		cunno = s;
		continue;
	    }	
	}
	if (*s == '#')
	{
	    s++;
	    switch (str_com (&s))
	    {
	    case SF:
		p_src_name = s;
		continue;
	    case WU:
		PRINTF ("with name %s\n", s);
		*wilist++ = s;
		*wilist = NULL;
		continue;
	    case SC:
		PRINTF ("sc name %s\n", s);
		scname = s;
		continue;
	    case ST:
		PRINTF ("stub name %s\n", s);
		st_cnt++;
		continue;
	    case KD:
		kind = s;
		kind_flag = 1;
		continue;
	    default:
		printf ("Unknown command: %s in update_lib\n", s);
		*status = FALSE;
	    }
	}
	s++;
    }

    /* save source name */
    if (*p_src_name != '\0')
        strncpy (src_name, p_src_name, FNAMESIZE);
    PRINTF (" secs name %s\n", scname);
    wilist = w_list;
    while (*wilist != 0)
	PRINTF ("with unit %s\n", *wilist++);

    /*
     * Check consistency of data by comparing to data already known
     */

    bld_cnt_lst (nlun, w_list, status);
    if (*status == FALSE)
	return;

    if (atoi (cunno) != ccun)
    {
	printf ("requested cun %d and cun in string %s are not equal\n", ccun, cunno);
    }

    /*
     * Build a new lun in core
     */

    strcpy (source_name (nlun), cur_dir ());
    strcat (source_name (nlun), src_name);
    nlun -> real_lun. _flags |= det_kind (kind, status);
    PRINTF ("kind %s detkind %x\n",kind, nlun -> real_lun. _flags);
    tree_stamp (nlun) = time (0);
    object_stamp (nlun) = time (0);
    stcount (nlun) = st_cnt;	/* bewaar aantal stubs */
    if (*status == FALSE)
	return;
    strcpy (name_of (nlun), u_name);
    sprintf(secondaries (nlun), "%s%s/.su%05d", prefix, OBJDIR, ccun);
    get_libdesc (ldesc, status);
    if (*status == FALSE)
    {
	printf ("get_libdesc niet gelukt\n");
	return;
    }
    strcpy (currentfile (nlun), lib_name);

    /*
     * update library
     */

    if (!is_subunit (nlun))
	scname = "";
    PRINTF ("scname :%s\n", scname);
    if (*scname != '\0')
    {
        strcpy (file_name, scname);
        strcat (file_name, ".");
        strcat (file_name, u_name);
    }
    else
	strcpy (file_name, u_name);
    PRINTF ("file_name voor get_lun %s\n", file_name);

    get_lun (ldesc, file_name, xlun, status);
    PRINTF ("xkind %x nkind %x\n",xlun -> real_lun. _flags, nlun -> real_lun. _flags);
    if (is_spec (xlun) && is_body (nlun))
    {
	PRINTF ("Gevonden lun is spec ipv body\n");
	*status = get_body (xlun, xlun);
	if (!*status) PRINTF ("Geen body\n");
    }
    if (!*status)
    {
	*status == TRUE;
	if (is_body (nlun) && !is_subunit(nlun))
	    scname = u_name;
	PRINTF ("scname :%s\n", scname);
	alloclun (ldesc, scname, u_name, xlun, status);
	if (*status == FALSE)
	{
	    printf ("alloclun niet gelukt\n");
	    return;
	}
    }
    else
    {
	free_lun (xlun, status);
	if (*status == FALSE)
	{
	    printf ("free_cun error\n");
	    return;
	}
    }
    phy_ident (nlun) = phy_ident (xlun);
    strcpy (currentfile (nlun), currentfile (xlun));
    alun = newlun;
    set_compiled (ldesc, xlun);
    put_lun (ldesc, xlun, status);
    if (*status == FALSE)
	printf ("put_lun niet gelukt\n");

    return;
}

/*
 * rm_proglib removes recursively all elements of a program library
 *    which has cun's > CUN_OFFSET
 */

rm_proglib (filename, status)
char * filename;
boolean *status;
{
    lunno i = 0;
    LUN armlun, *rmlun = &armlun;

    PRINTF ("remove library %s\n", filename);
    while (*status == TRUE)
    {
	PRINTF ("i = %d\n", i);
	*status = get_plun (filename, i, rmlun);
	if (*status == FALSE)
	{
	    PRINTF (" get_plun gaat fout\n");
	    *status = TRUE;
	    return;
	}

	i++;
	if (i == 0)
	    unlink (archivefile (rmlun));
	else
	{
	    PRINTF ("log_ident %d\n", log_ident (rmlun));
	    if (log_ident (rmlun) < CUN_OFFSET)
		continue;
	    
	    free_lun (rmlun, status);
	}
    }
}

free_lun (xl, status)
LUN *xl;
boolean *status;
{
    PRINTF ("Remove unit %s nr %d\n", name_of (xl), log_ident (xl));
    free_cun (log_ident (xl), status);
    PRINTF ("status na free_cun %d\n", *status);
    if (*status == FALSE)
	return;
    unlink (tree_name (xl));
    unlink (object_name (xl));
    if (has_secondaries (xl))
    {
	rm_proglib (secondaries (xl), status);
	PRINTF ("status na rm_proglib %d\n", *status);
	if (*status == TRUE)
	    unlink (secondaries (xl));
    }
}

int
str_com (s1)
char **s1;
{
    char *s = *s1;

    while (*(*s1)++ != ':');
    *(*s1-1) = '\0';

    if (strcmp (s, "sf") == 0)
	return SF;
    if (strcmp (s, "wu") == 0)
	return WU;
    if (strcmp (s, "su") == 0)
	return SC;
    if (strcmp (s, "st") == 0)
	return ST;
    if (strcmp (s, "kd") == 0)
	return KD;
    return 0;
}

int
det_kind (s, status)
char *s;
boolean *status;
{
    struct KindTab *kt = KindTab;

    for (; kt -> k_kind; kt++)
	if (strcmp (s, kt -> k_string) == 0)
	    return kt -> k_kind;

    printf ("Unknown kind %s\n", s);
    *status = FALSE;

    return NULL;
}

bld_cnt_lst (nlun, w_list, status)
LUN *nlun;
char *w_list[];
boolean *status;
{
    char **wilist = w_list;
    LUN tlun, *tl = &tlun;

    wcount (nlun) = 0;
    while (*wilist)
    {
	get_lun (ldesc, *wilist, tl, status);
	if (*status == FALSE)
	{
	    printf ("Context unit %s not found\n", *wilist);
	    return;
	}
	wlist (nlun, wcount (nlun)) = phy_ident (tl);
	wcount (nlun)++;
	wilist++;
    }
}

