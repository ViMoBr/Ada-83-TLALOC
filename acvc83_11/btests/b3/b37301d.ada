-- B37301D.ADA
 
-- CHECK THAT A VARIANT PART OF A RECORD MUST USE PROPER RESERVED
-- WORDS AND SYMBOLS WHERE NECESSARY, I.E.:
 
-- "=>" CANNOT BE REPLACED BY "THEN".
 
-- ASL 7/1/81
 
PROCEDURE B37301D IS
 
     TYPE DAY IS (SUN,MON,TUE,WED,THU,FRI,SAT);
 
     TYPE VREC1(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS 
                    WHEN THU =>
                         OK2 : INTEGER;
                    WHEN FRI THEN             -- ERROR: "THEN" FOR "=>".
                         JULY3 : INTEGER;
                                      
                    WHEN OTHERS =>
                         NOTA : INTEGER;
               END CASE;                           
          END RECORD;
  
         
BEGIN
     NULL;
END B37301D;
