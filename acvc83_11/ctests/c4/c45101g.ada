-- C45101G.ADA


-- CHECK THE CORRECT OPERATION OF  'AND' , 'OR' , AND 'XOR' (INCLUDING
--    COMBINATIONS WITH 'NOT' ), WITH ARITHMETIC EXPRESSIONS AS OPERANDS
--    (THE CASE OF VARIABLES AS OPERNDS IS TREATED IN A COMPANION TEST).

-- PART 1: CHECKING THE AXIOMS FOR  'AND' , 'OR'


-- RM    6 OCTOBER 1980     (PART OF C45101C)
-- RM   11 JANUARY 1982
-- JBG 8/21/83

WITH  REPORT ;
PROCEDURE  C45101G  IS

     USE REPORT;

     FLOW_INDEX : INTEGER := 0 ;   -- INITIAL VALUE ESSENTIAL

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP ;

BEGIN


     TEST( "C45101G" , "CHECK THE AXIOMS FOR  'AND' , 'OR'" );

     -- PART 1: CHECKING THE AXIOMS FOR  'AND' , 'OR'

     ON_FIRST_VARIABLE :                          --    BUMP VALUES:
     FOR  I  IN  0..1  LOOP                       --   NEW: | CUMUL.:

          IF  ( (I>0) OR (I>0) ) = 
              (I>0)  THEN
               BUMP ;                                --     2      2
          ELSE
               FAILED( "'OR' NOT IDEMPOTENT" );
          END IF;

          IF  ( (I>0) AND (I>0) ) = 
              (I>0)  THEN
               BUMP ;                                --     2      4
          ELSE
               FAILED( "'AND' NOT IDEMPOTENT" );
          END IF;

          ON_SECOND_VARIABLE :
          FOR  J  IN  1..2  LOOP

               IF  ( (I>0) OR (J>1) ) = 
                   ( (J>1) OR (I>0) )  THEN
                    BUMP ;                           --     4      8
               ELSE
                    FAILED( "'OR' NOT COMMUTATIVE" );
               END IF;

               IF  ( (I>0) AND (J>1) ) = 
                   ( (J>1) AND (I>0) )  THEN
                    BUMP ;                           --     4     12
               ELSE
                    FAILED( "'AND' NOT COMMUTATIVE" );
               END IF;

               IF  ( (I>0) AND ( (I>0) OR (J>1) )) = 
                   (I>0)  THEN
                    BUMP ;                           --     4     16
               ELSE
                    FAILED( "'AND-OR' ABSORPTION" );
               END IF;

               IF  ( (I>0) OR ( (I>0) AND (J>1) )) = 
                   (I>0)  THEN
                    BUMP ;                           --     4     20
               ELSE
                    FAILED( "'OR-AND' ABSORPTION" );
               END IF;

               IF  ( NOT( (I>0) OR (J>1) )) = 
                   (( NOT (I>0) ) AND ( NOT (J>1) ))  THEN
                    BUMP ;                           --     4     24
               ELSE
                    FAILED( "'NOT-OR'  DE MORGAN" );
               END IF;

               IF  ( NOT( (I>0) AND (J>1) )) = 
                   (( NOT (I>0) ) OR ( NOT (J>1) ))  THEN
                    BUMP ;                           --     4     28
               ELSE
                    FAILED( "'NOT-AND'  DE MORGAN" );
               END IF;

               ON_THIRD_VARIABLE :
               FOR  K  IN  REVERSE INTEGER RANGE -1..0  LOOP

                    IF  ( (I>0) AND ( (J>1) AND (K<0) )) = 
                        (( (I>0) AND (J>1) ) AND (K<0) ) THEN
                         BUMP ;                      --     8     36
                    ELSE
                         FAILED( "'AND' NOT ASSOCIATIVE" );
                    END IF;

                    IF  ( (I>0) OR ( (J>1) OR (K<0) )) = 
                        (( (I>0) OR (J>1) ) OR (K<0) )  THEN
                         BUMP ;                      --     8     44
                    ELSE
                         FAILED( "'OR' NOT ASSOCIATIVE" );
                    END IF;

                    IF  ( (I>0) AND (J>1) AND (K<0) ) = 
                        (( (I>0) AND (J>1) ) AND (K<0) )  THEN
                         BUMP ;                      --     8     52
                    ELSE
                         FAILED( "'AND'-CHAINS INCORRECT" );
                    END IF;

                    IF  ( (I>0) OR (J>1) OR (K<0) ) = 
                        (( (I>0) OR (J>1) ) OR (K<0) )  THEN
                         BUMP ;                      --     8     60
                    ELSE
                         FAILED( "'OR'-CHAINS INCORRECT" );
                    END IF;

                    IF  ( (I>0) AND ( (J>1) OR (K<0) )) = 
                        (( (I>0) AND (J>1) )OR( (I>0) AND (K<0) ))
                    THEN
                         BUMP ;                      --     8     68
                    ELSE
                         FAILED( "'AND' DOES NOT DISTRIBUTE OVER 'OR'");
                    END IF;

                    IF  ( (I>0) OR ( (J>1) AND (K<0) )) = 
                        (( (I>0) OR (J>1) )AND( (I>0) OR (K<0) ))
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


END C45101G;
