-- B73001E.ADA


-- CHECK THAT IF A GENERIC SUBPROGRAM SPECIFICATION IS PROVIDED IN A 
--    GENERIC OR NON-GENERIC PACKAGE SPECIFICATION, A PACKAGE BODY
--    MUST BE PROVIDED.


-- RM 05/05/81
-- JBG 9/19/83

PROCEDURE  B73001E  IS
BEGIN

     DECLARE

          PACKAGE  PACK1  IS
               GENERIC
               PROCEDURE  PR1(A1 : INTEGER; A2 : BOOLEAN);
          END  PACK1;

     BEGIN               -- ERROR: BODY OF PACK1 MISSING.
          NULL;
     END;


     DECLARE

          PACKAGE  PACK2  IS
               GENERIC
               FUNCTION  FN1(A1 : INTEGER; A2 : BOOLEAN; A3 : CHARACTER)
                         RETURN INTEGER;
          END  PACK2;

     BEGIN               -- ERROR: BODY OF PACK2 MISSING
          NULL;
     END;

     DECLARE

          GENERIC
          PACKAGE  PACK3  IS
               GENERIC
               PROCEDURE  PR1(A1 : INTEGER; A2 : BOOLEAN);
          END  PACK3;

     BEGIN               -- ERROR: BODY OF PACK3 MISSING.
          NULL;
     END;


     DECLARE

          GENERIC
          PACKAGE  PACK4  IS
               GENERIC
               FUNCTION  FN1(A1 : INTEGER; A2 : BOOLEAN; A3 : CHARACTER)
                         RETURN INTEGER;
          END  PACK4;

     BEGIN               -- ERROR: BODY OF PACK4 MISSING.
          NULL;
     END;


END B73001E;
