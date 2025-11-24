

x_of (x)
register ac x;
{
	switch (g_d (x))
	{
	case XSUB:
	case XPACKAGE:
		return SPEC;
	case XSUBBODY:
	case XPACKBODY:
		return XBODY;
	default:
		abort ();
	}
}

extern	f_name ();
extern	a_name ();
extern	o_name ();

tmp_name (s, k)
register char *s;
int k;
{
	return mktemp ("/tmp/adaXXXXXX");
}


p_name (s)
register char *s;
{
	static char vec [20];

	sprintf (vec, "%s.f", s);
	return vec;
}

/*
int get_cun (s)
register char *s;
{
	static int x = 100;
	return ++x;
}
*/
