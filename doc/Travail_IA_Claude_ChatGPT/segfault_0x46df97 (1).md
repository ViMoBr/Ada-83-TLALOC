 
#INSTRUCTION SEGFAULT 0x46df97
 <pre>
 (gdb) x/16i $rip-32
   0x46df77:    mov    %rax,0x8(%rbp)
   0x46df7b:    lea    0x8(%rbp),%rbp
   0x46df7f:    mov    0x18(%r15),%rax
   0x46df83:    mov    -0x8(%rax),%rax
   0x46df87:    mov    %rax,0x8(%rbp)
   0x46df8b:    lea    0x8(%rbp),%rbp
   0x46df8f:    mov    0x0(%rbp),%rax
   0x46df93:    lea    -0x8(%rbp),%rbp
=> 0x46df97:    mov    (%rax),%rax
   0x46df9a:    mov    %rax,0x8(%rbp)
   0x46df9e:    lea    0x8(%rbp),%rbp
   0x46dfa2:    mov    0x0(%rbp),%rsi
   0x46dfa6:    lea    -0x8(%rbp),%rbp
   0x46dfaa:    mov    0x0(%rbp),%rcx
   0x46dfae:    lea    -0x8(%rbp),%rbp
   0x46dfb2:    mov    0x0(%rbp),%rdi

</pre>

#REGISTRES AU SEGFAULT
<pre>
rax            0x18                24                 rbx            0x8                 8                  │
│rcx            0x7                 7                  rdx            0x0                 0                  │
│rsi            0x7fffffc06afc      140737484188412    rdi            0x7fffffc06ae4      140737484188388    │
│rbp            0x7fffffc06c18      0x7fffffc06c18     rsp            0x7fffffbfdad0      0x7fffffbfdad0     │
│r8             0xffffffffffffffff  -1                 r9             0x0                 0                  │
│r10            0x22                34                 r11            0x246               582                │
│r12            0x7ffff7df3800      140737351989248    r13            0xd6fdf8            14089720           │
│r14            0xd6fe00            14089728           r15            0x7fffffbfdaf0      140737484151536    │
│rip            0x46df97            0x46df97           eflags         0x10206             [ PF IF RF ]       │
</pre>

#STACK AU SEGFAULT
<pre>

</pre>
#BACKTRACE ET MAP
<pre>
(gdb) bt
#0  0x000000000046df97 in ?? ()
PRINT_NAME_L25 0x000000000046D106
var elab TR 0x000000000046D127
 disp 0x0000000000000008
var elab TXT_HDR 0x000000000046D49E
 disp 0x0000000000000008
var elab START 0x000000000046D62F
 disp 0x0000000000000034
var elab NB_TREES 0x000000000046D74B
 disp 0x0000000000000035
var elab NB_CARS 0x000000000046D8C7
 disp 0x0000000000000038
 -----------------------
TO_CHN_L186 0x000000000046DEFF
var elab THE_CHN 0x000000000046DFDD
 disp 0x00000000000000C8
-----------------------
#1  0x000000000046e228 in ?? ()
var elab THE_CHN 0x000000000046DFDD
 disp 0x00000000000000C8
lPRINT_NUM_L26 0x000000000046EBAF

#2  0x0000000000646212 in ?? ()
var elab COL 0x0000000000645D4E
 disp 0x000000000000001C
including sub body IDL-ERR_PHASE.FINC
WRITE_LIB_L13 0x00000000006465A6

#3  0x0000000000d179b1 in ?? ()
#4  0x0000000000d18437 in ?? ()

</pre>

#SOURCE ADA 83 SECTION IDL
<pre>
  function		PRINT_NAME	( T :TREE ) return STRING					--| POUR TXTREP OR SYMBOL_REP
  is			----------

    TR		: TREE	:= T;
  begin
    if TR.TY = DN_SYMBOL_REP then									--| POUR UN SYMBOL_REP
      TR := DABS( 1, TR );										--| PRENDRE LE TXTREP CORRRESPONDANT
    end if;

   if TR.TY = DN_TXTREP then										--| SI CE N'EST PAS UN TXTREP
    declare
      TXT_HDR		: TREE		:= DABS( 0, TR );						--| PRENDRE L'ENTETE DU BLOC DE CHAINE
      use SYSTEM;
      START		: LINE_IDX	:= TR.LN+1;						--| EMPLACEMENT DU PREMIER TREE COMPRENANT LE NOM
      NB_TREES		: LINE_IDX	:= LINE_IDX( TXT_HDR.NSIZ );					--| NOMBRE DE TREES COMPRENANT LE NOM
      NB_CARS		: NATURAL		:= NATURAL( NB_TREES )
					   *(TREE'SIZE+STORAGE_UNIT-1)/STORAGE_UNIT;
      type SUITE_TREES	is array( START .. START-1+NB_TREES ) of TREE;
      subtype CHN		is STRING( 1 .. NB_CARS );
      ----------------------------------
      function TO_CHN	is new UNCHECKED_CONVERSION( SUITE_TREES, CHN );
      ---------------------------------
      THE_CHN		: CHN;
    begin
      THE_CHN := TO_CHN( SUITE_TREES( PAG( CUR_RP ).DATA.all( START..START-1+NB_TREES ) ) );
      return THE_CHN( 2..1+NATURAL( CHARACTER'POS( THE_CHN( 1 ) ) ) );
    end;
    end if;

    PUT_LINE( "; PAS UN TXTREP/NUM_VAL PAS DE CHAINE ! " & NODE_NAME'IMAGE( TR.TY ) );				--| CHAINE PAS DE NOM
    raise PROGRAM_ERROR;

  end	PRINT_NAME;

</pre>

#SECTION LLIR IDL.FINC
<pre>
if defined PRINT_NAME_L25_
PRO	PRINT_NAME_L25				;---------- PRO PRINT_NAME
 hexa_show 'PRINT_NAME_L25 ', $
PRMS					;    debut parametrage
	PRM T_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 1					;    BODY ELAB
 hexa_show 'var elab TR ', $
VAR TR_disp, q				; variable record : pointeur aux data record
VAR TR__u, q				; variable record : pointeur aux useinfo
VAR TR__dat, STANDARD.IDL._TREE.size
	LVA	1, TR__dat
	Sa	1, TR_disp				; record fin
	LVA	1, STANDARD.IDL._TREE.SIZ
	Sa	1, TR__u
; CODE_VC_NAME DN_VARIABLE_ID
	La  1, TR_disp
	LI	STANDARD.IDL._TREE.size
	La  1,	-T_ofs
	La  ,  0
	BLKMOV

 hexa_show ' disp ', TR_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
					; debut if
	La	1, STANDARD.IDL.PRINT_NAME_L25.TR_disp
	Ld
	LI	24
	LI	8
	UBFX
	LI	9
	CEQ
	BF	L183
	LVA 1,	TR_disp
	La
	LI	STANDARD.IDL._TREE.size
VAR	ANON_485_13_disp, q
VAR	ANON_485_13__u,    q
VAR	ANON_485_13__dat, STANDARD.IDL._TREE.size
	LVA 1, ANON_485_13__dat
	Sa  1, ANON_485_13_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  1, ANON_485_13__u
	LVA 1, ANON_485_13_disp
					; doublet resultat record anonyme
	LVA 1,	TR_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.LST
	CGT
	BT	STANDARD.ce_raise_
	CALL	STANDARD.IDL.IDL_MAN. ,DABS_L38
	La  ,  0
	BLKMOV
	BRA	L182
L183:
L182:					; post if
					; debut if
	La	1, STANDARD.IDL.PRINT_NAME_L25.TR_disp
	Ld
	LI	24
	LI	8
	UBFX
	LI	1
	CEQ
	BF	L185
namespace	BLOCK__11
ELB 2					;    BODY ELAB
 hexa_show 'var elab TXT_HDR ', $
VAR TXT_HDR_disp, q				; variable record : pointeur aux data record
VAR TXT_HDR__u, q				; variable record : pointeur aux useinfo
VAR TXT_HDR__dat, STANDARD.IDL._TREE.size
	LVA	2, TXT_HDR__dat
	Sa	2, TXT_HDR_disp				; record fin
	LVA	2, STANDARD.IDL._TREE.SIZ
	Sa	2, TXT_HDR__u
; CODE_VC_NAME DN_VARIABLE_ID
	La  2, TXT_HDR_disp
	LI	STANDARD.IDL._TREE.size
VAR	ANON_490_27_disp, q
VAR	ANON_490_27__u,    q
VAR	ANON_490_27__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_490_27__dat
	Sa  2, ANON_490_27_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_490_27__u
	LVA 2, ANON_490_27_disp
					; doublet resultat record anonyme
	LVA 1,	STANDARD.IDL.PRINT_NAME_L25.TR_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.LST
	CGT
	BT	STANDARD.ce_raise_
	CALL	STANDARD.IDL.IDL_MAN. ,DABS_L38
	La  ,  0
	BLKMOV

 hexa_show ' disp ', TXT_HDR_disp
 hexa_show 'var elab START ', $
VAR START_disp, b				; variable entiere
	La	1, STANDARD.IDL.PRINT_NAME_L25.TR_disp
	Ld
	LI	2
	LI	7
	UBFX
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	ADD
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.LST
	CGT
	BT	STANDARD.ce_raise_
	Sb  2,	START_disp

 hexa_show ' disp ', START_disp
 hexa_show 'var elab NB_TREES ', $
VAR NB_TREES_disp, b			; variable entiere
	La	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.TXT_HDR_disp
	Ld
	LI	2
	LI	7
	UBFX
; CODE CONVERSION SOURCE DN_INTEGER TARGET DN_INTEGER
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.LST
	CGT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	ULb	0, STANDARD.IDL._ATTR_NBR.LST
	CGT
	BT	STANDARD.ce_raise_
	Sb  2,	NB_TREES_disp

 hexa_show ' disp ', NB_TREES_disp
 hexa_show 'var elab NB_CARS ', $
VAR NB_CARS_disp, d				; variable entiere
	ULb 2,	NB_TREES_disp
; CODE CONVERSION SOURCE DN_INTEGER TARGET DN_INTEGER
	DUP
	Ld	0, STANDARD._NATURAL.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	Ld	0, STANDARD._NATURAL.LST
	CGT
	BT	STANDARD.ce_raise_
	LId	 0, STANDARD.IDL._TREE.use__info
; CODE_NUMERIC_LITERAL DN_UNIVERSAL_INTEGER
	LI	8
	ADD
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	SUB
	MUL
; CODE_NUMERIC_LITERAL DN_UNIVERSAL_INTEGER
	LI	8
	DUP
	LI	0
	CEQ
	BT	STANDARD.ne_raise_
	DIV
	DUP
	Ld	0, STANDARD._NATURAL.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	Ld	0, STANDARD._NATURAL.LST
	CGT
	BT	STANDARD.ce_raise_
	Sd  2,	NB_CARS_disp

 hexa_show ' disp ', NB_CARS_disp

					; array decl constrained array type info
_SUITE_TREES = '_SUITE_TREES'
namespace _SUITE_TREES
VAR use__info, q
VAR SIZ, d
	LVA	2, SIZ
	Sa	2, use__info
VAR _COMP_SIZ, d
VAR _FST_1, d
VAR _LST_1, d
	LI	32
	Sd	2, _COMP_SIZ
	Ld	2, _COMP_SIZ
	ULb 2,	START_disp
	Sd	2, _FST_1
	ULb 2,	START_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	SUB
	ULb 2,	NB_TREES_disp
	ADD
	Sd	2, _LST_1
	Ld	2, _LST_1
	Ld	2, _FST_1
	SUB
	INC
	CLAMP0
	MUL
	Sd	2, SIZ
  virtual at 4
COMP_SIZ = $
	rd 1 
FST_1 = $
	rd 1 
LST_1 = $
	rd 1 
  end virtual
end namespace
_CHN = '_CHN'
namespace _CHN				; _CHN CONSTRAINED ARRAY SUBTYPE INFO
VAR use__info, q
VAR SIZ, d
	LVA	2, SIZ
	Sa	2, use__info
VAR _COMP_SIZ, d
VAR _FST_1, d
VAR _LST_1, d
	LI	8
	Sd	2, _COMP_SIZ
	Ld	2, _COMP_SIZ
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	Sd	2, _FST_1
	Ld 2,	NB_CARS_disp
	Sd	2, _LST_1
	Ld	2, _LST_1
	Ld	2, _FST_1
	SUB
	INC
	CLAMP0
	MUL
	Sd	2, SIZ
  virtual at 4
COMP_SIZ = $
	rd 1 
FST_1 = $
	rd 1 
LST_1 = $
	rd 1 
  end virtual
end namespace
					; sub program entry decl (in instantiation FALSE )
if defined TO_CHN_L186_
; F4A SET  cle=SOURCE  actuel=DN_CONSTRAINED_ARRAY
BRA post_LD_TO_CHN_L186SOURCE
LD_TO_CHN_L186SOURCE.elab:
	LI 0
	RTD 0
post_LD_TO_CHN_L186SOURCE:
BRA post_ST_TO_CHN_L186SOURCE
ST_TO_CHN_L186SOURCE.elab:
	DROP
	RTD 0
post_ST_TO_CHN_L186SOURCE:
BRA post_INADR_TO_CHN_L186SOURCE
INADR_TO_CHN_L186SOURCE.elab:
	LIa
	RTD 0
post_INADR_TO_CHN_L186SOURCE:
BRA post_OUTADR_TO_CHN_L186SOURCE
OUTADR_TO_CHN_L186SOURCE.elab:
	LIa
	RTD 0
post_OUTADR_TO_CHN_L186SOURCE:
VAR TO_CHN_L186SOURCE__outadr_ofs, q
	LCA OUTADR_TO_CHN_L186SOURCE.elab
	Sa	 2, TO_CHN_L186SOURCE__outadr_ofs
VAR TO_CHN_L186SOURCE__inadr_ofs, q
	LCA INADR_TO_CHN_L186SOURCE.elab
	Sa	 2, TO_CHN_L186SOURCE__inadr_ofs
VAR TO_CHN_L186SOURCE__st_ofs, q
	LCA ST_TO_CHN_L186SOURCE.elab
	Sa	 2, TO_CHN_L186SOURCE__st_ofs
VAR TO_CHN_L186SOURCE__ld_ofs, q
	LCA LD_TO_CHN_L186SOURCE.elab
	Sa	 2, TO_CHN_L186SOURCE__ld_ofs
VAR TO_CHN_L186SOURCE__u_ofs, q
	La	 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._SUITE_TREES.use__info
	Sa	 2, TO_CHN_L186SOURCE__u_ofs
; F4A SET  cle=TARGET  actuel=DN_CONSTRAINED_ARRAY
BRA post_LD_TO_CHN_L186TARGET
LD_TO_CHN_L186TARGET.elab:
	LI 0
	RTD 0
post_LD_TO_CHN_L186TARGET:
BRA post_ST_TO_CHN_L186TARGET
ST_TO_CHN_L186TARGET.elab:
	DROP
	RTD 0
post_ST_TO_CHN_L186TARGET:
BRA post_INADR_TO_CHN_L186TARGET
INADR_TO_CHN_L186TARGET.elab:
	LIa
	RTD 0
post_INADR_TO_CHN_L186TARGET:
BRA post_OUTADR_TO_CHN_L186TARGET
OUTADR_TO_CHN_L186TARGET.elab:
	LIa
	RTD 0
post_OUTADR_TO_CHN_L186TARGET:
VAR TO_CHN_L186TARGET__outadr_ofs, q
	LCA OUTADR_TO_CHN_L186TARGET.elab
	Sa	 2, TO_CHN_L186TARGET__outadr_ofs
VAR TO_CHN_L186TARGET__inadr_ofs, q
	LCA INADR_TO_CHN_L186TARGET.elab
	Sa	 2, TO_CHN_L186TARGET__inadr_ofs
VAR TO_CHN_L186TARGET__st_ofs, q
	LCA ST_TO_CHN_L186TARGET.elab
	Sa	 2, TO_CHN_L186TARGET__st_ofs
VAR TO_CHN_L186TARGET__ld_ofs, q
	LCA LD_TO_CHN_L186TARGET.elab
	Sa	 2, TO_CHN_L186TARGET__ld_ofs
VAR TO_CHN_L186TARGET__u_ofs, q
	La	 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.use__info
	Sa	 2, TO_CHN_L186TARGET__u_ofs
VAR GFP_disp, q				; Lieu du Generic Frame Pointer 
PRO	TO_CHN_L186				;---------- PRO TO_CHN
 hexa_show 'TO_CHN_L186 ', $
PRMS					;    debut parametrage
	PRM S_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 3
begin:
	La	3, -result__ofs
	La	, 0
	Ld	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.SIZ
	LI	8
	DIV
	La	3, -S_ofs
	La	, 0
	BLKMOV
	UNLINK	 3
	RTD	prm_siz-8
endPRO					;---------- end PRO TO_CHN
end if
 hexa_show 'var elab THE_CHN ', $
VAR THE_CHN_disp, q				; variable array : pointeur aux data
VAR THE_CHN__u, q				; variable array : useinfo pointeur au rec info
	La 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.use__info
	Sa	2, THE_CHN__u				; array info ptr at __u
	Ld	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.SIZ
	LI	8
	DIV
	CO_VAR
	Sa	2, THE_CHN_disp				; array data ptr at _disp

 hexa_show ' disp ', THE_CHN_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
	LVA 2,	THE_CHN_disp
	La
	LId	2, THE_CHN__u, 0
	LI	8
	DIV
VAR	ANON_501_18_disp, q
VAR	ANON_501_18__u,   q
	La  2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.use__info
	Sa  2, ANON_501_18__u
	Ld  2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.SIZ
	LI	8
	DIV
	CO_VAR
	Sa  2, ANON_501_18_disp
	LVA 2, ANON_501_18_disp
; CODE_SLICE : NAME.TY A FAIRE : DN_ALL
	ULb 2,	START_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	SUB
	ULb 2,	NB_TREES_disp
	ADD
	ULb 2,	START_disp
	SUB
	INC
	CLAMP0
	LI	4
	MUL
; CODE CONVERSION SOURCE DN_ARRAY TARGET DN_CONSTRAINED_ARRAY
; EXPRESSIONS.CODE_CONVERSION cible non faite DN_CONSTRAINED_ARRAY
	CALL	STANDARD.IDL.PRINT_NAME_L25.BLOCK__11. ,TO_CHN_L186
	La  ,  0
	BLKMOV
; CODE_RETURN : EXPR TYPE = DN_ARRAY  VUE COMPLETE = DN_ARRAY
	La 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.THE_CHN_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	2
	LId 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.THE_CHN__u, STANDARD._STRING.FST_1
	SUB
	LI	1
	MUL
	ADD
namespace ANON_502_14			; ensemble doublet @data/@info pour slice anonyme source
VAR ANON_502_14_disp, q
VAR ANON_502_14__u, q
VAR SIZ, d
VAR COMP_SIZ, d
VAR _FST_1, d
VAR _LST_1, d
	Sa	2, ANON_502_14_disp
	LVA	2, SIZ
	Sa	2, ANON_502_14__u
	LI	8
	Sd	2, COMP_SIZ
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	2
	Sd	2, _FST_1
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	La	 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.THE_CHN_disp	; array data start address on stack
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	DUP
	LId	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.THE_CHN__u, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.THE_CHN__u, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.THE_CHN__u, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11.THE_CHN__u, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	ULb
; CODE CONVERSION SOURCE DN_ANY_INTEGER TARGET DN_INTEGER
	DUP
	Ld	0, STANDARD._NATURAL.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	Ld	0, STANDARD._NATURAL.LST
	CGT
	BT	STANDARD.ce_raise_
	ADD
	Sd	2, _LST_1
	Ld	2, _LST_1
	Ld	2, _FST_1
	SUB
	INC
	CLAMP0
	LI	8
	MUL
	Sd	2, SIZ
	LVA	2, ANON_502_14_disp
end namespace
VAR	RET_INFO_L189, q
	DUP
	La  ,  0
	SIq   1, -result__ofs,  0
	DUP
	La  ,  8
	Sa   2, RET_INFO_L189
	DROP
	La   1, -result__ofs
	La  ,  8
	LI	16
	La   2, RET_INFO_L189
	BLKMOV
	UNLINK 2
	BRA ret_lbl
	UNLINK 2
endPRO
	BRA	L184
L185:
L184:					; post if
; CODE & concat _STRING
VAR	ANON_506_15_L190_G_data, q
VAR	ANON_506_15_L190_G_info, q
VAR	ANON_506_60_L190_D_data, q
VAR	ANON_506_60_L190_D_info, q
VAR	ANON_506_15_L190_G_len,  q
VAR	ANON_506_60_L190_D_len,  q
VAR	ANON_506_15_L190_R_disp, q
VAR	ANON_506_15_L190_R__u,   q
namespace ANON_506_15_L190_R_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
STR ANON_506_15_L190_G, "; PAS UN TXTREP/NUM_VAL PAS DE CHAINE ! "	; constante string="; PAS UN TXTREP/NUM_VAL PAS DE CHAINE ! "
	LCA	ANON_506_15_L190_G.data_ptr
	DUP
	La  ,  0
	Sa  1, ANON_506_15_L190_G_data
	La  ,  8
	Sa  1, ANON_506_15_L190_G_info
	LId 1, ANON_506_15_L190_G_info, _STRING.LST_1
	LId 1, ANON_506_15_L190_G_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_506_15_L190_G_len
VAR	ANON_506_60_disp, q
VAR	ANON_506_60__u,   q
namespace ANON_506_60_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 1, ANON_506_60_info.SIZ
	Sa  1, ANON_506_60__u
	LVA 1, ANON_506_60_disp
	La	1, STANDARD.IDL.PRINT_NAME_L25.TR_disp
	Ld
	LI	24
	LI	8
	UBFX
	La 0, STANDARD.DIANA_NODE_ATTR_CLASS_NAMES._NODE_NAME.use__info
	LI	16
	ADD
	CALL	STANDARD. ,ENUM_IMAGE_L31
	DUP
	La  ,  0
	Sa  1, ANON_506_60_L190_D_data
	La  ,  8
	Sa  1, ANON_506_60_L190_D_info
	LId 1, ANON_506_60_L190_D_info, _STRING.LST_1
	LId 1, ANON_506_60_L190_D_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_506_60_L190_D_len
	La  1, ANON_506_15_L190_G_len
	La  1, ANON_506_60_L190_D_len
	ADD
	CO_VAR
	Sa  1, ANON_506_15_L190_R_disp
	LI	1
	Sd  1, ANON_506_15_L190_R_info._FST_1
	La  1, ANON_506_15_L190_G_len
	La  1, ANON_506_60_L190_D_len
	ADD
	Sd  1, ANON_506_15_L190_R_info._LST_1
	LI	8
	Sd  1, ANON_506_15_L190_R_info._COMP_SIZ
	La  1, ANON_506_15_L190_G_len
	La  1, ANON_506_60_L190_D_len
	ADD
	LI	8
	MUL
	Sd  1, ANON_506_15_L190_R_info.SIZ
	LVA 1, ANON_506_15_L190_R_info.SIZ
	Sa  1, ANON_506_15_L190_R__u
	La  1, ANON_506_15_L190_R_disp
	La  1, ANON_506_15_L190_G_len
	La  1, ANON_506_15_L190_G_data
	BLKMOV
	La  1, ANON_506_15_L190_R_disp
	La  1, ANON_506_15_L190_G_len
	ADD
	La  1, ANON_506_60_L190_D_len
	La  1, ANON_506_60_L190_D_data
	BLKMOV
	LVA 1, ANON_506_15_L190_R_disp
	CALL	STANDARD.TEXT_IO. ,PUT_LINE_L60
	LCA	STANDARD.PROGRAM_ERROR__exc.data_ptr
	Sa	0, STANDARD.EXCEPTIONS_CURRENT_disp
	BRA	STANDARD.exc_raise_
ret_lbl:
	UNLINK 1
	RTD	prm_siz-8
excep:
endPRO					;---------- end PRO PRINT_NAME
end if

 </pre>

#PASSAGES

<pre>
</pre>

<pre>
</pre>

#INSCRIPTION AU LIEU UTILISE POUR RSI

<pre>

</pre>