-- B73001A.ADA


-- CHECK THAT IF A SUBPROGRAM SPECIFICATION IS PROVIDED IN A PACKAGE
--    SPECIFICATION, A PACKAGE BODY MUST BE PROVIDED.


-- RM 05/05/81
-- JBG 9/19/83


PROCEDURE  B73001A  IS
BEGIN


     DECLARE

          PACKAGE  PACK1  IS
               PROCEDURE  PR1(A1 : INTEGER; A2 : BOOLEAN);
          END  PACK1;

     BEGIN               -- ERROR: BODY OF PACK1 MISSING.
          NULL;
     END;


     DECLARE

          PACKAGE  PACK2  IS
               FUNCTION  FN1(A1 : INTEGER; A2 : BOOLEAN; A3 : CHARACTER)
                         RETURN INTEGER;
          END  PACK2;

     BEGIN               -- ERROR: BODY OF PACK2 MISSING.
          NULL;
     END;


     DECLARE

          PACKAGE  PACK3  IS
               FUNCTION  "+"(A1 : INTEGER; A2 : CHARACTER)
                         RETURN CHARACTER ;
          END  PACK3;

     BEGIN               -- ERROR: BODY OF PACK3 MISSING.
          NULL;
     END;

END B73001A;
