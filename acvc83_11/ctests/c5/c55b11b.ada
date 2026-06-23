-- C55B11B.ADA

-- OBJECTIVE:
--     CHECK THAT THE FORM 'FOR I IN ST RANGE L .. R LOOP' IS ACCEPTED
--     EVEN IF BOTH L AND R ARE OVERLOADED ENUMERATION LITERALS (SO
--     THAT L .. R WOULD BE ILLEGAL WITHOUT ST RANGE).

-- HISTORY:
--     DHH 09/07/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C55B11B IS
     TYPE ST IS (A, B, C, D, E, F, G, H);
     TYPE SI IS (A, B, C, D, F, E, G, H);

     GLOBAL : INTEGER := 0;

     PROCEDURE CHECK_VAR(T : ST) IS
     BEGIN
          GLOBAL := GLOBAL + 1;
          CASE T IS
               WHEN D =>
                    IF GLOBAL /= IDENT_INT(1) THEN
                         FAILED("1 WRONG VALUE");
                    END IF;

               WHEN E =>
                    IF GLOBAL /= IDENT_INT(2) THEN
                         FAILED("2 WRONG VALUE");
                    END IF;

               WHEN F =>
                    IF GLOBAL /= IDENT_INT(3) THEN
                         FAILED("3 WRONG VALUE");
                    END IF;

               WHEN G =>
                    IF GLOBAL /= IDENT_INT(4) THEN
                         FAILED("4 WRONG VALUE");
                    END IF;

               WHEN OTHERS =>
                   FAILED("WRONG VALUE TO PROCEDURE");

          END CASE;
     END CHECK_VAR;

     PROCEDURE CHECK_VAR(T : SI) IS
     BEGIN
          FAILED("WRONG PROCEDURE CALLED");
     END CHECK_VAR;

BEGIN
     TEST ("C55B11B", "CHECK THAT THE 'FORM FOR I IN ST RANGE L .. R " &
                      "LOOP' IS ACCEPTED EVEN IF BOTH L AND R ARE " &
                      "OVERLOADED ENUMERATION LITERALS (SO THAT L .. " &
                      "R WOULD BE ILLEGAL WITHOUT ST RANGE)");

     FOR I IN ST RANGE D .. G LOOP
          CHECK_VAR(I);
     END LOOP;

     RESULT;
END C55B11B;
