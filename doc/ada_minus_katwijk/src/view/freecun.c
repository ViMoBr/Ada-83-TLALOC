main (argc, argv)
int argc;
char *argv[];
{
    int i, j, status;

    for (i = 1; i < argc; ++i)
    {
	status = 1;
	printf ("free cun %d\n", j = atoi (argv[i]));
	free_cun (j, &status);
	if (status == 0)
	    printf ("Illegal status\n");
    }
}

