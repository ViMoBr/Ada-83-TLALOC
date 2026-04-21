with TEXT_IO, SEQUENTIAL_IO, UNCHECKED_CONVERSION;
use  TEXT_IO;
			--------
procedure			LIRE_PGM
is			--------


		---------------
package		MATRICES_IMAGES
is		---------------

  type OCTET		is new INTEGER range 0 .. 255;	for OCTET'SIZE use 8;
  package OCTETS_IO		is new SEQUENTIAL_IO( OCTET );

  type MATRICE_8BITS	is array ( POSITIVE range <>, POSITIVE range <> ) of OCTET;
  type A_MATRICE_8BITS	is access MATRICE_8BITS;

  type TRIPLET_RGB		is record
			 R, G, B, ALPHA	: OCTET;
			end record;			for TRIPLET_RGB'SIZE use 32;
  type MATRICE_32BITS	is array ( POSITIVE range <>, POSITIVE range <> ) of TRIPLET_RGB;
  type A_MATRICE_32BITS	is access MATRICE_32BITS;

  procedure READ_PGM_IMAGE	( MATRICE :out A_MATRICE_8BITS );
  procedure WRITE_PNG	( NOM_FICHIER : STRING; IMG :A_MATRICE_32BITS );
  procedure WRITE_PPM	( NOM_FICHIER : STRING; IMG :A_MATRICE_32BITS );

end	MATRICES_IMAGES;
	---------------
use MATRICES_IMAGES;

  A_BLOC	: A_MATRICE_8BITS;

  A_COLOR	: A_MATRICE_32BITS;

			---------------
package body		MATRICES_IMAGES
is			---------------

			--------------
procedure			READ_PGM_IMAGE		( MATRICE :out A_MATRICE_8BITS )
is			--------------

  package INT_IO	is new INTEGER_IO( INTEGER );
  use INT_IO;

  NOM_FICHIER	: STRING( 1 .. 256 );
  LONG_NOM	: NATURAL;
  FICHIER		: FILE_TYPE;

  LARG		: NATURAL;
  HAUT		: NATURAL;
  VAL_MAX		: NATURAL;


  CAR		: CHARACTER;
  FIN_LIGNE	: BOOLEAN;

  ERREUR_FORMAT	: exception;


		-------------
  procedure	SAUTER_BLANCS
  is		-------------
  begin
    loop
      LOOK_AHEAD( FICHIER, CAR, FIN_LIGNE );
      if  FIN_LIGNE  then
        SKIP_LINE( FICHIER );
      elsif  CAR = ' '  or  CAR = ASCII.HT  then
        GET( FICHIER, CAR );
      else  exit;
      end if;
    end loop;

  end	SAUTER_BLANCS;
	-------------

begin			-------------
			OPEN_PGM_FILE:
  begin
    PUT( "NOM DU FICHIER PGM : " );
    GET_LINE( NOM_FICHIER, LONG_NOM );

   --  OUVERTURE
    begin
      OPEN( FICHIER, TEXT_IO.IN_FILE, NOM_FICHIER( 1 .. LONG_NOM ) );
    exception
      when NAME_ERROR =>
        PUT_LINE( "ERREUR : FICHIER INTROUVABLE." );
        return;
    end;
  end	OPEN_PGM_FILE;
	-------------

			-------------
			READ_MAGIC_P5:
  declare
    MAGIQUE		: STRING( 1 .. 2 );
  begin
    GET( FICHIER, MAGIQUE( 1 ) );
    GET( FICHIER, MAGIQUE( 2 ) );
    if  MAGIQUE /= "P5"  then
      raise ERREUR_FORMAT;
    end if;
    SKIP_LINE( FICHIER );

  end	READ_MAGIC_P5;
	-------------
			------------
			READ_COMMENT:
  declare
    COMMENTAIRE	: STRING( 1 .. 256 );
    LONG_COM	: NATURAL;
  begin
    LOOK_AHEAD( FICHIER, CAR, FIN_LIGNE );
    if  not FIN_LIGNE  and then  CAR = '#'  then
      GET_LINE( FICHIER, COMMENTAIRE, LONG_COM );
      PUT_LINE( "COMMENTAIRE : " & COMMENTAIRE( 1 .. LONG_COM ) );
    else
      PUT_LINE( "COMMENTAIRE : (AUCUN)" );
    end if;
  end	READ_COMMENT;
	------------

   --  LECTURE DE LA LARGEUR, HAUTEUR ET VALEUR MAX
  SAUTER_BLANCS;
  GET( FICHIER, LARG );
  SAUTER_BLANCS;
  GET( FICHIER, HAUT );
  SAUTER_BLANCS;
  GET( FICHIER, VAL_MAX );

   --  VÉRIFICATION DE COHÉRENCE
  if  VAL_MAX > 255  then
    raise ERREUR_FORMAT;   --  PAS DU 8 BITS
  end if;

  PUT( "LARGEUR  = " ); PUT( LARG, 0 );		NEW_LINE;
  PUT( "HAUTEUR  = " ); PUT( HAUT, 0 );		NEW_LINE;
  PUT( "VAL_MAX  = " ); PUT( VAL_MAX, 0 );	NEW_LINE;
  CLOSE( FICHIER );

  declare
    F			: OCTETS_IO.FILE_TYPE;
    A0_COUNT		: NATURAL			:= 4;
    A_BYTES		: A_MATRICE_8BITS		:= new MATRICE_8BITS( 1 .. HAUT , 1 .. LARG );
    B			: OCTET;
  begin
    OCTETS_IO.OPEN( F, OCTETS_IO.IN_FILE, NOM_FICHIER( 1 .. LONG_NOM ) );

    while A0_COUNT > 0  loop
      OCTETS_IO.READ( F, B );
      if  B = 16#0A#  then A0_COUNT := A0_COUNT - 1; end if;
    end loop;

    for  L in 1 .. HAUT  loop
      for  K in 1 .. LARG  loop
        OCTETS_IO.READ( F, A_BYTES.all( L, K ) );
      end loop;
    end loop;
    OCTETS_IO.CLOSE( F );
    MATRICE := A_BYTES;

  exception
    when END_ERROR =>
      PUT( "FIN DE FICHIER PREMATUREE" );
      raise;
  end;

exception
  when  ERREUR_FORMAT  =>
    PUT_LINE( "ERREUR : CE N'EST PAS UN PGM P5 8 BITS VALIDE." );
    if  IS_OPEN( FICHIER )  then
      CLOSE( FICHIER );
    end if;

  when  DATA_ERROR | END_ERROR  =>
    PUT_LINE( "ERREUR : ENTETE PGM ILLISIBLE OU INCOMPLETE." );
    if IS_OPEN( FICHIER ) then
      CLOSE( FICHIER );
    end if;

end	READ_PGM_IMAGE;
	--------------


		---------
procedure		WRITE_PNG			( NOM_FICHIER : STRING; IMG :A_MATRICE_32BITS )
is		---------

  type U32 is range 0 .. 2**32 - 1;
  for  U32'SIZE use 32;

  F	: OCTETS_IO.FILE_TYPE;
  --------------------------------------------------------------------
  --  Table CRC-32 (polynôme PNG 0xEDB88320, calculée à l'init)
  --------------------------------------------------------------------
  type CRC_TABLE_T is array (0 .. 255) of U32;
  CRC_TABLE	: CRC_TABLE_T;

   --  Buffer pour accumuler un chunk avant calcul du CRC
   type OCTET_BUFFER is array (POSITIVE range <>) of OCTET;
   type A_BUFFER    is access OCTET_BUFFER;

      W : constant INTEGER := IMG'LENGTH (2);   -- colonnes = largeur
      H : constant INTEGER := IMG'LENGTH (1);   -- lignes   = hauteur

      --  Données brutes : pour chaque ligne, 1 octet de filtre (0) + W*4 octets RGBA
      RAW_SIZE : constant INTEGER := H * (1 + W * 4);
      RAW      : OCTET_BUFFER (1 .. RAW_SIZE);
      K        : INTEGER;

      --  Données compressées zlib : en-tête (2) + blocs stored + adler (4)
      --  Un bloc stored contient au maximum 65535 octets.
      MAX_BLOCK : constant INTEGER := 65535;
      NB_BLOCKS : constant INTEGER := (RAW_SIZE + MAX_BLOCK - 1) / MAX_BLOCK;
      ZLIB_SIZE : constant INTEGER := 2 + NB_BLOCKS * 5 + RAW_SIZE + 4;

      ZDATA : OCTET_BUFFER (1 .. ZLIB_SIZE);
      ZPOS  : INTEGER;
      ADL   : U32;

      --  Buffer pour IHDR
      IHDR : OCTET_BUFFER (1 .. 13);

  --------------------------------------------------------------------
  --  Écriture d'entiers en big-endian (octet de poids fort d'abord)
  --------------------------------------------------------------------
  procedure PUT_U32_BE (V : U32) is
    use OCTETS_IO;
    X : U32 := V;
  begin
    WRITE (F, OCTET (X / 2**24));
    WRITE (F, OCTET ((X / 2**16) mod 256));
    WRITE (F, OCTET ((X / 2**8) mod 256));
    WRITE (F, OCTET (X mod 256));
  end PUT_U32_BE;

  procedure PUT_U16_BE (V : INTEGER) is
    use OCTETS_IO;
  begin
    WRITE (F, OCTET (V / 256));
    WRITE (F, OCTET (V mod 256));
  end PUT_U16_BE;

  procedure PUT_U16_LE (V : INTEGER) is
    use OCTETS_IO;
  begin
    WRITE (F, OCTET (V mod 256));
    WRITE (F, OCTET (V / 256));
  end PUT_U16_LE;

  function "XOR" (A, B: U32) return U32 is
    type BIT_MASK is array ( 1 .. 32 ) of BOOLEAN; pragma PACK( BIT_MASK ); for BIT_MASK'SIZE use 32;
    function U32_TO_BIT_MASK	is new UNCHECKED_CONVERSION( U32, BIT_MASK );
    function BIT_MASK_TO_U32	is new UNCHECKED_CONVERSION( BIT_MASK, U32 );
  begin
      return BIT_MASK_TO_U32( U32_TO_BIT_MASK( A ) xor U32_TO_BIT_MASK( B ));
  end "XOR";

  procedure INIT_CRC_TABLE is
    C : U32;
  begin
    for N in 0 .. 255 loop
      C := U32 (N);
      for K in 1 .. 8 loop
        if (C mod 2) = 1 then
          C := 16#EDB88320# xor (C / 2);
        else
          C := C / 2;
        end if;
      end loop;
      CRC_TABLE (N) := C;
    end loop;
  end INIT_CRC_TABLE;


   function COMPUTE_CRC (BUF : OCTET_BUFFER) return U32 is
      C : U32 := 16#FFFFFFFF#;
      IDX : INTEGER;
   begin
      for I in BUF'RANGE loop
         IDX := INTEGER ((C xor U32 (BUF (I))) mod 256);
         C   := CRC_TABLE (IDX) xor (C / 256);
      end loop;
      return C xor 16#FFFFFFFF#;
   end COMPUTE_CRC;

   --------------------------------------------------------------------
   --  Adler-32 (pour l'en-tête zlib)
   --------------------------------------------------------------------
   function ADLER32 (BUF : OCTET_BUFFER) return U32 is
      S1 : U32 := 1;
      S2 : U32 := 0;
   begin
      for I in BUF'RANGE loop
         S1 := (S1 + U32 (BUF (I))) mod 65521;
         S2 := (S2 + S1)            mod 65521;
      end loop;
      return S2 * 65536 + S1;
   end ADLER32;

   --------------------------------------------------------------------
   --  Écrire un chunk complet : longueur | type | data | CRC
   --------------------------------------------------------------------
  procedure	WRITE_CHUNK	( TYP :STRING; DATA :OCTET_BUFFER )
  is		-----------
    use OCTETS_IO;
    HEADER_AND_DATA : OCTET_BUFFER (1 .. 4 + DATA'LENGTH);
    CRC             : U32;
  begin
    --  Longueur (données seules, big-endian)
    PUT_U32_BE (U32 (DATA'LENGTH));

    --  Préparer buffer pour CRC : type + data
    for I in 1 .. 4 loop
      HEADER_AND_DATA (I) := OCTET (CHARACTER'POS (TYP (TYP'FIRST + I - 1)));
    end loop;
    for I in DATA'RANGE loop
      HEADER_AND_DATA (4 + I - DATA'FIRST + 1) := DATA (I);
    end loop;

    --  Écrire type + data
    for I in HEADER_AND_DATA'RANGE loop
      WRITE (F, HEADER_AND_DATA (I));
    end loop;

    --  CRC
    CRC := COMPUTE_CRC (HEADER_AND_DATA);
    PUT_U32_BE (CRC);

  end	WRITE_CHUNK;
	-----------


  procedure PUT (B : OCTET) is
  begin
    ZDATA (ZPOS) := B;
    ZPOS := ZPOS + 1;
  end PUT;

  use OCTETS_IO;

begin
  INIT_CRC_TABLE;

  --  --- Construction du buffer RAW (scanlines avec filtre None) ---
  K := 1;
  for I in IMG'RANGE (1) loop
    RAW (K) := 0;                      -- filtre None
    K := K + 1;
    for J in IMG'RANGE (2) loop
      RAW (K)     := IMG (I, J).R;
      RAW (K + 1) := IMG (I, J).G;
      RAW (K + 2) := IMG (I, J).B;
      RAW (K + 3) := IMG (I, J).ALPHA;
      K := K + 4;
    end loop;
  end loop;

    --  --- Construction du flux zlib ---
  ZPOS := 1;
  PUT (16#78#);   -- CMF : deflate, 32K window
  PUT (16#01#);   -- FLG : no dict, fastest, checksum OK (0x7801)

  declare
    REMAINING : INTEGER := RAW_SIZE;
    OFFSET    : INTEGER := 1;
    BLOCK_LEN : INTEGER;
    IS_LAST   : BOOLEAN;
  begin
    while REMAINING > 0 loop
      if REMAINING > MAX_BLOCK then
        BLOCK_LEN := MAX_BLOCK;
        IS_LAST   := FALSE;
      else
        BLOCK_LEN := REMAINING;
        IS_LAST   := TRUE;
      end if;

      --  En-tête de bloc stored : BFINAL (1 bit) + BTYPE=00 (2 bits)
      if IS_LAST then
        PUT (1);
      else
        PUT (0);
      end if;

      --  LEN (little-endian) puis NLEN = complément à 1
      PUT (OCTET (BLOCK_LEN mod 256));
      PUT (OCTET (BLOCK_LEN / 256));
      PUT (OCTET (255 - (BLOCK_LEN mod 256)));
      PUT (OCTET (255 - (BLOCK_LEN / 256)));

      --  Les données brutes
      for I in 0 .. BLOCK_LEN - 1 loop
        PUT (RAW (OFFSET + I));
      end loop;

      OFFSET    := OFFSET + BLOCK_LEN;
      REMAINING := REMAINING - BLOCK_LEN;
    end loop;
  end;

  --  Adler-32 du flux non compressé (big-endian)
  ADL := ADLER32 (RAW);
  PUT (OCTET (ADL / 2**24));
  PUT (OCTET ((ADL / 2**16) mod 256));
  PUT (OCTET ((ADL / 2**8)  mod 256));
  PUT (OCTET (ADL mod 256));

  --  --- Écriture du fichier PNG ---
  CREATE( F, OUT_FILE, NOM_FICHIER );

  --  Signature PNG : 89 50 4E 47 0D 0A 1A 0A
  WRITE (F, 16#89#); WRITE (F, 16#50#); WRITE (F, 16#4E#); WRITE (F, 16#47#);
  WRITE (F, 16#0D#); WRITE (F, 16#0A#); WRITE (F, 16#1A#); WRITE (F, 16#0A#);

  --  IHDR : largeur(4) hauteur(4) depth(1) color(1) compr(1) filt(1) interl(1)
  IHDR (1) := OCTET (W / 2**24);
  IHDR (2) := OCTET ((W / 2**16) mod 256);
  IHDR (3) := OCTET ((W / 2**8)  mod 256);
  IHDR (4) := OCTET (W mod 256);
  IHDR (5) := OCTET (H / 2**24);
  IHDR (6) := OCTET ((H / 2**16) mod 256);
  IHDR (7) := OCTET ((H / 2**8)  mod 256);
  IHDR (8) := OCTET (H mod 256);
  IHDR (9)  := 8;    -- bit depth
  IHDR (10) := 6;    -- color type RGBA
  IHDR (11) := 0;    -- compression deflate
  IHDR (12) := 0;    -- filtre standard
  IHDR (13) := 0;    -- non entrelacé
  WRITE_CHUNK ("IHDR", IHDR);

  --  IDAT
  WRITE_CHUNK ("IDAT", ZDATA);

  --  IEND (chunk vide)
  declare
    EMPTY : OCTET_BUFFER (1 .. 0);
  begin
    WRITE_CHUNK ("IEND", EMPTY);
  end;

  CLOSE (F);
end	WRITE_PNG;
	---------

			---------
procedure			WRITE_PPM		(  NOM_FICHIER : STRING; IMG :A_MATRICE_32BITS )
is			---------
  use OCTETS_IO;
  F	: OCTETS_IO.FILE_TYPE;
  W	: constant INTEGER	 	:= IMG'LENGTH( 2 );
  H	: constant INTEGER		:= IMG'LENGTH( 1 );

		----------
  procedure	PUT_STRING	( S :STRING )
  is		----------
  begin
    for  I in S'RANGE  loop
      WRITE (F, OCTET (CHARACTER'POS (S (I))));
    end loop;

  end	PUT_STRING;
	----------

		----------
  function	IMAGE_TRIM	( N :INTEGER )	return STRING
  is		----------
    S	: constant STRING	:= INTEGER'IMAGE( N );
  begin
    return S( S'FIRST + 1 .. S'LAST );  -- enlève l'espace de tête

  end	IMAGE_TRIM;
	----------
begin
  CREATE( F, OUT_FILE, NOM_FICHIER );

  PUT_STRING( "P6" & ASCII.LF );
  PUT_STRING( IMAGE_TRIM( W ) & " " & IMAGE_TRIM( H ) & ASCII.LF );
  PUT_STRING( "255" & ASCII.LF );

  for I in IMG'RANGE( 1 ) loop
    for J in IMG'RANGE( 2 ) loop
      WRITE( F, IMG( I, J ).R );
      WRITE( F, IMG( I, J ).G );
      WRITE( F, IMG( I, J ).B );
      --  ALPHA ignoré : PPM ne le supporte pas
    end loop;
  end loop;

  CLOSE( F );

end	WRITE_PPM;
	---------


end	MATRICES_IMAGES;
	---------------


		------------------------
procedure		CALCULE_MACRO_BLOC_LINES	( A_BLOC :A_MATRICE_32BITS )
is		------------------------

  VERT		:constant TRIPLET_RGB	:= ( 0,   255,   0, 255 );
  BLEU		:constant TRIPLET_RGB	:= ( 0,     0, 255, 255 );
  ROUGE		:constant TRIPLET_RGB	:= ( 255,   0,   0, 255 );
  COULEUR		: TRIPLET_RGB;

  type OFFSETS_REELS	is array( 1 .. 64 ) of FLOAT;
  OFFSETS_REELS_V		: OFFSETS_REELS;
  OFFSETS_REELS_H		: OFFSETS_REELS;
  I_OFS_H, I_OFS_V		: POSITIVE	:= 1;

package F_IO is new TEXT_IO.FLOAT_IO( FLOAT );

begin
		------------------
		GRILLE_HORIZONTALE:
  declare
    NB_BANDES	:constant NATURAL	:= 82;
    CORRECTION	:constant NATURAL	:= 3;
    H_BANDE	: FLOAT		:= FLOAT( A_BLOC.all'LENGTH( 1 ) - CORRECTION ) / FLOAT( NB_BANDES );
    L		: NATURAL;
    OFFSET_REEL_V	: FLOAT;

  begin
    PUT( "H_BANDE =" ); F_IO.PUT( H_BANDE ); NEW_LINE;
    for  N_BANDE in 1 .. (NB_BANDES)  loop
      if  N_BANDE mod 10 = 1  then  COULEUR:= VERT;
      elsif  N_BANDE mod 10 = 2  then  COULEUR:= BLEU;
      else  COULEUR:= ROUGE;
      end if;
      OFFSET_REEL_V := FLOAT( N_BANDE ) * H_BANDE;
      if  COULEUR = ROUGE  then
        OFFSETS_REELS_V( I_OFS_V ) := OFFSET_REEL_V;
        I_OFS_V := I_OFS_V + 1;
      end if;
      L := NATURAL( OFFSET_REEL_V ) + A_BLOC.all'FIRST( 1 );
      if  L > A_BLOC.all'LAST( 1 )  then exit; end if;
      for  IH in A_BLOC.all'RANGE( 2 )  loop
        A_BLOC.all( L, IH ) := COULEUR;
      end loop;
    end loop;
  end	GRILLE_HORIZONTALE;
	------------------

		------------------
		GRILLE_VERTICALE:
  declare
    NB_BANDES	:constant NATURAL	:= 88;
    CORRECTION_1	:constant INTEGER	:= -3;
    CORRECTION_2	:constant INTEGER	:= -1;
    L_BANDE_1	: FLOAT		:= FLOAT( A_BLOC.all'LENGTH( 2 ) - CORRECTION_1 ) / FLOAT( NB_BANDES );
    L_BANDE_2	: FLOAT		:= FLOAT( A_BLOC.all'LENGTH( 2 ) - CORRECTION_2 ) / FLOAT( NB_BANDES );
    FACTEUR_DECAL_1	:constant FLOAT	:= 1.75;
    FACTEUR_DECAL_2	:constant FLOAT	:= 43.75;
    K		: NATURAL;
    OFFSET_REEL_H	: FLOAT;

  begin
    PUT( "L_BANDE_1 =" ); F_IO.PUT( L_BANDE_1 ); PUT( "   L_BANDE_2 =" ); F_IO.PUT( L_BANDE_2 ); NEW_LINE;

    for  N_BANDE in 1 .. 42  loop
      if  N_BANDE mod 10 = 1  then  COULEUR:= VERT;
      elsif  N_BANDE mod 10 = 2  then  COULEUR:= BLEU;
      else  COULEUR:= ROUGE;
      end if;
      OFFSET_REEL_H := FLOAT( N_BANDE ) * L_BANDE_1 + FACTEUR_DECAL_1 * L_BANDE_1;
      if  COULEUR = ROUGE  then
        OFFSETS_REELS_H( I_OFS_H ) := OFFSET_REEL_H;
        I_OFS_H := I_OFS_H + 1;
      end if;
      K := NATURAL( OFFSET_REEL_H ) + A_BLOC.all'FIRST( 2 );
      if  K > A_BLOC.all'LAST( 2 )  then exit; end if;
      for  IV in A_BLOC.all'RANGE( 1 )  loop
        A_BLOC.all( IV, K ) := COULEUR;
      end loop;
    end loop;

    for  N_BANDE in 1 .. 42  loop
      if  N_BANDE mod 10 = 1  then  COULEUR:= VERT;
      elsif  N_BANDE mod 10 = 2  then  COULEUR:= BLEU;
      else  COULEUR:= ROUGE;
      end if;
      OFFSET_REEL_H := FLOAT( N_BANDE ) * L_BANDE_2 + FACTEUR_DECAL_2 * L_BANDE_1;				-- Attention : L_BANDE_1 pour origine
      if  COULEUR = ROUGE  then
        OFFSETS_REELS_H( I_OFS_H ) := OFFSET_REEL_H;
        I_OFS_H := I_OFS_H + 1;
      end if;
      K := NATURAL( OFFSET_REEL_H ) + A_BLOC.all'FIRST( 2 );
      if  K > A_BLOC.all'LAST( 2 )  then exit; end if;
      for  IV in A_BLOC.all'RANGE( 1 )  loop
        A_BLOC.all( IV, K ) := COULEUR;
      end loop;
    end loop;

  end	GRILLE_VERTICALE;
	------------------


exception
  when CONSTRAINT_ERROR => PUT_LINE( "DEPASSEMENT" );

end	CALCULE_MACRO_BLOC_LINES;
	------------------------

begin
  READ_PGM_IMAGE( A_BLOC );
  A_COLOR := new MATRICE_32BITS( A_BLOC.all'RANGE( 1 ) , A_BLOC.all'RANGE( 2 ) );

  for  L in A_BLOC.all'RANGE( 1 )  loop
    for  K in A_BLOC.all'RANGE( 2 )  loop
      A_COLOR( L, K ) := ( A_BLOC.all( L, K ), A_BLOC.all( L, K ), A_BLOC.all( L, K ), 255 );
    end loop;
  end loop;

  CALCULE_MACRO_BLOC_LINES( A_COLOR );


  WRITE_PNG( "essai.png", A_COLOR );

end	LIRE_PGM;
	--------
