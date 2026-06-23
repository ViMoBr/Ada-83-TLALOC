-- C34007J.ADA

-- OBJECTIVE:
--     CHECK THAT THE REQUIRED PREDEFINED OPERATIONS ARE DECLARED
--     (IMPLICITLY) FOR DERIVED ACCESS TYPES WHOSE DESIGNATED TYPE
--     IS A TASK TYPE.

-- HISTORY:
--     JRK 09/26/86  CREATED ORIGINAL TEST.
--     JLH 09/25/87  REFORMATTED HEADER.
--     BCB 09/26/88  REMOVED COMPARISION INVOLVING OBJECT SIZE.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;

PROCEDURE C34007J IS

     TASK TYPE DESIGNATED IS
          ENTRY E (I : IN OUT INTEGER);
          ENTRY F (1 .. 3) (I : INTEGER; J : OUT INTEGER);
          ENTRY R (I : OUT INTEGER);
          ENTRY W (I : INTEGER);
     END DESIGNATED;

     TYPE PARENT IS ACCESS DESIGNATED;

     TYPE T IS NEW PARENT;

     X : T;
     K : INTEGER := X'SIZE;
     Y : T;
     W : PARENT;
     B : BOOLEAN := FALSE;
     I : INTEGER := 0;
     J : INTEGER := 0;

     PROCEDURE A (X : ADDRESS) IS
     BEGIN
          B := IDENT_BOOL (TRUE);
     END A;

     FUNCTION V RETURN T IS
     BEGIN
          RETURN NEW DESIGNATED;
     END V;

     FUNCTION IDENT (X : T) RETURN T IS
     BEGIN
          IF (X = NULL OR ELSE X'CALLABLE) OR IDENT_BOOL (TRUE) THEN
               RETURN X;                          -- ALWAYS EXECUTED.
          END IF;
          RETURN NEW DESIGNATED;
     END IDENT;

     TASK BODY DESIGNATED IS
          N : INTEGER := 1;
     BEGIN
          LOOP
               SELECT
                    ACCEPT E (I : IN OUT INTEGER) DO
                         I := I + N;
                    END E;
               OR
                    ACCEPT F (2) (I : INTEGER; J : OUT INTEGER) DO
                         J := I + N;
                    END F;
               OR
                    ACCEPT R (I : OUT INTEGER) DO
                         I := N;
                    END R;
               OR
                    ACCEPT W (I : INTEGER) DO
                         N := I;
                    END W;
               OR
                    TERMINATE;
               END SELECT;
          END LOOP;
     END DESIGNATED;

BEGIN
     TEST ("C34007J", "CHECK THAT THE REQUIRED PREDEFINED OPERATIONS " &
                      "ARE DECLARED (IMPLICITLY) FOR DERIVED " &
                      "ACCESS TYPES WHOSE DESIGNATED TYPE IS A " &
                      "TASK TYPE");

     X := NEW DESIGNATED;
     Y := NEW DESIGNATED;
     W := NEW DESIGNATED;

     IF Y = NULL THEN
          FAILED ("INCORRECT INITIALIZATION - 1");
     ELSE Y.W (2);
          Y.R (I);
          IF I /= 2 THEN
               FAILED ("INCORRECT INITIALIZATION - 2");
          END IF;
     END IF;

     X := IDENT (Y);
     IF X /= Y THEN
          FAILED ("INCORRECT :=");
     END IF;

     IF T'(X) /= Y THEN
          FAILED ("INCORRECT QUALIFICATION");
     END IF;

     IF T (X) /= Y THEN
          FAILED ("INCORRECT SELF CONVERSION");
     END IF;

     IF EQUAL (3, 3) THEN
          W := NEW DESIGNATED;
          W.W (3);
     END IF;
     X := T (W);
     IF X = NULL OR X = Y THEN
          FAILED ("INCORRECT CONVERSION FROM PARENT - 1");
     ELSE I := 5;
          X.E (I);
          IF I /= 8 THEN
               FAILED ("INCORRECT CONVERSION FROM PARENT - 2");
          END IF;
     END IF;

     X := IDENT (Y);
     W := PARENT (X);
     IF W = NULL OR T (W) /= Y THEN
          FAILED ("INCORRECT CONVERSION TO PARENT - 1");
     ELSE I := 5;
          W.E (I);
          IF I /= 7 THEN
               FAILED ("INCORRECT CONVERSION TO PARENT - 2");
          END IF;
     END IF;

     IF IDENT (NULL) /= NULL OR X = NULL THEN
          FAILED ("INCORRECT NULL");
     END IF;

     X := IDENT (NEW DESIGNATED);
     IF X = NULL OR X = Y THEN
          FAILED ("INCORRECT ALLOCATOR - 1");
     ELSE I := 5;
          X.E (I);
          IF I /= 6 THEN
               FAILED ("INCORRECT ALLOCATOR - 2");
          END IF;
     END IF;

     X := IDENT (Y);
     I := 5;
     X.E (I);
     IF I /= 7 THEN
          FAILED ("INCORRECT SELECTION (ENTRY)");
     END IF;

     I := 5;
     X.F (IDENT_INT (2)) (I, J);
     IF J /= 7 THEN
          FAILED ("INCORRECT SELECTION (FAMILY)");
     END IF;

     I := 5;
     X.ALL.E (I);
     IF I /= 7 THEN
          FAILED ("INCORRECT .ALL");
     END IF;

     X := IDENT (NULL);
     BEGIN
          IF X.ALL'CALLABLE THEN
               FAILED ("NO EXCEPTION FOR NULL.ALL - 1");
          ELSE FAILED ("NO EXCEPTION FOR NULL.ALL - 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION FOR NULL.ALL");
     END;

     X := IDENT (Y);
     IF X = NULL OR X = NEW DESIGNATED OR NOT (X = Y) THEN
          FAILED ("INCORRECT =");
     END IF;

     IF X /= Y OR NOT (X /= NULL) THEN
          FAILED ("INCORRECT /=");
     END IF;

     IF NOT (X IN T) THEN
          FAILED ("INCORRECT ""IN""");
     END IF;

     IF X NOT IN T THEN
          FAILED ("INCORRECT ""NOT IN""");
     END IF;

     B := FALSE;
     A (X'ADDRESS);
     IF NOT B THEN
          FAILED ("INCORRECT 'ADDRESS");
     END IF;

     IF T'BASE'SIZE < 1 THEN
          FAILED ("INCORRECT 'BASE'SIZE");
     END IF;

     IF NOT X'CALLABLE THEN
          FAILED ("INCORRECT OBJECT'CALLABLE");
     END IF;

     IF NOT V'CALLABLE THEN
          FAILED ("INCORRECT VALUE'CALLABLE");
     END IF;

     IF T'SIZE /= T'BASE'SIZE THEN
          FAILED ("INCORRECT TYPE'SIZE");
     END IF;

     IF T'STORAGE_SIZE /= PARENT'STORAGE_SIZE THEN
          FAILED ("INCORRECT 'STORAGE_SIZE");
     END IF;

     IF X'TERMINATED THEN
          FAILED ("INCORRECT OBJECT'TERMINATED");
     END IF;

     IF V'TERMINATED THEN
          FAILED ("INCORRECT VALUE'TERMINATED");
     END IF;

     RESULT;
END C34007J;
