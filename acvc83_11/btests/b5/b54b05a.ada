-- B54B05A.ADA


-- CHECK THAT IF THE CASE EXPRESSION IS  ' I + 0 ' , THE FULL RANGE
--    OF INTEGER VALUES MUST BE COVERED IF  I  IS OF AN INTEGER TYPE
--    OR OF AN INTEGER SUBTYPE.


-- RM 01/30/80
-- SPS 2/8/83

PROCEDURE  B54B05A  IS
BEGIN                                                       

     DECLARE
          
          SUBTYPE  INT   IS  INTEGER RANGE 1..50 ;
          I   :  INTEGER              := 2 ;
          J   :  INT                  := 2 ;
          K   :  INTEGER RANGE 1..50  := 2 ;
          L   :  INT     RANGE 2..2   := 2 ;

     BEGIN

          CASE  I+0  IS
               WHEN  3 | 5  =>  NULL ;
               WHEN  2 | 4  =>  NULL ;
               WHEN  INTEGER'FIRST..0 | 6..INTEGER'LAST  =>  NULL ;
          END CASE;  -- ERROR: MISSING 'OTHERS' 1

          CASE  J+0  IS
               WHEN  3 | 5  =>  NULL ;
               WHEN  2 | 4  =>  NULL ;
               WHEN  INTEGER'FIRST..1 |
                     6..50 | 52..INTEGER'LAST  =>  NULL ;
          END CASE;  -- ERROR: MISSING 'OTHERS' 2

          CASE  J+0  IS
               WHEN  1..50      =>  NULL ;
          END CASE;  -- ERROR: MISSING 'OTHERS' 3

          CASE  K+0  IS
               WHEN  1..50      =>  NULL ;
          END CASE;  -- ERROR: MISSING 'OTHERS' 4

          CASE  L+0  IS
               WHEN  1..50      =>  NULL ;
          END CASE;  -- ERROR: MISSING 'OTHERS' 5

          CASE  K+0  IS
               WHEN  1 | 3 | 5  =>  NULL ;
               WHEN  2 | 4      =>  NULL ;
               WHEN  INTEGER'FIRST..0 | 7..INTEGER'LAST  =>  NULL ;
          END CASE;  -- ERROR: MISSING 'OTHERS' 6

     END ;


END B54B05A ;
