-- B45207H.ADA


-- CHECK THAT EQUALITY AND INEQUALITY ARE NOT PREDEFINED FOR LIMITED
--     TYPES.


-- PART 2: LIMITED TYPES INVOLVING TYPE DERIVATION BUT NOT INVOLVING
--             TASKING.


-- CASES COVERED (ALL TYPES COVERED HERE INVOLVE DERIVATION, EITHER
--     "OUTSIDE" (E.G. TYPE DERIVED FROM AN ARRAY OF LIMITED TYPE),
--     OR "INSIDE" (E.G. ARRAY OF OBJECTS WHOSE TYPE IS DERIVED FROM
--     A LIMITED TYPE) :       ( ">>" MARKS CASES COVERED IN THIS FILE.)


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


PROCEDURE B45207H IS

BEGIN


     -------------------------------------------------------------------
     ---- ARRAY WHOSE COMPONENTS ARE OF A D(LIMITED PRIVATE) TYPE ------

     DECLARE

          B      : BOOLEAN := TRUE ;

          PACKAGE  P  IS
               TYPE  LP  IS  LIMITED PRIVATE;
          PRIVATE
               TYPE  LP  IS  ( AA , BB , CC );
          END  P ;

          USE  P ;

          TYPE  DLP  IS NEW  LP ;
          X , Y  :  ARRAY ( CHARACTER ) OF  DLP ;

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
     ---------  D(RECORD WITH A LIMITED-PRIVATE COMPONENT)  ------------

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
          X , Y  :  DREC ; 

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


END B45207H ;
