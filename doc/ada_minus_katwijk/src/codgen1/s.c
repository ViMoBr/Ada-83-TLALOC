/*
  s.c
  splits boom indien nodig
  19880806/wjvg
*/

#include  "def.h"
#include  "mknode.h"

#define ASGDYAD 0x01    /*is het een assign dyad?*/
#define TWOSUB  0x02    /*two subnode's?*/

extern char f__rev;     /*mogen we minus etc. omkeren?*/
extern char f_xbra;     /*branch uit elkaar halen?*/
extern char *prgrname;  /*naam van dit programma*/

extern int Anegrel[];   /*inversen voor compare kode's, zie h.c*/
extern int type;

extern unsigned Amaxreg[3];  /*0..8, number of regs per kind*/
extern unsigned Aminreg[3];  /*0..8, minimum nr of regs per kind*/
extern unsigned curfnr;      /*nummer van huidige funktie*/
extern unsigned linenr;

char  *filena;

static int level;     /*hoe hoog zit snode in de boom? (telt negatief)*/
static int stacklst;  /*laatstverzonden stack stand, min..0*/
static int stackmin;  /*tot hoe diep is de stack in gebruik geweest?*/
static int stacknow;  /*vanaf waar is de stack nu in gebruik?, min..0*/
static int stackorg;  /*hoe groot de stk volgens het front-end is, min..0*/
static int stkminfe;  /*minimale frame grens volgens front-end, (statist)*/
static int stkminfu;  /*minimale frame grens volgens dit prgr, (statist)*/

static unsigned Anreg[3];  /*0..8, current nr of regs per kind*/
static unsigned n_cbra;    /*hoeveel cbranches gesplitst?*/
static unsigned n_stck;    /*statistics: totale stackexpansie*/
static unsigned n_stor;    /*statistics: aantal pushes per file*/
static unsigned curfnr;    /*nummer van huidige funktie*/
static unsigned linenr;    /*nummer van huidige regel*/

struct snode *dupnode(),*sbranch(),*snode(),*mkleaf(),*mkmonad(),*mkdyad();
struct snode *mkcbranc(),*mkicnode(),*mkcomop();
char         *dupstr();

struct snode *sUNDEF(pn)
register struct snode *pn;
{
  errorn("unexpected intermediate code",pn->kode);
  return pn;
}

/*geef terug zonder er iets mee te doen*/
struct snode *sleaf(pn)
register struct snode *pn;
{
  return pn;
}

/*geef terug na het splitsen van 1 subtree*/
struct snode *smonad(pn)
register struct snode *pn;
{
  pn->arg[0].pn=snode(pn->arg[0].pn);
  return pn;
}

/*geef terug na het splitsen van 2 subtree's*/
struct snode *sboth(pn)
register struct snode *pn;
{
  pn->arg[0].pn=snode(pn->arg[0].pn);
  pn->arg[1].pn=snode(pn->arg[1].pn);
  return pn;
}

/*behandel call nodes*/
struct snode *scall(pn,flag)
struct snode *pn;
int    flag;
{
  /*kijk of er genoeg registers zijn*/
  if (pn->nreg[0]>Anreg[0])
    error("maybe not enough data registers for call");
  if (pn->nreg[1]>Anreg[1])
    error("maybe not enough address registers for call");
  if (pn->nreg[2]>Anreg[2])
    error("maybe not enough floating point registers for call");
  pn->arg[0].pn=snode(pn->arg[0].pn);
  if (flag&TWOSUB) pn->arg[1].pn=snode(pn->arg[1].pn);
  return pn;
}

struct snode *scbranch(pn)
register struct snode *pn;
{
  register struct snode *p0,*p1;

  p0=pn->arg[0].pn=snode(pn->arg[0].pn);
  p1=pn->arg[1].pn=snode(pn->arg[1].pn);
  if (f_xbra && p1->kode==ICON &&
      (p1->arg[3].pc==0 || *p1->arg[3].pc==0)) {
    /*cbranch uitrafelen?*/
    free(pn);
    pn=sbranch(p0,0,(int)p1->arg[0].l);
    free(p1);
  }
  return pn;
}

struct snode *srevcbra(pn)
register struct snode *pn;
{
  register struct snode *p0,*p1;

  p0=pn->arg[0].pn=snode(pn->arg[0].pn);
  p1=pn->arg[1].pn=snode(pn->arg[1].pn);
  if (f_xbra && p0->kode==ICON &&
      (p0->arg[3].pc==0 || *p0->arg[3].pc==0)) {
      /*revcbranch uitrafelen?*/
    free(pn);
    pn=sbranch(p1,0,(int)p0->arg[0].l);
    free(p0);
  }
  return pn;
}

/*splits dyad-, asgdyad- of assign-boom indien nodig*/
struct snode *sdyad(pn,flag)
struct snode *pn;
unsigned flag;
{
  unsigned regt;
  register struct snode *p0,*p1;
  struct   snode *poreg,*ph;
  unsigned stackold;
  int      n;

  diag("sdyad"); diah(pn);
  regt=regtype(pn->arg[2].i);   /*get register type for result*/
  p0=pn->arg[0].pn;
  p1=pn->arg[1].pn;
  /*probleem op dit nivo?*/
  if (pn->flag&INCRDATA && pn->nreg[regt]>Anreg[regt] ||
      pn->flag&INCRADDR && pn->nreg[   1]>Anreg[   1]) {
    p1=pn->arg[1].pn=snode(p1);                    /*splits expr1*/
    stackold=stacknow;                             /*bewaar stackgrootte*/
    stacknow-=getstsize(type);                     /*verlaag stackpointer*/
    stacknow&= -getalign(type);                    /*align*/
    if (stacknow<stackmin) stackmin=stacknow;      /*houd minimum bij*/
    poreg=mkoreg((long)stacknow,14,pn->arg[2].i);  /*tmp dest op stk*/
    ph=mkassign(poreg,p1,pn->arg[2].i);            /*zet op stk*/
    n_stor++;                                      /*statistics*/
    p0=pn->arg[0].pn=snode(p0);                    /*splits expr0*/
    p1=pn->arg[1].pn=dupnode(poreg);               /*dupliceer ex1*/
    pn=mkcomop(ph,pn,pn->arg[2].i);
    stacknow=stackold;                             /*herstel stack*/
  }
  else {
    pn->arg[0].pn=snode(p0);  /*splits expr0*/
    pn->arg[1].pn=snode(p1);  /*splits expr1*/
  }
  return pn;
}

/*
  evaluate p for truth value, and branch to ltrue or lfalse accordingly:
  label==0 means fall through
  deze routine is gebaseerd op die van de portable c compiler
*/
struct snode *sbranch(pn,ltrue,lfalse)
struct snode *pn;
{
  register struct snode *p0,*p1;
  register struct snode *po;
  unsigned ko,lab,flab,tlab;

  p0=pn->arg[0].pn;
  p1=pn->arg[1].pn;
  po=0;
  switch (ko=pn->kode) {
  case EQ:
  case NE:
  case LE:
  case LT:
  case GE:
  case GT:
  case ULE:
  case ULT:
  case UGE:
  case UGT:
    if (lfalse==0) {
      ko=Anegrel[ko-EQ];
      lfalse=ltrue;
      ltrue=0;
    }
    po=mkcbrani(mkdyad(ko,p0,p1,pn->arg[2].i),lfalse);
    if (ltrue) icjlabn(ltrue);
    break;
  case ANDAND:
    lab=(lfalse==0)?getlabn():lfalse;
    po=sbranch(p0,0,lab);
    po=mkcomop(po,sbranch(p1,ltrue,lfalse));
    if (lfalse==0) po=mkcomop(po,icdlabn(lab));
    n_cbra++;  /*statistiek*/
    break;
  case OROR:
    lab= (ltrue==0)?getlabn():ltrue;
    po=sbranch(p0,lab  ,0);
    po=mkcomop(po,sbranch(p1,ltrue,lfalse));
    if (ltrue==0) po=mkcomop(po,icdlabn(lab));
    n_cbra++;  /*statistiek*/
    break;
  case NOT:
    po=sbranch(p0,lfalse,ltrue);
    break;
  case COMOP:
    po=mkcomop(p0,sbranch(p1,ltrue,lfalse));
    n_cbra++;  /*statistiek*/
    break;
  case QUEST:
    flab= (lfalse==0)?getlabn():lfalse;
    tlab= (ltrue ==0)?getlabn():ltrue;
    lab=getlabn();
    po=sbranch(p0,0,lab);
    po=mkcomop(po,sbranch(pn->arg[1].pn,tlab,flab));
    po=mkcomop(po,icdlabn(lab));
    po=mkcomop(po,sbranch(p1->arg[1].pn,ltrue,lfalse));
    if (ltrue ==0) po=mkcomop(po,icdlabn(tlab));
    if (lfalse==0) po=mkcomop(po,icdlabn(flab));
    free(p1);
    n_cbra++;  /*statistiek*/
    break;
  case ICON:
    if (pn->arg[2].i!=FLOAT && pn->arg[2].i!=DOUBLE) {
      if (pn->arg[0].l || pn->arg[3].pc && *pn->arg[3].pc) {
        /*addresses of C objects are never 0*/
        if (ltrue) po=icjlabn(ltrue);
      }
      else if (lfalse) po=icjlabn(lfalse);
      break;
    }
    /*no break*/
  default:
    if (lfalse) {
      po=mkcbrani(pn,lfalse);
      if (ltrue) po=mkcomop(po,icjlabn(ltrue));
    }
    else {
      po=mkcbrani(mknot(pn,pn->arg[2].i),ltrue);
    }
  }
  free(pn);
  return po;
}

struct snode *sicfbeg(pn)
register struct snode *pn;
{
  curfnr=pn->arg[0].i;
  stkminfe=0;       /*houd bij, hoe laag de stack komt volgens frontend*/
  stkminfu=0;       /*houd bij, hoe laag de stack komt volgens dit prgr*/
  return pn;
}

struct snode *slb(pn)
register struct snode *pn;
{
  int n;
  int nstack;    /*stackpointer tov framepointer, negatief!*/
  int n0,n1,n2;  /*laagste register per soort, in gebruik 0..8*/

  if (pn->arg[0].i!=curfnr) error("wrong function number");
  nstack= -(pn->arg[1].i>>3);
  n0=pn->arg[2].i+1;
  n1=pn->arg[3].i-7;
  n2=pn->arg[4].i-15;
  stacklst=         /*laatst verzonden stackgrootte*/
  stackmin=         /*stack minimum*/
  stacknow=         /*huidige stack*/
  stackorg=nstack;  /*stack volgens front end*/
  if (stackorg<stkminfu) stkminfu=stackorg;  /*laagst van dit prgr, per fn*/
  if (stackorg<stkminfe) stkminfe=stackorg;  /*laagst van frontend, per fn*/
  /*kijk of er genoeg registers zijn*/
  if ((Anreg[0]=n0)<Aminreg[0]) error("not enough data registers free");
  if ((Anreg[1]=n1)<Aminreg[1]) error("not enough address registers free");
  if ((Anreg[2]=n2)<Aminreg[2]) error("not enough fp registers free");
  /*beperk het aantal registers tbv testen*/
  for (n=0;n<3;n++) if (Anreg[n]>Amaxreg[n]) Anreg[n]=Amaxreg[n];
  return pn;
}

/*deze routine wordt ook aangeroepen door stat_s*/
struct snode *sicfend(pn)
register struct snode *pn;
{
  n_stck+=stkminfe-stkminfu;  /*hoeveel extra posities aangemaakt?*/
  stkminfe=0;       /*houd bij, hoe laag de stack komt volgens frontend*/
  stkminfu=0;       /*houd bij, hoe laag de stack komt volgens dit prgr*/
  return pn;
}

struct snode *sicvers(pn)
register struct snode *pn;
{
  char   buftmp[200];

  sprintf(buftmp,"Register usage restriction by %s, version 19880715\n",prgrname);
  return mkcomop(iccom(dupstr(buftmp)),pn);
}

struct snode *spoint(pn)
register struct snode *pn;
{
  linenr=pn->arg[0].i;
  filena=pn->arg[1].pc;
  return pn;
}

static struct sfunc {
  struct   snode *(*func)();
  unsigned para;
} nu00s[]={
/*  0*/
  {sUNDEF  },{sUNDEF},
  {sleaf   },          /*name*/
  {sUNDEF  },
  {sleaf   },          /*icon*/
  {sleaf   },          /*fcon*/
  {sdyad   },          /*plus*/
  {sdyad   ,ASGDYAD},  /*asgplus*/
  {sdyad   },          /*minus*/
  {sdyad   ,ASGDYAD},  /*asgminus*/
/* 10*/
  {smonad  },          /*unyminus*/
  {sdyad   },          /*mul*/
  {sdyad   ,ASGDYAD},  /*asgmul*/
  {smonad  },          /*unymul*/
  {sdyad   },          /*and*/
  {sdyad   ,ASGDYAD},  /*asgand*/
  {sUNDEF  },
  {sdyad   },          /*or*/
  {sdyad   ,ASGDYAD},  /*asgor*/
  {sdyad   },          /*eor*/
/* 20*/
  {sdyad   ,ASGDYAD},  /*asgeor*/
  {sboth   },          /*quest*/
  {sboth   },          /*colon*/
  {sboth   },          /*andand*/
  {sboth   },          /*oror*/
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },
/* 30*/
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },
  {smonad  },          /*goto*/
  {sUNDEF  },{sUNDEF},
/* 40*/
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
/* 50*/
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sboth   },          /*cm*/
  {sboth   },          /*sm*/
  {sdyad   ,ASGDYAD},  /*assign*/
  {sboth   },          /*comop*/
/* 60*/
  {sdyad   },          /*div*/
  {sdyad   ,ASGDYAD},  /*asgdiv*/
  {sdyad   },          /*mod*/
  {sdyad   ,ASGDYAD},  /*asgmod*/
  {sdyad   },          /*ls*/
  {sdyad   ,ASGDYAD},  /*asgls*/
  {sdyad   },          /*rs*/
  {sdyad   ,ASGDYAD},  /*asgrs*/
  {sUNDEF  },
  {sUNDEF  },
/* 70*/
  {scall   ,TWOSUB},  /*call*/
  {sUNDEF  },
  {scall   },  /*unycall*/
  {sUNDEF  },
  {sUNDEF  },
  {sUNDEF  },
  {smonad  },  /*compl*/
  {smonad  },  /*not*/
  {smonad  },  /*incr*/
  {smonad  },  /*decr*/
/* 80*/
  {sdyad   },  /*eq*/
  {sdyad   },  /*ne*/
  {sdyad   },  /*le*/
  {sdyad   },  /*lt*/
  {sdyad   },  /*ge*/
  {sdyad   },  /*gt*/
  {sdyad   },  /*ule*/
  {sdyad   },  /*ult*/
  {sdyad   },  /*uge*/
  {sdyad   },  /*ugt*/
/* 90*/
  {sUNDEF  },
  {sUNDEF  },
  {sUNDEF  },
  {sUNDEF  },  /*ars*/
  {sleaf   },  /*reg*/
  {sleaf   },  /*oreg*/
  {sUNDEF  },
  {sUNDEF  },
  {sboth   },  /*stasg*/
  {smonad  },  /*starg*/
/*100*/
  {scall   ,TWOSUB},  /*stcall*/
  {sUNDEF  },
  {scall   },  /*unystcl*/
  {smonad  },  /*fld*/
  {smonad  },  /*sconv*/
  {sUNDEF  },
  {sUNDEF  },
  {sUNDEF  },
  {smonad  },  /*force*/
  {scbranch},
/*110*/
  {smonad  },          /*init*/
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },{sUNDEF},
  {sUNDEF  },
/*120*/
  {scall   ,TWOSUB},  /*revcall*/
  {scall   ,TWOSUB},  /*revstcall*/
  {sboth   },  /*revcm*/
  {sdyad   },  /*revminus*/
  {sdyad   },  /*revdiv*/
  {sdyad   },  /*revmod*/
  {sdyad   },  /*revls*/
  {sdyad   },  /*revrs*/
  {sdyad   },  /*revars*/
  {srevcbra}
};

static struct sfunc ic290s[]={
/*290*/
  {spoint  },
  {slb     },
  {sleaf   },  /*rb*/
  {sleaf   }   /*rp*/
};

/*splits node indien nodig*/
struct snode *snode(pn)
register struct snode *pn;
{
  register unsigned kode;

  diag("snode"); diah(pn);
  if (pn) {
    level--;
    kode=pn->kode;
    if (kode<130) pn=(*nu00s[kode].func)(pn,nu00s[kode].para);
    else if (kode>=1000 && kode<1052) {            /*ic-ickode?*/
      if      (kode==1000+ICFBEG) pn=sicfbeg(pn);
      else if (kode==1000+ICVERS) pn=sicvers(pn);
      else if (kode==1000+ICFEND) pn=sicfend(pn);
    }
    else if (kode>=1290 && kode<1294) pn=(*ic290s[kode-1290].func)(pn);
    else errorn("unknown tree to split, kode = %d",kode);
    level++;
  }
  return pn;
}

/*
  geef reserveringsnode terug, indien stack gewijzigd is
  wordt aangeroepen vanuit m.c!
*/
struct snode *chgframe()
{
  register struct snode *pn;

  diag("chgframe");
  /*we sturen alleen als er wat gewijzigd is:*/
  if (stackmin<stacklst) {
    stacklst=stackmin;
    pn=iclb(curfnr,-(stacklst<<3),Anreg[0]-1,Anreg[1]+7,Anreg[2]+15);
    if (stacklst<stkminfu) stkminfu=stacklst;          /*statistics*/
    stackmin=stackorg;                  /*vanaf hier weer allokeren*/
  }
  else pn=0;
  return pn;
}

/*doe voorbereidende dingen voor deze module, per file*/
init_s()
{
  int n;

  for (n=0;n<3;n++) Anreg[n]=Amaxreg[n];  /*init aantallen registers*/
  /*init statistics*/
  n_cbra=
  n_stor=
  n_stck=0;
}

/*doe statistics per file*/
prtt_s()
{
  sicfend();  /*eventueel allocatie buiten funkties verwerken*/
  if (n_stor) fprintf(stderr,"]]] Store operations added: %u\n",n_stor);
  if (n_stck)
    fprintf(stderr,
            "]]] Framespace added, (in bytes over all functions): %u\n",
            n_stck);
  if (n_cbra) fprintf(stderr,"]]] CBRANCH and REVCBRAN's split: %u\n",n_cbra);
}

/*end*/
