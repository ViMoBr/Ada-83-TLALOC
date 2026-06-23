-- B45207J.ADA


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
--    * ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)
--    * RECORDS OF LIMITED-TYPE ARRAYS  (AS ABOVE)
-->>  * ARRAY WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          LIMITED PRIVATE TYPE
-->>  * RECORD ALL OF WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          LIMITED PRIVATE TYPE


-- RM  2/12/82
-- RM  2/22/82


PROCEDURE B45207J IS

BEGIN


     -------------------------------------------------------------------
     -----  D(ARRAY OF EQUALITY-ENDOWED LIMITED-TYPE COMPONENTS)  ------
                            
     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ENUM  IS  ( AA , BB , CC );

          PACKAGE  P  IS
               TYPE  LP  IS  LIMITED PRIVATE;
               FUNCTION "=" ( U,V:LP ) RETURN BOOLEAN ;
          PRIVATE
               TYPE  LP  IS  NEW ENUM ;
          END  P ;

          USE  P ;

          TYPE  ARR  IS  ARRAY ( CHARACTER ) OF  LP ;

          TYPE  DARR  IS NEW  ARR ;
          X , Y : DARR ;

          PACKAGE BODY  P  IS
               FUNCTION "=" ( U,V:LP ) RETURN BOOLEAN IS
               BEGIN
                    RETURN ( ENUM(U) = ENUM(V) );
               END "=" ;
          BEGIN

               IF  X = Y                -- ERROR: EQUALITY NOT AVAILABLE
               THEN
                    NULL ;
               END IF;

          END  P ;

     BEGIN

          IF  X = Y               -- ERROR: EQUALITY STILL NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X /= Y ) ;       -- ERROR: EQUALITY STILL NOT AVAILABLE

     END ;


     -------------------------------------------------------------------
     -----  RECORD OF D(EQUALITY-ENDOWED LIMITED-TYPE) COMPONENTS  -----
                            
     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ENUM  IS  ( AA , BB , CC );

          PACKAGE  P  IS
               TYPE  LP  IS  LIMITED PRIVATE;
               FUNCTION "=" ( U,V:LP ) RETURN BOOLEAN ;
          PRIVATE
               TYPE  LP  IS  NEW ENUM ;
          END  P ;

          USE  P ;

          TYPE  DLP  IS  NEW LP ;

          TYPE  REC  IS
               RECORD
                    COMPONENT1 : DLP ;
                    COMPONENT2 : DLP ;
               END RECORD;

          X , Y : REC ;

          PACKAGE BODY  P  IS
               FUNCTION "=" ( U,V:LP ) RETURN BOOLEAN IS
                    -- ALSO DERIVED BY  DLP, AS  "="(U,V:DLP)
               BEGIN
                    RETURN ( ENUM(U) = ENUM(V) );
               END "=" ;
          BEGIN

               IF  X = Y                -- ERROR: EQUALITY NOT AVAILABLE
               THEN
                    NULL ;
               END IF;

          END  P ;

     BEGIN

          IF  X = Y               -- ERROR: EQUALITY STILL NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X /= Y ) ;       -- ERROR: EQUALITY STILL NOT AVAILABLE

     END ;


     -------------------------------------------------------------------


END B45207J ;
