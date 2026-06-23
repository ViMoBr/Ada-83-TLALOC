-- C72001B.ADA

-- CHECK THAT A PACKAGE BODY CAN BE PROVIDED FOR A PACKAGE SPECIFICATION
--    THAT DOES NOT CONTAIN ANY SUBPROGRAM OR TASK DECLARATIONS AND THAT
--    STATEMENTS WITHIN THE PACKAGE BODIES CAN BE USED TO INITIALIZE
--    VARIABLES VISIBLE WITHIN THE PACKAGE BODY.

-- RM 04/30/81
-- RM 05/07/81 (TO INCORPORATE OLD TEST OBJECTIVE  7.1/T1 )
-- ABW 6/10/82
-- SPS 11/4/82
-- JBG 9/15/83

WITH REPORT;
PROCEDURE  C72001B  IS

     USE  REPORT;

BEGIN

     TEST( "C72001B" , "CHECK: PACKAGE BODIES CAN INITIALIZE VISIBLE" &
                       " VARIABLES" );

     DECLARE


          PACKAGE  P5  IS

               A : CHARACTER := 'B';
               B : BOOLEAN   := FALSE;

               PACKAGE  P6  IS
                    I : INTEGER := IDENT_INT(6);
               END  P6;

          END  P5;


          PACKAGE BODY  P5  IS
               PACKAGE BODY  P6  IS
               BEGIN
                    A := 'C';
                    I := 17;
                    B := IDENT_BOOL(TRUE);
               END  P6;
          BEGIN
               A := 'A';
          END  P5;


          USE  P5;
          USE  P6;

     BEGIN

          IF A /= 'A' THEN
               FAILED ("INITIALIZATIONS NOT CORRECT - 1");
          END IF;

          IF B /= TRUE THEN
               FAILED ("INITIALIZATIONS NOT CORRECT - 2");
          END IF;

          IF I /= 17 THEN
               FAILED ("INITIALIZATIONS NOT CORRECT - 3");
          END IF;

     END;


     RESULT;


END C72001B;
