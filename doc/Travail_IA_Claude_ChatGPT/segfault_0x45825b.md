#COMMANDE AU COMPILATEUR
 <pre>
 $ ./A83.sh ./ ../_standrd.ads M
ada83 compiling ./../_standrd.ads
_STANDRD
STANDARD
BOOLEAN
SHORT_INTEGER
./A83.sh : ligne 2 : 1146276 Erreur de segmentation  (core dumped) ./ADA_COMP <<< "$1 $2 $3"

 </pre>
 

#REMARQUE
segfault dans FIX_PRE.WALK appel sous-programme D puis DABS.

#INSTRUCTION SEGFAULT 0x45825b
 <pre>
(gdb) x/16i $rip-32
   0x45823b:    mov    %rax,0x8(%rbp)
   0x45823f:    lea    0x8(%rbp),%rbp
   0x458243:    mov    0x8(%r15),%rax
   0x458247:    mov    -0x18(%rax),%rax
   0x45824b:    mov    %rax,0x8(%rbp)
   0x45824f:    lea    0x8(%rbp),%rbp
   0x458253:    mov    0x0(%rbp),%rax
   0x458257:    lea    -0x8(%rbp),%rbp
=> 0x45825b:    mov    (%rax),%rax
   0x45825e:    mov    %rax,0x8(%rbp)
   0x458262:    lea    0x8(%rbp),%rbp
   0x458266:    mov    0x0(%rbp),%rsi
   0x45826a:    lea    -0x8(%rbp),%rbp
   0x45826e:    mov    0x0(%rbp),%rcx
   0x458272:    lea    -0x8(%rbp),%rbp
   0x458276:    mov    0x0(%rbp),%rdi

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x0                 0                            rbx            0x8                 8                            │
│rcx            0x7                 7                            rdx            0x0                 0                            │
│rsi            0x7fffffc1e5b4      140737484285364              rdi            0x7fffffc1dcd4      140737484283092              │
│rbp            0x7fffffc1dfa8      0x7fffffc1dfa8               rsp            0x7fffffbfda50      0x7fffffbfda50               │
│r8             0xffffffffffffffff  -1                           r9             0x0                 0                            │
│r10            0x22                34                           r11            0x202               514                          │
│r12            0x7ffff7ded400      140737351963648              r13            0xea64c8            15361224                     │
│r14            0xea64d0            15361232                     r15            0x7fffffbfdaf0      140737484151536              │
│rip            0x45825b            0x45825b                     eflags         0x10202             [ IF RF ]                    │
</pre>

#STACK AU SEGFAULT $rbp=0x7fffffc1dfa8
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc1df68: 0x00007fffffc1df78      0x0000000000000000
0x7fffffc1df78: 0x00007fffffc1d730      0x0000000000000006
0x7fffffc1df88: 0x00007fffffc1de28      0x000000000000001a
0x7fffffc1df98: 0x00007fffffc1dce8      0x00007ffff7df0454
0x7fffffc1dfa8: 0x0000000000000004      0x0000000000000000
0x7fffffc1dfb8: 0x0000000000000008      0x0000000000000004
0x7fffffc1dfc8: 0x00007fffffc1de40      0x0000000000000002
0x7fffffc1dfd8: 0x00007fffffc1de58      0x00007fffffc1de60
</pre>

#BACKTRACE ET MAP
<pre>
#0  0x000000000045825b in IDL_MAN
DABS_L37 0x00000000004579F5
var elab RN 0x0000000000457A13
 disp 0x0000000000000008
 **zone segfault**
DABS_L38 0x0000000000458410
var elab RN 0x000000000045842E

#1  0x000000000046ca37 in IDL
MAKE_L15 0x000000000046BD6E
D_L16 0x000000000046C3F9
var elab APOS 0x000000000046C41A
 disp 0x0000000000000008
 **zone appel**
D_L17 0x000000000046D70C

#2  0x00000000006642c2 in ?? ()
WALK_L42 0x000000000065C0E3
...
var elab BLTN_OPERATOR_ID 0x00000000006628F9
 disp 0x00000000000000D0
 **zone appel**
var elab VALUE 0x0000000000664A74
 disp 0x0000000000000008

#3  0x0000000000667442 in ?? ()
var elab ITEM_NODE 0x0000000000666CC7
 disp 0x0000000000000028
MAKE_PREDEF_IDS_L169 0x0000000000667483

#4  0x0000000000662b1f in ?? ()
#5  0x00000000006652bf in ?? ()
#6  0x0000000000660810 in ?? ()
#7  0x000000000065da69 in ?? ()
#8  0x0000000000667442 in ?? ()
#9  0x0000000000665da9 in ?? ()
#10 0x000000000065e7af in ?? ()
#11 0x0000000000667442 in ?? ()
#12 0x0000000000665da9 in ?? ()
#13 0x000000000065e7af in ?? ()
#14 0x000000000066652c in ?? ()
#15 0x0000000000667442 in ?? ()
#16 0x000000000066613f in ?? ()
#17 0x000000000066c054 in ?? ()
#18 0x000000000066e4aa in ?? ()
#19 0x0000000000d97889 in ?? ()
#20 0x0000000000d98886 in ?? ()

</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT
<pre>
procedure			  DABS		( RANG :ATTR_NBR; T :TREE; VAL :TREE )
is			--------
  RN		: RPG_IDX;
begin
  if T.PG /= CUR_VP then										--| LA PAGE QUI NOUS INTERESSE N'EST PAS COURANTE
    CUR_VP := T.PG;											--| LA MENTIONNER COMME COURANTE
    RN := ASSOC_PAGE( CUR_VP );									--| SON ASSOCIEE PHYSIQUE EST LA RN
    if RN = 0 then											--| SI HORS MEMOIRE
      CUR_RP := READ_PAGE ( CUR_VP );									--| ASSURER LA PAGE PHYSIQUE
    else												--| NON FLOTTANTE
      CUR_RP := RN;											--| PAGE REELLE COURANTE
    end if;
  end if;

  PAG( CUR_RP ).DATA.all( T.LN + RANG ) := VAL;								--| ECRIRE
  PAG( CUR_RP ).CHANGED := TRUE;									--| MENTIONNEE CHANGEE (ON Y A ECRIT ! )

end	DABS;

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS IDL-IDL_MAN.FINC
<pre>
if defined DABS_L37_
PRO	DABS_L37				;---------- PRO DABS
 hexa_show 'DABS_L37 ', $
PRMS					;    debut parametrage
	PRM RANG_ofs				; in
	PRM T_ofs				; in
	PRM VAL_ofs				; in
endPRMS					;    fin parametrage
ELB 1					;    BODY ELAB
 hexa_show 'var elab RN ', $
VAR RN_disp, d				; variable entiere

 hexa_show ' disp ', RN_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
					; debut if
	La 1, -T_ofs
	La	-1, 0
	Ld
	LI	9
	LI	15
	UBFX
	ULw 0,	STANDARD.IDL.PAGE_MAN.CUR_VP_disp
	CNE
	BF	L129
	La 1, -T_ofs
	La	-1, 0
	Ld
	LI	9
	LI	15
	UBFX
	DUP
	ULw	0, STANDARD.IDL.PAGE_MAN._VPG_NUM.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULw	0, STANDARD.IDL.PAGE_MAN._VPG_NUM.LST
	CGT
	BT	STANDARD.ce_raise_
	Sw  0,	STANDARD.IDL.PAGE_MAN.CUR_VP_disp
	La	 0, STANDARD.IDL.PAGE_MAN.ASSOC_PAGE_disp	; array data start address on stack
	ULw 0,	STANDARD.IDL.PAGE_MAN.CUR_VP_disp
	DUP
	LId	0, STANDARD.IDL.PAGE_MAN.ASSOC_PAGE__u, STANDARD.IDL.PAGE_MAN._ASSOC_PAGE__type.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	0, STANDARD.IDL.PAGE_MAN.ASSOC_PAGE__u, STANDARD.IDL.PAGE_MAN._ASSOC_PAGE__type.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	0, STANDARD.IDL.PAGE_MAN.ASSOC_PAGE__u, STANDARD.IDL.PAGE_MAN._ASSOC_PAGE__type.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	0, STANDARD.IDL.PAGE_MAN.ASSOC_PAGE__u, STANDARD.IDL.PAGE_MAN._ASSOC_PAGE__type.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	ULd
	Sd  1,	RN_disp
					; debut if
	ULd 1,	RN_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	CEQ
	BF	L131
	LI	0					; lieu resultat sur pile
	ULw 0,	STANDARD.IDL.PAGE_MAN.CUR_VP_disp
	DUP
	ULw	0, STANDARD.IDL.PAGE_MAN._VPG_NUM.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULw	0, STANDARD.IDL.PAGE_MAN._VPG_NUM.LST
	CGT
	BT	STANDARD.ce_raise_
	CALL	STANDARD.IDL.PAGE_MAN. ,READ_PAGE_L16
	DUP
	ULd	0, STANDARD.IDL.PAGE_MAN._RPG_NUM.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULd	0, STANDARD.IDL.PAGE_MAN._RPG_NUM.LST
	CGT
	BT	STANDARD.ce_raise_
	Sd  0,	STANDARD.IDL.PAGE_MAN.CUR_RP_disp
	BRA	L130
L131:
	ULd 1,	RN_disp
	DUP
	ULd	0, STANDARD.IDL.PAGE_MAN._RPG_NUM.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULd	0, STANDARD.IDL.PAGE_MAN._RPG_NUM.LST
	CGT
	BT	STANDARD.ce_raise_
	Sd  0,	STANDARD.IDL.PAGE_MAN.CUR_RP_disp
L130:					; post if
	BRA	L128
L129:
L128:					; post if
	La	 0, STANDARD.IDL.PAGE_MAN.PAG_disp		; array data start address on stack
	ULd 0,	STANDARD.IDL.PAGE_MAN.CUR_RP_disp
	DUP
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	Lq	, STANDARD.IDL.PAGE_MAN._RPG_DATA.DATA
	La 1, -T_ofs
	La	-1, 0
	Ld
	LI	2
	LI	7
	UBFX
	ULb  1,	-RANG_ofs
	ADD
	DUP
	Ld	 0, STANDARD.IDL.PAGE_MAN._SECTOR._FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	Ld	 0, STANDARD.IDL.PAGE_MAN._SECTOR._LST_1
	CGT
	BT	STANDARD.ce_raise_
	Ld	 0, STANDARD.IDL.PAGE_MAN._SECTOR._FST_1
	SUB
	Ld	 0, STANDARD.IDL.PAGE_MAN._SECTOR._COMP_SIZ
	LI	8
	DIV
	MUL
	ADD
	LI	STANDARD.IDL._TREE.size
	La  1,	-VAL_ofs
	La
	BLKMOV
	La	 0, STANDARD.IDL.PAGE_MAN.PAG_disp		; array data start address on stack
	ULd 0,	STANDARD.IDL.PAGE_MAN.CUR_RP_disp
	DUP
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	0, STANDARD.IDL.PAGE_MAN.PAG__u, STANDARD.IDL.PAGE_MAN._PAG__type.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	LVA	, STANDARD.IDL.PAGE_MAN._RPG_DATA.CHANGED
	LI	1
	Sb
ret_lbl:
	UNLINK 1
	RTD	prm_siz
excep:
endPRO					;---------- end PRO DABS
end if

 </pre>

#SECTION LLIR APPELANTE DANS IDL.FINC
<pre>
if defined D_L16_
PRO	D_L16					;---------- PRO D
 hexa_show 'D_L16 ', $
PRMS					;    debut parametrage
	PRM AN_ofs				; in
	PRM T_ofs				; in
	PRM V_ofs				; in
endPRMS					;    fin parametrage
ELB 1					;    BODY ELAB
 hexa_show 'var elab APOS ', $
VAR APOS_disp, d				; variable entiere
	La	 0, STANDARD.IDL.IDL_TBL.N_SPEC_disp	; array data start address on stack
	La 1, -T_ofs
	La	-1, 0
	Ld
	LI	24
	LI	8
	UBFX
	DUP
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	Ld	, STANDARD.IDL.IDL_TBL._NODE_SPECIF.NS_FIRST_A
	Sd  1,	APOS_disp

 hexa_show ' disp ', APOS_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
VAR	IL114_disp, b				; compteur boucle LOOP__7
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	Sb  1,	IL114_disp
VAR	LMT_IL114_disp, b			; limite boucle LOOP__7
	La	 0, STANDARD.IDL.IDL_TBL.N_SPEC_disp	; array data start address on stack
	La 1, -T_ofs
	La	-1, 0
	Ld
	LI	24
	LI	8
	UBFX
	DUP
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	0, STANDARD.IDL.IDL_TBL.N_SPEC__u, STANDARD.IDL.IDL_TBL._NODE_SPECIF_TABLE.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	ULb	, STANDARD.IDL.IDL_TBL._NODE_SPECIF.NS_SIZE
	Sb  1,	LMT_IL114_disp
	ULb  1,	IL114_disp				; test null range LOOP__7
	ULb  1,	LMT_IL114_disp
	CGT
	BT	L113
LOOP__7:					; corps boucle LOOP__7
					; debut if
	La	 0, STANDARD.IDL.IDL_TBL.A_SPEC_disp	; array data start address on stack
	Ld 1,	APOS_disp
	DUP
	LId	0, STANDARD.IDL.IDL_TBL.A_SPEC__u, STANDARD.IDL.IDL_TBL._ATTR_ID_TABLE.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	0, STANDARD.IDL.IDL_TBL.A_SPEC__u, STANDARD.IDL.IDL_TBL._ATTR_ID_TABLE.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	0, STANDARD.IDL.IDL_TBL.A_SPEC__u, STANDARD.IDL.IDL_TBL._ATTR_ID_TABLE.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	0, STANDARD.IDL.IDL_TBL.A_SPEC__u, STANDARD.IDL.IDL_TBL._ATTR_ID_TABLE.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	ULb	, STANDARD.IDL.IDL_TBL._ATTR_SPECIF.ATTR
	ULb  1,	-AN_ofs
	CEQ
	BF	L116
	La  1,	-V_ofs
	La  1,	-T_ofs
	ULb  1,	IL114_disp
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.LST
	CGT
	BT	STANDARD.ce_raise_
	; **** APPEL DABS
	CALL	STANDARD.IDL.IDL_MAN. ,DABS_L37
	;****
	BRA ret_lbl
	BRA	L115
L116:
L115:					; post if
	Ld 1,	APOS_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	ADD
	Sd  1,	APOS_disp
	ULb  1,	IL114_disp				; test de sortie LOOP__7
	ULb  1,	LMT_IL114_disp
	CEQ
	BT	L113
	ULb  1,	IL114_disp				; mise a jour compteur LOOP__7
	INC
	Sb  1,	IL114_disp
	BRA	LOOP__7				; iteration suivante LOOP__7
L113:					; post loop LOOP__7
; CODE & concat _STRING
VAR	ANON_313_15_L117_G_data, q
VAR	ANON_313_15_L117_G_info, q
VAR	ANON_313_84_L117_D_data, q
VAR	ANON_313_84_L117_D_info, q
VAR	ANON_313_15_L117_G_len,  q
VAR	ANON_313_84_L117_D_len,  q
VAR	ANON_313_15_L117_R_disp, q
VAR	ANON_313_15_L117_R__u,   q
namespace ANON_313_15_L117_R_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
; CODE & concat _STRING
VAR	ANON_313_15_L118_G_data, q
VAR	ANON_313_15_L118_G_info, q
VAR	ANON_313_73_L118_D_data, q
VAR	ANON_313_73_L118_D_info, q
VAR	ANON_313_15_L118_G_len,  q
VAR	ANON_313_73_L118_D_len,  q
VAR	ANON_313_15_L118_R_disp, q
VAR	ANON_313_15_L118_R__u,   q
namespace ANON_313_15_L118_R_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
; CODE & concat _STRING
VAR	ANON_313_15_L119_G_data, q
VAR	ANON_313_15_L119_G_info, q
VAR	ANON_313_54_L119_D_data, q
VAR	ANON_313_54_L119_D_info, q
VAR	ANON_313_15_L119_G_len,  q
VAR	ANON_313_54_L119_D_len,  q
VAR	ANON_313_15_L119_R_disp, q
VAR	ANON_313_15_L119_R__u,   q
namespace ANON_313_15_L119_R_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
STR ANON_313_15_L119_G, "; !! PROCEDURE D : PAS D ATTRIBUT "	; constante string="; !! PROCEDURE D : PAS D ATTRIBUT "
	LCA	ANON_313_15_L119_G.data_ptr
	DUP
	La  ,  0
	Sa  1, ANON_313_15_L119_G_data
	La  ,  8
	Sa  1, ANON_313_15_L119_G_info
	LId 1, ANON_313_15_L119_G_info, _STRING.LST_1
	LId 1, ANON_313_15_L119_G_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_313_15_L119_G_len
VAR	ANON_313_54_disp, q
VAR	ANON_313_54__u,   q
namespace ANON_313_54_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 1, ANON_313_54_info.SIZ
	Sa  1, ANON_313_54__u
	LVA 1, ANON_313_54_disp
	ULb  1,	-AN_ofs
	CALL	STANDARD.IDL. ,ATTR_IMAGE_L28
	DUP
	La  ,  0
	Sa  1, ANON_313_54_L119_D_data
	La  ,  8
	Sa  1, ANON_313_54_L119_D_info
	LId 1, ANON_313_54_L119_D_info, _STRING.LST_1
	LId 1, ANON_313_54_L119_D_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_313_54_L119_D_len
	La  1, ANON_313_15_L119_G_len
	La  1, ANON_313_54_L119_D_len
	ADD
	CO_VAR
	Sa  1, ANON_313_15_L119_R_disp
	LI	1
	Sd  1, ANON_313_15_L119_R_info._FST_1
	La  1, ANON_313_15_L119_G_len
	La  1, ANON_313_54_L119_D_len
	ADD
	Sd  1, ANON_313_15_L119_R_info._LST_1
	LI	8
	Sd  1, ANON_313_15_L119_R_info._COMP_SIZ
	La  1, ANON_313_15_L119_G_len
	La  1, ANON_313_54_L119_D_len
	ADD
	LI	8
	MUL
	Sd  1, ANON_313_15_L119_R_info.SIZ
	LVA 1, ANON_313_15_L119_R_info.SIZ
	Sa  1, ANON_313_15_L119_R__u
	La  1, ANON_313_15_L119_R_disp
	La  1, ANON_313_15_L119_G_len
	La  1, ANON_313_15_L119_G_data
	BLKMOV
	La  1, ANON_313_15_L119_R_disp
	La  1, ANON_313_15_L119_G_len
	ADD
	La  1, ANON_313_54_L119_D_len
	La  1, ANON_313_54_L119_D_data
	BLKMOV
	LVA 1, ANON_313_15_L119_R_disp
	DUP
	La  ,  0
	Sa  1, ANON_313_15_L118_G_data
	La  ,  8
	Sa  1, ANON_313_15_L118_G_info
	LId 1, ANON_313_15_L118_G_info, _STRING.LST_1
	LId 1, ANON_313_15_L118_G_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_313_15_L118_G_len
STR ANON_313_73_L118_D, " DANS "		; constante string=" DANS "
	LCA	ANON_313_73_L118_D.data_ptr
	DUP
	La  ,  0
	Sa  1, ANON_313_73_L118_D_data
	La  ,  8
	Sa  1, ANON_313_73_L118_D_info
	LId 1, ANON_313_73_L118_D_info, _STRING.LST_1
	LId 1, ANON_313_73_L118_D_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_313_73_L118_D_len
	La  1, ANON_313_15_L118_G_len
	La  1, ANON_313_73_L118_D_len
	ADD
	CO_VAR
	Sa  1, ANON_313_15_L118_R_disp
	LI	1
	Sd  1, ANON_313_15_L118_R_info._FST_1
	La  1, ANON_313_15_L118_G_len
	La  1, ANON_313_73_L118_D_len
	ADD
	Sd  1, ANON_313_15_L118_R_info._LST_1
	LI	8
	Sd  1, ANON_313_15_L118_R_info._COMP_SIZ
	La  1, ANON_313_15_L118_G_len
	La  1, ANON_313_73_L118_D_len
	ADD
	LI	8
	MUL
	Sd  1, ANON_313_15_L118_R_info.SIZ
	LVA 1, ANON_313_15_L118_R_info.SIZ
	Sa  1, ANON_313_15_L118_R__u
	La  1, ANON_313_15_L118_R_disp
	La  1, ANON_313_15_L118_G_len
	La  1, ANON_313_15_L118_G_data
	BLKMOV
	La  1, ANON_313_15_L118_R_disp
	La  1, ANON_313_15_L118_G_len
	ADD
	La  1, ANON_313_73_L118_D_len
	La  1, ANON_313_73_L118_D_data
	BLKMOV
	LVA 1, ANON_313_15_L118_R_disp
	DUP
	La  ,  0
	Sa  1, ANON_313_15_L117_G_data
	La  ,  8
	Sa  1, ANON_313_15_L117_G_info
	LId 1, ANON_313_15_L117_G_info, _STRING.LST_1
	LId 1, ANON_313_15_L117_G_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_313_15_L117_G_len
VAR	ANON_313_84_disp, q
VAR	ANON_313_84__u,   q
namespace ANON_313_84_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 1, ANON_313_84_info.SIZ
	Sa  1, ANON_313_84__u
	LVA 1, ANON_313_84_disp
	La  1,	-T_ofs
	CALL	STANDARD.IDL.IDL_MAN. ,NODE_REP_L51
	DUP
	La  ,  0
	Sa  1, ANON_313_84_L117_D_data
	La  ,  8
	Sa  1, ANON_313_84_L117_D_info
	LId 1, ANON_313_84_L117_D_info, _STRING.LST_1
	LId 1, ANON_313_84_L117_D_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_313_84_L117_D_len
	La  1, ANON_313_15_L117_G_len
	La  1, ANON_313_84_L117_D_len
	ADD
	CO_VAR
	Sa  1, ANON_313_15_L117_R_disp
	LI	1
	Sd  1, ANON_313_15_L117_R_info._FST_1
	La  1, ANON_313_15_L117_G_len
	La  1, ANON_313_84_L117_D_len
	ADD
	Sd  1, ANON_313_15_L117_R_info._LST_1
	LI	8
	Sd  1, ANON_313_15_L117_R_info._COMP_SIZ
	La  1, ANON_313_15_L117_G_len
	La  1, ANON_313_84_L117_D_len
	ADD
	LI	8
	MUL
	Sd  1, ANON_313_15_L117_R_info.SIZ
	LVA 1, ANON_313_15_L117_R_info.SIZ
	Sa  1, ANON_313_15_L117_R__u
	La  1, ANON_313_15_L117_R_disp
	La  1, ANON_313_15_L117_G_len
	La  1, ANON_313_15_L117_G_data
	BLKMOV
	La  1, ANON_313_15_L117_R_disp
	La  1, ANON_313_15_L117_G_len
	ADD
	La  1, ANON_313_84_L117_D_len
	La  1, ANON_313_84_L117_D_data
	BLKMOV
	LVA 1, ANON_313_15_L117_R_disp
	CALL	STANDARD.TEXT_IO. ,PUT_LINE_L60
	LCA	STANDARD.PROGRAM_ERROR__exc.data_ptr
	Sa	0, STANDARD.EXCEPTIONS_CURRENT_disp
	BRA	STANDARD.exc_raise_
ret_lbl:
	UNLINK 1
	RTD	prm_siz
excep:
endPRO					;---------- end PRO D
end if

</pre>

## appel dans FIX_PRE.WALK
<pre>
 hexa_show 'var elab BLTN_OPERATOR_ID ', $
VAR BLTN_OPERATOR_ID_disp, q			; variable record : pointeur aux data record
VAR BLTN_OPERATOR_ID__u, q			; variable record : pointeur aux useinfo
VAR BLTN_OPERATOR_ID__dat, STANDARD.IDL._TREE.size
	LVA	4, BLTN_OPERATOR_ID__dat
	Sa	4, BLTN_OPERATOR_ID_disp			; record fin
	LVA	4, STANDARD.IDL._TREE.SIZ
	Sa	4, BLTN_OPERATOR_ID__u
	La  4, BLTN_OPERATOR_ID_disp
	LI	STANDARD.IDL._TREE.size
VAR	ANON_398_37_disp, q
VAR	ANON_398_37__u,    q
VAR	ANON_398_37__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_398_37__dat
	Sa  4, ANON_398_37_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_398_37__u
	LVA 4, ANON_398_37_disp
					; doublet resultat record anonyme
VAR	ANON_398_44_disp, q
VAR	ANON_398_44__u,    q
VAR	ANON_398_44__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_398_44__dat
	Sa  4, ANON_398_44_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_398_44__u
	LVA 4, ANON_398_44_disp
					; doublet resultat record anonyme
VAR	ANON_398_51_disp, q
VAR	ANON_398_51__u,    q
VAR	ANON_398_51__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_398_51__dat
	Sa  4, ANON_398_51_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_398_51__u
	LVA 4, ANON_398_51_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  13
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL. ,LIST_L22
	CALL	STANDARD.IDL.IDL_MAN. ,HEAD_L31
	La
	BLKMOV

 hexa_show ' disp ', BLTN_OPERATOR_ID_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
	La  3,	-REGION_ofs
	La  3,	-NODE_ofs
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.GENERAL_ASSOC_S_disp	; array actual
	CALL	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611. ,WALK_L42
					; debut if
	LI	0					; lieu resultat sur pile
VAR	ANON_403_28_disp, q
VAR	ANON_403_28__u,    q
VAR	ANON_403_28__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_403_28__dat
	Sa  4, ANON_403_28_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_403_28__u
	LVA 4, ANON_403_28_disp
					; doublet resultat record anonyme
VAR	ANON_403_35_disp, q
VAR	ANON_403_35__u,    q
VAR	ANON_403_35__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_403_35__dat
	Sa  4, ANON_403_35_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_403_35__u
	LVA 4, ANON_403_35_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.GENERAL_ASSOC_S_disp	; array actual
	CALL	STANDARD.IDL. ,LIST_L22
	CALL	STANDARD.IDL.IDL_MAN. ,TAIL_L32
	CALL	STANDARD.IDL. ,IS_EMPTY_L23
	LI	1
	OUX
	BF	L121
	LVA 4,	PARAM2_disp
	La
	LI	STANDARD.IDL._TREE.size
VAR	ANON_404_14_disp, q
VAR	ANON_404_14__u,    q
VAR	ANON_404_14__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_404_14__dat
	Sa  4, ANON_404_14_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_404_14__u
	LVA 4, ANON_404_14_disp
					; doublet resultat record anonyme
VAR	ANON_404_21_disp, q
VAR	ANON_404_21__u,    q
VAR	ANON_404_21__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_404_21__dat
	Sa  4, ANON_404_21_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_404_21__u
	LVA 4, ANON_404_21_disp
					; doublet resultat record anonyme
VAR	ANON_404_28_disp, q
VAR	ANON_404_28__u,    q
VAR	ANON_404_28__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_404_28__dat
	Sa  4, ANON_404_28_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_404_28__u
	LVA 4, ANON_404_28_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.GENERAL_ASSOC_S_disp	; array actual
	CALL	STANDARD.IDL. ,LIST_L22
	CALL	STANDARD.IDL.IDL_MAN. ,TAIL_L32
	CALL	STANDARD.IDL.IDL_MAN. ,HEAD_L31
	La
	BLKMOV
	BRA	L120
L121:
L120:					; post if
					; debut if
; CODE record equality "=" _TREE
	LVA 4,	PARAM2_disp
	La  ,  0
	Ld
	LVA 0,	STANDARD.IDL.TREE_VOID_disp
	La  ,  0
	Ld
	CEQ
	LI	0					; lieu resultat sur pile
	LVA 4,	BLTN_OPERATOR_ID_disp
	LI  152
	CALL	STANDARD.IDL. ,DI_L21
	ULb	1, STANDARD.IDL.SEM_PHASE_L11.PRENAME._CLASS_UNARY_OP.FST
	CGE
	ULb	1, STANDARD.IDL.SEM_PHASE_L11.PRENAME._CLASS_UNARY_OP.LST
	LI	0					; lieu resultat sur pile
	LVA 4,	BLTN_OPERATOR_ID_disp
	LI  152
	CALL	STANDARD.IDL. ,DI_L21
	CGE
	ET
	OUX
	BF	L123
	LVA 4,	BLTN_OPERATOR_ID_disp
	La
	LI	STANDARD.IDL._TREE.size
VAR	ANON_408_24_disp, q
VAR	ANON_408_24__u,    q
VAR	ANON_408_24__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_408_24__dat
	Sa  4, ANON_408_24_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_408_24__u
	LVA 4, ANON_408_24_disp
					; doublet resultat record anonyme
VAR	ANON_408_31_disp, q
VAR	ANON_408_31__u,    q
VAR	ANON_408_31__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_408_31__dat
	Sa  4, ANON_408_31_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_408_31__u
	LVA 4, ANON_408_31_disp
					; doublet resultat record anonyme
VAR	ANON_408_38_disp, q
VAR	ANON_408_38__u,    q
VAR	ANON_408_38__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_408_38__dat
	Sa  4, ANON_408_38_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_408_38__u
	LVA 4, ANON_408_38_disp
					; doublet resultat record anonyme
VAR	ANON_408_45_disp, q
VAR	ANON_408_45__u,    q
VAR	ANON_408_45__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_408_45__dat
	Sa  4, ANON_408_45_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_408_45__u
	LVA 4, ANON_408_45_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  13
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL. ,LIST_L22
	CALL	STANDARD.IDL.IDL_MAN. ,TAIL_L32
	CALL	STANDARD.IDL.IDL_MAN. ,HEAD_L31
	La
	BLKMOV
	BRA	L122
L123:
L122:					; post if
VAR	ANON_411_29_disp, q
VAR	ANON_411_29__u,    q
VAR	ANON_411_29__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_411_29__dat
	Sa  4, ANON_411_29_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_411_29__u
	LVA 4, ANON_411_29_disp
					; doublet resultat record anonyme
	LVA 4,	BLTN_OPERATOR_ID_disp
VAR	ANON_413_17_disp, q
VAR	ANON_413_17__u,    q
VAR	ANON_413_17__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_413_17__dat
	Sa  4, ANON_413_17_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_413_17__u
	LVA 4, ANON_413_17_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  13
	CALL	STANDARD.IDL. ,D_L17
VAR	ANON_413_52_disp, q
VAR	ANON_413_52__u,    q
VAR	ANON_413_52__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_413_52__dat
	Sa  4, ANON_413_52_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_413_52__u
	LVA 4, ANON_413_52_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  154
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.SEM_PHASE_L11.MAKE_NOD. ,MAKE_USED_OP_L349
	La  3,	-NODE_ofs
	LI  48
	CALL	STANDARD.IDL. ,D_L16
					; debut if
; CODE composite "=" _STRING
VAR	ANON_417_13_L126_G_data, q
VAR	ANON_417_13_L126_G_info, q
VAR	ANON_417_13_L126_G_len,  q
VAR	ANON_417_13_disp, q
VAR	ANON_417_13__u,   q
namespace ANON_417_13_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 4, ANON_417_13_info.SIZ
	Sa  4, ANON_417_13__u
	LVA 4, ANON_417_13_disp
VAR	ANON_417_26_disp, q
VAR	ANON_417_26__u,    q
VAR	ANON_417_26__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_417_26__dat
	Sa  4, ANON_417_26_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_417_26__u
	LVA 4, ANON_417_26_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  13
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL. ,PRINT_NAME_L25
	DUP
	La  ,  0
	Sa  4, ANON_417_13_L126_G_data
	La  ,  8
	Sa  4, ANON_417_13_L126_G_info
	LId 4, ANON_417_13_L126_G_info, STANDARD._STRING.LST_1
	LId 4, ANON_417_13_L126_G_info, STANDARD._STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_417_13_L126_G_len
VAR	ANON_417_52_L126_D_data, q
VAR	ANON_417_52_L126_D_info, q
VAR	ANON_417_52_L126_D_len,  q
STR ANON_417_52_L126_D, """-"""		; constante string="""-"""
	LCA	ANON_417_52_L126_D.data_ptr
	DUP
	La  ,  0
	Sa  4, ANON_417_52_L126_D_data
	La  ,  8
	Sa  4, ANON_417_52_L126_D_info
	LId 4, ANON_417_52_L126_D_info, STANDARD._STRING.LST_1
	LId 4, ANON_417_52_L126_D_info, STANDARD._STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_417_52_L126_D_len
	La  4, ANON_417_13_L126_G_len
	La  4, ANON_417_52_L126_D_len
	CEQ
	DUP
	BF	L127
	DROP
	La  4, ANON_417_13_L126_G_data
	La  4, ANON_417_13_L126_G_len
	La  4, ANON_417_52_L126_D_data
	BLKCMP
L127:
	BF	L125
					; debut if
; CODE record equality "=" _TREE
	LVA 4,	PARAM2_disp
	La  ,  0
	Ld
	LVA 0,	STANDARD.IDL.TREE_VOID_disp
	La  ,  0
	Ld
	CEQ
	BF	L129
VAR	ANON_419_27_disp, q
VAR	ANON_419_27__u,    q
VAR	ANON_419_27__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_419_27__dat
	Sa  4, ANON_419_27_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_419_27__u
	LVA 4, ANON_419_27_disp
					; doublet resultat record anonyme
VAR	ANON_419_28_disp, q
VAR	ANON_419_28__u,    q
VAR	ANON_419_28__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_419_28__dat
	Sa  4, ANON_419_28_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_419_28__u
	LVA 4, ANON_419_28_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.SEM_PHASE_L11.UARITH. ,_MINUS__L39
	La  3,	-NODE_ofs
	LI  88
	CALL	STANDARD.IDL. ,D_L16
	BRA	L128
L129:
VAR	ANON_421_27_disp, q
VAR	ANON_421_27__u,    q
VAR	ANON_421_27__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_421_27__dat
	Sa  4, ANON_421_27_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_421_27__u
	LVA 4, ANON_421_27_disp
					; doublet resultat record anonyme
VAR	ANON_421_51_disp, q
VAR	ANON_421_51__u,    q
VAR	ANON_421_51__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_421_51__dat
	Sa  4, ANON_421_51_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_421_51__u
	LVA 4, ANON_421_51_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM2_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
VAR	ANON_421_27_disp, q
VAR	ANON_421_27__u,    q
VAR	ANON_421_27__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_421_27__dat
	Sa  4, ANON_421_27_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_421_27__u
	LVA 4, ANON_421_27_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.SEM_PHASE_L11.UARITH. ,_MINUS__L42
	La  3,	-NODE_ofs
	LI  88
	CALL	STANDARD.IDL. ,D_L16
L128:					; post if
	BRA	L124
L125:
; CODE composite "=" _STRING
VAR	ANON_423_16_L131_G_data, q
VAR	ANON_423_16_L131_G_info, q
VAR	ANON_423_16_L131_G_len,  q
VAR	ANON_423_16_disp, q
VAR	ANON_423_16__u,   q
namespace ANON_423_16_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 4, ANON_423_16_info.SIZ
	Sa  4, ANON_423_16__u
	LVA 4, ANON_423_16_disp
VAR	ANON_423_29_disp, q
VAR	ANON_423_29__u,    q
VAR	ANON_423_29__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_423_29__dat
	Sa  4, ANON_423_29_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_423_29__u
	LVA 4, ANON_423_29_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  13
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL. ,PRINT_NAME_L25
	DUP
	La  ,  0
	Sa  4, ANON_423_16_L131_G_data
	La  ,  8
	Sa  4, ANON_423_16_L131_G_info
	LId 4, ANON_423_16_L131_G_info, STANDARD._STRING.LST_1
	LId 4, ANON_423_16_L131_G_info, STANDARD._STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_423_16_L131_G_len
VAR	ANON_423_55_L131_D_data, q
VAR	ANON_423_55_L131_D_info, q
VAR	ANON_423_55_L131_D_len,  q
STR ANON_423_55_L131_D, """*"""		; constante string="""*"""
	LCA	ANON_423_55_L131_D.data_ptr
	DUP
	La  ,  0
	Sa  4, ANON_423_55_L131_D_data
	La  ,  8
	Sa  4, ANON_423_55_L131_D_info
	LId 4, ANON_423_55_L131_D_info, STANDARD._STRING.LST_1
	LId 4, ANON_423_55_L131_D_info, STANDARD._STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_423_55_L131_D_len
	La  4, ANON_423_16_L131_G_len
	La  4, ANON_423_55_L131_D_len
	CEQ
	DUP
	BF	L132
	DROP
	La  4, ANON_423_16_L131_G_data
	La  4, ANON_423_16_L131_G_len
	La  4, ANON_423_55_L131_D_data
	BLKCMP
L132:
	BF	L130
VAR	ANON_424_24_disp, q
VAR	ANON_424_24__u,    q
VAR	ANON_424_24__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_424_24__dat
	Sa  4, ANON_424_24_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_424_24__u
	LVA 4, ANON_424_24_disp
					; doublet resultat record anonyme
VAR	ANON_424_48_disp, q
VAR	ANON_424_48__u,    q
VAR	ANON_424_48__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_424_48__dat
	Sa  4, ANON_424_48_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_424_48__u
	LVA 4, ANON_424_48_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM2_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
VAR	ANON_424_24_disp, q
VAR	ANON_424_24__u,    q
VAR	ANON_424_24__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_424_24__dat
	Sa  4, ANON_424_24_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_424_24__u
	LVA 4, ANON_424_24_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.SEM_PHASE_L11.UARITH. ,_MUL__L43
	La  3,	-NODE_ofs
	LI  88
	CALL	STANDARD.IDL. ,D_L16
	BRA	L124
L130:
; CODE composite "=" _STRING
VAR	ANON_426_16_L134_G_data, q
VAR	ANON_426_16_L134_G_info, q
VAR	ANON_426_16_L134_G_len,  q
VAR	ANON_426_16_disp, q
VAR	ANON_426_16__u,   q
namespace ANON_426_16_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 4, ANON_426_16_info.SIZ
	Sa  4, ANON_426_16__u
	LVA 4, ANON_426_16_disp
VAR	ANON_426_29_disp, q
VAR	ANON_426_29__u,    q
VAR	ANON_426_29__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_426_29__dat
	Sa  4, ANON_426_29_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_426_29__u
	LVA 4, ANON_426_29_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  13
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL. ,PRINT_NAME_L25
	DUP
	La  ,  0
	Sa  4, ANON_426_16_L134_G_data
	La  ,  8
	Sa  4, ANON_426_16_L134_G_info
	LId 4, ANON_426_16_L134_G_info, STANDARD._STRING.LST_1
	LId 4, ANON_426_16_L134_G_info, STANDARD._STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_426_16_L134_G_len
VAR	ANON_426_55_L134_D_data, q
VAR	ANON_426_55_L134_D_info, q
VAR	ANON_426_55_L134_D_len,  q
STR ANON_426_55_L134_D, """**"""		; constante string="""**"""
	LCA	ANON_426_55_L134_D.data_ptr
	DUP
	La  ,  0
	Sa  4, ANON_426_55_L134_D_data
	La  ,  8
	Sa  4, ANON_426_55_L134_D_info
	LId 4, ANON_426_55_L134_D_info, STANDARD._STRING.LST_1
	LId 4, ANON_426_55_L134_D_info, STANDARD._STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_426_55_L134_D_len
	La  4, ANON_426_16_L134_G_len
	La  4, ANON_426_55_L134_D_len
	CEQ
	DUP
	BF	L135
	DROP
	La  4, ANON_426_16_L134_G_data
	La  4, ANON_426_16_L134_G_len
	La  4, ANON_426_55_L134_D_data
	BLKCMP
L135:
	BF	L133
VAR	ANON_427_24_disp, q
VAR	ANON_427_24__u,    q
VAR	ANON_427_24__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_427_24__dat
	Sa  4, ANON_427_24_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_427_24__u
	LVA 4, ANON_427_24_disp
					; doublet resultat record anonyme
VAR	ANON_427_49_disp, q
VAR	ANON_427_49__u,    q
VAR	ANON_427_49__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_427_49__dat
	Sa  4, ANON_427_49_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_427_49__u
	LVA 4, ANON_427_49_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM2_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
VAR	ANON_427_24_disp, q
VAR	ANON_427_24__u,    q
VAR	ANON_427_24__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_427_24__dat
	Sa  4, ANON_427_24_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_427_24__u
	LVA 4, ANON_427_24_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.SEM_PHASE_L11.UARITH. ,_POW__L47
	La  3,	-NODE_ofs
	LI  88
	CALL	STANDARD.IDL. ,D_L16
	BRA	L124
L133:
; CODE & concat _STRING
VAR	ANON_430_16_L136_G_data, q
VAR	ANON_430_16_L136_G_info, q
VAR	ANON_430_44_L136_D_data, q
VAR	ANON_430_44_L136_D_info, q
VAR	ANON_430_16_L136_G_len,  q
VAR	ANON_430_44_L136_D_len,  q
VAR	ANON_430_16_L136_R_disp, q
VAR	ANON_430_16_L136_R__u,   q
namespace ANON_430_16_L136_R_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
STR ANON_430_16_L136_G, "FUNCTION NOT ALLOWED - "	; constante string="FUNCTION NOT ALLOWED - "
	LCA	ANON_430_16_L136_G.data_ptr
	DUP
	La  ,  0
	Sa  4, ANON_430_16_L136_G_data
	La  ,  8
	Sa  4, ANON_430_16_L136_G_info
	LId 4, ANON_430_16_L136_G_info, _STRING.LST_1
	LId 4, ANON_430_16_L136_G_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_430_16_L136_G_len
VAR	ANON_430_44_disp, q
VAR	ANON_430_44__u,   q
namespace ANON_430_44_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 4, ANON_430_44_info.SIZ
	Sa  4, ANON_430_44__u
	LVA 4, ANON_430_44_disp
VAR	ANON_430_57_disp, q
VAR	ANON_430_57__u,    q
VAR	ANON_430_57__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_430_57__dat
	Sa  4, ANON_430_57_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_430_57__u
	LVA 4, ANON_430_57_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.NAME_disp	; array actual
	LI  13
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL. ,PRINT_NAME_L25
	DUP
	La  ,  0
	Sa  4, ANON_430_44_L136_D_data
	La  ,  8
	Sa  4, ANON_430_44_L136_D_info
	LId 4, ANON_430_44_L136_D_info, _STRING.LST_1
	LId 4, ANON_430_44_L136_D_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  4, ANON_430_44_L136_D_len
	La  4, ANON_430_16_L136_G_len
	La  4, ANON_430_44_L136_D_len
	ADD
	CO_VAR
	Sa  4, ANON_430_16_L136_R_disp
	LI	1
	Sd  4, ANON_430_16_L136_R_info._FST_1
	La  4, ANON_430_16_L136_G_len
	La  4, ANON_430_44_L136_D_len
	ADD
	Sd  4, ANON_430_16_L136_R_info._LST_1
	LI	8
	Sd  4, ANON_430_16_L136_R_info._COMP_SIZ
	La  4, ANON_430_16_L136_G_len
	La  4, ANON_430_44_L136_D_len
	ADD
	LI	8
	MUL
	Sd  4, ANON_430_16_L136_R_info.SIZ
	LVA 4, ANON_430_16_L136_R_info.SIZ
	Sa  4, ANON_430_16_L136_R__u
	La  4, ANON_430_16_L136_R_disp
	La  4, ANON_430_16_L136_G_len
	La  4, ANON_430_16_L136_G_data
	BLKMOV
	La  4, ANON_430_16_L136_R_disp
	La  4, ANON_430_16_L136_G_len
	ADD
	La  4, ANON_430_44_L136_D_len
	La  4, ANON_430_44_L136_D_data
	BLKMOV
	LVA 4, ANON_430_16_L136_R_disp
	CALL	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611. ,ABORT_RUN_L10
	LCA	STANDARD.PROGRAM_ERROR__exc.data_ptr
	Sa	0, STANDARD.EXCEPTIONS_CURRENT_disp
	BRA	STANDARD.exc_raise_
L124:					; post if
VAR	ANON_434_33_disp, q
VAR	ANON_434_33__u,    q
VAR	ANON_434_33__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_434_33__dat
	Sa  4, ANON_434_33_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_434_33__u
	LVA 4, ANON_434_33_disp
					; doublet resultat record anonyme
VAR	ANON_434_49_disp, q
VAR	ANON_434_49__u,    q
VAR	ANON_434_49__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_434_49__dat
	Sa  4, ANON_434_49_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_434_49__u
	LVA 4, ANON_434_49_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM_disp
	LI  87
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611. ,GET_BASE_TYPE_L28
	La  3,	-NODE_ofs
	LI  87
	CALL	STANDARD.IDL. ,D_L16
VAR	ANON_435_43_disp, q
VAR	ANON_435_43__u,    q
VAR	ANON_435_43__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_435_43__dat
	Sa  4, ANON_435_43_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_435_43__u
	LVA 4, ANON_435_43_disp
					; doublet resultat record anonyme
VAR	ANON_437_17_disp, q
VAR	ANON_437_17__u,    q
VAR	ANON_437_17__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_437_17__dat
	Sa  4, ANON_437_17_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_437_17__u
	LVA 4, ANON_437_17_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.GENERAL_ASSOC_S_disp	; array actual
	LI  154
	CALL	STANDARD.IDL. ,D_L17
VAR	ANON_436_12_disp, q
VAR	ANON_436_12__u,    q
VAR	ANON_436_12__dat, STANDARD.IDL._SEQ_TYPE.size
	LVA 4, ANON_436_12__dat
	Sa  4, ANON_436_12_disp
	La  0, STANDARD.IDL._SEQ_TYPE.use__info
	Sa  4, ANON_436_12__u
	LVA 4, ANON_436_12_disp
					; doublet resultat record anonyme
	LVA  4,	STANDARD.IDL.SEM_PHASE_L11.FIX_PRE_L611.WALK_L42.BLOCK__18.GENERAL_ASSOC_S_disp	; array actual
	CALL	STANDARD.IDL. ,LIST_L22
	CALL	STANDARD.IDL.SEM_PHASE_L11.MAKE_NOD. ,MAKE_EXP_S_L311
	La  3,	-NODE_ofs
	LI  124
	CALL	STANDARD.IDL. ,D_L16
	UNLINK 4
endPRO
	BRA	L45
L69:
	DROP
namespace	BLOCK__19
ELB 4					;    BODY ELAB
 hexa_show 'var elab VALUE ', $
VAR VALUE_disp, q				; variable record : pointeur aux data record
VAR VALUE__u, q				; variable record : pointeur aux useinfo
VAR VALUE__dat, STANDARD.IDL._TREE.size
	LVA	4, VALUE__dat
	Sa	4, VALUE_disp				; record fin
	LVA	4, STANDARD.IDL._TREE.SIZ
	Sa	4, VALUE__u
	La  4, VALUE_disp
	LI	STANDARD.IDL._TREE.size
VAR	ANON_446_26_disp, q
VAR	ANON_446_26__u,    q
VAR	ANON_446_26__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_446_26__dat
	Sa  4, ANON_446_26_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_446_26__u
	LVA 4, ANON_446_26_disp
					; doublet resultat record anonyme
VAR	ANON_446_42_disp, q
VAR	ANON_446_42__u,   q
namespace ANON_446_42_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 4, ANON_446_42_info.SIZ
	Sa  4, ANON_446_42__u
	LVA 4, ANON_446_42_disp
VAR	ANON_446_54_disp, q
VAR	ANON_446_54__u,    q
VAR	ANON_446_54__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_446_54__dat
	Sa  4, ANON_446_54_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_446_54__u
	LVA 4, ANON_446_54_disp
					; doublet resultat record anonyme
	La  3,	-NODE_ofs
	LI  96
	CALL	STANDARD.IDL. ,D_L17
	CALL	STANDARD.IDL. ,PRINT_NAME_L25
	CALL	STANDARD.IDL.SEM_PHASE_L11.UARITH. ,U_VALUE_L22
	La
	BLKMOV
</pre>