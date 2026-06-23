-- B45261B.ADA


-- CHECK THAT THE ORDERING OPERATORS ARE NOT PREDEFINED FOR MULTI-
--     DIMENSIONAL ARRAYS OF FOR ONE-DIMENSIONAL ARRAYS OF NON-DISCRETE
--     TYPES.

-- CASES COVERED:              ( ">>" MARKS CASES COVERED IN THIS FILE.)

--    * ARRAY ( INT , INT , INT )
--    * ARRAY ( CHAR , CHAR )
--    * ARRAY ( BOOL , USER-DEF. ENUM. )

-->>  * ARRAY ( ACCESS-TO-INT )
-->>  * ARRAY ( "<"-ENDOWED ACCESS-TO-INT )
-->>  * ARRAY ( CHARACTERSTRING )
--    * ARRAY ( FIXED )
--    * ARRAY ( FLOAT )

 
-- RM  2/26/82


PROCEDURE B45261B IS

BEGIN

     -------------------------------------------------------------------
     --------------------  ARRAY ( ACCESS-TO-INT )  --------------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ACC  IS ACCESS INTEGER ;
          TYPE  ARR  IS ARRAY(1..3) OF ACC ;

          X , Y  :  ARR ;

     BEGIN

          IF  X > Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X <= Y ) ;             -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------
     -------------  ARRAY ( "<"-ENDOWED ACCESS-TO-INT )  ---------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ACC  IS ACCESS INTEGER ;
          TYPE  ARR  IS ARRAY(1..3) OF ACC ;

          X , Y  :  ARR ;

          FUNCTION  "<" (U,V:ACC)  RETURN BOOLEAN  IS
          BEGIN
               RETURN ( U.ALL < V.ALL );
          END  "<" ;
          
     BEGIN

          IF  X < Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X < Y ) ;              -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------
     -----------------  ARRAY ( CHARACTERSTRING )  ---------------------


     DECLARE

          B      : BOOLEAN := TRUE ;

          TYPE  ARR  IS ARRAY ( BOOLEAN ) OF STRING(1..3) ;
          X , Y  :   ARR  :=  ( BOOLEAN  =>  "ABC" );

     BEGIN

          IF  X > Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X <= Y ) ;             -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------


END B45261B ;
