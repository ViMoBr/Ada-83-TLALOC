/*
  m.c
  main module for many compiler applications
  19880805/wj van ganswijk
*/

#include "def.h"
#include "mknode.h"

extern char f_calc;  /*calculeer en converteer nodes eerst?*/
extern char f_diag;  /*diag aan?*/
extern char f_diah;  /*diah aan?*/
extern char f_incr;  /*postpone increments and decrements?*/
extern char f_ltor;  /*is de volgende pass een lr parser?*/
extern char f_opti;  /*optimize?*/
extern char f_oreg;  /*oreg nodes maken?*/
extern char f_outp;  /*stuur boom weer als ickode weg (=check)*/
extern char f_prtt;  /*statistics afdrukken?*/
extern char f_prti;  /*inputboom afdrukken?*/
extern char f_prts;  /*boom vertaald afdrukken*/
extern char f_prtO;  /*boom optimized afdrukken?*/
extern char f_prtc;  /*boom met registers afdrukken*/
extern char f_revc;  /*mogen calls omgedraaid worden?*/
extern char f_revd;  /*mogen dyads omgedraaid worden?*/
extern char f_sour;  /*c-source afdrukken?*/
extern char f_spli;  /*code splitsen?*/
extern char f_tabs;  /*tabs gebruiken?*/
extern char f_tfrc;  /*resultaat van call overzetten naar ander reg?*/
extern char f_xlat;  /*vertalen?*/
extern char f_xbra;  /*branches onderverdelen?*/

extern int Amaxreg[3];  /*hoeveel registers per soort bruikbaar?*/
extern int Asize[];     /*de breedte per type*/
extern int szptr;       /*de breedte van een pointer*/

char    *filename;
char    *prgrname;
char     vd[]="vd";

unsigned teller=0;

FILE    *fp;

struct snode *treepost=0;

struct snode *cnode(),*inode(),*onode(),*opnode(),*pnode();
struct snode *snode(),*xnode(),*poxnode(),*putnode(),*mkcomop();
char         *dupstr();

main(argc,argv)
unsigned argc;
char    *argv[];
{
  char    *ph;
  unsigned argcc;
  char   **argvv;
  char    *parg;

#ifdef on6809
  pflinit();
#endif
  prgrname = *argv++;
  argvv=argv;
  argcc=argc;
  /*ga opties verwerken en tel aantal echte argumenten*/
  while (--argcc) {
    parg = *argvv++;    /*lees ^arg*/
    switch (*parg) {
    case '+': opties(parg+1,TRUE ); break;
    case '-': opties(parg+1,FALSE); break;
    default: teller++; break;  /*tel echte argumenten*/
    }
  }
  if (f_diag || f_diah) setbuf(stdout,0);
  if (teller) while (--argc) {
    filename = *argv++;     /*lees ^arg*/
    switch (*filename) {
    case '+': break;  /*negeer opties nu*/
    case '-': break;
    default:
      if (fp=fopen(filename,"r")) {
        dofile();
        fclose(fp);
      }
      else eopen(filename);
      break;
    }
  }
  else {
    filename="standard input";
    diag(filename);
    fp=stdin;
    dofile();
  }
}

dofile()
{
  struct snode *pn;

  diag("dofile");
  init_c();                                 /*init c module*/
  init_s();                                 /*init s module*/
  while (pn=inode()) {                      /*behandel regels tot eof*/
    diag("main loop");
    if (f_prti) pnode(pn,f_xlat?"*":0,0);   /*tree afdrukken?*/
    if (f_opti) pn=opnode(pn);              /*tree optimizen?*/
    if (f_prtO) pnode(pn,f_xlat?"*":0,0);   /*tree afdrukken?*/
    if (f_calc) pn=cnode(pn);               /*tree calculeren?*/
    if (f_prtc && pn && pn->kode<1000) {    /*tree afdrukken?*/
      pnode(pn,f_xlat?"*":0,TRUE);          /*druk node af, met regs*/
    }
    if (f_spli) {
      pn=snode(pn);                         /*split node*/
      putnode(poxnode(chgframe()));         /*verander frame evt.*/
    }
    pn      =putnode(poxnode(pn      ));    /*stuur echte boom*/
    treepost=putnode(poxnode(treepost));    /*stuur achterboom*/
  }
  endprint();  /*sluit geopende hulpsourcefiles weer*/
  if (f_prtt) {
    fflush(stdout);
    fprintf(stderr,"]]] %s:\n",prgrname);
    fprintf(stderr,"]]] Statistics for file: %s\n",filename);
    prtt_c();  /*print c module statistics*/
    prtt_s();  /*print s module statistics*/
  }
}

/*stuur node weg, naar print en/of output routine*/
struct snode *poxnode(pn)
struct snode *pn;
{
  diag("poxnode"); diah(pn);
  if (pn) {
    if (pn->kode==SM || pn->kode==COMOP) {
      poxnode(pn->arg[0].pn);
      poxnode(pn->arg[1].pn);
    }
    else {
      if (f_prts) pnode(pn,f_outp?"*":0,0);  /*druk node af*/
      if (f_outp) onode(pn,0);               /*stuur weg*/
      if (f_xlat) xnode(pn,vd);              /*vertaal void*/
    }
  }
  return pn;
}

/*verzamel node's die achter de expressie moeten*/
opost(pn)
struct snode *pn;
{
  diag("otemp"); diah(pn);
  treepost=(treepost)?mkcomop(treepost,pn):pn;
}

/*vraag een nieuw label in stringvorm*/
char *getlabs()
{
  char buftmp[40];

  diag("getlabs");
  sprintf(buftmp,"_%d",getlabn());
  return dupstr(buftmp);
}

/*vraag een nieuw label in nummervorm*/
getlabn()
{
  static unsigned tlabel=20000;

  diag("getlabn");
  return tlabel++;
}

diag(ps)
char *ps;
{
  if (f_diag) printf("%s\t",ps);
}

diah(pn)
struct snode *pn;
{
  register int t;

  if (f_diah && pn) {
    printf("%04x: %4d(dec)  ",pn,pn->kode);
    printf(" %08lx ",pn->arg[0].l);
    for (t=1;t<5;t++) printf("%04x ",pn->arg[t].i);
    printf(" ");
    for (t=0;t<3;t++) printf("%02x ",pn->nreg[t]);
    puts("");
  }
}

/*druk error af*/
error(ps)
char    *ps;
{
  if (f_xlat) printf("*");
  printf("&%d\t-- %s --\n",ICCOM,ps);
  if (!isatty(fileno(stdout))) {
    fflush(stdout);
    fprintf(stderr,"-- %s --\n",ps);
  }
}

/*druk error af, met nummer*/
errorn(ps,n)
char    *ps;
unsigned n;
{
  if (f_xlat) printf("*");
  printf("&%d\t-- %s %d --\n",ICCOM,ps,n);
  if (!isatty(fileno(stdout))) {
    fflush(stdout);
    fprintf(stderr,"-- %s %d --\n",ps,n);
  }
}

/*opties*/

opties(parg,f)
char *parg;
int   f;
{
  while (*parg) {
    switch (*parg++) {
    case 'a': f_tfrc=f; break;  /*transfer registers after call?*/
    case 'b': f_xbra=f; break;  /*branches uiteenrafelen*/
    case 'c': f_calc=f; break;  /*calculeer en converteer nodes eerst*/
    case 'd': f_diag=f; break;  /*diagnose mode*/
    case 'h': f_diah=f; break;  /*diagnose mode*/
    case 'i': f_incr=f; break;  /*postpone increments and decrements?*/
    case 'l': f_ltor=f; break;  /*volgende pass is lr parser*/
    case 'm': f_oreg=f; break;  /*oreg's aanmaken ipv uny_mul?*/
    case 'o': f_outp=f; break;  /*output boom weer in icode vorm*/
    case 'O': f_opti=f; break;  /*optimize the tree*/
    case 'p':
      switch (*parg) {
      case 'c': parg++; f_prtc=f; break;  /*druk af na register calc*/
      case 'i': parg++; f_prti=f; break;  /*druk inputboom af*/
      case 'O': parg++; f_prtO=f; break;  /*druk optimized boom af*/
      case 's': parg++; f_prts=f; break;  /*druk output boom af na splitten*/
      case 't': parg++; f_prtt=f; break;  /*druk stats?*/
      default:
        if (f) f_prts=f;  /*met +p de output afdrukken*/
        else {
          f_prtc=f;  /*met -p worden alle manieren van afdrukken afgezet*/
          f_prti=f;
          f_prtO=f;
          f_prts=f;
          f_prtt=f;
        }
        break;
      }
      break;
    case 'r':
      switch (*parg) {
      case 'c': parg++; f_revc=f; break;   /*reverse call's etc*/
      case 'd': parg++; f_revd=f; break;   /*reverse dyad's*/
      default: f_revc=f; f_revd=f; break;  /*both*/
      }
      break;
    case 'R':
      if (*parg=='=') parg++;
      if (*parg>='0' && *parg<='7') {
        Amaxreg[0] = *parg-'0';
        parg++;
        if (*parg>='0' && *parg<='7') {
          Amaxreg[1] = *parg-'0';
          parg++;
          if (*parg>='0' && *parg<='7') {
            Amaxreg[2] = *parg-'0';
            parg++;
          }
        }
      }
      break;
    case 's': f_spli=f; break;        /*code splitsen?*/
    case 'S': f_prti=TRUE;            /*input afdrukken*/
              f_calc=FALSE;           /*niet berekenen en splitsen*/
              f_outp=FALSE;           /*geen output*/
              f_prtt=FALSE;           /*geen statistiek afdrukken*/
              break;                  /*sic mode*/
    case 't': f_tabs=f; break;        /*use tabs for printing?*/
    case 'w': Asize[    FARG]=        /*argument breedte wordt 4*/
              Asize[     INT]=        /*int breedte wordt  4*/
              Asize[UNSIGNED]=        /*uint breedte wordt 4*/
              szptr          =f?4:2;  /*ptr breedte wordt  4*/
              break;
    case 'x': f_xlat=f; break;        /*vertaal wel*/
    default:  eopti();  break;
    }
  }
}

/*end*/
