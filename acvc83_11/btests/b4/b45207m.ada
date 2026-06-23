-- B45207M.ADA


-- CHECK THAT EQUALITY AND INEQUALITY ARE NOT PREDEFINED FOR LIMITED
--     TYPES.


-- PART 3: LIMITED TYPES INVOLVING TASKING BUT NOT INVOLVING
--     TYPE DERIVATION.


-- CASES COVERED (ALL TYPES COVERED HERE INVOLVE TASK TYPES WHOSE
--     TASK NATURE IS DISCLOSED UP FRONT, AS DISTINGUISHED FROM
--     LIMITED PRIVATE TYPES WHICH TURN OUT TO BE REALIZED AS
--     (OR IN TERMS OF) TASKS)
--                             ( ">>" MARKS CASES COVERED IN THIS FILE.)

-->>  * TASK TYPE
--    * ARRAY WHOSE COMPONENTS ARE OF A TASK TYPE
--    * RECORD WITH A COMPONENT WHICH IS OF A TASK TYPE
--    * ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)
--    * RECORDS OF LIMITED-TYPE ARRAYS  (AS ABOVE)
--    * ARRAY WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          TASK TYPE
--    * RECORD ALL OF WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          TASK TYPE


-- RM  2/19/82


PROCEDURE B45207M IS

BEGIN

     -------------------------------------------------------------------
     ---------------------------   TASK   ------------------------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TASK TYPE  TT  IS
               ENTRY  E1 ;
          END  TT ;

          X , Y  :  TT ;

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


END B45207M ;
