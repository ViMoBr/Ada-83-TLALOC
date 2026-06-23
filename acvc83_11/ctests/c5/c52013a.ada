-- C52013A.ADA

-- CHECK WHETHER THE ENTIRE EXPRESSION IS EVALUATED BEFORE CHECKING THAT
-- A VARIABLE'S DISCRIMINANT CONSTRAINT IS SATISFIED OR THAT AN ARRAY
-- VALUE HAS THE CORRECT NUMBER OF COMPONENTS FOR EACH DIMENSION.

-- BHS 6/22/84

WITH REPORT;
PROCEDURE C52013A IS

     USE REPORT;

     TYPE ARR1_DIM IS ARRAY (INTEGER RANGE <>) OF INTEGER;
     TYPE ARR2_DIM IS ARRAY (INTEGER RANGE <>,
                             INTEGER RANGE <>) OF INTEGER;
     TYPE REC(D : INTEGER) IS
          RECORD
               C : INTEGER;
          END RECORD;

     GLOBAL : INTEGER := 0;

     FUNCTION F RETURN INTEGER IS
     BEGIN
          GLOBAL := GLOBAL + 1;
          RETURN 1;
     END F;

BEGIN
     TEST ("C52013A", "CHECK WHETHER ENTIRE EXPRESSION EVALUATED " &
                      "BEFORE CHECKING SUBTYPE OF TARGET VARIABLE");

     DECLARE
          ARR_V1 : ARR1_DIM (1..3);

     BEGIN
          GLOBAL := 1;
          ARR_V1 := (1..4 => F);            -- ERROR: ARR_V1 CONSTRAINT

          FAILED ("EXCEPTION NOT RAISED FOR ARRAY CONSTRAINT ERROR");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF GLOBAL = 1 THEN
                    COMMENT ("F NOT EVALUATED BEFORE CONSTRAINT " &
                             "ERROR RAISED FOR (1..4 => F)");
               ELSIF GLOBAL = 5 THEN
                    COMMENT ("F EVALUATED BEFORE CONSTRAINT " &
                             "ERROR RAISED FOR (1..4 => F)");
               ELSE  -- UNEXPECTED GLOBAL VALUE
                    FAILED ("INCORRECT GLOBAL VARIABLE VALUE");
               END IF;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - ARR_V1");

     END;


     DECLARE
          ARR_V2 : ARR2_DIM(1..5, -15..-10);

     BEGIN
          GLOBAL := 1;
          ARR_V2 := (1 => (1..5 => F),         
                     2 => (-16..-10 => F));     -- ERROR: CONSTRAINT 
          FAILED ("EXCEPTION NOT RAISED FOR CONSTRAINT ERROR - ARR_V2");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF GLOBAL = 1 THEN
                    COMMENT ("F NOT EVALUATED BEFORE " &
                             "CONSTRAINT ERROR RAISED FOR " &
                             "TWO-DIMENSION AGGREGATE");
               ELSIF GLOBAL = 6 THEN
                    COMMENT ("F EVALUATED FOR DIMENSION 1 ONLY " &
                             "BEFORE CONSTRAINT ERROR RAISED " &
                             "FOR TWO-DIMENSION AGGREGATE");
               ELSIF GLOBAL = 13 THEN
                    COMMENT ("F EVALUATED FOR BOTH DIMENSIONS " &
                             "BEFORE CONSTRAINT ERROR RAISED " &
                             "FOR TWO-DIMENSION AGGREGATE");
               ELSE  -- UNEXPECTED GLOBAL VALUE
                    FAILED ("INCORRECT GLOBAL VARIABLE VALUE - 2");
               END IF;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - ARR_V2");

     END;



     DECLARE
          REC_V : REC(3);

     BEGIN
          GLOBAL := 1;
          REC_V := (D => 4, C => F);        -- ERROR: DISCRIMINANT

          FAILED ("EXCEPTION NOT RAISED FOR DISCRIMINANT ERROR");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF GLOBAL = 1 THEN
                    COMMENT ("F NOT EVALUATED BEFORE CONSTRAINT " &
                             "ERROR RAISED FOR WRONG DISCRIMINANT " &
                             "VALUE IN AGGREGATE (D => 4, C => F)");
               ELSIF GLOBAL = 2 THEN
                    COMMENT ("F EVALUATED BEFORE CONSTRAINT " &
                             "ERROR RAISED FOR WRONG DISCRIMINANT " &
                             "VALUE IN AGGREGATE (D => 4, C => F)");
               ELSE  -- UNEXPECTED GLOBAL VALUE
                    FAILED ("INCORRECT GLOBAL VARIABLE VALUE - 3");
               END IF;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - REC_V");

     END;


     RESULT;

END C52013A;
