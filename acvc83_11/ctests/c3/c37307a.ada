-- C37307A.ADA

-- CHECK THAT RELATIONAL AND LOGICAL OPERATORS ARE ALLOWED IN CHOICES OF
-- A VARIANT PART OF A RECORD IF THE EXPRESSIONS CONTAINING THESE
-- OPERATORS ARE ENCLOSED IN PARENTHESES AND THE EXPRESSIONS ARE STATIC.
 
-- ASL 7/9/81
-- JBG 5/26/83
 
WITH REPORT;
PROCEDURE C37307A IS
   
     USE REPORT;
 
BEGIN
     TEST ("C37307A","RELATIONAL AND LOGICAL " &
           "OPERATORS ALLOWED IN VARIANT PART CHOICES IF " &
           "PARENTHESES ENCLOSE EXPRESSIONS USING THEM " &
           "AND THE EXPRESSIONS ARE STATIC");
 
     DECLARE
          T : CONSTANT BOOLEAN := TRUE;
          F : CONSTANT BOOLEAN := FALSE;
      
          TYPE REC1(DISC : BOOLEAN := FALSE) IS
               RECORD
                    CASE DISC IS
                         WHEN (3 < 5) => NULL;       
                         WHEN OTHERS => NULL;
                    END CASE;
               END RECORD;
      
          TYPE REC3(DISC : BOOLEAN := FALSE) IS
               RECORD
                    CASE DISC IS
                         WHEN (T AND F) => NULL;     
                         WHEN (T OR  F) => NULL; 
                         WHEN OTHERS => NULL;
                    END CASE;
               END RECORD;
 
          R1 : REC1;
          R3 : REC3;
     BEGIN
          R1 := (DISC => FALSE);
          IF EQUAL(3,3) THEN
               R1 := (DISC => TRUE);
          END IF;
          IF NOT R1.DISC THEN
               FAILED ("ASSIGNMENT FAILED - 1");
          END IF;
 
          R3 := (DISC => FALSE);
          IF EQUAL(3,3) THEN
               R3 := (DISC => TRUE);
          END IF;
          IF NOT R3.DISC THEN
               FAILED ("ASSIGNMENT FAILED - 3");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
                 FAILED ("EXCEPTION RAISED");
     END;
 
     RESULT;
 
END C37307A;
