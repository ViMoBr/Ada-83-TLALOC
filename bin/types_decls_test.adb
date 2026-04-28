			----------------
procedure			TYPES_DECLS_TEST
is			----------------


				-- DISCRETS

		-- patron 2 Types enumeres
  type COULEUR		is (BLEU, BLANC, ROUGE, VERT, NOIR);

		-- patron 3 Sous-types enumeres
  subtype COULEUR_DRAPEAU	is COULEUR range BLEU .. ROUGE;


				-- SCALAIRES

		-- patron 1 Types entiers
  type ENTIER_1		is range -32_768 .. 32_767;

		-- patron 1 Sous-types entiers
  subtype VAL_OCTET		is ENTIER_1 range -128 .. 127;


		-- patron 4 Types virgule flottante
  type REEL_1		is digits 5 range -10.0 .. 20.0;

		-- patron 5 Types virgule fixes
  type FIX_1		is delta 0.001 range -1.0 .. 5.0;


				-- COMPOSITES TABLEAUX

		-- patron 7 Types tableaux NON contraints
  type U_MAT_1		is array( NATURAL range <> , NATURAL range <> ) of FLOAT;

		-- patron 8 Types tableaux contraints
  type MATRICE_1		is array( 1 .. 10 , 0 .. 9 ) of LONG_INTEGER;


				-- COMPOSITES ARTICLES

		-- patron 11 Types record sans discriminants
  type SIMPLE_RECORD	is record
			  COMP_1	: NATURAL;
			  MAT	: MATRICE_1;
			end record;

  -- patron 12 Types record NON contraints AVEC discriminants
  type DISCRIM_RECORD_2( DX, DY :INTEGER )
			is record
			  COMP_1	: NATURAL;
			  MAT	: MATRICE_1;
			  case DX is
			  when 0 .. 10 => R1 :NATURAL;
			  when others => R2 :FLOAT;
			  end case;
			end record;


  -- patron 9 Types tableaux dependants de discriminants (dans un record NON contraint AVEC discriminants)
  type DISCRIM_RECORD( DX, DY :NATURAL )
			is record
			  INFO	: INTEGER;
			  MAT	: U_MAT_1( 1 .. DX, 1 .. DY );
			end record;

  -- patron 10 Types tableaux chaines unidimensionnelles


  -- patron 13 Types record CONTRAINTS AVEC discriminants (voir patron 9 origine)
  subtype MAT_RECORD	is DISCRIM_RECORD( 10, 20 );

  -- patron 14 Types record AVEC discriminants dependants de discriminants
  type REC_RECORD( L, DX, DY :NATURAL )		is record
			  CHAMP		: INTEGER;
			  SOUS_REC	: DISCRIM_RECORD( DX,DY );
			end record;


  -- patron 6 Types acces
  -- type PTR_1		is access INTEGER;


begin
  null;

end	TYPES_DECLS_TEST;
	----------------
