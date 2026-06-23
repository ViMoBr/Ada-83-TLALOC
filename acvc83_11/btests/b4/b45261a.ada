-- B45261A.ADA


-- CHECK THAT THE ORDERING OPERATORS ARE NOT PREDEFINED FOR MULTI-
--     DIMENSIONAL ARRAYS OF FOR ONE-DIMENSIONAL ARRAYS OF NON-DISCRETE
--     TYPES.

-- CASES COVERED:              ( ">>" MARKS CASES COVERED IN THIS FILE.)

-->>  * ARRAY ( INT , INT , INT )
-->>  * ARRAY ( CHAR , CHAR )
-->>  * ARRAY ( BOOL , USER-DEF. ENUM. )

--    * ARRAY ( ACCESS-TO-INT )
--    * ARRAY ( "<"-ENDOWED ACCESS-TO-INT )
--    * ARRAY ( CHARACTERSTRING )
--    * ARRAY ( FIXED )
--    * ARRAY ( FLOAT )

 
-- RM  2/26/82


PROCEDURE B45261A IS

BEGIN

     -------------------------------------------------------------------
     --------------------  ARRAY ( INT , INT , INT )  ------------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ARR  IS ARRAY ( 1..3 , 1..3 , 1..3 ) OF BOOLEAN ;
          X , Y  :  ARR ;

     BEGIN

          IF  X > Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X <= Y ) ;             -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------
     -----------------------  ARRAY ( CHAR , CHAR )  -------------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ARR  IS ARRAY ( CHARACTER , CHARACTER ) OF INTEGER ;
          X , Y  :  ARR ;

     BEGIN

          IF  X > Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X <= Y ) ;             -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------
     -----------------  ARRAY ( BOOL , USER-DEF. ENUM. )  --------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ENUM  IS ( AA , BB , CC );
          TYPE  ARR  IS ARRAY ( BOOLEAN , ENUM ) OF CHARACTER ;
          X , Y  :  ARR ;

     BEGIN

          IF  X > Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X <= Y ) ;             -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------


END B45261A ;
