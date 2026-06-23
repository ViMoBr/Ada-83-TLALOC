-- A32203C.ADA


-- CHECK THAT THE FOLLOWING ATTRIBUTES CAN APPEAR IN A NUMBER
--    DECLARATION:
--
--          'LARGE                'MANTISSA                'DELTA
--          'SMALL                'FORE                    'AFT
--          'SAFE_SMALL           'SAFE_LARGE              'SIZE
--
-- (ATTRIBUTES FOR FIXED-POINT).


-- RM 03/06/81
-- VKG 1/5/83


WITH REPORT;
PROCEDURE  A32203C  IS

     USE  REPORT ;

BEGIN

     TEST( "A32203C" , "TEST THAT FIXED-POINT ATTRIBUTES CAN APPEAR" &
                       " IN A NUMBER DECLARATION" );

     -------------------------------------------------------------------
     --------------------  ATTRIBUTES ON THE LIST  ---------------------

     DECLARE

          TYPE  FX333  IS  DELTA 0.01  RANGE 0.0 .. 9.9 ;
          TYPE  FX999  IS  NEW FX333   RANGE 1.0 .. 2.0 ;

          A01         :  CONSTANT  :=  FX333'LARGE ;
          A02         :  CONSTANT  :=  FX999'MANTISSA  ;
          A03         :  CONSTANT  :=  FX333'DELTA ;
          A04         :  CONSTANT  :=  FX999'SMALL ;
          A05         :  CONSTANT  :=  FX333'AFT ;
          A06         :  CONSTANT  :=  FX999'FORE ;
          A07         :  CONSTANT  :=  FX333'SAFE_SMALL ;
          A08         :  CONSTANT  :=  FX999'SAFE_LARGE ;
          A09         :  CONSTANT  :=  FX333'SIZE ;

     BEGIN

          NULL ;

     END ;


     RESULT ;


END A32203C ;
