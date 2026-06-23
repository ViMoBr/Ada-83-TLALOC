-- B37311A.ADA
 
-- CHECK THAT EVEN WHEN THE CONTEXT INDICATES THAT A DISCRIMINANT
-- COVERS A SMALLER RANGE OF VALUES THAN PERMITTED BY ITS SUBTYPE,
-- AN OTHERS ALTERNATIVE IS REQUIRED IF THE SUBTYPE VALUE RANGE
-- IS NOT FULLY COVERED.
 
-- ASL 7/14/81
-- SPS 12/7/82 

PROCEDURE  B37311A IS
 
     SUBTYPE INT IS INTEGER RANGE 1..10;
     TYPE REC (DISC : INT) IS
          RECORD
               CASE DISC IS 
                    WHEN 1 =>
                         CASE DISC IS
                              WHEN 1 => NULL;
                         END CASE;            -- ERROR: MISSING CHOICES.
                    WHEN 2..4 => NULL;
                    WHEN 5..10 =>
                         CASE DISC IS
                              WHEN 5..10 => NULL;
                         END CASE;            -- ERROR: MISSING CHOICES.
               END CASE;
          END RECORD;
 
BEGIN
     NULL;
END B37311A;
