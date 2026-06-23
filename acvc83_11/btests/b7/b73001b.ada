-- B73001B.ADA


-- CHECK THAT IF A TASK SPECIFICATION IS PROVIDED IN A PACKAGE
--    SPECIFICATION, A PACKAGE BODY MUST BE PROVIDED.


-- RM 05/05/81
-- ABW 6/17/82
-- JBG 9/19/83

PROCEDURE  B73001B  IS
BEGIN


     DECLARE

          PACKAGE  PACK1  IS
               TASK  TK1;
          END  PACK1;

     BEGIN               -- ERROR: PACK1 BODY MISSING.
          NULL;
     END;


     DECLARE

          PACKAGE  PACK2  IS
               TASK TYPE  TK1;
          END  PACK2;

     BEGIN               -- ERROR: PACK2 BODY MISSING.
          NULL;
     END;


     DECLARE

          PACKAGE  PACK3  IS
               TASK  TK1  IS
                    ENTRY  E1;
               END  TK1;
          END  PACK3;

     BEGIN               -- ERROR: PACK3 BODY MISSING.
          NULL;
     END;


     DECLARE

          PACKAGE  PACK4  IS
               TASK TYPE  TK1  IS
                    ENTRY  E1;
               END  TK1;
          END  PACK4;

     BEGIN               -- ERROR: PACK4 BODY MISSING.
          NULL;
     END;


END B73001B;
