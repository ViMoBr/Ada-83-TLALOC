-- C45101K.ADA


-- CHECK THE CORRECT OPERATION OF  'AND' , 'OR' , AND 'XOR' (INCLUDING
--    COMBINATIONS WITH  'NOT' )  ON OPERANDS WHICH ARE VARIABLES OF A
--    TYPE DERIVED FROM  'BOOLEAN' .

-- PURE BOOLEANS ARE TESTED IN PREVIOUS TESTS.

-- THE TRUTH TABLES ARE CHECKED HERE (FOR VARIABLES) AND IN A COMPANION
--    TEST (FOR LITERALS).


-- RM    5 NOVEMBER 1980  ( C45101D.ADA )
-- RM   11 JANUARY  1982


WITH  REPORT ;
PROCEDURE  C45101K  IS

     USE REPORT;

     TYPE  NB  IS  NEW BOOLEAN ;     

     CVAR : NB := NB'( FALSE ) ;   -- INITIAL VALUE IRRELEVANT
     FLOW_INDEX : INTEGER := 0 ;   -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP ;

BEGIN

     TEST( "C45101K" , "CHECK THE CORRECT OPERATION OF 'AND' , 'OR' ," &
                       " AND 'XOR', INCLUDING COMBINATIONS WITH " &
                       " 'NOT' , ON DERIVED-BOOLEAN OPERANDS" ) ;

     -- PART 1: CHECKING THE AXIOMS FOR  'AND' , 'OR'

     ON_FIRST_VARIABLE :                             --    BUMP VALUES:
     FOR  A  IN  NB  LOOP                            --   NEW: | CUMUL.:

          IF  ( A OR A ) = A  THEN
               BUMP ;                                --     2      2
          ELSE
               FAILED( "'OR' NOT IDEMPOTENT" );
          END IF;

          IF  ( A AND A ) = A  THEN
               BUMP ;                                --     2      4
          ELSE
               FAILED( "'AND' NOT IDEMPOTENT" );
          END IF;

          ON_SECOND_VARIABLE :
          FOR  B  IN  NB  LOOP

               IF  ( A OR B ) = ( B OR A )  THEN
                    BUMP ;                           --     4      8
               ELSE
                    FAILED( "'OR' NOT COMMUTATIVE" );
               END IF;

               IF  ( A AND B ) = ( B AND A )  THEN
                    BUMP ;                           --     4     12
               ELSE
                    FAILED( "'AND' NOT COMMUTATIVE" );
               END IF;

               IF  ( A AND ( A OR B )) = A  THEN
                    BUMP ;                           --     4     16
               ELSE
                    FAILED( "'AND-OR' ABSORPTION" );
               END IF;

               IF  ( A OR ( A AND B )) = A  THEN
                    BUMP ;                           --     4     20
               ELSE
                    FAILED( "'OR-AND' ABSORPTION" );
               END IF;

               IF  ( NOT( A OR B )) = (( NOT A ) AND ( NOT B ))  THEN
                    BUMP ;                           --     4     24
               ELSE
                    FAILED( "'NOT-OR'  DE MORGAN" );
               END IF;

               IF  ( NOT( A AND B )) = (( NOT A ) OR ( NOT B ))  THEN
                    BUMP ;                           --     4     28
               ELSE
                    FAILED( "'NOT-AND'  DE MORGAN" );
               END IF;

               ON_THIRD_VARIABLE :
               FOR  C  IN  NB  LOOP

                    IF  ( A AND ( B AND C )) = (( A AND B ) AND C ) THEN
                         BUMP ;                      --     8     36
                    ELSE
                         FAILED( "'AND' NOT ASSOCIATIVE" );
                    END IF;

                    IF  ( A OR ( B OR C )) = (( A OR B ) OR C )  THEN
                         BUMP ;                      --     8     44
                    ELSE
                         FAILED( "'OR' NOT ASSOCIATIVE" );
                    END IF;

                    IF  ( A AND B AND C ) = (( A AND B ) AND C )  THEN
                         BUMP ;                      --     8     52
                    ELSE
                         FAILED( "'AND'-CHAINS INCORRECT" );
                    END IF;

                    IF  ( A OR B OR C ) = (( A OR B ) OR C )  THEN
                         BUMP ;                      --     8     60
                    ELSE
                         FAILED( "'OR'-CHAINS INCORRECT" );
                    END IF;

                    IF  ( A AND ( B OR C )) = (( A AND B )OR( A AND C ))
                    THEN
                         BUMP ;                      --     8     68
                    ELSE
                         FAILED( "'AND' DOES NOT DISTRIBUTE OVER 'OR'");
                    END IF;

                    IF  ( A OR ( B AND C )) = (( A OR B )AND( A OR C ))
                    THEN
                         BUMP ;                      --     8     76
                    ELSE
                         FAILED( "'OR' DOES NOT DISTRIBUTE OVER 'AND'");
                    END IF;


               END LOOP ON_THIRD_VARIABLE;

          END LOOP ON_SECOND_VARIABLE;

     END LOOP ON_FIRST_VARIABLE;   -- FLOW_INDEX: 76

     -- PART 2: CHECKING THE PROPERTIES OF  'XOR'

     ON_FIRST :
     FOR  A  IN  NB  LOOP

          IF  ( A XOR A ) = NB'( FALSE )  THEN
               BUMP ;                                --     2     78
          ELSE
               FAILED( "'A XOR A' EVALUATES TO 'TRUE'" );
          END IF;

          ON_SECOND :
          FOR  B  IN  NB  LOOP

               IF  ( A XOR B ) = ( B XOR A )  THEN
                    BUMP ;                           --     4     82
               ELSE
                    FAILED( "'XOR' NOT COMMUTATIVE" );
               END IF;

               IF  ( B XOR ( A XOR B )) = A  THEN
                    BUMP ;                           --     4     86
               ELSE
                    FAILED( "TWICE 'XOR B' IS NOT A NO-OP" );
               END IF;

               IF  ( A XOR B ) = (( A AND (NOT B) ) OR ( B AND (NOT A)))
               THEN
                    BUMP ;                           --     4     90
               ELSE
                    FAILED( "'XOR' FAILS BASIC PROPERTY" );
               END IF;

               IF  (NOT( A XOR B )) = NB( A = B )
               THEN
                    BUMP ;                           --     4     94
               ELSE
                    FAILED( "'NOT-XOR' FAILS BASIC PROPERTY" );
               END IF;

               ON_THIRD :
               FOR  C  IN  NB  LOOP

                    IF  ( A XOR ( B XOR C )) = (( A XOR B ) XOR C ) THEN
                         BUMP ;                      --     8    102
                    ELSE
                         FAILED( "'XOR' NOT ASSOCIATIVE" );
                    END IF;

                    IF  ( A XOR B XOR C ) = (( A XOR B ) XOR C )  THEN
                         BUMP ;                      --     8    110
                    ELSE
                         FAILED( "'XOR'-CHAINS INCORRECT" );
                    END IF;


               END LOOP ON_THIRD;

          END LOOP ON_SECOND;

     END LOOP ON_FIRST;   -- FLOW_INDEX: 110 (THIS LOOP: 34)

     -- PART 3: CHECKING THE TRUTH TABLES FOR 'AND' , 'OR' , 'XOR'

     FIRST :
     FOR  A  IN  NB  LOOP

          SECOND :
          FOR  B  IN  NB  LOOP

               CVAR  :=  A AND B ;
               IF  A = NB'(TRUE)  THEN
                    IF  CVAR /= B  THEN  FAILED("TT ERROR: 'AND(T,.)'");
                    END IF;
               ELSIF  CVAR = NB'(TRUE)  THEN
                    FAILED("TT ERROR: 'AND(F,.)'") ;
               END IF;

               CVAR  :=  A OR B ;
               IF  A = NB'(TRUE)  THEN
                    IF CVAR /= NB'( TRUE )
                    THEN  FAILED("TT ERROR: 'OR(T,.)'");
                    END IF;
               ELSIF  CVAR /= B  THEN  FAILED("TT ERROR: 'OR(F,.)'") ;
               END IF;

               CVAR  :=  A XOR B ;
               IF  A = NB'(TRUE)  THEN
                    IF  CVAR = B  THEN  FAILED("TT ERROR: 'XOR(T,.)'") ;
                    END IF;
               ELSIF  CVAR /= B  THEN  FAILED("TT ERROR: 'XOR(F,.)'") ;
               END IF;

          END LOOP SECOND;

     END LOOP FIRST;

     IF  FLOW_INDEX  /= 110  THEN  FAILED( "WRONG FLOW_INDEX" );
     END IF;

     RESULT;

END C45101K;
