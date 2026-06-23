-- B37301E.ADA
 
-- CHECK THAT A VARIANT PART OF A RECORD MUST USE PROPER RESERVED
-- WORDS AND SYMBOLS WHERE NECESSARY, I.E.:
 
-- "END CASE" CANNOT BE REPLACED BY "END"
 
-- ASL 7/1/81
 
PROCEDURE B37301E IS
 
     TYPE DAY IS (SUN,MON,TUE,WED,THU,FRI,SAT);
 
     TYPE VREC1(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS 
                                                         
                    WHEN OTHERS =>
                         NOTA : INTEGER;
               END;                       -- ERROR: "CASE" MISSING    
          END RECORD;
  
         
BEGIN
     NULL;
END B37301E;
