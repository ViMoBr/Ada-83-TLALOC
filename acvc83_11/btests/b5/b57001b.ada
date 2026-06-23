-- B57001B.ADA


-- CHECK THAT AN EXIT STATEMENT CANNOT TRANSFER CONTROL OUTSIDE A
--    SUBPROGRAM OR A PACKAGE.


-- RM 03/21/81
-- SPS 11/3/82

PROCEDURE  B57001B  IS
BEGIN


     BEGIN

          FOR  I  IN  1..11  LOOP

               NULL ;

               DECLARE
                    PROCEDURE  PR  IS
                    BEGIN
                         NULL ;
                         EXIT ;         -- ERROR: ACROSS SUBPROG. WALLS
                    END  PR ;
               BEGIN
                    EXIT ;              -- OK.
               END;

          END LOOP;


          FOR  I  IN  CHARACTER  LOOP

               NULL ;

               DECLARE
                    FUNCTION  FN  RETURN CHARACTER  IS
                    BEGIN
                         NULL ;
                         EXIT WHEN I='A';-- ERROR: ACROSS SUBPROG. WALLS
                         RETURN  'B' ;
                    END  FN ;
               BEGIN
                    EXIT WHEN FN = I ; -- OK.
               END;

          END LOOP;


          LOOP_ID :
          FOR  I  IN  1..11  LOOP

               NULL ;

               DECLARE

                    PACKAGE  PACK1  IS
                    END  PACK1 ;

                    PACKAGE BODY  PACK1  IS
                    BEGIN
                         LOOP
                              NULL ;
                              EXIT  LOOP_ID ;-- ERROR: ACROSS PACKAGE 
                                             -- WALLS
                         END LOOP;
                    END  PACK1 ;

               BEGIN

                    EXIT  LOOP_ID ;     -- OK.

               END;


               DECLARE

                    PACKAGE  PACK2  IS
                    END  PACK2 ;

                    PACKAGE BODY  PACK2  IS
                    BEGIN
                         NULL ;
                         EXIT ;         -- ERROR: ACROSS PACKAGE WALLS
                    END  PACK2 ;

               BEGIN

                    EXIT  LOOP_ID ;     -- OK.

               END;


               DECLARE

                    PACKAGE  PACK1  IS
                    END  PACK1 ;

                    PACKAGE BODY  PACK1  IS
                    BEGIN
                         NULL ;
                         EXIT  WHEN I = 7;-- ERROR: ACROSS PACKAGE WALLS
                    END  PACK1 ;

               BEGIN

                    EXIT  LOOP_ID ;     -- OK.

               END;


               FOR  C  IN  CHARACTER  LOOP

                    NULL ;

                    DECLARE
                         FUNCTION  FN  RETURN CHARACTER  IS
                         BEGIN
                              LOOP
                                   NULL ;
                                   RETURN  'B' ;
                                   EXIT  LOOP_ID  WHEN  
                                      C = 'A' ;  -- ERROR:
                                                 --   ACROSS SUBPROG. 
                                                 --   WALLS
                              END LOOP;
                         END  FN ;
                    BEGIN
                         EXIT  LOOP_ID  WHEN  FN = C ;      -- OK.
                    END;

               END LOOP;

          END LOOP  LOOP_ID ;

     END ;


END B57001B ;
