/*
  c.c
  calculeer register behoeftes
  en transformeer de boom volgens de volgende vlaggen:
  f_incr = post-increment en -decrement nodes uitstellen?
  f_oreg = oregs maken ipv unymul(plus,minus)?
  f_revc = mogen reversed calls, stcalls and cbranches aangemaakt worden
           cq doorgegeven worden?
  f_revd = mag de executie-volgorde van met name dyads gewijzigd worden?

  bereken de benodigde aantallen registers per node, volgens:
  f_ltor = is de output voor een lr-parser?
  f_tfrc = wordt het resultaat van een funktie-call overgezet naar
           een nieuw register, met registernr>=2?
  19880723/wjvg
*/

#include  "def.h"

/*vlaggen om aan cmonad, cdyad en casgdyad mee te geven*/
#define REVBLE   0x001  /*commutatieve bewerking*/
#define FORCE0   0x002  /*eerste lid altijd in register*/
#define FORCE1   0x004  /*tweede lid altijd in register*/
#define SHIFT68  0x008  /*maximaal 8 schuiven?*/
#define CONV8    0x010  /*8 bits values konverteren?*/
#define TWOREG   0x020  /*twee registers nodig voor bewerking, bijv mod*/
#define RESINT   0x040  /*resultaat altijd in INT reg, voor cmp*/
#define RVSHFT68 0x080  /*reversed shift operation*/
#define LEFTEA   0x100  /*can dest be <ea>?*/
#define RIGHTEA  0x200  /*can sour be <ea>?*/
#define FPTOEA   0x400  /*mag fp naar ea als dest?, alleen voor assign zelf*/
#define ASGDYAD  0x800  /*is het een assign dyad of gewone assign?*/

/*vlaggen om aan ccall() mee te geven*/
#define REVERSED 0x001  /*reversed subnode's, igv revcall*/

extern char f_incr;    /*postpone incr/decr?*/
extern char f_ltor;    /*is de volgende pass een lr parser?*/
extern char f_oreg;    /*oreg's genereren?*/
extern char f_revc;    /*calls omdraaien?*/
extern char f_revd;    /*dyads omdraaien?*/
extern char f_tfrc;    /*resultaat van call, overzetten naar ander reg?*/

extern int  regt;      /*register soort van laatste node of subnode*/
extern int  type;      /*type van laatste node of subnode*/
extern int  width;     /*register breedte van laatste node of subnode*/

/*hoeveel registers maakt funktie stuk?*/
static int Afunkstuk[3]={2,2,2};

static unsigned n___cm;  /*hoeveel cm  's reversed?*/
static unsigned n_call;  /*hoeveel call's reversed?*/
static unsigned n_cbra;  /*hoeveel cbranches reversed?*/
static unsigned n_incr;  /*hoeveel incr's postponed?*/
static unsigned n_oreg;  /*hoeveel OREG's made?*/
static unsigned n_revd;  /*hoeveel dyad's reversed?*/

struct sfunc {
  struct snode *(*func)();
  int    para;
};

struct snode *cnode();    /*forward*/
struct snode *dupnode();

struct snode *cUNDEF(pn)
register struct snode *pn;
{
  errorn("unexpected intermediate code",pn->kode);
  regtype(INT);
  return pn;
}

/*
  Bepaal aantal registers voor leaf node, zoals name, icon, fcon, reg, oreg.
*/
struct snode *cleaf(pn)
register struct snode *pn;
{
  diag("cleaf");
  regtype(pn->arg[2].i);
  /*pn->nreg[0]=0; pn->nreg[1]=0; pn->nreg[2]=0;  is al zo in node*/
  return pn;
}

/*
  Bepaal het aantal registers voor een unary mul node.
  (Een waarde lezen van of schrijven naar een berekend adres.)
*/
struct snode *cunymul(pn)
register struct snode *pn;
{
  register struct snode *p0,*p00,*p01;
  unsigned n;
  int      type0;

  diag("cunymul");
  p0=pn->arg[0].pn;   /*subnode*/
  p00=p0->arg[0].pn;
  p01=p0->arg[1].pn;
  /*kijk of het een offset tov een adresregister is*/
  if ((p0->kode==PLUS || p0->kode==MINUS) &&
       p00->kode==REG && p00->arg[1].i>=8 && p00->arg[1].i<16 &&
       p01->kode==ICON) {
    if (p01->arg[3].pc==0 && f_oreg) {
      pn->kode=OREG;
      pn->arg[1].i=p00->arg[1].i;  /*regnr*/
      pn->arg[0].l=(p0->kode==PLUS)?p01->arg[0].l:-p01->arg[0].l;  /*offset*/
      free(p0);                    /*geef subnodes weer terug*/
      free(p00);
      free(p01);
      regtype(pn->arg[2].i);  /*zet type etc. nog goed, moet na cnode(sub)!*/
      n_oreg++;               /*houdt aantal bij*/
    }
    pn->nreg[0]=0; pn->nreg[1]=0; pn->nreg[2]=0;
  }
  else {
    p0=pn->arg[0].pn=cnode(p0);  /*bereken subnode*/
    type0=type;
    for (n=0;n<3;n++) pn->nreg[n]=p0->nreg[n];
    if (ISPTR(type0) && pn->nreg[1]==0) pn->nreg[1]=1;
    /*minstens adresregister voor pointer naar data*/
    regtype(pn->arg[2].i);  /*zet type etc. nog goed, moet na cnode(sub)!*/
  }
  return pn;
}

/*
  Bepaal aantal registers voor het vertalen van een monadische node.
*/
struct snode *cmonad(pn,flag)
struct snode *pn;
unsigned flag;
{
  register struct snode *p0;
  unsigned n;

  diag("cmonad");
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);
  regtype(pn->arg[2].i);
  for (n=0;n<3;n++) pn->nreg[n]=p0->nreg[n];  /*neem over*/
  if (flag&RESINT && regt==1) regt=0;         /*adres naar datareg?*/
  if (flag&FORCE0 && pn->nreg[regt]==0) pn->nreg[regt]=1;  /*forceren?*/
  return pn;
}

/*Bepaal aantal registers voor sconv-node.*/
struct snode *csconv(pn)
register struct snode *pn;
{
  register struct snode *p0;
  unsigned n;
  int      regt0,type0,width0;

  diag("csconv");
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);  /*bereken subnode*/
  type0=type;                             /*oude type*/
  regt0=regt;                             /*soort register van subtype*/
  width0=width;                           /*breedte van subtype*/
  regtype(pn->arg[2].i);
  for (n=0;n<3;n++) pn->nreg[n]=p0->nreg[n];  /*neem aantallen alvast over*/
  /*het volgende is zeer specifiek voor de 680x0:*/
#ifdef f68000
  if (regt==0 && regt0==0 &&
      width>width0 && ISUNSIGNED(type0) && pn->nreg[0]==1) {
    /*
      Als beide in dataregisters staan en het een vergroting is,
      waarbij het origineel unsigned is en al in een register staat,
      dan moet verplaats worden naar een ander register met nullen.
      Dus er is dan een extra register nodig.
    */
    pn->nreg[0]=2;
  }
#endif
  /*er zijn omzettingen van data naar adres registers en andersom:*/
  if (pn->nreg[regt0]==0) pn->nreg[regt0]=1;  /*forceer bron naar register*/
  if (pn->nreg[regt ]==0) pn->nreg[regt ]=1;  /*forceer doel naar register*/
  return pn;
}

/*
  Bepaal aantal registers voor quest-, colon-, andand-, oror-, sm-
  of comop-node.

  Het maximum aantal registers van de subleden is nodig.
*/
struct snode *cboth(pn)
register struct snode *pn;
{
  unsigned n;

  diag("cboth");
  pn->arg[0].pn=cnode(pn->arg[0].pn);
  pn->arg[1].pn=cnode(pn->arg[1].pn);
  regtype(pn->arg[2].i);          /*eig. niet nodig voor comop en sm*/
  for (n=0;n<3;n++)
    pn->nreg[n]=max(pn->arg[0].pn->nreg[n],pn->arg[1].pn->nreg[n]);
  return pn;
}

/*Bepaal het aantal registers voor een dyadische bewerking.*/
struct snode *cdyad(pn,flag)
register struct snode *pn;
unsigned flag;
{
  unsigned n,n0[3],n1[3];
  struct   snode *poreg;
  struct   snode *p0,*p1;
  int      hulp,regt0,regt1;

  diag("cdyad"); diah();
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);  /*calculeer eerste subexpr*/
  regt0=regt;
  p1=pn->arg[1].pn=cnode(pn->arg[1].pn);  /*calculeer tweede subexpr*/
  regt1=regt;
  regtype(pn->arg[2].i);      /*bepaal register type van resultaat*/
  for (n=0;n<3;n++) {
    n0[n]=p0->nreg[n];        /*neem aantallen over voor berekeningen*/
    n1[n]=p1->nreg[n];
  }

  /*kijk of er nog een konversie nodig is, bijv voor mul/divide*/
  if (flag&CONV8 && width==1) {
    n0[regt0]=conv8(n0[regt0],pn->arg[2].i);
    n1[regt0]=conv8(n1[regt0],pn->arg[2].i);
  }

  /*
    Indien vlag of reversed shift en niet constante 1..8,
    forceer linkerlid naar register
  */
  if (flag&FORCE0 ||
      flag&RVSHFT68 && !(p0->kode==ICON && !p0->arg[3].pc &&
                         p0->arg[0].l>=1 && p0->arg[0].l<=8)) {
    if (n0[regt0]==0) n0[regt0]=1;
  }

  /*
    Indien vlag of shift en niet constante 1..8,
    forceer rechterlid naar register
  */
  if (flag&FORCE1 ||
      flag&SHIFT68 && !(p1->kode==ICON && !p1->arg[3].pc &&
                        p1->arg[0].l>=1 && p1->arg[0].l<=8)) {
    if (n1[regt1]==0) n1[regt1]=1;
  }

  /*is het een dyad met assignment?*/
  if (flag&ASGDYAD) {
    if ((regt!=2 || flag&FPTOEA) && flag&LEFTEA && n0[regt0]==0) {
      /*vertaal als: <dyad> d0/#,<ea>*/
      if (p1->kode!=ICON) {
        if (n1[regt1]==0) n1[regt1]=1;  /*forceer rechterlid naar register*/
        if (n0[1]) n1[1]++;             /*bewaar adres van linkerlid*/
      }
    }
    else {
      /*
        vertaal als:
          move <ea0>,d0
          <dyad> #/<ea1>/d1,d0
          move d0,<ea0>
      */
      if (p1->kode!=ICON) {
        /*forceer evt. rechterlid naar register*/
        if (!(flag&RIGHTEA) && n1[regt1]==0) n1[regt1]=1;
        if (n0[1]) n1[1]++;           /*bewaar adres van linkerlid*/
      }
      if (n0[regt0]==0) n0[regt0]=1;  /*linkerlid via register*/
    }
  }
  else {
    /*
      mogen we dyads omdraaien?
      en mogen we revcodes gebruiken of is deze code commutatief
      en zijn de types gelijk (niet bv PTR+INT)
      en heeft de rechterexpressie meer registers nodig?
    */
    if (f_revd && (f_revc || flag&REVBLE) && regt0==regt1 &&
        n0[regt0]<n1[regt0]) {
      /*zoja, draai dan om*/
      pn->kode=revcode(pn->kode);
      pn->arg[0].pn=p1;
      p1=pn->arg[1].pn=p0;
      p0=pn->arg[0].pn;
      for (n=0;n<3;n++) {
        hulp=n0[n]; n0[n]=n1[n]; n1[n]=hulp;
      }
      n_revd++;  /*statistiek*/
    }

    /*
      We gaan er nu vanuit, dat het linkerlid eerst vertaald wordt,
      wanneer het een register nodig heeft.
      Er is dan bij het vertalen van het rechterlid een extra register
      nodig.
      Of als geen van beide een register nodig hebben, is er toch een
      nodig, om het resultaat in te berekenen.
    */
    if (n0[regt0] || n1[regt0]==0) n1[regt0]++;
  }

  for (n=0;n<3;n++) pn->nreg[n]=max(n0[n],n1[n]);  /*bereken echt*/

  /*voor mod zijn twee registers nodig*/
  if (flag&TWOREG && pn->nreg[regt0]<2) pn->nreg[regt0]=2;
  /*minstens een dr, bijv. voor INT=PTR-PTR, of cmp*/
  if ((regt==0 || flag&RESINT) && pn->nreg[0]==0) pn->nreg[0]=1;

  /*is de hoeveelheid dataregisters toegenomen?*/
  if (pn->nreg[regt]>p0->nreg[regt] && pn->nreg[regt]>p1->nreg[regt]) {
    pn->flag=INCRDATA;
  }

  /*
    is het aantal adresregisters toegenomen, dwz moet er tijdelijk
    gestored worden bij tekort? Misschien houdt de kodegenerator
    namelijk het adres van het linkerlid wel in een adresregister
    tijdens het berekenen van het rechterlid.
  */
  if (pn->nreg[1]>p0->nreg[1] && pn->nreg[1]>p1->nreg[1]) {
    pn->flag|=INCRADDR;
  }

  return pn;
}

/*Bepaal het aantal benodigde registers voor een call-node.*/
struct snode *ccall(pn,flag)
struct snode *pn;
{
  register struct snode *pa,*pp,*p0,*p1;
  int      n,na[3],np[3];

  diag("ccall");
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);  /*verwerk eerste lid*/
  p1=pn->arg[1].pn=cnode(pn->arg[1].pn);  /*verwerk tweede lid*/
  if (flag&REVERSED) {
    pa=p1;  /*adres*/
    pp=p0;  /*parameters*/
  }
  else {
    pa=p0;  /*adres*/
    pp=p1;  /*parameters, onzinnig igv uny-call*/
  }

  regtype(pn->arg[2].i);
  for (n=0;n<3;n++) {
    na[n]=pa->nreg[n];
    np[n]=pp->nreg[n];
  }

  /*
    Mogen we reversed codes genereren en is dit nog niet het geval,
    of andersom?
  */
  if (f_revc && !(flag&REVERSED) || !f_revc && flag&REVERSED) {
    /*Zoja, reverse*/
    pn->kode=revcode(pn->kode);
    pn->arg[0].pn=p1;
    pn->arg[1].pn=p0;
    flag^=REVERSED;
    n_call++;          /*statistiek*/
  }
  /*
    Is er een extra adresregister nodig om het funktieadres in te bewaren,
    tijdens de berekening van de parameters?
    Alleen voor lr-parsing codegenerators.
  */
  if (!f_revc && f_ltor && na[1]) np[1]++;

  /*
    Bereken het maximum van de aantallen registers, waaronder:
    - Het aantal benodigde registers voor het adres.
    - Het aantal registers voor de parameters.
    - Het aantal registers, dat de funktie stukmaakt.
  */
  for (n=0;n<3;n++) pn->nreg[n]=max3(na[n],np[n],Afunkstuk[n]);

  /*
    Moet het resultaat overgebracht worden naar een register met
    nummer >=2, voor codegenerators met een simpele registerstrategie?
  */
  if (f_tfrc && pn->nreg[regt]==Afunkstuk[regt]) pn->nreg[regt]++;
  return pn;
}

/*Bepaal het aantal benodigde registers voor een unycall-node.*/
struct snode *cunycall(pn,flag)
struct snode *pn;
{
  register struct snode *pa,*pp;
  int      n,na[3];

  diag("cunycall");
  pa=pn->arg[0].pn=cnode(pn->arg[0].pn);  /*verwerk eerste lid*/

  regtype(pn->arg[2].i);
  for (n=0;n<3;n++) {
    na[n]=pa->nreg[n];
  }

  /*
    Bereken het maximum van de aantallen registers, waaronder:
    - Het aantal benodigde registers voor het adres.
    - Het aantal registers, dat de funktie stukmaakt.
  */
  for (n=0;n<3;n++) pn->nreg[n]=max(na[n],Afunkstuk[n]);

  /*
    Moet het resultaat overgebracht worden naar een register met
    nummer >=2, voor codegenerators met een simpele registerstrategie?
  */
  if (f_tfrc && pn->nreg[regt]==Afunkstuk[regt]) pn->nreg[regt]++;
  return pn;
}

/*
  Bepaal het aantal registers nodig voor een cm- of revcm-node.

  Een comma-node mag nooit vrij voorkomen, maar alleen als subnode van een
  call-, stcall-, revcall-, revstcall- of andere cm-node.
  Daar checken we hier echter niet op, omdat anders het vertalen van de
  subtree van een call-node veel ingewikkelder wordt.
*/
struct snode *ccm(pn,flag)
struct snode *pn;
{
  struct   snode *p0,*p1;
  int      n,n0[3],n1[3];
  int      regt0,regt1;

  diag("ccm");
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);
  regt0=regt;
  p1=pn->arg[1].pn=cnode(pn->arg[1].pn);
  regt1=regt;
  /*
    "regtype(pn->arg[2].i);"
    hoeven we niet uit te voeren, aangezien, het type altijd INT is,
    we kunnen beter het type van de rechter subexpressie laten staan
  */
  for (n=0;n<3;n++) {
    n0[n]=p0->nreg[n];
    n1[n]=p1->nreg[n];
  }
  if (n0[regt0]==0) n0[regt0]=1;  /*forceer resultaat naar reg*/
  if (n1[regt1]==0) n1[regt1]=1;  /*forceer resultaat naar reg*/
  /*verwissel indien gewenst*/
  if (f_revc && !(flag&REVERSED) || !f_revc && flag&REVERSED) {
    pn->kode=(pn->kode==CM)?REVCM:CM;
    pn->arg[0].pn=p1;
    pn->arg[1].pn=p0;
    n___cm++;          /*statistiek*/
  }
  /*neem max over voor iedere soort*/
  for (n=0;n<3;n++) pn->nreg[n]=max(n0[n],n1[n]);
  return pn;
}

/*Bepaal het aantal registers voor een incr- of decr-node.*/
struct snode *cincr(pn)
register struct snode *pn;
{
  register struct snode *p0;
  unsigned n;

  diag("cincr");
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);  /*bepaal regs voor linker subexpr*/
  regtype(pn->arg[2].i);
  for (n=0;n<3;n++) pn->nreg[n]=p0->nreg[n];       /*neem over*/
  if (f_incr && isleaf(p0)) {
    pn->kode=(pn->kode==INCR)?ASG PLUS:ASG MINUS;  /*verander code*/
    opost(pn);                                     /*zet in achterboom*/
    pn=dupnode(p0);                                /*geef linkerlid terug*/
    n_incr++;  /*statistiek*/
  }
  else {
    if (f_incr) error("++ or -- may have side effects, can't postpone");
    if (pn->nreg[regt]==0) pn->nreg[regt]=1;       /*forceer*/
  }
  return pn;
}

struct snode *cstasg(pn)
register struct snode *pn;
{
  register struct snode *p0,*p1;
  unsigned n;

  diag("cstasg");
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);  /*bepaal regs voor linker subexpr*/
  p1=pn->arg[1].pn=cnode(pn->arg[1].pn);  /*bepaal regs voor rechter subexpr*/
  regtype(pn->arg[2].i);
  for (n=0;n<3;n++) pn->nreg[n]=max(p0->nreg[n],p1->nreg[n]);  /*neem over*/
  if (pn->nreg[0]<1) pn->nreg[0]=1;  /*minstens data register voor teller*/
  if (pn->nreg[1]<2) pn->nreg[1]=2;  /*twee adresregisters als pointers*/
  return pn;
}

struct snode *cstarg(pn)
register struct snode *pn;
{
  register struct snode *p0,*p1;
  unsigned n;

  diag("cstarg");
  p0=pn->arg[0].pn=cnode(pn->arg[0].pn);  /*bepaal regs voor linker subexpr*/
  regtype(pn->arg[2].i);                      /*anders dan in doc!*/
  for (n=0;n<3;n++) pn->nreg[n]=p0->nreg[n];  /*neem over*/
  if (pn->nreg[0]<1) pn->nreg[0]=1;  /*minstens data register voor teller*/
  if (pn->nreg[1]<2) pn->nreg[1]=2;  /*twee adresregisters als pointers*/
  return pn;
}

/*
  Bepaal aantal registers voor cbranch- en revcbranch-node.
*/
struct snode *ccbranch(pn,flag)
register struct snode *pn;
{
  register struct snode *pc;
  unsigned n;
  int      regt0;

  diag("ccbranch");
  if (flag&REVERSED) {
    pc=pn->arg[1].pn=cnode(pn->arg[1].pn);  /*igv revcbranch*/
    if (!f_revc) {
      pn->kode=CBRANCH;
      pn->arg[1].pn=pn->arg[0].pn;
      pn->arg[0].pn=pc;
      n_cbra++;          /*statistiek*/
    }
  }
  else {
    pc=pn->arg[0].pn=cnode(pn->arg[0].pn);
    if (f_revc) {
      pn->kode=REVCBRAN;
      pn->arg[0].pn=pn->arg[1].pn;
      pn->arg[1].pn=pc;
      n_cbra++;
    }
  }
  regt0=regt;
  regtype(pn->arg[2].i);
  for (n=0;n<3;n++) pn->nreg[n]=pc->nreg[n];      /*neem over*/
  if (regt0==2 && pn->nreg[2]==0) pn->nreg[2]=1;  /*igv fp en 0 regs*/
  return pn;
}

/*
  Hulproutine om het aantal registers aan te passen, voor een multiply
  of divide.

  Deze eisen namelijk operands van minstens 2 bytes.
  Dus verhoog het registeraantal igv byte value, ivm omzetting.
  i: nr=aantal reeds benodigde registers
     type=oorspr type (UCHAR of CHAR)
  o: nieuwe aantal benodigde registers
*/
conv8(nr,type)
int nr,type;
{
  if (type==UCHAR) {
    if (nr<=1) nr++;
    /*
      Minstens in register voor unsigned konversie
      of nog een, mits al in register, (zie conversie naar unsigned).
      Dit klopt niet helemaal, want nr==1 betekent niet altijd,
      dat het resultaat echt in een register staat.
    */
  }
  else {
    if (nr==0) nr=1;  /*minstens in register voor signed konversie*/
  }
  return nr;
}

#ifdef f68000
static struct sfunc nu00c[]={
/*  0*/
  {cUNDEF  },{cUNDEF},
  {cleaf   },          /*name, direct adresseerbaar*/
  {cUNDEF  },
  {cleaf   },          /*icon, direct 'adresseerbaar'*/
  {cleaf   },          /*fcon, direct adresseerbaar*/
  {cdyad   ,REVBLE},                  /*plus*/
  {cdyad   ,ASGDYAD|LEFTEA|RIGHTEA},  /*asgplus*/
  {cdyad   ,FORCE0},                  /*minus*/
  {cdyad   ,ASGDYAD|LEFTEA|RIGHTEA},  /*asgminus*/
/* 10*/
  {cmonad  ,FORCE0},                        /*unyminus, moet in reg*/
  {cdyad   ,REVBLE|CONV8},                  /*mul*/
  {cdyad   ,ASGDYAD|FORCE0|CONV8|RIGHTEA},  /*asgmul*/
  {cunymul },
  {cdyad   ,REVBLE},                        /*and*/
  {cdyad   ,ASGDYAD|LEFTEA|RIGHTEA},        /*asgand*/
  {cUNDEF  },
  {cdyad   ,REVBLE},                        /*or*/
  {cdyad   ,ASGDYAD|LEFTEA|RIGHTEA},        /*asgor*/
  {cdyad   ,FORCE0|FORCE1|REVBLE},          /*eor*/
/* 20*/
  {cdyad   ,ASGDYAD|FORCE1|LEFTEA},         /*asgeor*/
  {cboth   },                               /*quest*/
  {cboth   },                               /*colon*/
  {cboth   },                               /*andand*/
  {cboth   },                               /*oror*/
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },
/* 30*/
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },
  {cmonad  ,0},        /*goto*/
  {cUNDEF  },{cUNDEF},
/* 40*/
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
/* 50*/
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {ccm     },
  {cboth   },                                     /*sm*/
  {cdyad   ,ASGDYAD|LEFTEA|RIGHTEA|FPTOEA},       /*assign*/
  {cboth   },                                     /*comop*/
/* 60*/
  {cdyad   ,FORCE0|CONV8},                        /*div, 1e lid in reg*/
  {cdyad   ,ASGDYAD|FORCE0|CONV8|RIGHTEA},        /*asgdiv*/
  {cdyad   ,FORCE0|CONV8|TWOREG},                 /*mod, 2 registers nodig*/
  {cdyad   ,ASGDYAD|FORCE0|CONV8|TWOREG|RIGHTEA}, /*asgmod*/
  {cdyad   ,FORCE0|SHIFT68},                      /*ls*/
  {cdyad   ,ASGDYAD|FORCE0|SHIFT68},              /*asgls*/
  {cdyad   ,FORCE0|SHIFT68},                      /*rs*/
  {cdyad   ,ASGDYAD|FORCE0|SHIFT68},              /*asgrs*/
  {cUNDEF  },
  {cUNDEF  },
/* 70*/
  {ccall   },         /*call, twee subnodes*/
  {cUNDEF  },
  {cunycall},         /*unycall*/
  {cUNDEF  },
  {cUNDEF  },
  {cUNDEF  },
  {cmonad  ,FORCE0},  /*compl, moet in reg*/
  {cmonad  },         /*not, niet in reg, is omkering van voorwaarde*/
  {cincr   },         /*incr*/
  {cincr   },         /*decr*/
/* 80*/
  {cdyad   ,REVBLE|RESINT},  /*eq*/
  {cdyad   ,REVBLE|RESINT},  /*ne*/
  {cdyad   ,REVBLE|RESINT},  /*le*/
  {cdyad   ,REVBLE|RESINT},  /*lt*/
  {cdyad   ,REVBLE|RESINT},  /*ge*/
  {cdyad   ,REVBLE|RESINT},  /*gt*/
  {cdyad   ,REVBLE|RESINT},  /*ule*/
  {cdyad   ,REVBLE|RESINT},  /*ult*/
  {cdyad   ,REVBLE|RESINT},  /*uge*/
  {cdyad   ,REVBLE|RESINT},  /*ugt*/
/* 90*/
  {cUNDEF  },
  {cUNDEF  },
  {cUNDEF  },
  {cUNDEF  },  /*ars*/
  {cleaf   },  /*reg*/
  {cleaf   },  /*oreg*/
  {cUNDEF  },
  {cUNDEF},
  {cstasg  },  /*stasg*/
  {cstarg  },  /*starg*/
/*100*/
  {ccall   },                      /*stcall, twee subnodes*/
  {cUNDEF  },
  {cunycall},                      /*unystcall, geen subnodes*/
  {cmonad  ,FORCE0},               /*fld*/
  {csconv  },
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },
  {cmonad  ,FORCE0|RESINT},        /*force*/
  {ccbranch},                      /*cbranch*/
/*110*/
  {cmonad  ,0},                    /*init*/
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },{cUNDEF},
  {cUNDEF  },
/*120*/
  {ccall   ,REVERSED},             /*revcall, two reversed subnodes*/
  {ccall   ,REVERSED},             /*revstcall, two reversed subnodes*/
  {ccm     ,REVERSED},             /*revcm, ongeveer als cm*/
  {cdyad   ,FORCE1},               /*revminus*/
  {cdyad   ,FORCE1|CONV8},         /*revdiv*/
  {cdyad   ,FORCE1|CONV8|FORCE0},  /*revmod*/
  {cdyad   ,FORCE1|RVSHFT68},      /*revls*/
  {cdyad   ,FORCE1|RVSHFT68},      /*revrs*/
  {cUNDEF  },                      /*revars*/
  {ccbranch,REVERSED}              /*revcbra*/
};
#endif

/*xlate node*/
struct snode *cnode(pn)
register struct snode *pn;
{
  register unsigned kode;

  diah(pn);
  if (pn) {
    kode=pn->kode;
    if      (kode>=0 && kode<130) pn=(*nu00c[kode].func)(pn,nu00c[kode].para);
    else if (kode>=1000 && kode<1052 || kode>=1290 && kode<1294);
    else errorn("unknown kode to xlate = %d",kode);
  }
  return pn;
}

/*hulproutines*/

max(a,b)
int a,b;
{
  return (a>b)?a:b;
}

max3(a,b,c)
int a,b,c;
{
  return (a>=b)?((a>=c)?a:c):((b>=c)?b:c);
}

init_c()
{
  n___cm=
  n_call=
  n_cbra=
  n_incr=
  n_oreg=
  n_revd=0;
}

/*druk statistiek af*/
prtt_c()
{
  if (n_oreg)
    fprintf(stderr,"]]] OREG's made: %u\n",n_oreg);
  if (n_revd)
    fprintf(stderr,"]]] Dyadic operators (de)reversed: %u\n",n_revd);
  if (n_call)
    fprintf(stderr,"]]] CALL's and STCALL's (de)reversed: %u\n",n_call);
  if (n___cm)
    fprintf(stderr,"]]] CM's (de)reversed: %u\n",n_call);
  if (n_cbra)
    fprintf(stderr,"]]] CBRANCH's (de)reversed: %u\n",n_cbra);
  if (n_incr)
    fprintf(stderr,"]]] INCR's and DECR's postponed: %u\n",n_incr);
}

/*end*/
