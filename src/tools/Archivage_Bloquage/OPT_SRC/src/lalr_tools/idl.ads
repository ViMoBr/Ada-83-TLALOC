------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with LALRIDL_NODE_ATTR_CLASS_NAMES;
use  LALRIDL_NODE_ATTR_CLASS_NAMES;

					---
package					IDL
is					---


		--| CREATION/OUVERTURE FERMETURE DE FICHIER .LAR (FICHIER ARBRE)

  procedure CREATE_IDL_TREE_FILE	( PAGE_FILE_NAME :STRING );						--| CREE UN FICHIER	"PAGE_FILE_NAME.LAR"
  procedure OPEN_IDL_TREE_FILE	( PAGE_FILE_NAME :STRING );						--| OUVRE	UN FICHIER "PAGE_FILE_NAME.LAR" DEJÀ CREÉ
  procedure CLOSE_IDL_TREE_FILE;									--| FERMETURE DU FICHIER ".LAR"


		--| UTILITAIRES POUR GRAMMAIRE LALR

  procedure READ_GRMR		( NOM_TEXTE :STRING	);
  procedure OPTR_GRMR		( NOM_TEXTE :STRING	);
  procedure INIT_GRMR		( NOM_TEXTE :STRING	);
  procedure STAT_GRMR		( NOM_TEXTE :STRING	);
  procedure LALR_GRMR		( NOM_TEXTE :STRING	);
  procedure CHECK_GRMR		( NOM_TEXTE :STRING	);
  procedure PRINT_STAT		( NOM_TEXTE :STRING	);
  procedure LOAD_GRMR		( NOM_TEXTE :STRING	);


		--| DISPOSITIF D'ACCES A UN ARBRE REPESENTANT UNE	DESCRIPTION DE GRAMMAIRE

  type SHORT			is range -32_768 ..	32767;	for SHORT'SIZE    use 16;
  type POSITIVE_SHORT		is range 0 .. 32767;	for POSITIVE_SHORT'SIZE   use	15;
  type PAGE_IDX			is range 0 .. 16#7FFF#;	for PAGE_IDX'SIZE use 15;
  type LINE_IDX			is range 0 .. 127;		for LINE_IDX'SIZE use 7;
  subtype	ATTR_NBR			is LINE_IDX;
  type LINE_NBR			is range 0 .. 128;

  type SRCCOL_IDX			is range 0 .. 255;		for SRCCOL_IDX'SIZE	use 8;

  type VPTR_TYPE			is (P, S,	L, HI);							--| PTR NOEUD, SOURCE_POS, LIST, HEADER/INTEGER
  type TREE (PT : VPTR_TYPE := P)	is								--| PAR DEFAUt POINTEUR DE NOEUD
		record
		  case PT	is
		  when P | L =>									--| POINTEUR NORMAL	DE NOEUD OU ATTRIBUT LISTE
		    TY		: NODE_NAME;							--| TYPE DE NOEUD
		    PG		: PAGE_IDX;							--| REFERENCE DE PAGE VIRTUELLE
		    LN		: LINE_IDX;							--| DECALAGE DANS UNE PAGE VIRTUELLE
		  when S =>									--| POINTEUR DE SOURCE_LINE AVEC COLONNE SOURCE EN PLACE DU	TYPE
		    COL		: SRCCOL_IDX;							--| NUMERO DE COLONNE DANS LE	TEXTE SOURCE
		    SPG		: PAGE_IDX;							--| REFERENCE DE PAGE VIRTUELLE
		    SLN		: LINE_IDX;							--| DECALAGE DANS UNE PAGE VIRTUELLE
		  when HI	=>									--| HEADER DE NOEUD	OU INTEGER (SHORT) CODE PAR VALEUR ABSOLUE ET INDICATEUR DE	COMPLEMENT A DEUX
		    NOTY		: NODE_NAME;							--| TYPE DE NOEUD
		    ABSS		: POSITIVE_SHORT;							--| VALEUR ABSOLUE D UN SHORT	POUR UNE VALEUR ENTIERE
		    NSIZ		: ATTR_NBR;							--| NOMBRE D ATTRIBUTS DU NOEUD (SI ENTETE) OU INDICATEUR DE COMPLEMENT 0+ 1- POUR ABSS
		  end case;
		end record;
		for TREE'SIZE use 32;
		for TREE use record	at mod 4;
			PT	at 0 range 0..1;
			LN	at 0 range 2..8;
			SLN	at 0 range 2..8;
			NSIZ	at 0 range 2..8;
			PG	at 0 range 9..23;
			SPG	at 0 range 9..23;
			ABSS	at 0 range 9..23;
			COL	at 0 range 24..31;
			TY	at 0 range 24..31;
			NOTY	at 0 range 24..31;
			end record;

  TREE_NIL		: constant TREE	:= (P, TY	=> DN_NIL,   PG => 0, LN => 0);

  type SEQ_TYPE		is record
			  FIRST, NEXT	: TREE;
			end record;


			--| ACCES	A L'ARBRE


  function  MAKE		( NN :NODE_NAME )				return TREE;			--| AJOUTE UN NOEUD	DE TYPE NODE_NAME

  procedure D		( AN :ATTRIBUTE_NAME; T :TREE; V :TREE );					--| ECRITURE D'UN ATTRIBUT CONTENANT UN	ARBRE
  function  D		( AN :ATTRIBUTE_NAME; T :TREE	)		return TREE;			--| LECTURE D'UN ATTRIBUT CONTENANT UN ARBRE

  procedure DB		( AN :ATTRIBUTE_NAME; T :TREE; V :BOOLEAN );					--| ECRITURE D'UN ATTRIBUT CONTENANT UN	BOOLEEN
  function  DB		( AN :ATTRIBUTE_NAME; T :TREE	)		return BOOLEAN;			--| LECTURE D'UN ATTRIBUT CONTENANT UN BOOLEEN

  procedure DI		( AN :ATTRIBUTE_NAME; T :TREE; V :INTEGER );					--| ECRITURE D'UN ATTRIBUT CONTENANT UN	ENTIER (16 BITS)
  function  DI		( AN :ATTRIBUTE_NAME; T :TREE	)		return INTEGER;			--| LECTURE D'UN ATTRIBUT CONTENANT UN ENTIER (16	BITS)

  function  LIST		( T :TREE	)				return SEQ_TYPE;			--| REND LA LISTE CONTENUE DANS UN NOEUD POINTE PAR LE POINTEUR D'ARBRE
  function  IS_EMPTY	( S :SEQ_TYPE )				return BOOLEAN;			--| TESTE	UNE LISTE
  procedure POP		( S :in out SEQ_TYPE; T :out TREE );						--| EXTRAIT UN ELEMENT DE LISTE ET REPOINTE S SUR	LE RESTE

  function  PRINT_NAME	( T :TREE	)				return STRING;			--| TXTREP OR SYMBOL_REP
  function  NODE_IMAGE	( NN :NODE_NAME )				return STRING;			--| CHAINE REPRESENTANT UN NOEUD
  function  ATTR_IMAGE	( AN :ATTRIBUTE_NAME )			return STRING;			--| CHAIUNE REPRESENTANT UN NOM D'ATTRIBUT


			--| AFFICHAGE DE TOUT OU PARTIE DE L'ARBRE


				---------
  package				PRINT_NOD
  is				---------

    procedure PRINT_TREE	( T :TREE	);
    function  L_PRINT_TREE	( T :TREE	)			return NATURAL;				--| RETOURNE LE NOMBRE DE CARACTERES
    procedure PRINT_NODE	( T :TREE; INDENT :NATURAL :=0 );

	---------
  end	PRINT_NOD;
	---------


  pragma INLINE ( DB );
  pragma INLINE ( DI );
  pragma INLINE ( D	);


	---
end	IDL;
	---

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
