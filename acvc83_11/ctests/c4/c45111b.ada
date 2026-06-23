-- C45111B.ADA

-- CHECK THE CORRECT OPERATION OF 'XOR' WITH ARRAY VARIABLES AS
-- OPERANDS.

--    RJW  1/8/86

WITH REPORT; USE REPORT;
PROCEDURE  C45111B  IS

     FLOW_INDEX : INTEGER := 0;

     TYPE T IS ARRAY (1..8) OF BOOLEAN;
     A : T := ( TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE );
     B : T := ( TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE );
     C : T := ( TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE );

     TRUE_ARR : T := ( TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
                       TRUE);

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1;
     END BUMP;

BEGIN

     TEST( "C45111B" , "CHECK THE AXIOMS FOR 'XOR' FOR ARRAYS" );


                                                    --    BUMP VALUES:

     IF  ( A XOR A ) = ( NOT TRUE_ARR )  THEN
          BUMP;                                     --          1
     ELSE
          FAILED( "'A XOR A' EVALUATES TO 'TRUE'" );
     END IF;

     IF  ( A XOR B ) = ( B XOR A )  THEN
          BUMP;                                     --          2
     ELSE
          FAILED( "'XOR' NOT COMMUTATIVE" );
     END IF;

     IF  ( B XOR ( A XOR B )) = A  THEN
          BUMP;                                     --          3
     ELSE
          FAILED( "TWICE 'XOR B' IS NOT A NO-OP" );
     END IF;

     IF  ( A XOR B ) = (( A AND (NOT B) ) OR ( B AND (NOT A))) THEN
          BUMP;                                     --          4
     ELSE
          FAILED( "'XOR' FAILS BASIC PROPERTY" );
     END IF;

     IF  (NOT( A XOR B )) = (( NOT A OR B ) AND ( NOT B OR A )) THEN
          BUMP;                                     --          5
     ELSE
          FAILED( "'NOT-XOR' FAILS BASIC PROPERTY" );
     END IF;

     IF  ( A XOR ( B XOR C )) = (( A XOR B ) XOR C ) THEN
          BUMP;                                     --          6
     ELSE
          FAILED( "'XOR' NOT ASSOCIATIVE" );
     END IF;

     IF  ( A XOR B XOR C ) = (( A XOR B ) XOR C )  THEN
          BUMP;                                     --          7
     ELSE
          FAILED( "'XOR'-CHAINS INCORRECT" );
     END IF;


     IF  FLOW_INDEX  /= 7  THEN
          FAILED( "WRONG FLOW_INDEX" );
     END IF;

     RESULT;

END C45111B;
