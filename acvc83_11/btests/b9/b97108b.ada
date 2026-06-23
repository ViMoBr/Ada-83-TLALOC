-- B97108B.ADA


-- CHECK THAT IN A SELECTIVE_WAIT THE  'ELSE'  PART (IF PRESENT) MUST
--     BE THE LAST PART OF THE SELECTIVE_WAIT.


-- RM 4/28/1982


PROCEDURE  B97108B  IS


BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK TYPE  TT  IS
               ENTRY  A ;
          END  TT ;


          TASK BODY  TT  IS
               DUMMY : BOOLEAN := FALSE ;
          BEGIN

               SELECT
                         ACCEPT  A ;
               OR
                         ACCEPT  A ;
               ELSE
                         <<ELSE_PART>>
                         NULL ;
               OR                       -- ERROR: CANNOT FOLLOW  'ELSE'.
                         ACCEPT  A ;
               END SELECT ;

          END  TT ;


     BEGIN
          NULL ;
     END ;

     -------------------------------------------------------------------


END  B97108B ;
