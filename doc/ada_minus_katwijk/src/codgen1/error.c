/*
  error.c
  druk boodschap af op error channel en stop
  19870910/wjvg
*/

#include <stdio.h>

error(s)
char *s;
{
  fflush(stdout);                  /*werk eerst normale output af*/
  fprintf(stderr,"-- %s --\n",s);
  exit(-1);
}

/*end*/
