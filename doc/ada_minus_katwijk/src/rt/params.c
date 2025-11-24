#include	"../h/print.h"
#include	"../h/rt_defs.h"
#include	"../h/rt_types.h"
#include	"cnames.h"


extern int * _parbase;
num_pars (){

	PRINTF (printf ("\nin num_pars : *_parbase = %d,	_parbase = %d\n",
				*_parbase, _parbase));

	return (* _parbase);
}

get_par (n, s, leng)
int n, leng;
char *s;
{
	char *p;

	leng = 0;

	if (n >= (*_parbase) || n < 0)
		_raise (&PROGRAM_ERROR);

	p = (char *) * (_parbase + n + 3);

	while (*s++ = *p++) leng++;
	PRINTF (printf ("\nin get_par : n = %d, s = %s, leng = %d\n\n", n, s, leng));
}
