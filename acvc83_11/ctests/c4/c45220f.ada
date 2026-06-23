-- C45220F.ADA

-- CHECK THAT THE MEMBERSHIP OPERATIONS WORK CORRECTLY FOR DERIVED
-- BOOLEAN TYPES.

-- GLH 08/01/85

WITH REPORT;
PROCEDURE  C45220F  IS

     USE  REPORT ;

BEGIN

     TEST( "C45220F" , "CHECK MEMBERSHIP OPERATIONS FOR " &
                       "DERIVED BOOLEAN");

     DECLARE

          TYPE NEWBOOL IS NEW BOOLEAN;

          VAR  :          NEWBOOL  :=  FALSE ;
          CON  : CONSTANT NEWBOOL  :=  FALSE ;

     BEGIN

          IF   TRUE NOT IN NEWBOOL  OR
               VAR  NOT IN NEWBOOL  OR
               CON  NOT IN NEWBOOL
          THEN
               FAILED( "WRONG VALUES FOR 'IN NEWBOOL'" );
          END IF;

          IF  NEWBOOL'(FALSE)   IN TRUE..FALSE  OR
              VAR           NOT IN FALSE..TRUE  OR
              CON               IN TRUE..TRUE
          THEN
               FAILED( "WRONG VALUES FOR 'IN AAA..BBB'" );
          END IF;

          RESULT ;

     END ;

END C45220F ;
