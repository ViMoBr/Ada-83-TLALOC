/*
  x68z
  xlator, convert tree dummy
  19880718/wjvg
*/

#include "def.h"

static char flagx=FALSE;

/*xlate node*/
struct snode *xnode(pn)
struct snode *pn;
{
  if (!flagx) {
    error("This version can't generate objekt kode");
    flagx=TRUE;
  }
  return pn;
}

/*end*/
