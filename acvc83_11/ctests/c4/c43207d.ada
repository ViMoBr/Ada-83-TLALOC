-- C43207D.ADA

-- FOR A MULTIDIMENSIONAL AGGREGATE OF THE FORM (F..G => (H..I => J)),
-- CHECK THAT:

--     D) J IS EVALUATED ONCE FOR EACH COMPONENT (ZERO TIMES IF THE
--        ARRAY IS NULL).

-- EG  01/18/84

WITH REPORT;

PROCEDURE C43207D IS

     USE REPORT;

BEGIN

     TEST("C43207D", "CHECK THAT THE EVALUATION OF A MULTI" &
                     "DIMENSIONAL AGGREGATE OF THE FORM "   &
                     "(F..G => (H..I = J)) IS PERFORMED "   &
                     "CORRECTLY");

     DECLARE

          TYPE CHOICE_INDEX IS (F, G, H, I, J);
          TYPE CHOICE_CNTR  IS ARRAY(CHOICE_INDEX) OF INTEGER;

          CNTR : CHOICE_CNTR := (CHOICE_INDEX => 0);

          SUBTYPE SINT IS INTEGER RANGE 1 .. 8;
          TYPE T0 IS ARRAY(SINT RANGE <>, SINT RANGE <>) OF INTEGER;
   
          FUNCTION CALC (A : CHOICE_INDEX; B : INTEGER)
                         RETURN INTEGER IS
          BEGIN
               CNTR(A) := CNTR(A) + 1;
               RETURN IDENT_INT(B);
          END CALC;

     BEGIN

CASE_D :  BEGIN

     CASE_D1 : DECLARE
                    D1 : T0(8 .. 4, 5 .. 1);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    D1 := (8 .. 4 => (5 .. 1 => CALC(J,2)));
                    IF CNTR(J) /= 0 THEN
                         FAILED("CASE D1 : INCORRECT NUMBER " &
                                "OF EVALUATIONS. J EVALUATED" &
                                INTEGER'IMAGE(CNTR(J)) & " TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE D1 : EXCEPTION RAISED");
               END CASE_D1;

     CASE_D2 : DECLARE
                    D2 : T0(8 .. 4, 5 .. 1);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    D2 := (CALC(F,8) .. CALC(G,4) =>
                              (CALC(H,5) .. CALC(I,1) => CALC(J,2)));
                    IF CNTR(J) /= 0 THEN
                         FAILED("CASE D2 : INCORRECT NUMBER " &
                                "OF EVALUATIONS. J EVALUATED" &
                                INTEGER'IMAGE(CNTR(J)) & " TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE D2 : EXCEPTION RAISED");
               END CASE_D2;

     CASE_D3 : DECLARE
                    D3 : T0(3 .. 5, 1 .. 2);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    D3 := (3 .. 5 => (1 .. 2 => CALC(J,2)));
                    IF CNTR(J) /= 6 THEN
                         FAILED("CASE D3 : INCORRECT NUMBER " &
                                "OF EVALUATIONS. J EVALUATED" &
                                INTEGER'IMAGE(CNTR(J)) & " TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE D3 : EXCEPTION RAISED");
               END CASE_D3;

     CASE_D4 : DECLARE
                    D4 : T0(1 .. 2, 5 .. 7);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    D4 := (CALC(F,1) .. CALC(G,2) =>
                              (CALC(H,5) .. CALC(I,7) => CALC(J,2)));
                    IF CNTR(J) /= 6 THEN
                         FAILED("CASE D4 : INCORRECT NUMBER " &
                                "OF EVALUATIONS. J EVALUATED" &
                                INTEGER'IMAGE(CNTR(J)) & " TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE D4 : EXCEPTION RAISED");
               END CASE_D4;

          END CASE_D;

     END;

     RESULT;

END C43207D;
