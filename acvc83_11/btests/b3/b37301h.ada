-- B37301H.ADA
 
-- CHECK THAT A VARIANT PART OF A RECORD MUST USE PROPER RESERVED
-- WORDS AND SYMBOLS WHERE NECESSARY, I.E.:
 
-- "END CASE" CANNOT BE REPLACED BY "ESAC".
 
-- ASL 7/1/81
 
PROCEDURE B37301H IS
 
     TYPE DAY IS (SUN,MON,TUE,WED,THU,FRI,SAT);
 
     TYPE VREC3(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS                  
                    WHEN OTHERS =>            
                         VAR : INTEGER;
               ESAC;                    -- ERROR: "ESAC"    
          END RECORD;
   
         
BEGIN
     NULL;
END B37301H; 
