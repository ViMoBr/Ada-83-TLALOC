/*
 * adarm verwijdert de meegegeven unit namen uit de library
 * verwijderen wil zeggen: maak de entry ongeldig
 * echt weghalen kan niet
 */
#include <stdio.h>

main (argc, argv)
int argc;
char *argv[];
{
    int status;
    char *f_name();
    int kind;
    char u_name[100], *sstr;

    if (argc-- == 1)
    {
	printf (" Usage: adarm unitname[s]\n");
	exit ();
    }
    argv++;
    while (argc--)
    {
	status = 1;
	del_lun (*argv, &status);
	if (!status)
	    printf ("%s not found or not removed\n", *argv);
	else
	    printf ("%s removed\n", *argv);
	argv++;
    }
}
