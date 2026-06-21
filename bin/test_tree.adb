with TEXT_IO;
use  TEXT_IO;
			---------
procedure			TEST_TREE
is			---------

  type NODE_NAME			is (DN_NIL, DN_VOID, DN_ROOT);

  type SHORT			is range -32_768 ..	32767;		for SHORT'SIZE use 16;
  type POSITIVE_SHORT		is range 0 .. 32767;		for POSITIVE_SHORT'SIZE use 15;
  type PAGE_IDX			is range 0 .. 16#7FFF#;		for PAGE_IDX'SIZE use 15;
  type LINE_IDX			is range 0 .. 127;			for LINE_IDX'SIZE use 7;
  subtype	ATTR_NBR			is LINE_IDX;
  type LINE_NBR			is range 0 .. 128;

  type SRCCOL_IDX			is range 0 .. 255;			for SRCCOL_IDX'SIZE	use 8;

  type VPTR_TYPE			is (P, S,	L, HI);							--| PTR NOEUD, SOURCE_POS, LIST, HEADER/INTEGER

  type TREE (PT : VPTR_TYPE := P)	is record								--| PAR DEFAUT POINTEUR DE NOEUD
				  case PT	is
				  when P | L =>							--| POINTEUR NORMAL	DE NOEUD OU ATTRIBUT LISTE
				    TY		: NODE_NAME;					--| TYPE DE NOEUD
				    PG		: PAGE_IDX;					--| REFERENCE DE PAGE VIRTUELLE
				    LN		: LINE_IDX;					--| DECALAGE DANS UNE PAGE VIRTUELLE
				  when S =>							--| POINTEUR DE SOURCE_LINE AVEC COLONNE SOURCE EN PLACE DU	TYPE
				    COL		: SRCCOL_IDX;					--| NUMERO DE COLONNE DANS LE	TEXTE SOURCE
				    SPG		: PAGE_IDX;					--| REFERENCE DE PAGE VIRTUELLE
				    SLN		: LINE_IDX;					--| DECALAGE DANS UNE PAGE VIRTUELLE
				  when HI	=>							--| HEADER DE NOEUD	OU INTEGER (SHORT) CODE PAR VALEUR ABSOLUE ET INDICATEUR DE	COMPLEMENT A DEUX
				    NOTY		: NODE_NAME;					--| TYPE DE NOEUD
				    ABSS		: POSITIVE_SHORT;					--| VALEUR ABSOLUE D UN SHORT	POUR UNE VALEUR ENTIERE
				    NSIZ		: ATTR_NBR;					--| NOMBRE D ATTRIBUTS DU NOEUD (SI ENTETE) OU INDICATEUR DE COMPLEMENT 0+ 1- POUR ABSS
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

  TREE_NIL		:constant	TREE	:= (P, TY	=> DN_NIL,   PG => 0, LN => 0);
  TREE_VOID		:constant	TREE	:= (P, TY	=> DN_VOID,  PG => 0, LN => 0);			--| POINTEUR NON TYPE MAIS PAS NIL EN GENERAL (POINTE QUELQUE CHOSE)
  TREE_ROOT		:constant	TREE	:= (P, TY	=> DN_ROOT,  PG => 1, LN => 0);

  type SEQ_TYPE		is record
			  FIRST, NEXT	: TREE;
			end record;
begin
  declare
    package NODE_NAME_IO	is new ENUMERATION_IO( NODE_NAME );
    package PAGE_IDX_IO	is new INTEGER_IO( PAGE_IDX );
  begin
    PUT( "TY=> " ); NODE_NAME_IO.PUT( TREE_ROOT.TY );
    PUT( ", PG=> " ); PAGE_IDX_IO.PUT( TREE_ROOT.PG, WIDTH=> 2 );
    NEW_LINE;
  end;

end	TEST_TREE;
	---------
