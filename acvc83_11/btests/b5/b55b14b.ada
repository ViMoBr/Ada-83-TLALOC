-- B55B14B.ADA

-- USING A  CASE_STATEMENT , CHECK THAT THE SUBTYPE BOUNDS ASSOCIATED
--    WITH A LOOP OF THE FORM
--               FOR  I  IN  ST  LOOP
--    OR
--               FOR  I  IN  A'RANGE  LOOP
--    ARE THE BOUNDS OF ST'BASE WHEN ST IS NON-STATIC AND
--    ARE THE BOUNDS OF THE INDEX BASE TYPE (NOT INDEX SUBTYPE) FOR
--    THE A'RANGE CASE.

-- RM 04/07/81
-- SPS 3/2/83
-- JBG 3/14/83

PROCEDURE  B55B14B  IS

     USE ASCII;

     TYPE  ENUMERATION  IS  ( A,B,C,D,MIDPOINT,E,F,G,H );
     SUBTYPE   ST_I  IS       INTEGER RANGE 1..5;
     TYPE  NEW_ST_I  IS   NEW INTEGER RANGE 1..5;
     SUBTYPE   ST_E  IS       ENUMERATION RANGE B..G;
     SUBTYPE   ST_B  IS       BOOLEAN RANGE FALSE..FALSE;
     SUBTYPE   ST_C  IS       CHARACTER RANGE 'A'..DEL;

     X : INTEGER := 5;
     SUBTYPE ST_DYNI IS ST_I RANGE 1..X;
     SUBTYPE ST_DYNI5 IS ST_DYNI RANGE 1..5;

BEGIN

          FOR  I  IN  ST_DYNI5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL;
                    WHEN  2 | 4      =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;

     -------------------------------------------------------------------
     ---------------------  FOR  I  IN  A'RANGE  LOOP  -----------------

     DECLARE

          TYPE  A1  IS  ARRAY( ST_I     )  OF  INTEGER;
          TYPE  A2  IS  ARRAY( NEW_ST_I )  OF  INTEGER;
          TYPE  A3  IS  ARRAY( ST_B     )  OF  INTEGER;
          TYPE  A4  IS  ARRAY( ST_C     )  OF  INTEGER;
          TYPE  A5  IS  ARRAY( ST_E     )  OF  INTEGER;

     BEGIN


          FOR  I  IN  A1'RANGE  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL;
                    WHEN  2 | 4      =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A2'RANGE  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL;
                    WHEN  2 | 4      =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A3'RANGE  LOOP

               CASE  I  IS
                    WHEN  FALSE  =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A4'RANGE  LOOP

               CASE  I  IS
                    WHEN  'A'..'U'  =>  NULL;
                    WHEN  'V'..DEL  =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A5'RANGE  LOOP

               CASE  I  IS
                    WHEN  B..D      =>  NULL;
                    WHEN  E..G      =>  NULL;
                    WHEN  MIDPOINT  =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


     END;


     -------------------------------------------------------------------
     -------------------  FOR  I  IN  A'RANGE(2)  LOOP  ----------------

     DECLARE

          TYPE  A1  IS  ARRAY( 1..2 , ST_I , BOOLEAN  )  OF  CHARACTER;
          TYPE  A2  IS  ARRAY( 1..2 , NEW_ST_I , 1..1 )  OF  CHARACTER;
          TYPE  A3  IS  ARRAY( 1..2 , ST_B , BOOLEAN  )  OF  CHARACTER;
          TYPE  A4  IS  ARRAY( ST_C , 1..2 , BOOLEAN  )  OF  CHARACTER;
          TYPE  A5  IS  ARRAY( ST_E ,        BOOLEAN  )  OF  CHARACTER;

     BEGIN


          FOR  I  IN  A1'RANGE(2)  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL;
                    WHEN  2 | 4      =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A2'RANGE(2)  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL;
                    WHEN  2 | 4      =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A3'RANGE(2)  LOOP

               CASE  I  IS
                    WHEN  FALSE  =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A4'RANGE  LOOP

               CASE  I  IS
                    WHEN  'A'..'U'  =>  NULL;
                    WHEN  'V'..DEL  =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


          FOR  I  IN  A5'RANGE(1)  LOOP

               CASE  I  IS
                    WHEN  B..D      =>  NULL;
                    WHEN  E..G      =>  NULL;
                    WHEN  MIDPOINT  =>  NULL;
               END CASE;      -- ERROR: MISSING OTHERS.

          END LOOP;


     END;


END B55B14B;
