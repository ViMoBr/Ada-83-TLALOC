-- C43205J.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- THE LOWER BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE
-- POSITIONAL AGGREGATE IS USED AS:

--   J) THE INITIALIZATION EXPRESSION OF A CONSTANT, VARIABLE, OR FORMAL
--      PARAMETER (OF A SUBPROGRAM, ENTRY, OR GENERIC UNIT) WHEN THE
--      TYPE OF THE CONSTANT, VARIABLE, OR PARAMETER IS CONSTRAINED.

-- EG  01/27/84

WITH REPORT;

PROCEDURE C43205J IS

     USE REPORT;

BEGIN

     TEST("C43205J", "CASE J : INITIALIZATION OF CONSTRAINED " &
                     "ARRAY");

     BEGIN

CASE_J :  BEGIN

     CASE_J1 : DECLARE

                    TYPE TD1 IS ARRAY (IDENT_INT(11) .. 13) OF INTEGER;

                    D1 : CONSTANT TD1 := (-1, -2, -3);

               BEGIN

                    IF D1'FIRST /= 11 THEN
                         FAILED ("CASE J1 : LOWER BOUND INCORRECT");
                    ELSIF D1'LAST /= 13 THEN
                         FAILED ("CASE J1 : UPPER BOUND INCORRECT");
                    ELSIF D1 /= (-1, -2, -3) THEN
                              FAILED ("CASE J1 : ARRAY DOES NOT " &
                                      "CONTAINING THE CORRECT VALUES");
                    END IF;

               END CASE_J1;

     CASE_J2 : DECLARE

                    TYPE TD2 IS ARRAY(INTEGER RANGE -13 .. -11)
                                                            OF INTEGER;
                    D2 : TD2 := (3, 2, 1);

               BEGIN

                    IF D2'FIRST /= -13 THEN
                         FAILED ("CASE J2 : LOWER BOUND INCORRECT");
                    ELSIF D2'LAST /= -11 THEN
                         FAILED ("CASE J2 : UPPER BOUND INCORRECT");
                    ELSIF D2 /= (3, 2, 1) THEN
                         FAILED ("CASE J2 : INCORRECT VALUES");
                    END IF;

               END CASE_J2;

     CASE_J3 : DECLARE

                    TYPE TD3 IS ARRAY(IDENT_INT(5) .. 7) OF INTEGER;

                    PROCEDURE PROC1 (A : TD3 := (2, 3, 4)) IS
                    BEGIN
                         IF A'FIRST /= 5 THEN
                              FAILED ("CASE J3 : LOWER BOUND " &
                                      "INCORRECT");
                         ELSIF A'LAST /= 7 THEN
                              FAILED ("CASE J3 : UPPER BOUND " &
                                      "INCORRECT");
                         ELSIF A /= (2, 3, 4) THEN
                              FAILED ("CASE J3 : INCORRECT VALUES");
                         END IF;
                    END PROC1;

               BEGIN

               PROC1;

               END CASE_J3;

     CASE_J4 : DECLARE

                    TYPE TD4 IS ARRAY(5 .. 8) OF INTEGER;

                    GENERIC
                         D4 : TD4 := (1, -2, 3, -4);
                    PROCEDURE PROC1;

                    PROCEDURE PROC1 IS
                    BEGIN
                         IF D4'FIRST /= 5 THEN
                              FAILED ("CASE J4 : LOWER BOUND " &
                                      "INCORRECT");
                         ELSIF D4'LAST /= 8 THEN
                              FAILED ("CASE J4 : UPPER BOUND " &
                                      "INCORRECT");
                         ELSIF D4 /= (1, -2, 3, -4) THEN
                              FAILED ("CASE J4 : INCORRECT VALUES");
                         END IF;
                    END PROC1;

                    PROCEDURE PROC2 IS NEW PROC1;

               BEGIN

                    PROC2;

               END CASE_J4;

          END CASE_J;

     END;

     RESULT;

END C43205J;
