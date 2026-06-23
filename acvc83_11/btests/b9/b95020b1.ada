-- B95020B1.ADA

-- JRK 2/27/84

PACKAGE BODY B95020B0 IS

     TASK BODY TASK1 IS

          FUNCTION "*" (L, R : INTEGER) RETURN INTEGER
                       RENAMES STANDARD."*";
          FUNCTION "/" (L, R : INTEGER) RETURN INTEGER RENAMES "+";

          FUNCTION F1 (L, R : INTEGER) RETURN INTEGER
                      RENAMES STANDARD."+";

          PACKAGE P5 IS
               V1 : I RENAMES B95020B0.V1;
               SUBTYPE I IS B95020B0.I;
          END P5;

          F : CONSTANT BOOLEAN := FALSE;
          TYPE NONBOOL IS (TRUE, TOO_TRUE);
          FALSE : CONSTANT BOOLEAN := F;

     BEGIN

          ACCEPT T1A (D1 : I := V);          -- ERROR: (L) D1.

          ACCEPT T1B (D : I1 := V);          -- ERROR: (C) I1.

          ACCEPT T2A (D : I := V1);          -- ERROR: (B) V1.

          ACCEPT T2B (D : I1 := (VV1));      -- ERROR: (M) ()'S.

          ACCEPT T3 (D1 : I; D2, D3 : I);    -- ERROR: (H) D1, D2.

          ACCEPT T4A (D : BOOLEAN :=
                        (TRUE = TRUE));      -- ERROR: (E) AMBIGUOUS
                                             --   TRUE.

          ACCEPT T4B (D : BOOLEAN :=
               (TRUE = BOOLEAN'(TRUE)));     -- ERROR: (M)
                                             --   QUALIFICATION.

          ACCEPT T7A (D : I1 := WW1);        -- ERROR: (B) WW1.

          ACCEPT T7B (D : I := P1.W2);       -- OK: (A) P1.W2.

          ACCEPT T8A (D : I2 := W2);         -- OK: (A) I2, W2.

          ACCEPT T9A (D : I := 0 + 2);       -- ERROR: (G) 0 + 2.

          ACCEPT T9B (D : I2 := W2);         -- ERROR: (L) W2.

          ACCEPT T9C (D : I2 := "+"(2,0));   -- ERROR: (G) "+"(2,0).

          ACCEPT T10 (D : BOOLEAN := FALSE); -- ERROR: (E)
                                             --   DIFFERENT FALSE.

          ACCEPT T11 (D : STANDARD.BOOLEAN := STANDARD.FALSE);   -- OK:
                                                       -- (A) STANDARD.

          ACCEPT T12A (D : INTEGER := 00100);     -- OK: (D) 00100.

          ACCEPT T12B (D : INTEGER := 8#144#);    -- OK: (D) 8#144#.

          ACCEPT T13 (D :                    -- OK: (K) NEW COMMENT.
                          INTEGER            -- OK: (K) DIFFERENT
                                             --   COMMENT.
                          := 0
                     );

          ACCEPT T14 (D : INTEGER := 3 * 1); -- ERROR: (N)
                                             --   DIFFERENT *.

          ACCEPT T15 (D : INTEGER := 3 / 1); -- ERROR: (N)
                                             --   DIFFERENT /.

          ACCEPT T16A (D : P3.T);            -- OK: (A) P3.T.

          ACCEPT T16B (D : T);               -- OK: (A) T.

          ACCEPT T16C (D : NP3.T);           -- ERROR: (I) NP3.

          ACCEPT T17 (D : B95020B0.P3.T);    -- OK: (I)
                                             --   B95020B0.P3.T.

          ACCEPT T18 (D : I := F1(1,0));     -- ERROR: (E)
                                             --   DIFFERENT F1.

          ACCEPT T19A (D : I := STANDARD."+"(1,0));    -- ERROR: (O)
                                                       --  STANDARD."+".

          ACCEPT T19B (D : CHARACTER := 'A');     -- ERROR: (O) 'A'.

          ACCEPT T19C (D : CHARACTER := STANDARD.'A'); -- OK: (O)
                                                       --  STANDARD.'A'.

          ACCEPT T20A (D : P5.I);            -- ERROR: (P) P5.I.

          ACCEPT T20B (D : I := P5.V1);      -- ERROR: (P) P5.V1.

          ACCEPT T21A (D : I := 0);          -- ERROR: (Q) := 0.

          ACCEPT T21B (D : I);               -- ERROR: (Q) MISSING := 0.

          ACCEPT T22A (D : IN I);            -- ERROR: (R) IN.

          ACCEPT T22B (D : I);               -- ERROR: (R) MISSING IN.

          ACCEPT T22C (D : IN OUT I);        -- ERROR: (R) IN OUT.

          ACCEPT T22D (D : OUT I);           -- ERROR: (R) OUT.

          ACCEPT T22E (D : OUT I);           -- ERROR: (R) OUT.

          ACCEPT T22F (D : I);               -- ERROR: (R) MISSING IN
                                             --   OUT.

          ACCEPT T22G (D : I);               -- ERROR: (R) MISSING OUT.

     END TASK1;

END B95020B0;
