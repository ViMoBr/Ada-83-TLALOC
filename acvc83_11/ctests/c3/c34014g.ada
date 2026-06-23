-- C34014G.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE AND FURTHER DERIVABLE
--     UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED SUBPROGRAM IS IMPLICITLY DECLARED IN THE
--     VISIBLE PART OF A PACKAGE AND NO HOMOGRAPHIC SUBPROGRAM IS LATER
--     DECLARED EXPLICITLY.

-- HISTORY:
--     JRK 09/16/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34014G IS

     PACKAGE P IS
          TYPE T IS RANGE -100 .. 100;
          FUNCTION F RETURN T;
     END P;
     USE P;

     PACKAGE BODY P IS
          FUNCTION F RETURN T IS
          BEGIN
               RETURN T (IDENT_INT (1));
          END F;
     END P;

BEGIN
     TEST ("C34014G", "CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE " &
                      "AND FURTHER DERIVABLE UNDER APPROPRIATE " &
                      "CIRCUMSTANCES.  CHECK WHEN THE DERIVED " &
                      "SUBPROGRAM IS IMPLICITLY DECLARED IN THE " &
                      "VISIBLE PART OF A PACKAGE AND NO HOMOGRAPHIC " &
                      "SUBPROGRAM IS LATER DECLARED EXPLICITLY");

     -----------------------------------------------------------------

     COMMENT ("NO NEW SUBPROGRAM DECLARED EXPLICITLY");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := F;
          PRIVATE
               TYPE QS IS NEW QT;
               Z : QS := F;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT VISIBLE - 1");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - 1");
               END IF;
          END Q;

          PACKAGE R IS
               Y : QT := F;
               TYPE RT IS NEW QT;
               Z : RT := F;
          END R;
          USE R;

     BEGIN
          IF Y /= 1 THEN
               FAILED ("OLD SUBPROGRAM NOT VISIBLE - 2");
          END IF;

          IF Z /= 1 THEN
               FAILED ("OLD SUBPROGRAM NOT DERIVED - 2");
          END IF;
     END;

     -----------------------------------------------------------------

     RESULT;
END C34014G;
