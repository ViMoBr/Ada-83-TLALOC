/*
  def68.c
  geef groottes van types voor 680x0
  19880720/wjvg
*/

#include "def.h"

/*grootte per type*/
#define SZCHAR   1
#define SZSHORT  2
#define SZINT    4
#define SZLONG   4
#define SZFLOAT  4
#define SZDOUBLE 8

#define SZPTR    4

/*geef push grootte van type's*/
#define STCHAR   4
#define STSHORT  4
#define STINT    4
#define STLONG   4
#define STFLOAT  12
#define STDOUBLE 12

#define STPTR    4

/*geef alignment van type's*/
#define ALCHAR   2
#define ALSHORT  2
#define ALINT    4
#define ALLONG   4
#define ALFLOAT  4
#define ALDOUBLE 4

#define ALPTR    4

int Asize []={0,SZINT,SZCHAR,SZSHORT,SZINT,SZLONG,SZFLOAT,SZDOUBLE,0,0,
              0,0,    SZCHAR,SZSHORT,SZINT,SZLONG};
int Astack[]={0,STINT,STCHAR,STSHORT,STINT,STLONG,STFLOAT,STDOUBLE,0,0,
              0,0,    STCHAR,STSHORT,STINT,STLONG};
int Aalign[]={0,ALINT,ALCHAR,ALSHORT,ALINT,ALLONG,ALFLOAT,ALDOUBLE,0,0,
              0,0,    ALCHAR,ALSHORT,ALINT,ALLONG};

int szptr=SZPTR;  /*de grootte van een pointer*/
int stptr=STPTR;  /*de stackgrootte van een pointer*/
int alptr=ALPTR;  /*de alignment van een pointer*/

int Amaxreg[3]={8,6,8};  /*maximum nr regs regs per kind*/
int Aminreg[3]={2,2,2};  /*minimum nr regs regs per kind*/

/*end*/
