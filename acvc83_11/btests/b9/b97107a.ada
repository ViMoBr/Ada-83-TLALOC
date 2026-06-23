-- B97107A.ADA


-- CHECK THAT A SELECTIVE_WAIT CANNOT HAVE MORE THAN ONE  'TERMINATE'
--    ALTERNATIVE.


-- RM 4/28/1982
-- JBG 4/15/85

PROCEDURE  B97107A  IS


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
                         TERMINATE ;
               OR
                         ACCEPT  A ;
               OR
                         ACCEPT  A ;
               OR
                         TERMINATE ;  -- ERROR: SPURIOUS 'TERMINATE'.
               OR
                         ACCEPT  A ;
               END SELECT ;

          END  TT ;

     BEGIN
          NULL ;
     END ;

     -------------------------------------------------------------------


END  B97107A ;
