/*
  x68.c
  xlate to 68020 assembler, not working yet!
  19880720/wjvg
*/

#include  "def.h"

/*vlaggen*/
#define INREG    0x01  /*heeft bewerking altijd register nodig?*/
#define REVBLE   0x02  /*kan de operatie omgedraaid worden?*/
#define REVERSED 0x04
#define FSHIFT   0x08
#define FMOD     0x10

extern char  f_diag;      /*diagnose mode?*/
extern char *filena;
extern char *prgrname;
extern char *taal[];

extern int Anegrel[];  /*omgekeerden van relatie kode's*/
extern int regt;       /*register type of last node or subnode*/
extern int szptr;
extern int type;       /*type of last node or subnode*/
extern int width;      /*breedte van laatste type*/

static char  Awidch[4]="bwl";
static char  flags;                   /*zijn de vlaggen geldig?*/
static char *funcname;                /*huidige funktie naam*/

char  *dupstr(),*xnodeadr();

static int Areguse [24];   /*is het register in gebruik?*/
static int Aregused[24];   /*is het register in gebruik geweest in deze fn?*/
static int Astksize[ 3]={4,4,12};  /*size of tmp stored element*/

static int funcend;       /*nummer van eindlabel van funktie*/
static int funclink;      /*nummer van label van linkgedeelte van funktie*/
static int level;         /*hoe hoog zit xnode in de boom? (telt negatief)*/
static int mstacksize=0;  /*hoe groot is de stack ooit geweest? (0..)*/
static int switchdef;     /*label nummer voor default gedeelte van switch*/

static unsigned curfnr;   /*nummer van huidige funktie*/
static unsigned linenr;   /*nummer van huidige regel*/

/*arrays for conditionals*/
                        /*EQ   NE   LE   LT   GE   GT  ULE  ULT  UGE  UGT*/
static char *Accbranc[]={"eq","ne","le","lt","ge","gt","ls","lo","hs","hi"};
static char *Accbranz[]={"eq","ne",   0,"mi","pl",   0,"eq","rn","ra","ne"};

struct sfunc {
  int (*func)();
  unsigned pstring;
  unsigned para;
};

osimp(pn,ps)
struct snode *pn;
{
  printf("\t%s\n",ps);
}

owithnum(pn,ps)
struct snode *pn;
{
  printf("\t%s\t%d\n",ps,pn->arg[0].i);
}

owithstr(pn,ps)
struct snode *pn;
{
  printf("\t%s\t%s\n",ps,pn->arg[0].pc);
}

xicUNDEF(pn)
struct snode *pn;
{
}

xiclong(pn)
struct snode *pn;
{
  printf("\t.long\t%ld\n",pn->arg[0].l);
}

xicbytes(pn)
struct snode *pn;
{
  register int *ph;
  register int  t;

  printf(" .ascii ");
  for (t=pn->arg[0].i,ph=(int*)pn->arg[1].i;t--;)
    printf("%d%c",*ph++,t?',':'\n');
}

xicdlabn(pn)
struct snode *pn;
{
  olabn(pn->arg[0].i);
}

xicdlabs(pn)
struct snode *pn;
{
  puts(pn->arg[0].pc);
}

xicjlabn(pn)
struct snode *pn;
{
  printf("\tjra\t.L%d\n",pn->arg[0].i);
}

xicjlabs(pn)
struct snode *pn;
{
  printf("\tjra\t.L%s\n",pn->arg[0].pc);
}

xicfbeg(pn)
struct snode *pn;
{
  int n;

  curfnr=pn->arg[0].i;
  funcend=pn->arg[1].i;
  funcname=dupstr(pn->arg[3].i);
  funclink=getlabn();
  mstacksize=0;
  for (n=0;n<24;n++) Aregused[n]=FALSE;
}

xicfend(pn)
struct snode *pn;
{
  int m0,m1,m2;
  int ma0,ma1,ma2;
  int mi0,mi1,mi2;
  int n;

  m0=0; mi0=-1; ma0=-1;
  for (n= 0;n< 8;n++) {
    if (Aregused[n]) {
      if (mi0<0) mi0=n;
      ma0=n;
      m0+=4;
    }
  }
  m1=0; mi1=-1; ma1=-1;
  for (n= 8;n<16;n++) {
    if (Aregused[n]) {
      if (mi1<0) mi1=n;
      ma1=n;
      m1+=4;
    }
  }
  m2=0; mi2=-1; ma2=-1;
  for (n=16;n<24;n++) {
    if (Aregused[n]) {
      if (mi2<0) mi2=n;
      ma2=n;
      m2+=12;
    }
  }

  if (mi0||mi1) {
    printf("\tmovem.l\t-%d(a6),",mstacksize+m0+m1+m2);
    if (mi0) printf("r%d-r%d",mi0,ma0);
    if (mi0&&mi1) printf(":");
    if (mi1) printf("r%d-r%d",mi1,ma1);
    puts("");
  }
  if (mi2) {
    printf("\tfpmovem.l\t-%d(a6),",mstacksize+m2);
    printf("fp%d-fp%d",mi2-16,ma2-16);
    puts("");
  }
  puts("\tunlk a6");
  puts("\trts");
  puts(funcname);
  printf("\tlink.l\ta6,#-%d\n",mstacksize+m0+m1+m2);
  if (mi0||mi1) {
    printf("\tmovem.l\t");
    if (mi0) printf("r%d-r%d",mi0,ma0);
    if (mi0&&mi1) printf(":");
    if (mi1) printf("r%d-r%d",mi1,ma1);
    printf(",(sp)\n");
  }
  if (mi2) {
    printf("\tfpmovem.l\t");
    printf("fp%d-fp%d",mi2-16,ma2-16);
    printf(",%d(sp)\n",m0+m1);
  }
  printf("\tjra\t.L%d\n",funclink);
}

xiccomm(pn)
struct snode *pn;
{
  printf("\t.common\t%s,%d\n",pn->arg[1].pc,pn->arg[0].i);
}

xicswtch(pn)
struct snode *pn;
{
  switchdef=0;  /*nog geen default*/
}

xicswdef(pn)
struct snode *pn;
{
  switchdef=pn->arg[0].i;
}

xicswent(pn)
struct snode *pn;
{
  printf("\tcmp\t#%d,r0\n",pn->arg[1].i);
  printf("\tjbeq\t.L%d\n",pn->arg[0].i);
}

xicswend(pn)
struct snode *pn;
{
  if (switchdef) printf("\tjra\t.L%d\n",switchdef);
}

xiccom(pn)
struct snode *pn;
{
  printf("*%s\n",pn->arg[0].pc);
}

xicjfend(pn)
struct snode *pn;
{
  printf("\tjra\t.L%d\n",funcend);
}

xicnequ(pn)
struct snode *pn;
{
  printf("%s\t.equ\t%d\n",pn->arg[0].pc,pn->arg[1].i);
}

xicsequ(pn)
struct snode *pn;
{
  printf("%s\t.equ\t%s\n",pn->arg[0].pc,pn->arg[1].pc);
}

xicvers(pn)
struct snode *pn;
{
  printf("*Translation by '%s', version 19880530\n",prgrname);
}

xicstrin(pn)
struct snode *pn;
{
  printf("\t.asciz\t\"%s\"\n",pn->arg[0].pc);
}

xiclangu(pn)
struct snode *pn;
{
  printf("* language = %s\n",taal[pn->arg[0].i]);
}

xicfile(pn)
struct snode *pn;
{
  printf("\t.file\t\"%s\"\n",pn->arg[0].pc);
}

xicln(pn)
struct snode *pn;
{
  error("can't translate icln yet");
}

xicdim(pn)
struct snode *pn;
{
  int *ph;
  int n;

  printf("\t.dim\t%d,",pn->arg[0].i);
  for (ph=(int*)pn->arg[1].i,n=pn->arg[0].i;n--;) {
    printf("%d",*ph++);
    if (n) printf(",");
  }
  puts("");
}

xichex(pn)
struct snode *pn;
{
  error("syntax of ichex unknown");
}

xpoint(pn,reg)
struct snode *pn;
{
  linenr=pn->arg[0].i;
  filena=pn->arg[1].pc;
}

xlb(pn,reg)
struct snode *pn;
{
  if (pn->arg[0].i!=curfnr) error("wrong function number");
  setlocx(pn,reg);                 /*stel waarde's in*/
}

xrb(pn,reg)
struct snode *pn;
{
}

xrp(pn,reg)
struct snode *pn;
{
  printf("%s\n",pn->arg[0].pc);
}

xUNDEF(pn)
struct snode *pn;
{
  errorn("unexpected intermediate code",pn->kode);
}

xname(pn,reg)
struct snode *pn;
{
  error("unmatchable name node");
}

xicon(pn,reg)
struct snode *pn;
{
  if (pn->arg[3].pc && *pn->arg[3].pc) {
    if (pn->arg[0].l) printf("\tmove\t#%s+%ld,r%d\n",
                             pn->arg[3].pc,pn->arg[0].l,reg);
    else          printf("\tmove\t#%s,r%d\n",pn->arg[3].pc,reg);
  }
  else printf("\tmove\t#%d,r%ld\n",pn->arg[0].l,reg);
  return reg;
}

xfcon(pn,reg)
struct snode *pn;
{
  error("unmatchable fcon node");
}

xunyminu(pn,reg)
struct snode *pn;
{
  unsigned w;

  xnode(pn->arg[0].pn);
}

xunymul(pn,reg)
struct snode *pn;
{
  register struct snode *p0,*p1,*pp;
  int reg2;

  pp=pn->arg[0].pn;  /*subnode*/
  p0=pp->arg[0].pn;
  p1=pp->arg[1].pn;
  if (pp->kode==PLUS && p0->kode==REG && p1->kode==ICON) {
    printf("\tmove\t");
    if (p1->arg[3].pc) printf("%s+",p1->arg[3].pc);
    printf("%ld(r%d),r%d\n",p1->arg[0].l,p0->arg[1].i,reg);
  }
  else if (pp->kode==MINUS && p0->kode==REG && p1->kode==ICON) {
    printf("\tmove\t");
    if (p1->arg[3].pc) printf("%s",p1->arg[3].pc);
    printf("-%ld(r%d),r%d\n",p1->arg[0].l,p0->arg[1].i,reg);
  }
  else {
    reg2=xnode(pp,-2);
    printf("\tmove\t(r%d),r%d\n",reg2,reg);
    putreg(reg2);
  }
  return reg;
}

xquest(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn,-1);
  xnode(pn->arg[1].pn->arg[0].pn,reg);
  xnode(pn->arg[1].pn->arg[1].pn,reg);
  return reg;
}

xcolon(pn,reg)
struct snode *pn;
{
  error("unexpected colon-node");
}

xandand(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn);
  xnode(pn->arg[1].pn);
}

xoror(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn);
  xnode(pn->arg[1].pn);
}

xgoto(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn);
}

xcm(pn,reg)
struct snode *pn;
{
  error("unexpected cm node");
}

xrevcm(pn,reg)
struct snode *pn;
{
  error("unexpected revcm node");
}

xpushex(pn)
struct snode *pn;
{
  int hulp;
  int reg;

  if (pn->kode==CM) {
    hulp=xpushex(pn->arg[1].pn);
    hulp+=xpushex(pn->arg[0].pn);
  }
  else if (pn->kode==REVCM) {
    hulp=xpushex(pn->arg[0].pn);
    hulp+=xpushex(pn->arg[1].pn);
  }
  else {
    reg=xnode(pn,-2);
    if (reg>=0) {
      printf("\tmove.l\tr%d,-(sp)\n",reg);
      putreg(reg);
      hulp=Astksize[reg>>3];  /*geef grootte terug*/
    }
    else hulp=0;
  }
  return hulp;
}

xsm(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn,-1);
  return xnode(pn->arg[1].pn,reg);
}

xassign(pi,reg)
struct snode *pi;
int    reg;
{
  unsigned w;
  register struct snode *pn=pi;
  char    *pa;

  w=regtype(pn->arg[2].i);
  reg=xnode(pn->arg[1].pn,reg);
  pa=xnodeadr(pn->arg[0].pn);
  printf("\tmove\tr%d,%s\n",reg,pa);
  return reg;
}

xcomop(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn,-1);
  return xnode(pn->arg[1].pn,reg);
}

xcall(pn,reg)
struct snode *pn;
{
  reg=xcallsub(pn->arg[0].pn,pn->arg[1].pn,reg);
  return reg;
}

xrevcall(pn,reg)
struct snode *pn;
{
  reg=xcallsub(pn->arg[1].pn,pn->arg[0].pn,reg);
  return reg;
}

xunycall(pn,reg)
struct snode *pn;
{
  reg=xcallsub(pn->arg[0].pn,0,reg);
  return reg;
}

xcallsub(p0,p1,reg)
struct snode *p0;
struct snode *p1;
{
  char *pa;
  int   hulp;

  hulp=p1?xpushex(p1):0;
  if (p0->kode==ICON) {
    if (p0->arg[3].pc && *p0->arg[3].pc) {
      if (p0->arg[0].l) printf("\tjbsr\t%s+%ld\n",p0->arg[3].pc,p0->arg[0].l);
      else printf("\tjbsr\t%s\n",p0->arg[3].pc);
    }
    else printf("\tjbsr\t.L%ld\n",p0->arg[0].l);
  }
  else {
    pa=xnodeadr(p0);
    printf("\tjbsr\t%s\n",pa);
  }
  if (hulp) printf("\tlea\t%d(sp),sp\n",hulp);
  if (reg==-2) reg=0;
  if (reg>0)   printf("\tmove\tr0,r%d\n",reg);  /*verplaats uit r0*/
  return reg;
}

xmonad(pn,reg,ps)
struct snode *pn;
{
  unsigned w;

  xnode(pn->arg[0].pn,reg);
  ocmd(ps,getwidth(pn->arg[2].i));
  printf("r%d\n",reg);
  return reg;
}

xnot(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn);
  return reg;
}

/*these should have been removed by the preprocessor!*/
xincr(pn,reg)
struct snode *pn;
{
  error("preprocessor error, ++ node not removed");
}

xdecr(pn,reg)
struct snode *pn;
{
  error("preprocessor error, -- node not removed");
}

xreg(pn,reg)
struct snode *pn;
{
  ocmd(reg>=16?"fpmove":"move",getwidth(pn->arg[2].i));
  if (reg>=16) printf("fp%d,fp%d\n",pn->arg[1].i-16,reg-16);
  else         printf("r%d,r%d\n",pn->arg[1].i,reg);
  return reg;
}

xoreg(pn,reg)
struct snode *pn;
{
  char *pa;

  ocmd("lea",szptr);
  pa=xnodeadr(pn);
  printf("%s,r%d\n",pa,reg);
  return reg;
}

xstasg(pn,reg)
struct snode *pn;
{
  error("no structures yet");
}

xstarg(pn,reg)
struct snode *pn;
{
  error("no structures yet");
}

xstcall(pn,reg)
struct snode *pn;
{
  error("no structures yet");
}

xrevstca(pn,reg)
struct snode *pn;
{
  error("no structures yet");
}

xunystcl(pn,reg)
struct snode *pn;
{
  error("no structures yet");
}

xfld(pn,reg)
struct snode *pn;
{
  error("no fields yet");
}

xsconv(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn);
}

xforce(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn,0);
}

xcbranch(pn,reg)
struct snode *pn;
{
  return xbranch(pn->arg[0].pn,0,(int)pn->arg[1].pn->arg[0].l);
}

xrevcbra(pn,reg)
struct snode *pn;
{
  return xbranch(pn->arg[1].pn,0,(int)pn->arg[0].pn->arg[0].l);
}

xinit(pn,reg)
struct snode *pn;
{
  xnode(pn->arg[0].pn);
}

xdyad(pi,reg,ps,flag)
struct snode *pi;
char         *ps;  /*vertaling*/
{
  unsigned w,n0,n1,nn;
  struct   snode *poreg,*ph;
  register struct snode *pn=pi;
  int      disp;
  int      reg2;

  diag("xdyad"); diah(pn,reg);
  w=regtype(pn->arg[2].i);          /*get register type for result*/
  nn=pn->nreg[w];
  n0=pn->arg[0].pn->nreg[w];
  n1=pn->arg[1].pn->nreg[w];
  if (flag & REVERSED) {
    if (n0) {
      reg2=getreg(w);
      xnode(pn->arg[0].pn,reg2);
    }
    xnode(pn->arg[1].pn,reg);
    if (flag & FSHIFT) printf(issigned(pn->arg[2].i)?"a":"l");
    ocmd(ps,getwidth(pn->arg[1].i));
    if (n0) printf("r%d",reg2);
    else    xnodeadm(pn->arg[0].pn);
    printf(",r%d",reg);
    if (n0) putreg(reg2);
  }
  else {
    xnode(pn->arg[0].pn,reg);
    if (n1) {
      reg2=getreg(w);
      xnode(pn->arg[1].pn,reg2);
    }
    if (flag & FSHIFT) printf(issigned(pn->arg[2].i)?"a":"l");
    ocmd(ps,getwidth(pn->arg[1].i));
    if (n1) printf("r%d",reg2);
    else    xnodeadm(pn->arg[1].pn);
    printf(",r%d",reg);
    if (n1) putreg(reg2);
  }
  puts("");
}

xcomp(pn,reg)
{
  error("can't translate compare's, with result in register yet");
}

static struct sfunc ic00x[]={
/*  0*/
  {xicUNDEF},
  {osimp   ,".even"},  /*icalign*/
  {osimp   ,".text"},  /*ictext*/
  {osimp   ,".data"},  /*icdata*/
  {osimp   ,".bss" },  /*icbss*/
  {xiclong },
  {owithnum,".word"},  /*icword*/
  {owithnum,".byte"},  /*icbyte*/
  {xicbytes},
  {xicdlabn},
/* 10*/
  {xicdlabs},
  {xicjlabn},
  {xicjlabs},
  {xicfbeg },
  {xicfend },
  {xicUNDEF},
  {owithnum,".skip"},  /*icskip*/
  {xiccomm },
  {osimp   ,".text"},  /*icinit*/
  {xicswtch},
/* 20*/
  {xicswdef},
  {xicswent},
  {xicswend},
  {xiccom  },
  {owithstr,".globl"},  /*icglobl*/
  {xicjfend},
  {xicnequ },
  {xicsequ },
  {xicvers },
  {owithstr,".long"},  /*icaddr*/
/* 30*/
  {xicstrin},
  {xicUNDEF},
  {xicUNDEF},
  {xiclangu},
  {osimp   ,"nop"},    /*icnop*/
  {owithstr,"jbsr"},   /*icjsr*/
  {osimp   ,"rts"},    /*icrts*/
  {xicfile },
  {xicln   },
  {owithstr,".def"},   /*icdef*/
/* 40*/
  {osimp   ,"endef"},  /*icendef*/
  {owithnum,".val"},   /*icval*/
  {owithnum,".type"},  /*ictype*/
  {owithnum,".scl"},   /*icscl*/
  {owithstr,".tag"},   /*ictag*/
  {owithnum,".line"},  /*icline*/
  {owithnum,".size"},  /*icsize*/
  {xicdim  },
  {owithstr,".vals"},  /*icvals*/
  {xichex  },
/* 50*/
  {owithstr,".float"}, /*icfloat*/
  {owithstr,".double"} /*icdoubl*/
};

static struct sfunc ic290x[]={
/*290*/
  {xpoint  },
  {xlb     },
  {xrb     },
  {xrp     }
};

static struct sfunc nu00x[]={
/*  0*/
  {xUNDEF  },
  {xUNDEF  },
  {xname   },
  {xUNDEF  },
  {xicon   ,    0,INREG},
  {xfcon   ,    0,INREG},
  {xdyad   ,"add",INREG|REVBLE},  /*plus*/
  {xdyad   ,"add",INREG},         /*asgplus*/
  {xdyad   ,"sub",INREG},         /*minus*/
  {xdyad   ,"sub",INREG},         /*asgminus*/
/* 10*/
  {xmonad  ,"neg",INREG},         /*unyminu*/
  {xdyad   ,"mul",INREG|REVBLE},  /*mul*/
  {xdyad   ,"mul",INREG},         /*asgmul*/
  {xunymul ,    0,INREG},
  {xdyad   ,"and",INREG|REVBLE},  /*and*/
  {xdyad   ,"and",INREG},         /*asgand*/
  {xUNDEF  },
  {xdyad   ,"or" ,INREG|REVBLE},  /*or*/
  {xdyad   ,"or" ,INREG},         /*asgor*/
  {xdyad   ,"eor",INREG|REVBLE},  /*eor*/
/* 20*/
  {xdyad   ,"eor",INREG},         /*asgeor*/
  {xquest  },
  {xcolon  },
  {xandand },
  {xoror   },
  {xUNDEF  },{xUNDEF},{xUNDEF},{xUNDEF},{xUNDEF},
/* 30*/
  {xUNDEF  },{xUNDEF},{xUNDEF},{xUNDEF},{xUNDEF},
  {xUNDEF  },{xUNDEF},
  {xgoto   },
  {xUNDEF  },{xUNDEF},
/* 40*/
  {xUNDEF  },{xUNDEF},{xUNDEF},{xUNDEF},{xUNDEF},
  {xUNDEF  },{xUNDEF},{xUNDEF},{xUNDEF},{xUNDEF},
/* 50*/
  {xUNDEF  },{xUNDEF},{xUNDEF},{xUNDEF},{xUNDEF},
  {xUNDEF  },
  {xcm     },
  {xsm     },
  {xassign ,0,INREG},
  {xcomop  },
/* 60*/
  {xdyad   ,"div",INREG|0},       /*div*/
  {xdyad   ,"div",INREG|0},       /*asgdiv*/
  {xdyad   ,"div",INREG|FMOD},    /*mod*/
  {xdyad   ,"div",INREG|FMOD},    /*asgmod*/
  {xdyad   , "sl",INREG|FSHIFT},  /*ls*/
  {xdyad   , "sl",INREG|FSHIFT},  /*asgls*/
  {xdyad   , "sr",INREG|FSHIFT},  /*rs*/
  {xdyad   , "sr",INREG|FSHIFT},  /*asgrs*/
  {xUNDEF  },
  {xUNDEF  },
/* 70*/
  {xcall   },
  {xUNDEF  },
  {xunycall},
  {xUNDEF  },
  {xUNDEF  },
  {xUNDEF  },
  {xmonad  ,"com",INREG},  /*compl*/
  {xnot    },
  {xincr   },
  {xdecr   },
/* 80*/
  {xcomp   ,0,INREG},  /*eq*/
  {xcomp   ,0,INREG},  /*ne*/
  {xcomp   ,0,INREG},  /*le*/
  {xcomp   ,0,INREG},  /*lt*/
  {xcomp   ,0,INREG},  /*ge*/
  {xcomp   ,0,INREG},  /*gt*/
  {xcomp   ,0,INREG},  /*ule*/
  {xcomp   ,0,INREG},  /*ult*/
  {xcomp   ,0,INREG},  /*uge*/
  {xcomp   ,0,INREG},  /*ugt*/
/* 90*/
  {xUNDEF  },
  {xUNDEF  },
  {xUNDEF  },
  {xdyad   ,"asr",0},  /*ars*/
  {xreg    },
  {xoreg   },
  {xUNDEF  },
  {xUNDEF  },
  {xstasg  },
  {xstarg  },
/*100*/
  {xstcall },
  {xUNDEF  },
  {xunystcl},
  {xfld    },
  {xsconv  ,0,INREG},
  {xUNDEF  },{xUNDEF},{xUNDEF},
  {xforce  },
  {xcbranch},
/*110*/
  {xinit   },
  {xUNDEF  },{xUNDEF},{xUNDEF},{xUNDEF},
  {xUNDEF  },{xUNDEF},{xUNDEF},{xUNDEF},{xUNDEF},
/*120*/
  {xrevcall},
  {xrevstca},
  {xrevcm  },
  {xdyad   ,"sub",INREG|REVERSED},         /*revminus*/
  {xdyad   ,"div",INREG|REVERSED},         /*revdiv*/
  {xdyad   ,"div",INREG|REVERSED|FMOD},    /*revmod*/
  {xdyad   , "sl",INREG|REVERSED|FSHIFT},  /*revls*/
  {xdyad   , "sr",INREG|REVERSED|FSHIFT},  /*revrs*/
  {xdyad   ,"asr",INREG|REVERSED},         /*revars*/
  {xrevcbra}
};

/*xlate node*/
xnode(pn,reg)
struct snode *pn;
{
  int kode;
  int w;

  diag("xnode"); diah(pn);
  if (pn) {
    level--;
    kode=pn->kode;
    if (kode>=0&&kode<130) {
      if (reg==-2) {
        w=nodetype(pn);
        reg=getreg(w);
        xnode(pn,reg);
      }
      else if (reg==-1 && nu00x[kode].para&INREG) {
        w=nodetype(pn);
        reg=getreg(w);
        xnode(pn,reg);
        reg=putreg(reg);
      }
      else reg=(*nu00x[kode].func)(pn,reg,nu00x[kode].pstring,
                                          nu00x[kode].para);
    }
    else if (kode>=1000 && kode<1052) {
      reg=(*ic00x[kode-1000].func)(pn,ic00x[kode-1000].pstring,
                                      ic00x[kode-1000].para);
    }
    else if (kode>=1290 && kode<1294) reg=(*ic290x[kode-1290].func)(pn);
    else {
      errorn("unknown kode to xlate = %d",kode);
      reg=-1;
    }
    level++;
  }
  return reg;
}

/*
evaluate p for truth value, and branch to ltrue or lfalse accordingly:
label==0 means fall through
deze routine is gebaseerd op die van de portable c compiler
*/
xbranch(pn,ltrue,lfalse)
struct snode *pn;
int ltrue,lfalse;
{
  register ko,o,lab,flab,tlab;
  char    *ps;
  int      reg;

  switch (o=pn->kode) {
  case ULE:
  case ULT:
  case UGE:
  case UGT:
  case EQ:
  case NE:
  case LE:
  case LT:
  case GE:
  case GT:
    if (ltrue==0) {
      o=Anegrel[o-EQ];
      ltrue=lfalse;
      lfalse=0;
    }
    if (pn->arg[1].pn->kode==ICON && pn->arg[1].pn->arg[0].l==0 &&
        (pn->arg[1].pn->arg[3].pc==0 || *pn->arg[1].pn->arg[3].pc==0)) {
      switch (o) {
      case UGT:
      case ULE: o=(o==UGT)?NE:EQ;
      case EQ:
      case NE:
      case LE:
      case LT:
      case GE:
      case GT:
        if (ps=Accbranz[o-EQ]) {
          reg=xnode(pn->arg[0].pn,-2);
          tstres(reg);
          printf(" lb%s .L%d\n",ps,ltrue);
        }
        else goto labccz;            /*le0 en gt0 niet zo simpel*/
        break;
      case UGE: obra(ltrue); break;  /*unconditional branch*/
      case ULT: break;               /*do nothing for LT*/
      }
    }
    else {
labccz:
      printf("cmpb ,s+\tcmpb ,s+\tcmpd ,s++\tcmpd ,s++\n");
      printf(" jb%s .L%d\n",Accbranc[o-EQ],ltrue);
    }
    if (lfalse) obra(lfalse);
    break;
  case ANDAND:
    lab=(lfalse==0)? getlabn() : lfalse;
    xbranch(pn->arg[0].pn,0   ,lab);
    xbranch(pn->arg[1].pn,ltrue,lfalse);
    if (lfalse==0) olabn(lab);
    break;
  case OROR:
    lab=(ltrue==0)? getlabn() : ltrue;
    xbranch(pn->arg[0].pn,lab  ,0);
    xbranch(pn->arg[1].pn,ltrue,lfalse);
    if (ltrue==0) olabn(lab);
    break;
  case NOT:
    xbranch(pn->arg[0].pn,lfalse,ltrue);
    break;
  case COMOP:
    xnode(pn->arg[0].pn);
    xbranch(pn->arg[1].pn,ltrue,lfalse);
    break;
  case QUEST:
    flab=(lfalse==0)? getlabn() : lfalse;
    tlab=(ltrue ==0)? getlabn() : ltrue;
    xbranch(pn->arg[0].pn,0,lab=getlabn());
    xbranch(pn->arg[1].pn->arg[0].pn,tlab,flab);
    olabn(lab);
    xbranch(pn->arg[1].pn->arg[1].pn,ltrue,lfalse);
    if (ltrue==0)  olabn(tlab);
    if (lfalse==0) olabn(flab);
    break;
  case ICON:
    if (pn->arg[2].i!=FLOAT && pn->arg[2].i!=DOUBLE) {
      if (pn->arg[0].l || pn->arg[3].pc && *pn->arg[3].pc) {
        /*addresses of C objects are never 0*/
        if (ltrue) obra(ltrue);
      }
      else if (lfalse) obra(lfalse);
      return;
    }
    /*fall through to default with other strange constants*/
  default:
    xnode(pn);
    tstres(reg);
    if (ltrue)  cbgen(NE,ltrue);
    if (lfalse) cbgen(ltrue ? 0 : EQ,lfalse);
  }
}

/*Generate code for a conditional branch*/
cbgen(o,lab)
{
  if (o) printf("\tb%s\t.L%d\n",Accbranc[o-EQ],lab);
  else   obra(lab);
}

/*als de CC's nog niet gezet zijn, doen we dat alsnog*/
tstres(reg,w)
{
  if (flags) {}
  else       printf("\ttst.x\tr%d\n",reg);
}

obra(lab)
{
  printf("\tjbra\t.L%d\n",lab);
}

/*vertaal addressingmode or constant*/
xnodeadm(pi)
struct snode *pi;
{
  register struct snode *pn=pi,*pp;

  switch (pn->kode) {
  case ICON:
    if (pn->arg[3].pc && *pn->arg[3].pc) {
      if (pn->arg[0].l) printf("#%s+%ld",pn->arg[3].pc,pn->arg[0].l);
      else printf("#%s",pn->arg[3].pc);
    }
    else printf("#%ld",pn->arg[0].l);
    break;
  case UNY MUL:
    pp=pn->arg[0].pn;
    if (pp->kode==PLUS || pp->kode==MINUS) {
      if (pp->arg[0].pn->kode==REG && pp->arg[1].pn->kode==ICON) {
        if (pp->arg[1].pn->arg[0].l) {
          printf("%s%ld(a%d)",pp->kode==MINUS?"-":"",
                              pp->arg[1].pn->arg[0].l,
                              pp->arg[0].pn->arg[1].i);
        }
        else printf("(r%d)",pp->arg[0].pn->arg[1].i);
      }
      else error("unexpected unary mul");
    }
    else error("unexpected unary mul");
    break;
  default: error("can't translate this addressing mode yet");
  }
}    

ocmd(ps,w)
{
  printf("\t%s.%c\t",ps,Awidch[w]);
}

issigned(ty)
{
  return ty<USHORT;
}

setlocx()
{
  error("no setlocx yet");
}

char *xnodeadr()
{
  error("no xnodeadr yet");
  return "ea";
}

olabn(labn)
{
  printf(".L%d\n",labn);
}

/*hulp routines*/

/*stel de registeraantallen en vlaggen in*/
setregs(n0,n1,n2)
{
  int n;

  for (n=000;n<010;n++) Areguse[n]=(n>=n0);  /*init register flags*/
  for (     ;n<020;n++) Areguse[n]=(n>=n1);
  for (     ;n<030;n++) Areguse[n]=(n>=n2);
}

getreg(type)
int type;
{
  unsigned n,w;

  diag("getreg");
  w=regtype(type);
  if (f_diag) printf("w = %d\n",w);
  for (n=w*8+8;--n>=w*8;) {
    if (Areguse[n]==FALSE) {
      Areguse[n]=TRUE;            /*now in use*/
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
  if (Areguse[n]==FALSE) {
    Areguse[n]=TRUE;            /*now in use*/
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
  Areguse[n]=FALSE;  /*niet meer in gebruik*/
}

/*end*/
