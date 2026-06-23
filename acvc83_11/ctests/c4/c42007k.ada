-- C42007K.ADA

-- CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED CORRECTLY.
-- IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY THE LOWER
-- BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE STRING LITERAL IS
-- USED AS:

-- THE EXPRESSION OF AN ENCLOSING RECORD OR ARRAY AGGREGATE, AND
-- THE EXPRESSION GIVES THE VALUE OF A RECORD OR ARRAY COMPONENT
-- (WHICH IS NECESSARILY CONSTRAINED).

-- TBN  8/5/86

WITH REPORT; USE REPORT;
PROCEDURE C42007K IS

BEGIN

     TEST("C42007K", "CHECK THE BOUNDS OF A STRING LITERAL WHEN USED " &
                     "AS THE EXPRESSION OF AN ENCLOSING RECORD OR " &
                     "ARRAY AGGREGATE, AND THE EXPRESSION GIVES THE " &
                     "VALUE OF A RECORD OR ARRAY COMPONENT");
     BEGIN

CASE_K :  BEGIN

     CASE_K1 : DECLARE

                    SUBTYPE SK1 IS INTEGER RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SK1 RANGE <>) OF CHARACTER;
                    SUBTYPE TE1 IS BASE(IDENT_INT(3) .. 5);
                    TYPE TE2 IS ARRAY(IDENT_INT(1) .. 2) OF TE1;

                    E1 : TE2;

               BEGIN

                    E1 := (1 .. 2 => "WHO");
                    IF E1'FIRST /= 1 OR E1'LAST /= 2 THEN
                         FAILED ("ARRAY BOUNDS INCORRECTLY DETERMINED");
                    END IF;
                    IF E1(1)'FIRST /= 3 OR E1(1)'LAST /= 5 OR
                       E1(2)'FIRST /= 3 OR E1(2)'LAST /= 5 THEN
                         FAILED ("STRING LITERAL BOUNDS DETERMINED " &
                                 "INCORRECTLY - 1");
                    END IF;
                    IF (E1(1) /= "WHO") OR (E1(2) /= "WHO") THEN
                         FAILED ("INCORRECT STRING LITERAL - 1");
                    END IF;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         FAILED ("CONSTRAINT_ERROR RAISED IN - 1");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED IN - 1");
               END CASE_K1;

     CASE_K2 : DECLARE

                    TYPE SK2 IS RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SK2 RANGE <>) OF CHARACTER;
                    SUBTYPE TE1 IS BASE(3 .. 5);
                    TYPE TER IS
                         RECORD
                              REC : TE1;
                         END RECORD;

                    E2 : TER;

               BEGIN

                    E2 := (REC => "WHY");
                    IF E2.REC'FIRST /= 3 OR E2.REC'LAST /= 5 THEN
                         FAILED ("BOUNDS DETERMINED INCORRECTLY - 2");
                    END IF;
                    IF E2.REC /= "WHY" THEN
                         FAILED ("INCORRECT STRING LITERAL - 2");
                    END IF;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         FAILED ("CONSTRAINT_ERROR RAISED IN - 2");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED IN - 2");
               END CASE_K2;

          END CASE_K;

     END;

     RESULT;

END C42007K;
