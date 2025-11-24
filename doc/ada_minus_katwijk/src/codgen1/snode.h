/*
  snode.h
  snode definitie
  19880723/wjvg
*/

struct snode {
  int kode;
  union {
    struct snode *pn;
    long   l;
    int    i;
    int   *pi;
    char  *pc;
  } arg[5];
  char   nreg[3];     /*aantal benodigde registers per reg type 0..8*/
  char   flag;        /*splitsen nodig?*/
};

/*bitvlaggen voor in 'flag'*/
#define INCRDATA 0x01  /*is aantal dataregisters verhoogd in deze node?*/
#define INCRADDR 0x02  /*is aantal adresregisters verhoogd in deze node?*/

/*end*/
