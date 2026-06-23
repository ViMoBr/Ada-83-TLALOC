-- A83C01C.ADA


-- CHECK THAT COMPONENT NAMES MAY BE THE SAME AS NAMES OF
--    FORMAL PARAMETERS, LABELS, LOOP PARAMETERS,
--    VARIABLES, CONSTANTS, SUBPROGRAMS, PACKAGES, TYPES.
-- (NAMES OF COMPONENTS IN LOGICALLY NESTED RECORDS ARE TESTED IN
--    C83C01B.ADA .)
-- (NAMES OF TASKS ARE TESTED IN  A83C01T.ADA .)

--    RM    24 JUNE 1980
--    JRK   10 NOV  1980
--    RM    01 JAN  1982

WITH REPORT;
PROCEDURE  A83C01C  IS

     USE REPORT;

BEGIN

     TEST( "A83C01C" , "CHECK THAT COMPONENT NAMES MAY BE THE SAME AS" &
                       " NAMES OF VARIABLES AND CONSTANTS " ) ;



     DECLARE

          VAR1 , VAR2 : INTEGER := 27 ;
          CONST1      : CONSTANT INTEGER := 13 ;
          CONST2      : CONSTANT BOOLEAN := FALSE ;

          TYPE  R1A  IS
               RECORD
                    VAR1,VAR2,CONST1:INTEGER ;
               END RECORD ;

          TYPE  R1  IS
               RECORD
                    VAR1   : INTEGER ;
                    VAR2   : BOOLEAN ;
                    CONST1 : BOOLEAN ;
                    A      : R1A ;
               END RECORD ;

          A : R1 := ( VAR1 => VAR1 , A => ( VAR1 => VAR2 ,
                                            VAR2 => VAR2 ,
                                            CONST1 => VAR1 ) ,
                      VAR2 => CONST2 , CONST1 => CONST2 ) ;

     BEGIN

          VAR1 := A.A.VAR2 ;
          A.CONST1 := CONST2 ;
          A.A.CONST1 := A.VAR1 + VAR2 ;

     END ;


     RESULT;

END A83C01C;
