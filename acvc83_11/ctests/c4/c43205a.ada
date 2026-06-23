-- C43205A.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- 'FIRST OF THE INDEX SUBTYPE WHEN THE POSITIONAL AGGREGATE IS USED AS:

--   A) AN ACTUAL PARAMETER IN A SUBPROGRAM OR ENTRY CALL, AND THE
--      FORMAL PARAMETER IS UNCONSTRAINED.

-- EG  01/26/84

WITH REPORT;

PROCEDURE C43205A IS

     USE REPORT;

BEGIN

     TEST("C43205A", "CASE A1 : SUBPROGRAM WITH UNCONSTRAINED " &
                     "ONE-DIMENSIONAL ARRAY FORMAL PARAMETER");

     BEGIN

CASE_A :  BEGIN

     CASE_A1 : DECLARE

                    SUBTYPE STA IS INTEGER RANGE 11 .. 15;
                    TYPE TA IS ARRAY (STA RANGE <>) OF INTEGER;

                    PROCEDURE PROC1 (A : TA) IS
                    BEGIN
                         IF A'FIRST /= IDENT_INT(11) THEN
                              FAILED ("CASE A1 : LOWER BOUND " &
                                      "INCORRECTLY GIVEN BY 'FIRST");
                         ELSIF A'LAST /= 15 THEN
                              FAILED ("CASE A1 : UPPER BOUND " &
                                      "INCORRECTLY GIVEN BY 'LAST");
                         ELSIF A /= (6, 7, 8, 9, 10) THEN
                              FAILED ("CASE A1 : ARRAY DOES NOT " &
                                     "CONTAIN THE CORRECT VALUES");
                         END IF;
                    END;

               BEGIN

                    PROC1 ((6, 7, 8, 9, IDENT_INT(10)));

               END CASE_A1;

               COMMENT ("CASE A2 : SUBPROGRAM WITH UNCONSTRAINED " &
                        "TWO-DIMENSIONAL ARRAY FORMAL PARAMETER");

     CASE_A2 : DECLARE

                    SUBTYPE STA1 IS INTEGER RANGE 11 .. IDENT_INT(12);
                    SUBTYPE STA2 IS INTEGER RANGE 10 .. 11;
                    TYPE TA IS ARRAY (STA1 RANGE <>, STA2 RANGE <>)
                                    OF INTEGER;

                    PROCEDURE PROC1 (A : TA) IS
                    BEGIN
                         IF A'FIRST(1) /= 11 OR A'FIRST(2) /= 10 THEN
                              FAILED ("CASE A2 : LOWER BOUND " &
                                      "INCORRECTLY GIVEN BY 'FIRST");
                         ELSIF A'LAST(1) /= 12 OR 
                               A'LAST(2) /= IDENT_INT(11) THEN
                              FAILED ("CASE A2 : UPPER BOUND " &
                                      "INCORRECTLY GIVEN BY 'LAST");
                         ELSIF A /= ((1, 2), (3, 4)) THEN
                              FAILED ("CASE A2 : ARRAY DOES NOT " &
                                     "CONTAIN THE CORRECT VALUES");
                         END IF;
                    END;

               BEGIN

                    PROC1 (((1, 2), (IDENT_INT(3), 4)));

               END CASE_A2;

          END CASE_A;

     END;

     RESULT;

END C43205A;
