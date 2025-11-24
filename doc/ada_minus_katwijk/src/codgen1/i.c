/*
  i.c
  input node
  19880723/wj van ganswijk
*/

#include  <ctype.h>

#include  "def.h"

extern char   f_diag;

extern struct sinfo ic00 [];
extern struct sinfo ic290[];
extern struct sinfo nu00 [];

extern FILE  *fp;

unsigned char  bufin[200];
unsigned char *pbufin;
unsigned char *index();

struct snode *inode(),*calloc();   /*forward*/
char *dupstr();

char *istring()
{
  char     buftmp[200];
  register char *ph;
  unsigned b,c;

  diag("istring");
  ph=buftmp;
  c = *pbufin;
  if (c=='"' || c=='\'') {
    pbufin++;
    /*lees gekwote string*/
    while ((b = *pbufin) && (pbufin++,b!=c)) *ph++=b;
  }
  else {
    /*lees ongekwote string*/
    while ((b = *pbufin) && b>=' ') *ph++ = *pbufin++;
  }
  *ph=0;
  return buftmp[0]?dupstr(buftmp):0;  /*hier!*/
}

struct snode *icode(k,pinfo)
int    k;
struct sinfo *pinfo;
{
  char                   c;
  register unsigned      t;
  register struct snode *pn;
  int                   *ph;  /*hier*/
  int                   *pi;
  char                  *pa;
  long                   rdecl();
  int                    nn;

  diag("icode");
  pn=calloc(1,sizeof(struct snode));  /*memory voor node*/
  pn->kode=k;
  if (pinfo->ps) {
    if (pa=pinfo->pa) {
      nn=0;
      while ((c = *pa++) && c!='d') {     /*dummies altijd aan het eind*/
        if (*pbufin=='\t') pbufin++;
        switch (c) {
        case '0': if (pn->arg[nn++].i=rdec(&pbufin)) error("0 expected");
                  break;
        case 'L': pn->arg[nn++].i=t=rdec(&pbufin);
                  if (t>=10) errorn("unknown language",t);
                  break;
        case 'N': pn->arg[nn++].i=t=rdec(&pbufin);
                  pn->arg[nn++].pi=pi=(int*)calloc(1,t*sizeof(int));
                  while (t--) {
                    if (*pbufin=='\t') pbufin++;
                    *pi++=rdec(&pbufin);         /*list of numbers*/
                  }
                  break;
        case 'R': pn->arg[nn++].i=isdigit(*pbufin)?rdec(&pbufin):15;
                  break;                           /*evt. register*/
        case 'S': pn->arg[nn++].i=isdigit(*pbufin)?rdec(&pbufin):23;
                  break;                           /*evt. register*/
        case 'l': pn->arg[nn++].l=rdecl(&pbufin);   /*long value*/
                  break;
        case 'n': pn->arg[nn++].i=rdec(&pbufin);    break;  /*value*/
        case 'p': nn++; break;
        case 'q':                                   /*quoted string*/
        case 's': pn->arg[nn++].pc=istring();       break;  /*string*/
        case 't': pn->arg[nn++].i=roct(&pbufin);    break;  /*type*/
        default: errorn("inode: table error",c); break;
        }
      }
    }
  }
  else errorn("unknown code to input",k);
  diah(pn);
  if (pinfo->pa[0]=='p') pn->arg[0].pn=inode();
  if (pinfo->pa[1]=='p') pn->arg[1].pn=inode();
  diah(pn);
  return pn;
}

struct snode *ipoint()  {return icode(1290,&ic290[0]);}
struct snode *isqbrop() {return icode(1291,&ic290[1]);}
struct snode *isqbrcl() {return icode(1292,&ic290[2]);}
struct snode *ibrcl()   {return icode(1293,&ic290[3]);}

/*behandel ic kode's*/
struct snode *iamper()
{
  unsigned          k;
  register unsigned t;

  diag("iamper");
  diag(pbufin);
  k=rdec(&pbufin);
  if (k>=0 && k<52) return icode(1000+k,&ic00[k]);
  else {
    switch (k) {
    case 290: return ipoint();
    case 291: return isqbrop(); 
    case 292: return isqbrcl(); 
    case 293: return ibrcl(); 
    default:  errorn("unknown ic code",k); return 0;
    }
  }
}  

/*behandel normale kode*/
struct snode *inum()
{
  unsigned k;

  diag("inum");
  k=rdec(&pbufin);
  if (k>= 0 && k<130) return icode(k,&nu00[k]);
  else {
    errorn("unknown code",k);
    return 0;
  }
}

/*input node*/
struct snode *inode()
{
  char b;

  diag("inode");
  if (fgets(bufin,sizeof(bufin),fp)) {
    if (pbufin=index(bufin,'\n')) *pbufin=0;
    diag(bufin);
    pbufin=bufin;
    while (*pbufin>0 && *pbufin<=' ') pbufin++;
    if (isdigit(*pbufin)) return inum();
    else switch (b = *pbufin++) {
    case 0:   return inode();     /*empty line*/
    case '&': return iamper();  
    case '.': return ipoint();  
    case '[': return isqbrop(); 
    case ']': return isqbrcl(); 
    case ')': return ibrcl();   
    default:  errorn("unexpected char at start of line =",b); return 0;
    }
  }
  return 0;
}

/*end*/
