-- C83026A.ADA

-- OBJECTIVE:
--     CHECK THAT A DECLARATION IN AN ENTRY FORMAL PART OR THE
--     CORRESPONDING ACCEPT STATEMENT BODY HIDES AN OUTER DECLARATION OF
--     A HOMOGRAPH. ALSO CHECK THAT THE OUTER DECLARATION IS DIRECTLY
--     VISIBLE IN BOTH DECLARATIVE REGIONS BEFORE THE DECLARATION OF THE
--     INNER HOMOGRAPH AND THE OUTER DECLARATION IS VISIBLE BY SELECTION
--     AFTER THE INNER HOMOGRAPH DECLARATION.

-- HISTORY:
--     BCB 09/01/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C83026A IS

     GENERIC
          TYPE T IS PRIVATE;
          X : T;
     FUNCTION GEN_FUN RETURN T;

     FUNCTION GEN_FUN RETURN T IS
     BEGIN
          RETURN X;
     END GEN_FUN;

BEGIN
     TEST ("C83026A", "CHECK THAT A DECLARATION IN AN ENTRY FORMAL " &
                      "PART OR THE CORRESPONDING ACCEPT STATEMENT " &
                      "BODY HIDES AN OUTER DECLARATION OF A HOMOGRAPH");

     ONE:
     DECLARE
          A : INTEGER := IDENT_INT(2);
          B : INTEGER := A;

          TASK INNER IS
               ENTRY HERE (X : IN OUT INTEGER;
                           C : INTEGER := ONE.A;
                           A : INTEGER := IDENT_INT(3));
          END INNER;

          TASK BODY INNER IS
          BEGIN
               ACCEPT HERE (X : IN OUT INTEGER;
                            C : INTEGER := A;
                            A : INTEGER := IDENT_INT(3)) DO
                    IF A /= IDENT_INT(3) THEN
                         FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH" &
                                 " - 1");
                    END IF;

                    IF ONE.A /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH" &
                                 " - 2");
                    END IF;

                    IF ONE.B /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE FOR OUTER VARIABLE " &
                                 "- 3");
                    END IF;

                    IF C /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE FOR INNER VARIABLE " &
                                 "- 4");
                    END IF;

                    IF X /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE PASSED IN - 5");
                    END IF;

                    IF EQUAL(1,1) THEN
                         X := A;
                    ELSE
                         X := ONE.A;
                    END IF;
               END HERE;
          END INNER;

     BEGIN  -- ONE
          INNER.HERE(A);

          IF A /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 6");
          END IF;
     END ONE;

     TWO:
     DECLARE            -- AFTER THE SPECIFICATION OF TASK.
          A : INTEGER := IDENT_INT(2);

          TASK INNER IS
               ENTRY HERE (X : IN OUT INTEGER;
                           C : INTEGER := A;
                           A : INTEGER := IDENT_INT(3));
          END INNER;

          B : INTEGER := A;

          TASK BODY INNER IS
          BEGIN
               ACCEPT HERE (X : IN OUT INTEGER;
                            C : INTEGER := A;
                            A : INTEGER := IDENT_INT(3)) DO
                    IF A /= IDENT_INT(3) THEN
                         FAILED ("INCORRECT VALUE FOR INNER HOMOGRAPH" &
                                 " - 10");
                    END IF;

                    IF TWO.A /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE FOR OUTER HOMOGRAPH" &
                                 " - 11");
                    END IF;

                    IF TWO.B /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE FOR OUTER VARIABLE " &
                                 "- 12");
                    END IF;

                    IF C /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE FOR INNER VARIABLE " &
                                 "- 13");
                    END IF;

                    IF X /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT VALUE PASSED IN - 14");
                    END IF;

                    IF EQUAL(1,1) THEN
                         X := A;
                    ELSE
                         NULL;
                    END IF;
               END HERE;
          END INNER;

     BEGIN  -- TWO
          INNER.HERE(A);

          IF A /= IDENT_INT(3) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 15");
          END IF;
     END TWO;

     THREE:
     DECLARE                              -- RENAMING DECLARATION.
          A : INTEGER := IDENT_INT(2);

          TASK TEMPLATE IS
               ENTRY HERE (X : IN INTEGER := A;
                           Y : IN OUT INTEGER);
          END TEMPLATE;

          PROCEDURE INNER (Z : IN INTEGER := A;
                           A : IN OUT INTEGER) RENAMES TEMPLATE.HERE;

          B : INTEGER := A;
          OBJ : INTEGER := 5;

          TASK BODY TEMPLATE IS
          BEGIN  -- TEMPLATE
               ACCEPT HERE (X : IN INTEGER := A;
                            Y : IN OUT INTEGER) DO
                    IF X /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT RESULTS FOR VARIABLE - 20");
                    END IF;

                    IF Y /= IDENT_INT(5) THEN
                         FAILED ("INCORRECT RESULTS FOR VARIABLE - 21");
                    END IF;

                    Y := IDENT_INT(2 * X);

                    IF THREE.A /= IDENT_INT(2) THEN
                         FAILED ("INCORRECT RESULTS FOR OUTER " &
                                 "HOMOGRAPH - 22");
                    END IF;
               END HERE;
          END TEMPLATE;

     BEGIN  -- THREE
          IF B /= IDENT_INT(2) THEN
               FAILED ("INCORRECT VALUE FOR OUTER VARIABLE - 23");
          END IF;

          INNER (A => OBJ);

          IF OBJ /= IDENT_INT(4) THEN
               FAILED ("INCORRECT VALUE PASSED OUT - 24");
          END IF;
     END THREE;

     FOUR:
     DECLARE                 --  OVERLOADING OF FUNCTIONS.

          OBJ : INTEGER := 1;
          FLO : FLOAT := 5.0;

          FUNCTION F IS NEW GEN_FUN (INTEGER, OBJ);

          TASK INNER IS
               ENTRY HERE (X : IN OUT INTEGER;
                           F : FLOAT := 6.25);
          END INNER;

          FUNCTION F IS NEW GEN_FUN (FLOAT, FLO);

          TASK BODY INNER IS
          BEGIN
               ACCEPT HERE (X : IN OUT INTEGER;
                            F : FLOAT := 6.25) DO
                    X := INTEGER(F);
               END HERE;
          END INNER;

     BEGIN
          INNER.HERE (OBJ);

          IF OBJ /= IDENT_INT(6) THEN
               FAILED ("INCORRECT VALUE RETURNED FROM FUNCTION - 30");
          END IF;
     END FOUR;

     RESULT;
END C83026A;
