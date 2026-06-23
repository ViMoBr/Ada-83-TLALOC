-- CC3504E.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT
-- CONSTRAINT_ERROR IS RAISED WHEN CONSTRAINTS IMPOSED ON ITS DESIGNATED
-- TYPE T ARE NOT THE SAME AS THE CONSTRAINTS ON THE DESIGNATED TYPE OF
-- THE ACTUAL PARAMETER.

-- CHECK FOR SCALAR ACCESSED TYPES. (FIXED AND FLOAT ARE IN SEPERATE
-- TESTS).  NOTE: THE LACK OF A CONSTRAINT HAS THE SAME EFFECT AS
-- SUBTYPE'FIRST .. SUBTYPE'LAST.

-- CHECK WHEN T IS A GENERIC FORMAL TYPE APPEARING IN THE SAME FORMAL
-- PART.

-- DAT 9/24/81 
-- SPS 6/3/82

WITH REPORT; USE REPORT;

PROCEDURE CC3504E IS BEGIN
     TEST ("CC3504E", "CONSTRAINT_ERROR ON TYPES ACCESSED BY"
          & " GENERIC ACCESS TYPE PARAMETERS.  DESIGNATED TYPE IS A "
          & "FORMAL PARAMETER");

     FOR L IN IDENT_INT (1) .. IDENT_INT (4) LOOP
          COMMENT ("LOOP ITERATION");
          DECLARE
               SUBTYPE I IS INTEGER RANGE L .. IDENT_INT(3);
               SUBTYPE C IS CHARACTER RANGE CHARACTER'VAL(L)
                    .. CHARACTER'VAL (3);
               SUBTYPE B IS BOOLEAN RANGE BOOLEAN'VAL (L MOD 2)
                    .. BOOLEAN'VAL (IDENT_INT(3) MOD 2);
               TYPE AI IS ACCESS I;
               TYPE AC IS ACCESS C;
               TYPE AB IS ACCESS B;

               SUBTYPE INT IS INTEGER RANGE
                    IDENT_INT (2) .. IDENT_INT(3);
               SUBTYPE CH IS CHARACTER RANGE
                    IDENT_CHAR (ASCII.SOH).. ASCII.ETX;

               GENERIC
                    TYPE T IS (<>);
                    TYPE FT IS ACCESS T;
               PACKAGE P IS END P;

          BEGIN
               BEGIN
                    DECLARE
                         PACKAGE I1 IS NEW P (INT, AI);
                    BEGIN
                         IF L /= 2 THEN
                              FAILED ("INTEGER CONSTRAINT CHECK");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF L = 2 THEN
                              FAILED ("CONSTRAINT_ERROR RAISED " &
                                   "INAPPROPRIATELY ON INTEGERS");
                         END IF;
               END;

               BEGIN
                    DECLARE
                         PACKAGE I1 IS NEW P (CH, AC);
                    BEGIN
                         IF L /= 1 THEN
                              FAILED ("CHARACTER CONSTRAINT " &
                                   "CHECK");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF L = 1 THEN 
                              FAILED (" CONSTRAINT_ERROR RAISED " &
                                   " INAPPROPRIATELY ON CHARACTER");
                         END IF;
               END;

               BEGIN
                    DECLARE
                         PACKAGE I1 IS NEW P (BOOLEAN, AB);
                    BEGIN
                         IF B'FIRST /= FALSE OR B'LAST /= TRUE
                              THEN FAILED ("BOOLEAN CONSTRAINT " &
                                   "CHECK");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF B'FIRST = FALSE AND B'LAST = TRUE THEN
                              FAILED ("CONSTRAINT_ERROR RAISED " &
                                   "INAPPROPRIATELY ON BOOLEAN");
                         END IF;
               END;
          END;
     END LOOP;

     RESULT;
END CC3504E;
