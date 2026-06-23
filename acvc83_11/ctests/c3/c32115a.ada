-- C32115A.ADA

-- OBJECTIVE:
--    CHECK THAT WHEN A VARIABLE OR CONSTANT HAVING A CONSTRAINED
--    ACCESS TYPE IS DECLARED WITH AN INITIAL NON-NULL ACCESS VALUE,
--    CONSTRAINT_ERROR IS RAISED IF AN INDEX BOUND OR A DISCRIMINANT
--    VALUE OF THE DESIGNATED OBJECT DOES NOT EQUAL THE CORRESPONDING
--    VALUE SPECIFIED FOR THE ACCESS SUBTYPE.

-- HISTORY:
--    RJW 07/20/86  CREATED ORIGINAL TEST.
--    JET 08/05/87  ADDED DEFEAT OF DEAD VARIABLE OPTIMIZATION.

WITH REPORT; USE REPORT;

PROCEDURE C32115A IS

     PACKAGE PKG IS
          TYPE PRIV (D : INTEGER) IS PRIVATE;

     PRIVATE
          TYPE PRIV (D : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;
     END PKG;

     USE PKG;

     TYPE ACCP IS ACCESS PRIV (IDENT_INT (1));

     TYPE REC (D : INTEGER) IS
          RECORD
               NULL;
          END RECORD;

     TYPE ACCR IS ACCESS REC (IDENT_INT (2));

     TYPE ARR IS ARRAY (NATURAL RANGE <>) OF INTEGER;

     TYPE ACCA IS ACCESS ARR (IDENT_INT (1) .. IDENT_INT (2));

     TYPE ACCN IS ACCESS ARR (IDENT_INT (1) .. IDENT_INT (0));

BEGIN
     TEST ("C32115A", "CHECK THAT WHEN A VARIABLE OR CONSTANT " &
                      "HAVING A CONSTRAINED ACCESS TYPE IS " &
                      "DECLARED WITH AN INITIAL NON-NULL ACCESS " &
                      "VALUE, CONSTRAINT_ERROR IS RAISED IF AN " &
                      "INDEX BOUND OR A DISCRIMINANT VALUE OF THE " &
                      "DESIGNATED OBJECT DOES NOT EQUAL THE " &
                      "CORRESPONDING VALUE SPECIFIED FOR THE " &
                      "ACCESS SUBTYPE" );

     BEGIN
          DECLARE
               AC1 : CONSTANT ACCP := NEW PRIV (D => (IDENT_INT (2)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC1'" );
               IF AC1 /= NULL THEN
                    COMMENT ("DEFEAT 'AC1' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC1'" );
     END;

     BEGIN
          DECLARE
               AC2 : ACCP := NEW PRIV (D => (IDENT_INT (2)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC2'" );
               IF AC2 /= NULL THEN
                    COMMENT ("DEFEAT 'AC2' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC2'" );
     END;

     BEGIN
          DECLARE
               AC3 : CONSTANT ACCP := NEW PRIV (D => (IDENT_INT (0)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC3'" );
               IF AC3 /= NULL THEN
                    COMMENT ("DEFEAT 'AC3' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC3'" );
     END;

     BEGIN
          DECLARE
               AC4 : ACCP := NEW PRIV (D => (IDENT_INT (0)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC4'" );
               IF AC4 /= NULL THEN
                    COMMENT ("DEFEAT 'AC4' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC4'" );
     END;

     BEGIN
          DECLARE
               AC5 : CONSTANT ACCR := NEW REC'(D => (IDENT_INT (1)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC5'" );
               IF AC5 /= NULL THEN
                    COMMENT ("DEFEAT 'AC5' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC5'" );
     END;

     BEGIN
          DECLARE
               AC6 : ACCR := NEW REC' (D => (IDENT_INT (1)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC6'" );
               IF AC6 /= NULL THEN
                    COMMENT ("DEFEAT 'AC6' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC6'" );
     END;

     BEGIN
          DECLARE
               AC7 : CONSTANT ACCR := NEW REC'(D => (IDENT_INT (3)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC7'" );
               IF AC7 /= NULL THEN
                    COMMENT ("DEFEAT 'AC7' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC7'" );
     END;

     BEGIN
          DECLARE
               AC8 : ACCR := NEW REC' (D => (IDENT_INT (3)));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC8'" );
               IF AC8 /= NULL THEN
                    COMMENT ("DEFEAT 'AC8' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC8'" );
     END;

     BEGIN
          DECLARE
               AC9 : CONSTANT ACCA :=
                    NEW ARR'(IDENT_INT (1) .. IDENT_INT (1) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC9'" );
               IF AC9 /= NULL THEN
                    COMMENT ("DEFEAT 'AC9' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC9'" );
     END;

     BEGIN
          DECLARE
               AC10 : ACCA :=
                    NEW ARR'(IDENT_INT (1) .. IDENT_INT (1) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC10'" );
               IF AC10 /= NULL THEN
                    COMMENT ("DEFEAT 'AC10' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC10'" );
     END;

     BEGIN
          DECLARE
               AC11 : CONSTANT ACCA :=
                    NEW ARR' (IDENT_INT (0) .. IDENT_INT (2) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC11'" );
               IF AC11 /= NULL THEN
                    COMMENT ("DEFEAT 'AC11' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC11'" );
     END;

     BEGIN
          DECLARE
               AC12 : ACCA :=
                    NEW ARR'(IDENT_INT (0) .. IDENT_INT (2) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC12'" );
               IF AC12 /= NULL THEN
                    COMMENT ("DEFEAT 'AC12' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC12'" );
     END;

     BEGIN
          DECLARE
               AC13 : CONSTANT ACCA :=
                    NEW ARR' (IDENT_INT (2) .. IDENT_INT (3) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC13'" );
               IF AC13 /= NULL THEN
                    COMMENT ("DEFEAT 'AC13' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC13'" );
     END;

     BEGIN
          DECLARE
               AC14 : ACCA :=
                    NEW ARR'(IDENT_INT (2) .. IDENT_INT (3) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC14'" );
               IF AC14 /= NULL THEN
                    COMMENT ("DEFEAT 'AC14' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC14'" );
     END;

     BEGIN
          DECLARE
               AC15 : CONSTANT ACCN :=
                    NEW ARR' (IDENT_INT (0) .. IDENT_INT (0) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC15'" );
               IF AC15 /= NULL THEN
                    COMMENT ("DEFEAT 'AC15' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'AC15'" );
     END;

     BEGIN
          DECLARE
               AC16 : ACCN :=
                    NEW ARR'(IDENT_INT (0) .. IDENT_INT (0) => 0);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC16'" );
               IF AC16 /= NULL THEN
                    COMMENT ("DEFEAT 'AC16' OPTIMIZATION");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'AC16'" );
     END;

     RESULT;
END C32115A;
