-- B37301B.ADA
 
-- CHECK THAT A VARIANT PART OF A RECORD MUST USE PROPER RESERVED
-- WORDS AND SYMBOLS WHERE NECESSARY, I.E.:
 
-- "WHEN" CANNOT BE REPLACED BY "IF".
 
-- ASL 7/1/81
 
PROCEDURE B37301B IS
 
     TYPE DAY IS (SUN,MON,TUE,WED,THU,FRI,SAT);
 
     TYPE VREC1(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS 
                    WHEN TUE =>
                         WALTHAM : INTEGER;
                    IF MON =>                 -- ERROR: "IF" FOR "WHEN".
                         NEWPORT : INTEGER;
                    WHEN OTHERS =>
                         NOTA : INTEGER;
               END CASE;                           
          END RECORD;
  
         
BEGIN
     NULL;
END B37301B;
