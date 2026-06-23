-- B97108A.ADA


-- CHECK THAT A SELECTIVE_WAIT CANNOT HAVE MORE THAN ONE  'ELSE'  PART.


-- RM 4/28/1982


PROCEDURE  B97108A  IS


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
               ELSE                     -- ERROR: SPURIOUS  'ELSE'.
                         NULL ;
               END SELECT ;

          END  TT ;

     BEGIN
          NULL ;
     END ;

     -------------------------------------------------------------------


END  B97108A ;
