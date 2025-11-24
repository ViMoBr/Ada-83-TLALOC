/*
  rdec.c
  lees decimaal getal
  19871217/wjvg
*/

#include <ctype.h>

rdec(pp)
char **pp;
{
  register int v;

  while (**pp=='+') (*pp)++;
  if (**pp=='-') {
    (*pp)++;
    return -rdec(pp);
  }
  else {
    if (isdigit(**pp)) {
      v=0;
      do {
        v=v*10+(*(*pp)++)-'0';
      }
      while (isdigit(**pp));
      return v;
    }
    else {
      enuexp();
      return 0;
    }
  }
}

/*end*/
