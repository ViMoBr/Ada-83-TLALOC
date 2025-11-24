/* grinc.c: supporting routines and declarations for gr.y */

#include "grinc.h"
#include <stdio.h>

#define RANGETEST(x,low,high) ((low<=(x)) && ((x)<=high))

#define MINAREG 0
#define MINDREG 1
#define MINFPREG 1

/*********************************************************/
/* This is a declaration for gr.l, the LEX specification */
/*********************************************************/

int debuglex=FALSE;

/**************************/
/* The rest is for CGYACC */
/**************************/

char *languagename[] = { "Unknown","C","Fortan 77","Pascal","SPL",
			 "COBOL","Ada" };

int languagenumber;	/* 1=C,2=F77,3=PASCAL,4=SPL,5=COBOL,6=ADA */
int fendlabel;		/* numeric label of end of function */
int endlabel;		/* numeric label of end of some construct */
int dimlistsize = 0;	/* icdim expects a variable # of arguments */
int bytelistsize = 0;	/* icbytes expects a variable # of arguments */
int profile = 0;	/* boolean flag for generating profiling code
				(not implemented) */
stringtype fname;	/* name of function */
stringtype s;		/* temporary var */
int newlabel = 10000;	/* back-end generated numeric labels */
int l,l1,l2;		/* numeric labels for nice constructs */
int funclinklabel;	/*     "	"	"	"    */
int funcstartlabel;	/*     "	"	"	"    */
int defaultlabel;	/* label of default part of switch statement */
int autosize;		/* number of bytes on stack for automatic 
			   variables */
int framesize;		/* total number of bytes of frame */
int areghi=5;		/* highest free address register */
int a,a1,a2;		/* temporary address registers */
int dreghi=7;		/* highest free data register */
int d,d1,d2;		/* temporary data register */
int dr,dq;		/* temp remainder,quotient register pair */
int dsrc,ddest;		/* temporary data registers */
int fpreghi=7;		/* highest free floating point register */
int fp;			/* temporary float register */
int floatused=FALSE;	/* boolean */
int c;			/* temporary for "constant" values */


int savesize=0;		/* # of bytes occupied by arguments */
#define SAVESIZESTACKSIZE 50
int savesize_stack[SAVESIZESTACKSIZE];
int ssp = 0;

#define ISTACKSIZE 100
char instruction_stack[ISTACKSIZE][80]; 
			/* ISTACKSIZE instructions, 80 chars/instr */
int isp = 0;		/* instruction stack pointer 
			   isp == # of instructions on stack */

#define STARGBUFSIZE 30
char starg_buffer[STARGBUFSIZE][80];
int starg_buffer_top=0;	/* points to next free instruction in
			   starg_buffer */

int exchanged;		/* boolean; indicates whether the two
				   operands to a CMP instruction were
				   exchanged. This affects GT, LT etc. */

enum reginfotype dreginfo[8], areginfo[6], fpreginfo[8];
int savedreg[8], saveareg[6], savefpreg[8];  /* boolean */



/*********************************/
/* operations on node-attributes */
/*********************************/

nodeattr initnodeattr()
	{
	nodeattr n;
	n.nodetype=dummynode;
	n.type=4; /* int */
	n.address=FALSE;
	n.bitfld=FALSE;
	return n;
	}

ordinarynode(n)
/* Boolean; an address or some value is regarded ordinary */
nodeattr n;
	{
	return( (n.nodetype != cmnode) &&
		(n.nodetype != stargnode) &&
		(n.nodetype != dummynode) );
	}

dregnode(n)
nodeattr n;
	{
	return(n.nodetype==dreg);
	}

aregnode(n)
nodeattr n;
	{
	return(n.nodetype==areg);
	}

fpregnode(n)
nodeattr n;
	{
	return(n.nodetype==fpreg);
	}
	
dregscratchnode(n)
nodeattr n;
	{
	return((n.nodetype==dreg) && (dreginfo[n.regnr]==scratch));
	}

aregscratchnode(n)
nodeattr n;
	{
	return((n.nodetype==areg) && (areginfo[n.regnr]==scratch));
	}

fpregscratchnode(n)
nodeattr n;
	{
	return((n.nodetype==fpreg) && (fpreginfo[n.regnr]==scratch));
	}

aregvarnode(n)
nodeattr n;
	{
	return((n.nodetype==areg) && (n.regnr>areghi));
	}

dregvarnode(n)
nodeattr n;
	{
	return((n.nodetype==dreg) && (n.regnr>dreghi));
	}

immediatenode(n)
nodeattr n;
	{
	return(n.nodetype==immediate);
	}

bitfldnode(n)
nodeattr n;
	{
	return(n.bitfld);
	}

knownconstant(n)
nodeattr n;
	{
	return(	(n.nodetype==immediate) && n.valueknown );
	}

smallconstant(n)
nodeattr n;
	{
	return(	(n.nodetype==immediate) &&
		 n.valueknown           &&
		(n.value <=  127)       &&
		(n.value >= -127));
	}

wordconstant(n)
nodeattr n;
	{
	return(	(n.nodetype==immediate)	&&
		 n.valueknown		&&
		(n.value <=  32767)	&&
		(n.value >= -32767));
	}

verysmallconstant(n)
nodeattr n;
	{
	return(	(n.nodetype==immediate) &&
		 n.valueknown           &&
		(n.value <= 8)          &&
		(n.value >= 1));
	}

zeroconstant(n)
nodeattr n;
	{
	return(	(n.nodetype==immediate) &&
		 n.valueknown           &&
		(n.value == 0));   
	}

floatnode(n)
nodeattr n;
	{
	return(n.type==6 || n.type==7);
	}	


equal(x,y)
nodeattr x,y;
	{ 
	return(x.nodetype==y.nodetype && !strcmp(x.s,y.s));
	}
	
	
save_assign(n1,n2)
nodeattr *n1,*n2;
	/* this is the same as "n1=n2", except that when
	   n2 is predecr or postincr, it will be converted
	   to aregind_(with_displacement). Use this function 
	   whenever the .s part has been emitted, since it 
	   could've been a predecr or a postincr. 
	   For the ignorant (like the author once): 
	   referring twice to such an addressing mode will
	   induce TWO additions or subtractions, which is
	   not according to the defined semantics. */
	{
	*n1 = *n2;
	switch (n2->nodetype)
	 	{
	 	case predec:	
	 		n1->nodetype=aregind;
			n1->baseregnr=n2->regnr;
	 		sprintf(n1->s,"(a%d)",n1->regnr);
	 		break;
	 	case postinc:	
	 		n1->nodetype=aregind_with_displacement;
	 		n1->baseregnr=n2->regnr;
	 		n1->offsetknown=TRUE;
	 		n1->offset= -nbasictypesize(n2->type&15);
	 		sprintf(n1->s,"%d(a%d)",n1->offset,n1->baseregnr);
	 		break;
	 	}
	}
	    	


nodeattr make_dreg_node(registernumber,type)
int registernumber,type;
	{
	nodeattr t;
	t.nodetype=dreg;
	t.regnr=registernumber;
	t.address=FALSE;
	t.bitfld=FALSE;
	sprintf(t.s,"d%d",registernumber);
	t.type=type;
	return(t);
	}

nodeattr make_areg_node(registernumber,type)
int registernumber,type;
	{
	nodeattr t;
	t.nodetype=areg;
	t.regnr=registernumber;
	t.address=FALSE;
	t.bitfld=FALSE;
	sprintf(t.s,"a%d",registernumber);
	t.type=type;
	return(t);
	}

nodeattr make_fpreg_node(registernumber,type)
int registernumber,type;
	{
	nodeattr t;
	t.nodetype=fpreg;
	t.regnr=registernumber;
	t.address=FALSE;
	t.bitfld=FALSE;
	sprintf(t.s,"fp%d",registernumber);
	t.type=type;
	return(t);
	}


nodeattr make_dummy_node()
	{
	nodeattr t;
	t.nodetype=dummynode;
	t.type=4; /* int */
	return(t);
	}

freeregs(n)
nodeattr n;
	{
	switch (n.nodetype)
		{
		case areg: 	freeareg(n.regnr);
				break;
		case dreg:	freedreg(n.regnr);
				break;
		case fpreg:	freefpreg(n.regnr);
				break;
		case aregind:
		case aregind_with_displacement:
				freeareg(n.baseregnr);
				break;
		case aregind_with_index:
				freeareg(n.baseregnr);
				if (n.indexregtype=='d')
					freedreg(n.indexregnr);
				else	freeareg(n.indexregnr);
				break;
		}
	}
	





/*********************************/
/* register management routines  */
/*********************************/

gettempareg()
	{ 
	int i;
  	for (i=0;i<=areghi;i++) if (areginfo[i]==free) 
    		{ 
		areginfo[i]=scratch;
		if (i>=MINAREG) saveareg[i]=TRUE;
      		return(i);
    		}
  	error("out of address registers!!");
	}


gettempdreg()
	{ 
	int i;
  	for (i=0;i<=dreghi;i++) if (dreginfo[i]==free)
    		{ 
		dreginfo[i]=scratch;
		if (i>=MINDREG) savedreg[i]=TRUE;
     		return(i);
    		}
  	error("out of data registers!!");
	}
	
gettempfpreg()
	{
	int i;
	for (i=0;i<=fpreghi;i++) if (fpreginfo[i]==free)
		{
		fpreginfo[i]=scratch;
		if (i>=MINFPREG) savefpreg[i]=TRUE;
		return(i);
		}
	error("out of floating point registers!!");
	}


getareg()
	{ 
	int i;
  	for (i=MINAREG;i<=areghi;i++) if (areginfo[i]==free) 
    		{ 
		areginfo[i]=scratch;
		saveareg[i]=TRUE;
      		return(i);
    		}
  	error("out of address registers!!");
	}


getdreg()
	{ 
	int i;
  	for (i=MINDREG;i<=dreghi;i++) if (dreginfo[i]==free)
    		{ 
		dreginfo[i]=scratch;
		savedreg[i]=TRUE;
     		return(i);
    		}
  	error("out of data registers!!");
	}
	
getfpreg()
	{
	int i;
	for (i=MINFPREG;i<=fpreghi;i++) if (fpreginfo[i]==free)
		{
		fpreginfo[i]=scratch;
		savefpreg[i]=TRUE;
		return(i);
		}
	error("out of floating point registers!!");
	}

dregavailable()
	{
	int i;
	for (i=MINDREG;i<=dreghi;i++) if (dreginfo[i]==free) return(TRUE);
	return(FALSE);
	}

freeareg(a) 
int a;
	{ 
	if (!RANGETEST(a,0,6)) error("areg out of range in freeareg!");
	if (RANGETEST(a,0,5) && areginfo[a]!=regvar) areginfo[a]=free; 
	}

freedreg(d) 
int d;
	{ 
	if (!RANGETEST(d,0,7)) error("in freedreg!");
	if (dreginfo[d]!=regvar) dreginfo[d]=free; 
	}
	
freefpreg(fp)
int fp;
	{
	if (!RANGETEST(fp,0,7)) error("in freefpreg!");
	if (fpreginfo[fp]!=regvar) fpreginfo[fp]=free;
	}

useareg(a) 
int a;
	{ 
	if (!RANGETEST(a,0,5)) error("in useareg!");
	areginfo[a]=scratch; 
	if (a>=MINAREG) saveareg[a]=TRUE;
	}

usedreg(d) 
int d;
	{ 
	if (!RANGETEST(d,0,7)) error("in usedreg!");
	dreginfo[d]=scratch; 
	if (d>=MINDREG) savedreg[d]=TRUE;
	}
	
usefpreg(fp)
int fp;
	{
	if (!RANGETEST(fp,0,7)) error("in usefpreg!");
	fpreginfo[fp]=scratch;
	if (fp>=MINFPREG) savefpreg[fp]=TRUE;
	}

isscratchd(r) 
int r;
	{ 
	return(dreginfo[r]==scratch); 
	}

free_all_registers()
	{ 
	int i;
	if (!RANGETEST(fpreghi,0,7)) error("in free_all_registers!");
  	for (i=0; i<=dreghi; i++) dreginfo[i]=free;
	for (i=0; i<=areghi; i++) areginfo[i]=free;
	for (i=0; i<=fpreghi;i++) fpreginfo[i]=free;
	}

clear_reg_usage()
	{
	/* Resets save flags for all registers */
	int d,a,fp;
	for (d =0;d <=7; d++) savedreg[d]  = FALSE;
	for (a =0;a <=5; a++) saveareg[a]  = FALSE;
	for (fp=0;fp<=7;fp++) savefpreg[fp]= FALSE;
	}

dreg_usage()
	{
	int d;
	int numberofregs=0;
	for (d=0;d<=7;d++) if (savedreg[d]) numberofregs++;
	return numberofregs;
	}
	
areg_usage()
	{
	int a;
	int numberofregs=0;
	for (a=0;a<=5;a++) if (saveareg[a]) numberofregs++;
	return numberofregs;
	}
	
fpreg_usage()
	{
	int fp;
	int numberofregs=0;
	for (fp=0;fp<=fpreghi;fp++) if (savefpreg[fp]) numberofregs++;
	return numberofregs;
	}
	


/***************************/
/* Savesize stack routines */
/***************************/

push_savesize()
	{
	if (++ssp < SAVESIZESTACKSIZE)
		savesize_stack[ssp]=savesize;
	else error("Savesize stack overflow");
	}

pop_savesize()
	{
	savesize=savesize_stack[ssp--];
	}


/******************************/
/* Instruction stack routines */
/******************************/

push(a,b,c,d)
char *a;
	{ 
	if (++isp < ISTACKSIZE) 		
		sprintf(instruction_stack[isp],a,b,c,d);
	  else error("Instruction stack overflow");
	}


mark_stack()
	{
	if (++isp < ISTACKSIZE)
		strcpy(instruction_stack[isp],"call_marker");
	else error("Instruction stack overflow");
	}

flush_stack_till_marker()
	{
	while (strcmp(instruction_stack[isp],"call_marker"))
		printf("%s",instruction_stack[isp--]);
	isp--; /* remove marker */
	}



/*************************/
/* STARG-buffer routines */
/*************************/

empty_starg_buffer()
	{
	starg_buffer_top=0;
	}
	
append(a,b,c,d)
char *a;
	{
	sprintf(starg_buffer[starg_buffer_top++],a,b,c,d);
	}

output_starg_buffer()
	{
	int i;
	for (i=0;i<starg_buffer_top;i++) printf("%s",starg_buffer[i]);
	}




/******************************/
/* Operations on the IC types */
/******************************/

int floattype(t) /* boolean */
int t;
	{
	return(t==6 || t==7);
	}

int typeunsigned(t) /* boolean */
int t;
	{
	return(t>=12 && t<=15);
	}

int typesigned(t) /* boolean */
int t;
	{
	return(!typeunsigned(t));
	}
	
int nodeunsigned(n) /* boolean */
nodeattr n;
	{
	return(n.type>=12 && n.type<=15);
	}

char *stypesize(t) /* size of type t, returns string */
int t;
	{
	switch (t)
		{
		case 2:
		case 12: return(".b"); break;
		case 3:
		case 13: return(".w"); break;
		case 4:
		case 5:
		case 14:
		case 15: return(".l"); break;
		case 6:  return(".s"); break;
		case 7:  return(".d"); break;
		
		default: return(".l");
		}
	}

char *snodesize(n)
nodeattr n;
	{
	return(stypesize(n.type));
	}
	
char *snodesize2(n1,n2)
nodeattr n1,n2;
	{
	int size1,size2,size;
	size1=nnodesize(n1);
	size2=nnodesize(n2);
	size=(size1 <= size2 ? size1 : size2);
	if ((size==8) && fpregnode(n1) && fpregnode(n2))
		return(".x");
	else	return(size1<=size2 ? snodesize(n1) : snodesize(n2) );
	}

int nnodesize(n)
nodeattr n;
	{
	return(ntypesize(n.type));
	}
	
int pointertype(t) /* boolean; is the type an address? */
int t;
	{
	int modifier;
	t>>=4; /* skip the base type */
	if (t==0) return(FALSE);
	while (t!=0)
		{
		modifier=t&3; /* rightmost 2 bits */
		t>>=2;
		}
	return(modifier==1); /* 01 means pointer modifier */
	}

int ntypesize(t) /* returns the size of type t in bytes */
int t;
	{
	int basetype,modifier;
	basetype=t&15; /* rightmost 4 bits */
	t>>=4;
	if (t==0) return(nbasictypesize(basetype));
	while (t!=0)
		{
		modifier=t&3; /* rightmost 2 bits */
		t>>=2;
		}
	if (modifier!=1) 
		{
		error("Wat is de size van modifier %d?\n",modifier);
		}
	else return(4); /* pointer means 4 bytes */
	}


int ndereftypesize(t) /* returns the size of type x when t is PTR x */
int t;
	{
	int basetype,modifier,size;
	basetype=t&15; /* rightmost 4 bits */
	t>>=4; /* exposes modifiers */
	if (t==0) error("ndereftypesize a: no PTR");
	if ((t>>2)==0) return(nbasictypesize(basetype));
	while ((t>>4) != 0) t>>=2;  /* look two modifiers ahead */
	modifier=t&3;
	if (modifier==1) return(4); /* pointer: 4 bytes */
	else error("ndereftypesize b: no PTR");
	}

int nbasictypesize(t) 
/* returns the size of a basic type in bytes, 0 if unknown */
int t;
	{
	switch (t)
		{
		case  1: /* farg    */ return(0);
		case  2: /* char    */ return(1);
		case  3: /* short   */ return(2);
		case  4: /* int     */ return(4);
		case  5: /* long    */ return(4);
		case  6: /* float   */ return(4);
		case  7: /* double  */ return(8);
		case  8: /* strty   */ return(0);
		case  9: /* unionty */ return(0);
		case 10:
		case 11: /* ?       */ error("11: Unknown type");
		case 12: /* uchar   */ return(1);
		case 13: /* ushort  */ return(2);
		case 14: /* uint    */ return(4);
		case 15: /* ulong   */ return(4);
		}
	}

/**************************/
/*    Miscellaneous       */
/**************************/

savebf(n)
nodeattr n;

/* saves the changed contents of the register into the bitfield again */

	{
	printf("\tbfins\t%s,%s\n",n.s,n.bfs);
	}
	
	
incrnode(n,incr) /* increments the address if it's an addressing mode */
		/* Used by SCONV nodes */
nodeattr *n;
int incr;
	{
	stringtype s;
	switch (n->type) 
		{
		case absolute:	sprintf(s,"+%d",incr);
				strcat(n->s,s);
				break;
		case aregind_with_displacement:
				if (n->offsetknown)
					{
					n->offset += incr;
					sprintf(n->s,"%d(a%d)",
						n->offset,n->baseregnr);
					}
				else
				 error("incrnode:offset unknown");
				break;
		case aregind_with_index:
				if (n->offsetknown)
					{
					n->offset += incr;
					sprintf(n->s,"%d(a%d,%c%d.l)",
						n->offset,n->baseregnr,
						n->indexregtype,
						n->indexregnr);
					}
				else
				 error("incrnode:offset unknown");
				break;
		}
	}
				
movefloat(n1,n2,bytesize)
nodeattr n1,n2;
int bytesize;
	{
	nodeattr hulp1,hulp2;
	int bytesmoved=0;
	hulp1=n1;
	hulp2=n2;
	while (bytesmoved<bytesize)
		{
		printf("\tmove.l\t%s,%s\n",hulp1 .s,hulp2 .s);
		incrnode(&hulp1,4);
		incrnode(&hulp2,4);
		bytesmoved += 4;
		}
	}


genfpreglist()	/* generate floating point register list */
	{
	int i;
	int first=TRUE;
	for (i=0;i<=7;i++) 
	if (savefpreg[i])
		{ 
		if (first) first=FALSE; else printf("/");
		printf("fp%d",i);
		}
	}
	
outputfcmp(n1,n2)
nodeattr n1,n2;
	{
	int tfr;
	if (fpregnode(n1) && fpregnode(n2))
		printf("\tfcmp.x\t%s,%s\n",n1.s,n2.s);
	else if (fpregnode(n2))
		printf("\tfcmp.d\t%s,%s\n",n1.s,n2.s);
	else	{
		tfr=gettempfpreg();
		printf("\tfmove.d\t%s,fp%d\n",n2.s,tfr);
		printf("\tfcmp.d\t%s,fp%d\n",n1.s,tfr);
		freefpreg(tfr);
		}
	freeregs(n1);
	freeregs(n2);
	}
	
genftst(n)
nodeattr n;
	{
	if (fpregnode(n))
		printf("\tftst\t%s\n",n.s);
	else 	printf("\ttst.l\t%s\n",n.s);
	}
	
genext(n,size)
nodeattr *n;
int size;
	{
	nodeattr hn;
	int nsize;
	
	nsize=nnodesize(*n);
	if (!dregscratchnode(*n))
		{
		d=getdreg();
		hn=make_dreg_node(d,n->type);
		if (typeunsigned(n->type))
			printf("\tclr.%s\td%d\n",size==2?"w":"l",d);
		printf("\tmove%s\t%s,%s\n",snodesize(*n),n->s,hn.s);
		freeregs(*n);
		*n=hn;
		if (!typeunsigned(n->type))
			{
			printf("\t");
			if ((nsize==1) && (size==2))
				printf("ext.w");
			else if ((nsize==1) && (size==4))
				printf("extb.l");
			else	printf("extw.l");
			printf("\t%s\n",n->s);
			}
		}
	else 	{
		if (typeunsigned(n->type))
			printf("\tandi.%s\t#%d,%s\n",
				size==2 ? "w" : "l" ,
				nsize==1 ? 255 : 65535 ,
				n->s);
		else	{
			printf("\t");
			if ((nsize==1) && (size==2))
				printf("ext.w");
			else if ((nsize==1) && (size==4))
				printf("extb.l");
			else 	printf("extw.l");
			printf("\t%s\n",n->s);
			}
		}
	}
			
			

genpush(n)
nodeattr n;
	{
	int size;
	nodeattr hn;
	
	if (ordinarynode(n))
		{
		size=nnodesize(n);
		switch (size)
			{
			case 1:
			case 2:	savesize += 4;
				genext(&n,4);
				break;
			case 4: savesize += 4;
				break;
			case 8: savesize += 8;
			}
		if (size==8)
			{
			if (fpregnode(n))
				printf("\tfmove.l\t%s,-(sp)\n",n.s);
			else	{
				hn=n;
				incrnode(&hn,4);
				printf("\tmove.l\t%s,-(sp)\n",hn.s);
				printf("\tmove.l\t%s,-(sp)\n",n.s);
				}
			}
		else if (n.address)
			printf("\tpea\t%s\n",n.s);
		else if (wordconstant(n))
			printf("\tpea\t%s.w\n",n.nameonly);
		else if (immediatenode(n))
			printf("\tpea\t%s\n",n.nameonly);
		else 	printf("\tmove.l\t%s,-(sp)\n",n.s);
		}
	}

genpushpush(n)
nodeattr n;
	/* Same as genpush, but pushes push-instructions on a stack */
	/* Called by CM */		
	{
	int size;
	nodeattr hn;
	
	if (ordinarynode(n))
		{
		size=nnodesize(n);
		switch (size)
			{
			case 1:
			case 2:	savesize += 4;
				genext(&n,4);
				break;
			case 4: savesize += 4;
				break;
			case 8: savesize += 8;
			}
		if (size==8)
			{
			if (fpregnode(n))
				push("\tfmove.l\t%s,-(sp)\n",n.s);
			else	{
				hn=n;
				incrnode(&hn,4);
				push("\tmove.l\t%s,-(sp)\n",hn.s);
				push("\tmove.l\t%s,-(sp)\n",n.s);
				}
			}
		else if (n.address)
			push("\tpea\t%s\n",n.s);
		else if (wordconstant(n))
			push("\tpea\t%s.w\n",n.nameonly);
		else if (immediatenode(n))
			push("\tpea\t%s\n",n.nameonly);
		else 	push("\tmove.l\t%s,-(sp)\n",n.s);
		}
	}


outputcmp(n1,n2,exch)
nodeattr n1,n2;
int *exch; /* boolean, indicates whether n1 and n2 have been exchanged */
	{
	if (zeroconstant(n1) && !immediatenode(n2))
		{
		printf("\ttst%s\t%s\n",snodesize(n2),n2.s);
		*exch=TRUE;
		}
	else if (zeroconstant(n2) && !immediatenode(n1))
		{
		printf("\ttst%s\t%s\n",snodesize(n1),n1.s);
		*exch=FALSE;
		}
	else if (immediatenode(n1))
		{
		printf("\tcmpi%s\t%s,%s\n",snodesize(n2),n1.s,n2.s);
		*exch=TRUE;
		}
	else if (immediatenode(n2))
		{
		printf("\tcmpi%s\t%s,%s\n",snodesize(n1),n2.s,n1.s);
		*exch=FALSE;
		}
	else if (aregnode(n1))
		{
		printf("\tcmpa%s\t%s,%s\n",snodesize(n1),n2.s,n1.s);
		*exch=FALSE;
		}
	else if (aregnode(n2))
		{
		printf("\tcmpa%s\t%s,%s\n",snodesize(n2),n1.s,n2.s);
		*exch=TRUE;
		}
	else if (dregnode(n1))
		{
		printf("\tcmp%s\t%s,%s\n",snodesize(n1),n2.s,n1.s);
		*exch=FALSE;
		}
	else if (dregnode(n2))
		{
		printf("\tcmp%s\t%s,%s\n",snodesize(n2),n1.s,n2.s);
		*exch=TRUE;
		}
	else	
		{
		d=getdreg();
		printf("\tmove%s\t%s,d%d\n",snodesize(n1),n1.s,d);
		printf("\tcmp%s\t%s,d%d\n",snodesize(n2),n2.s,d);
		freedreg(d);
		*exch=FALSE;
		}
	freeregs(n1);
	freeregs(n2);
	}
	
		

		

error(s,a)
char *s;
int a;
{	fprintf(stderr,"\nCode generation fatal error:\n");
 	fprintf(stderr,s,a);
	exit(0);
}
