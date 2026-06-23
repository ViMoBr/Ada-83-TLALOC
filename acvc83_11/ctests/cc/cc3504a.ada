-- CC3504A.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT
-- CONSTRAINT_ERROR IS RAISED WHEN CONSTRAINTS IMPOSED ON ITS DESIGNATED
-- TYPE T ARE NOT THE SAME AS THE CONSTRAINTS ON THE DESIGNATED TYPE OF
-- THE ACTUAL PARAMETER.

-- CHECK FOR SCALAR ACCESSED TYPES. (FIXED AND FLOAT ARE IN SEPERATE 
-- TESTS).  NOTE:  THE LACK OF A CONSTRAINT HAS THE SAME EFFECT AS 
-- SUBTYPE'FIRST .. SUBTYPE'LAST.

-- CHECK WHEN T IS NOT A GENERIC FORMAL TYPE.

-- DAT 9/24/81
-- SPS 6/3/82

WITH REPORT; USE REPORT;

PROCEDURE CC3504A IS
BEGIN
     TEST ("CC3504A", "CONSTRAINT_ERROR ON TYPES ACCESSED BY"
          & " GENERIC ACCESS TYPE PARAMETERS");

     FOR L IN IDENT_INT (1) .. IDENT_INT (4) LOOP
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
                    TYPE A IS ACCESS INT;
               PACKAGE PI IS END PI;

               GENERIC
                    TYPE A IS ACCESS CH;
               PACKAGE PC IS END PC;
  
               GENERIC
                    TYPE A IS ACCESS BOOLEAN;
               PACKAGE PB IS END PB;
          BEGIN
               COMMENT ("LOOP ITERATION");
               BEGIN
                    DECLARE
                         PACKAGE I1 IS NEW PI (AI);
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
                         PACKAGE I1 IS NEW PC (AC);
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
                         PACKAGE I1 IS NEW PB (AB);
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
END CC3504A;
