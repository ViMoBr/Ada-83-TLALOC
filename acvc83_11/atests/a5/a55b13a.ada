-- A55B13A.ADA


-- USING A  CASE_STATEMENT , CHECK THAT IF  L , R  ARE LITERALS
--    OF TYPE  T  (INTEGER, BOOLEAN, CHARACTER, USER-DEFINED
--    ENUMERATION TYPE)  THE SUBTYPE BOUNDS ASSOCIATED WITH A
--    LOOP OF THE FORM
--               FOR  I  IN  L..R  LOOP
--    ARE THE SAME AS THOSE FOR THE CORRESPONDING LOOP OF THE FORM
--               FOR  I  IN  T RANGE L..R  LOOP   .


-- RM 04/07/81
-- SPS 3/2/83
-- JBG 8/21/83

WITH REPORT ;
PROCEDURE  A55B13A  IS

     USE REPORT ;

BEGIN

     TEST("A55B13A" , "CHECK THAT THE SUBTYPE OF A LOOP PARAMETER"   &
                      " IN A LOOP OF THE FORM  'FOR  I  IN "         &
                      " LITERAL_L .. LITERAL_R  LOOP'  IS CORRECTLY" &
                      " DETERMINED" );

     DECLARE

          TYPE  ENUMERATION  IS  ( A,B,C,D,MIDPOINT,E,F,G,H );
          ONE   :  CONSTANT  :=  1 ;
          FIVE  :  CONSTANT  :=  5 ;


     BEGIN


          FOR  I  IN  1..5  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  REVERSE  ONE .. FIVE  LOOP

               CASE  I  IS
                    WHEN  1 | 3 | 5  =>  NULL ;
                    WHEN  2 | 4      =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  REVERSE FALSE..TRUE  LOOP

               CASE  I  IS
                    WHEN  FALSE  =>  NULL ;
                    WHEN  TRUE   =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  'A' .. ASCII.DEL  LOOP

               CASE  I  IS
                    WHEN  'A'..'U'  =>  NULL ;
                    WHEN  'V'..ASCII.DEL  =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  'A'..'H'  LOOP

               CASE  I  IS
                    WHEN  'A'..'D'  =>  NULL ;
                    WHEN  'E'..'H'  =>  NULL ;
               END CASE;

          END LOOP;


          FOR  I  IN  REVERSE B..H  LOOP

               CASE  I  IS
                    WHEN  B..D      =>  NULL ;
                    WHEN  E..H      =>  NULL ;
                    WHEN  MIDPOINT  =>  NULL ;
               END CASE;

          END LOOP;


     END ;


     RESULT ;


END A55B13A ;
