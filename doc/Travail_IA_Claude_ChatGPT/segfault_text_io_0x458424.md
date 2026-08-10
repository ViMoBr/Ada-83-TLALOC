#COMMANDE AU COMPILATEUR
 <pre>
 ./T2 ./ ../text_io.adb W
 
 </pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR
<pre> 
text_io.adb
</pre>

#REMARQUES
Semble une erreur dans le PRO de DABS_L38 appelé par 

#INSTRUCTION SEGFAULT 0x458424
 <pre>
(gdb) x/16i $rip-32
   0x458404:    insl   (%dx),%es:(%rdi)
   0x458405:    add    %cl,-0x73(%rax)
   0x458408:    insl   (%dx),%es:(%rdi)
   0x458409:    call   0x8f76dd1
   0x45840e:    add    %al,(%rax)
   0x458410:    mov    0x8(%r15),%rax
   0x458414:    mov    %rax,0x8(%rbp)
   0x458418:    lea    0x8(%rbp),%rbp
   0x45841c:    mov    %rbp,0x8(%r15)
   0x458420:    lea    0x10(%rbp),%rbp
=> 0x458424:    mov    %r13,(%r14)
   0x458427:    mov    %r14,%r13
   0x45842a:    lea    0x8(%r14),%r14
   0x45842e:    mov    0x8(%r15),%rax
   0x458432:    mov    -0x10(%rax),%rax
   0x458436:    mov    %rax,0x8(%rbp)
</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x7fffffc0a2b8      140737484202680   rbx            0x7f                127               │
│rcx            0x8                 8                 rdx            0xff                255               │
│rsi            0x7fffffc0a26c      140737484202604   rdi            0x7fffffc0a0dc      140737484202204   │
│rbp            0x7fffffc0a360      0x7fffffc0a360    rsp            0x7fffffbfd9f8      0x7fffffbfd9f8    │
│r8             0xffffffffffffffff  -1                r9             0x0                 0                 │
│r10            0x22                34                r11            0x246               582               │
│r12            0x7ffff7ded400      140737351963648   r13            0x8dcfff8           148701176         │
│r14            0x8dd0000           148701184         r15            0x7fffffbfdaf0      140737484151536   │
│rip            0x458424            0x458424          eflags         0x10246             [ PF ZF IF RF ]   │
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc0a320: 0x00007fffffc0a2e0      0x00007fffffc0a2e0
0x7fffffc0a330: 0x0000000000000004      0x00007fffffc0a2f0
0x7fffffc0a340: 0x00007fffffc0a308      0x0000000000000002
0x7fffffc0a350: 0x00007fffffc0a2b8      0x000000000000007f
0x7fffffc0a360: 0x0000000000000028      0x0000000000000004
0x7fffffc0a370: 0x0000000000000008      0x00007ffff7def97c
0x7fffffc0a380: 0x000000000000017c      0x0000000000000004
0x7fffffc0a390: 0x0000000000000008      0x00000000004623fd
</pre>

#BACKTRACE ET MAP
<pre>
#0  0x0000000000458424 in ?? ()
DABS_L38 0x0000000000458410
**zone segfault**
var elab RN 0x000000000045842E
 disp 0x0000000000000008

#1  0x0000000000451865 in ?? ()
var elab QUEUE 0x0000000000451698
 disp 0x0000000000000008
**zone appel**
INSERT_L33 0x0000000000451D03

#2  0x0000000000473dc1 in ?? ()
POP_L24 0x0000000000473C36
**zone appel**
PRINT_NAME_L25 0x0000000000473E14

#3  0x00000000005041de in ?? ()
var elab ID_2 0x0000000000503FBC
 disp 0x0000000000000110
**zone appel**
CONFORM_PARAMETER_LISTS_L65 0x0000000000504862

#4  0x00000000004ff003 in ?? ()
var elab KIND_1 0x00000000004FEA18
 disp 0x0000000000000008
**zone appel**
MAKE_DEF_FOR_ID_L52 0x00000000004FF036

#5  0x00000000005036fe in ?? ()
var elab KIND_2 0x00000000005033A3
 disp 0x0000000000000009
**zone appel**
IS_SAME_PARAMETER_PROFILE_L64 0x00000000005037FD

#6  0x000000000055800a in ?? ()
var elab HEADER_KIND 0x000000000055566B
 disp 0x0000000000000034
**zone appel**
FIND_SELECTED_VISIBILITY_L171 0x000000000055C6CB

#7  0x000000000055342f in ?? ()
FIND_VISIBILITY_L169 0x00000000005532A1
**zone appel**
FIND_DIRECT_VISIBILITY_L170 0x00000000005534C5

#8  0x000000000062480b in ?? ()
var elab IS_SLICE 0x000000000062447B
 disp 0x0000000000000124
**zone appel**
var elab RESULT_TYPE 0x0000000000624C0E
 disp 0x0000000000000008

#9  0x00000000005eb044 in ?? ()
#10 0x00000000005e8834 in ?? ()
#11 0x00000000005d5065 in ?? ()
#12 0x00000000005c7070 in ?? ()
#13 0x00000000005d52ee in ?? ()
#14 0x00000000005c7070 in ?? ()
#15 0x00000000005d359e in ?? ()
#16 0x00000000005c7070 in ?? ()
#17 0x00000000005d4609 in ?? ()
#18 0x00000000005c7070 in ?? ()
#19 0x0000000000586922 in ?? ()
#20 0x000000000059d0de in ?? ()
#21 0x00000000005a4d6a in ?? ()
#22 0x000000000058641a in ?? ()
#23 0x000000000059f967 in ?? ()
#24 0x00000000005a4d6a in ?? ()
#25 0x000000000058641a in ?? ()
#26 0x000000000059f967 in ?? ()
#27 0x0000000000658f87 in ?? ()
#28 0x00000000006595f6 in ?? ()
#29 0x000000000066e70b in ?? ()
#30 0x0000000000d9c698 in ?? ()
#31 0x0000000000d9d695 in ?? ()
</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT idl.idlman.adb
<pre>
function			  DABS		( RANG :ATTR_NBR; T :TREE	)	return TREE
is			--------

  RN		: RPG_IDX;

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS IDL-IDL_MAN.FINC
<pre>
if defined DABS_L38_
PRO	DABS_L38				;---------- PRO DABS
 hexa_show 'DABS_L38 ', $
PRMS					;    debut parametrage
	PRM RANG_ofs				; in
	PRM T_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 1					;    BODY ELAB
 hexa_show 'var elab RN ', $
VAR RN_disp, d				; variable entiere

 </pre>

#SECTION LLIR APPELANTE DANS IDL-IDL_MAN.FINC
<pre>
if defined TAIL_L32_
PRO	TAIL_L32				;---------- PRO TAIL
 hexa_show 'TAIL_L32 ', $
PRMS					;    debut parametrage
	PRM S_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 1					;    BODY ELAB
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
					; debut if
	La 1, -S_ofs
	LIVA 	, 0, STANDARD.IDL._SEQ_TYPE.FIRST
	Ld
	LI	24
	LI	8
	UBFX
	LI	6
	CEQ
	BF	L43
namespace	BLOCK__1
ELB 2					;    BODY ELAB
 hexa_show 'var elab QUEUE ', $
VAR QUEUE_disp, q				; variable record : pointeur aux data record
VAR QUEUE__u, q				; variable record : pointeur aux useinfo
VAR QUEUE__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA	2, QUEUE__dat
	Sa	2, QUEUE_disp				; record fin
	LVA	2, STANDARD.IDL._SEQ_TYPE.SIZ
	Sa	2, QUEUE__u
	La 2, QUEUE_disp
					; Assign_record_aggregate type DN_RECORD
	DUP
	LVA	, STANDARD.IDL._SEQ_TYPE.FIRST
	LI	STANDARD.IDL._TREE.size
VAR	ANON_136_38_disp, q
VAR	ANON_136_38__u,    q
VAR	ANON_136_38__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_136_38__dat
	Sa  2, ANON_136_38_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_136_38__u
	LVA 2, ANON_136_38_disp
					; doublet resultat record anonyme
	VAR SELARG_L44_disp, q
	VAR SELARG_L44__u, q
	La 1, -S_ofs
	LIVA 	, 0, STANDARD.IDL._SEQ_TYPE.FIRST
	Sa	2, SELARG_L44_disp
	La 0, STANDARD.IDL._TREE.use__info
	Sa	2, SELARG_L44__u
	LVA 2, SELARG_L44_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	2
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.LST
	CGT
	BT	STANDARD.ce_raise_
	CALL	STANDARD.IDL.IDL_MAN. ,DABS_L38 ;**** APPEL
	La
	BLKMOV
	DUP
	LVA	, STANDARD.IDL._SEQ_TYPE.NEXT
	LI	STANDARD.IDL._TREE.size
	LVA 0,	STANDARD.IDL.TREE_NIL_disp
	La
	BLKMOV
	DROP

 hexa_show ' disp ', QUEUE_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
					; debut if
	LIVA 	2, STANDARD.IDL.IDL_MAN.TAIL_L32.BLOCK__1.QUEUE_disp, STANDARD.IDL._SEQ_TYPE.FIRST
	Ld
	LI	24
	LI	8
	UBFX
	LI	6
	CEQ
	BF	L48
	LIVA 	2, STANDARD.IDL.IDL_MAN.TAIL_L32.BLOCK__1.QUEUE_disp, STANDARD.IDL._SEQ_TYPE.NEXT
	LI	STANDARD.IDL._TREE.size
	La 1, -S_ofs
	LIVA 	, 0, STANDARD.IDL._SEQ_TYPE.NEXT
	BLKMOV
	BRA	L47
L48:
L47:					; post if
; CODE_RETURN : EXPR TYPE = DN_RECORD  VUE COMPLETE = DN_RECORD
	La   1,	-result__ofs
	La  ,  0
	LI	STANDARD.IDL._SEQ_TYPE.size
	LVA 2,	QUEUE_disp
	La
	BLKMOV
	UNLINK 2
	BRA ret_lbl
	UNLINK 2
endPRO
	BRA	L42
L43:
; CODE record equality "/=" _TREE
	La 1, -S_ofs
	LIVA 	, 0, STANDARD.IDL._SEQ_TYPE.FIRST
	Ld
	LVA 0,	STANDARD.IDL.TREE_NIL_disp
	La
	Ld
	CEQ
	LI	1
	OUX
	BF	L49
; CODE_RETURN : EXPR TYPE = DN_RECORD  VUE COMPLETE = DN_RECORD
	La   1,	-result__ofs
	La  ,  0
					; Assign_record_aggregate type DN_RECORD
	DUP
	LVA	, STANDARD.IDL._SEQ_TYPE.FIRST
	LI	STANDARD.IDL._TREE.size
	LVA 0,	STANDARD.IDL.TREE_NIL_disp
	La
	BLKMOV
	DUP
	LVA	, STANDARD.IDL._SEQ_TYPE.NEXT
	LI	STANDARD.IDL._TREE.size
	LVA 0,	STANDARD.IDL.TREE_NIL_disp
	La
	BLKMOV
	DROP
	BRA ret_lbl
	BRA	L42
L49:
L42:					; post if
STR STR_L50, "IDL.IDL-MAN.TAIL : LISTE VIDE S.FIRST = TREE_NIL !"	; constante string="IDL.IDL-MAN.TAIL : LISTE VIDE S.FIRST = TREE_NIL !"
	LCA	STR_L50.data_ptr
	CALL	STANDARD.TEXT_IO. ,PUT_LINE_L60
	LCA	STANDARD.PROGRAM_ERROR__exc.data_ptr
	Sa	0, STANDARD.EXCEPTIONS_CURRENT_disp
	BRA	STANDARD.exc_raise_
ret_lbl:
	UNLINK 1
	RTD	prm_siz-8
excep:
endPRO					;---------- end PRO TAIL
end if

if defined INSERT_L33_
PRO	INSERT_L33				;---------- PRO INSERT
 hexa_show 'INSERT_L33 ', $

</pre>

#Source Ada appelant dans idl-idl_man.adb
<pre>
function			  TAIL		( S :SEQ_TYPE )	return SEQ_TYPE				--| RETOURNE UN SEQ SUITE DE LISTE
is			--------
begin
  if S.FIRST.TY = DN_LIST then									--| LISTE A PLUSIEURS ELEMENTS
    declare
      QUEUE :  SEQ_TYPE	:= ( FIRST=> DABS ( 2, S.FIRST ) , NEXT=> TREE_NIL );				--| TETE DE QUEUE ET RIEN
    begin
      if QUEUE.FIRST.TY = DN_LIST then									--| SI TETE INDIQUANT UNE LISTE AVEC UNE SUITE
        QUEUE.NEXT := S.NEXT;										--| LA SUITE DE LA QUEUE EST RENDUE
      end if;
      return QUEUE;
    end;
  elsif S.FIRST /= TREE_NIL then									--| LISTE A UN SEUL ELEMENT
    return ( TREE_NIL, TREE_NIL );									--| RETOURNER UN SEQ VIDE
  end if;

  PUT_LINE ( "IDL.IDL-MAN.TAIL : LISTE VIDE S.FIRST = TREE_NIL !" );
  raise PROGRAM_ERROR;

end	TAIL;
</pre>