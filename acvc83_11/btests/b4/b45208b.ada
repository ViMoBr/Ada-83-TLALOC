-- B45208B.ADA


-- CHECK THAT THE ORDERING OERATORS ARE NOT PREDEFINED FOR LIMITED
--     TYPES, MULTIDIMENSIONAL ARRAY TYPES, RECORD TYPES, ACCESS
--     TYPES, AND FOR TYPES DERIVED FROM THESE.


-- PART 1:  TYPES NOT INVOLVING TASKING OR TYPE DERIVATION.


-- CASES COVERED:              ( ">>" MARKS CASES COVERED IN THIS FILE.)

--    * LIMITED PRIVATE TYPE
-->>  * ARRAY WHOSE COMPONENTS ARE OF A LIMITED PRIVATE TYPE
--          (ONE-DIMENSIONAL ARRAYS ONLY; SUCCESSFUL HANDLING
--          OF MULTIDIMENSIONAL ARRAYS IS IMPLIED BY THAT OF
--          MULTIDIMENSIONAL ARRAYS OF DISCRETE TYPES.)
--   ** ACCESS TO A LIMITED PRIVATE TYPE
--          (NOT DONE; SEE BELOW.)
--   ** RECORD WITH A COMPONENT WHICH IS OF A LIMITED PRIVATE TYPE
--          (NOT DONE; SEE BELOW.)
--   ** ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)
--          (NOT DONE; SEE BELOW.)
--   ** RECORDS OF LIMITED-TYPE ARRAYS  (AS ABOVE)
--          (NOT DONE;  SUCCESSFUL HANDLING OF THESE (AND OF MORE
--          HIGHLY COMPOSITE) LIMITED TYPES IS IMPLIED BY THE SUCCESSFUL
--          HANDLING OF
--             * ACCESS TO DISCRETE-TYPE OBJECTS;
--             * ONE-DIMENSIONAL ARRAYS;
--             * MULTIDIMENSIONAL ARRAYS OF DISCRETE-TYPE COMPONENTS;
--             * RECORDS CONTAINING DISCRETE-TYPE COMPONENTS. 
--          )
--    * ACCESS TO A DISCRETE TYPE
--          (FOR SIMILAR CASES, SEE BELOW.)
--    * RECORD WITH A COMPONENT WHICH IS OF A DISCRETE TYPE
--          (FOR SIMILAR CASES, SEE BELOW.)
--   ** MULTIDIMENSIONAL ARRAY OF DISCRETE-TYPE COMPONENTS
--          (DONE UNDER 4.5.2.F/T61)
--          (FOR SIMILAR CASES, SEE BELOW.)
--   ** ARRAY OF RECORDS
--          (NOT DONE; SEE BELOW.)
--   ** RECORDS OF ARRAYS
--          (NOT DONE;  SUCCESSFUL HANDLING OF THESE (AND OF MORE
--          HIGHLY COMPOSITE) TYPES IS IMPLIED BY THE SUCCESSFUL
--          HANDLING OF
--             * ACCESS TO DISCRETE-TYPE OBJECTS;
--             * ONE-DIMENSIONAL ARRAYS;
--             * MULTIDIMENSIONAL ARRAYS OF DISCRETE-TYPE COMPONENTS;
--             * RECORDS CONTAINING DISCRETE-TYPE COMPONENTS. 
--          )

 
-- RM  2/24/82


PROCEDURE B45208B IS

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

          TYPE  ARR  IS ARRAY ( 1..3 ) OF  LP ;
          X , Y  :  ARR ;

          PACKAGE BODY  P  IS
          BEGIN

               X(1) := AA ;
               X(2) := AA ;
               X(3) := AA ;
               Y(1) := AA ;
               Y(2) := AA ;
               Y(3) := AA ;

               IF  X < Y                -- ERROR: ORDERING NOT AVAILABLE
               THEN
                    NULL ;
               END IF;

          END  P ;

     BEGIN

          IF  X > Y                     -- ERROR: ORDERING NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X <= Y ) ;             -- ERROR: ORDERING NOT AVAILABLE

     END ;


     -------------------------------------------------------------------


END B45208B ;
