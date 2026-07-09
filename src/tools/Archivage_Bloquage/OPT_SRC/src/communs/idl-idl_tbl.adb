------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with SEQUENTIAL_IO;
with TEXT_IO;
separate( IDL )
					-------
	package body			IDL_TBL
is					-------


			--=====--
procedure			INIT_SPEC		( SPEC_FILE : STRING )
is			--=====--

  package INT_IO		is new INTEGER_IO( INTEGER );
  use INT_IO;
  use TEXT_IO;

  SFILE			: FILE_TYPE;
  T_CHR			: CHARACTER;
  T_INT			: INTEGER;
  T_TXT			: STRING( 1 .. 50 );
  T_LAST			: NATURAL;
  AS_SEEN			: BOOLEAN;
  AS_LIST_SEEN		: BOOLEAN;
  NON_AS_SEEN		: BOOLEAN;

begin
  OPEN( SFILE, IN_FILE, SPEC_FILE & ".tbl" );
  LAST_NODE := -1;
  LAST_ATTR := -1;
  LAST_NODE_ATTR := 0;
  while not END_OF_FILE( SFILE ) loop
    GET( SFILE, T_CHR );										--| PRENDRE LE CARACTERE INDIQUANT LE TYPE DE LIGNE
    if T_CHR /= 'C' and T_CHR /= 'E' then								--| PAS CLASSE (C OU E) DONC 'N' OU 'A'
      GET( SFILE, T_INT );										--| N° DE NOEUD OU D'ATTRIBUT (NEGATIF)
    end if;
    GET_LINE( SFILE, T_TXT, T_LAST );									--| PRENDRE LE RESTANT DE LA LIGNE

    SUPPRESS_BLANKS:
    declare
      D		: INTEGER := 0;
    begin
      for S in 1 .. T_LAST loop
        if T_TXT( S ) /= ' ' and T_TXT( S ) /= ASCII.HT then						--| CARACTERE NON ' ' OU TAB
	D := D + 1;										--| AVANCER LE POINTEUR DE DESTINATION
	T_TXT( D ) := T_TXT( S );									--| RECOPIER LE CARACTERE
        end if;
      end loop;
      T_LAST := D;											--| LONGUEUR REDUITE DES ESPACES
    end SUPPRESS_BLANKS;

				--| NOEUDS
    if T_CHR = 'N' then										--| UNE LIGNE DECLARANT UN NOEUD
      LAST_NODE := LAST_NODE + 1;									--| UN NOEUD DE PLUS
      if LAST_NODE /= T_INT then									--| LE NUMERO D'ORDRE DOIT CORRESPONDRE AU NUMERO D'IDENTIFICATION
        PUT_LINE( "IDL.IDL_TBL.INIT_SPEC: LAST NODE /= T_INT" );
        raise PROGRAM_ERROR;
      end if;

      N_SPEC( NODE_NAME'VAL( LAST_NODE ) ) := (	NS_SIZE		=> 0,					--| PAS D'ATTRIBUT, DONC TAILLE NULLE
					NS_FIRST_A	=> 0,					--| PAS D'ATTRIBUT ENCORE VU, NUMERO DU PREMIER À 0
					NS_ARITY		=> NULLARY
				);
      AS_LIST_SEEN := FALSE;										--| PAS VU D' "as_" LIST
      AS_SEEN      := FALSE;										--| PAS VU D' "as_"
      NON_AS_SEEN  := FALSE;										--| PAS VU DE NON "as_" (UN "xd_" OU "sm_" ...)

				--| ATTRIBUTS

    elsif T_CHR = 'A' or T_CHR = 'B' or T_CHR = 'I' then
      LAST_NODE_ATTR := LAST_NODE_ATTR + 1;								--| UN ATTRIBUT DE PLUS
      declare
        NN	: NODE_NAME	:= NODE_NAME'VAL( LAST_NODE );
      begin
        if N_SPEC( NN ).NS_FIRST_A = 0 then								--| SI L'ON A PAS VU LE PREMIER ATTRIBUT
	N_SPEC( NN ).NS_FIRST_A := LAST_NODE_ATTR;							--| METTRE L'INDICE DE CET ATTRIBUT COMME PREMIER
        end if;
        N_SPEC( NN ).NS_SIZE := N_SPEC(  NN ).NS_SIZE + 1;							--| INCREMENTER LA TAILLE DU NOEUD AUQUEL ON AJOUTE L'ATTRIBUT

        if T_LAST >= 3 and then T_TXT(1 .. 3) = "as_" then							--| ATTRIBUT COMMENÇANT PAR "as_"
	if T_INT < 0 then										--| IDENTIFICATEUR NEGATIF (REPERE UNE LISTE, UN SEQ_TYPE)
	  if AS_SEEN or NON_AS_SEEN then								--| ON A DEJÀ VU UN AS_ OU UN NON AS_, INTERDIT : UNE "AS_" LIST DOIT ARRIVER EN TÊTE
	    PUT_LINE ( "BAD AS_LIST: " &  T_TXT(1 .. T_LAST) );
	  end if;
	  AS_SEEN := TRUE;										--| VU UN "AS_"
	  AS_LIST_SEEN := TRUE;									--| VU UNE "AS_" LIST
	  N_SPEC( NN ).NS_ARITY := ARITIES'VAL( ARITIES'POS( N_SPEC( NN ).NS_ARITY)+ 4 );

	else											--| IDENTIFICATEUR POSITIF (UN  AS_" QUI N'EST PAS UN SEQ_TYPE)
	  if AS_LIST_SEEN or NON_AS_SEEN then								--| ON NE DOIT PAS AVOIR DE "AS_" LIST AVANT UN "AS_" NON LISTE ET PAS DE NON "AS_" NON PLUS
	    PUT_LINE ( "BAD AS_...: " & T_TXT(1 .. T_LAST) );
	  end if;
	  AS_SEEN := TRUE;										--| VU UN "AS_"
	  N_SPEC( NN ).NS_ARITY := ARITIES'VAL( ARITIES'POS( N_SPEC( NN ).NS_ARITY)+ 1 );
	end if;

        else											--| PAS UN "AS_"
	NON_AS_SEEN := TRUE;									--| NON "AS_" VU
        end if;
      end;

      A_SPEC( LAST_NODE_ATTR ).IS_LIST :=  T_INT < 0;							--| INDICATEUR DE LISTE (UNE SEULE PAR NOEUD)
      T_INT := abs T_INT;										--| IDENTIFICATEUR EN POSITIF
      A_SPEC( LAST_NODE_ATTR ).ATTR := ATTRIBUTE_NAME'VAL( T_INT );						--| STOCKER L'IDENTIFICATEUR DE L'ATTRIBUT
      if T_INT > LAST_ATTR then									--| DEPASSE LE NOMBRE D'ATTRIBUTS VUS
        LAST_ATTR := T_INT;										--| METTRE À JOUR CE NOMBRE (NOTRE ATTRIBUT INDIQUE QU'IL Y EN A PLUS)
      end if;

    end if;

  end loop;
  CLOSE( SFILE );

end	INIT_SPEC;
	--=====--


  package DTT_IO	is new SEQUENTIAL_IO (	DIANA_TABLE_TYPE );
  use DTT_IO;


			--======--
procedure			WRITE_SPEC	( SPEC_FILE :STRING )
is			--======--

  SFILE		: DTT_IO.FILE_TYPE;
begin
  DTT_IO.CREATE( SFILE, OUT_FILE, SPEC_FILE & ".bin" );
  DTT_IO.WRITE ( SFILE, DIANA_TABLE_AREA );
  DTT_IO.CLOSE ( SFILE );

end	WRITE_SPEC;
	--======--


			--=====--
procedure			READ_SPEC ( SPEC_FILE :STRING )
is			--=====--

  SFILE		: DTT_IO.FILE_TYPE;
begin
  DTT_IO.OPEN ( SFILE, IN_FILE, SPEC_FILE & ".bin" );
  DTT_IO.READ ( SFILE, DIANA_TABLE_AREA );
  DTT_IO.CLOSE( SFILE );

end	READ_SPEC;
	--=====--


	-------
end	IDL_TBL;
	-------

--	1	2	3	4	5	6	7	8	9	0	1	2
------------------------------------------------------------------------------------------------------------------------
