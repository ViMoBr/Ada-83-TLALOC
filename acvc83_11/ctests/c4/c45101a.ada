-- C45101A.ADA


-- CHECK THE CORRECT OPERATION OF  'AND' , 'OR' , AND 'XOR' (INCLUDING
--    COMBINATIONS WITH  'NOT' ), WITH VARIABLES AS OPERANDS (THE CASE
--    OF ARITHMETIC EXPRESSIONS AS OPERANDS IS TREATED IN A COMPANION
--    TEST).

-- PART 1: CHECKING THE AXIOMS FOR  'AND' , 'OR'

--    RM    24 SEPT 1980   (PART OF C45101A)
--    RM    11 JAN  1982
-- JWC 7/8/85    RENAMED TO -AB


WITH  REPORT ;
PROCEDURE  C45101A  IS

     USE REPORT;

     CVAR : BOOLEAN := FALSE ;     -- INITIAL VALUE IRRELEVANT
     FLOW_INDEX : INTEGER := 0 ;   -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP ;

BEGIN


     TEST( "C45101A" , "CHECK THE AXIOMS FOR  'AND' , 'OR'" );


     ON_FIRST_VARIABLE :                             --    BUMP VALUES:
     FOR  A  IN  BOOLEAN  LOOP                       --   NEW: | CUMUL.:

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
          FOR  B  IN  BOOLEAN  LOOP

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
               FOR  C  IN  BOOLEAN  LOOP

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



     IF  FLOW_INDEX  /= 76  THEN  FAILED( "WRONG FLOW_INDEX" );
     END IF;


     RESULT;


END C45101A;
