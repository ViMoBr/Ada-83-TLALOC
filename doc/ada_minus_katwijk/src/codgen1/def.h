/*
  def.h
  definities voor alle files
  19880606/wjvg
*/

#include <stdio.h>

#include "icdef.h"
#include "snode.h"

#define  FALSE  0
#define  TRUE (-1)  /*-1 ipv 1 ivm evt bitmasking, (-1) ivm =- ambiguiteit*/

#define  until(a)  while (!(a))

/*records met argument info*/
struct sinfo {
  char    *ps;
  char    *pa;
};

/*end*/
