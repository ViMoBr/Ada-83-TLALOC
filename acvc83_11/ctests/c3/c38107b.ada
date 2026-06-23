-- C38107B.ADA

-- OBJECTIVE:
--     IF A DISCRIMINANT CONSTRAINT IS APPLIED TO AN ACCESS TYPE WHICH
--     DESIGNATES AN INCOMPLETE TYPE WHICH WAS DECLARED IN THE VISIBLE
--     OR PRIVATE PART OF A PACKAGE SPECIFICATION, OR IN A DECLARATIVE
--     PART, CONSTRAINT_ERROR IS RAISED IF ONE OF THE
--     DISCRIMINANT'S VALUES DOES NOT BELONG TO THE CORRESPONDING
--     DISCRIMINANT'S SUBTYPE.

-- HISTORY:
--     DHH 08/05/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C38107B IS

BEGIN
     TEST("C38107B", "IF A DISCRIMINANT CONSTRAINT IS APPLIED TO AN " &
                     "ACCESS TYPE WHICH DESIGNATES AN INCOMPLETE " &
                     "TYPE WHICH WAS DECLARED IN THE VISIBLE OR " &
                     "PRIVATE PART OF A PACKAGE SPECIFICATION, OR IN " &
                     "A DECLARATIVE PART, CONSTRAINT_ERROR IS " &
                     "RAISED IF ONE OF THE DISCRIMINANT'S VALUES " &
                     "DOES NOT BELONG TO THE CORRESPONDING " &
                     "DISCRIMINANT'S SUBTYPE");

------------------------------ VISIBLE ------------------------------
     BEGIN
          DECLARE
               PACKAGE PACK IS
                    SUBTYPE SMALLER IS INTEGER RANGE 1 .. 5;

                    TYPE INCOMPLETE(A : SMALLER);

                    TYPE ACC_INC IS ACCESS INCOMPLETE;
                    SUBTYPE SUB_ACC IS ACC_INC(IDENT_INT(6));

                    TYPE INCOMPLETE(A : SMALLER) IS
                         RECORD
                              T : INTEGER := A;
                         END RECORD;

               END PACK;

               PACKAGE BODY PACK IS
               BEGIN
                    FAILED("CONSTRAINT_ERROR NOT RAISED - VISIBLE");
                    DECLARE
                         Z : SUB_ACC := NEW INCOMPLETE(IDENT_INT(6));
                    BEGIN
                         IF IDENT_INT(Z.T) = IDENT_INT(6) THEN
                              COMMENT("THIS LINE SHOULD NOT PRINT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         FAILED("CONSTRAINT_ERROR RAISED LATE " &
                                "- VISIBLE");
                    WHEN OTHERS =>
                         FAILED("UNEXPECTED EXCEPTION RAISED " &
                                "LATE - VISIBLE");
               END PACK;
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED " &
                      "- VISIBLE");
     END;

------------------------------ PRIVATE ------------------------------
     BEGIN
          DECLARE
               PACKAGE PACK2 IS
                    SUBTYPE SMALLER IS INTEGER RANGE 1 .. 5;

                    TYPE PRIV IS PRIVATE;

               PRIVATE
                    TYPE PRIV IS
                         RECORD
                              V : INTEGER;
                         END RECORD;

                    TYPE INCOMPLETE(A : SMALLER);

                    TYPE ACC_INC IS ACCESS INCOMPLETE;
                    SUBTYPE SUB_ACC IS ACC_INC(IDENT_INT(0));

                    TYPE INCOMPLETE(A : SMALLER) IS
                         RECORD
                              T : INTEGER := A;
                              U : PRIV := (V => A ** IDENT_INT(2));
                         END RECORD;

               END PACK2;

               PACKAGE BODY PACK2 IS
               BEGIN
                    FAILED("CONSTRAINT_ERROR NOT RAISED - PRIVATE");
                    DECLARE
                         Z : SUB_ACC := NEW INCOMPLETE(IDENT_INT(0));
                    BEGIN
                         IF IDENT_INT(Z.T) = IDENT_INT(0) THEN
                              COMMENT("THIS LINE SHOULD NOT PRINT");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         FAILED("CONSTRAINT_ERROR RAISED TOO LATE " &
                                "- PRIVATE");
                    WHEN OTHERS =>
                         FAILED("UNEXPECTED EXCEPTION RAISED LATE" &
                                "- PRIVATE");
               END PACK2;
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
                         FAILED("UNEXPECTED EXCEPTION RAISED " &
                                "- PRIVATE");
     END;

-------------------------- DECLARATIVE PART --------------------------
     BEGIN
          DECLARE
               SUBTYPE SMALLER IS INTEGER RANGE 1 .. 5;

               TYPE INCOMPLETE(A : SMALLER);

               TYPE ACC_INC IS ACCESS INCOMPLETE;
               SUBTYPE SUB_ACC IS ACC_INC(IDENT_INT(6));

               TYPE INCOMPLETE(A : SMALLER) IS
                    RECORD
                         T : INTEGER := INTEGER'(A);
                    END RECORD;

          BEGIN
               FAILED("CONSTRAINT_ERROR NOT RAISED - BLOCK " &
                      "STATEMENT");
               DECLARE
                    Z : SUB_ACC := NEW INCOMPLETE(IDENT_INT(6));
               BEGIN
                    IF IDENT_INT(Z.T) = IDENT_INT(6) THEN
                         COMMENT("THIS LINE SHOULD NOT PRINT");
                    END IF;
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED("CONSTRAINT_ERROR RAISED TOO LATE " &
                           "- BLOCK STATEMENT");
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED LATE" &
                           "- BLOCK STATEMENT");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
                         FAILED("UNEXPECTED EXCEPTION RAISED " &
                                "- BLOCK STATEMENT");
     END;

     RESULT;
END C38107B;
