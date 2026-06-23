-- C32114A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF A DEFAULT DISCRIMINANT VALUE
-- IS NOT COMPATIBLE WITH ITS USE FOR A COMPONENT THAT IS DEPENDENT ON
-- THE DISCRIMINANT.

-- JBG 11/8/85
-- PWB 03/04/86  CORRECTED ERROR (UNTERMINATED STRING LITERAL).

WITH REPORT; USE REPORT;
PROCEDURE C32114A IS

     SUBTYPE SMALL IS INTEGER RANGE -2..10;
     TYPE REC (D : SMALL := -1) IS
          RECORD
               C : STRING (D .. 3);
          END RECORD;

     SUBTYPE THREE IS INTEGER RANGE 3..3;
     TYPE REC2 (D : THREE) IS
          RECORD NULL; END RECORD;

     TYPE REC3 (D : SMALL := 2) IS
          RECORD
               C : REC2 (D);
          END RECORD;

     TYPE REC4 (D : SMALL := -1) IS
          RECORD
               C : REC;
          END RECORD;

     PACKAGE P IS

          TYPE REC (D : SMALL := -1) IS PRIVATE;
          TYPE REC3 (D : SMALL := 2) IS PRIVATE;
          TYPE REC4 (D : SMALL := -1) IS PRIVATE;

     PRIVATE

          SUBTYPE THREE IS INTEGER RANGE 3..3;
          TYPE REC2 (D : THREE) IS
               RECORD NULL; END RECORD;

          TYPE REC (D : SMALL := -1) IS
               RECORD
                    C : STRING (D .. 3);
               END RECORD;

          TYPE REC3 (D : SMALL := 2) IS
               RECORD
                    C : REC2 (D);
               END RECORD;

          TYPE REC4 (D : SMALL := -1) IS
               RECORD
                    C : REC;
               END RECORD;
     END P;

BEGIN

     TEST ("C32114A", "CHECK THAT DEFAULT DISCRIMINANT VALUES ARE "  &
                      "CHECKED WHEN USED IN CONSTRAINING COMPONENTS");

     BEGIN

          DECLARE
               OBJ : REC;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - 1");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - 1");
     END;

     BEGIN
          DECLARE
               OBJ : REC3;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - 2");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - 2");
     END;

     BEGIN
          DECLARE
               OBJ : REC4;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - 3");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - 3");
     END;

     BEGIN

          DECLARE
               OBJ : P.REC;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - 11");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - 11");
     END;

     BEGIN
          DECLARE
               OBJ : P.REC3;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - 12");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - 12");
     END;

     BEGIN
          DECLARE
               OBJ : P.REC4;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - 13");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - 13");
     END;

     RESULT;
END C32114A;
