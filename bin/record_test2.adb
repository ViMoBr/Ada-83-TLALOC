-- RECORD_TEST2 -- Pilier LRM 3.7.1 / 3.7.2 / 3.7.4 -- lot R-B
-- Defauts de discriminants, objets mutables, changement de variante par
-- affectation complete, agregats qualifies (dette CODE_QUALIFIED),
-- attribut 'CONSTRAINED, mutables imbriques, retour de mutable.

with TEXT_IO; use TEXT_IO;

procedure RECORD_TEST2 is

  type KIND is ( LEAF, UNARY, BINARY );

  type MUT ( PT : KIND := LEAF ) is             -- defauts -> objets mutables
    record
      COL : INTEGER;
      case PT is
        when LEAF   => VAL : INTEGER;
        when UNARY  => OPU : INTEGER;
        when BINARY => GAU : INTEGER;
                       DTE : INTEGER;
      end case;
    end record;

  subtype MLEAF is MUT( LEAF );                 -- sous-type contraint d'un type a defauts

  type BOX is
    record
      ID : INTEGER;
      N  : MUT;                                 -- composant mutable (taille max)
    end record;

  M  : MUT;                                     -- non contraint : PT = LEAF par defaut
  K  : MUT( BINARY );
  L  : MLEAF;
  BX : BOX;

  procedure FLIP ( R : in out MUT ) is
  begin
    R := ( UNARY, 9, 55 );                      -- changement de variante dans le formel
  end FLIP;

  function GEN return MUT is
  begin
    return ( BINARY, 2, 6, 7 );
  end GEN;

begin
  PUT_LINE( "=== E1 : defauts et mutation par affectation ===" );
  if M.PT = LEAF then PUT_LINE( " 0" ); end if; --  0 (defaut elabore)
  M := ( UNARY, 5, 77 );
  PUT_LINE( INTEGER'IMAGE( M.OPU ) );           --  77
  if M.PT = UNARY then PUT_LINE( " 1" ); end if; -- 1

  PUT_LINE( "=== E2 : attribut CONSTRAINED ===" );
  if M'CONSTRAINED then PUT_LINE( "VRAI" ); else PUT_LINE( "FAUX" ); end if; -- FAUX
  if K'CONSTRAINED then PUT_LINE( "VRAI" ); else PUT_LINE( "FAUX" ); end if; -- VRAI

  PUT_LINE( "=== E3 : agregat qualifie ===" );
  M := MUT'( LEAF, 3, 9 );
  PUT_LINE( INTEGER'IMAGE( M.VAL ) );           --  9

  PUT_LINE( "=== E4 : sous-type contraint d'un type a defauts ===" );
  if L.PT = LEAF then PUT_LINE( " 0" ); end if; --  0
  L := ( LEAF, 4, 13 );
  PUT_LINE( INTEGER'IMAGE( L.VAL ) );           --  13

  PUT_LINE( "=== E5 : mutable composant de record ===" );
  BX.ID := 3;
  BX.N  := ( BINARY, 1, 10, 11 );
  PUT_LINE( INTEGER'IMAGE( BX.N.GAU + BX.N.DTE ) ); --  21
  if BX.N.PT = BINARY then PUT_LINE( " 2" ); end if; -- 2

  PUT_LINE( "=== E6 : changement de variante via formel in out ===" );
  FLIP( M );
  PUT_LINE( INTEGER'IMAGE( M.OPU ) );           --  55
  if M.PT = UNARY then PUT_LINE( " 1" ); end if; -- 1

  PUT_LINE( "=== E7 : retour de mutable par fonction ===" );
  M := GEN;
  PUT_LINE( INTEGER'IMAGE( M.GAU + M.DTE ) );   --  13

  PUT_LINE( "=== fin RECORD_TEST2 ===" );
end RECORD_TEST2;
