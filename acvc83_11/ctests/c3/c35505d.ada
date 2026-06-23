-- C35505D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED FOR 'SUCC' AND 'PRED',
-- IF THE RESULT WOULD BE OUTSIDE THE RANGE OF THE BASE TYPE,
-- WHEN THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL ARGUMENT
-- IS TYPE INTEGER OR A SUBTYPE OF TYPE INTEGER.

-- RJW 6/9/86

WITH REPORT; USE REPORT;

PROCEDURE C35505D IS

     SUBTYPE I IS INTEGER RANGE 0 .. 0;

BEGIN
     TEST ( "C35505D", "CHECK THAT CONSTRAINT_ERROR IS RAISED FOR " &
                       "'SUCC' AND 'PRED', IF THE RESULT WOULD BE " &
                       "OUTSIDE THE RANGE OF THE BASE TYPE, WHEN " &
                       "THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE " &
                       "ACTUAL ARGUMENT IS TYPE INTEGER OR A " &
                       "SUBTYPE OF TYPE INTEGER" );

     DECLARE
          GENERIC
               TYPE T IS (<>);
               STR : STRING;
          PROCEDURE P;

          PROCEDURE P IS
          BEGIN
               BEGIN
                    IF T'PRED (T'BASE'FIRST) = T'VAL (0) THEN
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " & 
                                   STR & "'PRED -  1" );
                    ELSE
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " &
                                   STR & "'PRED -  2" );          
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR => 
                         NULL;
                    WHEN OTHERS => 
                         FAILED ( "WRONG EXCEPTION RAISED FOR " &
                                   STR & "'PRED - 1" );
               END;

               BEGIN
                    IF T'SUCC (T'BASE'LAST) = T'VAL (0) THEN
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " & 
                                   STR & "'SUCC -  1" );
                    ELSE
                         FAILED ( "CONSTRAINT_ERROR NOT RAISED FOR " &
                                   STR & "'SUCC -  2" );          
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR => 
                         NULL;
                    WHEN OTHERS => 
                         FAILED ( "WRONG EXCEPTION RAISED FOR " &
                                   STR & "'SUCC - 1" );
               END;
          END P;
          
          PROCEDURE PI   IS NEW P (I, "I");
          PROCEDURE PINT IS NEW P (INTEGER, "INTEGER");
     BEGIN
          PI;
          PINT;
     END;
RESULT;
END C35505D;
