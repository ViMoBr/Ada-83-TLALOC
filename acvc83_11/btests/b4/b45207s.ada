-- B45207S.ADA


-- CHECK THAT EQUALITY AND INEQUALITY ARE NOT PREDEFINED FOR LIMITED
--     TYPES.


-- PART 4: LIMITED TYPES INVOLVING BOTH TASKING AND TYPE DERIVATION.


-- CASES COVERED (ALL TYPES COVERED HERE INVOLVE TASK TYPES WHOSE
--     TASK NATURE IS DISCLOSED UP FRONT, AS DISTINGUISHED FROM
--     LIMITED PRIVATE TYPES WHICH TURN OUT TO BE REALIZED AS
--     (OR IN TERMS OF) TASKS;  F U R T H E R M O R E ,
--     ALL TYPES COVERED HERE INVOLVE DERIVATION, EITHER
--     "OUTSIDE" (E.G. TYPE DERIVED FROM AN ARRAY OF TASKS),
--     OR "INSIDE" (E.G. ARRAY OF OBJECTS WHOSE TYPE IS DERIVED FROM
--     A TASK TYPE) :       ( ">>" MARKS CASES COVERED IN THIS FILE.)

-->>  * TASK TYPE
--    * ARRAY WHOSE COMPONENTS ARE OF A TASK TYPE
--    * RECORD WITH A COMPONENT WHICH IS OF A TASK TYPE
--    * ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)
--    * RECORDS OF LIMITED-TYPE ARRAYS  (AS ABOVE)
--    * ARRAY WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          TASK TYPE
--    * RECORD ALL OF WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          TASK TYPE


-- RM  2/23/82


PROCEDURE B45207S IS

BEGIN

     -------------------------------------------------------------------
     --------------------------  D(TASK)  ------------------------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TASK TYPE  TT  IS
               ENTRY  E1 ;
          END  TT ;

          TYPE  DTT  IS NEW  TT ;
          X , Y  :  DTT ;

          TASK BODY  TT  IS
          BEGIN
               ACCEPT  E1  DO
                    NULL;
               END  E1 ;
          END  TT ;

     BEGIN

          IF  X = Y                     -- ERROR: EQUALITY NOT AVAILABLE
          THEN
               NULL ;
          END IF;

          B := ( X /= Y ) ;             -- ERROR: EQUALITY NOT AVAILABLE

     END ;


     -------------------------------------------------------------------


END B45207S ;
