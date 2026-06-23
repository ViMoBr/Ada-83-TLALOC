-- C35502K.ADA

-- CHECK THAT 'POS' AND 'VAL' YIELD THE CORRECT RESULTS WHEN
-- THE PREFIX IS AN ENUMERATION TYPE OTHER THAN  A BOOLEAN OR A
-- CHARACTER TYPE.

-- RJW 5/27/86
-- GMT 7/02/87  ADDED ENUM'VAL(3) CHECK NEAR END OF 2ND BLOCK STATEMENT.


WITH REPORT; USE REPORT;

PROCEDURE C35502K IS

     TYPE ENUM IS (A, BC, ABC, A_B_C, ABCD);
     SUBTYPE SUBENUM IS ENUM RANGE A .. BC;

     TYPE NEWENUM IS NEW ENUM;
     SUBTYPE SUBNEW IS NEWENUM RANGE A .. BC;

BEGIN
     TEST ("C35502K", "CHECK THAT 'POS' AND 'VAL' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS AN " &
                      "ENUMERATION TYPE OTHER THAN A CHARACTER " &
                      "OR A BOOLEAN TYPE" );

     DECLARE
          POSITION : INTEGER;
     BEGIN
          POSITION := 0;

          FOR E IN ENUM LOOP
               IF SUBENUM'POS (E) /= POSITION THEN
                    FAILED ( "INCORRECT SUBENUM'POS (" &
                              ENUM'IMAGE (E) & ")" );
               END IF;

               IF SUBENUM'VAL (POSITION) /= E THEN
                    FAILED ( "INCORRECT SUBENUM'VAL (" &
                              INTEGER'IMAGE (POSITION) &
                             ")" );
               END IF;

               POSITION := POSITION + 1;
          END LOOP;

          POSITION := 0;
          FOR E IN NEWENUM LOOP
               IF SUBNEW'POS (E) /= POSITION THEN
                    FAILED ( "INCORRECT SUBNEW'POS (" &
                              NEWENUM'IMAGE (E) & ")" );
               END IF;

               IF SUBNEW'VAL (POSITION) /= E THEN
                    FAILED ( "INCORRECT SUBNEW'VAL (" &
                              INTEGER'IMAGE (POSITION) &
                             ")" );
               END IF;

               POSITION := POSITION + 1;
          END LOOP;
     END;

     DECLARE
          FUNCTION A_B_C RETURN ENUM IS
          BEGIN
               RETURN ENUM'VAL (IDENT_INT (0));
          END A_B_C;

     BEGIN
          IF ENUM'VAL (0) /= A_B_C THEN
               FAILED ( "WRONG ENUM'VAL (0) WHEN HIDDEN " &
                        "BY FUNCTION - 1" );
          END IF;

          IF ENUM'VAL (0) = C35502K.A_B_C THEN
               FAILED ( "WRONG ENUM'VAL (0) WHEN HIDDEN " &
                        "BY FUNCTION - 2" );
          END IF;

          IF ENUM'VAL (3) /= C35502K.A_B_C THEN
               FAILED ( "WRONG ENUM'VAL (3) WHEN HIDDEN " &
                        "BY FUNCTION - 3" );
          END IF;
     END;

     BEGIN
          IF ENUM'VAL (IDENT_INT (-1)) = A THEN
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR ENUM'VAL (IDENT_INT (-1)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR ENUM'VAL (IDENT_INT (-1)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED " &
                        "FOR ENUM'VAL (IDENT_INT (-1))" );
     END;

     BEGIN
          IF NEWENUM'VAL (IDENT_INT (-1)) = A THEN
               FAILED ( "NO EXCEPTION RAISED FOR " &
                        "NEWENUM'VAL (IDENT_INT (-1)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR " &
                        "NEWENUM'VAL (IDENT_INT (-1)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "NEWENUM'VAL (IDENT_INT (-1))" );
     END;

     BEGIN
          IF ENUM'VAL (IDENT_INT (5)) = A THEN
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR ENUM'VAL (IDENT_INT (5)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR ENUM'VAL (IDENT_INT (5)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED " &
                        "FOR ENUM'VAL (IDENT_INT (5))" );
     END;

     BEGIN
          IF NEWENUM'VAL (IDENT_INT (5)) = A THEN
               FAILED ( "NO EXCEPTION RAISED FOR " &
                        "NEWENUM'VAL (IDENT_INT (5)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR " &
                        "NEWENUM'VAL (IDENT_INT (5)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "NEWENUM'VAL (IDENT_INT (5))" );
     END;

     RESULT;
END C35502K;
