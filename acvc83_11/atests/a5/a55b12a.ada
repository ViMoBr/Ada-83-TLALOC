-- A55B12A.ADA


-- CHECK THAT THE SUBTYPE OF A LOOP PARAMETER IN A LOOP OF THE FORM
--
--                    FOR  I  IN  ST RANGE L..R  LOOP
--
--    IS CORRECTLY DETERMINED SO THAT WHEN THE LOOP PARAMETER IS USED
--    IN A CASE STATEMENT  AN 'OTHERS' ALTERNATIVE IS NOT REQUIRED IF
--    THE CHOICES COVER THE APPROPRIATE RANGE OF SUBTYPE VALUES.

-- CASE  A :
--    L  AND  R  ARE BOTH STATIC EXPRESSIONS, AND  ST  IS A STATIC
--    SUBTYPE COVERING A RANGE GREATER THAN  L..R .


-- RM 02/02/80
-- JRK 03/02/83

WITH REPORT ;
PROCEDURE  A55B12A  IS

     USE REPORT ;

BEGIN

     TEST("A55B12A" , "CHECK THAT THE SUBTYPE OF A LOOP PARAMETER" &
                      " IN A LOOP OF THE FORM  'FOR  I  IN  ST RANGE" &
                      " L..R  LOOP'  IS CORRECTLY DETERMINED  (A)" );

     DECLARE

          SUBTYPE   STAT  IS       INTEGER RANGE 1..10 ;
          TYPE  NEW_STAT  IS  NEW  INTEGER RANGE 1..10 ;

          TYPE  ENUMERATION  IS  ( A,B,C,D,E,F,G,H,K,L,M,N );
          SUBTYPE   STAT_E  IS     ENUMERATION RANGE A..L ;
          SUBTYPE   STAT_B  IS     BOOLEAN RANGE FALSE..TRUE ;
          SUBTYPE   STAT_C  IS     CHARACTER RANGE 'A'..'L' ;

     BEGIN

          FOR  I  IN  STAT  RANGE  1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;

          END LOOP;

          FOR  I  IN  NEW_STAT  RANGE  1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;

          END LOOP;

          FOR  I  IN  INTEGER  RANGE  1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  REVERSE  STAT RANGE 1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  STAT_E  RANGE  A..E  LOOP

               CASE  I  IS
                    WHEN  C..E  =>  NULL ;
                    WHEN  A..B  =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  STAT_B  RANGE TRUE..TRUE  LOOP

               CASE  I  IS
                    WHEN  TRUE  =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  STAT_C  RANGE 'A'..'E'  LOOP

               CASE  I  IS
                    WHEN  'A'..'C'  =>  NULL ;
                    WHEN  'D'..'E'  =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  STAT_C  RANGE 'E'..'B'  LOOP

               CASE  I  IS
                    WHEN  'D'..'C'  =>  NULL ;
                    WHEN  'E'..'B'  =>  NULL ;
                    WHEN  'F'..'A'  =>  NULL ;
                    WHEN  'M'..'A'  =>  NULL ;
               END CASE;

          END LOOP;


     END ;

     RESULT ;

END A55B12A ;
