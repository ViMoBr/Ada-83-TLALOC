-- C45220E.ADA


-- CHECK THE PROPER OPERATION OF THE MEMBERSHIP OPERATORS  'IN'  AND
--    'NOT IN'  FOR BOOLEAN TYPES.


-- RM 03/20/81
-- SPS 10/26/82


WITH REPORT;
PROCEDURE  C45220E  IS

     USE  REPORT ;

BEGIN

     TEST( "C45220E" , "CHECK THE PROPER OPERATION OF THE MEMBERSHIP" &
                       " OPERATORS  'IN'  AND  'NOT IN'  FOR" &
                       " BOOLEAN TYPES" );

     DECLARE

          SUBTYPE  SUBBOOL   IS  BOOLEAN RANGE FALSE..TRUE ;

          VAR  :            BOOLEAN  :=  FALSE ;
          CON  :   CONSTANT BOOLEAN  :=  FALSE ;

     BEGIN

          IF   TRUE NOT IN SUBBOOL  OR
               VAR  NOT IN SUBBOOL  OR
               CON  NOT IN SUBBOOL
          THEN
               FAILED( "WRONG VALUES FOR 'IN SUBBOOL'" );
          END IF;

          IF   FALSE   IN TRUE..FALSE  OR
               VAR NOT IN FALSE..TRUE  OR
               CON     IN TRUE..TRUE
          THEN
               FAILED( "WRONG VALUES FOR 'IN AAA..BBB'" );
          END IF;


          RESULT ;


     END ;


END C45220E ;
