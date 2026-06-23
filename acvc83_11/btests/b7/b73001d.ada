-- B73001D.ADA


-- CHECK THAT IF A PACKAGE SPECIFICATION REQUIRES A BODY, AND THE
--    PACKAGE IS DECLARED INSIDE ANOTHER PACKAGE SPECIFICATION,
--    BODIES MUST BE PROVIDED FOR BOTH SPECIFICATIONS.

-- RM 05/06/81
-- JBG 9/19/83

PROCEDURE  B73001D  IS
BEGIN


     DECLARE

          PACKAGE  PACK1  IS

               PACKAGE  PACK2  IS
                    I  :  INTEGER; 
                    FUNCTION  FN1( A1 : INTEGER;  A2 : BOOLEAN )
                              RETURN INTEGER; 
               END  PACK2; 

          END  PACK1; 

          PACKAGE BODY  PACK1  IS

               FUNCTION  FN1( A1 : INTEGER;  A2 : BOOLEAN )
                         RETURN INTEGER  IS
               BEGIN
                    RETURN  A1; 
               END  FN1; 

          END  PACK1;    -- ERROR: BODY OF  PACK2  MISSING.

     BEGIN
          NULL; 
     END; 


     DECLARE

          PACKAGE  PACK1  IS

               PACKAGE  PACK2  IS
                    I  :  INTEGER; 
                    FUNCTION  "+"( A1 : INTEGER;  A2 : CHARACTER )
                              RETURN CHARACTER ; 
               END  PACK2; 

          END  PACK1; 

     BEGIN                -- ERROR: BOTH BODIES MISSING

          NULL; 
     END; 

     DECLARE

          PACKAGE PACK3 IS

               PACKAGE IN3 IS
                    TASK T;
               END IN3;

          END PACK3;

     BEGIN               -- ERROR: BODY OF PACK3 MISSING.
          NULL;
     END;

     DECLARE

          PACKAGE PACK4 IS
               PACKAGE IN2 IS
               PRIVATE
                    TYPE INC;
               END IN2;
          END PACK4;

     BEGIN          -- ERROR: BODY OF PACK4 MISSING.
          NULL;
     END;

END B73001D;
