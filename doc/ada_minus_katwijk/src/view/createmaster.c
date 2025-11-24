#include "libr.h"

/*
 * define PRIVE_STANDARD when you want to be asked during creation of the
 * masterfile which version of package standard you want to have.The default
 * one or another.
 */
#define PRIVE_STANDARD

createmaster (libraryname, filename, pmaster)
char *libraryname;
char *filename;
char *pmaster;
{
	LUN my_lun;
	LUN *init_lun = &my_lun;
	int fp;

	fprintf (stderr, "CREATING %s\n", filename);
	close (creat (filename, C_READWRITE));
	fp = open (filename, W);

	phy_ident (init_lun) = 0;
	log_ident (init_lun) = 0;
	set_occupied (init_lun);
	strncpy (name_of (init_lun), libraryname, UNAMESIZE);
	strncpy (currentfile (init_lun), filename, FNAMESIZE);
	strncpy (parentmaster  (init_lun), pmaster, FNAMESIZE);
	sprintf (archivefile   (init_lun), "%s.a", filename);
	write_oclun (fp, init_lun);
	close (fp);
}

init_lun (x)
LUN *x;
{
	int i;

	*(x-> real_lun. _unit_name) 	= (char)   0;
	x-> real_lun. _plunno		= (lunno)  0;
	x-> real_lun. _llunno		= (char)   0;
	x-> real_lun. _flags		= (short)  0;
	x-> real_lun. _csc		= (short)  0;
	x-> real_lun. _stc		= (short)  0;

	for (i = 0; i < MAXLIST; i++) 
	   x-> real_lun. _csv [i] = (lunno)  NULL;

	*(x-> currfile)	= (char)   0;
}

init_standard (filename)
char *filename;
{
	int fp;
#ifdef PRIVE_STANDARD
	char c;
#endif PRIVE_STANDARD
	LUN my_lun;
	LUN *il = &my_lun;

	if ((fp = open (filename, W)) == -1)
		return;

	init_lun (il);
	phy_ident (il) = 1;
	log_ident (il) = 1;
	set_occupied (il);
	il-> real_lun. _flags = PS;
	strncpy (name_of (il), ".standard1", UNAMESIZE);
	write_oclun (fp, il);

	init_lun (il);
	phy_ident (il) = 2;
	log_ident (il) = 2;
	set_occupied (il);
	il-> real_lun. _flags = PS|COMPILED;
	strncpy (name_of (il), "standard", UNAMESIZE);
#ifdef PRIVE_STANDARD
	printf ("Do you want the default package standard ? (y/n): ");
	if ((c = getchar ()) == 'y')
#endif PRIVE_STANDARD
	    def_stand (il);
#ifdef PRIVE_STANDARD
	else
	   read_stand (il);
#endif PRIVE_STANDARD
	write_oclun (fp, il);

	/*
	init_lun (il);
	phy_ident (il) = 3;
	log_ident (il) = 3;
	set_occupied (il);
	il-> real_lun. _flags = PS|COMPILED;
	strncpy (name_of (il), "standbody", UNAMESIZE);
#ifdef PRIVE_STANDARD
	if (c == 'y')
#endif PRIVE_STANDARD
	    def_body (il);
#ifdef PRIVE_STANDARD
	else
	    read_body (il);
#endif PRIVE_STANDARD
	write_oclun (fp, il);
	*/

	close (fp);
}

def_stand (init_lun)
LUN *init_lun;
{
	init_times (init_lun);
	strncpy (name_of (init_lun), U_STANDARD, UNAMESIZE);
	strncpy (tree_name (init_lun), T_STANDARD, FNAMESIZE);
	strncpy (object_name (init_lun), O_STANDARD, FNAMESIZE);
}

def_body (init_lun)
LUN *init_lun;
{
	init_times (init_lun);
	strncpy (object_name (init_lun), B_STANDARD, FNAMESIZE);
}

#ifdef PRIVE_STANDARD
read_stand (init_lun)
LUN *init_lun;
{
	init_times  (init_lun);
	printf ("give the unit name of standard: ");
	scanf ("%s", name_of (init_lun));
	printf ("give path name of the tree   of standard: ");
	scanf ("%s", tree_name (init_lun));
	/*
	printf ("give path name of the object of standard: ");
	scanf ("%s", object_name (init_lun));
	*/
}

read_body (init_lun)
LUN *init_lun;
{
	init_times  (init_lun);
	printf ("give path name of the body   of standard: ");
	scanf ("%s", object_name (init_lun));
}
#endif PRIVE_STANDARD

init_times (init_lun)
LUN *init_lun;
{
	long my_time;

	time (&my_time);
	tree_stamp (init_lun) = my_time;
	object_stamp (init_lun) = my_time;
}
