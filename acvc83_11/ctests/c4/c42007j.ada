-- C42007J.ADA

-- CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED CORRECTLY.
-- IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY THE LOWER
-- BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE STRING LITERAL
-- IS USED AS:

--   J) THE INITIALIZATION EXPRESSION OF A CONSTANT, VARIABLE, OR FORMAL
--      PARAMETER (OF A SUBPROGRAM, ENTRY, OR GENERIC UNIT) WHEN THE
--      TYPE OF THE CONSTANT, VARIABLE, OR PARAMETER IS CONSTRAINED.

-- TBN  7/30/86

WITH REPORT; USE REPORT;
PROCEDURE C42007J IS

BEGIN

     TEST("C42007J", "CHECK THE BOUNDS OF A STRING LITERAL WHEN " &
                     "USED AS THE INITIALIZATION EXPRESSION OF A " &
                     "CONSTRAINED ENTITY");
     BEGIN

CASE_J :  BEGIN

     CASE_J1 : DECLARE

                    SUBTYPE TD1 IS STRING (IDENT_INT(11) .. 13);

                    D1 : CONSTANT TD1 := "WHY";

               BEGIN

                    IF D1'FIRST /= 11 THEN
                         FAILED ("LOWER BOUND INCORRECTLY " &
                                 "DETERMINED - 1");
                    END IF;
                    IF D1'LAST /= 13 THEN
                         FAILED ("UPPER BOUND INCORRECTLY" &
                                 "DETERMINED - 1");
                    END IF;
                    IF D1 /= "WHY" THEN
                         FAILED ("INCORRECT STRING LITERAL - 1");
                    END IF;

               END CASE_J1;

     CASE_J2 : DECLARE

                    SUBTYPE TD2 IS STRING (IDENT_INT(13) .. 15);

                    D2 : TD2 := "WHO";

               BEGIN

                    IF D2'FIRST /= IDENT_INT(13) THEN
                         FAILED ("LOWER BOUND INCORRECTLY " &
                                 "DETERMINED - 2");
                    END IF;
                    IF D2'LAST /= IDENT_INT(15) THEN
                         FAILED ("UPPER BOUND INCORRECTLY " &
                                 "DETERMINED - 2");
                    END IF;
                    IF D2 /= "WHO" THEN
                         FAILED ("INCORRECT STRING LITERAL - 2");
                    END IF;

               END CASE_J2;

     CASE_J3 : DECLARE

                    SUBTYPE TD3 IS STRING (IDENT_INT(5) .. 8);

                    PROCEDURE PROC1 (A : TD3 := "WHAT") IS
                    BEGIN
                         IF A'FIRST /= IDENT_INT(5) THEN
                              FAILED ("LOWER BOUND INCORRECTLY " &
                                      "DETERMINED - 3");
                         END IF;
                         IF A'LAST /= IDENT_INT(8) THEN
                              FAILED ("UPPER BOUND INCORRECTLY " &
                                      "DETERMINED - 3");
                         END IF;
                         IF A /= "WHAT" THEN
                              FAILED ("INCORRECT STRING LITERAL - 3");
                         END IF;
                    END PROC1;

               BEGIN

                    PROC1;

               END CASE_J3;

     CASE_J4 : DECLARE

                    SUBTYPE TD4 IS STRING (IDENT_INT(5) .. 8);

                    GENERIC
                         D4 : TD4 := "WHEN";
                    PROCEDURE PROC1;

                    PROCEDURE PROC1 IS
                    BEGIN
                         IF D4'FIRST /= IDENT_INT(5) THEN
                              FAILED ("LOWER BOUND INCORRECTLY " &
                                      "DETERMINED - 4");
                         END IF;
                         IF D4'LAST /= IDENT_INT(8) THEN
                              FAILED ("UPPER BOUND INCORRECTLY " &
                                      "DETERMINED - 4");
                         END IF;
                         IF D4 /= "WHEN" THEN
                              FAILED ("INCORRECT STRING LITERAL - 4");
                         END IF;
                    END PROC1;

                    PROCEDURE PROC2 IS NEW PROC1;

               BEGIN

                    PROC2;

               END CASE_J4;

     CASE_J5 : DECLARE

                    SUBTYPE TD5 IS STRING (IDENT_INT(2) .. 5);

                    TASK T1 IS
                         ENTRY E1 (A : TD5 := "FIVE");
                    END T1;

                    TASK BODY T1 IS
                    BEGIN
                         ACCEPT E1 (A : TD5 := "FIVE") DO
                              IF A'FIRST /= IDENT_INT(2) THEN
                                   FAILED ("LOWER BOUND INCORRECTLY " &
                                           "DETERMINED - 5");
                              END IF;
                              IF A'LAST /= IDENT_INT(5) THEN
                                   FAILED ("UPPER BOUND INCORRECTLY " &
                                           "DETERMINED - 5");
                              END IF;
                              IF A /= "FIVE" THEN
                                   FAILED ("INCORRECT STRING LITERAL " &
                                           "- 5");
                              END IF;
                         END E1;
                    END T1;

               BEGIN

                    T1.E1;

               END CASE_J5;

          END CASE_J;

     END;

     RESULT;

END C42007J;
