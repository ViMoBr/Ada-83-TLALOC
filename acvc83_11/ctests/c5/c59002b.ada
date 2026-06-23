-- C59002B.ADA


-- CHECK THAT JUMPS OUT OF COMPOUND STATEMENTS (OTHER THAN
--    ACCEPT STATEMENTS) ARE POSSIBLE AND ARE CORRECTLY PERFORMED.


-- FLOW OF CONTROL:   A ->  B ->  C ->  D ->   E ->  F ->  G ->  H .
--                    |     |     |     |      |     |     |
--                    IF   LOOP   CASE  BLOCK  IF   LOOP   CASE
--                                             LOOP CASE   BLOCK


--          A : GOTO B              L111 -> L311
--          FAILURE                 L121
--          E : GOTO F              L131 -> L331

--          FAILURE                 L100

--          C : GOTO D              L211 -> L411
--          FAILURE                 L221
--          G : GOTO H              L231

--          FAILURE                 L200

--          B : GOTO C              L311 -> L211
--          FAILURE                 L321
--          F : GOTO G              L331

--          FAILURE                 L300

--          D : GOTO E              L411 -> L131
--          FAILURE                 L421
--          H :                     L431 -> (OUT)

--          PRINT RESULTS


-- RM 06/05/81
-- SPS 3/8/83

WITH REPORT;
PROCEDURE  C59002B  IS

     USE  REPORT ;

BEGIN

     TEST( "C59002B" , "CHECK THAT ONE CAN JUMP OUT OF COMPOUND STATE" &
                       "MENTS" );


     DECLARE

          FLOW_STRING : STRING(1..8) := "XXXXXXXX" ;
          INDEX       : INTEGER      :=  1 ;

     BEGIN

          << L111 >>

          FLOW_STRING(INDEX) := 'A' ;
          INDEX              := INDEX + 1 ;

          IF  FALSE  THEN
               FAILED( "WRONG 'IF' BRANCH" );
          ELSE
               GOTO  L311 ;
          END IF;

          << L121 >>

          FAILED( "AT L121  -  WRONGLY" );

          << L131 >>

          FLOW_STRING(INDEX) := 'E' ;
          INDEX              := INDEX + 1 ;

          IF  FALSE  THEN
               FAILED( "WRONG 'IF' BRANCH" );
          ELSE
               FOR  J  IN  1..1  LOOP
                    GOTO  L331 ;
               END LOOP;
          END IF;

          << L100 >>

          FAILED( "AT L100  -  WRONGLY" );

          << L211 >>

          FLOW_STRING(INDEX) := 'C' ;
          INDEX              := INDEX + 1 ;

          CASE  2  IS
               WHEN  1  =>
                    FAILED( "WRONG 'CASE' BRANCH" );
               WHEN  OTHERS  =>
                    GOTO  L411 ;
          END CASE;

          << L221 >>

          FAILED( "AT L221  -  WRONGLY" );

          << L231 >>

          FLOW_STRING(INDEX) := 'G' ;
          INDEX              := INDEX + 1 ;

          CASE  2  IS
               WHEN  1  =>
                    FAILED( "WRONG 'CASE' BRANCH" );
               WHEN  OTHERS  =>
                    DECLARE
                    BEGIN
                         GOTO  L431 ;
                    END ;
          END CASE;

          << L200 >>

          FAILED( "AT L200  -  WRONGLY" );

          << L311 >>

          FLOW_STRING(INDEX) := 'B' ;
          INDEX              := INDEX + 1 ;

          FOR  I  IN  1..1  LOOP
               GOTO  L211 ;
          END LOOP;

          << L321 >>

          FAILED( "AT L321  -  WRONGLY" );

          << L331 >>

          FLOW_STRING(INDEX) := 'F' ;
          INDEX              := INDEX + 1 ;

          FOR  I  IN  1..1  LOOP
               CASE  2  IS
                    WHEN  1  =>
                         FAILED( "WRONG 'CASE' BRANCH" );
                    WHEN  OTHERS  =>
                         GOTO  L231 ;
               END CASE;
          END LOOP;

          << L300 >>

          FAILED( "AT L300  -  WRONGLY" );

          << L411 >>

          FLOW_STRING(INDEX) := 'D' ;
          INDEX              := INDEX + 1 ;

          DECLARE
               K : INTEGER := 17 ;
          BEGIN
               GOTO  L131 ;
          END;

          << L421 >>

          FAILED( "AT L421  -  WRONGLY" );

          << L431 >>

          FLOW_STRING(INDEX) := 'H' ;


          IF  FLOW_STRING /= "ABCDEFGH"  THEN
               FAILED("WRONG FLOW OF CONTROL" );
          END IF;

     END ;


     RESULT ;


END C59002B;
