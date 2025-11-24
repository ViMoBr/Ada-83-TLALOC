/*
  hsize.c
  hulproutines for types and sizes etc.
  19880720/wj van ganswijk
*/

#include  "def.h"

extern char f_diag;    /*diagnose mode?*/

extern int Aalign[];  /*array met breedte's per type*/
extern int Asize[];   /*array met breedte's per type*/
extern int Astack[];  /*array met breedte's per type*/
extern int alptr;     /*de alignment van een pointer*/
extern int stptr;     /*de breedte van een pointer gepushed*/
extern int szptr;     /*de breedte van een pointer*/

static int Aregtype[16]={0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0};

int      regt;         /*register type of last node or subnode*/
int      type;         /*type of last node or subnode*/
int      width;        /*breedte van laatste type*/

/*
  determine register kind and width of type
  i: ty=type
  o: type (global) = current type
     regt (global) = type of register
                     0=data register
                     1=address register
                     2=floating point register
     width (global) = width of type
     return regt
*/
regtype(ty)
int ty;
{
  type=ty;          /*set global value*/
  if (ISPTR(ty)) {
    regt=1;
    width=szptr;
  }
  else if (ty&-16) {
    regt = -1;
  }
  else {
    regt=Aregtype[ty];
    width=Asize[ty];
  }
  if (regt<0) {
    errorn("can't determine register for type",ty);
    regt=0;            /*voor de zekerheid*/
    width=Asize[INT];
  }
  return regt;
}

/*bepaal breedte van een type*/
getwidth(ty)
int ty;
{
  int width;

  if (ISPTR(ty))           width=szptr;
  else if (ty>=0 && ty<16) width=Asize[ty];
  else {
    errorn("can't determine width",ty);
    width=Asize[INT];
  }
  return width;
}

/*bepaal de aligned breedte van een type*/
getalign(ty)
int ty;
{
  int align;

  if (ISPTR(ty))           align=alptr;
  else if (ty>=0 && ty<16) align=Aalign[ty];
  else {
    errorn("can't determine alignwidth",ty);
    align=Aalign[INT];
  }
  return align;
}

/*bepaal de stackbreedte van een type, voor temp storen*/
getstsize(ty)
int ty;
{
  int stsize;

  if (ISPTR(ty))           stsize=stptr;
  else if (ty>=0 && ty<16) stsize=Astack[ty];
  else {
    errorn("can't determine stackwidth",ty);
    stsize=Astack[INT];
  }
  return stsize;
}

/*end*/
