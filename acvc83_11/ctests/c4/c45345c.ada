-- C45345C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE RESULT OF CATENATION HAS
-- A BOUND THAT DOES NOT BELONG TO THE INDEX SUBTYPE.

-- BHS 6/25/84
-- JRK 9/5/84

WITH REPORT;
PROCEDURE C45345C IS

     USE REPORT;

BEGIN
     TEST ("C45345C", "CHECK THAT CONSTRAINT_ERROR RAISED IF RESULT " &
                      "OF CATENATION HAS BOUND THAT DOES NOT BELONG " &
                      "TO INDEX SUBTYPE");

     ----------------------------------------------------------
     ------------  CASE 1: INTEGER SUBTYPE   ------------------
     
     DECLARE
          A : ARRAY (1..10) OF INTEGER;

     BEGIN
          A := (1,2,3,4,5,6,7,8,9,10);
          A := A(6..9) & A(8..9) & A(8..9) & 0 & 0;

          FAILED ("NO EXCEPTION RAISED FOR SUBTYPE CONSTRAINT ERROR 1");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 1");

     END;

     -----------------------------------------------------------
     ------------- CASE 2: ENUMERATION SUBTYPE  ----------------

     DECLARE
          TYPE DAY IS (MON, TUE, WED, THU, FRI, SAT, SUN);
          A : ARRAY(MON..FRI) OF INTEGER;

     BEGIN
          A := (MON|WED|FRI => 0, TUE|THU => 1);
          A := A(WED..FRI) & A(MON) & 1;

          FAILED ("NO EXCEPTION RAISED FOR SUBTYPE CONSTRAINT ERROR 2");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 2");

     END;

     ---------------------------------------------------------------
     ------------   CASE 3: CHARACTER SUBTYPE   --------------------

     DECLARE
          A : ARRAY (CHARACTER RANGE 'A'..'G') OF INTEGER;

     BEGIN
          A := ('A'..'C' => 1, 'D'..'G' => 2);
          A := A('D'..'F') & A('D'..'E') & A('G') & 0;

          FAILED ("NO EXCEPTION RAISED FOR SUBTYPE CONSTRAINT ERROR 3");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 3");

     END;

     -------------------------------------------------------------
     -------------------  CASE 4: STRINGS  -----------------------

     DECLARE
          SUBTYPE SMALL IS INTEGER RANGE 1..7;
          TYPE CH_ARR IS ARRAY (SMALL RANGE <>) OF CHARACTER;
          A : CH_ARR (1..6);

     BEGIN
          A := "ABCDEF";
          A := A(3..5) & A(2..3) & 'G';

          FAILED ("NO EXCEPTION RAISED FOR CONSTRAINT ERROR 4");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 4");

     END;

     --------------------------------------------------------------

     RESULT;

END C45345C;
