#COMMANDE AU COMPILATEUR BOOTSTRAPPE
 <pre>
 $ ./A83.sh ./ ./null_prog.adb S
ada83 compiling ././null_prog.adb
2:  is
    ^ col 1./A83.sh : ligne 2 : 461885 Erreur de segmentation  (core dumped) ./ADA_COMP <<< "$1 $2 $3"
</pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR BOOTSTRAPPE
<pre> 
procedure NULL_PROG
is
begin
  null;
end NULL_PROG;

</pre>

#REMARQUES

Le source de test (null_prog.adb) est excessivement simple et sans erreur. Or le compilateur bootstrappé passe sur le PAR_PHASE et rentre en affichage d'erreur (ERR_PHASE) au niveau du "is".
Je crains qu'il ne s'agisse d'un défaut issu du parser (peut être dû à l'utilisation de la table parse.bin utilisée aussi par le compilateur généré par gnat. La taille de cette table est identique à celle de la structure de données TLALOC, mais il n'y a pas une absolue garantie que le parser du bootstrappé fonctionne correctement avec ce parse.bin. Il se pourrait aussi que le parser du bootstrappé ne fonctionne pas correctement pour une autre raison.
En tout cas l'erreur se produit dans l'affichage d'une erreur de compilation qui ne devrait pas exister. Toutefois cet affichage lui-même devrait se faire sans segfault.

#INSTRUCTION SEGFAULT 0x46ff17
 <pre>
(gdb) x/16i $rip-48
   0x46fee7:    lea    -0x8(%rbp),%ebp
   0x46feea:    mov    0x0(%rbp),%rax
   0x46feee:    lea    -0x8(%rbp),%rbp
   0x46fef2:    cqto
   0x46fef4:    idiv   %rbx
   0x46fef7:    mov    %rax,0x8(%rbp)
   0x46fefb:    lea    0x8(%rbp),%rbp
   0x46feff:    mov    0x18(%r15),%rax
   0x46ff03:    mov    -0x8(%rax),%rax
   0x46ff07:    mov    %rax,0x8(%rbp)
   0x46ff0b:    lea    0x8(%rbp),%rbp
   0x46ff0f:    mov    0x0(%rbp),%rax
   0x46ff13:    lea    -0x8(%rbp),%rbp
=> 0x46ff17:    mov    (%rax),%rax
   0x46ff1a:    mov    %rax,0x8(%rbp)
   0x46ff1e:    lea    0x8(%rbp),%rbp

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x18                24                 rbx            0x8                 8                  │
│rcx            0x7                 7                  rdx            0x0                 0                  │
│rsi            0x7fffffc06af4      140737484188404    rdi            0x7fffffc06adc      140737484188380    │
│rbp            0x7fffffc06c18      0x7fffffc06c18     rsp            0x7fffffbfdad0      0x7fffffbfdad0     │
│r8             0xffffffffffffffff  -1                 r9             0x0                 0                  │
│r10            0x22                34                 r11            0x246               582                │
│r12            0x7ffff7df3800      140737351989248    r13            0xdb4940            14371136           │
│r14            0xdb4948            14371144           r15            0x7fffffbfdaf0      140737484151536    │
│rip            0x46ff17            0x46ff17           eflags         0x10206             [ PF IF RF ]       │

</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc06bd8: 0x0000000000db4900      0x000000000000001d
0x7fffffc06be8: 0x00007fffffc06b98      0x00007ffff7df98ec
0x7fffffc06bf8: 0x0000000000000018      0x00007fffffc06930
0x7fffffc06c08: 0x0000000000000008      0x2052554552524516
0x7fffffc06c18: 0x000000000000001d      0x0000000000000018
0x7fffffc06c28: 0x00007ffff7df98e8      0x00000000000000e8
0x7fffffc06c38: 0x0000000000000004      0x0000000000000008
0x7fffffc06c48: 0x0000000000000004      0x00007fffffc06b00

</pre>

#BACKTRACE ET MAP
<pre>
(gdb) bt
#0  0x000000000046ff17 in ?? ()
PRINT_NAME_L25 0x000000000046F086
var elab TR 0x000000000046F0A7
 disp 0x0000000000000008
var elab TXT_HDR 0x000000000046F41E
 disp 0x0000000000000008
var elab START 0x000000000046F5AF
 disp 0x0000000000000034
var elab NB_TREES 0x000000000046F6CB
 disp 0x0000000000000035
var elab NB_CARS 0x000000000046F847
 disp 0x0000000000000038
TO_CHN_L187 0x000000000046FE7F
## zone segfault
var elab THE_CHN 0x000000000046FF5D
 disp 0x00000000000000C8

#1  0x0000000000470353 in ?? ()
var elab THE_CHN 0x000000000046FF5D
 disp 0x00000000000000C8
## zone appel
PRINT_NUM_L26 0x0000000000470CDA

#2  0x000000000065919a in ?? ()
ERR_PHASE_L12 0x0000000000656D3B
var elab FULL_LIST 0x0000000000656D5C
 disp 0x0000000000000008
var elab IFILE 0x0000000000656D7D
 disp 0x0000000000000010
var elab LINE_COUNT 0x0000000000657044
 disp 0x0000000000000144
var elab ERR_COUNT 0x00000000006570E4
 disp 0x0000000000000148
var elab SOURCE_LIST 0x00000000006578A6
 disp 0x0000000000000008
var elab ERRORLIST 0x00000000006579A9
 disp 0x0000000000000048
var elab SOURCENBR 0x00000000006579EC
 disp 0x0000000000000064
var elab NB_PREFIX_CHARS 0x0000000000657A0D
 disp 0x0000000000000068
var elab SOURCELINE 0x0000000000657B9D
 disp 0x0000000000000008
var elab SLINE 0x00000000006580FA
 disp 0x0000000000000020
var elab LAST 0x000000000065827E
 disp 0x0000000000000030
var elab ERROR 0x0000000000658BE4
 disp 0x0000000000000008
var elab COL 0x0000000000658CD6
 disp 0x000000000000001C
## zone appel
including sub body IDL-ERR_PHASE.FINC
WRITE_LIB_L13 0x000000000065952E

#3  0x0000000000d5a20f in ?? ()
#4  0x0000000000d5ac95 in ?? ()

</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT DANS idl.adb
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
      function TO_CHN	is new UNCHECKED_CONVERSION( SUITE_TREES, CHN );
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

#SECTION LLIR CONTENANT LE SEGFAULT DANS IDL.FINC
<pre>
if defined TO_CHN_L187_
; F4A SET  cle=SOURCE  actuel=DN_CONSTRAINED_ARRAY
BRA post_LD_TO_CHN_L187SOURCE
LD_TO_CHN_L187SOURCE.elab:
	LI 0
	RTD 0
post_LD_TO_CHN_L187SOURCE:
BRA post_ST_TO_CHN_L187SOURCE
ST_TO_CHN_L187SOURCE.elab:
	DROP
	RTD 0
post_ST_TO_CHN_L187SOURCE:
BRA post_INADR_TO_CHN_L187SOURCE
INADR_TO_CHN_L187SOURCE.elab:
	LIa
	RTD 0
post_INADR_TO_CHN_L187SOURCE:
BRA post_OUTADR_TO_CHN_L187SOURCE
OUTADR_TO_CHN_L187SOURCE.elab:
	LIa
	RTD 0
post_OUTADR_TO_CHN_L187SOURCE:
VAR TO_CHN_L187SOURCE__outadr_ofs, q
	LCA OUTADR_TO_CHN_L187SOURCE.elab
	Sa	 2, TO_CHN_L187SOURCE__outadr_ofs
VAR TO_CHN_L187SOURCE__inadr_ofs, q
	LCA INADR_TO_CHN_L187SOURCE.elab
	Sa	 2, TO_CHN_L187SOURCE__inadr_ofs
VAR TO_CHN_L187SOURCE__st_ofs, q
	LCA ST_TO_CHN_L187SOURCE.elab
	Sa	 2, TO_CHN_L187SOURCE__st_ofs
VAR TO_CHN_L187SOURCE__ld_ofs, q
	LCA LD_TO_CHN_L187SOURCE.elab
	Sa	 2, TO_CHN_L187SOURCE__ld_ofs
VAR TO_CHN_L187SOURCE__u_ofs, q
	La	 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._SUITE_TREES.use__info
	Sa	 2, TO_CHN_L187SOURCE__u_ofs
; F4A SET  cle=TARGET  actuel=DN_CONSTRAINED_ARRAY
BRA post_LD_TO_CHN_L187TARGET
LD_TO_CHN_L187TARGET.elab:
	LI 0
	RTD 0
post_LD_TO_CHN_L187TARGET:
BRA post_ST_TO_CHN_L187TARGET
ST_TO_CHN_L187TARGET.elab:
	DROP
	RTD 0
post_ST_TO_CHN_L187TARGET:
BRA post_INADR_TO_CHN_L187TARGET
INADR_TO_CHN_L187TARGET.elab:
	LIa
	RTD 0
post_INADR_TO_CHN_L187TARGET:
BRA post_OUTADR_TO_CHN_L187TARGET
OUTADR_TO_CHN_L187TARGET.elab:
	LIa
	RTD 0
post_OUTADR_TO_CHN_L187TARGET:
VAR TO_CHN_L187TARGET__outadr_ofs, q
	LCA OUTADR_TO_CHN_L187TARGET.elab
	Sa	 2, TO_CHN_L187TARGET__outadr_ofs
VAR TO_CHN_L187TARGET__inadr_ofs, q
	LCA INADR_TO_CHN_L187TARGET.elab
	Sa	 2, TO_CHN_L187TARGET__inadr_ofs
VAR TO_CHN_L187TARGET__st_ofs, q
	LCA ST_TO_CHN_L187TARGET.elab
	Sa	 2, TO_CHN_L187TARGET__st_ofs
VAR TO_CHN_L187TARGET__ld_ofs, q
	LCA LD_TO_CHN_L187TARGET.elab
	Sa	 2, TO_CHN_L187TARGET__ld_ofs
VAR TO_CHN_L187TARGET__u_ofs, q
	La	 2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.use__info
	Sa	 2, TO_CHN_L187TARGET__u_ofs
VAR GFP_disp, q				; Lieu du Generic Frame Pointer 
PRO	TO_CHN_L187				;---------- PRO TO_CHN
 hexa_show 'TO_CHN_L187 ', $
PRMS					;    debut parametrage
	PRM S_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 3
begin:
	La	3, -result__ofs
	La
	Ld	2, STANDARD.IDL.PRINT_NAME_L25.BLOCK__11._CHN.SIZ
	LI	8
	DIV
	La	3, -S_ofs
	La
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
	ULb 2,	START_disp
; CODE_NUMERIC_LITERAL DN_UNIVERSAL_INTEGER
	LI	0
	SUB
	LI	4
	MUL
	ADD
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
	CALL	STANDARD.IDL.PRINT_NAME_L25.BLOCK__11. ,TO_CHN_L187
	La
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
VAR	RET_INFO_L190, q
	DUP
	La  ,  0
	SIq   1, -result__ofs,  0
	DUP
	La  ,  8
	Sa   2, RET_INFO_L190
	DROP
	La   1, -result__ofs
	La  ,  8
	LI	16
	La   2, RET_INFO_L190
	BLKMOV
	UNLINK 2
	BRA ret_lbl
	UNLINK 2
endPRO
	BRA	L185
L186:
L185:					; post if
; CODE & concat _STRING
VAR	ANON_506_15_L191_G_data, q
VAR	ANON_506_15_L191_G_info, q
VAR	ANON_506_60_L191_D_data, q
VAR	ANON_506_60_L191_D_info, q
VAR	ANON_506_15_L191_G_len,  q
VAR	ANON_506_60_L191_D_len,  q
VAR	ANON_506_15_L191_R_disp, q
VAR	ANON_506_15_L191_R__u,   q
namespace ANON_506_15_L191_R_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
STR ANON_506_15_L191_G, "; PAS UN TXTREP/NUM_VAL PAS DE CHAINE ! "	; constante string="; PAS UN TXTREP/NUM_VAL PAS DE CHAINE ! "
	LCA	ANON_506_15_L191_G.data_ptr
	DUP
	La  ,  0
	Sa  1, ANON_506_15_L191_G_data
	La  ,  8
	Sa  1, ANON_506_15_L191_G_info
	LId 1, ANON_506_15_L191_G_info, _STRING.LST_1
	LId 1, ANON_506_15_L191_G_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_506_15_L191_G_len
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
	Sa  1, ANON_506_60_L191_D_data
	La  ,  8
	Sa  1, ANON_506_60_L191_D_info
	LId 1, ANON_506_60_L191_D_info, _STRING.LST_1
	LId 1, ANON_506_60_L191_D_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  1, ANON_506_60_L191_D_len
	La  1, ANON_506_15_L191_G_len
	La  1, ANON_506_60_L191_D_len
	ADD
	CO_VAR
	Sa  1, ANON_506_15_L191_R_disp
	LI	1
	Sd  1, ANON_506_15_L191_R_info._FST_1
	La  1, ANON_506_15_L191_G_len
	La  1, ANON_506_60_L191_D_len
	ADD
	Sd  1, ANON_506_15_L191_R_info._LST_1
	LI	8
	Sd  1, ANON_506_15_L191_R_info._COMP_SIZ
	La  1, ANON_506_15_L191_G_len
	La  1, ANON_506_60_L191_D_len
	ADD
	LI	8
	MUL
	Sd  1, ANON_506_15_L191_R_info.SIZ
	LVA 1, ANON_506_15_L191_R_info.SIZ
	Sa  1, ANON_506_15_L191_R__u
	La  1, ANON_506_15_L191_R_disp
	La  1, ANON_506_15_L191_G_len
	La  1, ANON_506_15_L191_G_data
	BLKMOV
	La  1, ANON_506_15_L191_R_disp
	La  1, ANON_506_15_L191_G_len
	ADD
	La  1, ANON_506_60_L191_D_len
	La  1, ANON_506_60_L191_D_data
	BLKMOV
	LVA 1, ANON_506_15_L191_R_disp
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

if defined PRINT_NUM_L26_
PRO	PRINT_NUM_L26				;---------- PRO PRINT_NUM
 hexa_show 'PRINT_NUM_L26 ', $

 </pre>
