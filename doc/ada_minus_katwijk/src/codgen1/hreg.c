/*
  hreg
  xlator, register allocation hulproutines
  19880715/wj van ganswijk
*/

#include  "def.h"

extern char f_diag;      /*diagnose mode?*/

extern int regt;         /*register type of last node or subnode*/
extern int type;         /*type of last node or subnode*/
extern int width;        /*breedte van laatste type*/

extern unsigned mregorg [3];
extern unsigned mreg    [3];  /*number of regs available for expressions*/

char     reginuse[24];  /*is het register in gebruik?*/
unsigned mregused[3];   /*nr van laagste reg per soort in gebruik*/

/*stel de registeraantallen en vlaggen in*/
setregs(n0,n1,n2)
{
  int n;

  mregused[0]=n0;  /*nummer van laagste registers in gebruik*/
  mregused[1]=n1;
  mregused[2]=n2;
  for (n=000;n<010;n++) reginuse[n]=(n>=n0);  /*init register flags*/
  for (     ;n<020;n++) reginuse[n]=(n>=n1);
  for (     ;n<030;n++) reginuse[n]=(n>=n2);
}

getreg(type)
int type;
{
  unsigned n,w;

  diag("getreg");
  w=regtype(type);
  if (f_diag) printf("w = %d\n",w);
  for (n=w*8+8;--n>=w*8;) {
    if (reginuse[n]==FALSE) {
      reginuse[n]=TRUE;                  /*now in use*/
      if (n<mregused[w]) mregused[w]=n;
      mreg[w]--;
      if (f_diag) printf("acquired reg %d\n",n);
      return n;
    }
  }
  error("register error");
  return 0;
}

/*vraag specifiek register aan*/
getregn(n)
int n;
{
  int w;

  diag("getregn");
  w=n/8;
  if (reginuse[n]==FALSE) {
    reginuse[n]=TRUE;                  /*now in use*/
    if (n<mregused[w]) mregused[w]=n;
    mreg[w]--;
    if (f_diag) printf("acquired reg %d\n",n);
    return n;
  }
  error("wanted register already in use");
  return n;
}

putreg(n)
int n;
{
  int w;

  diag("putreg");
  if (f_diag) printf("returned reg %d\n",n);
  w=n/8;
  reginuse[n]=FALSE;  /*niet meer in gebruik*/
  mreg[w]++;
}

/*end*/
