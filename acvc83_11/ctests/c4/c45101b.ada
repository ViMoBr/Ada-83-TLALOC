-- C45101B.ADA


-- CHECK THE CORRECT OPERATION OF  'XOR' WITH VARIABLES AS OPERANDS
--    (THE CASE OF ARITHMETIC EXPRESSIONS AS OPERANDS IS TREATED IN A
--    COMPANION TEST).

-- PART 2: CHECKING THE PROPERTIES OF  'XOR'

--    RM    24 SEPT 1980     (PART OF C45101A)
--    RM    11 JAN  1982
-- JWC 7/8/85   RENAMED TO -AB


WITH  REPORT ;
PROCEDURE  C45101B  IS

     USE REPORT;

     CVAR : BOOLEAN := FALSE ;     -- INITIAL VALUE IRRELEVANT
     FLOW_INDEX : INTEGER := 0 ;   -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP ;

BEGIN


     TEST( "C45101B" , "CHECK THE CORRECT OPERATION OF  'XOR'" );


     ON_FIRST :
     FOR  A  IN  BOOLEAN  LOOP

          IF  ( A XOR A ) = FALSE  THEN
               BUMP ;                                --     2      2
          ELSE
               FAILED( "'A XOR A' EVALUATES TO 'TRUE'" );
          END IF;

          ON_SECOND :
          FOR  B  IN  BOOLEAN  LOOP

               IF  ( A XOR B ) = ( B XOR A )  THEN
                    BUMP ;                           --     4      6
               ELSE
                    FAILED( "'XOR' NOT COMMUTATIVE" );
               END IF;

               IF  ( B XOR ( A XOR B )) = A  THEN
                    BUMP ;                           --     4     10
               ELSE
                    FAILED( "TWICE 'XOR B' IS NOT A NO-OP" );
               END IF;

               IF  ( A XOR B ) = (( A AND (NOT B) ) OR ( B AND (NOT A)))
               THEN
                    BUMP ;                           --     4     14
               ELSE
                    FAILED( "'XOR' FAILS BASIC PROPERTY" );
               END IF;

               IF  (NOT( A XOR B )) = ( A = B )
               THEN
                    BUMP ;                           --     4     18
               ELSE
                    FAILED( "'NOT-XOR' FAILS BASIC PROPERTY" );
               END IF;

               ON_THIRD :
               FOR  C  IN  BOOLEAN  LOOP

                    IF  ( A XOR ( B XOR C )) = (( A XOR B ) XOR C ) THEN
                         BUMP ;                      --     8     26
                    ELSE
                         FAILED( "'XOR' NOT ASSOCIATIVE" );
                    END IF;

                    IF  ( A XOR B XOR C ) = (( A XOR B ) XOR C )  THEN
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

END C45101B;
