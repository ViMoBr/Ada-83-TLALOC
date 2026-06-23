-- C45111A.ADA

-- CHECK THE CORRECT OPERATION OF  'AND' AND 'OR' ( INCLUDING
-- COMBINATIONS WITH  'NOT' ) WITH ARRAY VARIABLES AS OPERANDS.
-- CHECK THE AXIOMS FOR 'AND' AND 'OR'.

--    RJW  1/7/86

WITH REPORT; USE REPORT;
PROCEDURE  C45111A  IS

     FLOW_INDEX : INTEGER := 0;

     TYPE T2 IS ARRAY (1..2) OF BOOLEAN;
     A : T2 := ( TRUE, FALSE );

     TYPE T4 IS ARRAY (1..4) OF BOOLEAN;
     A4 : T4 := ( TRUE, TRUE, FALSE, FALSE );
     B4 : T4 := ( TRUE, FALSE, TRUE, FALSE );

     TYPE T8 IS ARRAY (1..8) OF BOOLEAN;
     A8 : T8 := ( TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE );
     B8 : T8 := ( TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE );
     C8 : T8 := ( TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE );

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1;
     END BUMP;

BEGIN

     TEST( "C45111A" , "CHECK THE AXIOMS FOR  'AND' , 'OR' FOR " &
                       "ARRAYS" );

                                                    --    BUMP VALUES:

     IF  ( A OR A ) = A  THEN
          BUMP;                                     --          1
     ELSE
          FAILED( "'OR' NOT IDEMPOTENT" );
     END IF;

     IF  ( A AND A ) = A  THEN
          BUMP;                                     --          2
     ELSE
          FAILED( "'AND' NOT IDEMPOTENT" );
     END IF;

     IF  ( A4 OR B4 ) = ( B4 OR A4 )  THEN
          BUMP;                                     --          3
     ELSE
          FAILED( "'OR' NOT COMMUTATIVE" );
     END IF;

     IF  ( A4 AND B4 ) = ( B4 AND A4 )  THEN
         BUMP;                                      --          4
     ELSE
          FAILED( "'AND' NOT COMMUTATIVE" );
     END IF;

     IF  ( A4 AND ( A4 OR B4 )) = A4  THEN
          BUMP;                                     --          5
     ELSE
          FAILED( "'AND-OR' ABSORPTION" );
     END IF;

     IF  ( A4 OR ( A4 AND B4 )) = A4  THEN
          BUMP;                                     --          6
     ELSE
          FAILED( "'OR-AND' ABSORPTION" );
     END IF;

     IF  ( NOT( A4 OR B4 )) = (( NOT A4 ) AND ( NOT B4 ))  THEN
          BUMP;                                     --          7
     ELSE
          FAILED( "'NOT-OR'  DE MORGAN" );
     END IF;

     IF  ( NOT( A4 AND B4 )) = (( NOT A4 ) OR ( NOT B4 ))  THEN
          BUMP;                                      --          8
     ELSE
          FAILED( "'NOT-AND'  DE MORGAN" );
     END IF;

     IF  ( A8 AND ( B8 AND C8 )) = (( A8 AND B8 ) AND C8 ) THEN
          BUMP;                                      --          9
     ELSE
          FAILED( "'AND' NOT ASSOCIATIVE" );
     END IF;

     IF  ( A8 OR ( B8 OR C8 )) = (( A8 OR B8 ) OR C8 )  THEN
          BUMP;                                      --          10
     ELSE
          FAILED( "'OR' NOT ASSOCIATIVE" );
     END IF;

     IF  ( A8 AND B8 AND C8 ) = (( A8 AND B8 ) AND C8 )  THEN
          BUMP;                                      --          11
     ELSE
          FAILED( "'AND'-CHAINS INCORRECT" );
     END IF;

     IF  ( A8 OR B8 OR C8 ) = (( A8 OR B8 ) OR C8 )  THEN
          BUMP;                                      --          12
     ELSE
          FAILED( "'OR'-CHAINS INCORRECT" );
     END IF;

     IF  ( A8 AND ( B8 OR C8 )) = (( A8 AND B8 ) OR ( A8 AND C8 )) THEN
          BUMP;                                      --          13
     ELSE
          FAILED( "'AND' DOES NOT DISTRIBUTE OVER 'OR'");
     END IF;

     IF  ( A8 OR ( B8 AND C8 )) = (( A8 OR B8 ) AND ( A8 OR C8 )) THEN
          BUMP;                                      --          14
     ELSE
          FAILED( "'OR' DOES NOT DISTRIBUTE OVER 'AND'");
     END IF;


     IF  FLOW_INDEX  /= 14  THEN
          FAILED ( "WRONG FLOW_INDEX" );
     END IF;


     RESULT;

END C45111A;
