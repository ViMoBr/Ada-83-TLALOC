-- B97101D.ADA


-- CHECK THAT AT THE END OF A SELECT STATEMENT THE WORD  'SELECT'
--    IS REQUIRED AFTER  'END'.


-- RM 3/17/1982


PROCEDURE  B97101D  IS
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


               << NEXT_SEL >>
               SELECT
                         ACCEPT  A ;
               OR
                         ACCEPT  A ;
               END SELECT  NEXT_SEL ;       -- ERROR: BAD  'END SELECT'.


          END  TT ;


     BEGIN
          NULL ;
     END  ;

     -------------------------------------------------------------------


END  B97101D ;
