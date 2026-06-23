-- CC1220A.ADA

-- OBJECTIVE:
--     CHECK THAT A GENERIC PART CAN REFER TO AN IMPLICITLY
--     DECLARED PREDEFINED OPERATOR.

-- HISTORY:
--     DAT 08/20/81  CREATED ORIGINAL TEST.
--     SPS 05/03/82
--     BCB 08/04/88  MODIFIED HEADER FORMAT AND ADDED CHECKS FOR OTHER
--                   OPERATIONS OF A DISCRETE TYPE.

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;

PROCEDURE CC1220A IS

BEGIN
     TEST ("CC1220A", "GENERIC PART CAN REFER TO IMPLICITLY " &
           "DECLARED OPERATORS");
     DECLARE
          GENERIC
               TYPE T IS RANGE <> ;
               P1 : T := 5;
               P2 : T := T(5);
               P3 : T := T'(5);
               P4 : T := 2 + T(IDENT_INT(3));
               P5 : T := T'(2) + 3;
               P6 : T := T'SUCC(T(2));
               P7 : BOOLEAN := (T(2) = 2);
               P8 : T := T'BASE'FIRST;
               P9 : T := T'FIRST;
               P10 : T := T'LAST;
               P11 : INTEGER := T'SIZE;
               P12 : ADDRESS := P10'ADDRESS;
               P13 : INTEGER := T'WIDTH;
               P14 : INTEGER := T'POS(P9);
               P15 : T := T'VAL(P14);
               P16 : T := T'PRED(T(2));
               P17 : STRING := T'IMAGE(P9);
               P18 : T := T'VALUE(" 3");
               P19 : BOOLEAN := (P15 IN T);
          PACKAGE PKG IS
               ARR : ARRAY (1 .. 6) OF T := (P1,P2,P3,P4,P5,P6);
               B1 : BOOLEAN := P7;
          END PKG;

          PACKAGE BODY PKG IS
          BEGIN
               IF P8 /= T(INTEGER'FIRST) THEN
                    FAILED ("IMPROPER VALUE FOR 'BASE'FIRST");
               END IF;

               IF P9 /= T(INTEGER'FIRST) THEN
                    FAILED ("IMPROPER VALUE FOR 'FIRST");
               END IF;

               IF P10 /= T(INTEGER'LAST) THEN
                    FAILED ("IMPROPER VALUE FOR 'LAST");
               END IF;

               IF NOT EQUAL(P11,INTEGER'SIZE) THEN
                    FAILED ("IMPROPER VALUE FOR 'SIZE");
               END IF;

               IF P12 /= P10'ADDRESS THEN
                    FAILED ("IMPROPER VALUE FOR 'ADDRESS");
               END IF;

               IF NOT EQUAL(P13,INTEGER'WIDTH) THEN
                    FAILED ("IMPROPER VALUE FOR 'WIDTH");
               END IF;

               IF NOT EQUAL(P14,INTEGER'POS(INTEGER'FIRST)) THEN
                    FAILED ("IMPROPER VALUE FOR 'POS");
               END IF;

               IF P15 /= T(INTEGER'VAL(INTEGER'FIRST)) THEN
                    FAILED ("IMPROPER VALUE FOR 'VAL");
               END IF;

               IF P16 /= T(IDENT_INT(1)) THEN
                    FAILED ("IMPROPER VALUE FOR 'PRED");
               END IF;

               IF P6 /= T(IDENT_INT(3)) THEN
                    FAILED ("IMPROPER VALUE FOR 'SUCC");
               END IF;

               IF P17 /= INTEGER'IMAGE(INTEGER'FIRST) THEN
                    FAILED ("IMPROPER VALUE FOR 'IMAGE");
               END IF;

               IF P18 /= T(IDENT_INT(3)) THEN
                    FAILED ("IMPROPER VALUE FOR 'VALUE");
               END IF;
          END PKG;

          PACKAGE N_P IS NEW PKG (T => INTEGER);

     BEGIN

          IF N_P.ARR(1) /= IDENT_INT(5) OR
             N_P.ARR(2) /= IDENT_INT(5) OR
             N_P.ARR(3) /= IDENT_INT(5) OR
             N_P.ARR(4) /= IDENT_INT(5) OR
             N_P.ARR(5) /= IDENT_INT(5) OR
             N_P.ARR(6) /= IDENT_INT(3) OR
             N_P.B1 /= TRUE THEN
               FAILED ("IMPLICITLY DECLARED OPERATORS UNSUCCESSFUL");
          END IF;

          RESULT;
     END;
END CC1220A;
