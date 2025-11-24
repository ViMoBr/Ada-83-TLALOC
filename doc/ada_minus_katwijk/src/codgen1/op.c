/*
  op.c
  optimizer module
  19880802/wjvg
*/

#include  "def.h"
#include  "mknode.h"

extern int  regt;
extern int  type;
extern int  width;

struct sfunc {
  struct snode *(*func)();
};

struct snode *opnode();

struct snode *opUNDEF(pn)
register struct snode *pn;
{
  errorn("unexpected intermediate code",pn->kode);
  regtype(INT);
  return pn;
}

/*
  Optimaliseer leaf node, zoals name, icon, fcon, reg, oreg.
*/
struct snode *opleaf(pn)
register struct snode *pn;
{
  diag("opleaf");
  regtype(pn->arg[2].i);
  return pn;
}

struct snode *opunymul(pn)
struct snode *pn;
{
  struct   snode        *p00,*p01;
  register struct snode *p0;

  int      type0;

  diag("opunymul");
  p0=pn->arg[0].pn;  /*subnode*/
  p00=p0->arg[0].pn;
  p01=p0->arg[1].pn;
  /*kijk of het een offset tov een adresregister is*/
  if ((p0->kode==PLUS || p0->kode==MINUS) &&
       p00->kode==REG && p00->arg[1].i>=8 && p00->arg[1].i<16 &&
       p01->kode==ICON) {
    if (p01->arg[3].pc==0) {
      pn->kode=OREG;
      pn->arg[1].i=p00->arg[1].i;                                  /*regnr*/
      pn->arg[0].l=(p0->kode==PLUS)?p01->arg[0].l:-p01->arg[0].l;  /*offset*/
      free(p0);  /*geef subnodes weer terug*/
      free(p00);
      free(p01);
      regtype(pn->arg[2].i);  /*zet type etc. nog goed, moet na opnode(sub)!*/
    }
  }
  else {
    p0=pn->arg[0].pn=opnode(p0);  /*bereken subnode*/
    regtype(pn->arg[2].i);     /*zet type etc. nog goed, moet na opnode(sub)!*/
  }
  return pn;
}

/*Optimaliseer een goto-node.*/
struct snode *opmonad(pn)
register struct snode *pn;
{
  diag("opmonad");
  pn->arg[0].pn=opnode(pn->arg[0].pn);
  regtype(pn->arg[2].i);
  return pn;
}

struct snode *opunyminu(pn)
register struct snode *pn;
{
  register struct snode *p0;

  diag("opunyminu");
  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);
  regtype(pn->arg[2].i);
  if (p0->kode==ICON && p0->arg[3].pc==0) {
    p0->arg[0].l=-p0->arg[0].l;
    free(pn);
    return p0;
  }
  return pn;
}

struct snode *opcompl(pn)
register struct snode *pn;
{
  register struct snode *p0;

  diag("opcompl");
  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);
  regtype(pn->arg[2].i);
  if (p0->kode==ICON && p0->arg[3].pc==0) {
    p0->arg[0].l=~p0->arg[0].l;
    free(pn);
    return p0;
  }
  return pn;
}

struct snode *opnot(pn)
register struct snode *pn;
{
  register struct snode *p0;

  diag("opnot");
  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);
  regtype(pn->arg[2].i);
  if (p0->kode==ICON && p0->arg[3].pc==0) {
    p0->arg[0].l=!p0->arg[0].l;
    free(pn);
    return p0;
  }
  return pn;
}

struct snode *opboth(pn)
register struct snode *pn;
{
  diag("opboth");
  pn->arg[0].pn=opnode(pn->arg[0].pn);
  pn->arg[1].pn=opnode(pn->arg[1].pn);
  regtype(pn->arg[2].i);          /*eig. niet nodig voor comop en sm*/
  return pn;
}

/*Optimaliseer cbranch node.*/
struct snode *opcbranc(pn)
register struct snode *pn;
{
  register struct snode *p0,*p1;

  diag("opcbranc");
  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);
  if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l) {
      free(p0);
      free(pn);
      return mkgoto(p1,INT);
    }
    else {
      free(p0);
      free(p1);
      free(pn);
      return 0;
    }
  }
  return pn;
}

/*Optimaliseer revcbranch-node.*/
struct snode *oprevcbr(pn)
register struct snode *pn;
{
  register struct snode *p0,*p1;

  diag("opcrevbr");
  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l) {
      free(p1);
      free(pn);
      return mkgoto(p0,INT);
    }
    else {
      free(p0);
      free(p1);
      free(pn);
      return 0;
    }
  }
  return pn;
}

struct snode *opor(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(pn);
      return mkcomop(p0,p1,pn->arg[2].i);  /*sideeffects*/
    }
    else if (p0->kode==ICON && p0->arg[3].pc==0) {
      p0->arg[0].l|=p1->arg[0].l;
      free(p1);
      free(pn);
      return p0;
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(pn);
      return mkcomop(p1,p0,pn->arg[2].i);  /*sideeffects*/
    }
  }
  return pn;
}

struct snode *opasgor(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(pn);
      return mkcomop(p0,p1,pn->arg[2].i);  /*side effects*/
    }
  }
  return pn;
}

struct snode *opand(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p0->kode==ICON && p0->arg[3].pc==0) {
      p0->arg[0].l&=p1->arg[0].l;
      free(p1);
      free(pn);
      return p0;
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(p0);
      free(pn);
      return p1;
    }
  }
  return pn;
}

struct snode *opasgand(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
  }
  return pn;
}

struct snode *opeor(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p0->kode==ICON && p0->arg[3].pc==0) {
      p0->arg[0].l^=p1->arg[0].l;
      free(p1);
      free(pn);
      return p0;
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(p0);
      free(pn);
      return p1;
    }
  }
  return pn;
}

struct snode *opasgeor(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
  }
  return pn;
}

struct snode *opplus(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p0->kode==ICON && p0->arg[3].pc==0) {
      p0->arg[0].l+=p1->arg[0].l;
      free(p1);
      free(pn);
      return p0;
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(p0);
      free(pn);
      return p1;
    }
  }
  return pn;
}

struct snode *opasgplus(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
  }
  return pn;
}

struct snode *opminus(pn)
struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p0->kode==ICON && p0->arg[3].pc==0) {
      p0->arg[0].l-=p1->arg[0].l;
      free(p1);
      free(pn);
      return p0;
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(p0);
      free(pn);
      return mkunymin(p1,pn->arg[2].i);
    }
  }
  return pn;
}

struct snode *opasgmin(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
  }
  return pn;
}

struct snode *opmul(pn)
struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p0->kode==ICON && p0->arg[3].pc==0) {
      p0->arg[0].l*=p1->arg[0].l;
      free(p1);
      free(pn);
      return p0;
    }
    else if (p1->arg[0].l==0L) {
      free(pn);
      return mkcomop(p0,p1,0);  /*side effects*/
    }
    else if (p1->arg[0].l==1L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p1->arg[0].l==2L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(1L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==4L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(2L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==8L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(3L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==16L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(4L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==32L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(5L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==64L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(6L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==128L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(7L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==256L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(8L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==65536L) {
      free(p1);
      free(pn);
      return mkls(p0,mkicon(16L,pn->arg[2].i,0),pn->arg[2].i);
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(pn);
      return mkcomop(p1,p0,0);  /*side effects*/
    }
    else if (p0->arg[0].l==1L) {
      free(p0);
      free(pn);
      return p1;
    }
  }
  return pn;
}

struct snode *opasgmul(pn)
struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(pn);
      return mkassign(p0,p1,pn->arg[2].i);
    }
    else if (p1->arg[0].l==1L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p1->arg[0].l==2L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(1L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==4L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(2L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==8L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(3L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==16L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(4L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==32L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(5L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==64L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(6L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==128L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(7L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==256L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(8L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==65536L) {
      free(p1);
      free(pn);
      return mkasgls(p0,mkicon(16L,pn->arg[2].i,0),pn->arg[2].i);
    }
  }
  return pn;
}

struct snode *opdiv(pn)
struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p0->kode==ICON && p0->arg[3].pc==0) {
      if (p1->arg[0].l) p0->arg[0].l/=p1->arg[0].l;
      else {
        error("Division by zero, I will put 0 as result");
        p0->arg[0].l=0;
      }
      free(p1);
      free(pn);
      return p0;
    }
    else if (p1->arg[0].l==0L) {
      error("division by zero, during optimising");
      return pn;
    }
    else if (p1->arg[0].l==1L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p1->arg[0].l==2L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(1L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==4L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(2L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==8L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(3L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==16L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(4L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==32L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(5L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==64L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(6L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==128L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(7L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==256L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(8L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==65536L) {
      free(p1);
      free(pn);
      return mkrs(p0,mkicon(16L,pn->arg[2].i,0),pn->arg[2].i);
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(pn);
      return mkcomop(p1,p0,0);  /*side effects*/
    }
  }
  return pn;
}

struct snode *opasgdiv(pn)
struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      error("division by zero, during optimising");
      return pn;
    }
    else if (p1->arg[0].l==1L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p1->arg[0].l==2L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(1L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==4L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(2L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==8L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(3L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==16L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(4L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==32L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(5L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==64L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(6L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==128L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(7L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==256L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(8L,pn->arg[2].i,0),pn->arg[2].i);
    }
    else if (p1->arg[0].l==65536L) {
      free(p1);
      free(pn);
      return mkasgrs(p0,mkicon(16L,pn->arg[2].i,0),pn->arg[2].i);
    }
  }
  return pn;
}

struct snode *opls(pn)
struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
    else if (p0->kode==ICON && p0->arg[3].pc==0) {
      if      (pn->kode==LS)    p0->arg[0].l<<=p1->arg[0].l;
      else                      p0->arg[0].l>>=p1->arg[0].l;
      free(p1);
      free(pn);
      return p0;
    }
  }
  else if (p0->kode==ICON && p0->arg[3].pc==0) {
    if (p0->arg[0].l==0L) {
      free(pn);
      return mkcomop(p1,p0,0);  /*side effects*/
    }
  }
  return pn;
}

struct snode *opasgls(pn)
register struct   snode *pn;
{
  register struct snode *p0,*p1;  /*for speed*/

  p0=pn->arg[0].pn=opnode(pn->arg[0].pn);     /*optimize first subexpr*/
  p1=pn->arg[1].pn=opnode(pn->arg[1].pn);     /*optimize second subexpr*/
  if (p1->kode==ICON && p1->arg[3].pc==0) {
    if (p1->arg[0].l==0L) {
      free(p1);
      free(pn);
      return p0;
    }
  }
  return pn;
}

/*voorlopig*/
struct snode *opmod(pn)
{
  return opboth(pn);
}

/*voorlopig*/
struct snode *opasgmod(pn)
{
  return opboth(pn);
}

static struct sfunc nu00op[]={
/*  0*/
  {opUNDEF },
  {opUNDEF },
  {opleaf  },  /*name*/
  {opUNDEF },
  {opleaf  },  /*icon*/
  {opleaf  },  /*fcon*/
  {opplus  },  /*plus*/
  {opasgplu},  /*asgplus*/
  {opminus },  /*minus*/
  {opasgmin},  /*asgminu*/
/* 10*/
  {opunymin},  /*unyminu*/
  {opmul   },  /*mul*/
  {opasgmul},  /*asgmul*/
  {opunymul},
  {opand   },  /*and*/
  {opasgand},  /*asgand*/
  {opUNDEF },
  {opor    },  /*or*/
  {opasgor },  /*asgor*/
  {opeor   },  /*eor*/
/* 20*/
  {opasgeor},  /*asgeor*/
  {opboth  },  /*quest*/
  {opboth  },  /*colon*/
  {opboth  },  /*andand*/
  {opboth  },  /*oror*/
  {opUNDEF },
  {opUNDEF},{opUNDEF},
  {opUNDEF},{opUNDEF},
/* 30*/
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },
  {opmonad },            /*goto*/
  {opUNDEF },{opUNDEF},
/* 40*/
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
/* 50*/
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opboth  },
  {opboth  },  /*sm*/
  {opboth  },  /*assign*/
  {opboth  },  /*comop*/
/* 60*/
  {opdiv   },  /*div*/
  {opasgdiv},  /*asgdiv*/
  {opmod   },  /*mod*/
  {opasgmod},  /*asgmod*/
  {opls    },  /*ls*/
  {opasgls },  /*asgls*/
  {opls    },  /*rs*/
  {opasgls },  /*asgrs*/
  {opUNDEF },
  {opUNDEF },
/* 70*/
  {opboth  },  /*call*/
  {opUNDEF },
  {opmonad },  /*unycall*/
  {opUNDEF },
  {opUNDEF },
  {opUNDEF },
  {opcompl },  /*compl*/
  {opnot   },  /*not*/
  {opmonad },  /*incr*/
  {opmonad },  /*decr*/
/* 80*/
  {opboth  },  /*eq*/
  {opboth  },  /*ne*/
  {opboth  },  /*le*/
  {opboth  },  /*lt*/
  {opboth  },  /*ge*/
  {opboth  },  /*gt*/
  {opboth  },  /*ule*/
  {opboth  },  /*ult*/
  {opboth  },  /*uge*/
  {opboth  },  /*ugt*/
/* 90*/
  {opUNDEF },
  {opUNDEF },
  {opUNDEF },
  {opUNDEF },  /*ars*/
  {opleaf  },  /*reg*/
  {opleaf  },  /*oreg*/
  {opUNDEF },
  {opUNDEF },
  {opboth  },  /*stasg*/
  {opmonad },  /*starg*/
/*100*/
  {opboth  },  /*stcall*/
  {opUNDEF },
  {opmonad },  /*unystcall*/
  {opmonad },  /*fld*/
  {opmonad },  /*sconv*/
  {opUNDEF },{opUNDEF},
  {opUNDEF },
  {opmonad },  /*force*/
  {opcbranc},  /*cbranch*/
/*110*/
  {opmonad },  /*init*/
  {opUNDEF },
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
  {opUNDEF },{opUNDEF},
/*120*/
  {opboth  },  /*revcall*/
  {opboth  },  /*revstcall*/
  {opboth  },  /*revcm*/
  {opboth  },  /*revminu*/
  {opboth  },  /*revdiv*/
  {opboth  },  /*revmod*/
  {opboth  },  /*revls*/
  {opboth  },  /*revrs*/
  {opUNDEF },  /*revars*/
  {oprevcbr}   /*revcbra*/
};

/*xlate node*/
struct snode *opnode(pn)
register struct snode *pn;
{
  register unsigned kode;

  diah(pn);
  if (pn) {
    kode=pn->kode;
    if      (kode>=0 && kode<130) pn=(*nu00op[kode].func)(pn);
    else if (kode>=1000 && kode<1052 || kode>=1290 && kode<1294);
    else errorn("unknown kode to xlate = %d",kode);
  }
  return pn;
}

/*end*/
