-- C45122A.ADA


-- CHECK THAT THE EVALUATION OF  'AND THEN'  AND  'OR ELSE'  IS INDEED
--    SHORT-CIRCUITED FOR THE APPROPRIATE VALUES OF THE FIRST
--    OPERAND.

-- (PART1: SIMPLE CASES;   PART2: CHAINS;   PART3: COMBINATIONS)

-- PART 1 :   SIMPLE CASES



-- RM   1 OCTOBER 1980
-- RM   6 JANUARY 1982
-- JWC 9/30/85    RENAMED FROM C45103A-AB.ADA

WITH  REPORT ;
PROCEDURE  C45122A  IS

     USE REPORT;

     A          : INTEGER := 0 ;   -- INITIAL VALUE ESSENTIAL
     B , C , D  : INTEGER := 3 ;   -- MUST HAVE A VALUE
     FLOW_INDEX : INTEGER := 0 ;

     TYPE  R  IS
          RECORD
               F: INTEGER ;
          END RECORD;

     TYPE  A_R  IS  ACCESS  R ;

     P          : A_R  :=  NULL ;

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX  :=  FLOW_INDEX + 1 ;
     END BUMP ;

     FUNCTION  SIDE_EFFECT_GT( X , Y : INTEGER )  RETURN  BOOLEAN  IS
     BEGIN
          BUMP ;
          RETURN ( X > Y ) ;
     END SIDE_EFFECT_GT ;

BEGIN

     TEST( "C45122A" , "CHECK THE SHORT-CIRCUIT OPERATORS" ) ;

     -- (PART1: SIMPLE CASES;   PART2: CHAINS;   PART3: COMBINATIONS)

     -- PART 1 :   SIMPLE CASES

     COMMENT( "STARTING THE CASE  'ANDTHEN-ZERODIV' " );
     FLOW_INDEX := 0 ;
     BEGIN

          IF  A /= 0  AND THEN  B/A > C  THEN
               FAILED( "'ANDTHEN-ZERODIV' CONDITION ASSUMED TRUE" );
          ELSE
               BUMP ;
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>
               BUMP ;
               BUMP ;
               FAILED( "EXCEPTION RAISED " &
                       "('ANDTHEN' NOT SHORT-CIRCUITED?)" );

     END ;

     COMMENT( "STARTING THE CASE  'ORELSE-ZERODIV' " );
     FLOW_INDEX := 0 ;
     BEGIN

          IF  A = 0  OR ELSE  B/A > C  THEN
               BUMP ;
          ELSE
               FAILED( "'ORELSE-ZERODIV' CONDITION ASSUMED FALSE" );
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>
               BUMP ;
               BUMP ;
               FAILED( "EXCEPTION RAISED " &
                       "('ORELSE' NOT SHORT-CIRCUITED?)" );

     END ;

     COMMENT( "STARTING THE CASE  'ANDTHEN-DEREFNULL' " );
     FLOW_INDEX := 0 ;
     BEGIN

          IF  P /= NULL  AND THEN  P.F = D  THEN
               FAILED( "'ANDTHEN-DEREFNULL' CONDITION ASSUMED TRUE" );
          ELSE
               BUMP ;
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>
               BUMP ;
               BUMP ;
               FAILED( "EXCEPTION RAISED " &
                       "('ANDTHEN' NOT SHORT-CIRCUITED?)" );

     END ;

     COMMENT( "STARTING THE CASE  'ORELSE-DEREFNULL' " );
     FLOW_INDEX := 0 ;
     BEGIN

          IF  P = NULL  OR ELSE  P.F = D  THEN
               BUMP ;
          ELSE
               FAILED( "'ORELSE-DEREFNULL' CONDITION ASSUMED FALSE" );
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>
               BUMP ;
               BUMP ;
               FAILED( "EXCEPTION RAISED " &
                       "('ORELSE' NOT SHORT-CIRCUITED?)" );

     END ;

     COMMENT( "STARTING THE CASE  'NOT(ANDTHEN-ZERODIV)' " );
     FLOW_INDEX := 0 ;
     BEGIN

          IF  NOT( A /= 0  AND THEN  B/A > C )  THEN
               BUMP ;
          ELSE
               FAILED( "'NOT(ANDTHEN-ZERODIV)' COND'N ASSUMED FALSE" );
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>
               BUMP ;
               BUMP ;
               FAILED( "EXCEPTION RAISED " &
                       "('NOTANDTHEN' NOT SHORT-CIRCUITED?)");

     END ;

     COMMENT( "STARTING THE CASE  'NOT(ORELSE-ZERODIV)' " );
     FLOW_INDEX := 0 ;
     BEGIN

          IF  NOT( A = 0  OR ELSE  B/A > C )  THEN
               FAILED( "'NOT(ORELSE-ZERODIV)' CONDITION ASSUMED TRUE" );
          ELSE
               BUMP ;
          END IF;

     EXCEPTION

          WHEN  OTHERS  =>
               BUMP ;
               BUMP ;
               FAILED( "EXCEPTION RAISED " &
                       "('NOTORELSE' NOT SHORT-CIRCUITED?)" );

     END ;


     RESULT;

END C45122A;
