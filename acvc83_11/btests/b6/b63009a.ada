-- B63009A.ADA

-- CHECK THAT THE FORMAL PART OF A SUBPROGRAM SPECIFICATION IN A BODY
-- MUST CONFORM TO THAT GIVEN IN THE DECLARATION, IF ANY, EXCEPT FOR
-- THE POSSIBLE USE OF SELECTED COMPONENT NOTATION TO DISAMBIGUATE
-- NAMES, THE FORM OF NUMERIC LITERALS THAT HAVE THE SAME VALUE, THE
-- CASE OF LETTERS IN STRING LITERALS USED AS OPERATOR SYMBOLS, AND THE
-- PRESENCE OF COMMENTS.

-- CASE A: THE DECLARATION AND THE BODY ARE IN THE SAME DECLARATIVE
--         PART; FOR NON-GENERIC SUBPROGRAMS.

-- SUBCASES:
--   (A)  USE OF SIMPLE VS. EXPANDED NAMES.
--   (B)  MISUSE OF RENAMED ENTITIES.
--   (C)  MISUSE OF SUBTYPES.
--   (D)  USE OF DIFFERENT FORMS OF INTEGER LITERALS.
--   (E)  MISUSE OF SIMPLE NAMES DENOTING DIFFERENT FUNCTIONS OR
--        OBJECTS.
--   (F)  USE OF STRING LITERALS AS OPERATOR SYMBOLS VS. MISUSE OF
--        STRING LITERALS AS SOMETHING OTHER THAN OPERATOR SYMBOLS.
--        (TESTED ELSEWHERE).
--   (G)  MISUSE OF INFIX VS. FUNCTIONAL FORM OF OPERATOR INVOCATION;
--        MISUSE OF COMMUTATIVITY OF CERTAIN OPERATORS.
--   (H)  MISUSE OF SINGLE VS. MULTIPLE PARAMETER DECLARATIONS.
--   (I)  USE/MISUSE OF EXPANDED VS. EXPANDED NAMES.
--   (J)  MISUSE OF PRAGMAS (TESTED ELSEWHERE).
--   (K)  USE OF COMMENTS.
--   (L)  MISUSE OF (DIFFERENT) PARAMETER NAMES.
--   (M)  MISUSE OF LEXICAL FORM OF EXPRESSIONS, E.G., EXTRA PARENTHESES
--        OR QUALIFICATION.
--   (N)  MISUSE OF SAME OPERATORS WITH DIFFERENT MEANINGS.
--   (O)  MISUSE OF SIMPLE VS. EXPANDED NAMES FOR OPERATOR SYMBOLS AND
--        CHARACTER LITERALS.
--   (P)  MISUSE OF EXPANDED NAMES ASSOCIATED WITH RENAMING OR SUBTYPE
--        DECLARATIONS.
--   (Q)  MISUSE OF PRESENCE/ABSENCE OF DEFAULT EXPRESSIONS.
--   (R)  MISUSE OF PARAMETER MODES.

-- JRK 2/24/84

PROCEDURE B63009A IS

     SUBTYPE I IS INTEGER RANGE 0..2;
     SUBTYPE I1 IS I;

     V1, V2, V : I := 0;

     PACKAGE P1 IS
          SUBTYPE I2 IS I1;
          W1, W2 : I := 0;
     END P1;
     USE P1;

     WW1 : I RENAMES P1.W1;
     VV1 : I RENAMES V1;

     PACKAGE P3 IS
          SUBTYPE T IS I;
     END P3;
     USE P3;

     FUNCTION F1 (L, R : INTEGER) RETURN INTEGER RENAMES STANDARD."+";

BEGIN
     DECLARE

          PROCEDURE T1A (D : I := V);
          PROCEDURE T1B (D : I := V);

          PROCEDURE T2A (D : I := VV1);
          PROCEDURE T2B (D : I1 := VV1);

          PROCEDURE T3 (D1, D2 : I; D3 : I);

          PROCEDURE T4A (D : BOOLEAN := (TRUE = TRUE));
          PROCEDURE T4B (D : BOOLEAN := (TRUE = TRUE));

          PROCEDURE T7A (D : I1 := W1);
          PROCEDURE T7B (D : I := W2);

          PROCEDURE T8A (D : P1.I2 := P1.W2);

          PROCEDURE T9A (D : I := 2 + 0);
          PROCEDURE T9B (D : P1.I2 := P1.W1);
          PROCEDURE T9C (D : I2 := 2 + 0);

          PROCEDURE T10 (D : BOOLEAN := FALSE);
          PROCEDURE T11 (D : BOOLEAN := FALSE);

          PROCEDURE T12A (D : INTEGER := 100);
          PROCEDURE T12B (D : INTEGER := 1E2);

          PROCEDURE T13 (D : INTEGER         -- A COMMENT.
                             := 0            -- ANOTHER COMMENT.
                        );

          PROCEDURE T14 (D : INTEGER := 3 * 1);
          FUNCTION "*" (L, R : INTEGER) RETURN INTEGER
                       RENAMES STANDARD."*";
          PROCEDURE T15 (D : INTEGER := 3 / 1);
          FUNCTION "/" (L, R : INTEGER) RETURN INTEGER RENAMES "+";

          PACKAGE NP3 RENAMES P3;
          PROCEDURE T16A (D : T);
          PROCEDURE T16B (D : NP3.T);
          PROCEDURE T16C (D : P3.T);
          PROCEDURE T17 (D : P3.T);

          PROCEDURE T18 (D : I := F1(1,0));
          FUNCTION F1 (L, R : INTEGER) RETURN INTEGER
                      RENAMES STANDARD."+";

          PROCEDURE T19A (D : I := "+"(1,0));
          PROCEDURE T19B (D : CHARACTER := STANDARD.'A');
          PROCEDURE T19C (D : CHARACTER := STANDARD.'A');

          PROCEDURE T20A (D : I);
          PROCEDURE T20B (D : I := V1);

          PACKAGE P5 IS
               V1 : I RENAMES B63009A.V1;
               SUBTYPE I IS B63009A.I;
          END P5;

          PROCEDURE T21A (D : I);
          PROCEDURE T21B (D : I := 0);

          PROCEDURE T22A (D : I);
          PROCEDURE T22B (D : IN I);
          PROCEDURE T22C (D : IN I);
          PROCEDURE T22D (D : IN OUT I);
          PROCEDURE T22E (D : IN I);
          PROCEDURE T22F (D : IN OUT I);
          PROCEDURE T22G (D : OUT I);

          F : CONSTANT BOOLEAN := FALSE;
          TYPE NONBOOL IS (TRUE, TOO_TRUE);
          FALSE : CONSTANT BOOLEAN := F;

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

          PROCEDURE T17 (D : B63009A.P3.T) IS     -- OK: (I)
                                                  --   B63009A.P3.T.
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

     BEGIN
          NULL;
     END;
END B63009A;
