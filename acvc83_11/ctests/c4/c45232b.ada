-- C45232B.ADA

-- CHECK THAT NO EXCEPTION IS RAISED WHEN AN INTEGER LITERAL IN
-- A COMPARISON  BELONGS TO THE BASE TYPE BUT IS OUTSIDE THE 
-- SUBTYPE OF THE OTHER OPERAND.

-- P. BRASHEAR  08/21/86

WITH REPORT, SYSTEM; USE REPORT;
PROCEDURE C45232B IS

BEGIN

     TEST ("C45232B", "NO EXCEPTION IS RAISED WHEN AN INTEGER " & 
                      "LITERAL IN A COMPARISON BELONGS TO THE BASE " &
                      "TYPE BUT IS OUTSIDE THE SUBTYPE OF THE " &
                      "OTHER OPERAND");

     DECLARE

           TYPE INT10 IS RANGE -10 .. 5;

     BEGIN    

          IF 7 > INT10'(-10) THEN
               COMMENT ("NO EXCEPTION RAISED FOR '7 > " &
                        "INT10'(-10)'");
          ELSE
               FAILED ("WRONG RESULT FOR '7 > INT10'(-10)'");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR '7 > " &
                       "INT10'(-10)'");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR '7 " &
                       "> INT10'(-10)'");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR '7 > " &
                       "INT10'(-10)'");
     END;  

     DECLARE

           TYPE INT10 IS RANGE -10 .. 5;

     BEGIN    

          IF 7 NOT IN INT10 THEN
               COMMENT ("NO EXCEPTION RAISED FOR '7 NOT IN " &
                        "INT'");
          ELSE
               FAILED ("WRONG RESULT FOR '7 NOT IN INT'");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR '7 NOT IN " &
                       "INT'");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR '7 " &
                       "NOT IN INT'");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR '7 NOT IN " &
                       "INT'");
     END;  

     DECLARE

           TYPE INT700 IS RANGE -700 .. 500;

     BEGIN    
          IF 600 > INT700'(5) THEN
               COMMENT ("NO EXCEPTION RAISED FOR '600 > " &
                        "INT700'(5)'");
          ELSE
               FAILED ("WRONG RESULT FOR '600 > INT700'(5)'");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR '600 > " &
                       "INT700'(5)'");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR '600 " &
                       "> INT700'(5)'");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR '600 > " &
                       "INT700'(5)'");
     END;  

     DECLARE

           TYPE INT700 IS RANGE -700 .. 500;

     BEGIN    

          IF 600 NOT IN INT700 THEN
               COMMENT ("NO EXCEPTION RAISED FOR '600 NOT IN " &
                        "INT700'");
          ELSE
               FAILED ("WRONG RESULT FOR '600 NOT IN INT700'");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR '600 NOT IN " &
                       "INT700'");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR '600 " &
                       "NOT IN INT700'");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR '600 NOT IN " &
                       "INT700'");
     END;  

     RESULT;

END C45232B;
