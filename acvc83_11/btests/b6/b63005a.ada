-- B63005A.ADA


-- CHECK THAT IF A SUBPROGRAM SPECIFICATION IS PROVIDED IN A PACKAGE
--    SPECIFICATION, A CORRESPONDING SUBPROGRAM BODY MUST BE
--    PROVIDED IN A PACKAGE BODY.


-- RM 05/05/81


PROCEDURE  B63005A  IS
BEGIN


     DECLARE

          PACKAGE  PACK1  IS
               PROCEDURE  PR1(A1 : INTEGER; A2 : BOOLEAN);
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;   -- ERROR: BODY OF  PR1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               FUNCTION  FN1(A1 : INTEGER; A2 : BOOLEAN; A3 : CHARACTER)
                         RETURN INTEGER;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;   -- ERROR: BODY OF  FN1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               PROCEDURE  PR1(A1 : INTEGER; A2 : BOOLEAN);
          END  PACK1;

          PACKAGE BODY  PACK1  IS
               FUNCTION   PR1(A1 : INTEGER; A2 : BOOLEAN)
                          RETURN INTEGER   IS
               BEGIN
                    RETURN 17;
               END  PR1;
          END  PACK1;   -- ERROR: BODY OF  PR1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               FUNCTION   FN1(A1 : INTEGER; A2 : BOOLEAN)
                          RETURN INTEGER;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
               PROCEDURE  FN1(A1 : INTEGER; A2 : BOOLEAN)
                          IS
               BEGIN
                    NULL;
               END  FN1;
          END  PACK1;   -- ERROR: BODY OF  FN1  MISSING.


     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               FUNCTION  "+"(A1 : INTEGER; A2 : CHARACTER)
                         RETURN CHARACTER ;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;   -- ERROR: BODY OF  "+"  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS

               PACKAGE  PACK2  IS
                    I  :  INTEGER;
               END  PACK2;

               FUNCTION  "+"(A1 : INTEGER; A2 : CHARACTER)
                         RETURN CHARACTER ;

          END  PACK1;

          PACKAGE BODY  PACK1  IS
               PACKAGE BODY  PACK2  IS
                    FUNCTION  "+"(A1 : INTEGER; A2 : CHARACTER)
                              RETURN CHARACTER  IS
                    BEGIN
                         RETURN  A2;
                    END  "+";
               END  PACK2;
          END  PACK1;   -- ERROR: BODY OF  PACK1."+"  MISSING.

     BEGIN
          NULL;
     END;


END B63005A;
