-- B63009C2.ADA

-- JRK 2/24/84

PACKAGE BODY B63009C1 IS

          PROCEDURE T1A (D1 : I := V) IS     -- ERROR: (L) D1.
               BEGIN NULL; END;

          PROCEDURE T1B (D : I1 := V) IS     -- ERROR: (C) I1.
               BEGIN NULL; END;

          PROCEDURE T2A (D : I := V1) IS     -- ERROR: (B) V1.
               BEGIN NULL; END;

          PROCEDURE T2B (D : I1 := (VV1)) IS -- ERROR: (M) ()'S.
               BEGIN NULL; END;

          PROCEDURE T3 (D1 : I; D2, D3 : I) IS    -- ERROR: (H) D1, D2.
               BEGIN NULL; END;

          PROCEDURE T4A (D : BOOLEAN :=
                        (TRUE = TRUE)) IS    -- ERROR: (E) AMBIGUOUS
                                             --   TRUE.
               BEGIN NULL; END;

          PROCEDURE T4B (D : BOOLEAN :=
               (TRUE = BOOLEAN'(TRUE))) IS   -- ERROR: (M)
                                             --   QUALIFICATION.
               BEGIN NULL; END;

          PROCEDURE T7A (D : I1 := WW1) IS   -- ERROR: (B) WW1.
               BEGIN NULL; END;

          PROCEDURE T7B (D : I := P1.W2) IS  -- OK: (A) P1.W2.
               BEGIN NULL; END;

          PROCEDURE T8A (D : I2 := W2) IS    -- OK: (A) I2, W2.
               BEGIN NULL; END;

          PROCEDURE T9A (D : I := 0 + 2) IS  -- ERROR: (G) 0 + 2.
               BEGIN NULL; END;

          PROCEDURE T9B (D : I2 := W2) IS    -- ERROR: (L) W2.
               BEGIN NULL; END;

          PROCEDURE T9C (D : I2 := "+"(2,0)) IS  -- ERROR: (G) "+"(2,0).
               BEGIN NULL; END;

          PROCEDURE T10 (D : BOOLEAN := FALSE) IS -- ERROR: (E)
                                                  --   DIFFERENT FALSE.
               BEGIN NULL; END;

          PROCEDURE T11 (D : STANDARD.BOOLEAN := STANDARD.FALSE) IS--OK:
                                                       -- (A) STANDARD.
               BEGIN NULL; END;

          PROCEDURE T12A (D : INTEGER := 00100) IS     -- OK: (D) 00100.
               BEGIN NULL; END;

          PROCEDURE T12B (D : INTEGER := 8#144#) IS   -- OK: (D) 8#144#.
               BEGIN NULL; END;

          PROCEDURE T13 (D :                 -- OK: (K) NEW COMMENT.
                             INTEGER         -- OK: (K) DIFFERENT
                                             --   COMMENT.
                             := 0
                        ) IS
               BEGIN NULL; END;

          PROCEDURE T14 (D : INTEGER := 3 * 1) IS -- ERROR: (N)
                                                  --   DIFFERENT *.
               BEGIN NULL; END;

          PROCEDURE T15 (D : INTEGER := 3 / 1) IS -- ERROR: (N)
                                                  --   DIFFERENT /.
               BEGIN NULL; END;

          PROCEDURE T16A (D : P3.T) IS       -- OK: (A) P3.T.
               BEGIN NULL; END;

          PROCEDURE T16B (D : T) IS          -- OK: (A) T.
               BEGIN NULL; END;

          PROCEDURE T16C (D : NP3.T) IS      -- ERROR: (I) NP3.
               BEGIN NULL; END;

          PROCEDURE T17 (D : B63009C0.P3.T) IS    -- OK: (I)
                                                  --   B63009C0.P3.T.
               BEGIN NULL; END;

          PROCEDURE T18 (D : I := F1(1,0)) IS     -- ERROR: (E)
                                                  --   DIFFERENT F1.
               BEGIN NULL; END;

          PROCEDURE T19A (D : I := STANDARD."+"(1,0)) IS   -- ERROR: (O)
                                                       --  STANDARD."+".
               BEGIN NULL; END;

          PROCEDURE T19B (D : CHARACTER := 'A') IS    -- ERROR: (O) 'A'.
               BEGIN NULL; END;

          PROCEDURE T19C (D : CHARACTER := STANDARD.'A') IS -- OK: (O)
                                                       --  STANDARD.'A'.
               BEGIN NULL; END;

          PROCEDURE T20A (D : P5.I) IS       -- ERROR: (P) P5.I.
               BEGIN NULL; END;

          PROCEDURE T20B (D : I := P5.V1) IS -- ERROR: (P) P5.V1.
               BEGIN NULL; END;

          PROCEDURE T21A (D : I := 0) IS     -- ERROR: (Q) := 0.
               BEGIN NULL; END;

          PROCEDURE T21B (D : I) IS          -- ERROR: (Q) MISSING := 0.
               BEGIN NULL; END;

          PROCEDURE T22A (D : IN I) IS       -- ERROR: (R) IN.
               BEGIN NULL; END;

          PROCEDURE T22B (D : I) IS          -- ERROR: (R) MISSING IN.
               BEGIN NULL; END;

          PROCEDURE T22C (D : IN OUT I) IS   -- ERROR: (R) IN OUT.
               BEGIN NULL; END;

          PROCEDURE T22D (D : OUT I) IS      -- ERROR: (R) OUT.
               BEGIN NULL; END;

          PROCEDURE T22E (D : OUT I) IS      -- ERROR: (R) OUT.
               BEGIN NULL; END;

          PROCEDURE T22F (D : I) IS          -- ERROR: (R) MISSING IN
                                             --   OUT.
               BEGIN NULL; END;

          PROCEDURE T22G (D : I) IS          -- ERROR: (R) MISSING OUT.
               BEGIN NULL; END;

END B63009C1;
