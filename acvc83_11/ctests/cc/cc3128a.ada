-- CC3128A.ADA

-- OBJECTIVE:
--     FOR A CONSTRAINED IN FORMAL PARAMETER HAVING AN ACCESS TYPE,
--     CONSTRAINT_ERROR IS  RAISED IF AND ONLY IF THE ACTUAL PARAMETER
--     IS NOT NULL AND THE OBJECT DESIGNATED BY ACTUAL PARAMETER DOES
--     NOT SATISFY THE FORMAL PARAMETER'S CONSTRAINTS.

-- HISTORY:
--     RJW 10/28/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CC3128A IS

BEGIN
     TEST ("CC3128A", "FOR A CONSTRAINED IN FORMAL PARAMETER HAVING " &
                      "AN ACCESS TYPE, CONSTRAINT_ERROR IS RAISED " &
                      "IF AND ONLY IF THE ACTUAL PARAMETER IS NOT " &
                      "NULL AND THE OBJECT DESIGNATED BY ACTUAL " &
                      "PARAMETER DOES NOT SATISFY FORMAL PARAMETER'S " &
                      "CONSTRAINTS");

     DECLARE
          TYPE REC (D : INTEGER := 10) IS
               RECORD
                    NULL;
               END RECORD;

          SUBTYPE SUBREC5 IS REC (5);

          TYPE ACCREC IS ACCESS REC;

          SUBTYPE ACCREC5 IS ACCREC (5);
          SUBTYPE ACCREC10 IS ACCREC (IDENT_INT (10));
          SUBTYPE LINK IS ACCREC (5);

          GENERIC
               TYPE LINK IS ACCESS SUBREC5;
               LINK1 : IN LINK;
          PROCEDURE P (I : IN OUT INTEGER);

          PROCEDURE P (I : IN OUT INTEGER) IS
          BEGIN
               IF I = 5 THEN
                    I := IDENT_INT (6);
               ELSE
                    FAILED ("CONSTRAINT_ERROR NOT RAISED PRIOR " &
                            "TO CALL TO PROCEDURE P - 1");
               END IF;
               IF NOT EQUAL (I, 6) AND THEN
                  NOT EQUAL (LINK1.D, LINK1.D) THEN
                    COMMENT ("DISREGARD");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED WITHIN PROCEDURE P - 1");
          END P;

          GENERIC
               LINK1 : LINK;
          FUNCTION F (I : INTEGER) RETURN INTEGER;

          FUNCTION F (I : INTEGER) RETURN INTEGER IS
          BEGIN
               IF I /= 5 THEN
                    FAILED ("CONSTRAINT_ERROR NOT RAISED PRIOR " &
                            "TO CALL TO FUNCTION F - 1");
               END IF;
               IF NOT EQUAL (I, 5) AND THEN
                  NOT EQUAL (LINK1.D, LINK1.D) THEN
                    COMMENT ("DISREGARD");
               END IF;
               RETURN I + 1;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED WITHIN FUNCTION F - 1");
               RETURN I + 1;
          END F;

          GENERIC
               TYPE PRIV (D : INTEGER) IS PRIVATE;
               PRIV1 : PRIV;
          PACKAGE GEN IS
               TYPE ACCPRIV IS ACCESS PRIV;
               SUBTYPE LINK IS ACCPRIV (5);
               GENERIC
                    LINK1 : LINK;
                    I : IN OUT INTEGER;
               PACKAGE P IS END P;
          END GEN;

          PACKAGE BODY GEN IS
               PACKAGE BODY P IS
               BEGIN
                    IF I /= 5 THEN
                         FAILED ("CONSTRAINT_ERROR NOT RAISED PRIOR " &
                                 "TO PACKAGE BODY P - 1");
                    END IF;
                    IF NOT EQUAL (I, 5) AND THEN
                       NOT EQUAL (LINK1.D, LINK1.D) THEN
                         COMMENT ("DISREGARD");
                    END IF;
                    I := I + 1;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED WITHIN " &
                                 "PACKAGE P - 1");
                    I := I + 1;
               END P;

          BEGIN
               BEGIN
                    DECLARE
                         AR10 : ACCPRIV;
                         I : INTEGER := IDENT_INT (5);
                         PACKAGE P1 IS NEW P (AR10, I);
                    BEGIN
                         IF I /= 6 THEN
                              FAILED ("INCORRECT RESULT - " &
                                      "PACKAGE P1");
                         END IF;
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("EXCEPTION RAISED TOO LATE - " &
                                      "PACKAGE P1 - 1");
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT INSTANTIATION " &
                                 "OF PACKAGE P1 WITH NULL ACCESS " &
                                 "VALUE");
               END;

               BEGIN
                    DECLARE
                         AR10 : ACCPRIV := NEW PRIV'(PRIV1);
                         I : INTEGER := IDENT_INT (0);
                         PACKAGE P1 IS NEW P (AR10, I);
                    BEGIN
                         FAILED ("NO EXCEPTION RAISED BY " &
                                 "INSTANTIATION OF PACKAGE P1");
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("EXCEPTION RAISED TOO LATE - " &
                                      "PACKAGE P1 - 2");
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED AT " &
                                 "INSTANTIATION OF PACKAGE P1");
               END;
          END GEN;

          PACKAGE NEWGEN IS NEW GEN (REC, (D => 10));

     BEGIN
          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (5);
                    AR10 : ACCREC10;
                    PROCEDURE P1 IS NEW P (ACCREC5, AR10);
               BEGIN
                    P1 (I);
                    IF I /= 6 THEN
                         FAILED ("INCORRECT RESULT RETURNED BY " &
                                 "PROCEDURE P1");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "PROCEDURE P1 - 1");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT INSTANTIATION OF " &
                            "PROCEDURE P1 WITH NULL ACCESS VALUE");
          END;

          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (0);
                    AR10 : ACCREC10 := NEW REC'(D => IDENT_INT (10));
                    PROCEDURE P1 IS NEW P (ACCREC5, AR10);
               BEGIN
                    FAILED ("NO EXCEPTION RAISED BY INSTANTIATION " &
                            "OF PROCEDURE P1");
                    P1 (I);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "PROCEDURE P1 - 2");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED AT " &
                            "INSTANTIATION OF PROCEDURE P1");
          END;

          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (5);
                    AR10 : ACCREC;
                    FUNCTION F1 IS NEW F (AR10);
               BEGIN
                    I := F1 (I);
                    IF I /= 6 THEN
                         FAILED ("INCORRECT RESULT RETURNED BY " &
                                 "FUNCTION F1");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "FUNCTION F1 - 1");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT INSTANTIATION OF " &
                            "FUNCTION F1 WITH NULL ACCESS VALUE");
          END;

          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (0);
                    AR10 : ACCREC := NEW REC'(D => 10);
                    FUNCTION F1 IS NEW F (AR10);
               BEGIN
                    FAILED ("NO EXCEPTION RAISED BY INSTANTIATION " &
                            "OF FUNCTION F1");
                    I := F1 (I);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "FUNCTION F1 - 2");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED AT " &
                            "INSTANTIATION OF FUNCTION F1");
          END;
     END;

     DECLARE
          TYPE ARR IS ARRAY (POSITIVE RANGE <>) OF INTEGER;

          SUBTYPE SUBARR15 IS ARR (1 .. 5);

          TYPE ACCARR IS ACCESS ARR;

          SUBTYPE ACCARR15 IS ACCARR (1 .. 5);
          SUBTYPE ACCARR26 IS ACCARR (IDENT_INT (2) .. IDENT_INT (6));
          SUBTYPE LINK IS ACCARR (1 .. 5);

          GENERIC
               TYPE LINK IS ACCESS SUBARR15;
               LINK1 : IN LINK;
          PROCEDURE P (I : IN OUT INTEGER);

          PROCEDURE P (I : IN OUT INTEGER) IS
          BEGIN
               IF I = 5 THEN
                    I := IDENT_INT (6);
               ELSE
                    FAILED ("CONSTRAINT_ERROR NOT RAISED PRIOR " &
                            "TO CALL TO PROCEDURE P - 2");
               END IF;
               IF NOT EQUAL (I, 6) AND THEN
                  NOT EQUAL (LINK1(IDENT_INT (3)), LINK1(IDENT_INT (3)))
                  THEN
                    COMMENT ("DISREGARD");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED WITHIN PROCEDURE P - 2");
          END P;

          GENERIC
               LINK1 : LINK;
          FUNCTION F (I : INTEGER) RETURN INTEGER;

          FUNCTION F (I : INTEGER) RETURN INTEGER IS
          BEGIN
               IF I /= 5 THEN
                    FAILED ("CONSTRAINT_ERROR NOT RAISED PRIOR " &
                            "TO CALL TO FUNCTION F - 2");
               END IF;
               IF NOT EQUAL (I, 5) AND THEN
                  NOT EQUAL (LINK1(IDENT_INT (3)),LINK1(IDENT_INT (3)))
                  THEN
                    COMMENT ("DISREGARD");
               END IF;
               RETURN I + 1;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED WITHIN FUNCTION F - 2");
               RETURN I + 1;
          END F;

          GENERIC
               TYPE GENARR IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
          PACKAGE GEN IS
               TYPE ACCGENARR IS ACCESS GENARR;
               SUBTYPE LINK IS ACCGENARR (1 .. 5);
               GENERIC
                    LINK1 : LINK;
                    I : IN OUT INTEGER;
               PACKAGE P IS END P;
          END GEN;

          PACKAGE BODY GEN IS
               PACKAGE BODY P IS
               BEGIN
                    IF I /= 5 THEN
                         FAILED ("CONSTRAINT_ERROR NOT RAISED PRIOR " &
                                 "TO PACKAGE BODY P - 2");
                    END IF;
                    IF NOT EQUAL (I, 5) AND THEN
                       NOT
                       EQUAL(LINK1(IDENT_INT (3)),LINK1(IDENT_INT (3)))
                       THEN
                         COMMENT ("DISREGARD");
                    END IF;
                    I := I + 1;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED WITHIN " &
                                 "PACKAGE P - 2");
                    I := I + 1;
               END P;

          BEGIN
               BEGIN
                    DECLARE
                         AR26 : ACCGENARR (2 .. 6);
                         I : INTEGER := IDENT_INT (5);
                         PACKAGE P2 IS NEW P (AR26, I);
                    BEGIN
                         IF I /= 6 THEN
                              FAILED ("INCORRECT RESULT - " &
                                      "PACKAGE P2");
                         END IF;
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("EXCEPTION RAISED TOO LATE - " &
                                      "PACKAGE P2 - 1");
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT INSTANTIATION " &
                                 "OF PACKAGE P2 WITH NULL ACCESS " &
                                 "VALUE");
               END;

               BEGIN
                    DECLARE
                         AR26 : ACCGENARR
                                (IDENT_INT (2) .. IDENT_INT (6)) :=
                                NEW GENARR'(1,2,3,4,5);
                         I : INTEGER := IDENT_INT (0);
                         PACKAGE P2 IS NEW P (AR26, I);
                    BEGIN
                         FAILED ("NO EXCEPTION RAISED BY " &
                                 "INSTANTIATION OF PACKAGE P2");
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("EXCEPTION RAISED TOO LATE - " &
                                      "PACKAGE P2 - 2");
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED AT " &
                                 "INSTANTIATION OF PACKAGE P2");
               END;
          END GEN;

          PACKAGE NEWGEN IS NEW GEN (ARR);

     BEGIN
          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (5);
                    AR26 : ACCARR26;
                    PROCEDURE P2 IS NEW P (ACCARR15, AR26);
               BEGIN
                    P2 (I);
                    IF I /= 6 THEN
                         FAILED ("INCORRECT RESULT RETURNED BY " &
                                 "PROCEDURE P2");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "PROCEDURE P2 - 1");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT INSTANTIATION OF " &
                            "PROCEDURE P2 WITH NULL ACCESS VALUE");
          END;

          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (0);
                    AR26 : ACCARR26 := NEW ARR'(1,2,3,4,5);
                    PROCEDURE P2 IS NEW P (ACCARR15, AR26);
               BEGIN
                    FAILED ("NO EXCEPTION RAISED BY INSTANTIATION " &
                            "OF PROCEDURE P2");
                    P2 (I);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "PROCEDURE P2 - 2");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED AT " &
                            "INSTANTIATION OF PROCEDURE P2");
          END;

          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (5);
                    AR26 : ACCARR (IDENT_INT (2) .. IDENT_INT (6));
                    FUNCTION F2 IS NEW F (AR26);
               BEGIN
                    I := F2 (I);
                    IF I /= 6 THEN
                         FAILED ("INCORRECT RESULT RETURNED BY " &
                                 "FUNCTION F2");
                    END IF;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "FUNCTION F2 - 1");
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED AT INSTANTIATION OF " &
                            "FUNCTION F2 WITH NULL ACCESS VALUE");
          END;

          BEGIN
               DECLARE
                    I : INTEGER := IDENT_INT (0);
                    AR26 : ACCARR (2 .. 6) := NEW ARR'(1,2,3,4,5);
                    FUNCTION F2 IS NEW F (AR26);
               BEGIN
                    FAILED ("NO EXCEPTION RAISED BY INSTANTIATION " &
                            "OF FUNCTION F2");
                    I := F2 (I);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED AT CALL TO " &
                                 "FUNCTION F2 - 2");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED AT " &
                            "INSTANTIATION OF FUNCTION F2");
          END;
     END;
     RESULT;
END CC3128A;
