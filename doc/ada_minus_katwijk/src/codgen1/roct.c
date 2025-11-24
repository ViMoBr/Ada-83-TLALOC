/*
  roct
  lees octaal getal
  19880213/wjvg
*/

#include <ctype.h>

roct(pp)
char **pp;
{
  register int v;
  register int hv;

  while (**pp=='+') (*pp)++;
  if (**pp=='-') {
    (*pp)++;
    return -roct(pp);
  }
  else {
    if ((hv=octval(**pp))>=0) {
      v=0;
      do {
        v=(v<<3)+hv;
        (*pp)++;
      } while ((hv=octval(**pp))>=0);
      return v;
    }
    else {
      enuexp();
      return -1;
    }
  }
}

/*bepaal octvalue van character of -1*/
octval(c)
char c;
{
  if (isdigit(c)) return c-'0';
  return -1;
}

/*end*/
