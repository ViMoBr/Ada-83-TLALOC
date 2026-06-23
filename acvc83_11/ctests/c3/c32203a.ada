-- C32203A.ADA

-- CHECK THAT THE FOLLOWING ATTRIBUTES CAN APPEAR IN A NUMBER
--    DECLARATION:
--
--          'SIZE FOR SCALAR STATIC SUBTYPES
--          'POS FOR SCALAR STATIC SUBTYPES.

-- RM 03/06/81
-- SPS 2/4/83


WITH REPORT;
PROCEDURE  C32203A  IS

     USE  REPORT ;

BEGIN

     TEST( "C32203A" , "TEST THAT 'SIZE AND 'POS FOR SCALAR STATIC" &
                       " SUBTYPES CAN APPEAR IN A NUMBER DECLARATION" );

     -------------------------------------------------------------------
     --------------------  ATTRIBUTES ON THE LIST  ---------------------

     DECLARE

          SUBTYPE I IS INTEGER RANGE 1 .. 5;
          TYPE INT IS NEW INTEGER RANGE 1 .. 5;

          A1 : CONSTANT := INT'POS (3);
          A2 : CONSTANT := INT'SIZE;
          A3 : CONSTANT := I'SIZE;

     BEGIN
          IF A1 /= 3 THEN
               FAILED ("WRONG 'POS VALUE");
          END IF;

          IF A2 /= A3 THEN
               FAILED ("SIZE VALUES INCORRECT");
          END IF;
     END ;

     RESULT ;

END  C32203A ;
