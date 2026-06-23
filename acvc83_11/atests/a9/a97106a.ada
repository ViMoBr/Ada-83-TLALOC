-- A97106A.ADA


-- CHECK THAT A SELECTIVE_WAIT MAY HAVE MORE THAN ONE  'DELAY'  ALTER-
--    NATIVE.


-- RM 4/27/1982


WITH REPORT;
USE REPORT;
PROCEDURE  A97106A  IS


BEGIN


     TEST ( "A97106A" , "CHECK THAT A SELECTIVE_WAIT MAY HAVE" &
                        " MORE THAN ONE  'DELAY'  ALTERNATIVE" );

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
                         DELAY 2.5 ;
               OR
                         ACCEPT  A ;
               OR
                         ACCEPT  A ;
               OR
                         DELAY 2.5 ;  -- MULTIPLE 'DELAY'S PERMITTED (IF
               OR                     --     AND ONLY IF SINGLE 'DELAY'S
                         DELAY 2.5 ;  --     ARE PERMITTED).
               OR
                         ACCEPT  A ;
               END SELECT ;

          END  TT ;

     BEGIN
          NULL ;
     END ;

     -------------------------------------------------------------------


     RESULT;


END  A97106A ;
