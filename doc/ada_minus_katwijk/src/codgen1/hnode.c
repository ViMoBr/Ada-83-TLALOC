/*
  hnode.c
  hulproutines met node's
  19880804/wj van ganswijk
*/

#include  "def.h"
#include  "mknode.h"

extern char f_revc;    /*reverse CALL and CBRANCH nodes?*/
extern char f_diag;    /*diagnose mode?*/

extern struct sinfo ic00 [];
extern struct sinfo ic290[];
extern struct sinfo nu00 [];

/*arrays for conditionals*/
              /*EQ NE LE LT GE GT ULE ULT UGE UGT*/
int Anegrel []={NE,EQ,GT,GE,LT,LE,UGT,UGE,ULT,ULE};  /*inv*/

struct snode *dupnode(),*calloc();  /*forward*/
char         *dupstr();

/*dupliceer boom*/
struct snode *dupnode(p0)
struct snode *p0;
{
  register struct snode *p1;
  char     c;
  char     *pa;
  int      n,n0,n1;
  int      *pd,*ps;
  unsigned kode;
  struct   sinfo *pinfo;

  diag("dupnode"); diah(p0);
  if (p0==0) return 0;
  p1=calloc(1,sizeof(struct snode));
  kode=p0->kode;
  if      (              kode< 130) pinfo = &nu00 [kode];
  else if (kode>=1000 && kode<1052) pinfo = &ic00 [kode-1000];
  else if (kode>=1290 && kode<1294) pinfo = &ic290[kode-1290];
  else errorn("unknown node to remove",kode);
  if (pinfo->ps) {
    if (pa=pinfo->pa) {
      p1->kode=p0->kode;
      n1 = 0;
      n0 = 0;
      while ((c = *pa++) && c!='d') {
        switch (c) {
        case 'l': p1->arg[n1++].l=p0->arg[n0++].l; break;
        case '0':
        case 'R':
        case 'S':
        case 'n': 
        case 't':
        case 'L': p1->arg[n1++].i=p0->arg[n0++].i; break;
        case 'N': p1->arg[n1++].i=n=p0->arg[n0++].i;
                  p1->arg[n1++].pi=pd=(int*)calloc(1,sizeof(int)*n);
                  for (ps=p0->arg[n0++].pi;n--;) *pd++ = *ps++;
                  break;
        case 'p': p1->arg[n1++].pn=dupnode(p0->arg[n0++].pn); break;
        case 'q':                                             /*"string"*/
        case 's': p1->arg[n1++].pc=dupstr(p0->arg[n0++].pc);  /*string*/
                  break;
        default: errorn("dupnode: table error",c); break;
        }
      }
    }
  }
  else errorn("unknown node to duplicate",kode);
  return p1;              /*geef nieuwe terug*/
}

/*breek boom weer af*/
struct snode *putnode(pn)
register struct snode *pn;
{
  char          c;
  char         *pa,*ps;
  unsigned      kode;
  struct sinfo *pinfo;
  int           nn,*pi;

  diag("putnode"); diah(pn);
  if (pn) {
    kode=pn->kode;
    if      (              kode< 130) pinfo = &nu00 [kode];
    else if (kode>=1000 && kode<1052) pinfo = &ic00 [kode-1000];
    else if (kode>=1290 && kode<1294) pinfo = &ic290[kode-1290];
    else errorn("unknown node to remove",kode);
    if (pinfo->ps) {
      if (pa=pinfo->pa) {
        nn=0;
        while ((c = *pa++) && c!='d') {
          switch (c) {
          case '0':
          case 'l':
          case 'L':
          case 'n': 
          case 'R':
          case 'S':
          case 't': nn++; break;
          case 'N': nn++; free(pn->arg[nn++].pi); break;
          case 'p': putnode(pn->arg[nn++].pn);    break;       /*subnode*/
          case 'q':                                            /*"string"*/
          case 's': if (ps=pn->arg[nn++].pc) free(ps); break;  /*string*/
          default:  errorn("putnode: table error",c); break;
          }
        }
      }
    }
    else errorn("unknown node to remove",kode);
    free(pn);  /*geef node zelf terug*/
  }
  return 0;    /*niets meer over*/
}

/*bepaal type van willekeurige node*/
int nodetype(pn)
register struct snode *pn;
{
  diag("nodetype"); diah(pn);
  if (pn && pn->kode<=130) return pn->arg[2].i;
  return 0;
}

struct snode *mkleaf(ko,l0,a1,a2,a3)
unsigned      ko;
int           a1,a2,a3;
long          l0;
{
  register struct snode *ph;

  ph=calloc(1,sizeof(struct snode));
  ph->kode=ko;
  ph->arg[0].l=l0;
  ph->arg[1].i=a1;
  ph->arg[2].i=a2;
  ph->arg[3].i=a3;
  return ph;
}

struct snode *mkmonad(ko,p0,ty)
unsigned      ko;
struct snode *p0;
int           ty;
{
  register struct snode *ph;

  ph=calloc(1,sizeof(struct snode));
  ph->kode=ko;
  ph->arg[0].pn=p0;
  ph->arg[2].i =ty;
  return ph;
}

struct snode *mkdyad(ko,p0,p1,ty)
unsigned      ko;
struct snode *p0,*p1;
int           ty;
{
  register struct snode *ph;

  ph=calloc(1,sizeof(struct snode));
  ph->kode=ko;
  ph->arg[0].pn=p0;
  ph->arg[1].pn=p1;
  ph->arg[2].i =ty;
  return ph;
}

struct snode *mkicnode(ko,a0,a1,a2,a3,a4)
unsigned      ko;
int           a0,a1,a2,a3,a4;
{
  register struct snode *ph;

  ph=calloc(1,sizeof(struct snode));
  ph->kode=1000+ko;
  ph->arg[0].i=a0;
  ph->arg[1].i=a1;
  ph->arg[2].i=a2;
  ph->arg[3].i=a3;
  ph->arg[4].i=a4;
  return ph;
}

struct snode *mkcbranc(p0,p1,type)
register struct snode *p0,*p1;
int    type;
{
  return f_revc?mkdyad(REVCBRAN,p1,p0,type):mkdyad(CBRANCH,p0,p1,type);
}

struct snode *mkcall(p0,p1,type)
register struct snode *p0,*p1;
int    type;
{
  return f_revc?mkdyad(REVCALL,p1,p0,type):mkdyad(CALL,p0,p1,type);
}

struct snode *mkcm(p0,p1,type)
register struct snode *p0,*p1;
int    type;
{
  return f_revc?mkdyad(REVCM,p1,p0,type):mkdyad(CM,p0,p1,type);
}

struct snode *mkcomop(p0,p1)
struct snode *p0,*p1;
{
  register struct snode *ph;

  ph=calloc(1,sizeof(struct snode));
  ph->kode=COMOP;
  ph->arg[0].pn=p0;
  ph->arg[1].pn=p1;
  ph->arg[2].i =p1->arg[2].i;  /*neem type over van rechter subnode*/
  return ph;
}

int isleaf(pn)
register struct snode *pn;
{
  register unsigned kode;

  kode=pn->kode;
  return (kode==ICON || kode==NAME || kode==REG || kode==OREG);
}

/*
  deze routine kan met een array versneld worden!
*/
int revcode(kode)
register int kode;
{
  switch (kode) {
  /*commutatieve operators blijven gelijk*/
  case AND:
  case ER:
  case EQ:
  case MUL:
  case NE:
  case OR:
  case PLUS: break;
  /*vergelijkingen hebben al een tegenovergestelde*/
  case GE:  kode=LE;  break;
  case GT:  kode=LT;  break;
  case LE:  kode=GE;  break;
  case LT:  kode=GT;  break;
  case UGE: kode=ULE; break;
  case UGT: kode=ULT; break;
  case ULE: kode=UGE; break;
  case ULT: kode=UGT; break;
  /*andere hebben een nieuw soort node nodig*/
  case CALL:     kode=REVCALL;  break;
  case DIV:      kode=REVDIV;   break;
  case LS:       kode=REVLS;    break;
  case MINUS:    kode=REVMINUS; break;
  case MOD:      kode=REVMOD;   break;
  case RS:       kode=REVRS;    break;
  case STCALL:   kode=REVSTCAL; break;
  case REVCALL:  kode=CALL;     break;
  case REVDIV:   kode=DIV;      break;
  case REVLS:    kode=LS;       break;
  case REVMINUS: kode=MINUS;    break;
  case REVMOD:   kode=MOD;      break;
  case REVRS:    kode=RS;       break;
  case REVSTCAL: kode=STCALL;   break;
  default: errorn("can't reverse",kode); break;
  }
  return kode;
}

/*end*/
