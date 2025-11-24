/*
  o.c
  output node in intermediate code format
  19880803/wj van ganswijk
*/

#include  "def.h"

extern struct sinfo ic00 [];
extern struct sinfo ic290[];
extern struct sinfo nu00 [];

/*print node*/
onode(pn,ps)
register struct snode *pn;
char         *ps;
{
  char              c;
  register char    *pa;
  int               kode;
  int              *ph;
  register unsigned t;
  struct sinfo     *pinfo;
  int               nn;

  diag("onode"); diah(pn);
  if (pn==0) return;
  if (ps) printf("%s",ps);
  kode=pn->kode;
  if      (kode>=0    && kode< 130) pinfo = &nu00[kode];
  else if (kode>=1000 && kode<1052) {
    pinfo = &ic00 [kode-1000];
    printf("&%d",kode-1000);
  }
  else if (kode>=1290 && kode<1294) {
    pinfo = &ic290[kode-1290];
    printf("%s",pinfo->ps);
  }
  else errorn("unknown kode to print",kode);
  if (kode<1000) printf("%d",kode);
  if (pinfo->ps) {
    if (kode<1290) putchar('\t');
    if (pa=pinfo->pa) {
      nn=0;
      while ((c = *pa++) && c!='d') {
        switch (c) {
        case 'l': printf("%ld\t",pn->arg[nn++].l); break;
        case '0':
        case 'R':
        case 'n':
        case 'L': printf("%d\t",pn->arg[nn++].i); break;
        case 'N': printf("%d\t",t=pn->arg[nn++].i);
                  ph=pn->arg[nn++].pi;
                  while (t--) printf("\t%d\t",*ph++); 
                  break;
        case 'S':
        case 'p': nn++; break;
        case 'q': /*"string"*/
                  printf("\"%s\"",pn->arg[nn].pc?pn->arg[nn].pc:""); nn++;
                  if (*pa) printf("\t");  /*alleen als er nog wat volgt*/
                  break;
        case 's': /*string*/
                  printf("%s"    ,pn->arg[nn].pc?pn->arg[nn].pc:""); nn++;
                  if (*pa) printf("\t");  /*alleen als er nog wat volgt*/
                  break;
        case 't': printf("%o\t",pn->arg[nn++].i); break; /*type*/
        default: puts(""); errorn("onode: table error",c); return;
        }
      }
      puts("");
      if (pinfo->pa[0]=='p') onode(pn->arg[0].pn,ps);
      if (pinfo->pa[1]=='p') onode(pn->arg[1].pn,ps);
    }
    else puts("");
  }
  else errorn("unknown code",kode);
}

/*end*/
