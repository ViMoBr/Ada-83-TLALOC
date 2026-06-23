-- B96002A.ADA

-- CHECK THAT AN ARGUMENT TO THE DELAY STATEMENT MUST HAVE TYPE
-- DURATION. ALSO, CHECK THE TYPE OF ARGUMENTS PASSED TO "+" AND "-"
-- FUNCTIONS IN THE PACKAGE CALENDAR. TESTS ARE:
--   (A) TYPE OF ARGUMENT TO A DELAY STATEMENT.
--   (B) TYPE OF ARGUMENTS TO FUNCTION "+".
--   (C) TYPE OF ARGUMENTS TO FUNCTION "-".

-- CPP 8/14/84

WITH SYSTEM;
WITH CALENDAR;  USE CALENDAR;
PROCEDURE B96002A IS
BEGIN

     -----------------------------------------------

DECLARE   -- (A)

     TYPE REAL IS DIGITS 3;
     X : INTEGER := 5;
     Y : TIME := CLOCK;
     Z : CONSTANT REAL := 3.0;

BEGIN     -- (A)

     DELAY X;                      -- ERROR: INTEGER.
     NULL;

     DELAY Y;                      -- ERROR: TIME.
     NULL;

     DELAY Z;                      -- ERROR: REAL.
     NULL;

END; -- (A)

     -----------------------------------------------

DECLARE   -- (B)

     TYPE REAL IS DIGITS 3;
     BEFORE : TIME := CLOCK;
     AFTER : TIME;
     INC1 : CONSTANT REAL := 2.0;

BEGIN     -- (B)

     AFTER := CLOCK + SYSTEM.TICK;
     AFTER := BEFORE + AFTER;      -- ERROR: ARGS OF TYPE TIME.
     NULL;

     AFTER := BEFORE + INC1;       -- ERROR: TIME + REAL.
     NULL;

END; -- (B)

     -----------------------------------------------

DECLARE   -- (C)

     TYPE REAL IS DIGITS 3;
     BEFORE : TIME := CLOCK;
     AFTER : TIME;
     INC1 : CONSTANT REAL := 3.0;

BEGIN     -- (C)

     BEFORE := INC1 - BEFORE;      -- ERROR: DURATION - TIME.
     NULL;

     AFTER := BEFORE - INC1;            -- ERROR: TIME - REAL.
     NULL;

END; -- (C)

     -----------------------------------------------

END B96002A;
