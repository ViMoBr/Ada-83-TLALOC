-- C45211A.ADA

-- CHECK MEMBERSHIP TESTS FOR AN 'UNNATURAL' ORDERING OF CHARACTER
-- LITERALS.

-- RJW 1/22/86

WITH REPORT; USE REPORT;
PROCEDURE C45211A IS

     TYPE  T  IS  ( 'S' , 'Q' , 'P' , 'M' , 'R' );
     SUBTYPE ST IS T RANGE 'P' .. 'R';

     MVAR  : T := T'('M') ;
     QVAR  : T := T'('Q') ;
     MCON  : CONSTANT T := T'('M');
     QCON  : CONSTANT T := T'('Q');

BEGIN

     TEST( "C45211A" , "CHECK MEMBERSHIP TESTS FOR AN 'UNNATURAL' " &
                       "ORDERING OF CHARACTER LITERALS" ) ;

     IF QVAR IN T'('P') .. T'('R')  OR
        'Q'  IN ST
     THEN
          FAILED ( "MEMBERSHIP TEST FOR 'UNNATURAL' ORDERING - 1" );
     END IF;

     IF MVAR NOT IN T'('P') .. T'('R')  OR
        'M'  NOT IN ST
     THEN
          FAILED ( "MEMBERSHIP TEST FOR 'UNNATURAL' ORDERING - 2" );
     END IF;

     IF QCON IN T'('P') .. T'('R')  OR
        MCON NOT IN ST
     THEN
          FAILED ( "MEMBERSHIP TEST FOR 'UNNATURAL' ORDERING - 3" );
     END IF;

     RESULT;

END C45211A;
