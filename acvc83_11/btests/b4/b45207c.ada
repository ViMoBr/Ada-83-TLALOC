-- B45207C.ADA


-- CHECK THAT EQUALITY AND INEQUALITY ARE NOT PREDEFINED FOR LIMITED
--     TYPES.


-- PART 1: LIMITED TYPES NOT INVOLVING TASKING OR TYPE DERIVATION.


-- CASES COVERED:              ( ">>" MARKS CASES COVERED IN THIS FILE.)

--    * LIMITED PRIVATE TYPE
--    * ARRAY WHOSE COMPONENTS ARE OF A LIMITED PRIVATE TYPE
--    * RECORD WITH A COMPONENT WHICH IS OF A LIMITED PRIVATE TYPE
-->>  * ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)
-->>  * RECORDS OF LIMITED-TYPE ARRAYS  (AS ABOVE)
--    * ARRAY WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          LIMITED PRIVATE TYPE
--    * RECORD ALL OF WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          LIMITED PRIVATE TYPE


-- RM  2/12/82
-- RM  2/22/82
-- SPS 12/10/82

PROCEDURE B45207C IS

BEGIN


     -------------------------------------------------------------------
     -----------  ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)  ------------
                            
     DECLARE

          B      : BOOLEAN := TRUE ;

          PACKAGE  P  IS
               TYPE  LP  IS  LIMITED PRIVATE;
          PRIVATE
               TYPE  LP  IS  ( AA , BB , CC );
          END  P ;

          USE  P ;

          TYPE  REC  IS
               RECORD
                    COMPONENT : LP ;
               END RECORD;

          TYPE ARR IS ARRAY ( BOOLEAN ) OF REC ;
          X , Y  :  ARR ;

          PACKAGE BODY  P  IS
          BEGIN

               X( TRUE  ).COMPONENT := AA ;
               Y( TRUE  ).COMPONENT := AA ;
               X( FALSE ).COMPONENT := AA ;
               Y( FALSE ).COMPONENT := AA ;

               IF  X = Y                -- ERROR: EQUALITY NOT AVAILABLE
               THEN
                    NULL ;
               END IF;

          END  P ;

     BEGIN

          IF  X = Y                     -- ERROR: EQUALITY NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X /= Y ) ;             -- ERROR: EQUALITY NOT AVAILABLE

     END ;


     -------------------------------------------------------------------
     -----------  RECORD OF LIMITED-TYPE ARRAYS (AS ABOVE)  ------------

     DECLARE    

          B      : BOOLEAN := TRUE ;

          PACKAGE  P  IS
               TYPE  LP  IS  LIMITED PRIVATE;
          PRIVATE
               TYPE  LP  IS  ( AA , BB , CC );
          END  P ;

          USE  P ;

          TYPE ARR IS  ARRAY ( BOOLEAN ) OF  LP ;
          TYPE  REC  IS
               RECORD
                    COMPONENT : ARR ;
               END RECORD;

          X , Y  :  REC ; 

          PACKAGE BODY  P  IS
          BEGIN

               X.COMPONENT( TRUE  ) := AA ;
               Y.COMPONENT( TRUE  ) := AA ;
               X.COMPONENT( FALSE ) := AA ;
               Y.COMPONENT( FALSE ) := AA ;

               IF  X = Y                -- ERROR: EQUALITY NOT AVAILABLE
               THEN
                    NULL ;
               END IF;

          END  P ;

     BEGIN

          IF  X = Y                     -- ERROR: EQUALITY NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X /= Y ) ;             -- ERROR: EQUALITY NOT AVAILABLE

     END ;


     -------------------------------------------------------------------


END B45207C ;
