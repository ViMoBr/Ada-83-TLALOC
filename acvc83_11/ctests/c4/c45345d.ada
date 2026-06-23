-- C45345D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE RESULT OF CATENATION HAS
-- A BOUND THAT DOES NOT BELONG TO THE INDEX SUBTYPE.

-- PART 2: DYNAMIC BOUNDS

-- BHS 6/25/84
-- JRK 9/5/84

WITH REPORT;
PROCEDURE C45345D IS

     USE REPORT;

     TYPE DAY IS (MON, TUE, WED, THU, FRI, SAT, SUN);

     FUNCTION ID_DAY (D : DAY) RETURN DAY IS
     BEGIN
          IF EQUAL(DAY'POS(D),DAY'POS(D)) THEN
               RETURN D;  
          END IF;
          RETURN DAY'FIRST;
     END ID_DAY;

BEGIN
     TEST ("C45345D", "CHECK THAT CONSTRAINT_ERROR RAISED IF RESULT " &
                      "OF CATENATION HAS BOUND THAT DOES NOT BELONG " &
                      "TO INDEX SUBTYPE");

     ----------------------------------------------------------
     ------------  CASE 1: INTEGER SUBTYPE   ------------------
     
     DECLARE
          A : ARRAY (1..IDENT_INT(10)) OF INTEGER;

     BEGIN
          A := (1,2,3,4,5,6,7,8,9,10);
          A := A(IDENT_INT(6)..IDENT_INT(9)) & 
                A(IDENT_INT(8)..IDENT_INT(9)) &
                A(IDENT_INT(8)..IDENT_INT(9)) & 0 & 0;

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
          A : ARRAY(MON..ID_DAY(FRI)) OF INTEGER;

     BEGIN
          A := (MON|WED|FRI => 0, TUE|THU => 1);
          A := A(ID_DAY(WED)..ID_DAY(FRI)) & A(MON) & 1;

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
          A : ARRAY (CHARACTER RANGE 'A'..IDENT_CHAR('G')) OF INTEGER;

     BEGIN
          A := ('A'..'C' => 1, 'D'..'G' => 2);
          A := A(IDENT_CHAR('D')..IDENT_CHAR('F')) &
                A(IDENT_CHAR('D')..IDENT_CHAR('E')) &
                A(IDENT_CHAR('G')) & 0;
                
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
          A : CH_ARR (1..IDENT_INT(6));

     BEGIN
          A := "ABCDEF";
          A := A(IDENT_INT(3)..IDENT_INT(5)) &
               A(IDENT_INT(2)..IDENT_INT(3)) & 'G';

          FAILED ("NO EXCEPTION RAISED FOR CONSTRAINT ERROR 4");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 4");

     END;

     --------------------------------------------------------------

     RESULT;

END C45345D;
