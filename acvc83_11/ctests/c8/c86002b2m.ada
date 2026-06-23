-- C86002B2M.ADA


-- CHECK THAT A LIBRARY UNIT CAN BE GIVEN THE NAME  'STANDARD' .
--    CHECK THAT THE PREDEFINED PACKAGE  'STANDARD'  IS NOT REPLACED
--    BY THIS NEW UNIT.

-- PART B :  THE NEW UNIT IS A SUBPROGRAM ( A FUNCTION).  ITS
--    DEFINITION IS IN THE FILE  C86002B1.ADA .

-- RM 01/19/80


WITH  REPORT , STANDARD ;
PROCEDURE  C86002B2M  IS

     USE REPORT ;

BEGIN

     TEST("C86002B" , "CHECK THAT A (SUBPROGRAM) LIBRARY UNIT CAN BE " &
                      " GIVEN THE NAME  'STANDARD' (WITHOUT " &
                      " REPLACING THE STANDARD ENVIRONMENT)" );

     DECLARE    -- A
     BEGIN

          DECLARE

               CHAR  :  CHARACTER ;
               BOOL  :  BOOLEAN ;

          BEGIN

               CHAR  :=  IDENT_CHAR( 'Z' )   ;
               BOOL  :=  IDENT_BOOL( TRUE )  ;

               IF  ( CHAR /= 'Z'  OR
                     BOOL /= TRUE )  THEN FAILED( "WRONG VALUE  -  A ");
               END IF;

          EXCEPTION

               WHEN  OTHERS  =>  FAILED("EXCEPTION RAISED BY OPER.(A)");

          END ;

     EXCEPTION

          WHEN  OTHERS  =>  FAILED( "EXCEPTION RAISED BY DECL. (A)" );

     END ;    -- A


     DECLARE    -- B

          A , B :  INTEGER  :=  IDENT_INT( 7 ) ;

     BEGIN

          A  :=  B * 3 + IDENT_INT(5) ;
                              -- IF THE ORIGINAL STANDARD ENVIRONMENT
                              --    COMPLETELY DISAPPEARED, '*'  AND
                              --    '+'  WOULD BOTH BE UNDEFINED.

          IF  A /= 26  THEN FAILED( "WRONG VALUE  -  B ");
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>  FAILED( "EXCEPTION RAISED  -  B") ;

     END ;    -- B


     DECLARE    -- C

          C , D :  BOOLEAN := IDENT_BOOL( TRUE ) ;

     BEGIN

          C  :=  STANDARD( C , D );
          IF  C  THEN  FAILED( "WRONG BOOLEAN VALUE FOR  C " );
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>  FAILED( "EXCEPTION RAISED  -  C" );

     END ;    -- C


     RESULT ;


END C86002B2M ;
