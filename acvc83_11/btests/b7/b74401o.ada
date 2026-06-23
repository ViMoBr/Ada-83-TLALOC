-- B74401O.ADA

-- CHECK THAT IN A GENERIC SUBPROGRAM DECLARATION, A PARAMETER OF MODE
-- OUT MAY NOT BE OF A LIMITED TYPE IF:

--   C) THE DECLARATION APPEARS IN THE VISIBLE PART OF A PACKAGE
--      SPECIFICATION, THE OUT PARAMETER IS A LIMITED PRIVATE TYPE
--      DECLARED IN THE SAME VISIBLE PART, BUT THE FULL DECLARATION
--      DECLARES A TASK TYPE, A COMPOSITE LIMITED TYPE, OR A TYPE
--      DERIVED FROM A LIMITED PRIVATE TYPE.

-- JBG 9/23/83
-- BHS 7/10/84
-- JRK 12/4/84
-- JBG 5/1/85

PROCEDURE B74401O IS

     PACKAGE P IS
          TYPE LP IS LIMITED PRIVATE;
          TASK TYPE TSK;
          TYPE ARR_LP IS ARRAY(1..2) OF P.LP;
          TYPE REC_LP IS
               RECORD
                    LP : P.LP;
               END RECORD;
     PRIVATE
          TYPE LP IS NEW INTEGER;
     END P;

     PACKAGE BODY P IS
          TASK BODY TSK IS
          BEGIN
               NULL;
          END TSK;
     END P;

     PACKAGE CASE_C IS
          TYPE LP4 IS LIMITED PRIVATE;
          TYPE LP5 IS LIMITED PRIVATE;
          TYPE LP6 IS LIMITED PRIVATE;
          TYPE LP7 IS LIMITED PRIVATE;

          GENERIC
          PROCEDURE P14 (X : OUT LP4);

          GENERIC
          PROCEDURE P15 (X : OUT LP5);

          GENERIC
          PROCEDURE P16 (X : OUT LP6);

          GENERIC
          PROCEDURE P17 (X : OUT LP7);

     PRIVATE

          TASK TYPE LP4;                   -- ERROR: OUT PARAMETER.
          TYPE LP5 IS ARRAY(1..2) OF P.LP; -- ERROR: OUT PARAMETER.
          TYPE LP6 IS
               RECORD
                    LP : P.LP;
               END RECORD;                 -- ERROR: OUT PARAMETER.
          TYPE LP7 IS NEW P.LP;            -- ERROR: OUT PARAMETER.
     
     END CASE_C;

     PACKAGE BODY CASE_C IS

          TASK BODY LP4 IS
          BEGIN
               NULL;
          END LP4;

          PROCEDURE P14 (X : OUT LP4) IS     -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P14;

          PROCEDURE P15 (X : OUT LP5) IS     -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P15;

          PROCEDURE P16 (X : OUT LP6) IS     -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P16;

          PROCEDURE P17 (X : OUT LP7) IS     -- ERR MSG OPTIONAL.
          BEGIN
               NULL;
          END P17;

     END CASE_C;

BEGIN
     NULL;
END B74401O;
