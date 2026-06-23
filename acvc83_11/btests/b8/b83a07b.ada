-- B83A07B.ADA

-- OBJECTIVE:
--     CHECK THAT A STATEMENT LABEL IN A TASK BODY
--     CANNOT BE THE SAME AS A BLOCK OR LOOP IDENTIFIER,
--     VARIABLE, CONSTANT, NAMED NUMBER, SUBPROGRAM, TYPE,
--     ENTRY, PACKAGE, EXCEPTION, OR GENERIC UNIT DECLARED
--     IN THE TASK.

-- HISTORY:
--     SDA 09/08/88  CREATED ORIGINAL TEST.

PROCEDURE B83A07B IS

          TASK TYPE TT IS
               ENTRY E;
          END TT;

          TASK BODY TT IS

               EX : EXCEPTION;
               A : INTEGER := 0;
               B : CONSTANT := 5;
               C : CONSTANT INTEGER := 5;
               TYPE D IS (ON,OFF);

               PROCEDURE PRO;

               PROCEDURE PRO IS
               BEGIN
                    NULL;
               END PRO;

               GENERIC
                    TYPE ELEMENT IS PRIVATE;
               PACKAGE PKG_GEN IS
                    PROCEDURE PROC (ITEM : IN OUT ELEMENT);
               END PKG_GEN;

               PACKAGE BODY PKG_GEN IS

                    PROCEDURE PROC (ITEM : IN OUT ELEMENT) IS

                    BEGIN
                         NULL;
                    END PROC;

               END PKG_GEN;

               PACKAGE PKG IS
                    PROCEDURE PROC_2;
               END PKG;

               PACKAGE BODY PKG IS

                    PROCEDURE PROC_2 IS

                    BEGIN
                         NULL;
                    END PROC_2;

               END PKG;

          BEGIN
               ACCEPT E;
               <<E>>         -- ERROR: ENTRY CAN NOT BE USED AS A LABEL.
                    NULL;
          L:   LOOP
                    EXIT L;
               END LOOP L;
               <<L>>         -- ERROR: LOOP IDENTIFIER CAN NOT BE USED
                             -- AS A LABEL.
                    NULL;
               <<A>>         -- ERROR: VARIABLE CAN NOT BE USED AS A
                             -- LABEL.
                    NULL;
               <<B>>         -- ERROR: NAMED NUMBER CAN NOT BE USED
                             -- AS A LABEL.
                    NULL;
               <<C>>         -- ERROR: CONSTANT CAN NOT BE USED AS A
                             -- LABEL.
                    NULL;
               <<D>>         -- ERROR: TYPE CAN NOT BE USED AS A LABEL.
                    NULL;
               <<PKG_GEN>>   -- ERROR: GENERIC PACKAGE CAN NOT BE USED
                             -- AS A LABEL.
                    NULL;
               <<PKG>>       -- ERROR: PACKAGE CAN NOT BE USED AS A
                             -- LABEL.
                    NULL;
               <<PRO>>       -- ERROR: SUBPROGRAM CAN NOT BE USED AS
                             -- A LABEL.
                    NULL;
               <<EX>>        -- ERROR: EXCEPTION CAN NOT BE USED AS A
                             -- LABEL.
                    NULL;
          END TT;

BEGIN
NULL;
END B83A07B;
