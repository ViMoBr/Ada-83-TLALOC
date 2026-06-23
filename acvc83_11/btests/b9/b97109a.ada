-- B97109A.ADA


-- CHECK THAT A  'TERMINATE'  ALTERNATIVE  AND AN  'ELSE'  PART
--     ARE NOT ALLOWED IN THE SAME SELECTIVE_WAIT.

-- SINCE AN  'ELSE'  PART FOLLOWED BY A  'TERMINATE'  (OR BY
--     ANY OTHER KIND OF SELECTIVE_WAIT COMPONENT)  IS ALREADY
--     RULED OUT BY A PREVIOUS TEST, THIS TEST WILL DEAL ONLY
--     WITH A (UNIQUE)  'ELSE'  PART CONCLUDING A SELECTIVE_WAIT
--     WHICH CONTAINS A  'TERMINATE'  ALTERNATIVE.


-- RM 4/28/1982


PROCEDURE  B97109A  IS


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
               ELSE           -- ERROR: INCOMPATIBLE WITH  'TERMINATE' .
                         NULL ;
               END SELECT ;

          END  TT ;


     BEGIN
          NULL ;
     END ;

     -------------------------------------------------------------------


END  B97109A ;
