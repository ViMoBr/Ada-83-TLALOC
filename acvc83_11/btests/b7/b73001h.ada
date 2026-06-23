-- B73001H.ADA


-- CHECK THAT IF A GENERIC OR NON-GENERIC PACKAGE SPECIFICATION REQUIRES
--    A BODY, AND THE PACKAGE IS DECLARED INSIDE A GENERIC PACKAGE 
--    SPECIFICATION, BODIES MUST BE PROVIDED FOR BOTH SPECIFICATIONS.

-- RM 05/06/81
-- JBG 9/19/83
-- JBG 4/15/85

PROCEDURE  B73001H  IS
BEGIN


     DECLARE

          GENERIC
          PACKAGE  PACK1  IS

               PACKAGE  PACK2  IS
                    I  :  INTEGER; 
                    GENERIC
                    FUNCTION  FN1( A1 : INTEGER;  A2 : BOOLEAN )
                              RETURN INTEGER; 
               END  PACK2; 

          END  PACK1; 

     BEGIN               -- ERROR: BODY OF PACK1 MISSING.
          NULL; 
     END; 


     DECLARE

          GENERIC
          PACKAGE  PACK1A  IS

               PACKAGE  PACK2  IS
                    I  :  INTEGER; 
                    FUNCTION  "+"( A1 : INTEGER;  A2 : CHARACTER )
                              RETURN CHARACTER ; 
               END  PACK2; 

          END  PACK1A; 

     BEGIN                -- ERROR: BODY OF PACK1A MISSING.

          NULL; 
     END; 

     DECLARE

          GENERIC
          PACKAGE PACK3 IS

               PACKAGE IN3 IS
                    TASK T;
               END IN3;

          END PACK3;

     BEGIN               -- ERROR: BODY OF PACK3 MISSING.
          NULL;
     END;

     DECLARE

          GENERIC
          PACKAGE PACK4 IS
               PACKAGE IN2 IS
               PRIVATE
                    TYPE INC;
               END IN2;
          END PACK4;

     BEGIN          -- ERROR: BODY OF PACK4 MISSING.
          NULL;
     END;

     DECLARE

          GENERIC
          PACKAGE  PACK1  IS

               GENERIC
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

          GENERIC
          PACKAGE  PACK1B  IS

               GENERIC
               PACKAGE  PACK2  IS
                    I  :  INTEGER; 
                    FUNCTION  "+"( A1 : INTEGER;  A2 : CHARACTER )
                              RETURN CHARACTER ; 
               END  PACK2; 

          END  PACK1B; 

     BEGIN                -- ERROR: BODY OF PACK1B MISSING.

          NULL; 
     END; 

     DECLARE

          GENERIC
          PACKAGE PACK3A IS

               GENERIC
               PACKAGE IN3 IS
                    TASK T;
               END IN3;

          END PACK3A;

     BEGIN               -- ERROR: BODY OF PACK3A MISSING.
          NULL;
     END;

     DECLARE

          GENERIC
          PACKAGE PACK4A IS

               GENERIC
               PACKAGE IN2 IS
               PRIVATE
                    TYPE INC;
               END IN2;

          END PACK4A;

     BEGIN          -- ERROR: BODY OF PACK4A MISSING.
          NULL;
     END;

END B73001H;
