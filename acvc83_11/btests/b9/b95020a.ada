-- B95020A.ADA

-- CHECK THAT THE FORMAL PART OF AN ACCEPT STATEMENT MUST CONFORM TO
-- THAT GIVEN IN THE ENTRY DECLARATION, EXCEPT FOR THE POSSIBLE USE OF
-- SELECTED COMPONENT NOTATION TO DISAMBIGUATE NAMES, THE FORM OF
-- NUMERIC LITERALS THAT HAVE THE SAME VALUE, THE CASE OF LETTERS IN
-- STRING LITERALS USED AS OPERATOR SYMBOLS, AND THE PRESENCE OF
-- COMMENTS.

-- CASE A: THE TASK DECLARATION AND ITS BODY ARE IN THE SAME DECLARATIVE
--         PART, AND ARE NOT SEPARATELY COMPILED.

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

-- JRK 2/27/84

PROCEDURE B95020A IS

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

     PACKAGE NP3 RENAMES P3;

     FUNCTION F1 (L, R : INTEGER) RETURN INTEGER RENAMES STANDARD."+";

     TASK TYPE TASK1 IS

          ENTRY T1A (D : I := V);
          ENTRY T1B (D : I := V);

          ENTRY T2A (D : I := VV1);
          ENTRY T2B (D : I1 := VV1);

          ENTRY T3 (D1, D2 : I; D3 : I);

          ENTRY T4A (D : BOOLEAN := (TRUE = TRUE));
          ENTRY T4B (D : BOOLEAN := (TRUE = TRUE));

          ENTRY T7A (D : I1 := W1);
          ENTRY T7B (D : I := W2);

          ENTRY T8A (D : P1.I2 := P1.W2);

          ENTRY T9A (D : I := 2 + 0);
          ENTRY T9B (D : P1.I2 := P1.W1);
          ENTRY T9C (D : I2 := 2 + 0);

          ENTRY T10 (D : BOOLEAN := FALSE);
          ENTRY T11 (D : BOOLEAN := FALSE);

          ENTRY T12A (D : INTEGER := 100);
          ENTRY T12B (D : INTEGER := 1E2);

          ENTRY T13 (D : INTEGER             -- A COMMENT.
                         := 0                -- ANOTHER COMMENT.
                    );

          ENTRY T14 (D : INTEGER := 3 * 1);
          ENTRY T15 (D : INTEGER := 3 / 1);

          ENTRY T16A (D : T);
          ENTRY T16B (D : NP3.T);
          ENTRY T16C (D : P3.T);
          ENTRY T17 (D : P3.T);

          ENTRY T18 (D : I := F1(1,0));

          ENTRY T19A (D : I := "+"(1,0));
          ENTRY T19B (D : CHARACTER := STANDARD.'A');
          ENTRY T19C (D : CHARACTER := STANDARD.'A');

          ENTRY T20A (D : I);
          ENTRY T20B (D : I := V1);

          ENTRY T21A (D : I);
          ENTRY T21B (D : I := 0);

          ENTRY T22A (D : I);
          ENTRY T22B (D : IN I);
          ENTRY T22C (D : IN I);
          ENTRY T22D (D : IN OUT I);
          ENTRY T22E (D : IN I);
          ENTRY T22F (D : IN OUT I);
          ENTRY T22G (D : OUT I);

     END TASK1;

     TASK BODY TASK1 IS

          FUNCTION "*" (L, R : INTEGER) RETURN INTEGER
                       RENAMES STANDARD."*";
          FUNCTION "/" (L, R : INTEGER) RETURN INTEGER RENAMES "+";

          FUNCTION F1 (L, R : INTEGER) RETURN INTEGER
                      RENAMES STANDARD."+";

          PACKAGE P5 IS
               V1 : I RENAMES B95020A.V1;
               SUBTYPE I IS B95020A.I;
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

          ACCEPT T17 (D : B95020A.P3.T);     -- OK: (I)
                                             --   B95020A.P3.T.

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

BEGIN
     NULL;
END B95020A;
