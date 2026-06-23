-- C45504D.ADA

-- CHECK THAT NUMERIC_ERROR/CONSTRAINT_ERROR IS RAISED WHEN THE SECOND
-- OPERAND OF '/', 'MOD', OR 'REM' EQUALS ZERO, IF THE OPERANDS ARE OF 
-- PREDEFINED TYPE INTEGER.

-- R.WILLIAMS 9/1/86

WITH REPORT; USE REPORT;
PROCEDURE C45504D IS

     I0 : INTEGER := IDENT_INT (0);
     I5 : INTEGER := IDENT_INT (5);
     N5 : INTEGER := IDENT_INT (-5);

BEGIN
     TEST ( "C45504D", "CHECK THAT NUMERIC_ERROR/CONSTRAINT_ERROR " &
                       "IS RAISED WHEN THE SECOND OPERAND OF '/', " &
                       "'MOD', OR 'REM' EQUALS ZERO, IF THE " & 
                       "OPERANDS ARE OF PREDEFINED TYPE INTEGER" );

     BEGIN
          IF I5 / I0 = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I5 / I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I5 / I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I5 / I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I5 / I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I5 / I0'" );
     END;

     BEGIN
          IF N5 / I0 = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'N5 / I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'N5 / I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'N5 / I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'N5 / I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'N5 / I0'" );
     END;

     BEGIN
          IF I0 / I0  = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I0 / I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I0 / I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I0 / I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I0 / I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I0 / I0'" );
     END;

     BEGIN
          IF I5 / I0 * I0  = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I5 / I0 * I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I5 / I0 * I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I5 / I0 * I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I5 / I0 * I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I5 / I0 * I0'" );
     END;

     BEGIN
          IF I5 MOD I0 = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I5 MOD I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I5 MOD I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I5 MOD I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I5 MOD I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I5 MOD I0'" );
     END;

     BEGIN
          IF N5 MOD I0 = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'N5 MOD I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'N5 MOD I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'N5 MOD I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'N5 MOD I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'N5 MOD I0'" );
     END;

     BEGIN
          IF I0 MOD I0  = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I0 MOD I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I0 MOD I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I0 MOD I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I0 MOD I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I0 MOD I0'" );
     END;

     BEGIN
          IF I5 MOD I0 = (I5 + I0) MOD I0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I5 MOD I0 = " &
                        "(I5 + I0) MOD I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I5 MOD I0 = " &
                        "(I5 + I0) MOD I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I5 MOD I0 = " &
                         "(I5 + I0) MOD I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I5 MOD I0 = " &
                         "(I5 + I0) MOD I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I5 MOD I0 = " &
                         "(I5 + I0) MOD I0'" );
     END;
          
     BEGIN
          IF I5 REM I0 = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I5 REM I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I5 REM I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I5 REM I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I5 REM I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I5 REM I0'" );
     END;

     BEGIN
          IF N5 REM I0 = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'N5 REM I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'N5 REM I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'N5 REM I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'N5 REM I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'N5 REM I0'" );
     END;

     BEGIN
          IF I0 REM I0  = 0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I0 REM I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I0 REM I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I0 REM I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I0 REM I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I0 REM I0'" );
     END;

     BEGIN
          IF I5 REM (-I0) = I5 REM I0 THEN
               FAILED ( "NO EXCEPTION RAISED BY 'I5 REM (-I0) = " &
                        "I5 REM I0' - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED BY 'I5 REM (-I0) = " &
                        "I5 REM I0' - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ( "CONSTRAINT_ERROR RAISED BY 'I5 REM (-I0) " &
                         "= I5 REM I0'" );
          WHEN NUMERIC_ERROR =>
               COMMENT ( "NUMERIC_ERROR RAISED BY 'I5 REM (-I0) = " &
                         "I5 REM I0'" );
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED BY 'I5 REM (-I0) = " &
                         "I5 REM I0'" );
     END;
          
     RESULT;
END C45504D;
