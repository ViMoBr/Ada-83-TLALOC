-- B45207I.ADA


-- CHECK THAT EQUALITY AND INEQUALITY ARE NOT PREDEFINED FOR LIMITED
--     TYPES.


-- PART 2: LIMITED TYPES INVOLVING TYPE DERIVATION BUT NOT INVOLVING
--             TASKING.


-- CASES COVERED (ALL TYPES COVERED HERE INVOLVE DERIVATION, EITHER
--     "OUTSIDE" (E.G. TYPE DERIVED FROM AN ARRAY OF LIMITED TYPE),
--     OR "INSIDE" (E.G. ARRAY OF OBJECTS WHOSE TYPE IS DERIVED FROM
--     A LIMITED TYPE) :       ( ">>" MARKS CASES COVERED IN THIS FILE.)


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

PROCEDURE B45207I IS

BEGIN


     -------------------------------------------------------------------
     ---------  ARRAY OF D(LIMITED-TYPE RECORDS) (AS ABOVE)  -----------
                            
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

          TYPE  DREC  IS NEW  REC ;
          TYPE ARR IS ARRAY ( BOOLEAN ) OF DREC ;
          X , Y  :  ARR ;

          PACKAGE BODY  P  IS
          BEGIN

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
     ----------  RECORD OF D(LIMITED-TYPE) ARRAYS (AS ABOVE)  ----------

     DECLARE    

          B      : BOOLEAN := TRUE ;

          PACKAGE  P  IS
               TYPE  LP  IS  LIMITED PRIVATE;
          PRIVATE
               TYPE  LP  IS  ( AA , BB , CC );
          END  P ;

          USE  P ;

          TYPE  DLP  IS NEW  LP ;
          TYPE ARR IS ARRAY ( BOOLEAN ) OF  DLP ;
          TYPE  REC  IS
               RECORD
                    COMPONENT : ARR ;
               END RECORD;

          X , Y  :  REC ; 

          PACKAGE BODY  P  IS
          BEGIN

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


END B45207I ;
