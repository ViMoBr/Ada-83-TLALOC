-- B54B04A.ADA


-- CHECK THAT EVEN WHEN THE CONTEXT INDICATES THAT A CASE EXPRESSION
--    COVERS A SMALLER RANGE OF VALUES THAN PERMITTED BY ITS SUBTYPE,
--    AN  'OTHERS'  ALTERNATIVE IS REQUIRED IF THE SUBTYPE VALUE RANGE
--    (ASSUMED TO BE STATIC) IS NOT FULLY COVERED.

-- PART  I :  STATIC SUBRANGES OF STATIC RANGES


-- RM 01/29/80
-- SPS 2/2/83


PROCEDURE  B54B04A  IS
BEGIN                                                       

     -- THE TEST CASES APPEAR IN THE FOLLOWING ORDER:
     --
     --    I.  STATIC SUBRANGES OF STATIC RANGES
     --
     --         (A)    VARIABLES (INTEGER , BOOLEAN)
     --         (C)    QUALIFIED EXPRESSIONS
     --         (D)    CONVERSIONS
     --         (E)    PARENTHESIZED EXPRESSIONS OF THE ABOVE KINDS



     DECLARE   --  STATIC SUBRANGES OF STATIC RANGES
          
          SUBTYPE  STAT  IS  INTEGER RANGE 1..5 ;
          TYPE  ENUMERATION  IS  ( FIRST,SECOND,THIRD,FOURTH,FIFTH );
          I   : INTEGER RANGE 1..5   := 2 ;
          J   : STAT                 := 2 ;
          BOOL: BOOLEAN              := TRUE  ;
          CHAR: CHARACTER            := 'U' ;
          ENUM: ENUMERATION          := THIRD ;

     BEGIN

          CASE  I  IS

               WHEN  2  =>
                    CASE  I  IS
                         WHEN  1 | 3  =>  NULL ;
                         WHEN  2 | 4  =>  NULL ;
                    END CASE;  -- ERROR: MISSING 'OTHERS' I A

               WHEN OTHERS  =>
                    NULL ;

          END CASE;


          IF  BOOL  THEN

               CASE  BOOL  IS
                    WHEN  TRUE   =>  NULL ;
               END CASE;  -- ERROR: MISSING 'OTHERS' I A

          END IF;


          CASE  STAT'( 2 )  IS

               WHEN  2  =>
                    CASE  STAT'( 2 )  IS
                         WHEN  5 | 2..4  =>  NULL ;
                    END CASE;  -- ERROR: MISSING 'OTHERS' I C

               WHEN OTHERS  =>
                    NULL ;

          END CASE;


          CASE  STAT( J )  IS

               WHEN  2  =>
                    CASE  STAT( J )  IS
                         WHEN  5 | 2..3  =>  NULL ;
                         WHEN  1         =>  NULL ;
                    END CASE;  -- ERROR: MISSING 'OTHERS' I D

               WHEN OTHERS  =>
                    NULL ;

          END CASE;


     END ;     --  STATIC SUBRANGES OF STATIC RANGES



END B54B04A ;
