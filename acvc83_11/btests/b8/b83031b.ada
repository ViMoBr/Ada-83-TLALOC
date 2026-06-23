-- B83031B.ADA

-- OBJECTIVE:
--     CHECK THAT IF AN IMPLICIT DECLARATION OF A PREDEFINED OPERATOR
--     IS HIDDEN BY A SUBPROGRAM DECLARATION OR A RENAMING DECLARATION,
--     THEN A USE OF THE COMMON IDENTIFIER OF THE HOMOGRAPHS MUST BE
--     REJECTED IF IT WOULD BE LEGAL FOR THE HIDDEN IMPLICIT
--     DECLARATION BUT ILLEGAL FOR THE VISIBLE EXPLICIT DECLARATION.

-- HISTORY:
--     BCB 09/15/88  CREATED ORIGINAL TEST.

PROCEDURE B83031B IS

BEGIN
     DECLARE             -- CHECK SUBPROGRAM DECLARATIONS OF OPERATORS
          PACKAGE P IS
               TYPE INT IS RANGE -20 .. 20;

               M : INT := 3 * 3;
               N : INT := 1;
               O : INT := 1;

               FUNCTION "*" (L, R : INT) RETURN INT;

               FUNCTION "-" (MINUEND, SUBTRAHEND : INT) RETURN INT
                            RENAMES "+";
          END P;

          PACKAGE BODY P IS
               FUNCTION "*" (L, R : INT) RETURN INT IS
               BEGIN
                    RETURN 0;
               END "*";
          BEGIN
               M := "*" (LEFT => N, RIGHT => O);       -- ERROR:

               M := "-" (LEFT => N, RIGHT => O);       -- ERROR:
          END P;
     BEGIN
          NULL;
     END;

END B83031B;
