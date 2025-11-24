/*
  mknode.h
  macro's om nodes te maken
  19880804/wj van ganswijk
*/

#define mkicon(n,t,l)   mkleaf(ICON,(long)n,0,t,l)
#define mkname(n,t,l)   mkleaf(NAME,(long)n,0,t,l)
#define mkoreg(n,r,t)   mkleaf(OREG,(long)n,r,t,0)
#define mkreg(r,t)      mkleaf(REG ,(long)0,r,t,0)

#define mkcompl(p,t)    mkmonad(COMPL    ,p,t)
#define mkforce(p,t)    mkmonad(FORCE    ,p,t)
#define mkgoto(p,t)     mkmonad(GOTO     ,p,t)
#define mknot(p,t)      mkmonad(NOT      ,p,t)
#define mksconv(p,t)    mkmonad(SCONV    ,p,t)
#define mkunycal(p,t)   mkmonad(UNY CALL ,p,t)
#define mkunymin(p,t)   mkmonad(UNY MINUS,p,t)
#define mkunymul(p,t)   mkmonad(UNY MUL  ,p,t)

#define mkasgls(p,q,t)  mkdyad(ASG LS   ,p,q,t)
#define mkasgmin(p,q,t) mkdyad(ASG MINUS,p,q,t)
#define mkasgplu(p,q,t) mkdyad(ASG PLUS ,p,q,t)
#define mkasgrs(p,q,t)  mkdyad(ASG RS   ,p,q,t)
#define mkassign(p,q,t) mkdyad(ASSIGN   ,p,q,t)
#define mkcolon(p,q,t)  mkdyad(COLON    ,p,q,t)
#define mkls(p,q,t)     mkdyad(LS       ,p,q,t)
#define mkminus(p,q,t)  mkdyad(MINUS    ,p,q,t)
#define mkmul(p,q,t)    mkdyad(MUL      ,p,q,t)
#define mkplus(p,q,t)   mkdyad(PLUS     ,p,q,t)
#define mkquest(p,q,t)  mkdyad(QUEST    ,p,q,t)
#define mkrs(p,q,t)     mkdyad(RS       ,p,q,t)

#define icbss()         mkicnode(ICBSS   )
#define iccom(s)        mkicnode(ICCOM   ,s)
#define icdata()        mkicnode(ICDATA  )
#define icdlabn(n)      mkicnode(ICDLABN ,n)
#define icdlabs(s)      mkicnode(ICDLABS ,s)
#define icglobl(s)      mkicnode(ICGLOBL ,s)
#define icjfend(n)      mkicnode(ICJFEND )
#define icjlabn(n)      mkicnode(ICJLABN ,n)
#define iclb(a,b,c,d,e) mkicnode(ICLB    ,a,b,c,d,e)
#define icnequ(l,n)     mkicnode(ICNEQU  ,l,n)
#define icpoint(a,b)    mkicnode(ICPOINT ,a,b)
#define icskip(n)       mkicnode(ICSKIP  ,n)
#define icstring(s)     mkicnode(ICSTRING,s)
#define ictext()        mkicnode(ICTEXT  )

#define mkfalse()       mkicon(0L,INT,0)
#define mktrue ()       mkicon(1L,INT,0)
#define mkcbrani(e,n)   mkcbranc(e,mkicon(n,INT,0),INT)

/*end*/
