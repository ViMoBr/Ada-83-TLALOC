-- B97102I.ADA


-- CHECK THAT A  SELECT  STATEMENT USED IN A SELECTIVE WAIT MUST CONTAIN
--    AT LEAST ONE ALTERNATIVE STARTING WITH AN  ACCEPT  STATEMENT.


-- RM 3/15/1982


PROCEDURE  B97102I  IS
BEGIN


     -------------------------------------------------------------------


     DECLARE


          TASK TYPE  TT  IS
               ENTRY  A ;
          END  TT ;


          TASK BODY  TT  IS
               BUSY : BOOLEAN := FALSE ;
          BEGIN

               ACCEPT  A ;


               SELECT
               END SELECT;         -- ERROR: ACCEPT ALTERNATIVE MISSING.


          END  TT ;


     BEGIN
          NULL ;
     END  ;

     -------------------------------------------------------------------


END  B97102I ;
