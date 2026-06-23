-- A32203D.ADA


-- CHECK THAT THE FOLLOWING  SYSTEM  CONSTANTS CAN APPEAR IN A NUMBER
--    DECLARATION:
--
--           STORAGE_UNIT     MEMORY_SIZE        MIN_INT
--           MAX_DIGITS       MAX_MANTISSA       FINE_DELTA
--           TICK             MAX_INT .

-- RM 03/06/81
-- SPS 2/4/83

WITH SYSTEM;
WITH REPORT;
PROCEDURE  A32203D  IS

     USE  REPORT ;

BEGIN

     TEST( "A32203D" , "TEST THAT SYSTEM CONSTANTS CAN APPEAR" &
                       " IN A NUMBER DECLARATION" );

     -------------------------------------------------------------------
     ----------------  SYSTEM CONSTANTS ON THE LIST  -------------------

     DECLARE

          A01         :  CONSTANT  :=  SYSTEM.STORAGE_UNIT ;
          A02         :  CONSTANT  :=  SYSTEM.MEMORY_SIZE  ;
          A03         :  CONSTANT  :=  SYSTEM.MIN_INT ;
          A04         :  CONSTANT  :=  SYSTEM.MAX_INT ;
          A05         :  CONSTANT  :=  SYSTEM.MAX_DIGITS ;
          A06         :  CONSTANT  :=  SYSTEM.MAX_MANTISSA ;
          A07         :  CONSTANT  :=  SYSTEM.FINE_DELTA ;
          A08         :  CONSTANT  :=  SYSTEM.TICK ;

     BEGIN

          NULL ;

     END ;


     RESULT ;


END A32203D ;
