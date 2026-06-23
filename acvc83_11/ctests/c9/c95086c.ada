-- C95086C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS NOT RAISED FOR ACCESS PARAMETERS
--   AFTER THE ENTRY CALL, WHEN AN IN OUT OR OUT FORMAL
--   ACCESS VALUE IS NULL, AND THE ACTUAL PARAMETER HAS
--   DIFFERENT CONSTRAINTS.
--
--   SUBTESTS ARE:
--       (A) IN OUT MODE, STATIC PRIVATE DISCRIMINANT.
--       (B) OUT MODE, DYNAMIC TWO DIMENSIONAL BOUNDS.
--       (C) SAME AS (A), WITH TYPE CONVERSION.
--       (D) SAME AS (B), WITH TYPE CONVERSION.

-- RJW 1/29/86

WITH REPORT; USE REPORT;
PROCEDURE C95086C IS

BEGIN
     TEST ("C95086C", "CHECK THAT CONSTRAINT_ERROR IS NOT RAISED " &
           "AFTER THE ENTRY CALL, WHEN AN IN OUT OR OUT FORMAL " &
           "ACCESS VALUE IS NULL, AND THE ACTUAL PARAMETER HAS " &
           "DIFFERENT CONSTRAINTS" );

     --------------------------------------------------

     DECLARE -- (A)

          PACKAGE PKG IS
               TYPE E IS (E1, E2);
               TYPE T (D : E := E1) IS PRIVATE;
          PRIVATE
               TYPE T (D : E := E1) IS
                    RECORD
                         I : INTEGER;
                         CASE D IS
                              WHEN E1 =>
                                   B : BOOLEAN;
                              WHEN E2 =>
                                   C : CHARACTER;
                         END CASE;
                    END RECORD;
          END PKG;

          USE PKG;

          TYPE A IS ACCESS T;
          SUBTYPE SA IS A (E2);
          V : A (E1) := NULL;
          ENTERED : BOOLEAN := FALSE;

          TASK T1 IS
               ENTRY P (X : IN OUT SA);
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT P (X : IN OUT SA) DO
                    ENTERED := TRUE;
                    X := NULL;
               END P;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (A)");
          END T1;

     BEGIN -- (A)

          T1.P (V);

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT ENTERED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (A)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (A)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (A)");
     END; -- (A)

     --------------------------------------------------

     DECLARE -- (B)

          TYPE T IS ARRAY (CHARACTER RANGE <>, BOOLEAN RANGE <>) OF
                    INTEGER;

          TYPE A IS ACCESS T;
          SUBTYPE SA IS A ('D'..'F', FALSE..FALSE);
          V : A (IDENT_CHAR('A') .. IDENT_CHAR('B'),
                 IDENT_BOOL(TRUE) .. IDENT_BOOL(TRUE)) := NULL;
          ENTERED : BOOLEAN := FALSE;

          TASK T1 IS
               ENTRY P (X : OUT SA);
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT P (X : OUT SA) DO
                    ENTERED := TRUE;
                    X := NULL;
               END P;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (B)");
          END T1;

     BEGIN -- (B)

          T1.P (V);

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT ENTERED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (B)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (B)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (B)");
     END; -- (B)

     --------------------------------------------------

     DECLARE -- (C)

          PACKAGE PKG IS
               TYPE E IS (E1, E2);
               TYPE T (D : E := E1) IS PRIVATE;
          PRIVATE
               TYPE T (D : E := E1) IS
                    RECORD
                         I : INTEGER;
                         CASE D IS
                              WHEN E1 =>
                                   B : BOOLEAN;
                              WHEN E2 =>
                                   C : CHARACTER;
                         END CASE;
                    END RECORD;
          END PKG;

          USE PKG;

          TYPE A IS ACCESS T;
          SUBTYPE SA IS A (E2);
          V : A (E1) := NULL;
          ENTERED : BOOLEAN := FALSE;

          TASK T1 IS
               ENTRY P (X : IN OUT SA);
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT P (X : IN OUT SA) DO
                    ENTERED := TRUE;
                    X := NULL;
               END P;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (C)");
          END T1;

     BEGIN -- (C)

          T1.P (SA(V));

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT ENTERED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (C)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (C)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (C)");
     END; -- (C)

     --------------------------------------------------

     DECLARE -- (D)

          TYPE T IS ARRAY (CHARACTER RANGE <>, BOOLEAN RANGE <>) OF
                    INTEGER;

          TYPE A IS ACCESS T;
          SUBTYPE SA IS A ('D'..'F', FALSE..FALSE);
          V : A (IDENT_CHAR('A') .. IDENT_CHAR('B'),
                 IDENT_BOOL(TRUE) .. IDENT_BOOL(TRUE)) := NULL;
          ENTERED : BOOLEAN := FALSE;

          TASK T1 IS
               ENTRY P (X : OUT SA);
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT P (X : OUT SA) DO
                    ENTERED := TRUE;
                    X := NULL;
               END P;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (D)");
          END T1;

     BEGIN -- (D)

          T1.P (SA(V));

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT ENTERED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (D)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (D)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (D)");
     END; -- (D)

     --------------------------------------------------

     RESULT;
END C95086C;
