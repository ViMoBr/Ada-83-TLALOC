-- B66001C.ADA

-- CHECK THAT A SUBPROGRAM CANNOT HAVE THE SAME IDENTIFIER AS A 
--   VARIABLE, TYPE, SUBTYPE, CONSTANT, NUMBER, ARRAY, GENERIC
--   UNIT, OR PACKAGE DECLARED PREVIOUSLY IN THE SAME DECLARATIVE PART.

-- DAS 2/3/81
-- CPP 6/8/84

PROCEDURE B66001C IS
BEGIN

     DECLARE
          P : INTEGER;
          PROCEDURE P IS           -- ERROR: DUPLICATE NAME P.
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          TYPE P IS (P0,P1,P2);
          PROCEDURE P IS           -- ERROR: DUPLICATE NAME P.
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          SUBTYPE P IS INTEGER RANGE 1..10;
          PROCEDURE P IS           -- ERROR: DUPLICATE NAME P.
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          P : CONSTANT INTEGER := 2;
          PROCEDURE P IS           -- ERROR: DUPLICATE NAME P.
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          P : CONSTANT := 7;
          PROCEDURE P IS           -- ERROR: DUPLICATE NAME P.
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          P : ARRAY (1..3) OF INTEGER;
          PROCEDURE P IS           -- ERROR: DUPLICATE NAME P.
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          GENERIC
          PROCEDURE P;
          PROCEDURE P (A : INTEGER);  -- ERROR: DUPLICATE NAME P.

          PROCEDURE P IS
               PROCEDURE P (B : INTEGER) IS  -- OK.
               BEGIN
                    NULL;
               END P;
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

     DECLARE
          PACKAGE P IS
          END P;
          PROCEDURE P IS           -- ERROR: DUPLICATE NAME P.
          BEGIN
               NULL;
          END P;
     BEGIN
          NULL;
     END;

END B66001C;
