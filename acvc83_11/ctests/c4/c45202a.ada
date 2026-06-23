-- C45202A.ADA


-- CHECK THE PROPER OPERATION OF THE MEMBERSHIP OPERATORS  'IN'  AND
--    'NOT IN'  (FOR USER-DEFINED ENUMERATION TYPES).


-- RM 03/19/81
-- SPS 10/26/82


WITH REPORT;
PROCEDURE  C45202A  IS

     USE  REPORT ;

BEGIN

     TEST( "C45202A" , "CHECK THE PROPER OPERATION OF THE MEMBERSHIP" &
                       " OPERATORS  'IN'  AND  'NOT IN'  (FOR" &
                       " USER-DEFINED ENUMERATION TYPES)" );

     DECLARE

          TYPE     ENUM      IS  ( AA , BB , CC , LIT , XX , YY , ZZ );
          SUBTYPE  SUBENUM   IS  ENUM RANGE AA..LIT ;

          VAR  :           ENUM  :=  LIT ;
          CON  :  CONSTANT ENUM  :=  LIT ;

     BEGIN

          IF   LIT NOT IN SUBENUM  OR
               VAR NOT IN SUBENUM  OR
               CON NOT IN SUBENUM
          THEN
               FAILED( "WRONG VALUES FOR 'IN SUBENUM'" );
          END IF;

          IF   LIT     IN AA ..CC  OR
               VAR NOT IN LIT..ZZ  OR
               CON     IN ZZ ..AA
          THEN
               FAILED( "WRONG VALUES FOR 'IN AAA..BBB'" );
          END IF;


          RESULT ;


     END ;


END C45202A ;
