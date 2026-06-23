-- C38107A.ADA

-- OBJECTIVE:
--     FOR AN INCOMPLETE TYPE WITH DISCRIMINANTS DECLARED IN THE
--     VISIBLE PART OF A PACKAGE OR IN A DECLARATIVE PART, CHECK THAT
--     CONSTRAINT_ERROR IS RAISED IF A DISCRIMINANT CONSTRAINT IS
--     SPECIFIED FOR THE TYPE AND ONE OF THE DISCRIMINANT VALUES DOES
--     NOT BELONG TO THE CORRESPONDING DISCRIMINANT'S SUBTYPE.

-- HISTORY:
--     BCB 01/21/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C38107A IS

BEGIN
     TEST ("C38107A", "FOR AN INCOMPLETE TYPE WITH DISCRIMINANTS " &
                      "DECLARED IN THE VISIBLE PART OF A PACKAGE OR " &
                      "IN A DECLARATIVE PART, CHECK THAT CONSTRAINT_" &
                      "ERROR IS RAISED IF A DISCRIMINANT CONSTRAINT " &
                      "IS SPECIFIED FOR THE TYPE AND ONE OF THE " &
                      "DISCRIMINANT VALUES DOES NOT BELONG TO THE " &
                      "CORRESPONDING DISCRIMINANT'S SUBTYPE");

     BEGIN
          DECLARE
               PACKAGE P IS
                    SUBTYPE INT6 IS INTEGER RANGE 1 .. 6;
                    TYPE T_INT6 (D6 : INT6);
                    TYPE TEST IS ACCESS T_INT6(7);  -- CONSTRAINT_ERROR.
                    TYPE T_INT6 (D6 : INT6) IS
                         RECORD
                              NULL;
                         END RECORD;
               END P;
               USE P;
          BEGIN
               FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 1");
               DECLARE
                    T : P.TEST := NEW T_INT6(7);
               BEGIN
                    IF EQUAL(T.D6, T.D6) THEN
                         COMMENT ("DON'T OPTIMIZE T.D6");
                    END IF;
               END;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 1");
     END;

     BEGIN
          DECLARE
               SUBTYPE INT7 IS INTEGER RANGE 1 .. 7;
               TYPE T_INT7 (D7 : INT7);
               TYPE TEST IS ACCESS T_INT7(8);       -- CONSTRAINT_ERROR.
               TYPE T_INT7 (D7 : INT7) IS
                    RECORD
                         NULL;
                    END RECORD;
          BEGIN
               FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 2");
               DECLARE
                    T : TEST := NEW T_INT7(6);
               BEGIN
                    IF EQUAL(T.D7, T.D7) THEN
                         COMMENT ("DON'T OPTIMIZE T.D7");
                    END IF;
               END;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                       "WAS RAISED - 2");
     END;
     RESULT;
END C38107A;
