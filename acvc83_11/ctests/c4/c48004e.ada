-- C48004E.ADA

-- CHECK THAT THE FORM "NEW T" IS PERMITTED IF T IS A CONSTRAINED ARRAY
-- TYPE.

-- RM  01/12/80
-- JBG 03/03/83
-- EG  07/05/84

WITH REPORT;

PROCEDURE  C48004E  IS

     USE REPORT;

BEGIN

     TEST("C48004E","CHECK THAT THE FORM 'NEW T' IS PERMITTED IF T " &
                    "IS A CONSTRAINED ARRAY TYPE");

     DECLARE

          TYPE ARR0 IS ARRAY( INTEGER RANGE <> ) OF BOOLEAN;
          SUBTYPE ARR IS ARR0(1 .. 10);
          TYPE  A_ARR  IS  ACCESS ARR;
          VARR : A_ARR;

          PACKAGE P IS
               TYPE LPRIV IS LIMITED PRIVATE;
               FUNCTION CHECK (X : LPRIV) RETURN INTEGER;
          PRIVATE
               TYPE LPRIV IS
                    RECORD
                         Q : INTEGER := 20;
                    END RECORD;
          END P;

          TYPE LPARR IS ARRAY(1 .. 2) OF P.LPRIV;
          TYPE A_LPARR IS ACCESS LPARR;

          V_A_LPARR : A_LPARR;

          PACKAGE BODY P IS
               FUNCTION CHECK (X : LPRIV) RETURN INTEGER IS
               BEGIN
                    RETURN X.Q;
               END CHECK;
          END P;
          
     BEGIN

          VARR := NEW ARR;
          IF  ( VARR'FIRST /= IDENT_INT(1)  OR
                VARR'LAST /= 10 )  THEN FAILED("WRONG BOUNDS - CASE 1");
          END IF;

          V_A_LPARR := NEW LPARR;
          IF ( P.CHECK(V_A_LPARR.ALL(1)) /= IDENT_INT(20) OR
               P.CHECK(V_A_LPARR.ALL(2)) /= IDENT_INT(20) ) THEN
               FAILED ("WRONG VALUES - CASE 2");
          END IF;

     END;

     RESULT;

END C48004E;
