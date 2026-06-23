-- B59001H.ADA


-- CHECK THAT JUMPS FROM INSIDE BODIES OF ACCEPT STATEMENTS ARE NOT
--    ALLOWED.


-- RM 08/17/82
-- SPS 3/8/83

PROCEDURE  B59001H  IS
BEGIN

     DECLARE

          TASK  T  IS
               ENTRY  E1 ;
               ENTRY  E2 ;
               ENTRY  E3 ;
          END  T ;

          TASK BODY  T  IS
          BEGIN

               SELECT 
                    ACCEPT  E1  DO
                         GOTO  L111 ;      -- ERROR: JUMP FROM INSIDE
                                           --     ACCEPT BODY.
                    END;
                    << L111 >>  NULL ;
               OR
                    ACCEPT  E2 ;
                    << L222 >>  NULL ;
               OR
                    ACCEPT  E3  DO
                         GOTO  L222 ;      -- ERROR: JUMP FROM INSIDE
                                           --     ACCEPT BODY.
                    END;
               END SELECT;

          END T;

     BEGIN

          NULL ;

     END;


END  B59001H ;
