-- B55B09B.ADA

-- CHECK THAT UNIVERSAL_INTEGER LOOPS RESULT IN A LOOP INDEX
--     OF TYPE INTEGER.

-- PART 1: CONTEXT SUGGESTS  "NEW INTEGER" .


-- RM 7/09/82
-- JBG 10/5/83

PROCEDURE B55B09B IS

     TYPE  T  IS  NEW INTEGER ;

     A  :  ARRAY ( INTEGER RANGE 0 .. 2 ) OF  T ;
     B  :  ARRAY ( T       RANGE 0 .. 2 ) OF  INTEGER ;

     J  :  T  := 0 ;

     C1 :  CONSTANT := 1 + 1 - 1 ;
     C2 :  CONSTANT := C1 + 1 ;

     PROCEDURE  P ( I : T ) IS
     BEGIN
          NULL ;
     END  P ;

BEGIN

     FOR  K  IN 1 .. 2  LOOP

          J        :=  K ;          -- ERROR: WRONG RHS TYPE.
          A ( K )  :=  K ;          -- ERROR: WRONG RHS TYPE.
          B ( K )  :=  K ;          -- ERROR: WRONG INDEX TYPE.
          P ( K )        ;          -- ERROR: WRONG ARGUMENT TYPE.
          A ( 0 MOD 3 )  :=  K ;    -- ERROR: WRONG RHS TYPE.
          B ( K REM 3 )  :=  7 ;    -- ERROR: WRONG "REM"-ARGUMENT TYPE.

     END LOOP;


     FOR  K  IN C1 .. C2  LOOP

          DECLARE

               PROCEDURE  Q ( L : T ) IS
               BEGIN

                    J        :=  K ;      -- ERROR: WRONG RHS TYPE.
                    A ( K )  :=  K ;      -- ERROR: WRONG RHS TYPE.
                    B ( K )  :=  K ;      -- ERROR: WRONG INDEX TYPE.
                    P ( K )        ;      -- ERROR: WRONG ARGUMENT TYPE.
                    A ( K MOD 3 )  :=  K ;-- ERROR: WRONG RHS TYPE.
                    B ( K REM 3 )  :=  K ;-- ERROR: WRONG "REM"-ARGUMENT
                                          --     TYPE.

               END  Q ;

          BEGIN
               NULL ;
          END ;

     END LOOP;


END  B55B09B ;
