-- B83A01C.ADA

-- CHECK THAT A STATEMENT LABEL INSIDE AN ACCEPT STATEMENT CANNOT BE
--    THE SAME AS A STATEMENT LABEL OUTSIDE IT.

-- RM  02/05/80
-- EG  10/18/85  CORRECT ERROR COMMENTS.

-- TYPE OF ERRORS:
--         DUPL.1 : ILLEGAL REDECLARATION IN SAME SEQ. OF DECLARATIONS
--         DUPL.2 : LABEL NOT DISTINCT

PROCEDURE  B83A01C  IS

     TASK  TASK1  IS
          ENTRY  E1 ;
          ENTRY  E2 ;
     END  TASK1 ;

     TASK BODY  TASK1  IS
     BEGIN

          << LAB_OUTSIDE_INACCEPT >>             NULL ;

          BEGIN

               << LAB_INBLOCK_INACCEPT >>        NULL ;

               FOR  I  IN  1..2  LOOP
                    << LAB_INBLOCKLOOP_INACCEPT>>NULL ;
               END LOOP;

          END ;

          FOR  I  IN  INTEGER  LOOP
               << LAB_INLOOP_INACCEPT >>         NULL ;
          END LOOP;

          ACCEPT  E1  DO
               << LAB_OUTSIDE_INACCEPT >>        NULL ;-- ERROR: DUPL.1
               << LAB_INBLOCK_INACCEPT >>        NULL ;-- ERROR: DUPL.2
               << LAB_INBLOCKLOOP_INACCEPT>>     NULL ;-- ERROR: DUPL.2
               << LAB_INLOOP_INACCEPT >>         NULL ;-- ERROR: DUPL.1
               << LAB_INACCEPT_INACCEPT >>       NULL ;
          END  E1 ;

          ACCEPT  E2  DO
               << LAB_INACCEPT_INACCEPT >>       NULL ;-- ERROR: DUPL.1
          END  E2 ;

     END  TASK1 ;

BEGIN

     NULL ;

END B83A01C ;
