-- B55B12B.ADA


-- CHECK THAT THE SUBTYPE OF A LOOP PARAMETER IN A LOOP OF THE FORM
--
--                    FOR  I  IN  ST RANGE L..R  LOOP
--
--    IS CORRECTLY DETERMINED SO THAT WHEN THE LOOP PARAMETER IS USED
--    IN A CASE STATEMENT,  AN 'OTHERS' ALTERNATIVE IS REQUIRED IF
--    ST IS A NON-STATIC SUBTYPE, L AND R ARE STATIC, AND THE
--    ALTERNATIVES DO NOT COVER THE RANGE OF ST'BASE.


-- RM 02/02/80
-- JBG 03/25/82
-- JRK 03/02/83

PROCEDURE  B55B12B  IS

BEGIN

     DECLARE

          C50 : INTEGER := 50;
          SUBTYPE   DYN    IS  INTEGER RANGE 1..C50;
          TYPE  NEW_DYN    IS  NEW  INTEGER RANGE  1..C50;

          TYPE  ENUMERATION  IS  ( A,B,C,D,E,F,G,H,K,L,M,N );
          CM : ENUMERATION := M;
          SUBTYPE   DYN_E  IS
               ENUMERATION RANGE A..CM;
          CTRUE : BOOLEAN := TRUE;
          SUBTYPE   DYN_B  IS  BOOLEAN RANGE FALSE..CTRUE;
          C_L : CHARACTER := 'L';
          SUBTYPE   DYN_C  IS  CHARACTER RANGE 'A'..C_L;

     BEGIN

          FOR  I  IN  DYN  RANGE  1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;           -- ERROR: NON-STATIC SUBTYPE.

          END LOOP;

          FOR  I  IN  NEW_DYN  RANGE  1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;           -- ERROR: NON-STATIC SUBTYPE.

          END LOOP;

          FOR  I  IN  REVERSE  DYN RANGE 1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;           -- ERROR: NON-STATIC SUBTYPE.

          END LOOP;


          FOR  I  IN  DYN_E  RANGE  A..E  LOOP

               CASE  I  IS
                    WHEN  C..E  =>  NULL ;
                    WHEN  A..B  =>  NULL ;
               END CASE;           -- ERROR: NON-STATIC SUBTYPE.

          END LOOP;


          FOR  I  IN  DYN_B  RANGE TRUE..TRUE  LOOP

               CASE  I  IS
                    WHEN  TRUE  =>  NULL ;
               END CASE;           -- ERROR: NON-STATIC SUBTYPE.

          END LOOP;


          FOR  I  IN  DYN_C  RANGE 'A'..'E'  LOOP

               CASE  I  IS
                    WHEN  'A'..'C'  =>  NULL ;
                    WHEN  'D'..'E'  =>  NULL ;
               END CASE;           -- ERROR: NON-STATIC SUBTYPE.

          END LOOP;


          FOR  I  IN  DYN_C  RANGE 'E'..'B'  LOOP

               CASE  I  IS
                    WHEN  'D'..'C'  =>  NULL ;
                    WHEN  'E'..'B'  =>  NULL ;
                    WHEN  'F'..'A'  =>  NULL ;
               END CASE;           -- ERROR: NON-STATIC SUBTYPE.

          END LOOP;


     END ;

END B55B12B ;
