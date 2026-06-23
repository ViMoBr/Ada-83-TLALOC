-- A54B01A.ADA


-- CHECK THAT IF A CASE EXPRESSION IS A CONSTANT, VARIABLE,
--    TYPE CONVERSION, OR QUALIFIED EXPRESSION,
--    AND THE SUBTYPE OF THE
--    EXPRESSION IS STATIC, AN  'OTHERS'  CAN BE OMITTED IF ALL
--    VALUES IN THE SUBTYPE'S RANGE ARE COVERED.


-- RM 01/23/80
-- SPS 10/26/82
-- SPS 2/1/83

WITH REPORT ;
PROCEDURE  A54B01A  IS

     USE REPORT ;

BEGIN                                                       

     TEST("A54B01A" , "CHECK THAT IF" &
                      " THE SUBTYPE OF A CASE EXPRESSION IS STATIC," &
                      " AN  'OTHERS'  CAN BE OMITTED IF ALL" &
                      " VALUES IN THE SUBTYPE'S RANGE ARE COVERED" );

     -- THE TEST CASES APPEAR IN THE FOLLOWING ORDER:
     --
     --    I.   CONSTANTS
     --
     --    II.  STATIC SUBRANGES
     --
     --         (A)    VARIABLES (INTEGER , BOOLEAN)
     --         (B)    QUALIFIED EXPRESSIONS
     --         (C)    TYPE CONVERSIONS

     DECLARE  -- CONSTANTS
          T : CONSTANT BOOLEAN := TRUE;
          FIVE : CONSTANT INTEGER := IDENT_INT(5);
     BEGIN

          CASE  FIVE  IS
               WHEN  INTEGER'FIRST..4  =>  NULL ;
               WHEN  5                 =>  NULL ; 
               WHEN  6 .. INTEGER'LAST =>  NULL ; 
          END CASE;                                         
                                                            
          CASE  T  IS
               WHEN  TRUE              =>  NULL ;
               WHEN  FALSE             =>  NULL ;
          END CASE;

     END ;


     DECLARE   --  STATIC SUBRANGES
          
          SUBTYPE  STAT  IS  INTEGER RANGE 1..5 ;
          I   : INTEGER RANGE 1..5 ;
          J   : STAT ;
          BOOL: BOOLEAN := FALSE ;
          CHAR: CHARACTER := 'U' ;
          TYPE  ENUMERATION  IS  ( FIRST,SECOND,THIRD,FOURTH,FIFTH );
          ENUM: ENUMERATION := THIRD ;


     BEGIN

          I  :=  IDENT_INT( 2 );
          J  :=  IDENT_INT( 2 );

          CASE  I  IS
               WHEN  1 | 3 | 5  =>  NULL ;
               WHEN  2 | 4      =>  NULL ;
          END CASE;

          CASE  BOOL  IS
               WHEN  TRUE   =>  NULL ;
               WHEN  FALSE  =>  NULL ;
          END CASE;

          CASE  STAT'( 2 )  IS
               WHEN  5 | 2..4  =>  NULL ;
               WHEN  1         =>  NULL ;
          END CASE;

          CASE  STAT( J )  IS
               WHEN  5 | 2..4  =>  NULL ;
               WHEN  1         =>  NULL ;
          END CASE;


     END ;     --  STATIC SUBRANGES

     RESULT ;


END A54B01A ;
