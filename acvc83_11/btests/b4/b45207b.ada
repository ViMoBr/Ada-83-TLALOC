-- B45207B.ADA


-- CHECK THAT EQUALITY AND INEQUALITY ARE NOT PREDEFINED FOR LIMITED
--     TYPES.


-- PART 1: LIMITED TYPES NOT INVOLVING TASKING OR TYPE DERIVATION.


-- CASES COVERED:              ( ">>" MARKS CASES COVERED IN THIS FILE.)

--    * LIMITED PRIVATE TYPE
-->>  * ARRAY WHOSE COMPONENTS ARE OF A LIMITED PRIVATE TYPE
-->>  * RECORD WITH A COMPONENT WHICH IS OF A LIMITED PRIVATE TYPE
--    * ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)
--    * RECORDS OF LIMITED-TYPE ARRAYS  (AS ABOVE)
--    * ARRAY WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          LIMITED PRIVATE TYPE
--    * RECORD ALL OF WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          LIMITED PRIVATE TYPE


-- RM  2/12/82
-- RM  2/22/82
-- JRK 2/2/84


PROCEDURE B45207B IS

BEGIN


     -------------------------------------------------------------------
     -----  ARRAY WHOSE COMPONENTS ARE OF A LIMITED PRIVATE TYPE  ------

     DECLARE

          B      : BOOLEAN := TRUE ;

          PACKAGE  P  IS
               TYPE  LP  IS  LIMITED PRIVATE;
          PRIVATE
               TYPE  LP  IS  ( AA , BB , CC );
          END  P ;

          USE  P ;

          TYPE  ARR  IS  ARRAY ( 1..3 ) OF  LP ;

          X , Y  :  ARR ;

          PACKAGE BODY  P  IS
          BEGIN

               X(1) := AA ;
               X(2) := AA ;
               X(3) := AA ;
               Y(1) := AA ;
               Y(2) := AA ;
               Y(3) := AA ;

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
     -----------  RECORD WITH A LIMITED-PRIVATE COMPONENT  -------------

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

          X , Y  :  REC ; 

          PACKAGE BODY  P  IS
          BEGIN

               X.COMPONENT := AA ;
               Y.COMPONENT := AA ;

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


END B45207B ;
