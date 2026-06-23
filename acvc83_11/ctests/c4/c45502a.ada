-- C45502A.ADA

-- CHECK THAT MULTIPLICATION AND DIVISION YIELD CORRECT RESULTS WHEN
-- THE OPERANDS ARE OF PREDEFINED TYPE INTEGER.

-- R.WILLIAMS 9/1/86

WITH REPORT; USE REPORT;
PROCEDURE C45502A IS

BEGIN
     TEST ( "C45502A", "CHECK THAT MULTIPLICATION AND DIVISION " &
                       "YIELD CORRECT RESULTS WHEN THE OPERANDS " &
                       "ARE OF PREDEFINED TYPE INTEGER" );

     DECLARE
          I0  : INTEGER := 0;
          I1  : INTEGER := 1;
          I2  : INTEGER := 2;
          I3  : INTEGER := 3;
          I5  : INTEGER := 5;    
          I10 : INTEGER := 10;
          I11 : INTEGER := 11;
          I12 : INTEGER := 12;
          I13 : INTEGER := 13;
          I14 : INTEGER := 14;
          N1  : INTEGER := -1;
          N2  : INTEGER := -2;
          N5  : INTEGER := -5;
          N10 : INTEGER := -10;
          N11 : INTEGER := -11;
          N12 : INTEGER := -12;
          N13 : INTEGER := -13;
          N14 : INTEGER := -14;
          N50 : INTEGER := -50;

     BEGIN
          IF I0 * INTEGER'FIRST /= 0 THEN 
               FAILED ( "INCORRECT RESULT FOR I0 * INTEGER'FIRST" );
          END IF;

          IF I0 * INTEGER'LAST /= 0 THEN 
               FAILED ( "INCORRECT RESULT FOR I0 * INTEGER'LAST" );
          END IF;

          IF N1 * INTEGER'LAST + INTEGER'LAST /= 0 THEN 
               FAILED ( "INCORRECT RESULT FOR N1 * INTEGER'LAST" );
          END IF;

          IF I3 * I1 /= I3 THEN 
               FAILED ( "INCORRECT RESULT FOR I3 * I1" );
          END IF;

          IF IDENT_INT (I3) * IDENT_INT (I1) /= I3 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (I3) * " &
                        "IDENT_INT (I1)" );
          END IF;

          IF I2 * N1 /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR I2 * N1" );
          END IF;

          IF "*" (LEFT => I2, RIGHT => N1) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR ""*"" (LEFT => I2, " &
                        "RIGHT => N1)" );
          END IF;

          IF IDENT_INT (I2) * IDENT_INT (N1) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (I2) * " &
                        "IDENT_INT (N1)" );
          END IF;
              
          IF I5 * I2 * N5 /= N50 THEN
               FAILED ( "INCORRECT RESULT FOR I5 * I2 * N5" );
          END IF;

          IF IDENT_INT (N1) * IDENT_INT (N5) /= I5 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (N1) * " &
                        "IDENT_INT (N5)" );
          END IF;

          IF "*" (LEFT => IDENT_INT (N1), RIGHT => IDENT_INT (N5)) /= 
                 I5 THEN
               FAILED ( "INCORRECT RESULT FOR ""*"" (LEFT => " &
                        "IDENT_INT (N1), RIGHT => IDENT_INT (N5))" );
          END IF;

          IF IDENT_INT (N1) * IDENT_INT (I2) * IDENT_INT (N5) /= I10 
             THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (N1) * " &
                        "IDENT_INT (I2) * IDENT_INT (N5)" );
          END IF;

          IF (-IDENT_INT (I0)) * IDENT_INT (I10) /= I0 THEN
               FAILED ( "INCORRECT RESULT FOR (-IDENT_INT (I0)) * " &
                        "IDENT_INT (I10)" );
          END IF;

          IF I0 * I10 /= (-I0) THEN
               FAILED ( "INCORRECT RESULT FOR I0 * I10" );
          END IF;

          IF "*" (LEFT => I0, RIGHT => I10) /= (-I0) THEN
               FAILED ( "INCORRECT RESULT FOR ""*"" (LEFT => I0, " &
                        "RIGHT => I10)" );
          END IF;

          IF IDENT_INT (I10) / IDENT_INT (I5) /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (I10) " &
                        "/ IDENT_INT (I5)" );
          END IF;

          IF I11 / I5 /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR I11 / I5" );
          END IF;
          
          IF IDENT_INT (I12) / IDENT_INT (I5) /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (I12) " &
                        "/ IDENT_INT (I5)" );
          END IF;

          IF "/" (LEFT => IDENT_INT (I12), RIGHT => IDENT_INT (I5)) /= 
                 I2 THEN
               FAILED ( "INCORRECT RESULT FOR ""/"" (LEFT => " &
                        "IDENT_INT (I12), RIGHT => IDENT_INT (I5))" );
          END IF;

          IF I13 / I5 /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR I13 / I5" );
          END IF;
          
          IF IDENT_INT (I14) / IDENT_INT (I5) /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (I14) " &
                        "/ IDENT_INT (I5)" );
          END IF;

          IF I10 / N5 /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR I10 / N5" );
          END IF;
          
          IF "/" (LEFT => I10, RIGHT => N5) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR ""/"" (LEFT => I10, " &
                        "RIGHT => N5)" );
          END IF;
          
          IF IDENT_INT (I11) / IDENT_INT (N5) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (I11) " &
                        "/ IDENT_INT (N5)" );
          END IF;

          IF I12 / N5 /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR I12 / N5" );
          END IF;
          
          IF IDENT_INT (I13) / IDENT_INT (N5) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (I13) " &
                        "/ IDENT_INT (N5)" );
          END IF;

          IF I14 / N5 /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR I14 / N5" );
          END IF;
          
          IF IDENT_INT (N10) / IDENT_INT (I5) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (N10) " &
                        "/ IDENT_INT (I5)" );
          END IF;

          IF "/" (LEFT => IDENT_INT (N10), RIGHT => IDENT_INT (I5)) /= 
                 N2 THEN
               FAILED ( "INCORRECT RESULT FOR ""/"" (LEFT => " &
                        "IDENT_INT (N10), RIGHT => IDENT_INT (I5))" );
          END IF;

          IF N11 / I5 /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR N11 / I5" );
          END IF;
          
          IF IDENT_INT (N12) / IDENT_INT (I5) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (N12) " &
                        "/ IDENT_INT (I5)" );
          END IF;

          IF N13 / I5 /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR N13 / I5" );
          END IF;
          
          IF "/" (LEFT => N13, RIGHT => I5) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR ""/"" (LEFT => N13, " &
                        "RIGHT => I5)" );
          END IF;
          
          IF IDENT_INT (N14) / IDENT_INT (I5) /= N2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (N14) " &
                        "/ IDENT_INT (I5)" );
          END IF;

          IF N10 / N5 /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR N10 / N5" );
          END IF;

          IF IDENT_INT (N11) / IDENT_INT (N5) /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (N11) " &
                        "/ IDENT_INT (N5)" );
          END IF;

          IF "/" (LEFT => IDENT_INT (N11), RIGHT => IDENT_INT (N5)) /= 
                 I2 THEN
               FAILED ( "INCORRECT RESULT FOR ""/"" (LEFT => " &
                        "IDENT_INT (N11), RIGHT => IDENT_INT (N5))" );
          END IF;

          IF N12 / N5 /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR N12 / N5" );
          END IF;
          

          IF IDENT_INT (N13) / IDENT_INT (N5) /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR IDENT_INT (N13) " &
                        "/ IDENT_INT (N5)" );
          END IF;

          IF N14 / N5 /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR N14 / N5" );
          END IF;
          
          IF "/" (LEFT => N14, RIGHT => N5) /= I2 THEN
               FAILED ( "INCORRECT RESULT FOR ""/"" (LEFT => N14, " &
                        "RIGHT => N5)" );
          END IF;
          
          IF I0 / I5 /= (-I0) THEN
               FAILED ( "INCORRECT RESULT FOR I0 / I5" );
          END IF;

          IF "/" (LEFT => I0, RIGHT => I5) /= (-I0) THEN
               FAILED ( "INCORRECT RESULT FOR ""/"" (LEFT => I0, " &
                        "RIGHT => I5)" );
          END IF;
          
          IF (-IDENT_INT (I0)) / IDENT_INT (I5) /= I0 THEN
               FAILED ( "INCORRECT RESULT FOR (-IDENT_INT (I0)) / " &
                        "IDENT_INT (I5)" );
          END IF;

     END;
          
     RESULT;
END C45502A;
