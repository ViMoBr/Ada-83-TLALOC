-- B63005B.ADA


-- CHECK THAT IF A GENERIC SUBPROGRAM SPECIFICATION IS PROVIDED IN A 
--    GENERIC OR NON-GENERIC PACKAGE SPECIFICATION, A CORRESPONDING 
--    SUBPROGRAM BODY MUST BE PROVIDED IN A PACKAGE BODY.


-- RM 05/05/81
-- JBG 9/19/83

PROCEDURE  B63005B  IS
BEGIN


     DECLARE

          PACKAGE  PACK1  IS
               GENERIC
               PROCEDURE  PR1(A1 : INTEGER; A2 : BOOLEAN);
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;   -- ERROR: BODY OF  PR1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               GENERIC
               FUNCTION  FN1(A1 : INTEGER; A2 : BOOLEAN; A3 : CHARACTER)
                         RETURN INTEGER;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;   -- ERROR: BODY OF  FN1  MISSING.

     BEGIN
          NULL;
     END;

     DECLARE

          GENERIC
          PACKAGE  PACK1  IS
               GENERIC
               PROCEDURE  PR1(A1 : INTEGER; A2 : BOOLEAN);
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;   -- ERROR: BODY OF  PR1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          GENERIC
          PACKAGE  PACK1  IS
               GENERIC
               FUNCTION  FN1(A1 : INTEGER; A2 : BOOLEAN; A3 : CHARACTER)
                         RETURN INTEGER;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;   -- ERROR: BODY OF  FN1  MISSING.

     BEGIN
          NULL;
     END;


END B63005B;
