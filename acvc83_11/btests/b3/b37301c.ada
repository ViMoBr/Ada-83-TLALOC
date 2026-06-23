-- B37301C.ADA
 
-- CHECK THAT A VARIANT PART OF A RECORD MUST USE PROPER RESERVED
-- WORDS AND SYMBOLS WHERE NECESSARY, I.E.:
 
-- "|" CANNOT BE REPLACED BY "OR".
 
-- ASL 7/1/81
 
PROCEDURE B37301C IS
 
     TYPE DAY IS (SUN,MON,TUE,WED,THU,FRI,SAT);
 
     TYPE VREC1(DISC : DAY) IS
          RECORD
               COMP : INTEGER;
               CASE DISC IS 
                    WHEN WED =>
                         OK1 : INTEGER;
                    WHEN SAT OR SUN =>        -- ERROR: "OR" FOR "|".
                         HOME : INTEGER;
                   
                    WHEN OTHERS =>
                         NOTA : INTEGER;
               END CASE;                           
          END RECORD;
  
         
BEGIN
     NULL;
END B37301C;
