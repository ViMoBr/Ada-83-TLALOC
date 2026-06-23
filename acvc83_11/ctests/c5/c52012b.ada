-- C52012B.ADA

-- CHECK THAT IF EVALUATION OF THE EXPRESSION IN AN ASSIGNMENT RAISES AN
-- EXCEPTION, THE VALUE OF THE TARGET VARIABLE IS NOT CHANGED.
-- THIS TEST IS IN TWO PARTS, COVERING RESPECTIVELY STATIC AND
-- DYNAMIC BOUNDS.

-- PART 2: DYNAMIC BOUNDS

-- BHS 06/21/84
-- EG  10/28/85  FIX NUMERIC_ERROR/CONSTRAINT_ERROR ACCORDING TO
--               AI-00387.

WITH REPORT;
PROCEDURE C52012B IS

     USE REPORT;

     SUBTYPE SMALL IS INTEGER RANGE IDENT_INT(1)..IDENT_INT(10);

     TYPE REC IS
          RECORD
               C1 : SMALL;
               C2 : SMALL;
          END RECORD;

     TYPE SHORT_ARR IS ARRAY (1..IDENT_INT(3)) OF SMALL;
     TYPE LONG_ARR IS ARRAY (1..IDENT_INT(10)) OF SMALL;

BEGIN
     TEST ("C52012B", "CHECK THAT TARGET VARIABLE VALUE IS UNCHANGED " &
                      "IF EVALUATION OF ASSIGNMENT EXPRESSION RAISES " &
                      "AN EXCEPTION");

     ----------------------------------------------------------------

     DECLARE
          R1 : REC := (5,3);

     BEGIN
          R1 := (11,10);                  -- ERROR: COMPONENT 1 RANGE

          FAILED ("EXCEPTION NOT RAISED FOR OUT-OF-RANGE COMPONENT");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF R1 /= (5,3) THEN
                    FAILED ("TARGET VALUE CHANGED DESPITE EXCEPTION " &
                            " - R1");
               END IF;

     END;

     -------------------------------------------------------------

     DECLARE
          R2 : REC := (5,3);

     BEGIN
          R2 := (10,11);                  -- ERROR: COMPONENT 2 RANGE

          FAILED ("EXCEPTION NOT RAISED FOR OUT-OF-RANGE COMPONENT ");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF R2 /= (5,3) THEN
                    FAILED ("TARGET VALUE CHANGED DESPITE EXCEPTION " &
                            " - R2");
               END IF;

     END;

     --------------------------------------------------------------

     DECLARE
          A1 : SHORT_ARR := (2,3,4);

     BEGIN
          A1 := (11,1,2);                  -- ERROR: COMPONENT 1 RANGE

          FAILED ("EXCEPTION NOT RAISED FOR OUT-OF-RANGE COMPONENT");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF A1 /= (2,3,4) THEN
                    FAILED ("TARGET VALUE CHANGED DESPITE EXCEPTION " &
                            " - A1");
               END IF;

     END;

     --------------------------------------------------------------

     DECLARE
          A2 : SHORT_ARR := (2,3,4);

     BEGIN
          A2 := (1,2,0);                   -- ERROR: COMPONENT 3 RANGE

          FAILED ("EXCEPTION NOT RAISED FOR OUT-OF-RANGE COMPONENT");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF A2 /= (2,3,4) THEN
                    FAILED ("TARGET VALUE CHANGED DESPITE EXCEPTION " &
                            " - A2");
               END IF;

     END;

     ------------------------------------------------------------

     DECLARE
          A3 : LONG_ARR := (OTHERS => 2);
          A4 : LONG_ARR := (1,2,3,4,5,6,7,8,9,10);
          I,J : INTEGER;

     BEGIN
          I := 5;
          J := 6;
          A3 := A4 (2..5) & A4 (IDENT_INT(7) .. I + J); -- ERROR:
                                                         -- CONSTRAINT
          FAILED ("EXCEPTION NOT RAISED FOR ARRAY SUBTYPE " &
                  "CONSTRAINT ERROR");

     EXCEPTION
          WHEN CONSTRAINT_ERROR  =>
               IF A3 /= (2,2,2,2,2,2,2,2,2,2) THEN
                    FAILED ("TARGET VALUE CHANGED DESPITE EXCEPTION " &
                            " - A3");
               END IF;

     END;

     --------------------------------------------------------------

     DECLARE
          A5 : LONG_ARR := (OTHERS => 2);
          A6 : LONG_ARR := (1..5 => 3, 6..8 => 4, 9..10 => 5);
          K,L : INTEGER;

     BEGIN
          K := 5;
          L := IDENT_INT(0);
          A5 := A6 (4..9) & A6 (IDENT_INT(7)..K/L);  -- ERROR: DIVISION
                                                         -- BY 0
          FAILED ("EXCEPTION NOT RAISED FOR NUMERIC ERROR");

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               IF A5 /= (2,2,2,2,2,2,2,2,2,2) THEN
                    FAILED ("NUMERIC_ERROR RAISED - TARGET VALUE " &
                            "CHANGED DESPITE EXCEPTION - A5");
               ELSE
                    COMMENT ("NUMERIC_ERROR RAISED FOR / BY 0");
               END IF;
          WHEN CONSTRAINT_ERROR =>
               IF A5 /= (2,2,2,2,2,2,2,2,2,2) THEN
                    FAILED ("CONSTRAINT_ERROR RAISED - TARGET VALUE " &
                            "CHANGED DESPITE EXCEPTION - A5");
               ELSE
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR / BY 0");
               END IF;

     END;

     --------------------------------------------------------------

     RESULT;

END C52012B;
