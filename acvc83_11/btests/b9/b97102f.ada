-- B97102F.ADA


-- CHECK THAT A  SELECT  STATEMENT USED IN A SELECTIVE WAIT MUST CONTAIN
--    AT LEAST ONE ALTERNATIVE STARTING WITH AN  ACCEPT  STATEMENT.


-- RM 3/15/1982


PROCEDURE  B97102F  IS
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
                    WHEN NOT BUSY =>
                         TERMINATE;
               END SELECT;         -- ERROR: ACCEPT ALTERNATIVE MISSING.



          END  TT ;


     BEGIN
          NULL ;
     END  ;

     -------------------------------------------------------------------


END  B97102F ;
