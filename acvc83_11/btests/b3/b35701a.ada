-- B35701A.ADA

-- OBJECTIVE:
--     ERRORS IN REAL TYPE DEFINITIONS:
--        (A) EXPRESSION AFTER DIGITS IS REAL
--        (B) DIGITS 0, NEGATIVE
--        (C) NOT STATIC_EXPRESSION AFTER DIGITS
--        (D) FLOATING POINT PRECISION TOO HIGH
--        (E) CHECK REAL RANGE NOT INTEGER

-- HISTORY:
--     BAW 05/09/80  CREATED ORIGINAL TEST.
--     BCB 08/01/88  MODIFIED HEADER FORMAT, CHANGED FROM A .'TST' TEST,
--                   CHANGED $MAX_DIGITS TO SYSTEM.MAX_DIGITS, AND ADDED
--                   CHECKS FOR THE UPPER AND LOWER BOUNDS OF A RANGE
--                   OUTSIDE THE RANGE OF THE SAFE NUMBERS.

WITH SYSTEM;

PROCEDURE B35701A IS

     TYPE MY_R1 IS DIGITS 1.0; -- ERROR: EXPRESSION AFTER DIGITS
                               --           IS NOT INTEGER
     TYPE MY_R2 IS DIGITS 0;   -- ERROR: EXPRESSION AFTER DIGITS
                               --         HAS VALUE ZERO
     TYPE MY_R3 IS DIGITS -1;  -- ERROR: NEGATIVE DIGITS VALUE
     D : INTEGER := 1;
     TYPE MY_R4 IS DIGITS D;   -- ERROR: EXPRESSION AFTER DIGITS
                               --        IS NOT STATIC
     M : CONSTANT := SYSTEM.MAX_DIGITS + 1;

     TYPE MY_R5 IS DIGITS M;   -- ERROR: EXPRESSION AFTER DIGITS
                               --        HAS VALUE MAX_DIGITS+1
     TYPE MY_REAL IS DIGITS 5
                  RANGE -1..1; -- ERROR: INTEGER EXPRESSION IN
                               --        RANGE CONSTRAINT

     TYPE F0 IS DIGITS SYSTEM.MAX_DIGITS;

     TYPE F1 IS DIGITS SYSTEM.MAX_DIGITS
                  RANGE 0.0 .. F0'SAFE_LARGE*2.0; -- ERROR: UPPER BOUND
                                                  -- EXCEEDS RANGE OF
                                                  -- SAFE NUMBERS.

     TYPE F2 IS DIGITS SYSTEM.MAX_DIGITS
               RANGE -(F0'SAFE_LARGE*2.0) .. 0.0; -- ERROR: LOWER BOUND
                                                  -- EXCEEDS RANGE OF
                                                  -- SAFE NUMBERS.


BEGIN
      NULL;
END B35701A;
