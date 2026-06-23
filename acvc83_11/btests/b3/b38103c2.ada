-- B38103C2.ADA

-- JRK 2/16/84

PACKAGE BODY B38103C1 IS

          TYPE T1A (D1 : I := V) IS          -- ERROR: (L) D1.
               RECORD NULL; END RECORD;

          TYPE T1B (D : I1 := V) IS          -- ERROR: (C) I1.
               RECORD NULL; END RECORD;

          TYPE T2A (D : I := V1) IS          -- ERROR: (B) V1.
               RECORD NULL; END RECORD;

          TYPE T2B (D : I1 := (VV1)) IS      -- ERROR: (M) ()'S.
               RECORD NULL; END RECORD;

          TYPE T3 (D1 : I; D2, D3 : I) IS    -- ERROR: (H) D1, D2.
               RECORD NULL; END RECORD;

          TYPE T4A (D : BOOLEAN :=
                        (TRUE = TRUE)) IS    -- ERROR: (E) AMBIGUOUS
                                             --   TRUE.
               RECORD NULL; END RECORD;

          TYPE T4B (D : BOOLEAN :=
               (TRUE = BOOLEAN'(TRUE))) IS   -- ERROR: (M)
                                             --   QUALIFICATION.
               RECORD NULL; END RECORD;

          TYPE T7A (D : I1 := WW1) IS        -- ERROR: (B) WW1.
               RECORD NULL; END RECORD;

          TYPE T7B (D : I := P1.W2) IS       -- OK: (A) P1.W2.
               RECORD NULL; END RECORD;

          TYPE T8A (D : I2 := W2) IS         -- OK: (A) I2, W2.
               RECORD NULL; END RECORD;

          TYPE T9A (D : I := 0 + 2) IS       -- ERROR: (G) 0 + 2.
               RECORD NULL; END RECORD;

          TYPE T9B (D : I2 := W2) IS         -- ERROR: (L) W2.
               RECORD NULL; END RECORD;

          TYPE T9C (D : I2 := "+"(2,0)) IS   -- ERROR: (G) "+"(2,0).
               RECORD NULL; END RECORD;

          TYPE T10 (D : BOOLEAN := FALSE) IS -- ERROR: (E) DIFFERENT 
                                             --   FALSE.
               RECORD NULL; END RECORD;

          TYPE T11 (D : STANDARD.BOOLEAN := STANDARD.FALSE) IS-- OK: (A)
                                                            -- STANDARD.
               RECORD NULL; END RECORD;

          TYPE T12A (D : INTEGER := 00100) IS     -- OK: (D) 00100.
               RECORD NULL; END RECORD;

          TYPE T12B (D : INTEGER := 8#144#) IS    -- OK: (D) 8#144#.
               RECORD NULL; END RECORD;

          TYPE T13 (D :                      -- OK: (K) NEW COMMENT.
                        INTEGER              -- OK: (K) DIFFERENT
                                             --   COMMENT.
                        := 0
                   ) IS
               RECORD NULL; END RECORD;

          TYPE T14 (D : INTEGER := 3 * 1) IS -- ERROR: (N) DIFFERENT *.
               RECORD NULL; END RECORD;

          TYPE T15 (D : INTEGER := 3 / 1) IS -- ERROR: (N) DIFFERENT /.
               RECORD NULL; END RECORD;

          TYPE T16A (D : P3.T) IS            -- OK: (A) P3.T.
               RECORD NULL; END RECORD;

          TYPE T16B (D : T) IS               -- OK: (A) T.
               RECORD NULL; END RECORD;

          TYPE T16C (D : NP3.T) IS           -- ERROR: (I) NP3.
               RECORD NULL; END RECORD;

          TYPE T17 (D : B38103C0.P3.T) IS    -- OK: (I) B38103C0.P3.T.
               RECORD NULL; END RECORD;

          TYPE T18 (D : I := F1(1,0)) IS     -- ERROR: (E) DIFFERENT F1.
               RECORD NULL; END RECORD;

          TYPE T19A (D : I := STANDARD."+"(1,0)) IS    -- ERROR: (O)
                                                       --  STANDARD."+".
               RECORD NULL; END RECORD;

          TYPE T19B (D : CHARACTER := 'A') IS     -- ERROR: (O) 'A'.
               RECORD NULL; END RECORD;

          TYPE T19C (D : CHARACTER := STANDARD.'A') IS -- OK: (O)
                                                       --  STANDARD.'A'.
               RECORD NULL; END RECORD;

          TYPE T20A (D : P5.I) IS            -- ERROR: (P) P5.I.
               RECORD NULL; END RECORD;

          TYPE T20B (D : I := P5.V1) IS      -- ERROR: (P) P5.V1.
               RECORD NULL; END RECORD;

          TYPE T21A (D : I := 0) IS          -- ERROR: (Q) := 0.
               RECORD NULL; END RECORD;

          TYPE T21B (D : I) IS               -- ERROR: (Q) MISSING := 0.
               RECORD NULL; END RECORD;

          TYPE T22 IS NEW RD;                -- ERROR: (R) MISSING
                                             --   DISCRIMINANT PART,
                                             --   NEW RD.

          TYPE T23 IS                        -- ERROR: (S) MISSING
                                             --   DISCRIMINANT PART.
               RECORD
                    D : I := 0;
               END RECORD;

          TYPE T24 (D : I := 0) IS NEW R;    -- ERROR: (T) NEW R.

END B38103C1;
