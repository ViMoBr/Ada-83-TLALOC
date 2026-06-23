-- B91003A.ADA


-- CHECK THAT IF A TASK SPECIFICATION IS PROVIDED IN A PACKAGE
--    SPECIFICATION, A CORRESPONDING TASK BODY MUST BE PROVIDED
--    IN A PACKAGE BODY.


-- RM 05/05/81
-- ABW 6/17/82


PROCEDURE  B91003A  IS
BEGIN


     DECLARE

          PACKAGE  PACK1  IS
               TASK  TK1;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;              -- ERROR: BODY OF  TK1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               TASK TYPE  TK1;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;              -- ERROR: BODY OF  TK1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               TASK  TK1  IS
                    ENTRY  E1;
               END  TK1;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;              -- ERROR: BODY OF  TK1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS
               TASK TYPE  TK1  IS
                    ENTRY  E1;
               END  TK1;
          END  PACK1;

          PACKAGE BODY  PACK1  IS
          END  PACK1;              -- ERROR: BODY OF  TK1  MISSING.

     BEGIN
          NULL;
     END;


     DECLARE

          PACKAGE  PACK1  IS

               PACKAGE  PACK2  IS
                    I : INTEGER;
               END  PACK2;

               TASK TYPE  TK1  IS
                    ENTRY  E1;
               END  TK1;

          END  PACK1;

          PACKAGE BODY  PACK1  IS
               PACKAGE BODY  PACK2  IS
                    TASK BODY  TK1  IS  -- ERROR: NO  TK1  IN  PACK2.
                    BEGIN
                         NULL;
                    END  TK1;
               END  PACK2;
          END  PACK1;              -- ERROR: BODY OF PACK1.TK1 MISSING.

     BEGIN
          NULL;
     END;


END B91003A;
