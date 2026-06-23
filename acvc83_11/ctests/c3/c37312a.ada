-- C37312A.ADA

-- OBJECTIVE:
--     CHECK THAT A DISCRIMINANT CAN HAVE A GENERIC FORMAL DISCRETE
--     TYPE WHEN IT DOES NOT GOVERN A VARIANT PART AND THAT AN
--     OBJECT OF A GENERIC FORMAL TYPE CAN CONSTRAIN A COMPONENT
--     IN A VARIANT PART.

-- HISTORY:
--     AH  08/22/86  CREATED ORIGINAL TEST.
--     JET 08/13/87  REVISED FROM CLASS 'A' TO CLASS 'C' TEST.

WITH REPORT; USE REPORT;

PROCEDURE C37312A IS

BEGIN
     TEST ("C37312A", "DISCRIMINANT TYPE IS GENERIC FORMAL TYPE");

     DECLARE
          TYPE T IS RANGE 1 ..5;

          GENERIC
               TYPE G1 IS RANGE <>;
          PACKAGE P IS
               TYPE G2 (D1 : G1) IS
                    RECORD
                         R1 : G1;
                         R2 : BOOLEAN;
                    END RECORD;

               TYPE STR IS ARRAY(G1 RANGE <>) OF INTEGER;
               TYPE G3 (D : G1; E : INTEGER) IS
                    RECORD
                         CASE E IS
                              WHEN 1 =>
                                   S1 : STR(G1'FIRST..D);
                              WHEN OTHERS =>
                                   S2 : INTEGER;
                         END CASE;
                    END RECORD;

          END P;

          PACKAGE PKG IS NEW P (G1 => T);
          USE PKG;

          A2: G2(1) := (1, 5, FALSE);
          A3: G3(5, 1) := (5, 1, (1, 2, 3, 4, 5));

     BEGIN
          A2.R2 := IDENT_BOOL (TRUE);
          A3.S1(1) := IDENT_INT (6);

          IF A2 /= (1, 5, TRUE) THEN
               FAILED ("INVALID CONTENTS OF RECORD A2");
          END IF;
          IF A3 /= (5, 1, (6, 2, 3, 4, 5)) THEN
               FAILED ("INVALID CONTENTS OF RECORD A3");
          END IF;
     END;

     RESULT;

END C37312A;
