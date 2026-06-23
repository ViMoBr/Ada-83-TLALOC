-- C45114B.ADA

-- CHECK THAT LOGICAL OPERATORS ARE DEFINED FOR PACKED BOOLEAN ARRAYS.

--  RJW  1/17/86

WITH  REPORT; USE REPORT;
PROCEDURE  C45114B  IS

BEGIN

     TEST( "C45114B" , "CHECK THAT LOGICAL OPERATORS ARE DEFINED " &
                       "FOR PACKED BOOLEAN ARRAYS" );

     DECLARE

          TYPE ARR IS ARRAY (1 .. 32) OF BOOLEAN;

          PRAGMA PACK (ARR);

          A : ARR := ( TRUE, TRUE, FALSE, FALSE, OTHERS => TRUE );
          B : ARR := ( TRUE, FALSE, TRUE, FALSE, OTHERS => FALSE );

          A_AND_B : ARR := ( TRUE, OTHERS => FALSE );
          A_OR_B  : ARR := ARR'( 4 => FALSE, OTHERS => TRUE );
          A_XOR_B : ARR := ARR'( 1|4 => FALSE, OTHERS => TRUE );
          NOT_A   : ARR := ARR'( 3|4 => TRUE, OTHERS => FALSE );

     BEGIN

          IF ( A AND B ) /= A_AND_B THEN
               FAILED ( "'AND' NOT CORRECTLY DEFINED" );
          END IF;

          IF ( A OR B ) /= A_OR_B THEN
               FAILED ( "'OR' NOT CORRECTLY DEFINED" );
          END IF;

          IF ( A XOR B ) /= A_XOR_B THEN
               FAILED ( "'XOR' NOT CORRECTLY DEFINED" );
          END IF;

          IF NOT A /= NOT_A THEN
               FAILED ( "'NOT' NOT CORRECTLY DEFINED" );
          END IF;

     END;

     RESULT;

END C45114B;
