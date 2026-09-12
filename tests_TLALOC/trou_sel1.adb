    procedure TROU_SEL1 is
      -- S1 : record ORDINAIRE, champ scalaire
      type REC is record
        A : INTEGER;
        B : CHARACTER;
      end record;

      -- S3 : record REPRESENTE 64 bits (calquer un petit TREE local
      -- avec sa rep-clause, deux champs)
      --   type CREC is record H, S : ... end record;
      --   for CREC use record ... end record;
      --   function MKC ... return CREC ...

      I : INTEGER;
      C : CHARACTER;

      function MK( N : INTEGER ) return REC is
      begin
        return ( A=> N, B=> 'x' );
      end MK;

    begin
      -- S1 champ scalaire d'un appel
      I := MK( 41 ).A + 1;
      if I /= 42 then raise PROGRAM_ERROR; end if;

      -- S2 deuxieme champ (offsets non nuls exerces)
      C := MK( 7 ).B;
      if C /= 'x' then raise PROGRAM_ERROR; end if;

      -- S3 champ d'un record represente retourne (le cas DABS/NSIZ)
      -- S4 prefixe imbrique : F(N).A en operande d'expression
      --    (MK(1).A + MK(2).A = 3)
    end TROU_SEL1;
