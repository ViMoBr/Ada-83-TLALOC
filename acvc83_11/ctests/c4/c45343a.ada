-- C45343A.ADA

-- CHECK THAT CATENATION OF NULL OPERANDS YIELDS THE CORRECT RESULT,
-- WITH THE CORRECT BOUNDS.

-- BHS 6/29/84

WITH REPORT;
PROCEDURE C45343A IS

     USE REPORT;

     TYPE ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;
     SUBTYPE ARR_8 IS ARR (1..8);
     A1, A2 : ARR_8;

     PROCEDURE CAT (A : ARR; I1,I2 : INTEGER; NUM : CHARACTER) IS
     BEGIN
          IF A'FIRST /= I1 OR A'LAST /= I2 THEN
               FAILED ("INCORRECT CATENATION - " & NUM);
          END IF;
     END CAT;

BEGIN

     TEST ("C45343A", "CATENATION OF NULL OPERANDS"); 


     A1 := (1,2,3,4,5,6,7,8);
     A2 := A1(1..0) & A1(6..5) & A1(1..8);
     IF A2 /= (1,2,3,4,5,6,7,8) THEN
          FAILED ("INCORRECT CATENATION RESULT - 1");
     END IF;

     A1 := (1,2,3,4,5,6,7,8);
     A2 := A1(2..8) & A1(1..0) & 9;
     IF A2 /= (2,3,4,5,6,7,8,9) THEN
          FAILED ("INCORRECT CATENATION RESULT - 2");
     END IF;


     CAT ( A1(1..0) & A1(IDENT_INT(2)..0), 2, 0, '3' );
     CAT ( A1(IDENT_INT(1)..0) & A2(2..0), 2, 0, '4' );

     CAT ( A1(1..0) & A1(6..5) & A1(2..8), 2, 8, '5' );
     CAT ( A1(2..8) & A1(1..0), 2, 8, '6' );

     CAT ( A2(1..0) & A2(6..5) & A2(IDENT_INT(2)..8), 2, 8, '7' );
     CAT ( A2(IDENT_INT(2)..8) & A2(1..0), 2, 8, '8' );

     RESULT;

END C45343A;
