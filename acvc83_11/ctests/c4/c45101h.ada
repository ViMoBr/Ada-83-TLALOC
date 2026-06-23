-- C45101H.ADA


-- CHECK THE CORRECT OPERATION OF  'XOR' 
--    WITH ARITHMETIC EXPRESSIONS AS OPERANDS
--    (THE CASE OF VARIABLES AS OPERNDS IS TREATED IN A COMPANION TEST).

-- PART 2: CHECKING THE PROPERTIES OF  'XOR'

-- RM    6 OCTOBER 1980     (PART OF C45101C)
-- RM   11 JANUARY 1982
-- JBG 8/21/83

WITH  REPORT ;
PROCEDURE  C45101H  IS

     USE REPORT;

     FLOW_INDEX : INTEGER := 0 ;   -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP ;

BEGIN

     TEST( "C45101H" , "CHECK THE CORRECT OPERATION OF  'XOR'" );


     -- PART 2: CHECKING THE PROPERTIES OF  'XOR'

     ON_FIRST :
     FOR  I  IN  0..1  LOOP

          IF  ( (I>0) XOR (I>0) ) = 
              FALSE  THEN
               BUMP ;                                --     2      2
          ELSE
               FAILED( "'A XOR A' EVALUATES TO 'TRUE'" );
          END IF;

          ON_SECOND :
          FOR  J  IN  1..2  LOOP

               IF  ( (I>0) XOR (J>1) ) = 
                   ( (J>1) XOR (I>0) )  THEN
                    BUMP ;                           --     4      6
               ELSE
                    FAILED( "'XOR' NOT COMMUTATIVE" );
               END IF;

               IF  ( (J>1) XOR ( (I>0) XOR (J>1) )) = 
                   (I>0)  THEN
                    BUMP ;                           --     4     10
               ELSE
                    FAILED( "TWICE 'XOR B' IS NOT A NO-OP" );
               END IF;

               IF  ( (I>0) XOR (J>1) ) = 
                   (( (I>0) AND (NOT(J>1)) ) OR ( (J>1) AND (NOT(I>0))))
               THEN
                    BUMP ;                           --     4     14
               ELSE
                    FAILED( "'XOR' FAILS BASIC PROPERTY" );
               END IF;

               IF  (NOT( (I>0) XOR (J>1) )) = 
                   ( (I>0) = (J>1) )
               THEN
                    BUMP ;                           --     4     18
               ELSE
                    FAILED( "'NOT-XOR' FAILS BASIC PROPERTY" );
               END IF;

               ON_THIRD :
               FOR  K  IN  REVERSE INTEGER RANGE -1..0  LOOP
                    IF  (  (I>0) XOR ( (J>1) XOR (K<0) )) = 
                        ((  (I>0) XOR (J>1) ) XOR (K<0) ) THEN
                         BUMP ;                      --     8     26
                    ELSE
                         FAILED( "'XOR' NOT ASSOCIATIVE" );
                    END IF;

                    IF  (  (I>0) XOR (J>1) XOR (K<0) ) = 
                        ((  (I>0) XOR (J>1) ) XOR (K<0) )  THEN
                         BUMP ;                      --     8     34
                    ELSE
                         FAILED( "'XOR'-CHAINS INCORRECT" );
                    END IF;


               END LOOP ON_THIRD;

          END LOOP ON_SECOND;

     END LOOP ON_FIRST;   -- FLOW_INDEX:  34


     IF  FLOW_INDEX  /= 34  THEN  FAILED( "WRONG FLOW_INDEX" );
     END IF;


     RESULT;


END C45101H;
