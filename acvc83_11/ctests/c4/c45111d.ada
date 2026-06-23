-- C45111D.ADA

-- CHECK THE CORRECT OPERATION OF  'AND' AND 'OR' (INCLUDING
-- COMBINATIONS WITH  'NOT' ) ON OPERANDS WHICH ARE ARRAY VARIABLES
-- WITH DERIVED BOOLEAN TYPES AS COMPONENTS AND ALSO ON DERIVED ARRAYS
-- OF DERIVED BOOLEANS.

-- SUBTESTS:
--     (A). ARRAY VARIABLES WITH DERIVED BOOLEAN TYPES AS COMPONENTS.
--     (B). DERIVED ARRAYS OF DERIVED BOOLEAN TYPES.

--     RJW  1/8/86

WITH  REPORT;
PROCEDURE  C45111D  IS

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

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1;
     END BUMP;

BEGIN

     TEST( "C45111D" , "CHECK THE AXIOMS FOR  'AND' , 'OR' FOR " &
                       "(DERIVED) ARRAYS OF DERIVED BOOLEAN" );

     -- (A)


                                                    --    BUMP VALUES:

     IF  ( A OR A ) = A  THEN
          BUMP;                                     --          1
     ELSE
          FAILED( "'OR' NOT IDEMPOTENT - (A)" );
     END IF;

     IF  ( A AND A ) = A  THEN
          BUMP;                                     --          2
     ELSE
          FAILED( "'AND' NOT IDEMPOTENT - (A)" );
     END IF;

     IF  ( A OR B ) = ( B OR A )  THEN
          BUMP;                                     --          3
     ELSE
          FAILED( "'OR' NOT COMMUTATIVE - (A)" );
     END IF;

     IF  ( A AND B ) = ( B AND A )  THEN
         BUMP;                                      --          4
     ELSE
          FAILED( "'AND' NOT COMMUTATIVE - (A)" );
     END IF;

     IF  ( A AND ( A OR B )) = A  THEN
          BUMP;                                     --          5
     ELSE
          FAILED( "'AND-OR' ABSORPTION - (A)" );
     END IF;

     IF  ( A OR ( A AND B )) = A  THEN
          BUMP;                                     --          6
     ELSE
          FAILED( "'OR-AND' ABSORPTION - (A)" );
     END IF;

     IF  ( NOT( A OR B )) = (( NOT A ) AND ( NOT B ))  THEN
          BUMP;                                     --          7
     ELSE
          FAILED( "'NOT-OR'  DE MORGAN - (A)" );
     END IF;

     IF  ( NOT( A AND B )) = (( NOT A ) OR ( NOT B ))  THEN
          BUMP;                                      --          8
     ELSE
          FAILED( "'NOT-AND'  DE MORGAN - (A)" );
     END IF;

     IF  ( A AND ( B AND C )) = (( A AND B ) AND C ) THEN
          BUMP;                                      --          9
     ELSE
          FAILED( "'AND' NOT ASSOCIATIVE - (A)" );
     END IF;

     IF  ( A OR ( B OR C )) = (( A OR B ) OR C )  THEN
          BUMP;                                      --          10
     ELSE
          FAILED( "'OR' NOT ASSOCIATIVE - (A)" );
     END IF;

     IF  ( A AND B AND C ) = (( A AND B ) AND C )  THEN
          BUMP;                                      --          11
     ELSE
          FAILED( "'AND'-CHAINS INCORRECT - (A)" );
     END IF;

     IF  ( A OR B OR C ) = (( A OR B ) OR C )  THEN
          BUMP;                                      --          12
     ELSE
          FAILED( "'OR'-CHAINS INCORRECT - (A)" );
     END IF;

     IF  ( A AND ( B OR C )) = (( A AND B ) OR ( A AND C )) THEN
          BUMP;                                      --          13
     ELSE
          FAILED( "'AND' DOES NOT DISTRIBUTE OVER 'OR' - (A)");
     END IF;

     IF  ( A OR ( B AND C )) = (( A OR B ) AND ( A OR C )) THEN
          BUMP;                                      --          14
     ELSE
          FAILED( "'OR' DOES NOT DISTRIBUTE OVER 'AND' - (A)");
     END IF;

     ----------------------------------------------------------------

     -- (B)


     IF  ( DA OR DA ) = DA  THEN
          BUMP;                                     --          15
     ELSE
          FAILED( "'OR' NOT IDEMPOTENT - (B)" );
     END IF;

     IF  ( DA AND DA ) = DA  THEN
          BUMP;                                     --          16
     ELSE
          FAILED( "'AND' NOT IDEMPOTENT - (B)" );
     END IF;

     IF  ( DA OR DB ) = ( DB OR DA )  THEN
          BUMP;                                     --          17
     ELSE
          FAILED( "'OR' NOT COMMUTATIVE - (B)" );
     END IF;

     IF  ( DA AND DB ) = ( DB AND DA )  THEN
         BUMP;                                      --          18
     ELSE
          FAILED( "'AND' NOT COMMUTATIVE - (B)" );
     END IF;

     IF  ( DA AND ( DA OR DB )) = DA  THEN
          BUMP;                                     --          19
     ELSE
          FAILED( "'AND-OR' ABSORPTION - (B)" );
     END IF;

     IF  ( DA OR ( DA AND DB )) = DA  THEN
          BUMP;                                     --          20
     ELSE
          FAILED( "'OR-AND' ABSORPTION - (B)" );
     END IF;

     IF  ( NOT( DA OR DB )) = (( NOT DA ) AND ( NOT DB ))  THEN
          BUMP;                                     --          21
     ELSE
          FAILED( "'NOT-OR'  DE MORGAN - (B)" );
     END IF;

     IF  ( NOT( DA AND DB )) = (( NOT DA ) OR ( NOT DB ))  THEN
          BUMP;                                      --          22
     ELSE
          FAILED( "'NOT-AND'  DE MORGAN - (B)" );
     END IF;

     IF  ( DA AND ( DB AND DC )) = (( DA AND DB ) AND DC ) THEN
          BUMP;                                      --          23
     ELSE
          FAILED( "'AND' NOT ASSOCIATIVE - (B)" );
     END IF;

     IF  ( DA OR ( DB OR DC )) = (( DA OR DB ) OR DC )  THEN
          BUMP;                                      --          24
     ELSE
          FAILED( "'OR' NOT ASSOCIATIVE - (B)" );
     END IF;

     IF  ( DA AND DB AND DC ) = (( DA AND DB ) AND DC )  THEN
          BUMP;                                      --          25
     ELSE
          FAILED( "'AND'-CHAINS INCORRECT - (B)" );
     END IF;

     IF  ( DA OR DB OR DC ) = (( DA OR DB ) OR DC )  THEN
          BUMP;                                      --          26
     ELSE
          FAILED( "'OR'-CHAINS INCORRECT - (B)" );
     END IF;

     IF  ( DA AND ( DB OR DC )) = (( DA AND DB ) OR ( DA AND DC )) THEN
          BUMP;                                      --          27
     ELSE
          FAILED( "'AND' DOES NOT DISTRIBUTE OVER 'OR' - (B)");
     END IF;

     IF  ( DA OR ( DB AND DC )) = (( DA OR DB ) AND ( DA OR DC )) THEN
          BUMP;                                      --          28
     ELSE
          FAILED( "'OR' DOES NOT DISTRIBUTE OVER 'AND' - (B)");
     END IF;


     IF  FLOW_INDEX  /= 28  THEN
          FAILED ( "WRONG FLOW_INDEX" );
     END IF;


     RESULT;

END C45111D;
