-- B45261D.ADA


-- CHECK THAT THE ORDERING OPERATORS ARE NOT PREDEFINED FOR MULTI-
--     DIMENSIONAL ARRAYS OF FOR ONE-DIMENSIONAL ARRAYS OF NON-DISCRETE
--     TYPES.

-- CASES COVERED:              ( ">>" MARKS CASES COVERED IN THIS FILE.)

--    * ARRAY ( INT , INT , INT )
--    * ARRAY ( CHAR , CHAR )
--    * ARRAY ( BOOL , USER-DEF. ENUM. )

--    * ARRAY ( ACCESS-TO-INT )
--    * ARRAY ( "<"-ENDOWED ACCESS-TO-INT )
--    * ARRAY ( CHARACTERSTRING )
--    * ARRAY ( FIXED )
-->>  * ARRAY ( FLOAT )

 
-- RM  2/26/82


PROCEDURE B45261D IS

BEGIN

     -------------------------------------------------------------------
     --------------------  ARRAY ( FLOAT )  ----------------------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ARR  IS ARRAY (1..3) OF FLOAT ;

          X , Y  :  ARR  :=  ( 1..3  => 125.125 );

     BEGIN

          IF  X > Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X <= Y ) ;             -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------


END B45261D ;
