/*
  p.c
  print node
  19880718/wj van ganswijk
*/

#include  "def.h"

#define  TAB_NIVO 2  /*tab per nivo*/
#define  LF      10  /*ascii: line feed*/

extern struct sinfo ic00 [];
extern struct sinfo ic290[];
extern struct sinfo nu00 [];

extern   char f_sour;  /*c-source mee afdrukken?*/
extern   char f_tabs;  /*tabs gebruiken?*/

char     buftmp[200],*pbuftmp;

unsigned nivo=0;
unsigned tpos;       /*positie in regel tov. tab begin*/

char *taal[]={"undef","c","pascal","spl","cobol","ada"};

static char *comptype[]={"","ptr.","ftn.","ary."};

static char *simptype[]={
  "undef","farg",
  "char","short","int","long",
  "float","double",
  "strty","unionty","enumty","moety",
  "uchar","ushort","unsigned","ulong"
};

struct {
  char    *fname;
  FILE    *fp;
  unsigned ln;
} Apnt[50];           /*ruim voldoende lijkt me!*/

char *dupstr();

/*print node*/
pnode(pn,phead,freg)
register struct snode *pn;
char           *phead;
int             freg;
{
  char     c,*fn,fx=0,*pa,*ps;
  int      kode,*ph;
  register unsigned t;
  struct   sinfo *pinfo;
  int      nn;

  diag("pnode"); diah(pn);
  if (pn==0) return;
  tpos=0;
  if (phead) prints(phead);  /*evt * ervoor oid*/
  kode=pn->kode;
  if      (kode>=0    && kode< 130) pinfo = &nu00 [kode];
  else if (kode>=1000 && kode<1052) pinfo = &ic00 [kode-1000];
  else if (kode>=1290 && kode<1294) pinfo = &ic290[kode-1290];
  else errorn("unknown kode to print",kode);
  if (kode==1000+ICPOINT) if (ppoint(pn,phead)) return;
  tabto(tpos+nivo);
  if (pinfo->ps) {
    prints(pinfo->ps);
    if (kode<1000) tabto(16);  /*spring in voor echte nodes*/
    if (pa=pinfo->pa) {
      nn=0;
      while (c = *pa++) {
        if (kode<1290 || nn!=0) printtab();
        switch (c) {
        case 'l': printdl(pn->arg[nn++].l); break;
        case '0':
        case 'R':
        case 'n': printd(pn->arg[nn++].i); break;
        case 'L': prints(taal[pn->arg[nn++].i]); break;
        case 'N': printd(t=pn->arg[nn++].i);
                  ph=pn->arg[nn++].pi;
                  while (t--) {
                    printtab();
                    printd(*ph++);
                  }
                  break;
        case 'S':
        case 'd':
        case 'p': nn++; break;
        case 'q': prints("\"");
                  ps=pn->arg[nn++].pc;
                  prints(ps?ps:"");
                  prints("\"");
                  break;                            /*"string"*/
        case 's': ps=pn->arg[nn++].pc;
                  prints(ps?ps:"");
                  break;             /*string*/
        case 't': ptype(pn->arg[nn++].i); break;  /*type*/
        default:  puts(""); errorn("pnode: table error",c); return;
        }
      }
      if (freg && kode<1000) {
        printtab();
        printf("(%d,%d,%d;%d)",pn->nreg[0],pn->nreg[1],pn->nreg[2],
                               pn->flag&1);
      }
      puts("");
      nivo+=TAB_NIVO;
      if (pinfo->pa[0]=='p') pnode(pn->arg[0].pn,phead,freg);
      if (pinfo->pa[1]=='p') pnode(pn->arg[1].pn,phead,freg);
      nivo-=TAB_NIVO;
    }
    else puts("");
  }
  else errorn("unknown node to print",kode);
}

ppoint(pn,phead)
struct snode *pn;
char  *phead;
{
  register unsigned n;
  unsigned          ln;
  register char    *pb;
  char             *fn;

  puts("");
  tpos=0;
  if (f_sour) {  /*source toevoegen*/
    ln=pn->arg[0].i;
    fn=pn->arg[1].pc;
    for (n=0;Apnt[n].fname && strcmp(fn,Apnt[n].fname);n++);
    if (Apnt[n].fname==0) {
      Apnt[n].fname=dupstr(fn);
      if (Apnt[n].fp=fopen(fn,"r"));
      else {
        fflush(stdout);
        perror("--> can't open c-source file ");
      }
    }
    if (Apnt[n].fp) {  /*is 0 igv error bij openen*/
      pb="";           /*ivm meerdere keren zelfde regelnummer*/
      while (Apnt[n].ln<ln && (pb=fgets(buftmp,sizeof(buftmp),Apnt[n].fp))) {
        Apnt[n].ln++;
        if (*pb==LF) pb++;
        if (phead) printf("%s",phead);
        printf("%s/%03d: %s",Apnt[n].fname,Apnt[n].ln,pb);  /*\n onnodig!*/
      };
      if (pb==0) puts("---> sync error, with source file!!!");
      return 1;               /*al afgedrukt*/
    }
  }
  return 0;  /*druk alsnog op ouderwetse manier af*/
}

/*sluit alle geopende files tbv printen weer*/
endprint()
{
  char    *ps;
  unsigned n;

  for (n=0;ps=Apnt[n].fname;n++) {
    if (Apnt[n].fp) fclose(Apnt[n].fp);
    if (ps) free(ps);
    Apnt[n].fname=0;
  }
}

/*druk type af*/
ptype(ty)
int ty;
{
  unsigned vv;

  vv=ty>>4;
  while (vv) {
    prints(comptype[vv&3]);
    vv>>=2;
  }
  prints(simptype[ty&0xf]);
}

/*io hulp routines*/

/*druk een tab*/
printtab()
{
  tabto(tpos+8&-8);
}

/*druk spaties tot nivo n*/
tabto(n)
unsigned n;
{
  unsigned h;

  if (f_tabs) for (;(h=tpos+8&-8)<=n;tpos=h) putchar('\t');
  for (;tpos<n;tpos++) putchar(' ');
}

prints(ps)
char *ps;
{
  printf("%s",ps);
  tpos+=strlen(ps);
}

printd(n)
int n;
{
  char buftmp[20];

  sprintf(buftmp,"%d",n);
  printf("%s",buftmp);
  tpos+=strlen(buftmp);
}

printdl(n)
long n;
{
  char buftmp[20];

  sprintf(buftmp,"%ld",n);
  printf("%s",buftmp);
  tpos+=strlen(buftmp);
}

/*end*/
