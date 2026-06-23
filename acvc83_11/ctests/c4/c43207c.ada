-- C43207C.ADA

-- FOR A MULTIDIMENSIONAL AGGREGATE OF THE FORM (F..G => (H..I => J)),
-- CHECK THAT:

--     C) F, G, H, AND I ARE EVALUATED ONCE, WHETHER OR NOT F..G IS A
--        NULL RANGE;

-- EG  01/18/84

WITH REPORT;

PROCEDURE C43207C IS

     USE REPORT;

BEGIN

     TEST("C43207C", "CHECK THAT THE EVALUATION OF A MULTI" &
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

CASE_C :  BEGIN

    CASE_C1 :  DECLARE
                    C1 : T0(8 .. 4, 1 .. 8);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    C1 := (CALC(F,8) .. CALC(G,4) =>
                               (CALC(H,1) .. CALC(I,8) => 2));
                    IF CNTR(F) /= 1 THEN
                         FAILED("CASE C1 : F WAS NOT EVALUATED " &
                                "ONCE. F WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(F)) & " TIMES");
                    END IF;
                    IF CNTR(G) /= 1 THEN
                         FAILED("CASE C1 : G WAS NOT EVALUATED " &
                                "ONCE. G WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(G)) & " TIMES");
                    END IF;
                    IF CNTR(H) /= 1 THEN
                         FAILED("CASE C1 : H WAS NOT EVALUATED " &
                                "ONCE. H WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(H)) & " TIMES");
                    END IF;
                    IF CNTR(I) /= 1 THEN
                         FAILED("CASE C1 : I WAS NOT EVALUATED " &
                                "ONCE. I WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(I)) & " TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE C1 : EXCEPTION RAISED");
               END CASE_C1;

     CASE_C2 : DECLARE
                    C2 : T0(1 .. 8, 1 .. 8);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    C2 := (CALC(F,1) .. CALC(G,8) =>
                               (CALC(H,1) .. CALC(I,8) => 2));
                    IF CNTR(F) /= 1 THEN
                         FAILED("CASE C2 : F WAS NOT EVALUATED " &
                                "ONCE. F WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(F)) & " TIMES");
                    END IF;
                    IF CNTR(G) /= 1 THEN
                         FAILED("CASE C2 : G WAS NOT EVALUATED " &
                                "ONCE. G WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(G)) & " TIMES");
                    END IF;
                    IF CNTR(H) /= 1 THEN
                         FAILED("CASE C2 : H WAS NOT EVALUATED " &
                                "ONCE. H WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(H)) & " TIMES");
                    END IF;
                    IF CNTR(I) /= 1 THEN
                         FAILED("CASE C2 : I WAS NOT EVALUATED " &
                                "ONCE. I WAS EVALUATED"          &
                                INTEGER'IMAGE(CNTR(I)) & " TIMES");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CASE C2 : EXCEPTION RAISED");
               END CASE_C2;

          END CASE_C;

     END;

     RESULT;

END C43207C;
