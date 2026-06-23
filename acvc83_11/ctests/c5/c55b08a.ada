-- C55B08A.ADA

-- CHECK THAT WHEN INTEGER LITERALS FROM OUTSIDE THE RANGE OF  'INTEGER'
--    ARE USED IN A LOOP OF THE FORM
--                'FOR  I  IN  L..R  LOOP'
--   NUMERIC OR CONSTRAINT ERROR IS RAISED.

-- RM  04/17/81
-- SPS 11/01/82
-- JBG 08/21/83
-- EG  10/28/85  FIX NUMERIC_ERROR/CONSTRAINT_ERROR ACCORDING TO
--               AI-00387.

WITH SYSTEM;
WITH REPORT;
PROCEDURE  C55B08A  IS

     USE  REPORT ;

BEGIN

     TEST( "C55B08A" , "'FOR  I  IN  L..R  LOOP'  RAISES AN EXCEPTION" &
                       " WHEN  L,R ARE NOT BOTH OF THE (PREDEF.) TYPE" &
                       " 'INTEGER'" );

     BEGIN

          DECLARE

               HUGE : CONSTANT := SYSTEM.MAX_INT - 10 ;
               HUGE15 : CONSTANT := HUGE - 15;
               TOO_BIG: BOOLEAN := HUGE > INTEGER'POS(INTEGER'LAST);

          BEGIN

               -- IF  MAX_INT - 10 > INTEGER'LAST , NUMERIC_ERROR
               --    SHOULD BE RAISED; OTHERWISE, WE HAVE AN ORDINARY
               --    NULL RANGE AND NO NUMERIC_ERROR.
               FOR  I  IN  HUGE..HUGE15  LOOP
                    NULL;
               END LOOP;
               IF TOO_BIG THEN
                    FAILED ("EXCEPTION NOT RAISED(1)");
               END IF;

          EXCEPTION

               WHEN NUMERIC_ERROR =>
                    IF NOT TOO_BIG THEN
                         FAILED ("NUMERIC_ERROR RAISED - 1");
                    ELSE
                         COMMENT ("NUMERIC_ERROR RAISED - 1");
                    END IF;
               WHEN CONSTRAINT_ERROR =>
                    IF NOT TOO_BIG THEN
                         FAILED ("CONSTRAINT_ERROR RAISED - 1");
                    ELSE
                         COMMENT ("CONSTRAINT_ERROR RAISED - 1");
                    END IF;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (1)" );

          END ;


          DECLARE

               MINUS_HUGE : CONSTANT := SYSTEM.MIN_INT ;
               TOO_BIG : BOOLEAN := MINUS_HUGE <
                                    INTEGER'POS(INTEGER'FIRST);

          BEGIN

               -- IF  MIN_INT < INTEGER'FIRST , CONSTRAINT_ERROR
               --    SHOULD BE RAISED; OTHERWISE, WE HAVE AN ORDINARY
               --    NULL RANGE AND NO CONSTRAINT_ERROR.
               FOR  I  IN  0..MINUS_HUGE  LOOP
                    NULL;
               END LOOP;
               IF TOO_BIG THEN
                    FAILED("EXCEPTION NOT RAISED (2)");
               END IF;

          EXCEPTION

               WHEN NUMERIC_ERROR =>
                    IF NOT TOO_BIG THEN
                         FAILED ("NUMERIC_ERROR RAISED - 2");
                    ELSE
                         COMMENT ("NUMERIC_ERROR RAISED - 2");
                    END IF;
               WHEN  CONSTRAINT_ERROR =>
                    IF NOT TOO_BIG THEN
                         FAILED ("CONSTRAINT_ERROR RAISED - 2");
                    ELSE
                         COMMENT ("CONSTRAINT_ERROR RAISED - 2");
                    END IF;
               WHEN  OTHERS           =>
                    FAILED( "WRONG EXCEPTION RAISED (2)" );

          END ;

     END ;


     RESULT ;


END  C55B08A ;
