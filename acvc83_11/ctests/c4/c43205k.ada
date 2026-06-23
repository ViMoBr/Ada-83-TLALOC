-- C43205K.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- THE LOWER BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE
-- POSITIONAL AGGREGATE IS USED AS:

-- THE EXPRESSION OF AN ENCLOSING RECORD OR ARRAY AGGREGATE, AND
-- THE EXPRESSION GIVES THE VALUE OF A RECORD OR ARRAY COMPONENT
-- (WHICH IS NECESSARILY CONSTRAINED).

-- EG  01/27/84
-- JBG 3/30/84

WITH REPORT;

PROCEDURE C43205K IS

     USE REPORT;

BEGIN

     TEST("C43205K", "THE EXPRESSION OF AN ENCLOSING RECORD " &
                     "OR ARRAY AGGREGATE, AND THE EXPRESSION GIVES "   &
                     "THE VALUE OF A RECORD OR ARRAY COMPONENT");

     BEGIN

CASE_K :  BEGIN

     CASE_K1 : DECLARE

                    SUBTYPE SK1 IS INTEGER RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SK1 RANGE <>) OF INTEGER;
                    SUBTYPE TE1 IS BASE(IDENT_INT(3) .. 5);
                    TYPE TE2 IS ARRAY(1 .. 2) OF TE1;

                    E1 : TE2;

               BEGIN

                    E1 := (1 .. 2 => (3, 2, 1));
                    IF (E1'FIRST /= 1 OR E1'LAST /= 2) OR ELSE
                       (E1(1)'FIRST /= 3 OR E1(1)'LAST /= 5 OR
                        E1(2)'FIRST /= 3 OR E1(2)'LAST /= 5) THEN
                         FAILED ("CASE K1 : INCORRECT BOUNDS");
                    ELSE
                         IF E1 /= (1 .. 2 => (3, 2, 1)) THEN
                              FAILED ("CASE K1 : ARRAY DOES NOT " &
                                      "CONTAIN THE CORRECT VALUES");
                         END IF;
                    END IF;

               END CASE_K1;

     CASE_K2 : DECLARE

                    TYPE SK2 IS RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SK2 RANGE <>) OF INTEGER;
                    SUBTYPE TE1 IS BASE(3 .. 5);
                    TYPE TER IS
                         RECORD
                              REC : TE1;
                         END RECORD;

                    E2 : TER;

               BEGIN

                    E2 := (REC => (3, 2, 1));
                    IF E2.REC'FIRST /= 3 OR E2.REC'LAST /= 5 THEN
                         FAILED ("CASE K2 : INCORRECT BOUNDS");
                    ELSE
                         IF E2.REC /= (3, 2, 1) THEN
                              FAILED ("CASE K2 : ARRAY DOES NOT " &
                                      "CONTAIN CORRECT VALUES");
                         END IF;
                    END IF;

               END CASE_K2;

          END CASE_K;

     END;

     RESULT;

END C43205K;
