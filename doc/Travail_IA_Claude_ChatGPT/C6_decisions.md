- **Q1a** — Contresigner : valeur d'accès composite = @data nu (lecture
  allocateur ci-dessus).  Un fragment FINC d'un `new` + déréférence
  d'idl.adb suffit.
  
###ALLOCATION DE SECTOR DANS IDL.PAGE_MAN.INIT_PAGE_MAN
 
 Source Ada 83 lignes 30-35 de idl-page_man.adb :
  <pre>
    PAG	   := (others=> (	VP		=> 0,					--| INITIALISER LA TABLE DES PAGES PHYSIQUES
			AREA		=> 0,
			RECUPERABLE	=> TRUE,
			CHANGED		=> FALSE,
			DATA		=> new SECTOR )
			);

  </pre>
  
Section de FINC :
 
  <pre>
	La  0,	PAG_disp
					; Assign_array_aggregate dynamic type DN_CONSTRAINED_ARRAY
namespace ANON_32_13_aga
  VAR _FST_1, d
  VAR _LST_1, d
  VAR _LEN_1, d
  VAR _STR_1, d
  VAR _PTR_1, q
  VAR _CNT_1, d
  VAR _EMIS_1, d
end namespace
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	Sd  1, ANON_32_13_aga._FST_1
; CODE_NUMERIC_LITERAL DN_UNIVERSAL_INTEGER
	LI	50
	Sd  1, ANON_32_13_aga._LST_1
	Ld  1, ANON_32_13_aga._LST_1
	Ld  1, ANON_32_13_aga._FST_1
	SUB
	INC
	CLAMP0
	Sd  1, ANON_32_13_aga._LEN_1
	LI	24
	Sd  1, ANON_32_13_aga._STR_1
	Sa  1, ANON_32_13_aga._PTR_1
	LI	0
	Sd  1, ANON_32_13_aga._EMIS_1
	Ld  1, ANON_32_13_aga._LEN_1
	Ld  1, ANON_32_13_aga._EMIS_1
	SUB
	Sd  1, ANON_32_13_aga._CNT_1
	Ld  1, ANON_32_13_aga._CNT_1
	LI	0
	CLE
	BT  L25

L24:
	La  1, ANON_32_13_aga._PTR_1
					; Assign_record_aggregate type DN_RECORD
	DUP
	LVA	, STANDARD.IDL.PAGE_MAN._RPG_DATA.VP
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	Sw

	DUP
	LVA	, STANDARD.IDL.PAGE_MAN._RPG_DATA.AREA
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	Sd
	DUP
	LVA	, STANDARD.IDL.PAGE_MAN._RPG_DATA.CHANGED
	LI	0
	Sb

	DUP
	LVA	, STANDARD.IDL.PAGE_MAN._RPG_DATA.RECUPERABLE
	LI	1
	Sb
	DUP
	LVA	, STANDARD.IDL.PAGE_MAN._RPG_DATA.DATA
	Ld	0, STANDARD.IDL.PAGE_MAN._SECTOR.SIZ
	LI	8
	DIV
	HEAP_ALLOC
	Sq
	
	DROP

	La  1, ANON_32_13_aga._PTR_1
	Ld  1, ANON_32_13_aga._STR_1
	ADD
	Sa  1, ANON_32_13_aga._PTR_1
	Ld  1, ANON_32_13_aga._EMIS_1
	INC
	Sd  1, ANON_32_13_aga._EMIS_1
	Ld  1, ANON_32_13_aga._CNT_1
	DEC
	DUP
	Sd  1, ANON_32_13_aga._CNT_1
	LI	0
	CGT
	BT  L24
L25:
</pre>

###ACCES A DATA DANS IDL.PAGE_MAN.ALLOC_PAGE

Source Ada 83 ligne 273 idl-page_man.adb :
  <pre>
      PAG( RP ).DATA.all := (others=> TREE_VIRGIN);					--| INITIALISER LE BLOC ALLOUE
</pre>

Section de FINC :

<pre>
  	La	 0, STANDARD.IDL.PAGE_MAN.PAG_disp		; array data start address on stack
	ULd 2,	RP_disp
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
					; Assign_array_aggregate dynamic type DN_CONSTRAINED_ARRAY
namespace ANON_268_29_aga


  </pre>
  
  
- **Q1b** — Le site DN_ALL d'idl.adb tranche-t-il un désigné CONTRAINT ?
  (Si non contraint : bornes portées par l'objet au tas — AUTRE modèle,
  non couvert par cette note, à instruire séparément.)
  
  Le type SECTOR qui fait l'objet d'allocation dynamique est défini ici :
  <pre>
    type SECTOR		is array( LINE_IDX ) of TREE;							--| TREE DE 0 A 127
    type A_SECTOR		is access SECTOR;

    type RPG_DATA		is record									--| DONNEES GESTION PAGE REELLE
			  VP		: VPG_IDX;						--| PAGE VIRTUELLE ASSOCIEE (0 SI PAS ASSOCIEE)
			  AREA		: AREA_IDX;
			  CHANGED		: BOOLEAN;
			  RECUPERABLE	: BOOLEAN;
			  DATA		: A_SECTOR;
			end record;
    PAG			: array( RPG_NUM ) of RPG_DATA;						--| TABLE DE PAGES REELLES
</pre>

C'est donc un composite contraint.

- **Q1c** — Localiser le site (fichier:ligne) et le joindre à la note
  validée.
  
extraits du fichier idl-page_man.adb lignes indiquées avec les extraits.
  
- **Q2** — Nom/chemin EXACT de la lecture statique de la première borne :
  le FINC montre `VAR _FST_1, d` dans le namespace du type (souligné),
  mais les lectures par pointeur du rameau paramètre impriment `.FST_1`
  (sans souligné).  Lever l'ambiguïté sur un FINC existant de
  tranche-sur-paramètre (le corpus en a depuis vague ≤ 4) : quelle
  chaîne exacte pour `Ld <lvl>, <path>._<TYPE>.?FST_1` en statique ?
  
Les variables ont un nom commençant par underscore (par exemple VAR _FST_1, d) pour éviter la confusion avec des noms similaires d'offsets statiques du genre NOMTYPE.FST_1 (donc sans underscore pour les offsets).
  
- **Q3** — Contresigner que CODE_INDEXED sur composant COMPOSITE laisse
  bien @data nue (n° 112) : un FINC de `GA_NAME( I )` hors tranche, ou
  lecture de la queue de CODE_INDEXED.
  
##test_indexed.adb :
  <pre>
  procedure TEST_INDEXED
is
  type GA_TYPE	is array( 1 .. 128 ) of INTEGER;
  GA_NAME	: GA_TYPE;

  I	: INTEGER	:= 8;
  J	: INTEGER	:= 4;
begin
  GA_NAME( 4 ) := I;
  I := GA_NAME( J );

end	TEST_INDEXED;
</pre>

FINC associé :

<pre>
TEST_INDEXED = 'TEST_INDEXED'
PRO	TEST_INDEXED_L1				;---------- PRO TEST_INDEXED
 hexa_show 'TEST_INDEXED_L1 ', $
ELB 1					;    BODY ELAB

					; array decl constrained array type info
_GA_TYPE = '_GA_TYPE'
namespace _GA_TYPE
VAR use__info, q
VAR SIZ, d
	LVA	1, SIZ
	Sa	1, use__info
VAR _COMP_SIZ, d
VAR _FST_1, d
VAR _LST_1, d
	LI	32
	Sd	1, _COMP_SIZ
	Ld	1, _COMP_SIZ
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	Sd	1, _FST_1
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	128
	Sd	1, _LST_1
	Ld	1, _LST_1
	Ld	1, _FST_1
	SUB
	INC
	CLAMP0
	MUL
	Sd	1, SIZ
  virtual at 4
COMP_SIZ = $
	rd 1 
FST_1 = $
	rd 1 
LST_1 = $
	rd 1 
  end virtual
end namespace
 hexa_show 'var elab GA_NAME ', $
VAR GA_NAME_disp, q				; variable array : pointeur aux data
VAR GA_NAME__u, q				; variable array : useinfo pointeur au rec info
	La 1, STANDARD.TEST_INDEXED_L1._GA_TYPE.use__info
	Sa	1, GA_NAME__u				; array info ptr at __u
	Ld	1, STANDARD.TEST_INDEXED_L1._GA_TYPE.SIZ
	LI	8
	DIV
	CO_VAR
	Sa	1, GA_NAME_disp				; array data ptr at _disp

 hexa_show ' disp ', GA_NAME_disp
 hexa_show 'var elab I ', $
VAR I_disp, d				; variable entiere
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	8
	Sd  1,	I_disp

 hexa_show ' disp ', I_disp
 hexa_show 'var elab J ', $
VAR J_disp, d				; variable entiere
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	4
	Sd  1,	J_disp

 hexa_show ' disp ', J_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
	La	 1, STANDARD.TEST_INDEXED_L1.GA_NAME_disp	; array data start address on stack
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	4
	DUP
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	Ld 1,	I_disp
	Sd
	La	 1, STANDARD.TEST_INDEXED_L1.GA_NAME_disp	; array data start address on stack
	Ld 1,	J_disp
	DUP
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.FST_1
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.LST_1
	CGT
	BT	STANDARD.ce_raise_
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.FST_1	; (index - FST_1) * SIZ_1
	SUB
	LId	1, STANDARD.TEST_INDEXED_L1.GA_NAME__u, STANDARD.TEST_INDEXED_L1._GA_TYPE.COMP_SIZ
	LI	8
	DIV
	MUL
	ADD					; add offset to start address
	Ld
	Sd  1,	I_disp
ret_lbl:
	UNLINK 1
	RTD
excep:
endPRO					;---------- end PRO TEST_INDEXED

</pre>
 Donc les adresses directes sont utilisées.