-- C45264A.ADA

-- CHECK THAT EQUALITY COMPARISONS YIELD CORRECT RESULTS FOR ONE
-- DIMENSIONAL AND MULTI-DIMENSIONAL ARRAY TYPES.
-- CASE THAT CHECKS THAT TWO NULL ARRAYS OF THE SAME TYPE ARE
-- ALWAYS EQUAL.

-- PK  02/21/84
-- EG  05/30/84

WITH REPORT;
USE REPORT;

PROCEDURE C45264A IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 3;

BEGIN

     TEST("C45264A","CHECK THAT EQUALITY COMPARISONS YIELD CORRECT " &
                    "RESULTS FOR ONE DIMENSIONAL AND MULTI-"         &
                    "DIMENSIONAL ARRAY TYPES");

     DECLARE

          TYPE A1 IS ARRAY(INT RANGE <>) OF INTEGER;

     BEGIN

          IF A1'(1 .. IDENT_INT(2) => IDENT_INT(1)) /=
             A1'(IDENT_INT(2) .. 3 => IDENT_INT(1)) THEN
               FAILED ("A1 - ARRAYS NOT EQUAL");
          END IF;

     EXCEPTION

          WHEN OTHERS => 
               FAILED ("A1 - EXCEPTION RAISED");

     END;

     DECLARE

          TYPE A2 IS ARRAY(INT RANGE <>, INT RANGE <>) OF INTEGER;

     BEGIN
          IF A2'(1 .. IDENT_INT(2) => 
                 (IDENT_INT(3) .. IDENT_INT(2) => IDENT_INT(1))) /=
             A2'(IDENT_INT(2) .. 3 => 
                 (IDENT_INT(2) .. IDENT_INT(1) =>  IDENT_INT(1))) THEN
                FAILED ("A2 - ARRAYS NOT EQUAL");
          END IF;

     EXCEPTION

          WHEN OTHERS => 
                FAILED ("A2 - EXCEPTION RAISED");

     END;

     DECLARE

          TYPE A3 IS 
               ARRAY(INT RANGE <>, INT RANGE <>, INT RANGE <>) OF
                    INTEGER;

     BEGIN

          IF A3'(1 .. IDENT_INT(2) => 
                 (IDENT_INT(1) .. IDENT_INT(3) => 
                  (IDENT_INT(3) .. IDENT_INT(2) => IDENT_INT(1)))) /=
             A3'(IDENT_INT(1) .. 3 => 
                 (IDENT_INT(2) .. IDENT_INT(1) =>  
                  (IDENT_INT(1) .. IDENT_INT(2) => IDENT_INT(1)))) THEN
                FAILED ("A3 - ARRAYS NOT EQUAL");
          END IF;

     EXCEPTION

          WHEN OTHERS => 
                FAILED ("A3 - EXCEPTION RAISED");

     END;

     RESULT;

END C45264A;
