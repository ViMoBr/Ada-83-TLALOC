-- C43208A.ADA

-- FOR A ONE-DIMENSIONAL AGGREGATE OF THE FORM (F..G => (H..I => J)),
-- CHECK THAT:

--     A) IF F..G IS A NULL RANGE, H, I, AND J ARE NOT EVALUATED.

--     B) IF F..G IS A NON-NULL RANGE, H AND I ARE EVALUATED G-F+1
--        TIMES, AND J IS EVALUATED (I-H+1)*(G-F+1) TIMES IF H..I
--        IS NON-NULL.

-- EG  01/19/84

WITH REPORT;

PROCEDURE C43208A IS

     USE REPORT;

BEGIN

     TEST("C43208A", "CHECK THAT THE EVALUATION OF A ONE-" &
                     "DIMENSIONAL AGGREGATE OF THE FORM "  &
                     "(F..G => (H..I = J)) IS PERFORMED "  &
                     "CORRECTLY");

     DECLARE

          TYPE CHOICE_INDEX IS (F, G, H, I, J);
          TYPE CHOICE_CNTR  IS ARRAY(CHOICE_INDEX) OF INTEGER;

          CNTR : CHOICE_CNTR := (CHOICE_INDEX => 0);

          TYPE T1 IS ARRAY(INTEGER RANGE <>) OF INTEGER;
   
          FUNCTION CALC (A : CHOICE_INDEX; B : INTEGER)
                         RETURN INTEGER IS
          BEGIN
               CNTR(A) := CNTR(A) + 1;
               RETURN IDENT_INT(B);
          END CALC;

     BEGIN

CASE_A :  BEGIN

     CASE_A1 : DECLARE
                    A1 : ARRAY(4 .. 2) OF T1(1 .. 2);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    A1 := (4 .. 2 => 
                              (CALC(H,1) .. CALC(I,2) => CALC(J,2)));
                    IF CNTR(H) /= 0 THEN
                         FAILED("CASE A1 : H WAS EVALUATED");
                    END IF;
                    IF CNTR(I) /= 0 THEN
                         FAILED("CASE A1 : I WAS EVALUATED");
                    END IF;
                    IF CNTR(J) /= 0 THEN
                         FAILED("CASE A1 : J WAS EVALUATED");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE A1 : EXCEPTION RAISED");
               END CASE_A1;

     CASE_A2 : DECLARE
                    A2 : ARRAY(4 .. 2) OF T1(1 .. 2);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    A2 := (CALC(F,4) .. CALC(G,2) =>
                               (CALC(H,1) .. CALC(I,2) => CALC(J,2)));
                    IF CNTR(H) /= 0 THEN
                         FAILED("CASE A2 : H WAS EVALUATED");
                    END IF;
                    IF CNTR(I) /= 0 THEN
                         FAILED("CASE A2 : I WAS EVALUATED");
                    END IF;
                    IF CNTR(J) /= 0 THEN
                         FAILED("CASE A2 : J WAS EVALUATED");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE A2 : EXCEPTION RAISED");
               END CASE_A2;

          END CASE_A;

CASE_B :  BEGIN

     CASE_B1 : DECLARE
                    B1 : ARRAY(2 .. 3) OF T1(1 .. 2);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    B1 := (2 .. 3 =>
                              (CALC(H,1) .. CALC(I,2) => CALC(J,2)));
                    IF CNTR(H) /= 2 THEN
                         FAILED("CASE B1 : H NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(I) /= 2 THEN
                         FAILED("CASE B1 : I NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(J) /= 4 THEN
                         FAILED("CASE B1 : J NOT EVALUATED (I-H+1)*" &
                                "(G-F+1) TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE B1 : EXECEPTION RAISED");
               END CASE_B1;

     CASE_B2 : DECLARE
                    B2 : ARRAY(2 .. 3) OF T1(9 .. 10);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    B2 := (CALC(F,2) .. CALC(G,3) =>
                              (CALC(H,9) .. CALC(I,10) => CALC(J,2)));
                    IF CNTR(H) /= 2 THEN
                         FAILED("CASE B2 : H NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(I) /= 2 THEN
                         FAILED("CASE B2 : I NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(J) /= 4 THEN
                         FAILED("CASE B2 : J NOT EVALUATED (I-H+1)*" &
                                "(G-F+1) TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE B2 : EXECEPTION RAISED");
               END CASE_B2;

     CASE_B3 : DECLARE
                    B3 : ARRAY(2 .. 3) OF T1(2 .. 1);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    B3 := (2 .. 3 =>
                              (CALC(H,2) .. CALC(I,1) => CALC(J,2)));
                    IF CNTR(H) /= 2 THEN
                         FAILED("CASE B3 : H NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(I) /= 2 THEN
                         FAILED("CASE B3 : I NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(J) /= 0 THEN
                         FAILED("CASE B3 : J NOT EVALUATED ZERO TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE B3 : EXECEPTION RAISED");
               END CASE_B3;

     CASE_B4 : DECLARE
                    B4 : ARRAY(2 .. 3) OF T1(2 .. 1);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    B4 := (CALC(F,2) .. CALC(G,3) =>
                              (CALC(H,2) .. CALC(I,1) => CALC(J,2)));
                    IF CNTR(H) /= 2 THEN
                         FAILED("CASE B4 : H NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(I) /= 2 THEN
                         FAILED("CASE B4 : I NOT EVALUATED G-F+1 " &
                                "TIMES");
                    END IF;
                    IF CNTR(J) /= 0 THEN
                         FAILED("CASE B4 : J NOT EVALUATED ZERO TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE B4 : EXECEPTION RAISED");
               END CASE_B4;

          END CASE_B;
      END;

     RESULT;

END C43208A;
