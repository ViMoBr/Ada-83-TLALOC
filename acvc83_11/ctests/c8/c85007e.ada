-- C85007E.ADA

-- CHECK THAT A RENAMED OUT PARAMETER, OUT PARAMETER COMPONENT, OR
-- OUT PARAMETER SLICE CAN BE ASSIGNED TO.

-- EG  02/22/84

WITH REPORT;

PROCEDURE C85007E IS

     USE REPORT;

BEGIN

     TEST("C85007E","CHECK THAT A RENAMED OUT PARAMETER, PARAMETER " &
                    "COMPONENT, OR PARAMETER SLICE CAN BE ASSIGNED TO");

     DECLARE

          TYPE AT1 IS ARRAY(1 .. 3) OF INTEGER;
          TYPE RT (A : INTEGER) IS
               RECORD
                    B : AT1;
                    C : INTEGER;
               END RECORD;

          A1, B1 : INTEGER;
          A2, B2 : AT1;
          A3, B3 : RT(1);

          PROCEDURE PROC1 (A : OUT INTEGER;
                           B : OUT AT1;
                           C : OUT RT) IS

               AA : INTEGER RENAMES A;
               BB : AT1     RENAMES B;
               CC : RT      RENAMES C;

          BEGIN

               AA := -1;
               BB := (1 .. 3 => -2);
               CC := (1, (2, 3, 4), 5);

          END PROC1;

          PROCEDURE PROC2 (X : OUT AT1;
                           Y : OUT INTEGER;
                           Z : OUT RT) IS

               XX : AT1     RENAMES X;
               YY : INTEGER RENAMES Y;
               ZZ : RT      RENAMES Z;

          BEGIN

               PROC1 (YY, XX, ZZ);

          END PROC2;

     BEGIN

          PROC1 (A1, A2, A3);
          IF A1 /= IDENT_INT(-1) OR A2 /= (1 .. 3 => IDENT_INT(-2)) OR
             A3 /= (1, (2, 3, 4), IDENT_INT(5)) THEN
               FAILED ("CASE 1 : ERROR IN ASSIGNMENT");
          END IF;

          PROC2 (B2, B1, B3);
          IF B1 /= IDENT_INT(-1) OR B2 /= (1 .. 3 => IDENT_INT(-2)) OR
             B3 /= (1, (2, 3, 4), IDENT_INT(5)) THEN
               FAILED ("CASE 2 : ERROR IN ASSIGNMENT");
          END IF;

     END;

     RESULT;

END C85007E;
