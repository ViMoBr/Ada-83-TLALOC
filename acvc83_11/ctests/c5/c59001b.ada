-- C59001B.ADA


-- CHECK THAT A STATEMENT WITH MULTIPLE LABELS CAN BE A TARGET FOR A
--    GOTO STATEMENT WHENEVER AN IDENTICAL SIMPLY-LABELED STATEMENT CAN,
--    AND THAT ANY ONE OF ITS LABELS MAY BE USED FOR THIS PURPOSE.


-- FLOW OF CONTROL:   A - B - C - D - E - F - G - H

--          A : GOTO B      LABELS: L111-112-113
--          FAILURE                 L121-122-123
--          E : GOTO F              L131-132-133

--          FAILURE                    L100

--          C : GOTO D      LABELS: L211-212-213
--          FAILURE                 L221-222-223
--          G : GOTO H              L231-232-233

--          FAILURE                    L200

--          B : GOTO C      LABELS: L311-312-313
--          FAILURE                 L321-322-323
--          F : GOTO G              L331-332-333

--          FAILURE                    L300

--          D : GOTO E      LABELS: L411-412-413
--          FAILURE                 L421-422-423
--          H :                     L431-432-433

--          PRINT RESULTS


-- RM 05/22/81
-- SPS 3/8/83

WITH REPORT;
PROCEDURE  C59001B  IS

     USE  REPORT ;

BEGIN

     TEST( "C59001B" , "CHECK THAT MULTIPLY-LABELED STATEMENTS CAN BE" &
                       " TARGETS OF GOTO STATEMENTS" );


     DECLARE

          FLOW_STRING : STRING(1..8) := "XXXXXXXX" ;
          INDEX       : INTEGER      :=  1 ;

     BEGIN

          << L111 >>
          << L112 >>
          << L113 >>

          FLOW_STRING(INDEX) := 'A' ;
          INDEX              := INDEX + 1 ;
          GOTO  L311 ;

          << L121 >>
          << L122 >>
          << L123 >>

          FAILED( "AT L12X  -  WRONGLY" );

          << L131 >>
          << L132 >>
          << L133 >>

          FLOW_STRING(INDEX) := 'E' ;
          INDEX              := INDEX + 1 ;
          GOTO  L332 ;

          << L100 >>

          FAILED( "AT L100  -  WRONGLY" );

          << L211 >>
          << L212 >>
          << L213 >>

          FLOW_STRING(INDEX) := 'C' ;
          INDEX              := INDEX + 1 ;
          GOTO  L413 ;

          << L221 >>
          << L222 >>
          << L223 >>

          FAILED( "AT L22X  -  WRONGLY" );

          << L231 >>
          << L232 >>
          << L233 >>

          FLOW_STRING(INDEX) := 'G' ;
          INDEX              := INDEX + 1 ;
          GOTO  L431 ;

          << L200 >>

          FAILED( "AT L200  -  WRONGLY" );

          << L311 >>
          << L312 >>
          << L313 >>

          FLOW_STRING(INDEX) := 'B' ;
          INDEX              := INDEX + 1 ;
          GOTO  L212 ;

          << L321 >>
          << L322 >>
          << L323 >>

          FAILED( "AT L32X  -  WRONGLY" );

          << L331 >>
          << L332 >>
          << L333 >>

          FLOW_STRING(INDEX) := 'F' ;
          INDEX              := INDEX + 1 ;
          GOTO  L233 ;

          << L300 >>

          FAILED( "AT L300  -  WRONGLY" );

          << L411 >>
          << L412 >>
          << L413 >>

          FLOW_STRING(INDEX) := 'D' ;
          INDEX              := INDEX + 1 ;
          GOTO  L131 ;

          << L421 >>
          << L422 >>
          << L423 >>

          FAILED( "AT L42X  -  WRONGLY" );

          << L431 >>
          << L432 >>
          << L433 >>

          FLOW_STRING(INDEX) := 'H' ;


          IF  FLOW_STRING /= "ABCDEFGH"  THEN
               FAILED("WRONG FLOW OF CONTROL" );
          END IF;

     END ;


     RESULT ;


END C59001B;
