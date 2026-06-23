-- C52103G.ADA


-- CHECK THAT LENGTHS MUST MATCH IN ARRAY AND SLICE ASSIGNMENTS.
--    MORE SPECIFICALLY, TEST THAT ARRAY ASSIGNMENTS WITH MATCHING
--    LENGTHS DO NOT CAUSE  CONSTRAINT_ERROR  TO BE RAISED AND
--    ARE PERFORMED CORRECTLY.
--    (OVERLAPS BETWEEN THE OPERANDS OF THE ASSIGNMENT STATEMENT
--    ARE TREATED ELSEWHERE.)

-- THIS IS THE SECOND FILE IN
--    DIVISION  B : STATICALLY-DETERMINABLE NULL LENGTHS.


-- RM 07/20/81
-- SPS 3/22/83


WITH REPORT;
PROCEDURE  C52103G  IS

     USE  REPORT ;

BEGIN

     TEST( "C52103G" , "CHECK THAT IN ARRAY ASSIGNMENTS AND IN SLICE" &
                       " ASSIGNMENTS  THE LENGTHS MUST MATCH" );


     --                              ( EACH DIVISION COMPRISES 3 FILES,
     --                                COVERING RESPECTIVELY THE FIRST
     --                                3 , NEXT 2 , AND LAST 3 OF THE 8
     --                                SELECTIONS FOR THE DIVISION.)


     -------------------------------------------------------------------

     --    (5) UNSLICED ONE-DIMENSIONAL ARRAY OBJECTS WHOSE TYPEMARKS
     --        WERE DEFINED WITHOUT EVER USING THE "BOX" SYMBOL
     --        AND FOR WHICH THE COMPONENT TYPE IS  'CHARACTER' .
     --

     DECLARE

          TYPE  TA51  IS  ARRAY( INTEGER RANGE 11..10 )  OF CHARACTER ;

          ARR51  :  TA51 ;

     BEGIN


          -- ARRAY ASSIGNMENT (WITH STRING AGGREGATE):

          ARR51 :=  "" ;


          -- CHECKING THE VALUES AFTER THE ASSIGNMENT:

          IF  ARR51           /=  ""
          THEN
               FAILED( "ARRAY ASSIGNMENT NOT CORRECT (5)" );
          END IF;


     EXCEPTION

          WHEN  OTHERS  =>
               FAILED( "EXCEPTION RAISED  -  SUBTEST 5" );

     END ;


     -------------------------------------------------------------------

     --   (14) SLICED ONE-DIMENSIONAL ARRAY OBJECTS WHOSE TYPEMARKS
     --        WERE DEFINED USING THE "BOX" SYMBOL
     --        AND FOR WHICH THE COMPONENT TYPE IS  'CHARACTER' .

     DECLARE

          TYPE  TABOX4  IS  ARRAY( INTEGER RANGE <> )  OF CHARACTER ;

          SUBTYPE  TABOX42  IS  TABOX4( 11..15 );

          ARRX42  :  TABOX42 ;

     BEGIN

          -- INITIALIZATION OF LHS ARRAY:

          ARRX42  :=  "QUINC"  ;


          -- NULL SLICE ASSIGNMENT:

          ARRX42( 13..12 ) :=  "" ;


          -- CHECKING THE VALUES AFTER THE SLICE ASSIGNMENT:

          IF  ARRX42           /=  "QUINC"  OR
              ARRX42( 11..15 ) /=  "QUINC"
          THEN
               FAILED( "SLICE ASSIGNMENT NOT CORRECT (14)" );
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>
               FAILED( "EXCEPTION RAISED  -  SUBTEST 14" );

     END ;


     -------------------------------------------------------------------


     RESULT ;


END C52103G;
