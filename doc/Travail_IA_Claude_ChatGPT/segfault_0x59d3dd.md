#COMMANDE AU COMPILATEUR T2 BOOTSTRAPPE
 <pre>
 ./A83.sh ./ ./_standrd.adb M
 </pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR
<pre> 
_standrd.adb
</pre>

#REMARQUES

Segfault dans la procedure du frontend  IDL.SEM_PHASE.NOD_WALK.WALK :
<pre>
  procedure			WALK		( NODE :TREE; H :H_TYPE )
</pre>
Indication claire trou d'implémentation dans le NOD_WALK.FINC :
; CODE_SELECTED.RECURSE_SELECTED DESIGNATOR.TY PAS FAIT: DN_IN_ID

Défaut dans procedure PROCESS_DESIGNATOR fichier expander.expressions.adb ligne 1716


#INSTRUCTION SEGFAULT 0x59d3dd
sur un blkmov.
 <pre>
 0x59d3bd:    insl   (%dx),%es:(%rdi)
   0x59d3be:    or     %cl,-0x75(%rax)
   0x59d3c1:    jne    0x59d3c3
   0x59d3c3:    lea    -0x8(%rbp),%rbp
   0x59d3c7:    mov    0x0(%rbp),%rcx
   0x59d3cb:    lea    -0x8(%rbp),%rbp
   0x59d3cf:    mov    0x0(%rbp),%rdi
   0x59d3d3:    lea    -0x8(%rbp),%rbp
   0x59d3d7:    test   %rcx,%rcx
   0x59d3da:    je     0x59d3e1
   0x59d3dc:    cld
=> 0x59d3dd:    lods   %ds:(%rsi),%al
   0x59d3de:    stos   %al,%es:(%rdi)
   0x59d3df:    loop   0x59d3dd
   0x59d3e1:    mov    0x18(%r15),%rax
   0x59d3e5:    lea    0xc8(%rax),%rax

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x24                36                            rbx            0x7fffffc07458      140737484190808               │
│rcx            0x7fffffc074a8      140737484190888               rdx            0x0                 0                             │
│rsi            0x24                36                            rdi            0x7fffffc07830      140737484191792               │
│rbp            0x7fffffc07818      0x7fffffc07818                rsp            0x7fffffbfdac8      0x7fffffbfdac8                │
│r8             0xffffffffffffffff  -1                            r9             0x0                 0                             │
│r10            0x22                34                            r11            0x246               582                           │
│r12            0x7ffff7ded400      140737351963648               r13            0xef16f0            15668976                      │
│r14            0xef1718            15669016                      r15            0x7fffffbfdaf0      140737484151536               │
│rip            0x59d3dd            0x59d3dd                      eflags         0x10202             [ IF RF ]                     │
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc077d8: 0x0000000000000004      0x0000000000000008
0x7fffffc077e8: 0x0000000001007098      0x00007fffffc07800
0x7fffffc077f8: 0x00007fffffc04c68      0x00007fff0100000f
0x7fffffc07808: 0x00007fffffc07818      0x00007fffffc0e798
0x7fffffc07818: 0x00007fff5d011828      0x00007fffffc07830
0x7fffffc07828: 0x00007fffffc074a8      0x0000000000000024
0x7fffffc07838: 0x0000000000000000      0x0000000000000000
0x7fffffc07848: 0x0000000000000002      0x00007fffffc066e0
</pre>

#BACKTRACE ET MAP
<pre>
#0  0x000000000059d3dd in ?? ()
WALK_L184 0x000000000058B41F
....
var elab H 0x000000000059D351
 disp 0x0000000000000080
 **zone segfault**
var elab S 0x000000000059D3E1
 disp 0x00000000000000B8
...
WALK_SOURCE_NAME_S_L194 0x00000000005A0D41

#1  0x0000000000658c03 in ?? ()
#2  0x0000000000659272 in ?? ()
#3  0x000000000066f15c in ?? ()
#4  0x0000000000d98be8 in ?? ()
#5  0x0000000000d99be5 in ?? (
</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT
Dans idl.sem_phase.nod_walk.adb lignes 1151 à 1160
probablement affectation ligne 1157 :
	H	 : H_TYPE := WALK.H;

<pre>
      when DN_PACKAGE_BODY =>
        declare
	SOURCE_NAME : TREE := D (AS_SOURCE_NAME, NODE);
	BODY_NODE	  : TREE := D (AS_BODY, NODE);

	FIRST_NAME : TREE;
	H	 : H_TYPE := WALK.H;
	S	 : S_TYPE;
	SOURCE_DEF : TREE;
        begin

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS IDL-SEM_PHASE-NOD_WALK.FINC
<pre>
 hexa_show 'var elab H ', $
VAR H_disp, q				; variable record : pointeur aux data record
VAR H__u, q				; variable record : pointeur aux useinfo
VAR H__dat, STANDARD.IDL.SEM_PHASE_L11.SEM_GLOB._H_TYPE.size
	LVA	3, H__dat
	Sa	3, H_disp				; record fin
	LVA	3, STANDARD.IDL.SEM_PHASE_L11.SEM_GLOB._H_TYPE.SIZ
	Sa	3, H__u
	La  3, H_disp
	LI	STANDARD.IDL.SEM_PHASE_L11.SEM_GLOB._H_TYPE.size
; CODE_SELECTED.RECURSE_SELECTED DESIGNATOR.TY PAS FAIT: DN_IN_ID
	BLKMOV

 hexa_show ' disp ', H_disp

 </pre>
