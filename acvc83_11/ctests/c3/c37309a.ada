-- C37309A.ADA
 
-- CHECK THAT IF A DISCRIMINANT HAS A STATIC SUBTYPE, AN OTHERS
-- CHOICE CAN BE OMITTED IF ALL VALUES IN THE 
-- SUBTYPE'S RANGE ARE COVERED IN A VARIANT PART.
 
-- ASL 7/10/81
-- SPS 10/25/82
-- SPS 7/17/83

WITH REPORT;
PROCEDURE C37309A IS

     USE REPORT;
 
BEGIN
     TEST ("C37309A","OTHERS CHOICE CAN BE OMITTED IN VARIANT PART " &
           "IF ALL VALUES IN STATIC SUBTYPE RANGE OF DISCRIMINANT " &
           "ARE COVERED");
 
     DECLARE
          SUBTYPE STATCHAR IS CHARACTER RANGE 'I'..'N';
          TYPE REC1(DISC : STATCHAR := 'J') IS
               RECORD
                    CASE DISC IS
                         WHEN 'I' => NULL;
                         WHEN 'J' => NULL;
                         WHEN 'K' => NULL;
                         WHEN 'L' => NULL;
                         WHEN 'M' => NULL;
                         WHEN 'N' => NULL;
                    END CASE;          
               END RECORD;
      
          R1 : REC1;
     BEGIN
          R1 := (DISC => 'N');
          IF EQUAL(3,3) THEN
               R1 := (DISC => 'K');
          END IF;
          IF R1.DISC /= 'K' THEN
               FAILED ("ASSIGNMENT FAILED - 1");
          END IF;
 
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED");
     END;
 
     RESULT;
 
END C37309A;
