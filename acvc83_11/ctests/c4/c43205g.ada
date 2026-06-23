-- C43205G.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- THE LOWER BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE
-- POSITIONAL AGGREGATE IS USED AS:

-- AN ACTUAL PARAMETER IN A SUBPROGRAM, AND THE
-- FORMAL PARAMETER IS CONSTRAINED.

-- EG  01/27/84

WITH REPORT;

PROCEDURE C43205G IS

     USE REPORT;

BEGIN

     TEST("C43205G", "SUBPROGRAM WITH CONSTRAINED " &
                     "ONE-DIMENSIONAL ARRAY FORMAL PARAMETER");

     BEGIN

CASE_G :  BEGIN

     CASE_G1 : DECLARE

                    TYPE TA IS ARRAY (IDENT_INT(11) .. 15) OF INTEGER;

                    PROCEDURE PROC1 (A : TA) IS
                    BEGIN
                         IF A'FIRST /= 11 THEN
                              FAILED ("CASE A1 : LOWER BOUND " &
                                      "INCORRECT");
                         ELSIF A'LAST /= 15 THEN
                              FAILED ("CASE A1 : UPPER BOUND " &
                                      "INCORRECT");
                         ELSIF A /= (6, 7, 8, 9, 10) THEN
                              FAILED ("CASE A1 : ARRAY DOES NOT " &
                                     "CONTAIN THE CORRECT VALUES");
                         END IF;
                    END;

               BEGIN

                    PROC1 ((6, 7, 8, IDENT_INT(9), 10));

               END CASE_G1;

     CASE_G2 : DECLARE

                    TYPE TA IS ARRAY (11 .. 12, 
                                      IDENT_INT(10) .. 11) OF INTEGER;

                    PROCEDURE PROC1 (A : TA) IS
                    BEGIN
                         IF A'FIRST(1) /= 11 OR A'FIRST(2) /= 10 THEN
                              FAILED ("CASE A2 : LOWER BOUND " &
                                      "INCORRECT");
                         ELSIF A'LAST(1) /= 12 OR A'LAST(2) /= 11 THEN
                              FAILED ("CASE A2 : UPPER BOUND " &
                                      "INCORRECT");
                         ELSIF A /= ((1, 2), (3, 4)) THEN
                              FAILED ("CASE A2 : ARRAY DOES NOT " &
                                      "CONTAIN THE CORRECT VALUES");
                         END IF;
                    END;

               BEGIN

                    PROC1 (((1, 2), (3, 4)));

               END CASE_G2;

          END CASE_G;

     END;

     RESULT;

END C43205G;
