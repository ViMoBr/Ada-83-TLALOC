-- C59002A.ADA


-- CHECK THAT JUMPS OUT OF AN EXCEPTION HANDLER CONTAINED IN A BLOCK
--    TO A STATEMENT IN AN ENCLOSING UNIT ARE ALLOWED AND ARE PERFORMED 
--    CORRECTLY.


-- RM 05/22/81
-- SPS 3/8/83

WITH REPORT;
PROCEDURE  C59002A  IS

     USE  REPORT ;

BEGIN

     TEST( "C59002A" , "CHECK THAT JUMPS OUT OF EXCEPTION HANDLERS" &
                       " ARE ALLOWED" );

     DECLARE

          FLOW : INTEGER := 1 ;
          EXPON: INTEGER RANGE 0..3 := 0 ;

     BEGIN

          GOTO  START ;

          FAILED( "'GOTO' NOT OBEYED" );

          << BACK_LABEL >>
          FLOW  := FLOW  * 3**EXPON ;                    -- 1*5*9
          EXPON := EXPON + 1 ;
          GOTO  FINISH ;

          << START >>
          FLOW  := FLOW  * 7**EXPON ;                    -- 1
          EXPON := EXPON + 1 ;

          DECLARE
          BEGIN
               RAISE  CONSTRAINT_ERROR ;
               FAILED( "EXCEPTION NOT RAISED  -  1" );
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    GOTO  FORWARD_LABEL ;
          END ;

          FAILED( "INNER 'GOTO' NOT OBEYED  -  1" );

          << FORWARD_LABEL >>
          FLOW  := FLOW  * 5**EXPON ;                    -- 1*5
          EXPON := EXPON + 1 ;

          DECLARE
          BEGIN
               RAISE  CONSTRAINT_ERROR ;
               FAILED( "EXCEPTION NOT RAISED  -  2" );
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    GOTO  BACK_LABEL ;
          END ;

          FAILED( "INNER 'GOTO' NOT OBETED  -  2" );

          << FINISH >>
          FLOW  := FLOW  * 2**EXPON ;                    -- 1*5*9*8

          IF  FLOW /= 360  THEN
               FAILED( "WRONG FLOW OF CONTROL" );
          END IF;

     END ;


     RESULT ;


END C59002A;
