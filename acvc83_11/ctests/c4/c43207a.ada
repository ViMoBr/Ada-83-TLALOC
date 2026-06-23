-- C43207A.ADA

-- FOR A MULTIDIMENSIONAL AGGREGATE OF THE FORM (F..G => (H..I => J)),
-- CHECK THAT:

--     A) H AND I ARE EVALUATED EXCEPT POSSIBLY WHEN F..G IS NON-NULL
--        AND DOES NOT BELONG TO THE INDEX SUBTYPE;

-- EG  01/18/84
-- BHS  7/13/84
-- JBG 12/6/84

WITH REPORT;

PROCEDURE C43207A IS

     USE REPORT;

BEGIN

     TEST("C43207A", "CHECK THAT THE EVALUATION OF A MULTI" &
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

          PROCEDURE PR (X : T0) IS
          BEGIN
               NULL;
          END PR;

     BEGIN

CASE_A :  BEGIN

     CASE_A1 : BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    PR((2 .. 9 => (CALC(H,1) .. CALC(I,8) => 2)));
                    FAILED("CASE A1 : CONSTRAINT_ERROR NOT RAISED");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF CNTR(H) /= 0 AND CNTR(I) /= 0 THEN
                              COMMENT ("CASE A1 : ALL CHOICES " &
                                       "EVALUATED BEFORE CHECKING " &
                                       "INDEX SUBTYPE");
                         ELSIF CNTR(H) = 0 AND CNTR(I) = 0 THEN
                              COMMENT ("CASE A1 : SUBTYPE CHECKS "&
                                       "MADE AS CHOICES ARE EVALUATED");
                         END IF;
                              
                         IF CNTR(H) > 1 THEN
                              FAILED("CASE A1 : H WAS NOT EVALUATED " &
                                     "AT MOST ONCE. H WAS EVALUATED" &
                                     INTEGER'IMAGE(CNTR(H)) & " TIMES");
                         END IF;

                         IF CNTR(I) > 1 THEN
                              FAILED("CASE A1 : I WAS NOT EVALUATED " &
                                     "AT MOST ONCE. I WAS EVALUATED" &
                                     INTEGER'IMAGE(CNTR(I)) & " TIMES");
                         END IF;
                    WHEN OTHERS =>
                         FAILED("CASE A1 : EXCEPTION RAISED");
               END CASE_A1;

     CASE_A2 : BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    PR((CALC(F,2) .. CALC(G,9) =>
                                    (CALC(H,1) .. CALC(I,8) => 2)));
                    FAILED("CASE A2 : CONSTRAINT_ERROR NOT RAISED");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF CNTR(H) /= 0 AND CNTR(I) /= 0 THEN
                              COMMENT ("CASE A2 : ALL CHOICES " &
                                       "EVALUATED BEFORE CHECKING " &
                                       "INDEX SUBTYPE");
                         ELSIF CNTR(H) = 0 AND CNTR(I) = 0 THEN
                              COMMENT ("CASE A2 : SUBTYPE CHECKS "&
                                       "MADE AS CHOICES ARE EVALUATED");
                         END IF;
                              
                         IF CNTR(H) > 1 THEN
                              FAILED("CASE A2 : H WAS NOT EVALUATED " &
                                     "AT MOST ONCE. H WAS EVALUATED" &
                                     INTEGER'IMAGE(CNTR(H)) & " TIMES");
                         END IF;

                         IF CNTR(I) > 1 THEN
                              FAILED("CASE A2 : I WAS NOT EVALUATED " &
                                     "AT MOST ONCE. I WAS EVALUATED" &
                                     INTEGER'IMAGE(CNTR(I)) & " TIMES");
                         END IF;
                    WHEN OTHERS =>
                         FAILED("CASE A2 : EXCEPTION RAISED");
               END CASE_A2;

     CASE_A3 : DECLARE
                    A3 : T0(1 .. 8, 5 .. 4);
               BEGIN
                    CNTR := (CHOICE_INDEX => 0);
                    A3 := (1 .. 9 => (CALC(H,5) .. CALC(I,4) => 2));
                    FAILED ("CASE A3 : CONSTRAINT_ERROR NOT RAISED");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF CNTR(H) /= 0 AND CNTR(I) /= 0 THEN
                              COMMENT ("CASE A3 : ALL CHOICES " &
                                       "EVALUATED BEFORE CHECKING " &
                                       "INDEX SUBTYPE");
                         ELSIF CNTR(H) = 0 AND CNTR(I) = 0 THEN
                              COMMENT ("CASE A3 : SUBTYPE CHECKS "&
                                       "MADE AS CHOICES ARE EVALUATED");
                         END IF;
                              
                         IF CNTR(H) > 1 THEN
                              FAILED("CASE A3 : H WAS NOT EVALUATED " &
                                     "AT MOST ONCE. H WAS EVALUATED" &
                                     INTEGER'IMAGE(CNTR(H)) & " TIMES");
                         END IF;

                         IF CNTR(I) > 1 THEN
                              FAILED("CASE A3 : I WAS NOT EVALUATED " &
                                     "AT MOST ONCE. I WAS EVALUATED" &
                                     INTEGER'IMAGE(CNTR(I)) & " TIMES");
                         END IF;
                    WHEN OTHERS =>
                         FAILED("CASE A3 : EXCEPTION RAISED");
               END CASE_A3;

          END CASE_A;

     END;

     RESULT;

END C43207A;
