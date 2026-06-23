-- C45111E.ADA

-- CHECK THE CORRECT OPERATION OF  'XOR' ( INCLUDING COMBINATIONS 
-- WITH  'NOT' ) ON ARRAY VARIABLES  WITH DERIVED BOOLEAN TYPES AS 
-- COMPONENTS AND ALSO ON DERIVED ARRAYS OF DERIVED BOOLEAN TYPES.

-- CHECK THE AXIOMS FOR 'XOR'.

-- SUBTESTS:
--     (A). ARRAY VARIABLES WITH DERIVED BOOLEAN TYPES AS COMPONENTS.
--     (B). DERIVED ARRAYS OF DERIVED BOOLEAN TYPES.

--    RJW  1/9/86

WITH  REPORT; 
PROCEDURE  C45111E  IS

     USE REPORT;

     FLOW_INDEX : INTEGER := 0;   
 

     TYPE NEWBOOL IS NEW BOOLEAN;
     TYPE T IS ARRAY (1..8) OF NEWBOOL;

     A : T := ( TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE );
     B : T := ( TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE );
     C : T := ( TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE );
     
     TYPE DT IS NEW T;

     DA : DT := ( TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE );
     DB : DT := ( TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE );
     DC : DT := ( TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE );


     TRU_ARR  : T  := ( TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, 
                        TRUE );
     DTRU_ARR : DT := ( TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, 
                        TRUE );
     
     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1; 
     END BUMP; 

BEGIN

     TEST( "C45111E" , "CHECK THE AXIOMS FOR  'XOR' FOR (DERIVED) " &
                       "ARRAYS OF DERIVED BOOLEAN" );


     -- (A)
                                                    --    BUMP VALUES:

     IF  ( A XOR A ) = ( NOT TRU_ARR )  THEN
          BUMP;                                     --          1
     ELSE
          FAILED( "'A XOR A' EVALUATES TO 'TRUE' - (A)" );
     END IF;

     IF  ( A XOR B ) = ( B XOR A )  THEN
          BUMP;                                     --          2
     ELSE
          FAILED( "'XOR' NOT COMMUTATIVE - (A)" );
     END IF;

     IF  ( B XOR ( A XOR B )) = A  THEN
          BUMP;                                     --          3
     ELSE
          FAILED( "TWICE 'XOR B' IS NOT A NO-OP - (A)" );
     END IF;

     IF  ( A XOR B ) = (( A AND (NOT B) ) OR ( B AND (NOT A))) THEN
          BUMP;                                     --          4
     ELSE
          FAILED( "'XOR' FAILS BASIC PROPERTY - (A)" );
     END IF;

     IF  (NOT( A XOR B )) = (( NOT A OR B ) AND ( NOT B OR A )) THEN
          BUMP;                                     --          5
     ELSE
          FAILED( "'NOT-XOR' FAILS BASIC PROPERTY - (A)" );
     END IF;

     IF  ( A XOR ( B XOR C )) = (( A XOR B ) XOR C ) THEN
          BUMP;                                     --          6
     ELSE
          FAILED( "'XOR' NOT ASSOCIATIVE - (A)" );
     END IF;

     IF  ( A XOR B XOR C ) = (( A XOR B ) XOR C )  THEN
          BUMP;                                     --          7
     ELSE
          FAILED( "'XOR'-CHAINS INCORRECT - (A)" );
     END IF;

    --------------------------------------------------------------------

     -- (B)


     IF  ( DA XOR DA ) = ( NOT DTRU_ARR )  THEN
          BUMP;                                     --          8
     ELSE
          FAILED( "'A XOR A' EVALUATES TO 'TRUE' - (B)" );
     END IF;

     IF  ( DA XOR DB ) = ( DB XOR DA )  THEN
          BUMP;                                     --          9
     ELSE
          FAILED( "'XOR' NOT COMMUTATIVE - (B)" );
     END IF;

     IF  ( DB XOR ( DA XOR DB )) = DA  THEN
          BUMP;                                     --          10
     ELSE
          FAILED( "TWICE 'XOR B' IS NOT A NO-OP - (B)" );
     END IF;

     IF  ( DA XOR DB ) = (( DA AND ( NOT DB )) OR ( DB AND ( NOT DA )))
     THEN
          BUMP;                                     --          11
     ELSE
          FAILED( "'XOR' FAILS BASIC PROPERTY - (B)" );
     END IF;

     IF  (NOT( DA XOR DB )) = (( NOT DA OR DB ) AND ( NOT DB OR DA ))
     THEN
          BUMP;                                     --          12
     ELSE
          FAILED( "'NOT-XOR' FAILS BASIC PROPERTY - (B)" );
     END IF;

     IF  ( DA XOR ( DB XOR DC )) = (( DA XOR DB ) XOR DC ) THEN
          BUMP;                                     --          13
     ELSE
          FAILED( "'XOR' NOT ASSOCIATIVE - (B)" );
     END IF;

     IF  ( DA XOR DB XOR DC ) = (( DA XOR DB ) XOR DC )  THEN
          BUMP;                                     --          14
     ELSE
          FAILED( "'XOR'-CHAINS INCORRECT - (B)" );
     END IF;


     IF  FLOW_INDEX  /= 14  THEN  
          FAILED( "WRONG FLOW_INDEX" );
     END IF;

     RESULT;

END C45111E;
