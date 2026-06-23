-- C45347C.ADA

-- CHECK THAT CATENATION IS DEFINED FOR PRIVATE TYPES AS COMPONENT
-- TYPES.

-- JWC 11/15/85

WITH REPORT; USE REPORT;

PROCEDURE C45347C IS

BEGIN

     TEST ("C45347C", "CHECK THAT CATENATION IS DEFINED " &
                      "FOR PRIVATE TYPES AS COMPONENT TYPES");

     DECLARE

          PACKAGE PKG IS
               TYPE PRIV IS PRIVATE;
               ONE : CONSTANT PRIV;
               TWO : CONSTANT PRIV;
               THREE : CONSTANT PRIV;
               FOUR : CONSTANT PRIV;
          PRIVATE
               TYPE PRIV IS NEW INTEGER;
               ONE : CONSTANT PRIV := 1;
               TWO : CONSTANT PRIV := 2;
               THREE : CONSTANT PRIV := 3;
               FOUR : CONSTANT PRIV := 4;
          END PKG;

          USE PKG;

          SUBTYPE INT IS INTEGER RANGE 1 .. 4;
          TYPE A IS ARRAY ( INT RANGE <>) OF PRIV;

          P1 : PRIV := FOUR;
          P2 : PRIV := ONE;

          A1 : A(1 .. 2) := (ONE, TWO);
          A2 : A(1 .. 2) := (THREE, FOUR);
          A3 : A(1 .. 4) := (ONE, TWO, THREE, FOUR);
          A4 : A(1 .. 4);
          A5 : A(1 .. 4) := (FOUR, THREE, TWO, ONE);

     BEGIN

          A4 := A1 & A2;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR TWO ARRAYS OF " &
                       "PRIVATE");
          END IF;

          A4 := A5;

          A4 := A1 & A2(1) & P1;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ARRAY OF PRIVATE, " &
                       "AND PRIVATE");
          END IF;

          A4 := A5;

          A4 := P2 & (A1(2) & A2);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR PRIVATE, AND ARRAY " &
                       "OF PRIVATE");
          END IF;

          A4 := A5;

          A4 := P2 & A1(2) & (A2(1) & P1);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR PRIVATE");
          END IF;

     END;

     RESULT;

END C45347C;
