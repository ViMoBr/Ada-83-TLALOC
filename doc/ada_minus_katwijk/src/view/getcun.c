main (argc, argv)
int argc;
char *argv[];
{
    int i, j;
    int status;
    short get_cun(), cun;

    if (argc == 2)
	j = atoi(argv[1]);
    else
	j = 1;

    for (i = 0; i < j; ++i)
    {
	status = 1;
	cun = get_cun (&status);
	if (status)
	    printf ("get_cun %d\n ", cun);
	else
	    printf ("illegal status\n");
    }
}

