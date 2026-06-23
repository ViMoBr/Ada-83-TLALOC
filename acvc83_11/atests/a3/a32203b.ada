-- A32203B.ADA


-- CHECK THAT THE FOLLOWING ATTRIBUTES CAN APPEAR IN A NUMBER
--    DECLARATION:
--
--          'SMALL                'LARGE                'DIGITS
--          'MANTISSA             'EMAX                 'EPSILON
--          'MACHINE_EMAX         'MACHINE_EMIN         'MACHINE_RADIX
--          'MACHINE_MANTISSA     'SAFE_EMAX            'SAFE_SMALL
--          'SAVE_LARGE
--
-- (ATTRIBUTES FOR FLOATING-POINT).


-- RM 03/06/81
-- SPS 2/4/83

WITH REPORT;
PROCEDURE  A32203B  IS

     USE  REPORT ;

BEGIN

     TEST( "A32203B" , "TEST THAT FLOATING-POINT ATTRIBUTES CAN APPEAR"&
                       " IN A NUMBER DECLARATION" );

     -------------------------------------------------------------------
     --------------------  ATTRIBUTES ON THE LIST  ---------------------

     DECLARE

          TYPE  FL333  IS  DIGITS 5 ;
          TYPE  FL999  IS  NEW FL333 RANGE 0.0 .. 1000.0 ;

          A01         :  CONSTANT  :=  FLOAT'SMALL ;
          A02         :  CONSTANT  :=  FL333'LARGE ;
          A03         :  CONSTANT  :=  FLOAT'DIGITS ;
          A04         :  CONSTANT  :=  FL999'MANTISSA ;
          A05         :  CONSTANT  :=  FLOAT'EMAX ;
          A06         :  CONSTANT  :=  FL333'EPSILON ;
          A07         :  CONSTANT  :=  FLOAT'MACHINE_EMAX ;
          A08         :  CONSTANT  :=  FL999'MACHINE_EMIN ;
          A09         :  CONSTANT  :=  FLOAT'MACHINE_RADIX ;
          A10         :  CONSTANT  :=  FL333'MACHINE_MANTISSA ;
          A11         :  CONSTANT  :=  FLOAT'SAFE_EMAX ;
          A12         :  CONSTANT  :=  FLOAT'SAFE_SMALL ;
          A13         :  CONSTANT  :=  FL333'SAFE_LARGE ;

     BEGIN
          NULL ;
     END ;

     RESULT ;

END A32203B ;
