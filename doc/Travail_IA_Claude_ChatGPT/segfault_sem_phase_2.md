#COMMANDE AU COMPILATEUR
 <pre>
 ./T2 ./ ../_standrd.adb M
 </pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR
<pre> 
_standrd.adb
</pre>

#REMARQUES
flot d'exécution envoyé dans la pile.

#INSTRUCTION SEGFAULT
n'importe quoi on est allé dans la pile !
 <pre>
0x7fffffc0f498  rorb   $0x0,(%rsi)                                                                                             │
│   0x7fffffc0f49b  (bad)                                                                                                          │
│   0x7fffffc0f49c  (bad)                                                                                                          │
│  
</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x7fffffc0f498      140737484223640   rbx            0xe5                229               │
│rcx            0x0                 0                 rdx            0xff                255               │
│rsi            0x7fffffc0f6c4      140737484224196   rdi            0x7fffffc0f664      140737484224100   │
│rbp            0x7fffffc0f698      0x7fffffc0f698    rsp            0x7fffffbfda68      0x7fffffbfda68    │
│r8             0xffffffffffffffff  -1                r9             0x0                 0                 │
│r10            0x22                34                r11            0x246               582               │
│r12            0x7ffff7ded400      140737351963648   r13            0xefbb88            15711112          │
│r14            0xefbbc8            15711176          r15            0x7fffffbfdaf0      140737484151536   │
│rip            0x7fffffc0f498      0x7fffffc0f498    eflags         0x10202             [ IF RF ]         │
│</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc0f658: 0x00007fffffc04c68      0x00000000e3000000
0x7fffffc0f668: 0x00007fffffc0f630      0x00007fffffc0f498
0x7fffffc0f678: 0x00007fffffc06b60      0x00007fffffc0f640
0x7fffffc0f688: 0x00007fffffc0f548      0x0000000000000000
0x7fffffc0f698: 0x00007fffffc0f650      0x00007fffffc0f498
0x7fffffc0f6a8: 0x00007fffffc0f560      0x00007fffffc0f6c0
0x7fffffc0f6b8: 0x00007fffffc16720      0x00007fffe3000000
0x7fffffc0f6c8: 0x00007fffffc0f608      0x0000000005000001

</pre>

#BACKTRACE ET MAP
<pre>
#0  0x00007fffffc0f498 in ?? ()
**envoyé sur une adresse pile**
#1  0x0000000000516311 in ?? ()
REQUIRE_XXX_L18 0x0000000000515E9E
....
var elab NEW_TAIL 0x0000000000515FF4
 disp 0x0000000000000040
 **zone appel**
GET_BASE_STRUCT_L108 0x000000000051682E
var elab BASE_STRUCT 0x000000000051684F
 disp 0x0000000000000008

#2  0x00000000005166dd in ?? ()
var elab NEW_TAIL 0x0000000000515FE4
 disp 0x0000000000000040
 **zone appel**
GET_BASE_STRUCT_L108 0x000000000051680E

#3  0x000000000052016d in ?? ()

#4  0x00000000005201ab in ?? ()
N_REQUIRE_SCALAR_TYPE_L248 0x000000000052011A
**zone appel**
REQUIRE_UNIVERSAL_TYPE_L138 0x00000000005201C9

#5  0x00000000005eed71 in ?? ()
EVAL_RANGE_L219 0x00000000005EE955
....
var elab TYPESET_2 0x00000000005EECB3
 disp 0x0000000000000088
 **zone appel**
var elab IS_SUBTYPE 0x00000000005EF0D3
 disp 0x0000000000000008

#6  0x00000000005ef677 in ?? ()
EVAL_DISCRETE_RANGE_L220 0x00000000005EF3AF
var elab NEW_TYPESET 0x00000000005EF3CD
 disp 0x0000000000000008
 **zone appel**
var elab SUBTYPE_INDICATION 0x00000000005EF69A
 disp 0x0000000000000008

#7  0x00000000005eff19 in ?? ()
#8  0x0000000000573ca8 in ?? ()
#9  0x0000000000591250 in ?? ()
#10 0x00000000005a4d31 in ?? ()
#11 0x00000000005863e1 in ?? ()
#12 0x000000000059f92e in ?? ()
#13 0x0000000000658f4e in ?? ()
#14 0x00000000006595bd in ?? ()
#15 0x000000000066e6d2 in ?? ()
#16 0x0000000000d9c147 in ?? ()

</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT
<pre>
    procedure REQ_TYPE_XXX (EXP : TREE; TYPESET : in out TYPESET_TYPE) is	     --| ENLÈVE DE TYPESET LES INTERPRETATIONS QUI ONT IS_XXX FAUSSE

      function REQUIRE_XXX (TYPESET : TYPESET_TYPE) return TYPESET_TYPE is
        SET_TAIL : TYPESET_TYPE;
        SET_HEAD : TYPEINTERP_TYPE;
        NEW_TAIL : TYPESET_TYPE;
      begin
        SET_TAIL := TYPESET;
        POP (SET_TAIL, SET_HEAD);
        if IS_EMPTY (SET_TAIL) then
	NEW_TAIL := SET_TAIL;
        else
	NEW_TAIL := REQUIRE_XXX (SET_TAIL);
        end if;
        -- PROBLEME PROBABLE ICI
        if IS_XXX (GET_TYPE (SET_HEAD)) then
	if NEW_TAIL = SET_TAIL then
	  return TYPESET;
	else
	  NEW_TAIL := INSERT (NEW_TAIL, SET_HEAD);
	  return NEW_TAIL;
	end if;
        else
	return NEW_TAIL;
        end if;

      end REQUIRE_XXX;

    begin
      if IS_EMPTY (TYPESET) then
        return;
      end if;
      TYPESET := REQUIRE_XXX (TYPESET);
      if IS_EMPTY (TYPESET) then
        ERROR (D (LX_SRCPOS, EXP), MESSAGE);
      end if;
    end REQ_TYPE_XXX;

  end REQ_GENE;

</pre>

#Source Ada Instantiation appelante
<pre>
  procedure REQUIRE_SCALAR_TYPE (EXP : TREE; TYPESET : in out TYPESET_TYPE) is
    procedure N_REQUIRE_SCALAR_TYPE is new REQ_TYPE_XXX (IS_SCALAR_TYPE, "SCALAR TYPE REQUIRED");
  begin
    N_REQUIRE_SCALAR_TYPE (EXP, TYPESET);
  end REQUIRE_SCALAR_TYPE;

</pre>
#SECTION LLIR CONTENANT LE SEGFAULT DANS REQ_UTIL.FINC
<pre>
REQ_UTIL = 'REQ_UTIL'
namespace REQ_UTIL				;---------- PACKAGE (BDY)
					;    BODY ELAB
REQ_GENE = 'REQ_GENE'
namespace REQ_GENE				;---------- PACKAGE (BDY)
					;    BODY ELAB

if defined REQ_DEF_XXX_L1_
PRO	REQ_DEF_XXX_L1				;---------- PRO REQ_DEF_XXX
 hexa_show 'REQ_DEF_XXX_L1 ', $
virtual at 8
	MESSAGE__u_ofs = $
	rq 1
	MESSAGE_ofs = $
	rq 1
	IS_XXX__call_ofs = $
	rq 1
end virtual
PRMS					;    debut parametrage
	PRM EXP_ofs				; in
	PRM DEFSET_ofs				; in out
	PRM GFP_ofs
endPRMS					;    fin parametrage
ELB 2					;    BODY ELAB

if defined REQUIRE_XXX_L2_
PRO	REQUIRE_XXX_L2				;---------- PRO REQUIRE_XXX
 hexa_show 'REQUIRE_XXX_L2 ', $
PRMS					;    debut parametrage
	PRM DEFSET_ofs				; in
	PRM GFP_ofs
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 3					;    BODY ELAB
 hexa_show 'var elab SET_TAIL ', $
VAR SET_TAIL_disp, q			; variable record : pointeur aux data record
VAR SET_TAIL__u, q				; variable record : pointeur aux useinfo
VAR SET_TAIL__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA	3, SET_TAIL__dat
	Sa	3, SET_TAIL_disp			; record fin
	LVA	3, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.SIZ
	Sa	3, SET_TAIL__u

 hexa_show ' disp ', SET_TAIL_disp
 hexa_show 'var elab SET_HEAD ', $
VAR SET_HEAD_disp, q			; variable record : pointeur aux data record
VAR SET_HEAD__u, q				; variable record : pointeur aux useinfo
VAR SET_HEAD__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFINTERP_TYPE.size
	LVA	3, SET_HEAD__dat
	Sa	3, SET_HEAD_disp			; record fin
	LVA	3, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFINTERP_TYPE.SIZ
	Sa	3, SET_HEAD__u
	La  3, SET_HEAD_disp
					; store represented component PT range 0 .. 1 width 2
	DUP
	Ld
	LI	0
	LI	0
	LI	2
	BFI
	Sd

 hexa_show ' disp ', SET_HEAD_disp
 hexa_show 'var elab NEW_TAIL ', $
VAR NEW_TAIL_disp, q			; variable record : pointeur aux data record
VAR NEW_TAIL__u, q				; variable record : pointeur aux useinfo
VAR NEW_TAIL__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA	3, NEW_TAIL__dat
	Sa	3, NEW_TAIL_disp			; record fin
	LVA	3, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.SIZ
	Sa	3, NEW_TAIL__u

 hexa_show ' disp ', NEW_TAIL_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
	LVA 3,	SET_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	La  3,	-DEFSET_ofs
	La
	BLKMOV
	LVA  3,	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_DEF_XXX_L1.REQUIRE_XXX_L2.SET_HEAD_disp
	LVA  3,	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_DEF_XXX_L1.REQUIRE_XXX_L2.SET_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,POP_L75
					; debut if
	LI	0					; lieu resultat sur pile
	LVA 3,	SET_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,IS_EMPTY_L74
	BF	L6
	LVA 3,	NEW_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA 3,	SET_TAIL_disp
	La
	BLKMOV
	BRA	L5
L6:
	LVA 3,	NEW_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
VAR	ANON_35_14_disp, q
VAR	ANON_35_14__u,    q
VAR	ANON_35_14__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA 3, ANON_35_14__dat
	Sa  3, ANON_35_14_disp
	La  1, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.use__info
	Sa  3, ANON_35_14__u
	LVA 3, ANON_35_14_disp
					; doublet resultat record anonyme
	La  2,	-GFP_ofs				; propagation GFP generique
	LVA 3,	SET_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_DEF_XXX_L1. ,REQUIRE_XXX_L2
	La
	BLKMOV
L5:					; post if
					; debut if
	LI	0					; lieu resultat sur pile
	La  2,	-GFP_ofs				; propagation GFP generique
VAR	ANON_37_20_disp, q
VAR	ANON_37_20__u,    q
VAR	ANON_37_20__dat, STANDARD.IDL._TREE.size
	LVA 3, ANON_37_20__dat
	Sa  3, ANON_37_20_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  3, ANON_37_20__u
	LVA 3, ANON_37_20_disp
					; doublet resultat record anonyme
	LVA 3,	SET_HEAD_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,GET_DEF_L82
	La 2,	-GFP_ofs
	La ,	-IS_XXX__call_ofs
	CALLI
	BF	L8
					; debut if
	LVA 3,	NEW_TAIL_disp
	LVA 3,	SET_TAIL_disp
	CEQ
	BF	L10
; CODE_RETURN : EXPR TYPE = DN_PRIVATE  VUE COMPLETE = DN_RECORD
	La   3,	-result__ofs
	La  ,  0
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	La  3,	-DEFSET_ofs
	La
	BLKMOV
	BRA ret_lbl
	BRA	L9
L10:
	LVA 3,	NEW_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
VAR	ANON_41_16_disp, q
VAR	ANON_41_16__u,    q
VAR	ANON_41_16__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA 3, ANON_41_16__dat
	Sa  3, ANON_41_16_disp
	La  1, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.use__info
	Sa  3, ANON_41_16__u
	LVA 3, ANON_41_16_disp
					; doublet resultat record anonyme
	LVA 3,	SET_HEAD_disp
	LVA 3,	NEW_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,INSERT_L81
	La
	BLKMOV
; CODE_RETURN : EXPR TYPE = DN_PRIVATE  VUE COMPLETE = DN_RECORD
	La   3,	-result__ofs
	La  ,  0
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA 3,	NEW_TAIL_disp
	La
	BLKMOV
	BRA ret_lbl
L9:					; post if
	BRA	L7
L8:
; CODE_RETURN : EXPR TYPE = DN_PRIVATE  VUE COMPLETE = DN_RECORD
	La   3,	-result__ofs
	La  ,  0
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA 3,	NEW_TAIL_disp
	La
	BLKMOV
	BRA ret_lbl
L7:					; post if
ret_lbl:
	UNLINK 3
	RTD	prm_siz-8
excep:
endPRO					;---------- end PRO REQUIRE_XXX
end if
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
					; debut if
	LI	0					; lieu resultat sur pile
	La  2,	-DEFSET_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,IS_EMPTY_L74
	BF	L14
	BRA ret_lbl
	BRA	L13
L14:
L13:					; post if
	La  2,	-DEFSET_ofs
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
VAR	ANON_54_17_disp, q
VAR	ANON_54_17__u,    q
VAR	ANON_54_17__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.size
	LVA 2, ANON_54_17__dat
	Sa  2, ANON_54_17_disp
	La  1, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._DEFSET_TYPE.use__info
	Sa  2, ANON_54_17__u
	LVA 2, ANON_54_17_disp
					; doublet resultat record anonyme
	La  2,	-GFP_ofs				; propagation GFP generique
	La  2,	-DEFSET_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_DEF_XXX_L1. ,REQUIRE_XXX_L2
	La
	BLKMOV
					; debut if
	LI	0					; lieu resultat sur pile
	La  2,	-DEFSET_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,IS_EMPTY_L74
	BF	L16
	La 2,	-GFP_ofs
	LVA ,	-MESSAGE_ofs
VAR	ANON_56_16_disp, q
VAR	ANON_56_16__u,    q
VAR	ANON_56_16__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_56_16__dat
	Sa  2, ANON_56_16_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_56_16__u
	LVA 2, ANON_56_16_disp
					; doublet resultat record anonyme
	La  2,	-EXP_ofs
	LI  154
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.IDL_MAN. ,ERROR_L45
	BRA	L15
L16:
L15:					; post if
ret_lbl:
	UNLINK 2
	RTD	prm_siz
excep:
endPRO					;---------- end PRO REQ_DEF_XXX
end if

if defined REQ_TYPE_XXX_L17_
PRO	REQ_TYPE_XXX_L17			;---------- PRO REQ_TYPE_XXX
 hexa_show 'REQ_TYPE_XXX_L17 ', $
virtual at 8
	MESSAGE__u_ofs = $
	rq 1
	MESSAGE_ofs = $
	rq 1
	IS_XXX__call_ofs = $
	rq 1
end virtual
PRMS					;    debut parametrage
	PRM EXP_ofs				; in
	PRM TYPESET_ofs				; in out
	PRM GFP_ofs
endPRMS					;    fin parametrage
ELB 2					;    BODY ELAB

if defined REQUIRE_XXX_L18_
PRO	REQUIRE_XXX_L18				;---------- PRO REQUIRE_XXX
 hexa_show 'REQUIRE_XXX_L18 ', $
PRMS					;    debut parametrage
	PRM TYPESET_ofs				; in
	PRM GFP_ofs
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 3					;    BODY ELAB
 hexa_show 'var elab SET_TAIL ', $
VAR SET_TAIL_disp, q			; variable record : pointeur aux data record
VAR SET_TAIL__u, q				; variable record : pointeur aux useinfo
VAR SET_TAIL__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA	3, SET_TAIL__dat
	Sa	3, SET_TAIL_disp			; record fin
	LVA	3, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.SIZ
	Sa	3, SET_TAIL__u

 hexa_show ' disp ', SET_TAIL_disp
 hexa_show 'var elab SET_HEAD ', $
VAR SET_HEAD_disp, q			; variable record : pointeur aux data record
VAR SET_HEAD__u, q				; variable record : pointeur aux useinfo
VAR SET_HEAD__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPEINTERP_TYPE.size
	LVA	3, SET_HEAD__dat
	Sa	3, SET_HEAD_disp			; record fin
	LVA	3, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPEINTERP_TYPE.SIZ
	Sa	3, SET_HEAD__u
	La  3, SET_HEAD_disp
					; store represented component PT range 0 .. 1 width 2
	DUP
	Ld
	LI	0
	LI	0
	LI	2
	BFI
	Sd

 hexa_show ' disp ', SET_HEAD_disp
 hexa_show 'var elab NEW_TAIL ', $
VAR NEW_TAIL_disp, q			; variable record : pointeur aux data record
VAR NEW_TAIL__u, q				; variable record : pointeur aux useinfo
VAR NEW_TAIL__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA	3, NEW_TAIL__dat
	Sa	3, NEW_TAIL_disp			; record fin
	LVA	3, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.SIZ
	Sa	3, NEW_TAIL__u

 hexa_show ' disp ', NEW_TAIL_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
	LVA 3,	SET_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	La  3,	-TYPESET_ofs
	La
	BLKMOV
	LVA  3,	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_TYPE_XXX_L17.REQUIRE_XXX_L18.SET_HEAD_disp
	LVA  3,	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_TYPE_XXX_L17.REQUIRE_XXX_L18.SET_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,POP_L89
					; debut if
	LI	0					; lieu resultat sur pile
	LVA 3,	SET_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,IS_EMPTY_L88
	BF	L22
	LVA 3,	NEW_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA 3,	SET_TAIL_disp
	La
	BLKMOV
	BRA	L21
L22:
	LVA 3,	NEW_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
VAR	ANON_73_14_disp, q
VAR	ANON_73_14__u,    q
VAR	ANON_73_14__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA 3, ANON_73_14__dat
	Sa  3, ANON_73_14_disp
	La  1, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.use__info
	Sa  3, ANON_73_14__u
	LVA 3, ANON_73_14_disp
					; doublet resultat record anonyme
	La  2,	-GFP_ofs				; propagation GFP generique
	LVA 3,	SET_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_TYPE_XXX_L17. ,REQUIRE_XXX_L18
	La
	BLKMOV
L21:					; post if
					; debut if
	LI	0					; lieu resultat sur pile
	La  2,	-GFP_ofs				; propagation GFP generique
VAR	ANON_75_20_disp, q
VAR	ANON_75_20__u,    q
VAR	ANON_75_20__dat, STANDARD.IDL._TREE.size
	LVA 3, ANON_75_20__dat
	Sa  3, ANON_75_20_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  3, ANON_75_20__u
	LVA 3, ANON_75_20_disp
					; doublet resultat record anonyme
	LVA 3,	SET_HEAD_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,GET_TYPE_L95
	La 2,	-GFP_ofs
	La ,	-IS_XXX__call_ofs
	CALLI
	BF	L24
					; debut if
	LVA 3,	NEW_TAIL_disp
	LVA 3,	SET_TAIL_disp
	CEQ
	BF	L26
; CODE_RETURN : EXPR TYPE = DN_PRIVATE  VUE COMPLETE = DN_RECORD
	La   3,	-result__ofs
	La  ,  0
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	La  3,	-TYPESET_ofs
	La
	BLKMOV
	BRA ret_lbl
	BRA	L25
L26:
	LVA 3,	NEW_TAIL_disp
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
VAR	ANON_79_16_disp, q
VAR	ANON_79_16__u,    q
VAR	ANON_79_16__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA 3, ANON_79_16__dat
	Sa  3, ANON_79_16_disp
	La  1, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.use__info
	Sa  3, ANON_79_16__u
	LVA 3, ANON_79_16_disp
					; doublet resultat record anonyme
	LVA 3,	SET_HEAD_disp
	LVA 3,	NEW_TAIL_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,INSERT_L94
	La
	BLKMOV
; CODE_RETURN : EXPR TYPE = DN_PRIVATE  VUE COMPLETE = DN_RECORD
	La   3,	-result__ofs
	La  ,  0
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA 3,	NEW_TAIL_disp
	La
	BLKMOV
	BRA ret_lbl
L25:					; post if
	BRA	L23
L24:
; CODE_RETURN : EXPR TYPE = DN_PRIVATE  VUE COMPLETE = DN_RECORD
	La   3,	-result__ofs
	La  ,  0
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA 3,	NEW_TAIL_disp
	La
	BLKMOV
	BRA ret_lbl
L23:					; post if
ret_lbl:
	UNLINK 3
	RTD	prm_siz-8
excep:
endPRO					;---------- end PRO REQUIRE_XXX
end if
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
					; debut if
	LI	0					; lieu resultat sur pile
	La  2,	-TYPESET_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,IS_EMPTY_L88
	BF	L30
	BRA ret_lbl
	BRA	L29
L30:
L29:					; post if
	La  2,	-TYPESET_ofs
	La
	LI	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
VAR	ANON_92_18_disp, q
VAR	ANON_92_18__u,    q
VAR	ANON_92_18__dat, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.size
	LVA 2, ANON_92_18__dat
	Sa  2, ANON_92_18_disp
	La  1, STANDARD.IDL.SEM_PHASE_L11.SET_UTIL._TYPESET_TYPE.use__info
	Sa  2, ANON_92_18__u
	LVA 2, ANON_92_18_disp
					; doublet resultat record anonyme
	La  2,	-GFP_ofs				; propagation GFP generique
	La  2,	-TYPESET_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE.REQ_TYPE_XXX_L17. ,REQUIRE_XXX_L18
	La
	BLKMOV
					; debut if
	LI	0					; lieu resultat sur pile
	La  2,	-TYPESET_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.SET_UTIL. ,IS_EMPTY_L88
	BF	L32
	La 2,	-GFP_ofs
	LVA ,	-MESSAGE_ofs
VAR	ANON_94_16_disp, q
VAR	ANON_94_16__u,    q
VAR	ANON_94_16__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_94_16__dat
	Sa  2, ANON_94_16_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_94_16__u
	LVA 2, ANON_94_16_disp
					; doublet resultat record anonyme
	La  2,	-EXP_ofs
	LI  154
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.IDL_MAN. ,ERROR_L45
	BRA	L31
L32:
L31:					; post if
ret_lbl:
	UNLINK 2
	RTD	prm_siz
excep:
endPRO					;---------- end PRO REQ_TYPE_XXX
end if
begin:					;---------- package BDY INSTRUCTIONS
end namespace 				;---------- end package BDY REQ_GENE

 </pre>
 
#SECTION LLIR INSTANCIATION APPELANTE DANS REQ_UTIL.FINC
 <pre>
 if defined REQUIRE_SCALAR_TYPE_L137_
PRO	REQUIRE_SCALAR_TYPE_L137			;---------- PRO REQUIRE_SCALAR_TYPE
 hexa_show 'REQUIRE_SCALAR_TYPE_L137 ', $
PRMS					;    debut parametrage
	PRM EXP_ofs				; in
	PRM TYPESET_ofs				; in out
endPRMS					;    fin parametrage
ELB 2					;    BODY ELAB
					; sub program entry decl (in instantiation FALSE )
if defined N_REQUIRE_SCALAR_TYPE_L248_
VAR IS_XXX__call_ofs, q
	LSPA	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL. ,IS_SCALAR_TYPE_L118
	Sa	 2, IS_XXX__call_ofs
VAR N_REQUIRE_SCALAR_TYPE_L248MESSAGE_disp, q
VAR N_REQUIRE_SCALAR_TYPE_L248MESSAGE__u, q
STR STR_L250, "SCALAR TYPE REQUIRED"		; constante string="SCALAR TYPE REQUIRED"
	LCA	STR_L250.data_ptr
	DUP
	La  ,  0
	Sa  2, N_REQUIRE_SCALAR_TYPE_L248MESSAGE_disp
	La  ,  8
	Sa  2, N_REQUIRE_SCALAR_TYPE_L248MESSAGE__u
VAR GFP_disp, q				; Lieu du Generic Frame Pointer 
PRO	N_REQUIRE_SCALAR_TYPE_L248		;---------- PRO N_REQUIRE_SCALAR_TYPE
 hexa_show 'N_REQUIRE_SCALAR_TYPE_L248 ', $
PRMS					;    debut parametrage
	PRM EXP_ofs				; in
	PRM TYPESET_ofs				; in out
endPRMS					;    fin parametrage
ELB 3
begin:
	LVA	 2, GFP_disp
	La 	 3, -TYPESET_ofs
	La 	 3, -EXP_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQ_GENE. ,REQ_TYPE_XXX_L17
	UNLINK	 3
	RTD	prm_siz
endPRO					;---------- end PRO N_REQUIRE_SCALAR_TYPE
end if
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
	La  2,	-TYPESET_ofs
	La  2,	-EXP_ofs
	CALL	STANDARD.IDL.SEM_PHASE_L11.REQ_UTIL.REQUIRE_SCALAR_TYPE_L137. ,N_REQUIRE_SCALAR_TYPE_L248
ret_lbl:
	UNLINK 2
	RTD	prm_siz
excep:
endPRO					;---------- end PRO REQUIRE_SCALAR_TYPE
end if

 </pre>
