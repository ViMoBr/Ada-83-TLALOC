/*
  dupstr.c
  string funktie
  19870910/wjvg
  19880224/wjvg
*/

/*dupliceer string*/
dupstr(p0)
char *p0;
{
  register char *p1;
  register char *ph;

  if (p0) {
    ph=p0;
    while (*ph++) {};     /*ga naar achter 0 achter string*/
    p1=ph=malloc(ph-p0);  /*vraag geheugenbytes aan*/
    while (*ph++=*p0++);  /*neem over*/
  }
  else p1=0;
  return p1;
}    
 
/*end*/
