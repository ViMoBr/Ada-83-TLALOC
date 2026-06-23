-- B96003A.ADA

-- CHECK THAT CERTAIN PRE-DEFINED FUNCTIONS IN THE PACKAGE CALENDAR DO
-- NOT HAVE DEFAULT PARAMETERS. SPECIFICALLY,
--   (A) THE YEAR, MONTH, AND DAY PARAMETERS OF TIME_OF() DO NOT HAVE
--       DEFAULT VALUES.
--   (B) THE DATE PARAMETER OF SPLIT() DOES NOT HAVE A DEFAULT VALUE.
--   (C) THE DATE PARAMETER OF YEAR(), MONTH(), DAY(), AND SECONDS()
--       DOES NOT HAVE A DEFAULT VALUE.
--   (D) ENUMERATED MONTH NAMES ARE NOT ALLOWED.

-- CPP 8/15/84

WITH CALENDAR;  USE CALENDAR;
PROCEDURE B96003A IS
BEGIN

     ------------------------------------------------

DECLARE   -- (A)

     NOW : TIME;

BEGIN     -- (A)

     NOW := TIME_OF;                            -- ERROR:
     NULL;

     NOW := TIME_OF(1984);                   -- ERROR:
     NULL;

     NOW := TIME_OF(1984, 8);                -- ERROR:
     NULL;

     NOW := TIME_OF(1984, 8, 13);            -- OK.
     NULL;

END; -- (A)

     ------------------------------------------------

DECLARE   -- (B)

     YR : YEAR_NUMBER;
     MO : MONTH_NUMBER;
     DY : DAY_NUMBER;
     SEC : DAY_DURATION;

BEGIN     -- (B)

     SPLIT (YEAR => YR, MONTH => MO,
            DAY => DY, SECONDS => SEC);      -- ERROR:
     NULL;

END; -- (B)

     ------------------------------------------------

DECLARE   -- (C)

     YR : YEAR_NUMBER;
     MO : MONTH_NUMBER;
     DY : DAY_NUMBER;
     SEC : DAY_DURATION;

BEGIN     -- (C)

     YR := YEAR;                             -- ERROR:
     NULL;

     MO := MONTH;                            -- ERROR:
     NULL;

     DY := DAY;                              -- ERROR:
     NULL;

     SEC := SECONDS;                         -- ERROR:
     NULL;

END; -- (C)

     ------------------------------------------------

DECLARE   -- (D)

     MO : MONTH_NUMBER;

BEGIN     -- (D)

     MO := AUG;                              -- ERROR:

END; -- (D)

     ------------------------------------------------

END B96003A;
