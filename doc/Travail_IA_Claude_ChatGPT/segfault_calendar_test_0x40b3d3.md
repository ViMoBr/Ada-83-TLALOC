#COMMANDE AU COMPILATEUR
 <pre>
 </pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR
<pre> 

</pre>

#REMARQUES
récursion infinie terminée sur pile épuisée dans un opérateur de comparaison.
La compilation d'une fonction de comparaison pour TIME dérivé de DURATION se rappelle elle même.

#INSTRUCTION SEGFAULT 0x40b3d3
 <pre>
(gdb) x/16i $rip-32
   0x40b3b3:    lea    0x8(%rbp),%rbp
   0x40b3b7:    mov    %rbp,0x8(%r15)
   0x40b3bb:    lea    0x8(%rbp),%rbp
   0x40b3bf:    mov    %r13,(%r14)
   0x40b3c2:    mov    %r14,%r13
   0x40b3c5:    lea    0x8(%r14),%r14
   0x40b3c9:    movabs $0x0,%rax
=> 0x40b3d3:    mov    %rax,0x8(%rbp)
   0x40b3d7:    lea    0x8(%rbp),%rbp
   0x40b3db:    mov    0x8(%r15),%rax
   0x40b3df:    mov    -0x10(%rax),%rax
   0x40b3e3:    mov    %rax,0x8(%rbp)
   0x40b3e7:    lea    0x8(%rbp),%rbp
   0x40b3eb:    mov    0x8(%r15),%rax
   0x40b3ef:    mov    -0x8(%rax),%rax
   0x40b3f3:    mov    %rax,0x8(%rbp)

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x0                 0                             rbx            0x0                 0                             │
│rcx            0x403850            4208720                       rdx            0x1                 1                             │
│rsi            0x7fffffbfe8b8      140737484155064               rdi            0x1                 1                             │
│rbp            0x7ffffffff000      0x7ffffffff000                rsp            0x7fffffb30c80      0x7fffffb30c80                │
│r8             0xffffffffffffffff  -1                            r9             0x0                 0                             │
│r10            0x22                34                            r11            0x202               514                           │
│r12            0x7ffff7e00000      140737352040448               r13            0x4ddb48            5102408                       │
│r14            0x4ddb50            5102416                       r15            0x7fffffbfdae0      140737484151520               │
│rip            0x40b3d3            0x40b3d3                      eflags         0x10246             [ PF ZF IF RF ]               │
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffffefc0: 0x178cdb7ff8000000      0x178cdb8000000000
0x7fffffffefd0: 0x00007fffffffefa8      0x6e69622f434f4c41
0x7fffffffefe0: 0x0000000000000000      0x178cdb7ff8000000
0x7fffffffeff0: 0x178cdb8000000000      0x00007fffffffefd0
0x7ffffffff000: Cannot access memory at address 0x7ffffffff000

</pre>

#BACKTRACE ET MAP
<pre>
#0  0x000000000040b3d3 in ?? ()
_GT__L14 0x000000000040B3AB
**zone segfault**
_GE__L15 0x000000000040B433

#1  0x000000000040b400 in ?? ()
_GT__L14 0x000000000040B3AB
**zone appel**
_GE__L15 0x000000000040B433

#2  0x000000000040b400 in ?? ()
#3  0x000000000040b400 in ?? ()
#4  0x000000000040b400 in ?? ()
#5  0x000000000040b400 in ?? ()
#6  0x000000000040b400 in ?? ()
#7  0x000000000040b400 in ?? ()
#8  0x000000000040b400 in ?? ()
**récursion infinie**
</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT
<pre>
  function		">"		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			---
  begin
    return  LEFT > RIGHT;

  end	">";

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS CALENDAR.FINC
<pre>
if defined _GT__L14_
PRO	_GT__L14				;---------- PRO _GT_
 hexa_show '_GT__L14 ', $
PRMS					;    debut parametrage
	PRM LEFT_ofs				; in
	PRM RIGHT_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 1					;    BODY ELAB
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
; CODE_RETURN : EXPR TYPE = DN_ENUMERATION  VUE COMPLETE = DN_ENUMERATION
	LI	0					; lieu resultat sur pile
	La  1,	-RIGHT_ofs
	La  1,	-LEFT_ofs
	CALL	STANDARD.CALENDAR. ,_GT__L14
	Sq  1,	-result__ofs
	BRA ret_lbl
ret_lbl:
	UNLINK 1
	RTD	prm_siz-8
excep:
endPRO					;---------- end PRO _GT_
end if

 </pre>
