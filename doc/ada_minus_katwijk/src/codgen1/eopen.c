#include <stdio.h>

eopen(pn)
char *pn;
{
  fprintf(stderr,"error opening '%s'",pn); perror("");
  exit(255);
}
