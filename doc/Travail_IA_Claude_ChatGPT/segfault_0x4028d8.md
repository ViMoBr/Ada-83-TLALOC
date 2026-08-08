#COMMANDE AU COMPILATEUR BOOTSTRAPPE
 <pre>
 $ ./A83.sh ./ ../_standrd.ads M
ada83 compiling ././_standrd.ads
Program received signal SIGSEGV, Segmentation fault.
0x00000000004028d8 in ?? ()
</pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR BOOTSTRAPPE
<pre> 
_standrd.ads (joint)
</pre>

#REMARQUES

La procedure FIX_PRE dans le package IDL.SEM_PHASE effectue des initialisations. Des appels à l'attribut image sont utilisés. L'un d'eux segfaulte.

#INSTRUCTION SEGFAULT 0x4028d8
 <pre>
(gdb) x/16i $rip-32
   0x4028b8:    cmc
   0x4028b9:    lea    0x8(%r14),%r14
   0x4028bd:    mov    0x8(%r15),%rax
   0x4028c1:    lea    -0x8(%rax),%rax
   0x4028c5:    mov    %rax,0x8(%rbp)
   0x4028c9:    lea    0x8(%rbp),%rbp
   0x4028cd:    mov    0x0(%rbp),%rax
   0x4028d1:    lea    -0x8(%rbp),%rbp
   0x4028d5:    mov    (%rax),%rax
=> 0x4028d8:    mov    0x8(%rax),%rax
   0x4028dc:    mov    %rax,0x8(%rbp)
   0x4028e0:    lea    0x8(%rbp),%rbp
   0x4028e4:    mov    0x0(%rbp),%rax
   0x4028e8:    lea    -0x8(%rbp),%rbp
   0x4028ec:    movslq 0x8(%rax),%rax
   0x4028f0:    mov    %rax,0x8(%rbp)

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x10                16                           rbx            0x7fffffc07500      140737484190976              │
│rcx            0x0                 0                            rdx            0x0                 0                            │
│rsi            0x7fffffc04c84      140737484180612              rdi            0x7fffffc072cc      140737484190412              │
│rbp            0x7fffffc075f0      0x7fffffc075f0               rsp            0x7fffffbfdac8      0x7fffffbfdac8               │
│r8             0xffffffffffffffff  -1                           r9             0x0                 0                            │
│r10            0x22                34                           r11            0x246               582                          │
│r12            0x7ffff7ded400      140737351963648              r13            0xf7fe38            16252472                     │
│r14            0xf7fe40            16252480                     r15            0x7fffffbfdaf0      140737484151536              │
│rip            0x4028d8            0x4028d8                     eflags         0x10202             [ IF RF ]                    │

</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc075b0: 0x0000000000000004      0x00007fffffc074d8
0x7fffffc075c0: 0x00007fffffc074f0      0x0000000000000000
0x7fffffc075d0: 0x0000000000000010      0x00007fffffc071e0
0x7fffffc075e0: 0x0000000000000018      0x0000000000000008
0x7fffffc075f0: 0x00007fffffbfdc18      0x00007fffffc075d0
0x7fffffc07600: 0x0000000000f7e640      0x00007fffffc07660
0x7fffffc07610: 0x0000000000db9bb0      0x00007fffffc06f00
0x7fffffc07620: 0x0000000000000001      0x0000000000000008

</pre>

#BACKTRACE ET MAP
<pre>
(gdb) bt
#0  0x00000000004028d8 in ?? ()
**situation source Ada : _standrd.adb**
**sous programme : ENUM_IMAGE**
ENUM_IMAGE_L31 0x000000000040289F
var elab I 0x00000000004028BD
 disp 0x0000000000000008
 **zone du segfault**
var elab ITEM_REP 0x0000000000402983
 disp 0x000000000000000C

#1  0x000000000065bcbe in ?? ()
MAKE_PREDEF_IDS_L171 0x000000000065A5D4

**situation source Ada : idl-sem_phase-fix_pre.adb**
**sous programme : IDL.SEM_PHASE.FIX_PRE.MAKE_PREDEF_IDS**

var elab NEW_ID_LIST 0x000000000065A5F5
 disp 0x0000000000000008
var elab NEW_ID 0x000000000065A73A
 disp 0x0000000000000028
var elab NEW_ARG_LIST 0x000000000065A82C
 disp 0x0000000000000040
var elab NEW_ARG 0x000000000065A86F
 disp 0x0000000000000060
var elab ITEM_LENGTH 0x000000000065A961
 disp 0x0000000000000074
var elab SYM 0x000000000065BB90
 disp 0x0000000000000008
**zone source appel probable**
------
	        NEW_ARG := MAKE_ARGUMENT_ID (
			LX_SYMREP => STORE_SYM ( LIST_ARGUMENTS'IMAGE ( ARG_NAME ) ),
			XD_POS	=> LIST_ARGUMENTS'POS ( ARG_NAME )
			);
------

var elab ITEM_NAME 0x000000000065C180
 disp 0x0000000000000008

#2  0x000000000065ea41 in ?? ()
var elab PREDEF_ID_LIST 0x000000000065E904
 disp 0x0000000000000020
**zone appel**
var elab INTEGER_ID 0x000000000065EB04
 disp 0x0000000000000008

#3  0x0000000000660f39 in ?? ()
var elab SRC_NAME 0x0000000000660B90
 disp 0x00000000000000D8
including sub body IDL-SEM_PHASE.FINC
**zone appel**
------
begin
  declare
    USER_ROOT		: TREE;
    PREDEF_ID_LIST		: SEQ_TYPE;
  begin
    USER_ROOT := D( XD_USER_ROOT, TREE_ROOT );
    MAKE_PREDEF_IDS( PREDEF_ID_LIST );							--| NOEUDS STANDARD POUR LES NOMS PREDEFINIS
------
ERR_PHASE_L12 0x000000000066109F

#4  0x0000000000d869ee in ?? ()
#5  0x0000000000d879e0 in ?? ()

</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT DANS _standrd.adb
<pre>
  function		ENUM_IMAGE	( IMAGES :STRING; REP :INTEGER )	return STRING
  is			----------
  -- Primitive Ada cachee de l''IMAGE des ENUMERES, pendant d'INTEGER_IMAGE.
  -- Appelee par le code genere : CODE_IMAGE empile le descripteur resultat,
  -- REP (l'argument de l'attribut, deja empile par l'appelant), puis le
  -- doublet IMAGES du type -- qui est le doublet contractuel pose par
  -- END_BLOC_DEF a use__info+16 (SIZ@0, FST@4, LST@8, pad, data_ptr@16,
  -- info_ptr@24 ; pieges n 29 et 87) : directement un doublet STRING,
  -- zero copie.  Format IMAGES : triplets ( REP, LEN, caracteres... ),
  -- le meme que celui parcouru par TEXT_IO.ENUMERATION_IO (PUT/GET).
    I		: POSITIVE	:= IMAGES'FIRST;
    ITEM_REP	: INTEGER;
    LEN		: INTEGER;
  begin
    while  I <= IMAGES'LAST  loop
      ITEM_REP := CHARACTER'POS( IMAGES( I ) );
      LEN	     := CHARACTER'POS( IMAGES( I + 1 ) );

      if  ITEM_REP = REP  then
        declare
	-- Rebasage OBLIGATOIRE a 1..LEN (LRM 3.5.5 : la borne basse du
	-- resultat de 'IMAGE est 1) : LEX compte dessus (IMAGE(4..LGR)).
	-- Initialisation par tranche : c'est le patch n 3 de
	-- COMPILE_ARRAY_VAR qui rend cette declaration compilable.
	IMG	: constant STRING( 1 .. LEN ) := IMAGES( I + 2 .. I + 1 + LEN );
        begin
	return IMG;
        end;
      end if;

      I := I + 2 + LEN;
    end loop;

    raise PROGRAM_ERROR;										-- valeur hors table : bruyant (piege n 53)

  end	ENUM_IMAGE;

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS _STANDRD.FINC
<pre>
if defined ENUM_IMAGE_L31_
PRO	ENUM_IMAGE_L31				;---------- PRO ENUM_IMAGE
 hexa_show 'ENUM_IMAGE_L31 ', $
PRMS					;    debut parametrage
	PRM IMAGES_ofs				; in
	PRM REP_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 1					;    BODY ELAB
 hexa_show 'var elab I ', $
VAR I_disp, d				; variable entiere
	LVA	1, -IMAGES_ofs
	LIa	, , 8
	Ld	, _STRING.FST_1
	DUP
	Ld	0, STANDARD._POSITIVE.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	Ld	0, STANDARD._POSITIVE.LST
	CGT
	BT	STANDARD.ce_raise_
	Sd  1,	I_disp

 hexa_show ' disp ', I_disp
 hexa_show 'var elab ITEM_REP ', $
VAR ITEM_REP_disp, d			; variable entiere

 </pre>

#SECTION LLIR APPELANTE DANS IDL-SEM_PHASE-FIX_PRE.FINC
<pre>
LOOP__33:					; corps boucle LOOP__33
	LVA 2,	NEW_ARG_disp
	La
	LI	STANDARD.IDL._TREE.size
VAR	ANON_583_21_disp, q
VAR	ANON_583_21__u,    q
VAR	ANON_583_21__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_583_21__dat
	Sa  2, ANON_583_21_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_583_21__u
	LVA 2, ANON_583_21_disp
					; doublet resultat record anonyme
	ULb 2,	ARG_NAMEL179_disp
VAR	ANON_584_17_disp, q
VAR	ANON_584_17__u,    q
VAR	ANON_584_17__dat, STANDARD.IDL._TREE.size
	LVA 2, ANON_584_17__dat
	Sa  2, ANON_584_17_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  2, ANON_584_17__u
	LVA 2, ANON_584_17_disp
					; doublet resultat record anonyme
VAR	ANON_584_29_disp, q
VAR	ANON_584_29__u,   q
namespace ANON_584_29_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 2, ANON_584_29_info.SIZ
	Sa  2, ANON_584_29__u
	LVA 2, ANON_584_29_disp
	ULb 2,	ARG_NAMEL179_disp
	La 1, STANDARD.IDL.SEM_PHASE_L11.PRENAME._LIST_ARGUMENTS.use__info
	LI	16
	ADD
	CALL	STANDARD. ,ENUM_IMAGE_L31
	CALL	STANDARD.IDL.IDL_MAN. ,STORE_SYM_L40
	LVA  0,	STANDARD.IDL.TREE_VOID_disp		; array actual
	CALL	STANDARD.IDL.SEM_PHASE_L11.MAKE_NOD. ,MAKE_ARGUMENT_ID_L254
	La
	BLKMOV
