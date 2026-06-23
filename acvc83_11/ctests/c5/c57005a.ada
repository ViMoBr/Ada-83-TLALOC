-- C57005A.ADA


-- CHECK THAT CONDITIONS OF A TYPE DERIVED FROM  'BOOLEAN'  ARE ALLOWED
--    IN EXIT STATEMENTS.


--  RM 07/23/82
-- SPS 3/7/83

WITH REPORT;
PROCEDURE  C57005A  IS

     USE  REPORT ;

BEGIN

     TEST( "C57005A" , "CHECK THAT  CONDITIONS OF A TYPE DERIVED FROM" &
                       "  'BOOLEAN'  ARE ALLOWED IN EXIT STATEMENTS"  );

     DECLARE

          TYPE  NEWBOOL  IS NEW BOOLEAN ;
          BNEW : NEWBOOL ;
          B : BOOLEAN ;

     BEGIN

          BNEW := NEWBOOL(IDENT_BOOL( TRUE ));
          WHILE BOOLEAN'(TRUE) LOOP
               EXIT  WHEN  BNEW ;
               FAILED( "LOOP1" );
               EXIT ;
          END LOOP;

          B := IDENT_BOOL(TRUE);
          WHILE BOOLEAN'(TRUE) LOOP
               EXIT  WHEN  NEWBOOL (B) ;
               FAILED( "LOOP2" );
               EXIT ;
          END LOOP;

          FOR  I  IN  1..1  LOOP
               EXIT WHEN  NEWBOOL'PRED(BNEW) ;
               COMMENT( "EXIT CORRECTLY REJECTED" )  ;
               EXIT WHEN  NEWBOOL'SUCC(NOT( BNEW) )  ;
               FAILED( "LOOP3" );
          END LOOP;

          FOR  I  IN  1..1  LOOP
               EXIT WHEN  NOT BNEW OR ELSE TRUE ;
               FAILED( "LOOP4" );
          END LOOP;

     END ;


     RESULT ;


END  C57005A ;
