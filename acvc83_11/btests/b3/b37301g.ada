-- B37301G.ADA
 
-- CHECK THAT A VARIANT PART OF A RECORD MUST USE PROPER RESERVED
-- WORDS AND SYMBOLS WHERE NECESSARY, I.E.:
 
-- "IS" CANNOT BE REPLACED BY "OF".
 
-- ASL 7/1/81
 
PROCEDURE B37301G IS
 
     TYPE DAY IS (SUN,MON,TUE,WED,THU,FRI,SAT);
 
     TYPE VREC3(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC OF                   -- ERROR: "OF" FOR "IS".
                    WHEN OTHERS =>            
                         VAR : INTEGER;
               END CASE;                        
          END RECORD;
   
         
BEGIN
     NULL;
END B37301G;
