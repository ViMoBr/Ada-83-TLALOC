-- CC1207B.ADA

-- OBJECTIVE:
--     CHECK THAT AN UNCONSTRAINED FORMAL TYPE WITH DISCRIMINANTS IS
--     ALLOWED AS THE TYPE OF A SUBPROGRAM OR AN ENTRY FORMAL
--     PARAMETER, AND AS THE TYPE OF A GENERIC FORMAL OBJECT PARAMETER,
--     AS A GENERIC ACTUAL PARAMETER, AND IN A MEMBERSHIP TEST, IN A
--     SUBTYPE DECLARATION, IN AN ACCESS TYPE DEFINITION, AND IN A
--     DERIVED TYPE DEFINITION.

-- HISTORY:
--     BCB 08/04/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE CC1207B IS

     GENERIC
          TYPE X (L : INTEGER) IS PRIVATE;
     PACKAGE PACK IS
     END PACK;

BEGIN
     TEST ("CC1207B", "CHECK THAT AN UNCONSTRAINED FORMAL TYPE WITH " &
                      "DISCRIMINANTS IS ALLOWED AS THE TYPE OF A " &
                      "SUBPROGRAM OR AN ENTRY FORMAL PARAMETER, AND " &
                      "AS THE TYPE OF A GENERIC FORMAL OBJECT " &
                      "PARAMETER, AS A GENERIC ACTUAL PARAMETER, AND " &
                      "IN A MEMBERSHIP TEST, IN A SUBTYPE " &
                      "DECLARATION, IN AN ACCESS TYPE DEFINITION, " &
                      "AND IN A DERIVED TYPE DEFINITION");

     DECLARE
          TYPE REC (D : INTEGER := 3) IS RECORD
               NULL;
          END RECORD;

          GENERIC
               TYPE R (D : INTEGER) IS PRIVATE;
               OBJ : R;
          PACKAGE P IS
               PROCEDURE S (X : R);

               TASK T IS
                    ENTRY E (Y : R);
               END T;

               SUBTYPE SUB_R IS R;

               TYPE ACC_R IS ACCESS R;

               TYPE NEW_R IS NEW R;

               BOOL : BOOLEAN := (OBJ IN R);

               SUB_VAR : SUB_R(5);

               ACC_VAR : ACC_R := NEW R(5);

               NEW_VAR : NEW_R(5);

               PACKAGE NEW_PACK IS NEW PACK (R);
          END P;

          REC_VAR : REC(5) := (D => 5);

          PACKAGE BODY P IS
               PROCEDURE S (X : R) IS
               BEGIN
                    IF NOT EQUAL(X.D,5) THEN
                         FAILED ("WRONG DISCRIMINANT VALUE - S");
                    END IF;
               END S;

               TASK BODY T IS
               BEGIN
                    ACCEPT E (Y : R) DO
                         IF NOT EQUAL(Y.D,5) THEN
                              FAILED ("WRONG DISCRIMINANT VALUE - T");
                         END IF;
                    END E;
               END T;
          BEGIN
               IF NOT EQUAL(OBJ.D,5) THEN
                    FAILED ("IMPROPER DISCRIMINANT VALUE");
               END IF;

               S (OBJ);

               T.E (OBJ);

               IF NOT EQUAL(SUB_VAR.D,5) THEN
                    FAILED ("IMPROPER DISCRIMINANT VALUE - SUBTYPE");
               END IF;

               IF NOT EQUAL(ACC_VAR.D,5) THEN
                    FAILED ("IMPROPER DISCRIMINANT VALUE - ACCESS");
               END IF;

               IF NOT EQUAL(NEW_VAR.D,5) THEN
                    FAILED ("IMPROPER DISCRIMINANT VALUE - DERIVED");
               END IF;

               IF NOT BOOL THEN
                    FAILED ("IMPROPER RESULT FROM MEMBERSHIP TEST");
               END IF;
          END P;

          PACKAGE NEW_P IS NEW P (REC,REC_VAR);

     BEGIN
          NULL;
     END;

     RESULT;
END CC1207B;
