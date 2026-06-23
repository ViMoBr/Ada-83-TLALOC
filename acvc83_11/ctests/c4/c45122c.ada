-- C45122C.ADA


-- CHECK THAT THE EVALUATION OF  'AND THEN'  AND  'OR ELSE'  IS INDEED
--    SHORT-CIRCUITED FOR THE APPROPRIATE VALUES OF THE FIRST
--    OPERAND.

-- (PART1: SIMPLE CASES;   PART2: CHAINS;   PART3: COMBINATIONS)

-- PART 3 :   COMBINATIONS


-- RM   1 OCTOBER 1980
-- JWC 9/30/85   RENAMED FROM C45103C-AB.ADA


WITH  REPORT ;
PROCEDURE  C45122C  IS

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

     TEST( "C45122C" , "CHECK THE SHORT-CIRCUIT OPERATORS" ) ;

     -- (PART1: SIMPLE CASES;   PART2: CHAINS;   PART3: COMBINATIONS)

     -- PART 3 :   COMBINATIONS

     COMMENT( "STARTING THE CASE  'COMBINATIONS' " );
     FLOW_INDEX := 0 ;

     IF  NOT( SIDE_EFFECT_GT( A , B )  AND THEN
              SIDE_EFFECT_GT( C , A )           )  AND
            ( SIDE_EFFECT_GT( A , C )  AND THEN
              SIDE_EFFECT_GT( B , A )           )
     THEN
          FAILED( "'S.C. AND S.C.'  -  WRONG" );
     END IF;

     IF     ( SIDE_EFFECT_GT( A , D )  AND THEN
              SIDE_EFFECT_GT( B , A )           )  OR
         NOT( SIDE_EFFECT_GT( D , A )  OR ELSE
              SIDE_EFFECT_GT( A , C )           )
     THEN
          FAILED( "'S.C. OR S.C.'  -  WRONG" );
     END IF;

     IF  NOT(
            ( SIDE_EFFECT_GT( C , A )  OR ELSE
              SIDE_EFFECT_GT( A , B )           )  XOR
         NOT( SIDE_EFFECT_GT( D , A )  OR ELSE
              SIDE_EFFECT_GT( A , C )           )       )
     THEN
          FAILED( "'S.C. XOR S.C.'  -  WRONG" );
     END IF;

     IF  FLOW_INDEX /= 6  THEN
          FAILED( "COMBINATIONS - WRONG # OF EVALUATIONS" );
     END IF;

     COMMENT( "STARTING THE CASE  'TRIPLE-DECKER' " );
     FLOW_INDEX := 0 ;

     IF  NOT( SIDE_EFFECT_GT( A , B )  AND THEN
              SIDE_EFFECT_GT( C , A )           )
     THEN
          IF     ( SIDE_EFFECT_GT( A , D )  AND THEN
                   SIDE_EFFECT_GT( B , A )           )
          THEN  NULL ;
          ELSE
               IF  NOT( SIDE_EFFECT_GT( C , A )  OR ELSE
                        SIDE_EFFECT_GT( A , B )           )
               THEN
                    FAILED( "'TRIPLE-DECKER'  -  WRONG RESULT" );
               END IF;
          END IF;
     END IF;

     IF  FLOW_INDEX /= 3  THEN
          FAILED( "'TRIPLE-DECKER' - WRONG # OF EVALUATIONS" );
     END IF;

     RESULT;

END C45122C;
