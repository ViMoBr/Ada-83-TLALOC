-- C86002A2M.ADA


-- CHECK THAT A LIBRARY UNIT CAN BE GIVEN THE NAME  'STANDARD' .
--    CHECK THAT THE PREDEFINED PACKAGE  'STANDARD'  IS NOT REPLACED
--    BY THIS NEW UNIT.

-- PART A :  THE NEW UNIT IS A PACKAGE.  ITS SPECIFICATION IS IN THE
--    THE FILE  C86002A0.ADA , ITS BODY IN  C86002A1.ADA .

-- RM 01/19/80


WITH  REPORT , STANDARD ;
PROCEDURE  C86002A2M  IS

     USE REPORT ;

BEGIN

     TEST("C86002A" , "CHECK THAT A (PACKAGE) LIBRARY UNIT CAN BE " &
                      " GIVEN THE NAME  'STANDARD' (WITHOUT " &
                      " REPLACING THE STANDARD ENVIRONMENT)" );

     DECLARE    -- A
     BEGIN

          DECLARE

               CHAR  :  CHARACTER ;
               BOOL  :  STANDARD.CHARACTER ;  -- A BOOLEAN...

          BEGIN

               CHAR  :=  IDENT_CHAR( 'Z' )  ;
               BOOL  :=  IDENT_BOOL( TRUE ) ;

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
          USE  STANDARD ;

     BEGIN

          A  :=  B * 3 + IDENT_INT(5) ;
                              -- IF THE ORIGINAL STANDARD ENVIRONMENT
                              --    COMPLETELY DISAPPEARED, '*' WOULD
--    BE UNDEFINED, '+' WOULD BE DEFINED
--    ONLY FOR BOOLEANS.

          IF  A /= 26  THEN FAILED( "WRONG VALUE  -  B ");
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>  FAILED( "EXCEPTION RAISED  -  B") ;

     END ;    -- B


     DECLARE    -- C

          C , D :  BOOLEAN := IDENT_BOOL( TRUE ) ;
          USE  STANDARD ;

     BEGIN

          C  :=  C + D ;
          IF  C  THEN  FAILED( "WRONG BOOLEAN VALUE FOR  C " );
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>  FAILED( "EXCEPTION RAISED  -  C" );

     END ;    -- C


     RESULT ;


END C86002A2M ;
