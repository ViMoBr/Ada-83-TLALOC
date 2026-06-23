-- C45632A.ADA

-- OBJECTIVE:
--     CHECK THAT FOR PREDEFINED TYPE INTEGER, NUMERIC_ERROR OR
--     CONSTRAINT_ERROR IS RAISED FOR ABS (INTEGER'FIRST) IF
--     -INTEGER'LAST > INTEGER'FIRST.

-- HISTORY:
--     RJW 02/10/86  CREATED ORIGINAL TEST.
--     JET 12/30/87  UPDATED HEADER FORMAT AND ADDED CODE TO
--                   PREVENT OPTIMIZATION.

WITH REPORT; USE REPORT;

PROCEDURE C45632A IS

     I : INTEGER := IDENT_INT (INTEGER'FIRST);

BEGIN

     TEST ( "C45632A", "CHECK THAT FOR PREDEFINED TYPE INTEGER " &
                       "NUMERIC_ERROR/CONSTRAINT_ERROR IS RAISED " &
                       "FOR ABS (INTEGER'FIRST) IF -INTEGER'LAST > " &
                       "INTEGER'FIRST" );

     BEGIN
          IF - INTEGER'LAST > INTEGER'FIRST THEN
               BEGIN
                    IF EQUAL (ABS I, I) THEN
                         NULL;
                    ELSE
                         FAILED ( "WRONG RESULT FOR ABS" );
                    END IF;
                    FAILED ( "EXCEPTION NOT RAISED" );
               EXCEPTION
                    WHEN NUMERIC_ERROR =>
                         COMMENT ( "NUMERIC_ERROR RAISED" );
                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ( "CONSTRAINT_ERROR RAISED" );
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED" );
               END;
          ELSE
               COMMENT ( "-INTEGER'LAST <= INTEGER'FIRST" );
          END IF;
     END;

     RESULT;

END C45632A;
