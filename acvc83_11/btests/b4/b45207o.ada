-- B45207O.ADA


-- CHECK THAT EQUALITY AND INEQUALITY ARE NOT PREDEFINED FOR LIMITED
--     TYPES.


-- PART 3: LIMITED TYPES INVOLVING TASKING BUT NOT INVOLVING
--     TYPE DERIVATION.


-- CASES COVERED (ALL TYPES COVERED HERE INVOLVE TASK TYPES WHOSE
--     TASK NATURE IS DISCLOSED UP FRONT, AS DISTINGUISHED FROM
--     LIMITED PRIVATE TYPES WHICH TURN OUT TO BE REALIZED AS
--     (OR IN TERMS OF) TASKS)
--                             ( ">>" MARKS CASES COVERED IN THIS FILE.)

--    * TASK TYPE
--    * ARRAY WHOSE COMPONENTS ARE OF A TASK TYPE
--    * RECORD WITH A COMPONENT WHICH IS OF A TASK TYPE
-->>  * ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)
-->>  * RECORDS OF LIMITED-TYPE ARRAYS  (AS ABOVE)
--    * ARRAY WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          TASK TYPE
--    * RECORD ALL OF WHOSE COMPONENTS ARE OF AN EQUALITY-ENDOWED
--          TASK TYPE


-- RM  2/22/82
-- RM  2/23/82  (GIVE NAME TO EACH ANON. TYPE USED FOR SEVERAL OBJECTS)


PROCEDURE B45207O IS

BEGIN

 
     -------------------------------------------------------------------
     -----------  ARRAY OF LIMITED-TYPE RECORDS (AS ABOVE)  ------------
     
     DECLARE

          B      : BOOLEAN := TRUE ;

          TASK TYPE  TT  IS
               ENTRY  E1 ;
          END  TT ;

          TYPE  REC  IS
               RECORD
                    COMPONENT : TT ;
               END RECORD;

          TYPE  ARR  IS ARRAY ( BOOLEAN ) OF  REC ;   

          X , Y  :  ARR ;

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
     -----------  RECORD OF LIMITED-TYPE ARRAYS (AS ABOVE)  ------------

     DECLARE

          B      : BOOLEAN := TRUE ;

          TASK TYPE  TT  IS
               ENTRY  E1 ;
          END  TT ;

          TYPE  ARR  IS ARRAY ( BOOLEAN ) OF  TT ;

          TYPE  REC  IS
               RECORD
                    COMPONENT : ARR ;
               END RECORD;

          X , Y  :  REC ; 

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


END B45207O ;
