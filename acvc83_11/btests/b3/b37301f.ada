-- B37301F.ADA
 
-- CHECK THAT A VARIANT PART OF A RECORD MUST USE PROPER RESERVED
-- WORDS AND SYMBOLS WHERE NECESSARY, I.E.:
 
-- "END CASE" CANNOT BE REPLACED BY "ENDCASE"
 
-- ASL 7/1/81
 
PROCEDURE B37301F IS
 
     TYPE DAY IS (SUN,MON,TUE,WED,THU,FRI,SAT);
 
     TYPE VREC2(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS
                    WHEN OTHERS =>
                         VAR : INTEGER;
               ENDCASE;                       -- ERROR: "ENDCASE".
          END RECORD;
 
  
         
BEGIN
     NULL;
END B37301F; 
