-- B63009C1.ADA

-- JRK 2/24/84

WITH B63009C0; USE B63009C0;

PACKAGE B63009C1 IS

          USE P1;
          USE P3;

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
               V1 : I RENAMES B63009C0.V1;
               SUBTYPE I IS B63009C0.I;
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

END B63009C1;
