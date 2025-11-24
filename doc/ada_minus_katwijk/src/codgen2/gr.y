/*
 *     68020 code generator specification
 *	
 *     This grammar, intended to be processed by CGYACC,
 *     describes a code generator for the 
 *     Portable C Compiler (PCC) on a 68020-based computer.
 *     Although the CGYACC-generated code generator may replace
 *     the second pass (PCC2) of the PCC, better code is generated
 *     when an additional preprocessor is used.
 */


%{
# include "grinc.h"
%}

%start icprog

%union	{
	int ival;
	stringtype sval;
	}

%token <ival> NUMBER CONDNUMBER ICCODE DIMENSION BYTE
%token <sval> STR
%token DOT LBRACKET RBRACKET RPAREN

%type <ival> anynumber

%attribute node(^nodeattr); 
%attribute topnode(^nodeattr);
%attribute cmsubnode(^nodeattr);
%attribute rev_cmsubnode(^nodeattr);
%attribute condition(|int,int);
%attribute constant(^int);
%attribute string(^stringtype);
%attribute line_number(^int);
%attribute filename(^stringtype);
%attribute funcnr(^int);
%attribute automatic(^int);
%attribute datareg(^int);
%attribute addrreg(^int);
%attribute assemblerline(^stringtype);
%attribute offset(^int);
%attribute type(^int);
%attribute label(^stringtype);
%attribute regnr(^int);
%attribute size(^int);
%attribute alignment(^int);
%attribute code(^int);


/* attribute movers and other tricky stuff */

%attribute notcopy(|int,int,^int,int,int);
%attribute preparelabels(|int,int,^int,int,int,int);
%attribute andandlnode(|int,int,int);
%attribute andandrnode(|int,int,int);
%attribute andandlcopy(|int,int,int,^int,int);
%attribute andandrcopy(|int,int,int,^int,int);
%attribute ororlnode(|int,int,int);
%attribute ororrnode(|int,int,int);
%attribute ororlcopy(|int,int,int,^int,int);
%attribute ororrcopy(|int,int,int,^int,int);
%attribute rev_cbranchcopy(|nodeattr,^int,int);
%attribute questgenstuff(^int,int,int,int);
%attribute colonlnode(|int,int,int,int);
%attribute colonrnode(|int,int,int,int);
%attribute genlabel(^int,int);



%%

icprog		: list  
			{
			if (floatused) printf("\t.globl\t_fltused\n");
			}
		;

list		: list topnode(^n) 
			{ free_all_registers(); }
		| list iccode
		| list auxiliary_code
		| /* nothing... */
		;

/* nodes may have to be treated differently when they're topnodes */

topnode(^n)	: incr type(^t)
		    node(^n1)
		    node(^n2)
		  [ verysmallconstant($n2) ]
			{
			printf("\taddq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| incr type(^t)
		    node(^n1)
		    node(^n2)
		  [ immediatenode($n2) ]
		  	{
			printf("\taddi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| decr type(^t)
		    node(^n1)
		    node(^n2)
		  [ verysmallconstant($n2) ]
			{
			printf("\tsubq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| decr type(^t)
		    node(^n1)
		    node(^n2)
		  [ immediatenode($n2) ]
		  	{
			printf("\tsubi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}

		| unary_call zero type(^t) node(^n1)
		  [ immediatenode($n1) ]
			{ 
			printf("\tjbsr\t%s\n",$n1 .nameonly);
			}
		| unary_call zero type(^t) node(^n1)
		  [ aregnode($n1) ]
		  	{
		  	printf("\tjbsr\t(%s)\n",$n1 .s);
		  	}
		| unary_call zero type(^t) node(^n1)
			{
			a=gettempareg();
			printf("\tmovea.l\t%s,a%d\n",$n1 .s,a);	
			printf("\tjbsr\t(a%d)\n",a);
			freeareg(a);
			}
		| unary_stcall zero type(^t) size(^s) alignment(^a) node(^n1)
		  [ immediatenode($n1) ]
			{
			printf("\tjbsr\t%s\n",$n1 .nameonly);
			}
		| unary_stcall zero type(^t) size(^s) alignment(^a) node(^n1)
		  [ aregnode($n1) ]
		  	{
		  	printf("\tjbsr\t(%s)\n",$n1 .s);
		  	}
		| unary_stcall zero type(^t) size(^s) alignment(^a) node(^n1)
			{
			a=gettempareg();
			printf("\tmovea.l\t%s,a%d\n",$n1 .s,a);
			printf("\tjbsr\t(a%d)\n",a);
			freeareg(a);
			}
		| call mark type(^t) node(^n1) node(^n2) 
			{ 
			/******** push argument **********/
			if (ordinarynode($n2))
			  {
			  savesize+=4;
			  if ($n2 .address)
			    printf("\tpea\t%s\n",$n2 .s);
			  else
			  if (immediatenode($n2))
			    printf("\tpea\t%s\n",$n2 .nameonly);
			  else
			    printf("\tmove.l\t%s,-(sp)\n",$n2 .s);
			  }
			else if ($n2 .nodetype==stargnode)
				output_starg_buffer();

			/* flush instruction stack */
			
			flush_stack_till_marker();

			/********** do the jump ************/
			if (immediatenode($n1))
				printf("\tjbsr\t%s\n",$n1 .nameonly);
			else
			if (aregnode($n1))
				printf("\tjbsr\t(%s)\n",$n1 .s);
			else	{
				a=gettempareg();
				printf("\tmovea.l\t%s,a%d\n",$n1 .s,a);
				printf("\tjbsr\t(a%d)\n",a);
				freeareg(a);
				}
			/********** adjust the stackpointer *****/
			if (savesize>8)
			      printf("\tlea\t%d(sp),sp\n",savesize);
			else  printf("\taddq.l\t#%d,sp\n",savesize);
			pop_savesize(); /* pushed by mark */
			}

		| unary_mul zero type(^t) node(^n1)
			/* do nothing */
		
		| node(^n1)
		  [ $n1 .nodetype==predec ]
			/* predec detected, but not used; so emit sub only */
			{
			printf("\tsubq.l\t#%d,a%d\n",$n1 .offset,$n1 .regnr);
			}
		| node(^n1)
		  [ $n1 .nodetype==postinc ]
			/* postinc detected, but not used; so emit add only */
			{
			printf("\taddq.l\t#%d,a%d\n",$n1 .offset,$n1 .regnr);
			}

		| node(^n1);  /* topnode may be an ordinary node */


node(^n)	:	/* leaf nodes */

		  name offset(^o) zero type(^t) label(^l) 
		  [ $o != 0 ]
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=absolute;
			sprintf($n .s,"%s+%d",$l,$o);
			}
		| name offset(^o) zero type(^t) label(^l)
		  [ $o == 0 ]
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=absolute;
			sprintf($n .s,"%s",$l);
			}
		| reg zero regnr(^r) type(^t)
		  [ $r > 7 ]
			{
			$n=make_areg_node($r-8,$t);
			$n .type=$t;
			}
		| reg zero regnr(^r) type(^t)
		  [ $r <= 7 ] 
			{
			$n=make_dreg_node($r,$t);
			$n .type=$t;
			}
		| icon constant(^c) zero type(^t) string(^s)
		  [ $c == 0 ]
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=immediate;
			$n .valueknown=FALSE;
			sprintf($n .s,"#%s",$s);
			sprintf($n .nameonly,"%s",$s);
			}
		| icon constant(^c) zero type(^t) string(^s)
		  [ $c != 0 ]
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=immediate;
			$n .valueknown=FALSE;
			sprintf($n .s,"#%s+%d",$s,$c);
			sprintf($n .nameonly,"%s+%d",$s,$c);
			}
		| icon constant(^c) zero type(^t)
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=immediate;
			$n .valueknown=TRUE;
			$n .value=$c;
			sprintf($n .s,"#%d",$c);
			sprintf($n .nameonly,"%d",$c);
			}
/*		| fcon constant(^high) constant(^low) type(^t)												
*/
		| oreg offset(^o) regnr(^r) type(^t)
		  [ $r > 7 ]
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=aregind_with_displacement;
			$n .baseregnr=$r-8;
			$n .offsetknown=TRUE;
			$n .offset=$o;
			sprintf($n .s,"%d(a%d)",$o,$r-8);
			}

/*	 	| eaddr offset(^o) regnr(^r) type(^t)
			not used, and number unknown
*/
	

			/* unary nodes */

		| unary_min zero type(^t) node(^n1)
		  [ dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tneg%s\t%s\n",stypesize($t),$n1 .s);
			}
		| unary_min zero type(^t) node(^n1)
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,%s\n",stypesize($t),$n1 .s,$n .s);
			printf("\tneg%s\t%s\n",stypesize($t),$n .s);
			freeregs($n1);
			}
		| compl zero type(^t) node(^n1)
		  [ dregscratchnode($n1) ]
			{ 
			save_assign(&$n,&$n1);
			printf("\tnot%s\t%s\n",stypesize($t),$n .s);
			}
		| compl zero type(^t) node(^n1)
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,%s",stypesize($t),$n1 .s,$n .s);
			printf("\tnot%s\t%s",stypesize($t),$n .s);
			freeregs($n1);
			}
		| unary_mul zero type(^t) node(^n1)
		  [ aregnode($n1) ]
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=aregind;
			$n .baseregnr=$n1 .regnr;
			sprintf($n .s,"(a%d)",$n1 .regnr);
			} 
		| unary_mul zero type(^t) node(^n1)
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=aregind;
			a=getareg();
			printf("\tmovea%s\t%s,a%d\n",snodesize($n1),$n1 .s,a); 
			sprintf($n .s,"(a%d)",a);
			freeregs($n1);
			$n .baseregnr=a;
			} 
		| force zero type(^t) node(^n1)
		  [ floattype($t) ]
		  	{
		  	printf("\tfmove\t%s,fp0\n",$n1 .s);
			usefpreg(0);
		  	}
		| force zero type(^t) node(^n1)
		  [ smallconstant($n1) ]
			{
			printf("\tmoveq\t%s,d0\n",$n1 .s);
			usedreg(0);
			}
		| force zero type(^t) node(^n1)
		  [ $n1 .address ]
			{
			a=gettempareg();
			printf("\tlea\t%s,a%d\n",$n1 .s,a);
			printf("\tmove.l\ta%d,d0\n",a);
			freeareg(a);
			usedreg(0);
			}
		| force zero type(^t) node(^n1)
			{ 
			printf("\tmove%s\t%s,d0\n",stypesize($t),$n1 .s);
			usedreg(0);
			}
		| goto zero type(^t) node(^n1)
			{
			printf("\tjmp\t%s\n",$n1 .s);
			}
		| init zero type(^t) node(^n1)
			{			
			if (($t>=2 && $t<=7) ||
			    ($t>=12 && $t<=15))
				{
				printf("\t");
				switch ($t)
					{
					case 2:
					case 12:	printf(".byte");
							break;
					case 3:
					case 13:	printf(".word");
							break;
					case 4:
					case 5:
					case 14:
					case 15:	printf(".long");
							break;
					case 6:		printf(".float");
							break;
					case 7:		printf(".double");
					}
				}
			else printf("\t.long");
			printf("\t%s\n",$n1 .nameonly);					
			}
			
		/* b -> l conversions */		
		
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==1 &&
		    dregscratchnode($n1) &&
		    nodeunsigned($n1) ]
		  	{
		  	printf("\tandi.l\t#255,%s\n",$n1 .s);
		  	save_assign(&$n,&$n1);
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==1 &&
		    dregscratchnode($n1) ]
		  	{
		  	printf("\textb.l\t%s\n",$n1 .s);
		  	save_assign(&$n,&$n1);
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==1 &&
		    immediatenode($n1) ]
		  	{
		  	$n=$n1;
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==1 &&
		    nodeunsigned($n1) ]	
		    	{
		    	d=getdreg();
		    	$n=make_dreg_node(d,$t);
		    	printf("\tmoveq\t#0,d%d\n",d);
		    	printf("\tmove.b\t%s,d%d\n",$n1 .s,d);
		    	freeregs($n1);
		    	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==1 ]
		    	{
		    	d=getdreg();
		    	$n=make_dreg_node(d,$t);
		    	printf("\tmove.b\t%s,d%d\n",$n1 .s,d);
		    	printf("\textb.l\td%d\n",d);
		    	freeregs($n1);
		    	}
		    	
		/* w -> l conversions */  	

		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==2 &&
		    dregscratchnode($n1) &&
		    nodeunsigned($n1) ]
		  	{
		  	printf("\tandi.l\t#65535,%s\n",$n1 .s);
		  	save_assign(&$n,&$n1);
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==2 &&
		    dregscratchnode($n1) ]
		  	{
		  	printf("\textw.l\t%s\n",$n1 .s);
		  	save_assign(&$n,&$n1);
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==2 &&
		    immediatenode($n1) ]
		  	{
		  	$n=$n1;
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==2 &&
		    nodeunsigned($n1) ]	
		    	{
		    	d=getdreg();
		    	$n=make_dreg_node(d,$t);
		    	printf("\tmoveq\t#0,d%d\n",d);
		    	printf("\tmove.w\t%s,d%d\n",$n1 .s,d);
		    	freeregs($n1);
		    	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==4 &&
		    nnodesize($n1)==2 ]
		    	{
		    	d=getdreg();
		    	$n=make_dreg_node(d,$t);
		    	printf("\tmove.w\t%s,d%d\n",$n1 .s,d);
		    	printf("\textw.l\td%d\n",d);
		    	freeregs($n1);
		    	}
		    	
		/* b -> w conversions */
		
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==2 &&
		    nnodesize($n1)==1 &&
		    dregscratchnode($n1) &&
		    nodeunsigned($n1) ]
		  	{
		  	printf("\tandi.w\t#255,%s\n",$n1 .s);
		  	save_assign(&$n,&$n1);
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==2 &&
		    nnodesize($n1)==1 &&
		    dregscratchnode($n1) ]
		  	{
		  	printf("\text.w\t%s\n",$n1 .s);
		  	save_assign(&$n,&$n1);
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==2 &&
		    nnodesize($n1)==1 &&
		    immediatenode($n1) ]
		  	{
		  	$n=$n1;
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==2 &&
		    nnodesize($n1)==1 &&
		    nodeunsigned($n1) ]	
		    	{
		    	d=getdreg();
		    	$n=make_dreg_node(d,$t);
		    	printf("\tmoveq\t#0,d%d\n",d);
		    	printf("\tmove.b\t%s,d%d\n",$n1 .s,d);
		    	freeregs($n1);
		    	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==2 &&
		    nnodesize($n1)==1 ]
		    	{
		    	d=getdreg();
		    	$n=make_dreg_node(d,$t);
			printf("\tmove.b\t%s,d%d\n",$n1 .s,d);
		    	printf("\text.w\td%d\n",d);
		    	freeregs($n1);
		    	}

		/* big -> small conversions */
		
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==2 &&
		    nnodesize($n1)==4 ]		
		    	{
		    	save_assign(&$n,&$n1);
		    	$n .type=$t;
		    	incrnode(&$n,2);
		    	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==1 &&
		    nnodesize($n1)==4 ]
		    	{
		    	save_assign(&$n,&$n1);
		    	$n .type=$t;
		    	incrnode(&$n,3);
		    	}
		| sconv zero type(^t) node(^n1)
		  [ ntypesize($t)==1 &&
		    nnodesize($n1)==2 ]
		    	{
		    	save_assign(&$n,&$n1);
		    	$n .type=$t;
		    	incrnode(&$n,1);
		    	}
		    	
		/* floating point conversions */
		
		| sconv zero type(^t) node(^n1)
		  [ floattype($t) && fpregnode($n1) ]
		  	{
		  	$n=$n1;
		  	$n .type=$t;
		  	}
		| sconv zero type(^t) node(^n1)
		  [ floattype($t) ]
		  	{
		  	fp=getfpreg();
		  	$n=make_fpreg_node(fp,$t);
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		snodesize($n1),$n1 .s,fp);
		  	}
		| sconv zero type(^t) node(^n1)
		  [ floattype($n1 .type) ]
		  	{
		  	fp=gettempfpreg();
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		snodesize($n1),$n1 .s,fp);
		  	d=getdreg();
		  	$n=make_dreg_node(d,$t);
		  	printf("\tfmove%s\tfp%d,d%d\n",
		  		stypesize($t),fp,d);
		  	freefpreg(fp);
		  	freeregs($n1);
		  	}

		| sconv zero type(^t) node(^n1)
			{
			printf("* NO SCONV-rule for these types!!!\n");
			save_assign(&$n,&$n1);
			}
		  	
		| unary_call zero type(^t) node(^n1)
		  [ immediatenode($n1) ]
			{ 
			printf("\tjbsr\t%s\n",$n1 .nameonly);
			usedreg(0);
			d=getdreg();
			printf("\tmove%s\td0,d%d\n",stypesize($t),d);
			$n=make_dreg_node(d,$t);
			}
		| unary_call zero type(^t) node(^n1)
			{
			a=gettempareg();
			printf("\tmovea.l\t%s,a%d\n",$n1 .s,a);	
			printf("\tjbsr\t(a%d)\n",a);
			freeareg(a);
			usedreg(0);
			d=getdreg();
			printf("\tmove%s\td0,d%d\n",stypesize($t),d);
			$n=make_dreg_node(d,$t);
			}
		| unary_stcall zero type(^t) size(^s) alignment(^a) node(^n1)
		  [ immediatenode($n1) ]
			{
			printf("\tjbsr\t%s\n",$n1 .nameonly);
			usedreg(0);
			d=getdreg();
			printf("\tmove.l\td0,d%d\n",d);
			$n=make_dreg_node(d,$t);
			}
		| unary_stcall zero type(^t) size(^s) alignment(^a) node(^n1)
			{
			a=gettempareg();
			printf("\tmovea.l\t%s,a%d\n",$n1 .s,a);
			printf("\tjbsr\t(a%d)\n",a);
			freeareg(a);
			usedreg(0);
			d=getdreg();
			printf("\tmove.l\td0,d%d\n",d);
			$n=make_dreg_node(d,$t);
			}
		| fld code(^c) type(^t) node(^n1)
			/* When used as lvalue, fld will be recognized
			   by the assign statement */
			{
			int offset,width;
			d=getdreg();
			$n=make_dreg_node(d,$t);
			$n .bitfld=TRUE;
			offset = $c / 64;
			width  = $c % 64;
			sprintf($n .bfs,"%s {%d:%d}",$n1 .s,offset,width);
			if (typeunsigned($t))
				printf("\tbfextu\t%s,d%d\n",$n .bfs,d);
			else	printf("\tbfexts\t%s,d%d\n",$n .bfs,d);
			freeregs($n1);
			}
		| starg zero type(^t) size(^s) alignment(^a) node(^n1)
			{
			int tempsize;
			int alignedsize;
			/* We're going to fill a buffer with the
			   following instructions, since we don't
			   know whether our parent is a CM or a REV_CM */
			
			empty_starg_buffer();

			tempsize= $s / 8; /* in bytes */
			/* alignment to words */
			alignedsize=( ((tempsize%2)==0)?tempsize:tempsize+1);
			savesize+=alignedsize;

			/* make room on the stack */
			append("\tlea\t-%d(sp),sp\n",alignedsize);

		
			$n .nodetype=stargnode;	

			/* load source pointer */
			if (aregscratchnode($n1)) 
				a1=$n1 .regnr;
			else
				{
				a1=gettempareg();
				if ($n1 .address || $n1 .nodetype==absolute)
					append("\tlea\t%s,a%d\n",$n1 .s,a1);
				else
					append("\tmovea%s\t%s,a%d\n",
						snodesize($n1),$n1 .s,a1);
				}

			/* load destination pointer */
			a2=gettempareg();
			append("\tlea\t(sp),a%d\n",a2);

			/* do the moves */
			if (tempsize >= 3*4) 
				/* more than 3 longs; make a loop */
				{
				int numberoflongs;
				d=gettempdreg();
				numberoflongs=tempsize / 4;
				tempsize -= numberoflongs * 4;
				if (numberoflongs-1 <= 127)
				  append("\tmoveq\t#%d,d%d\n",
						 numberoflongs-1,d);
				else
				  append("\tmove.l\t#%d,d%d\n",
						numberoflongs-1,d);
				l=newlabel++;
				append(".L%d\n",l);
				append("\tmove.l\t(a%d)+,(a%d)+\n",a1,a2);
				append("\tdbra\td%d,.L%d\n",d,l);
				freedreg(d);
				}
			while (tempsize >= 4)
				{
				tempsize -= 4;
				append("\tmove.l\t(a%d)+,(a%d)+\n",a1,a2);
				}
			while (tempsize >= 2)
				{
				tempsize -= 2;
				append("\tmove.w\t(a%d),(a%d)\n",a1,a2);
				}
			freeareg(a1);
			freeareg(a2);
			}




			/* binary nodes */



		| plus type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfadd%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
	  		freeregs($n2);
		  	}
		| plus type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregscratchnode($n2) ]
		  	{
		  	save_assign(&$n,&$n2);
		  	printf("\tfadd%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n1 .s,$n2 .s);
	  		freeregs($n1);
		  	}
		| plus type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	fp=getfpreg();
		  	$n=make_fpreg_node(fp,$t);
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfadd%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
	  		freeregs($n1);
	  		freeregs($n2);
		  	}
		| plus type(^t) node(^n1) node(^n2)
		  [ pointertype($t) && aregscratchnode($n1) &&
		    !$n1 .address && !$n2 .address ]
			{
			save_assign(&$n,&$n1);
			printf("\tadda.l\t%s,%s\n",$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| plus type(^t) node(^n1) node(^n2)
		  [ pointertype($t) && aregscratchnode($n2) &&
		    !$n1 .address && !$n2 .address ]
			{
			save_assign(&$n,&$n2);
			printf("\tadda.l\t%s,%s\n",$n1 .s,$n2 .s);
			freeregs($n1);
			}
		| plus type(^t) node(^n1) node(^n2)
		  [ pointertype($t) && !$n1 .address && !$n2 .address ]
			{
			a=getareg();
			$n=make_areg_node(a,$t);
			printf("\tmovea.l\t%s,a%d\n",$n1 .s,a);
			printf("\tadda.l\t%s,a%d\n",$n2 .s,a);
			freeregs($n1);
			freeregs($n2);
			}
		| plus type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) && verysmallconstant($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\taddq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| plus type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) && verysmallconstant($n1) ]
			{
			save_assign(&$n,&$n2);
			printf("\taddq%s\t%s,%s\n",stypesize($t),$n1 .s,$n2 .s);
			}
		| plus type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) && immediatenode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\taddi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| plus type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) && immediatenode($n1) ]
			{
			save_assign(&$n,&$n2);
			printf("\taddi%s\t%s,%s\n",stypesize($t),$n1 .s,$n2 .s);
			}
		| plus type(^t) node(^n1) node(^n2) 
		  [ dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tadd%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| plus type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) ]
			{
			save_assign(&$n,&$n2);
			printf("\tadd%s\t%s,%s\n",stypesize($t),$n1 .s,$n2 .s);
			freeregs($n1);
			}
		| plus type(^t) node(^n1) node(^n2)
		 	{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			if (immediatenode($n2))
			  printf("\taddi%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			else
			  printf("\tadd%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			freeregs($n1);
			freeregs($n2);
			}

		| minus type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfsub%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
	  		freeregs($n2);
		  	}
		| minus type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	fp=getfpreg();
		  	$n=make_fpreg_node(fp,$t);
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfsub%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
	  		freeregs($n1);
	  		freeregs($n2);
		  	}
		| minus type(^t) node(^n1) node(^n2) 
		  [ pointertype($t) && aregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tsuba.l\t%s,%s\n",$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| minus type(^t) node(^n1) node(^n2) 
		  [ pointertype($t) ]
			{
			a=getareg();
			$n=make_areg_node(a,$t);
			printf("\tmovea.l\t%s,a%d\n",$n1 .s,a);
			printf("\tsuba.l\t%s,a%d\n",$n2 .s,a);
			freeregs($n1);
			freeregs($n2);
			}
		| minus type(^t) node(^n1) node(^n2) 
		  [ pointertype($n1 .type) && pointertype($n2 .type) ]
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove.l\t%s,d%d\n",$n1 .s,d);
			printf("\tsub.l\t%s,d%d\n",$n2 .s,d);
			freeregs($n1);
			freeregs($n2);
			}
		| minus type(^t) node(^n1) node(^n2) 
		  [ !pointertype($t) &&
		    dregscratchnode($n1) && 
		    verysmallconstant($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tsubq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| minus type(^t) node(^n1) node(^n2) 
		  [ !pointertype($t) && dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tsub%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| minus type(^t) node(^n1) node(^n2)
		  [ verysmallconstant($n2) ]
		 	{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tsubq%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			freeregs($n1);
			}
		| minus type(^t) node(^n1) node(^n2)
		 	{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tsub%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			freeregs($n1);
			freeregs($n2);
			}
			
		| mul type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfmul%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
	  		freeregs($n2);
		  	}
		| mul type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregscratchnode($n2) ]
		  	{
		  	save_assign(&$n,&$n2);
		  	printf("\tfmul%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n1 .s,$n2 .s);
	  		freeregs($n1);
		  	}
		| mul type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	fp=getfpreg();
		  	$n=make_fpreg_node(fp,$t);
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfmul%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
	  		freeregs($n1);
	  		freeregs($n2);
		  	}
		| mul type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tmuls%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| mul type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) ]
			{
			save_assign(&$n,&$n2);
			printf("\tmuls%s\t%s,%s\n",stypesize($t),$n1 .s,$n2 .s);
			freeregs($n1);
			}
		| mul type(^t) node(^n1) node(^n2)
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tmuls%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			freeregs($n1);
			freeregs($n2);
			}

		| div type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfdiv%s\t%s,%s\n",
		  		snodesize($n1,$n2),$n2 .s,$n1 .s);
	  		freeregs($n2);
		  	}
		| div type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	fp=getfpreg();
		  	$n=make_fpreg_node(fp,$t);
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfdiv%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
	  		freeregs($n1);
	  		freeregs($n2);
		  	}
		| div type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) ]
			{
			save_assign(&$n,&$n2);
			printf("\tdivs%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n1);
			}
		| div type(^t) node(^n1) node(^n2)
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tdivs%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			freeregs($n1);
			freeregs($n2);
			}
		| mod type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			dr=$n1 .regnr;
			dq=gettempdreg();
			printf("\tmove%s\td%d,d%d\n",stypesize($t),dr,dq);
			printf("\tdivsl%s\t%s,d%d:d%d\n",stypesize($t),$n2 .s,dr,dq);
			freedreg(dq);
			freeregs($n2);
			}
		| mod type(^t) node(^n1) node(^n2)
			{
			dr=getdreg();
			dq=gettempdreg();
			$n=make_dreg_node(dr,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,dr);
			printf("\tmove%s\td%d,d%d\n",stypesize($t),dr,dq);
			printf("\tdivsl%s\t%s,d%d:d%d\n",stypesize($t),$n2 .s,dr,dq);
			freedreg(dq);
			freeregs($n1);
			freeregs($n2);
			}
			
		| and type(^t) node(^n1) node(^n2)
		  [ immediatenode($n1) && dregscratchnode($n2) ]
		  	{
		  	save_assign(&$n,&$n2);
		  	printf("\tandi%s\t%s,%s\n",
		  			stypesize($t),$n1 .s,$n2 .s);
		  	}
		| and type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) && dregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tandi%s\t%s,%s\n",
		  			stypesize($t),$n2 .s,$n1 .s);
		  	}
		| and type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tand%s\t%s,%s\n",
					stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| and type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) ]
			{
			save_assign(&$n,&$n2);
			printf("\tand%s\t%s,%s\n",
					stypesize($t),$n1 .s,$n2 .s);
			freeregs($n1);
			}
		| and type(^t) node(^n1) node(^n2)
		  [ immediatenode($n1) ]
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tandi%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			freeregs($n2);
			}
		| and type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) ]
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tandi%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			freeregs($n1);
			}
		| and type(^t) node(^n1) node(^n2)
		  	{
		  	d=getdreg();
		  	$n=make_dreg_node(d,$t);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tand%s\t%s,d%d\n", stypesize($t),$n2 .s,d);
			freeregs($n1);
			freeregs($n2);
			}
			
/* the or-rules are identical to the and-rules */
			
		| or type(^t) node(^n1) node(^n2)
		  [ immediatenode($n1) && dregscratchnode($n2) ]
		  	{
		  	save_assign(&$n,&$n2);
		  	printf("\tori%s\t%s,%s\n",
		  			stypesize($t),$n1 .s,$n2 .s);
		  	}
		| or type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) && dregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tori%s\t%s,%s\n",
		  			stypesize($t),$n2 .s,$n1 .s);
		  	}
		| or type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tor%s\t%s,%s\n",
					stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| or type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) ]
			{
			save_assign(&$n,&$n2);
			printf("\tor%s\t%s,%s\n",
					stypesize($t),$n1 .s,$n2 .s);
			freeregs($n1);
			}
		| or type(^t) node(^n1) node(^n2)
		  [ immediatenode($n1) ]
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tori%s\t%s,d%d\n", stypesize($t),$n1 .s,d);
			freeregs($n2);
			}
		| or type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) ]
			{
			d=getdreg();
			$n=make_dreg_node(d,$t);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tori%s\t%s,d%d\n", stypesize($t),$n2 .s,d);
			freeregs($n1);
			}
		| or type(^t) node(^n1) node(^n2)
		  	{
		  	d=getdreg();
		  	$n=make_dreg_node(d,$t);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tor%s\t%s,d%d\n",  stypesize($t),$n2 .s,d);
			freeregs($n1);
			freeregs($n2);
			}

/* the er-rules are NOT identical to the or-rules */

		| er type(^t) node(^n1) node(^n2)
		  [ immediatenode($n1) && dregscratchnode($n2) ]
			{
			save_assign(&$n,&$n2);
			printf("\teori%s\t%s,%s\n",
					stypesize($t),$n1 .s,$n2 .s);		
			}
		| er type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) && dregscratchnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\teori%s\t%s,%s\n",
					stypesize($t),$n2 .s,$n1 .s);		
			}
		| er type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n2) ]
			{
			save_assign(&$n,&$n2);
			if (!dregnode($n1))
				{
				d=gettempdreg();
				printf("\tmove%s\t%s,d%d\n",
					stypesize($t),$n1 .s,d);
				freedreg(d);
				}
			else d=$n1 .regnr;
			printf("\teor%s\td%d,%s\n",
					stypesize($t),d,$n2 .s);		
			freeregs($n1);
			}
		| er type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) ]
			{
			if (!dregnode($n2))
				{
				d=gettempdreg();
				printf("\tmove%s\t%s,d%d\n",
					stypesize($t),$n2 .s,d);
				freedreg(d);
				}
			else d=$n2 .regnr;
			printf("\teor%s\td%d,%s\n",
					stypesize($t),d,$n1 .s);		
			freeregs($n2);
			}
		| er type(^t) node(^n1) node(^n2)
			{
			/* put node 1 in a data register, if necessary */
			if (!dregnode($n1))
				{
				dsrc=gettempdreg();
				printf("\tmove%s\t%s,d%d\n",
					stypesize($t),$n1 .s,dsrc);
				}
			else dsrc=$n1 .regnr;
			ddest=getdreg();
			$n=make_dreg_node(ddest,$t);
			printf("\tmove%s\t%s,d%d\n",
				stypesize($t),$n2 .s,ddest);			
			printf("\teor%s\td%d,%s\n",
					stypesize($t),dsrc,ddest);
			if (!dregnode($n1)) freedreg(dsrc);
			freeregs($n1);
			freeregs($n2);
			}
						
		| ls type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) && 
		    (verysmallconstant($n2) || dregnode($n2)) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tasl%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	freeregs($n2);
		  	}
		| ls type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	d=gettempdreg();
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
		  	printf("\tasl%s\td%d,%s\n",stypesize($t),d,$n1 .s);
		  	freedreg(d);
		  	freeregs($n2);
		  	}
		| ls type(^t) node(^n1) node(^n2)
		  [ verysmallconstant($n2) || dregnode($n2) ]
		  	{
		  	d=getdreg();
		  	$n=make_dreg_node(d,$t);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
		  	printf("\tasl%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
		  	freeregs($n1);
		  	freeregs($n2);
		  	}
		| ls type(^t) node(^n1) node(^n2)
		  	{
		  	d1=getdreg();
		  	d2=gettempdreg();
		  	$n=make_dreg_node(d1,$t);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d1);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d2);
		  	printf("\tasl%s\td%d,%s\n",stypesize($t),d2,d1);
		  	freedreg(d2);
		  	freeregs($n1);
		  	freeregs($n2);
		  	}
		  	
/* the rs-rules are identical to the ls-rules */

		| rs type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) && 
		    (verysmallconstant($n2) || dregnode($n2)) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tasr%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	freeregs($n2);
		  	}
		| rs type(^t) node(^n1) node(^n2)
		  [ dregscratchnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	d=gettempdreg();
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
		  	printf("\tasr%s\td%d,%s\n",stypesize($t),d,$n1 .s);
		  	freedreg(d);
		  	freeregs($n2);
		  	}
		| rs type(^t) node(^n1) node(^n2)
		  [ verysmallconstant($n2) || dregnode($n2) ]
		  	{
		  	d=getdreg();
		  	$n=make_dreg_node(d,$t);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
		  	printf("\tasr%s\t%s,d\n",stypesize($t),$n2 .s,d);
		  	freeregs($n1);
		  	freeregs($n2);
		  	}
		| rs type(^t) node(^n1) node(^n2)
		  	{
		  	d1=getdreg();
		  	d2=gettempdreg();
		  	$n=make_dreg_node(d1,$t);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d1);
		  	printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d2);
		  	printf("\tasr%s\td%d,%s\n",stypesize($t),d2,d1);
		  	freedreg(d2);
		  	freeregs($n1);
		  	freeregs($n2);
		  	}

		| asg_plus type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfadd%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
		  		freeregs($n2);
		  	}
		| asg_plus type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	fp=gettempfpreg();
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfadd%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
		  	printf("\tfmove%s\tfp%d,%s\n",
		  		stypesize($t),fp,$n1 .s);
		  	freefpreg(fp);
		  	freeregs($n2);
		  	}
		| asg_plus type(^t1) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tadd%s\t%s,%s\n",snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		| asg_plus type(^t) node(^n1) node(^n2)
		  [ verysmallconstant($n2) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\taddq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	}
		| asg_plus type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\taddi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	}
		| asg_plus type(^t) node(^n1) node(^n2)
		  [ aregnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tadda%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	freeregs($n2);
		  	}
		| asg_plus type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) || dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tadd%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_plus type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tadd%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}
			
/* asg_minus-rules are identical to asg_plus-rules */

		| asg_minus type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfsub%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
		  		freeregs($n2);
		  	}		  	
		| asg_minus type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	fp=gettempfpreg();
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfsub%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
		  	printf("\tfmove%s\tfp%d,%s\n",
		  		stypesize($t),fp,$n1 .s);
		  	freefpreg(fp);
		  	freeregs($n2);
		  	}
		| asg_minus type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tsub%s\t%s,%s\n",snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		| asg_minus type(^t) node(^n1) node(^n2)
		  [ verysmallconstant($n2) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tsubq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	}
		| asg_minus type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tsubi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	}
		| asg_minus type(^t) node(^n1) node(^n2)
		  [ aregnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tsuba%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
		  	freeregs($n2);
		  	}
		| asg_minus type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) || dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tsub%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_minus type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tsub%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}

		| asg_mul type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfmul%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
		  		freeregs($n2);
		  	}		  	
		| asg_mul type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	fp=gettempfpreg();
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfmul%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
		  	printf("\tfmove%s\tfp%d,%s\n",
		  		stypesize($t),fp,$n1 .s);
		  	freefpreg(fp);
		  	freeregs($n2);
		  	}
		| asg_mul type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tmulu%s\t%s,%s\n",
					snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		  
		| asg_mul type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tmuls%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_mul type(^t) node(^n1) node(^n2)
			{
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tmuls%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tmove%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}
			
/* asg_div-rules are identical to asg_mul-rules */

		| asg_div type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregnode($n1) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfdiv%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
		  		freeregs($n2);
		  	}		  	
		| asg_div type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	fp=gettempfpreg();
		  	printf("\tfmove%s\t%s,fp%d\n",
		  		stypesize($t),$n1 .s,fp);
		  	printf("\tfdiv%s\t%s,fp%d\n",
		  		stypesize($t),$n2 .s,fp);
		  	printf("\tfmove%s\tfp%d,%s\n",
		  		stypesize($t),fp,$n1 .s);
		  	freefpreg(fp);
		  	freeregs($n2);
		  	}
		| asg_div type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tdivu%s\t%s,%s\n",
					snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		| asg_div type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tdivs%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_div type(^t) node(^n1) node(^n2)
			{
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tdivs%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tmove%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}

		| asg_mod type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			d2=gettempdreg();
			printf("\tdivu%s\t%s,%s:d%d\n",
				snodesize($n2),$n2 .s,$n1 .s,d2);
			savebf($n1);
			freedreg(d2);
			freeregs($n2);
			}
		| asg_mod type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) ]
			{
			save_assign(&$n,&$n1);
			dr=$n1 .regnr;
			dq=gettempdreg();
			printf("\tmove%s\td%d,d%d\n",stypesize($t),dr,dq);
			printf("\tdivsl%s\t%s,d%d:d%d\n",stypesize($t),$n2 .s,dr,dq);
			freedreg(dq);
			freeregs($n2);
			}
		| asg_mod type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			dr=gettempdreg();
			dq=gettempdreg();
			printf("\tmove%s\td%d,d%d\n",stypesize($t),$n1 .s,dq);
			printf("\tdivsl%s\t%s,d%d:d%d\n",stypesize($t),$n2 .s,dr,dq);
			printf("\tmove%s\td%d,%s\n",stypesize($t),dr,$n1 .s);
			freedreg(dr);
			freedreg(dq);
			freeregs($n2);
			}
			
		| asg_and type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tand%s\t%s,%s\n",snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);			
			}
		| asg_and type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tandi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n1);
			}
		| asg_and type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) || dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tand%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_and type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tand%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}

/* asg_or-rules are identical to asg_and-rules */

		| asg_or type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tor%s\t%s,%s\n",snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		| asg_or type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tori%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| asg_or type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) || dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tor%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_or type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tor%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}

		| asg_er type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\teor%s\t%s,%s\n",snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		| asg_er type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\teori%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			}
		| asg_er type(^t) node(^n1) node(^n2)
		  [ dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\teor%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_er type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\teor%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}
			
		| asg_ls type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) && dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tasl%s\t%s,%s\n",snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		| asg_ls type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			d2=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",snodesize($n2),$n2 .s,d2);
			printf("\tasl%s\td%d,%s\n",snodesize($n2),d2,$n1 .s);
			savebf($n1);	
			freedreg(d2);
			freeregs($n2);
			}
		| asg_ls type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) &&
		   (immediatenode($n2) || dregnode($n2)) ]
			{
			save_assign(&$n,&$n1);
			printf("\tasl%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_ls type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) || dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tasl%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tmove%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}
		| asg_ls type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			dsrc=gettempdreg();
			ddest=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,dsrc);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,ddest);
			printf("\tasl%s\td%d,d%d\n",stypesize($t),dsrc,ddest);
			printf("\tmove%s\td%d,%s\n",stypesize($t),ddest,$n1 .s);
			freedreg(dsrc);
			freedreg(ddest);
			freeregs($n2);
			}

/* asg_rs-rules are identical to asg_ls-rules */

		| asg_rs type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) && dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tasr%s\t%s,%s\n",snodesize($n2),$n2 .s,$n1 .s);
			savebf($n1);
			freeregs($n2);
			}
		| asg_rs type(^t) node(^n1) node(^n2)
		  [ bitfldnode($n1) ]
			{
			save_assign(&$n,&$n1);
			d2=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",snodesize($n2),$n2 .s,d2);
			printf("\tasr%s\td%d,%s\n",snodesize($n2),d2,$n1 .s);
			savebf($n1);
			freedreg(d2);
			freeregs($n2);
			}
		| asg_rs type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) &&
		   (immediatenode($n2) || dregnode($n2)) ]
			{
			save_assign(&$n,&$n1);
			printf("\tasr%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| asg_rs type(^t) node(^n1) node(^n2)
		  [ immediatenode($n2) || dregnode($n2) ]
			{
			save_assign(&$n,&$n1);
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,d);
			printf("\tasr%s\t%s,d%d\n",stypesize($t),$n2 .s,d);
			printf("\tmove%s\td%d,%s\n",stypesize($t),d,$n1 .s);
			freedreg(d);
			freeregs($n2);
			}
		| asg_rs type(^t) node(^n1) node(^n2)
			{
			save_assign(&$n,&$n1);
			dsrc=gettempdreg();
			ddest=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n2 .s,dsrc);
			printf("\tmove%s\t%s,d%d\n",stypesize($t),$n1 .s,ddest);
			printf("\tasr%s\td%d,d%d\n",stypesize($t),dsrc,ddest);
			printf("\tmove%s\td%d,%s\n",stypesize($t),ddest,$n1 .s);
			freedreg(dsrc);
			freedreg(ddest);
			freeregs($n2);
			}

		| comop type(^t) node(^n1) node(^n2)
			{
			$n=$n2;
			freeregs($n1);
			}
		| assign type(^t) node(^n1) node(^n2)
		  [ floattype($t) && fpregnode($n2) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	printf("\tfmove%s\t%s,%s\n",
		  		snodesize2($n1,$n2),$n2 .s,$n1 .s);
	  		freeregs($n2);
		  	}
		| assign type(^t) node(^n1) node(^n2)
		  [ floattype($t) ]
		  	{
		  	save_assign(&$n,&$n1);
		  	movefloat($n2,$n1,ntypesize($t));
		  	freeregs($n2);
		  	}
		| assign type(^t1)
			fld code(^c) type(^t2) node(^n1)
			node(^n2)
		  [ zeroconstant($n2) ]
			{
			$n=$n2;
			printf("\tbfclr\t%s {%d:%d}\n",$n1 .s,$c/64,$c%64);
			}
		| assign type(^t1) 
			fld code(^c) type(^t2) node(^n1) 
			node(^n2)
		  [ dregnode($n2) ]
			{
			save_assign(&$n,&$n2);
			printf("\tbfins\t%s,%s {%d:%d}\n",
					$n2 .s,$n1 .s,$c/64,$c%64);
			freeregs($n2);
			}
		| assign type(^t1) 
			fld code(^c) type(^t2) node(^n1) 
			node(^n2)
			{
			d=getdreg();
			$n=make_dreg_node(d,$t1);
			printf("\tmove%s\t%s,d%d\n",
					snodesize($n2),$n2 .s,d);
			printf("\tbfins\td%d,%s {%d:%d}\n",
				d,$n1 .s,$c/64,$c%64);
			freeregs($n1);
			freeregs($n2);
			}
		| assign type(^t) node(^n1) node(^n2)
		  [ zeroconstant($n2) ]
			{
			$n=$n2;
			printf("\tclr%s\t%s\n",stypesize($t),$n1 .s);
			}
		| assign type(^t) node(^n1) node(^n2)
		  [ $n2 .address && aregvarnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tlea\t%s,%s\n",$n2 .s,$n1 .s);
			}
		| assign type(^t) node(^n1) node(^n2)
		  [ $n2 .address ]
			{
			save_assign(&$n,&$n1);
			a=gettempareg();
			printf("\tlea\t%s,a%d\n",$n2 .s,a);
			printf("\tmove%s\ta%d,%s\n",stypesize($t),a,$n1 .s);
			freeareg(a);
			freeregs($n2);
			}
		| assign type(^t) node(^n1) node(^n2)
		  [ dregnode($n1) && smallconstant($n2) ]
			{
			save_assign(&$n,&$n1);
			printf("\tmoveq\t#%d,%s\n",$n2 .value,$n1 .s);
			}
		| assign type(^t) node(^n1) node(^n2)
		  [ aregnode($n1) ]
			{
			save_assign(&$n,&$n1);
			printf("\tmovea%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
		| assign type(^t) node(^n1) node(^n2)
			{ 
			save_assign(&$n,&$n1);
			printf("\tmove%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			freeregs($n2);
			}
			
/* At the INCR and DECR rules C if-statements are favoured over
   CGYACC predicates because the use of predicates would rather explode
   the number of rules.
 */
			
		| incr type(^t)
		    node(^n1) 
		    node(^n2)
			{
			if (pointertype($t))
				{
				a=getareg();
				$n=make_areg_node(a,$t);
				printf("\tmovea%s\t%s,a%d\n",
					snodesize($n1),$n1 .s,a);
				}
			else	{
				d=getdreg();
				$n=make_dreg_node(d,$t);
				printf("\tmove%s\t%s,d%d\n",
					snodesize($n1),$n1 .s,d);
				}
			if (verysmallconstant($n2))
			  printf("\taddq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else if (immediatenode($n2))
			  printf("\taddi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else if (dregnode($n1) || dregnode($n2))
			  printf("\tadd%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else if (aregnode($n1))
			  printf("\tadda%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else	{
				d=gettempdreg();
				printf("\tmove%s\t%s,d%d\n",
					stypesize($t),$n2 .s,d);
				printf("\tadd%s\td%d,%s\n",
					stypesize($t),d,$n1 .s);
				freedreg(d);
				}			  
			freeregs($n2);			
			}
		| decr type(^t)
		    node(^n1) 
		    node(^n2)
			{
			if (pointertype($t))
				{
				a=getareg();
				$n=make_areg_node(a,$t);
				printf("\tmovea%s\t%s,a%d\n",
					snodesize($n1),$n1 .s,a);
				}
			else	{
				d=getdreg();
				$n=make_dreg_node(d,$t);
				printf("\tmove%s\t%s,d%d\n",
					snodesize($n1),$n1 .s,d);
				}
			if (verysmallconstant($n2))
			  printf("\tsubq%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else if (immediatenode($n2))
			  printf("\tsubi%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else if (dregnode($n1) || dregnode($n2))
			  printf("\tsub%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else if (aregnode($n1))
			  printf("\tsuba%s\t%s,%s\n",stypesize($t),$n2 .s,$n1 .s);
			else	{
				d=gettempdreg();
				printf("\tmove%s\t%s,d%d\n",
					stypesize($t),$n2 .s,d);
				printf("\tsub%s\td%d,%s\n",
					stypesize($t),d,$n1 .s);
				freedreg(d);
				}			  
			freeregs($n2);
			}
			
		| call mark type(^t) node(^n1) node(^n2)
			{ 
			/******** push argument **********/
			if (ordinarynode($n2))
			  {
			  savesize+=4;
			  if ($n2 .address || $n2 .nodetype==absolute)
			    printf("\tpea\t%s\n",$n2 .s);
			  else
			  if (immediatenode($n2))
			    printf("\tpea\t%s\n",$n2 .nameonly);
			  else
			    printf("\tmove.l\t%s,-(sp)\n",$n2 .s);
    			  freeregs($n2);
			  }
			else if ($n2 .nodetype==stargnode)
				output_starg_buffer();

			/* flush instruction stack */
			
			flush_stack_till_marker();

			/********** do the jump ************/
			if (immediatenode($n1))
				printf("\tjbsr\t%s\n",$n1 .nameonly);
			else if (aregnode($n1))
				printf("\tjbsr\t(%s)\n",$n1 .s);
			else
				{
				a=gettempareg();
				printf("\tmovea%s\t%s,a%d\n",
					snodesize($n1),$n1 .s,a);
				printf("\tjbsr\t(a%d)\n",a);
				freeareg(a);
				}
			freeregs($n1);
			/********** adjust the stackpointer *****/
			if (savesize>8)
			      printf("\tlea\t%d(sp),sp\n",savesize);
			else  printf("\taddq.l\t#%d,sp\n",savesize);
			
			/* We don't know whether d0 will be needed
			   again in this tree, so we ALWAYS put the
			   result (d0) in a free register. 
			   Something must be done, someday...
			*/
			usedreg(0);
			d=getdreg();
			printf("\tmove%s\td0,d%d\n",stypesize($t),d);
			$n=make_dreg_node(d,$t);
			pop_savesize(); /* pushed by mark */
			}
		| cm type(^t) cmsubnode(^n1) cmsubnode(^n2)
			{
			$n .nodetype=cmnode;
			}
		;

cmsubnode(^n) : node(^n1)
			{ 
			save_assign(&$n,&$n1);
			/* pushes push-instructions on a stack */ 

			if (ordinarynode($n1))
				{
				genpushpush($n1);
				/* Do NOT free registers, because they
				   still must be referenced when 
				   the stack is flushed */
				}				
			else if ($n1 .nodetype==stargnode)
				{
				while (starg_buffer_top>=0)
					push(starg_buffer[starg_buffer_top--]);
				}
			}
		;
node(^n)	: rev_cm type(^t) rev_cmsubnode(^n1) rev_cmsubnode(^n2) 
			{
			$n .nodetype=cmnode;
			}
		;

rev_cmsubnode(^n) : node(^n1)
			{ 
			save_assign(&$n,&$n1);
			/* directly outputs this node */

			if (ordinarynode($n1))
				{
				genpush($n1);
				freeregs($n1);
				}				
			else if ($n1 .nodetype==stargnode)
				output_starg_buffer();
			}
		;

node(^n)	: stasg type(^t) size(^s) alignment(^a) 
		    unary_mul zero type(^t1)
		      node(^n1) 
		    node(^n2)
		  [ !pointertype($t1) ]
			{
			/* alignment of 16 bits always assumed */
			int tempsize; 
			save_assign(&$n,&$n1);
			/* load source pointer */
			if (aregscratchnode($n2)) 
				a1=$n2 .regnr;
			else
				{
				a1=gettempareg();
				if ($n2 .address || $n2 .nodetype==absolute)
					printf("\tlea\t%s,a%d\n",$n2 .s,a1);
				else
					printf("\tmovea%s\t%s,a%d\n",
						snodesize($n2),$n2 .s,a1);
				}

			/* load destination pointer */
			if (aregscratchnode($n1)) 
				a2=$n1 .regnr;
			else
				{
				a2=gettempareg();
				if ($n1 .address || $n1 .nodetype==absolute)
					printf("\tlea\t%s,a%d\n",$n1 .s,a2);
				else
					printf("\tmovea%s\t%s,a%d\n",
						snodesize($n1),$n1 .s,a2);
				}

			/* do the moves */
			tempsize= $s / 8; /* in bytes */
			if (tempsize >= 3*4) 
				/* more than 3 longs; make a loop */
				{
				int numberoflongs;
				d=gettempdreg();
				numberoflongs=tempsize / 4;
				tempsize -= numberoflongs * 4;
				if (numberoflongs-1 <= 127)
				  printf("\tmoveq\t#%d,d%d\n",
						 numberoflongs-1,d);
				else
				  printf("\tmove.l\t#%d,d%d\n",
						numberoflongs-1,d);
				l=newlabel++;
				printf(".L%d\n",l);
				printf("\tmove.l\t(a%d)+,(a%d)+\n",a1,a2);
				printf("\tdbra\td%d,.L%d\n",d,l);
				freedreg(d);
				}
			while (tempsize >= 4)
				{
				tempsize -= 4;
				printf("\tmove.l\t(a%d)+,(a%d)+\n",a1,a2);
				}
			while (tempsize >= 2)
				{
				tempsize -= 2;
				printf("\tmove.w\t(a%d),(a%d)\n",a1,a2);
				}
			freeareg(a1);
			freeareg(a2);
			freeregs($n2);
			}
		| stasg type(^t) size(^s) alignment(^a) node(^n1) node(^n2)
			{
			/* alignment of 16 bits always assumed */
			int tempsize; 
			save_assign(&$n,&$n1);
			/* load source pointer */
			if (aregscratchnode($n2)) 
				a1=$n2 .regnr;
			else
				{
				a1=gettempareg();
				if ($n2 .address || $n2 .nodetype==absolute)
					printf("\tlea\t%s,a%d\n",$n2 .s,a1);
				else
					printf("\tmovea%s\t%s,a%d\n",
						snodesize($n2),$n2 .s,a1);
				}

			/* load destination pointer */
			if (aregscratchnode($n1)) 
				a2=$n1 .regnr;
			else
				{
				a2=gettempareg();
				if ($n1 .address || $n1 .nodetype==absolute)
					printf("\tlea\t%s,a%d\n",$n1 .s,a2);
				else
					printf("\tmovea%s\t%s,a%d\n",
						snodesize($n1),$n1 .s,a2);
				}

			/* do the moves */
			tempsize= $s / 8; /* in bytes */
			if (tempsize >= 3*4) 
				/* more than 3 longs; make a loop */
				{
				int numberoflongs;
				d=gettempdreg();
				numberoflongs=tempsize / 4;
				tempsize -= numberoflongs * 4;
				if (numberoflongs-1 <= 127)
				  printf("\tmoveq\t#%d,d%d\n",
						 numberoflongs-1,d);
				else
				  printf("\tmove.l\t#%d,d%d\n",
						numberoflongs-1,d);
				l=newlabel++;
				printf(".L%d\n",l);
				printf("\tmove.l\t(a%d)+,(a%d)+\n",a1,a2);
				printf("\tdbra\td%d,.L%d\n",d,l);
				freedreg(d);
				}
			while (tempsize >= 4)
				{
				tempsize -= 4;
				printf("\tmove.l\t(a%d)+,(a%d)+\n",a1,a2);
				}
			while (tempsize >= 2)
				{
				tempsize -= 2;
				printf("\tmove.w\t(a%d),(a%d)\n",a1,a2);
				}
			freeareg(a1);
			freeareg(a2);
			freeregs($n2);
			}
		| stcall mark type(^t) size(^s) alignment(^a) 
			node(^n1) 
			node(^n2)
			/* same code as for call statement */
			{ 
			/******** push argument **********/
			if (ordinarynode($n2))
			  {
			  freeregs($n2);
			  savesize+=4;
			  if ($n2 .address || $n2 .nodetype==absolute)
			    printf("\tpea\t%s\n",$n2 .s);
			  else
			  if (immediatenode($n2))
			    printf("\tpea\t%s\n",$n2 .nameonly);
			  else
			    printf("\tmove.l\t%s,-(sp)\n",$n2 .s);
			  }
			else if ($n2 .nodetype==stargnode)
				output_starg_buffer();

			/* flush instruction stack */
			
			flush_stack_till_marker();

			/********** do the jump ************/
			if (immediatenode($n1))
				printf("\tjbsr\t%s\n",$n1 .nameonly);
			else
				{
				a=gettempareg();
				printf("\tmovea%s\t%s,a%d\n",
						snodesize($n1),$n1 .s,a);
				printf("\tjbsr\t(a%d)\n",a);
				freeareg(a);
				}
			freeregs($n1);
			/********** adjust the stackpointer *****/
			if (savesize>8)
			      printf("\tlea\t%d(sp),sp\n",savesize);
			else  printf("\taddq.l\t#%d,sp\n",savesize);
			
			/* We don't know whether d0 will be needed
			   again in this tree, so we ALWAYS put the
			   result (d0) in a free register. 
			   Something must be done, someday...
			*/
			usedreg(0);
			d=getdreg();
			printf("\tmove%s\td0,d%d\n",stypesize($t),d);
			$n=make_dreg_node(d,$t);
			pop_savesize(); /* pushed by mark */
			}
	
		;



/*********************/
/* Condition section */
/*********************/

/* Rules to translate conditions to nodes and vice versa */


node(^n)	: genlabel(^falselabel,invert) condition(|falselabel,invert)
			{
			d=getdreg();
			$n=make_dreg_node(d,4); /* 4 means int type */
			printf("\tmoveq\t#1,d%d\n",d);
			endlabel=newlabel++;
			printf("\tjra\t.L%d\n",endlabel);
			printf(".L%d\n",$falselabel);
			printf("\tclr.l\td%d\n",d);
			printf(".L%d\n",endlabel);
			}
		;

condition(|falselabel,invert)
		: node(^n) [ zeroconstant($n) ]
			{
			if (!$invert) printf("\tjra\t.L%d\n",$falselabel);
			}
		| node(^n) [ immediatenode($n) ] /* so a nonzero constant */
			{
		  	if ($invert) printf("\tjra\t.L%d\n",$falselabel);
			}
		| node(^n)
		  [ aregnode($n) ]	
			{
			d=gettempdreg();
			printf("\tmove%s\t%s,d%d\n",
				snodesize($n), $n .s,d);
			if ($invert)
				printf("\tbne\t.L%d\n",$falselabel);
			else	printf("\tbeq\t.L%d\n",$falselabel);
			freedreg(d);
			}
		| node(^n)
			{
			printf("\ttst%s\t%s\n",snodesize($n),$n .s);
			if ($invert)
				printf("\tbne\t.L%d\n",$falselabel);
			else	printf("\tbeq\t.L%d\n",$falselabel);
			}
		;


/* boolean operators will initially be regarded as "conditions" */		


condition(|falselabel,invert) 
		: eq type(^t) node(^n1) node(^n2)
		  [ floattype($n1 .type) || floattype($n2 .type) ]
			{
			outputfcmp($n1,$n2);
			if ($invert)
				printf("\tjfeq\t.L%d\n",$falselabel);
			else 	printf("\tjfne\t.L%d\n",$falselabel);
			}
		| eq type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				printf("\tjeq\t.L%d\n",$falselabel);
			else	printf("\tjne\t.L%d\n",$falselabel);
			}
		| ne type(^t) node(^n1) node(^n2)
		  [ floattype($n1 .type) || floattype($n2 .type) ]
			{
			outputfcmp($n1,$n2);
			if ($invert)
				printf("\tjfne\t.L%d\n",$falselabel);
			else 	printf("\tjfeq\t.L%d\n",$falselabel);
			}
		| ne type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				printf("\tjne\t.L%d\n",$falselabel);
			else	printf("\tjeq\t.L%d\n",$falselabel);
			}
		| gt type(^t) node(^n1) node(^n2)
		  [ floattype($n1 .type) || floattype($n2 .type) ]
			{
			outputfcmp($n1,$n2);
			if ($invert)
				printf("\tjfgt\t.L%d\n",$falselabel);
			else 	printf("\tjfle\t.L%d\n",$falselabel);
			}
		| gt type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjlt\t.L%d\n",$falselabel);
				else 	printf("\tjgt\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjge\t.L%d\n",$falselabel);
				else	printf("\tjle\t.L%d\n",$falselabel);
			}
		| ge type(^t) node(^n1) node(^n2)
		  [ floattype($n1 .type) || floattype($n2 .type) ]
			{
			outputfcmp($n1,$n2);
			if ($invert)
				printf("\tjfge\t.L%d\n",$falselabel);
			else 	printf("\tjflt\t.L%d\n",$falselabel);
			}
		| ge type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjle\t.L%d\n",$falselabel);
				else 	printf("\tjge\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjgt\t.L%d\n",$falselabel);
				else	printf("\tjlt\t.L%d\n",$falselabel);
			}		
		| lt type(^t) node(^n1) node(^n2)
		  [ floattype($n1 .type) || floattype($n2 .type) ]
			{
			outputfcmp($n1,$n2);
			if ($invert)
				printf("\tjflt\t.L%d\n",$falselabel);
			else 	printf("\tjfge\t.L%d\n",$falselabel);
			}
		| lt type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjgt\t.L%d\n",$falselabel);
				else 	printf("\tjlt\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjle\t.L%d\n",$falselabel);
				else	printf("\tjge\t.L%d\n",$falselabel);
			}		
		| le type(^t) node(^n1) node(^n2)
		  [ floattype($n1 .type) || floattype($n2 .type) ]
			{
			outputfcmp($n1,$n2);
			if ($invert)
				printf("\tjfle\t.L%d\n",$falselabel);
			else 	printf("\tjfgt\t.L%d\n",$falselabel);
			}
		| le type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjge\t.L%d\n",$falselabel);
				else 	printf("\tjle\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjlt\t.L%d\n",$falselabel);
				else	printf("\tjgt\t.L%d\n",$falselabel);
			}
	
		| ugt type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjcs\t.L%d\n",$falselabel);
				else 	printf("\tjhi\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjcc\t.L%d\n",$falselabel);
				else	printf("\tjls\t.L%d\n",$falselabel);
			}
		| uge type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjls\t.L%d\n",$falselabel);
				else 	printf("\tjcc\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjhi\t.L%d\n",$falselabel);
				else	printf("\tjcs\t.L%d\n",$falselabel);
			}		
		| ult type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjhi\t.L%d\n",$falselabel);
				else 	printf("\tjcs\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjls\t.L%d\n",$falselabel);
				else	printf("\tjcc\t.L%d\n",$falselabel);
			}		
		| ule type(^t) node(^n1) node(^n2)
		  	{
		  	outputcmp($n1,$n2,&exchanged);
			if ($invert)
				if (exchanged)
					printf("\tjcc\t.L%d\n",$falselabel);
				else 	printf("\tjls\t.L%d\n",$falselabel);
			else	if (exchanged)
					printf("\tjcs\t.L%d\n",$falselabel);
				else	printf("\tjhi\t.L%d\n",$falselabel);
			}


		| not zero notcopy(|falselabel,invert,^t,falselabel1,invert1) 
				              condition(|falselabel1,invert1)

			 /* notcopy inverts the "invert" attribute */

			
		| andand  
		  preparelabels(|falselabel,invert,
		  	      ^t,truelabel1,falselabel1,invert1)
		  andandlnode(|truelabel1,falselabel1,invert1)
		  andandrnode(|truelabel1,falselabel1,invert1)
		| oror  
		  preparelabels(|falselabel,invert,
		  	      ^t,truelabel1,falselabel1,invert1)
		  ororlnode(|truelabel1,falselabel1,invert1)
		  ororrnode(|truelabel1,falselabel1,invert1)
		;

node(^n)	: cbranch type(^t) node(^n1) node(^n2)
		  [ zeroconstant($n1) ]
			{
			$n=make_dummy_node();
			printf("\tjra\t.L%d\n",$n2 .value);
			}
		| cbranch type(^t) node(^n1) node(^n2)
		  [ immediatenode($n1) ]
		  /* constant non-zero value? */
			{
			$n=make_dummy_node();
			/* node 1 is true, so don't jump */
			}
		| cbranch type(^t) node(^n1) node(^n2)
			{
			$n=make_dummy_node();
			printf("\ttst%s\t%s\n",snodesize($n1),$n1 .s);
			printf("\tjeq\t.L%d\n",$n2 .value);
			freeregs($n1);
			}
		| rev_cbranch type(^t) 
		    node(^n1) 
		    rev_cbranchcopy(|n1,^falselabel,invert)
		    condition(|falselabel,invert)
		  /* no action, the condition takes care of the jump */
			{
			$n=make_dummy_node();
			}

		| quest type(^t1) 
		  questgenstuff(^dreg,endlabel,falselabel,invert)
		  condition(|falselabel,invert)
		  colon discardtype 
		  colonlnode(|dreg,endlabel,falselabel,invert)
		  colonrnode(|dreg,endlabel,falselabel,invert)
			{
			$n=make_dreg_node($dreg,$t1);
			}
		;

/* attribute movers and some other tricky rules */

colonlnode(|dreg,endlabel,falselabel,invert)
		: node(^n)
		  	{
		  	printf("\tmove%s\t%s,d%d\n",
		  		snodesize($n),$n .s,$dreg);
		  	printf("\tjra\t.L%d\n",$endlabel);
		  	printf(".L%d\n",$falselabel);
		  	}
		;
colonrnode(|dreg,endlabel,falselabel,invert)
		: node(^n)
			{
			printf("\tmove%s\t%s,d%d\n",
				snodesize($n),$n .s,$dreg);
			printf(".L%d\n",$endlabel);
			}
		;		


genlabel(^falselabel,invert)
		: /* epsilon */
		 	{ 
			$falselabel=newlabel++;
			$invert=FALSE;
			}
		;
		


questgenstuff(^dreg,endlabel,falselabel,invert)
		: 	{
			/* generate two labels for question/colon construct */
			$falselabel=newlabel++;
			$endlabel=newlabel++;

			$invert=FALSE;

			/* generate data register number for storing result */
			$dreg=getdreg();
			}
		;

notcopy(|falselabel,invert,^t,falselabel1,invert1) 
		: type(^t1) 
			{
			$t = $t1;
			$falselabel1 = $falselabel;
			$invert1 = !$invert;   /* That does it! */
			}
		;
		
preparelabels(|falselabel,invert,
	    ^t,truelabel1,falselabel1,invert1)
	    /* put a truelabel and a falselabel on the attributestack */
		: type(^t1)
			{
			$t=$t1;
			$invert1=$invert;
			$truelabel1=newlabel++;
			$falselabel1=$falselabel;
			}
		;
		
		
/* Note the nice duality between && and || */

andandlnode(|truelabel,falselabel,invert)
		: andandlcopy(|truelabel,falselabel,invert,
			      ^falselabel1,invert1)
		  condition(|falselabel1,invert1)
		;
andandlcopy(|truelabel,falselabel,invert,^falselabel1,invert1)
		:	{
			$invert1=FALSE;
			if ($invert) $falselabel1=$truelabel;
			else	     $falselabel1=$falselabel;
			}
		;
				
andandrnode(|truelabel,falselabel,invert)
		: andandrcopy(|truelabel,falselabel,invert,
			      ^falselabel1,invert1)
		  condition(|falselabel1,invert1)
		  	{
		  	if ($invert) printf(".L%d\n",$truelabel);
		  	}
		;
andandrcopy(|truelabel,falselabel,invert,^falselabel1,invert1)
		:	{
			$falselabel1=$falselabel;
			if ($invert) $invert1=TRUE;
			else	     $invert1=FALSE;
			}
		;
		
ororlnode(|truelabel,falselabel,invert)
		: ororlcopy(|truelabel,falselabel,invert,
			      ^falselabel1,invert1)
		  condition(|falselabel1,invert1)
		;
ororlcopy(|truelabel,falselabel,invert,^falselabel1,invert1)
		:	{
			$invert1=TRUE;
			if ($invert) $falselabel1=$falselabel;
			else	     $falselabel1=$truelabel;
			}
		;
				
ororrnode(|truelabel,falselabel,invert)
		: ororrcopy(|truelabel,falselabel,invert,
			      ^falselabel1,invert1)
		  condition(|falselabel1,invert1)
		  	{
		  	if (!$invert) printf(".L%d\n",$truelabel);
		  	}
		;
ororrcopy(|truelabel,falselabel,invert,^falselabel1,invert1)
		:	{
			$falselabel1=$falselabel;
			if ($invert) $invert1=TRUE;
			else	     $invert1=FALSE;
			}
		;

rev_cbranchcopy(|n1,^falselabel,invert)
		:	{
			$falselabel=$n1 .value;
			$invert=FALSE;
			}
		;


mark		:	{
			/* marks bottom of stack for this call */
			mark_stack();
			/* remember savesize if this is a parameter */
			push_savesize();
			savesize=0;
			}
		;
		
/* End of attribute movers and tricky rules */		



/*************************/
/* optimizations section */
/*************************/

/*
The codegenerator would work with just the previous production rules;
the following rules recognize special IC constructs which correspond
to special instructions or particular addressing modes of the 68020.
*/

/* Complex adressing modes */

		/* A node is regarded an addressing mode only if 
		  the contents of an address is taken */

node(^n)	: unary_mul zero type(^t) node(^a)
		  [ $a .address ] 
		  %cost 0 
			{
			$n=$a; /* copy everything */
			$n .type=$t; /* it's no pointer no more */
			$n .address=FALSE; /* neither an address */
			}
		;

/* The following rules are all address computations */

		/* register indirect plus or minus offset */

node(^n)	: minus type(^t) 
		    node(^n1) 
		    node(^n2)
		  [ pointertype($t) && aregnode($n1) && wordconstant($n2) ]
		  %cost 5
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .address=TRUE;
			$n .nodetype=aregind_with_displacement;
			sprintf($n .s,"-%d(%s)",$n2 .value,$n1 .s);
			if ($n .offsetknown=$n2 .valueknown)
				$n .offset= -$n2 .value;
			else	strcpy($n .offsets,strcat("-",$n2 .s));
			$n .baseregnr=$n1 .regnr;
			}			
		| plus type(^t)
		    node(^n1) 
		    node(^n2)
		  [ pointertype($t) && aregnode($n1) && wordconstant($n2) ]
		  %cost 5
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .address=TRUE;
			$n .nodetype=aregind_with_displacement;
			sprintf($n .s,"%d(%s)",$n2 .value,$n1 .s);
			if ($n .offsetknown=$n2 .valueknown)
				$n .offset= $n2 .value;
			else	strcpy($n .offsets,$n2 .s);
			$n .baseregnr=$n1 .regnr;
			}

		/* postincrement */

		| incr type(^t)
		      node(^n1)
		      node(^n2)
		  [ pointertype($t) && aregvarnode($n1) &&
		    knownconstant($n2) && (ndereftypesize($t)==$n2 .value) ]
		  %cost 3
			 /* increment must match size of type */
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .address=TRUE;
			$n .nodetype=postinc;
			$n .regnr=$n1 .regnr;
			$n .offset=$n2 .value;
				/* offset used when this is a topnode */
			sprintf($n .s,"(a%d)+",$n1 .regnr);
			}

		/* predecrement */

		| asg_minus type(^t)
		    node(^n1)
		    node(^n2)
		  [ pointertype($t) && aregvarnode($n1) &&
		    knownconstant($n2) && (ndereftypesize($t)==$n2 .value) ]
		  %cost 3
			 /* decrement must match size of type */
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .address=TRUE;
			$n .nodetype=predec;
			$n .regnr=$n1 .regnr;
			$n .offset=$n2 .value;   
				/* offset used when this is a topnode  */
			sprintf($n .s,"-(a%d)",$n1 .regnr);
			}

		/* address register indirect with index & base displacement */
		
		| plus type(^t1)
		      minus type(^t2)
			node(^n1)
			node(^n2)
		      node(^n3)
		  [ pointertype($t1) && smallconstant($n2) ]
		  %cost 7
			/* Node 2 is an icon, so
			   we can now use this addressing mode effectively. */
			{
			int afound = FALSE;
			int dfound = FALSE;
			int used1  = FALSE; /* node 1 used? */
			int used3  = FALSE; /* node 3 used? */
			char *indexsize;
			switch ($n1 .nodetype)
				{
				case areg:	a=$n1 .regnr; 
						afound=TRUE; break;
				case dreg:	d=$n1 .regnr; 
						indexsize=snodesize($n1);
						dfound=TRUE; break;
				default:	used1=FALSE;
				}
			switch ($n3 .nodetype)
				{
				case areg:	a=$n3 .regnr;
						afound=TRUE; break;
				case dreg:	d=$n3 .regnr;
						indexsize=snodesize($n3);
						dfound=TRUE; break;
				default:	used3=FALSE;
				}
			if (!afound) /* do something about it */
				{
				a=getareg();
				if (!used1) /* use node 1 for areg */
					{
					if ($n1 .address)
					printf("\tlea\t%s,a%d\n",$n1 .s,a);
					else
					printf("\tmovea.l\t%s,a%d\n",
							$n1 .s,a);
					used1=TRUE;
					}
				else /* use node 3 */
					{
					if ($n3 .address)
					printf("\tlea\t%s,a%d\n",$n3 .s,a);
					else
					printf("\tmovea.l\t%s,a%d\n",
							$n3 .s,a);
					used3=TRUE;
					}
				}
			if (!dfound) /* do something about it */
				{
				d=getdreg();
				if (!used1) /* use node 1 for dreg */
					{
					if ($n1 .address)
						{
						/* put in areg first: 
								not nice */
						a1=gettempareg();
						printf("\tlea\t%s,a%d\n",
							$n1 .s,a1);
						printf("\tmove.l\ta%d,d%d\n",
							a1,d);
						freeareg(a1);
						}
					else 	printf("\tmove%s\t%s,d%d\n",
						   snodesize($n1),$n1 .s,d);
					indexsize=snodesize($n1);
					used1=TRUE;
					}
				else /* use node 3 */
					{
					if ($n3 .address)
						{
						/* put in areg first: 
								not nice */
						a1=gettempareg();
						printf("\tlea\t%s,a%d\n",
							$n3 .s,a1);
						printf("\tmove.l\ta%d,d%d\n",
							a1,d);
						freeareg(a1);
						}
					else 	printf("\tmove%s\t%s,d%d\n",
						snodesize($n3),$n3 .s,d);
					indexsize=snodesize($n3);
					used3=TRUE;
					}
				}
			$n=initnodeattr();
			$n .nodetype=aregind_with_index;
			$n .type=$t1;
			$n .address=TRUE;
			sprintf($n .s,"-%d(a%d,d%d%s)",
					$n2 .value,a,d,indexsize);
			$n .offsetknown=TRUE;
			$n .offset= -$n2 .value;
			$n .baseregnr=a;
			$n .indexregnr=d;
			$n .indexregtype='d';
			}


		/* The following rules are more general forms of the previous
		   rule, and must be present to prevent the parser from
		   blocking. These rules are called "bridge productions".
		*/
		| plus type(^t1)
		      minus type(^t2)
			node(^n1)
			node(^n2)
		      node(^n3)
		  [ pointertype($t1) ] 
			{
			/* Output subtraction, put result in an areg */
			if (aregscratchnode($n1)) a1=$n1 .regnr;
			else a1=getareg();
			if (wordconstant($n2) && aregnode($n1))
				printf("\tlea\t-%s(a%d),a%d\n",
						$n2 .nameonly,$n1 .regnr,a1);
			else	{
				if (!aregscratchnode($n1))
					{
					if ($n1 .address)
						printf("\tlea\t%s,a%d\n",
							$n1 .s,a1);
					else 	printf("\tmovea.l\t%s,a%d\n",
							$n1 .s,a1);
					}
			 	printf("\tsuba.l\t%s,a%d\n",$n2 .s,a1);
				}
			/* node 3 in areg or dreg? */
			if (aregnode($n3) || $n3 .address)
				/* put in areg */
				{
				if (!aregnode($n3))  /* it's an address */
					{
					a2=getareg();
					printf("\tlea\t%s,a%d\n",$n3 .s,a2);
					}
				else  /* n3 already in areg */
					a2=$n3 .regnr;
				sprintf($n .s,"0(a%d,a%d%s)",
						a1,a2,snodesize($n3));
				$n .indexregnr=a2;
				$n .indexregtype='a';
				}
			else /* put in dreg */
				{
				if (dregnode($n3))
					d=$n3 .regnr;
				else
					{
					d=getdreg();
					printf("\tmove%s\t%s,d%d\n",
						snodesize($n3),$n3 .s,d);
					}
				sprintf($n .s,"0(a%d,d%d%s)",
						a1,d,snodesize($n3));
				$n .indexregnr=d;
				$n .indexregtype='d';
				}
			$n .nodetype=aregind_with_index;
			$n .type=$t1;
			$n .address=TRUE;
			$n .offsetknown=TRUE;
			$n .offset=0;
			$n .baseregnr=a1;
			}

		/* Most general bridge production */
		| plus type(^t1)
		      minus type(^t2)
			node(^n1)
			node(^n2)
		      node(^n3)
		  /* Boy, oh boy, is this naive!!!!
		     This rule should cover all the special cases
		     given in the separate plus and minus rules */
			{
			d=getdreg();
			$n=make_dreg_node(d,$t1);
			printf("\tmove%s\t%s,d%d\n",
					stypesize($n1 .type),$n1 .s,d);
			printf("\tsub%s\t%s,d%d\n",
					stypesize($n2 .type),$n2 .s,d);
			printf("\tadd%s\t%s,d%d\n",
					stypesize($n3 .type),$n3 .s,d);
			}
			

		/* address register indirect with index, WITHOUT offset */

		| plus type(^t)
		      node(^n1)
		      node(^n2)
		  [ pointertype($t) && aregnode($n1) && aregnode($n2) ]
		  %cost 7
			{
			$n=initnodeattr();
			$n .type=$t;
			$n .nodetype=aregind_with_index;
			$n .address=TRUE;
			sprintf($n .s,"0(a%d,a%d%s)",
				$n1 .regnr,$n2 .regnr,snodesize($n2));
			$n .offsetknown=TRUE;
			$n .offset=0;
			$n .baseregnr=$n1 .regnr;
			$n .indexregnr=$n2 .regnr;
			$n .indexregtype='a';
			}

		| plus type(^t)
		      node(^n1)
		      node(^n2)
		  [ pointertype($t) && aregnode($n1) && !$n2 .address ]
		  %cost 7
			{
			a=$n1 .regnr;
			if (dregnode($n2)) d=$n2 .regnr;
			else	{
				d=getdreg();
				printf("\tmove%s\t%s,d%d\n",
					snodesize($n2),$n2 .s,d);
				}
			$n=initnodeattr();
			$n .nodetype=aregind_with_index;
			$n .type=$t;
			$n .address=TRUE;
			sprintf($n .s,"0(a%d,d%d%s)",a,d,snodesize($n2));
			$n .offsetknown=TRUE;
			$n .offset=0;
			$n .baseregnr=a;
			$n .indexregnr=d;
			$n .indexregtype='d';
			}

		| plus type(^t)
		      node(^n1)
		      node(^n2)
		  [ pointertype($t) && aregnode($n2) && !$n1 .address ]
		  %cost 7
			{
			a=$n2 .regnr;
			if (dregnode($n1)) d=$n1 .regnr;
			else	{
				d=getdreg();
				printf("\tmove%s\t%s,d%d\n",
					snodesize($n1),$n1 .s,d);
				}
			$n=initnodeattr();
			$n .nodetype=aregind_with_index;
			$n .type=$t;
			$n .address=TRUE;
			sprintf($n .s,"0(a%d,d%d%s)",a,d,snodesize($n1));
			$n .offsetknown=TRUE;
			$n .offset=0;
			$n .baseregnr=a;
			$n .indexregnr=d;
			$n .indexregtype='d';
			}

		| plus type(^t)
		      node(^n1)
		      node(^n2)
		  [ pointertype($t) && dregnode($n1) ]
		  %cost 7
			{
			d=$n1 .regnr;
			a=getareg();
			if ($n2 .address)
				printf("\tlea\t%s,a%d\n",$n2 .s,a);
			else 	printf("\tmovea%s\t%s,a%d\n",
					snodesize($n2),$n2 .s,a);
			$n=initnodeattr();
			$n .nodetype=aregind_with_index;
			$n .type=$t;
			$n .address=TRUE;
			sprintf($n .s,"0(a%d,d%d%s)",a,d,snodesize($n1));
			$n .offsetknown=TRUE;
			$n .offset=0;
			$n .baseregnr=a;
			$n .indexregnr=d;
			$n .indexregtype='d';
			}

		| plus type(^t)
		      node(^n1)
		      node(^n2)
		  [ pointertype($t) && dregnode($n2) ]
		  %cost 7
			{
			d=$n2 .regnr;
			a=getareg();
			if ($n1 .address)
				printf("\tlea\t%s,a%d\n",$n1 .s,a);
			else 	printf("\tmovea%s\t%s,a%d\n",
					snodesize($n1),$n1 .s,a);
			$n=initnodeattr();
			$n .nodetype=aregind_with_index;
			$n .type=$t;
			$n .address=TRUE;
			sprintf($n .s,"0(a%d,d%d%s)",a,d,snodesize($n2));
			$n .offsetknown=TRUE;
			$n .offset=0;
			$n .baseregnr=a;
			$n .indexregnr=d;
			$n .indexregtype='d';			
			}
	
		| plus type(^t)
		      node(^n1)
		      node(^n2)
		  [ pointertype($t) ]
		 /* General case, nothing already in a register */
			{
			a1=getareg();
			a2=getareg();
			if ($n1 .address)
				printf("\tlea\t%s,a%d\n",$n1 .s,a1);
			else 	printf("\tmovea%s\t%s,a%d\n",
					snodesize($n1),$n1 .s,a1);
			if ($n2 .address)
				printf("\tlea\t%s,a%d\n",$n2 .s,a2);
			else 	printf("\tmovea%s\t%s,a%d\n",
					snodesize($n2),$n2 .s,a2);
			$n=initnodeattr();
			$n .nodetype=aregind_with_index;
			$n .type=$t;
			$n .address=TRUE;
			sprintf($n .s,"0(a%d,a%d%s)",a1,a2,snodesize($n1));
			$n .offsetknown=TRUE;
			$n .offset=0;
			$n .baseregnr=a1;
			$n .indexregnr=a2;
			$n .indexregtype='a';
			}
		;

/* Try dbra instruction , in 1992

node(^n)	: cbranch type(^t1)
			not zero type(^t2)
				ge type(^t3)
		
*/			

		/* Peephole optimizations */

		| icjlabn anynumber icdlabn anynumber
		  [ $2==$4 ]
			{
			/* eliminate jump to itself */
			printf(".L%d\n",$4);
			}
		| icjlabn anynumber icdlabn anynumber
			/* bridge */
			{
			printf("\tjra\t.L%d\n",$2);
			printf(".L%d\n",$4);
			}

		| icjfend icdlabn anynumber
		  [ fendlabel==$3 ]
			{
			/* eliminate jump */
			printf(".L%d\n",$3);
			}
		| icjfend icdlabn anynumber
			/* bridge */
			{
			printf("\tjra\t.L%d\n",fendlabel);
			printf(".L%d\n",$3);
			}

		| icjlabs STR icdlabs STR
		  [ !strcmp($2,$4) ]
			/* eliminate jump */
			{
			printf("%s\n",$4);
			}
		| icjlabs STR icdlabs STR
		  	/* bridge */
			{
			printf("\tjra\t%s\n",$2);
			printf("%s\n",$4);
			}
		;		


/*******************/
/* IC code section */
/*******************/

anynumber	: NUMBER | CONDNUMBER ; /* default transfer */

iccode		: iceven anynumber { printf("\t.even\n"); }
		| ictext	{ printf("\t.text\n"); }
		| icdata	{ printf("\n\t.data\n"); }
		| icbss		{ printf("\t.bss\n"); }
		| iclong anynumber { printf("\t.long\t%d\n",$2); }
		| icword anynumber { printf("\t.word\t%d\n",$2); }
		| icbyte anynumber { printf("\t.byte\t%d\n",$2); }
		| icbytes anynumber 
			{
			bytelistsize=$2;
			printf("\t.ascii\t\"");
			}
		  bytelist
		| icdlabn anynumber 
			{
			printf(".L%d\n",$2); 
			}
		| icdlabs STR	{ printf("%s\n",$2); }
		| icjlabn anynumber
				{ printf("\tjra\t.L%d\n",$2); }
		| icjlabs STR	{ printf("\tjra\t%s\n",$2); }
		| icfbeg funcnr(^fnr) anynumber anynumber STR
				{ printf("%s\n",$5);
				  funclinklabel=newlabel++;
				  printf("\tjra\t.L%d\n",funclinklabel);
				  funcstartlabel=newlabel++;
				  printf(".L%d\n",funcstartlabel); 
				  fendlabel=$3;
				  profile=$4;
				  strcpy(fname,$5);
				  clear_reg_usage();
				}
		| icfend 	{ 
				char reglist[80]; /* holds registerlist */
				int numberofdaregs;
				 /* number of data & address regs to save */
				int offset;
				
				
				/* restore data and address registers */
				
				numberofdaregs =
					areg_usage()+
					dreg_usage(); 
						    /* # of other registers
							used, except d0,d1 */
													
				offset=	framesize +
					fpreg_usage()*12 +
					numberofdaregs*4;

				if (numberofdaregs > 0)
				    	{
					int n;		/* temp counter */
					char s[4]; 	/* temp */
					n=numberofdaregs;
					sprintf(reglist,"");
					for (d=0;d<=7;d++) if (savedreg[d]) 
						{
						sprintf(s,"d%d",d);
						strcat(reglist,s);
						if (--n) strcat(reglist,"/");
						}
					for (a=0;a<=5;a++) if (saveareg[a]) 
						{
						sprintf(s,"a%d",a);
						strcat(reglist,s);
						if (--n) strcat(reglist,"/");
						}
					if (numberofdaregs==1)
					  if (areg_usage()) /* is it 1 areg? */
					    printf("\tmovea.l\t-%d(a6),%s\n",
						   	offset,reglist);
					    else /* it's a dreg */
					    printf("\tmove.l\t-%d(a6),%s\n",
							offset,reglist);
					else /* more than 1 register */
				  	printf("\tmovem.l\t-%d(a6),%s\n",
							offset,reglist);
					}
					
				  /* Now, restore fp regs */	
				  
				  if (fpreg_usage()>0)
				    {
				    if (fpreg_usage()==1)
				      printf("\tfmove.x\t");
				    else
				      printf("\tfmovem.x\t");
				    printf("-%d(a6),",offset-numberofdaregs*4);
				    genfpreglist();
				    printf("\n");
				    }
				  	  				  
				  /* Unlink */			
				  
				  printf("\tunlk\ta6\n");
				  printf("\trts\n");
				  
				  /* Link */
				  
				  printf(".L%d\n",funclinklabel);
				  if (offset<32767)
				    printf("\tlink.w\ta6,#-%d\n",offset);
				  else
				    printf("\tlink.l\ta6,#-%d\n",offset);
				    
				  /* save data and address regs */
				  
				  if (numberofdaregs > 0)
				    if (numberofdaregs == 1)
				      printf("\tmove.l\t%s,(sp)\n",reglist);
				    else
				    printf("\tmovem.l\t%s,(sp)\n",reglist);
				    
				  /* save fp regs */
				  
				  if (fpreg_usage()>0)
				    {
				    if (fpreg_usage()==1)
				      printf("\tfmove.x\t");
				    else
				      printf("\tfmovem.x\t");
				    genfpreglist();
				    printf(",");
				    if (numberofdaregs>0)
				      printf("%d",numberofdaregs*4);
				    printf("(sp)\n");
				    }
				    
				  printf("\tjra\t.L%d\n",funcstartlabel);
				 }
		| icskip anynumber { printf("\t.space\t%d\n",$2); }
		| iccomm anynumber STR 
				{ printf("\t.comm\t%s,%d\n",$3,$2); }
		| icinit 	{ printf("\t.data\n"); }
		| icswitch anynumber 
				/* $2 = number of following icswent's */
				{
				defaultlabel=FALSE;
				}
		| icswdef anynumber
				{
				/* keep the default label in mind, because
				   it precedes the ordinary case labels */
				defaultlabel=$2;
				}
		| icswent anynumber anynumber
				{
				if ($3==0) 
					printf("\ttst.l\td0\n");
				else	printf("\tcmpi.l\t#%d,d0\n",$3);
				printf("\tjeq\t.L%d\n",$2);
				}
		| icswend	
				{
				if (defaultlabel)
					printf("\tjra\t.L%d\n",defaultlabel);
				}
		| iccom STR	{ printf("* %s\n",$2); }
		| icglobl STR	{ printf("\t.globl\t%s\n",$2); }
		| icjfend 	{ printf("\tjra\t.L%d\n",fendlabel); }
		| icnequ STR anynumber
				{ printf("%s\tEQU\t%d\n",$2,$3); }
		| icsequ STR STR
				{ printf("%s\tEQU\t%s\n",$2,$3); }
		| icvers
			{ printf("* Maarten's ceegeetje voor de 68020\n"); }
		| icaddr STR	{ printf("\t.long\t%s\n",$2); }
		| icstring STR	{ printf("\t.asciz\t\"%s\"\n",$2); }
		| ic_31		{ /* ? */ }
		| iclanguage anynumber
				{ languagenumber=$2;
				  if (languagenumber>6) languagenumber=0;
				  printf("*  Source language: %s\n",
				 	languagename[languagenumber]);
				}
		| icnop		{ printf("\tnop\n"); }
		| icjsr STR	{ printf("\tjbsr\t%s\n",$2); }
		| icrts		{ printf("\trts\n"); }
		| icfile STR	{ printf("\t.file \"%s\"\n",$2); }
		| icln anynumber { printf("\t.ln\t%d\n",$2); }
		| icdef STR	{ printf("\t.def\t%s\n",$2); }
		| icendef	{ printf("\t.endef\n"); }
		| icval anynumber { printf("\t.val\t%d\n",$2); }
		| ictype anynumber { printf("\t.type\t%d\n",$2); }
		| icscl anynumber { printf("\t.scl\t%d\n",$2); }
		| ictag STR	{ printf("\t.tag\t%s\n",$2); }
		| icline anynumber { printf("\t.line\t%d\n",$2); }
		| icsize anynumber { printf("\t.size\t%d\n",$2); }
		| icdim anynumber { printf("\t.dim\t");
				       dimlistsize=$2; } dimlist
		| icvals STR	{ printf("\t.val\t%s\n",$2); }
		| ichex		{
				error("CG: I don't know what to do with ICHEX");
				}
		| icfloat STR	{ printf("\t.float\t%s\n",$2); }
		| icdouble STR	{ printf("\t.double\t%s\n",$2); }
		;


dimlist		: dimlist DIMENSION 	
			{ printf("%d",$2);
			  dimlistsize -= 1;
		 	  if (dimlistsize) printf(", ");
			  else  printf("\n");  }
		| /* nothing */
		;


bytelist	: bytelist BYTE 	
			{
			printf("%c",$2);
			bytelistsize--;
			if (!bytelistsize) printf("\"\n");
			}
		| /* nothing */
		;
						

auxiliary_code	: DOT line_number(^n) filename(^f)
				{ printf("* line %d of %s\n",$n,$f); }
		| DOT line_number(^n)
				{ printf("* line %d\n",$n); }
		| LBRACKET funcnr(^f) automatic(^auto) datareg(^d) addrreg(^a)
				{ int i;
				  autosize=$auto/8;  /* $auto is in # bits */

				  if ($auto%8) autosize++;
				  /* align autosize to 4 byte boundary */
				  if (autosize%4) 
					autosize += (4-(autosize % 4)); 
				  dreghi=$d;
				  areghi=$a-8;
				  for (i=dreghi+1; i<=7; i++) 
					{
					dreginfo[i]=regvar;
					savedreg[i]=TRUE;
					}
				  for (i=areghi+1; i<=5; i++) 
					{
					areginfo[i]=regvar;
					saveareg[i]=TRUE;
					}
				  free_all_registers();
				  framesize=autosize+4*((7-dreghi)+(5-areghi));

				  /* No fp register vars yet: */
	
				  fpreghi=7;
				}
		| RBRACKET
		| RPAREN assemblerline(^s)
				{ 
				if (!strcmp($s,"debugcgyaccon"))
					yydebug=TRUE; 
				else if (!strcmp($s,"debugcgyaccoff"))
					yydebug=FALSE; 
				else if (!strcmp($s,"debuglexon"))
					debuglex=TRUE;
				else if (!strcmp($s,"debuglexoff"))
					debuglex=FALSE;
				else if (!strcmp($s,"debugon"))
					{
					debuglex=TRUE;
					yydebug=TRUE;
					}
				else if (!strcmp($s,"debugoff"))
					{
					debuglex=FALSE;
					yydebug=FALSE;
					}
				else printf("%s\n",$s); 
				}
		;




/* The following productions translate the ic code into human readable
 * nonterminals.
 */


/* clarifying productions for auxiliary codes */

line_number(^n)	:	anynumber { $n=$1; } ;
filename(^f)	:	STR	{ strcpy($f,$1); } ;
funcnr(^fnr)	:	anynumber { $fnr=$1; } ;
automatic(^auto):	anynumber { $auto=$1; } ;
datareg(^d)	:	anynumber { $d=$1; } ;
addrreg(^a)	:	anynumber { $a=$1; } ;
assemblerline(^s) :	STR	{ strcpy($s,$1); } ;


/* select node names */

/* 1? */
name		:	NUMBER	[ $1==2  ] ;
/* 3? */
icon		:	NUMBER	[ $1==4  ] ;
fcon		:	NUMBER	[ $1==5  ] ;
plus		:	NUMBER	[ $1==6  ] ;
asg_plus	:	NUMBER	[ $1==7  ] ;
minus		:	NUMBER	[ $1==8  ] ;
asg_minus	:	NUMBER	[ $1==9  ] ;
unary_min	:	NUMBER	[ $1==10 ] ;
mul		:	NUMBER	[ $1==11 ] ;
asg_mul		:	NUMBER	[ $1==12 ] ;
unary_mul	:	NUMBER	[ $1==13 ] ;
and		:	NUMBER	[ $1==14 ] ;
asg_and		:	NUMBER	[ $1==15 ] ;
/* 16? */
or		:	NUMBER	[ $1==17 ] ;
asg_or		:	NUMBER	[ $1==18 ] ;
er		:	NUMBER	[ $1==19 ] ;
asg_er		:	NUMBER	[ $1==20 ] ;
quest		:	NUMBER	[ $1==21 ] ;
colon		:	NUMBER	[ $1==22 ] ;
andand		:	CONDNUMBER	[ $1==23 ] ;
oror		:	CONDNUMBER	[ $1==24 ] ;
/* 25-36? */
goto		:	NUMBER	[ $1==37 ] ;
/* 38-55? */
cm		:	NUMBER	[ $1==56 ] ;
/* 57? */
assign		:	NUMBER	[ $1==58 ] ;
comop		:	NUMBER	[ $1==59 ] ;
div		:	NUMBER	[ $1==60 ] ;
asg_div		:	NUMBER 	[ $1==61 ] ;
mod		:	NUMBER	[ $1==62 ] ;
asg_mod		:	NUMBER	[ $1==63 ] ;
ls		:	NUMBER	[ $1==64 ] ;
asg_ls		:	NUMBER	[ $1==65 ] ;
rs		:	NUMBER	[ $1==66 ] ;
asg_rs		:	NUMBER	[ $1==67 ] ;
/* 68-69? */
call		:	NUMBER	[ $1==70 ] ;
/* 71? */
unary_call	:	NUMBER	[ $1==72 ] ;
/* 73-75? */
not		:	CONDNUMBER	[ $1==76 ] ;
compl		:	NUMBER	[ $1==77 ] ;
incr		:	NUMBER	[ $1==78 ] ;
decr		:	NUMBER	[ $1==79 ] ;
eq		:	CONDNUMBER	[ $1==80 ] ;
ne		:	CONDNUMBER	[ $1==81 ] ;
le		:	CONDNUMBER	[ $1==82 ] ;
lt		:	CONDNUMBER	[ $1==83 ] ;
ge		:	CONDNUMBER	[ $1==84 ] ;
gt		:	CONDNUMBER	[ $1==85 ] ;
ule		:	CONDNUMBER	[ $1==86 ] ;
ult		:	CONDNUMBER	[ $1==87 ] ;
uge		:	CONDNUMBER	[ $1==88 ] ;
ugt		:	CONDNUMBER	[ $1==89 ] ;
/* 90-93? */
reg		:	NUMBER	[ $1==94 ] ;
oreg		:	NUMBER	[ $1==95 ] ;
/* 96? */
stasg		:	NUMBER	[ $1==98 ] ;
starg		:	NUMBER	[ $1==99 ] ;
stcall		:	NUMBER	[ $1==100 ] ;
/* 101? */
unary_stcall	:	NUMBER	[ $1==102 ] ;
fld		:	NUMBER	[ $1==103 ] ;
sconv		:	NUMBER	[ $1==104 ] ;
/* 105-107? */
force		:	NUMBER	[ $1==108 ] ;
cbranch		:	NUMBER	[ $1==109 ] ;
init		:	NUMBER	[ $1==110 ] ;


/* New IC statements as defined by Maarten Landzaat and Jaap van Ganswijk */

rev_call	: 	NUMBER	[ $1==120 ] ;
rev_stcall	:	NUMBER  [ $1==121 ] ;
rev_cm		:	NUMBER	[ $1==122 ] ;
rev_minus	:	NUMBER	[ $1==123 ] ;
rev_div		:	NUMBER	[ $1==124 ] ;
rev_mod		:	NUMBER	[ $1==125 ] ;
rev_ls		:	NUMBER	[ $1==126 ] ;
rev_rs		:	NUMBER	[ $1==127 ] ;
/* 128 not used */
rev_cbranch	:	NUMBER	[ $1==129 ] ;

/* End of new IC statements */


/* arguments to nodes */
zero		:	NUMBER 	[ $1==0 ] ; 
constant(^c)	:	anynumber { $c=$1; } ; 
offset(^o)	:	anynumber { $o=$1; } ;
type(^t)	:	anynumber { /* interpret as octal */
				sprintf(s,"%d",$1);
				sscanf(s,"%o",&$t);
				} ;
discardtype	:	anynumber ; /*  reads same type as type(^t) rule,
					but does nothing with its value.
					Used when inherited attributes
					are used. */
regnr(^r)	:	anynumber { $r=$1; } ;
label(^l)	:	STR     { strcpy($l,$1); } ;
string(^s)	:	STR 	{ strcpy($s,$1); } ;
size(^s)	:	anynumber { $s=$1; } ;
alignment(^a)	:	anynumber { $a=$1; } ;
code(^c)	:	anynumber { $c=$1; } ;



/* select ic codes */
iceven		:	ICCODE [ $1==1  ] ;
ictext		:	ICCODE [ $1==2  ] ;
icdata		:	ICCODE [ $1==3  ] ;
icbss		:	ICCODE [ $1==4  ] ;
iclong		:	ICCODE [ $1==5  ] ;
icword		:	ICCODE [ $1==6  ] ;
icbyte		:	ICCODE [ $1==7  ] ;
icbytes		:	ICCODE [ $1==8  ] ;
icdlabn		:	ICCODE [ $1==9  ] ;
icdlabs		:	ICCODE [ $1==10 ] ;
icjlabn		:	ICCODE [ $1==11 ] ;
icjlabs		:	ICCODE [ $1==12 ] ;
icfbeg		:	ICCODE [ $1==13 ] ;
icfend		:	ICCODE [ $1==14 ] ;
/* 15? */
icskip		:	ICCODE [ $1==16 ] ;
iccomm		:	ICCODE [ $1==17 ] ;
icinit		:	ICCODE [ $1==18 ] ;
icswitch	:	ICCODE [ $1==19 ] ;
icswdef		:	ICCODE [ $1==20 ] ;
icswent		:	ICCODE [ $1==21 ] ;
icswend		:	ICCODE [ $1==22 ] ;
iccom		:	ICCODE [ $1==23 ] ;
icglobl		:	ICCODE [ $1==24 ] ;
icjfend		:	ICCODE [ $1==25 ] ;
icnequ		:	ICCODE [ $1==26 ] ;
icsequ		:	ICCODE [ $1==27 ] ;
icvers		: 	ICCODE [ $1==28 ] ;
icaddr		:	ICCODE [ $1==29 ] ;
icstring	:	ICCODE [ $1==30 ] ;
ic_31		:	ICCODE [ $1==31 ] ; /* effect unknown */
/* 32? */
iclanguage	:	ICCODE [ $1==33 ] ;
icnop		:	ICCODE [ $1==34 ] ;
icjsr		:	ICCODE [ $1==35 ] ;
icrts		:	ICCODE [ $1==36 ] ;
icfile		:	ICCODE [ $1==37 ] ;
icln		:	ICCODE [ $1==38 ] ;
icdef		:	ICCODE [ $1==39 ] ;
icendef		:	ICCODE [ $1==40 ] ;
icval		:	ICCODE [ $1==41 ] ;
ictype		:	ICCODE [ $1==42 ] ;
icscl		:	ICCODE [ $1==43 ] ;
ictag		:	ICCODE [ $1==44 ] ;
icline		:	ICCODE [ $1==45 ] ;
icsize		:	ICCODE [ $1==46 ] ;
icdim		:	ICCODE [ $1==47 ] ;
icvals		:	ICCODE [ $1==48 ] ;
ichex		:	ICCODE [ $1==49 ] ;
icfloat		:	ICCODE [ $1==50 ] ;
icdouble	:	ICCODE [ $1==51 ] ;


%%
# include "lex.yy.c"
