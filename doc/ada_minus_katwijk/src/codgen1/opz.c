/*
  opz.c
*/

#include "def.h"

static char flagop=FALSE;

struct snode *opnode(pn)
struct snode *pn;
{
  if (!flagop) {
    error("No optimizer available in this version");
    flagop=TRUE;
  }
  return pn;
}

/*end*/
