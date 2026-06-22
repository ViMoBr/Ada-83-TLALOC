with DIRECT_IO;
			--------
procedure			TEST_NEW
is

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

    MAX_VPG			: constant PAGE_IDX	:= PAGE_IDX'LAST;					--| PAGES	VIRTUELLES (N° DE PAGES PHYSIQUES)
    subtype VPG_IDX			is PAGE_IDX range 0	.. MAX_VPG;

    MAX_RPG			: constant	:= 50;						--| PAGES	PHYSIQUES	(REELLES)
    type RPG_IDX			is new INTEGER range 0 .. MAX_RPG;					--|
    subtype RPG_NUM			is RPG_IDX     range 1 .. MAX_RPG;

    MAX_AREA			: constant	:= 10;						--| POINTS D'INSERTION
    type AREA_IDX			is new INTEGER range 0 .. MAX_AREA;

    type SECTOR		is array(	LINE_IDX ) of TREE;							--| TREE DE 0 A 127
    type A_SECTOR		is access	SECTOR;

    type RPG_DATA		is record									--| DONNEES GESTION	PAGE REELLE
			  VP		: VPG_IDX;						--| PAGE VIRTUELLE ASSOCIEE (0 SI PAS ASSOCIEE)
			  AREA		: AREA_IDX;
			  CHANGED		: BOOLEAN;
			  RECUPERABLE	: BOOLEAN;
			  DATA		: A_SECTOR;
			end record;
    PAG			: array( RPG_NUM ) of RPG_DATA;						--| TABLE	DE PAGES REELLES

    CUR_RP			: RPG_NUM;							--| PAGE PHYSIQUE COURANTE
    HIGH_VPG			: VPG_IDX;							--| DERNIERE PAGE VIRTUELLE

begin

  CUR_RP := 1;									--| LIRE LA RACINE (PAGE VIRTUELLE 1) DANS LA PAGE REELLE DE No RENDU
  PAG( CUR_RP ).DATA := new SECTOR;
  HIGH_VPG := VPG_IDX( PAG( CUR_RP ).DATA.all( 1 ).ABSS );					--| NUMERO DE LA DERNIERE PAGE VIRTUELLE (AUSSI NUMERO DE BLOC FICHIER)

end	TEST_NEW;
	--------
