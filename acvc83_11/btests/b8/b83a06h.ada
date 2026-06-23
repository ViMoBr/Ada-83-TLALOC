-- B83A06H.ADA


-- CHECK THAT IF A STATEMENT LABEL IN A LOOP OF
--    A PROCEDURE  HAS THE SAME IDENTIFIER AS AN EXCEPTION
--    KNOWN OUTSIDE THE PROCEDURE, THEN NO HANDLERS FOR THAT EXCEPTION
--    CAN EXIST INSIDE THE PROCEDURE (SINCE THE INNER LABEL HIDES THE
--    EXCEPTION).


-- RM 02/16/80
-- JBG 5/16/83

PROCEDURE  B83A06H  IS

     LABEL_EXCEPTION_1  :  EXCEPTION ;
     LABEL_EXCEPTION_2  :  EXCEPTION ;
     LABEL_EXCEPTION_3  :  EXCEPTION ;

     PROCEDURE  PROC  IS
     BEGIN

          BEGIN

               << LABEL_EXCEPTION_1 >>            NULL ;
               << CONSTRAINT_ERROR  >>            NULL ;

               FOR  I  IN  INTEGER  LOOP
                    << LABEL_EXCEPTION_2 >>       NULL ;
                    << NUMERIC_ERROR  >>          NULL ;
               END LOOP;

          END ;

          FOR  I  IN  INTEGER  LOOP
               << LABEL_EXCEPTION_3 >>            NULL ;
               << STORAGE_ERROR  >>               NULL ;
          END LOOP;

     EXCEPTION

          WHEN  LABEL_EXCEPTION_1  =>  NULL ; -- OK.
          WHEN  LABEL_EXCEPTION_2  =>  NULL ; -- OK.
          WHEN  LABEL_EXCEPTION_3  =>  NULL ; -- ERROR: EXC. NAME HIDDEN
          WHEN  STORAGE_ERROR      =>  NULL ; -- ERROR: EXC. NAME HIDDEN
          WHEN  NUMERIC_ERROR      =>  NULL ; -- OK.
          WHEN  CONSTRAINT_ERROR   =>  NULL ; -- OK.

     END PROC ;

BEGIN

     NULL ;

END B83A06H ;
