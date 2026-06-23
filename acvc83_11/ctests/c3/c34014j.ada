-- C34014J.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE AND FURTHER DERIVABLE
--     UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED SUBPROGRAM IS IMPLICITLY DECLARED IN THE
--     PRIVATE PART OF A PACKAGE AFTER AN EXPLICIT DECLARATION OF A
--     HOMOGRAPHIC SUBPROGRAM IN THE PRIVATE PART.

-- HISTORY:
--     JRK 09/17/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34014J IS

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
     TEST ("C34014J", "CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE " &
                      "AND FURTHER DERIVABLE UNDER APPROPRIATE " &
                      "CIRCUMSTANCES.  CHECK WHEN THE DERIVED " &
                      "SUBPROGRAM IS IMPLICITLY DECLARED IN THE " &
                      "PRIVATE PART OF A PACKAGE AFTER AN EXPLICIT " &
                      "DECLARATION OF A HOMOGRAPHIC SUBPROGRAM IN " &
                      "THE PRIVATE PART");

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY SUBPROGRAM DECLARATION");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS PRIVATE;
          PRIVATE
               FUNCTION F RETURN QT;
               TYPE QR1 IS
                    RECORD
                         C : QT := F;
                    END RECORD;
               TYPE QT IS NEW T;
               TYPE QR2 IS
                    RECORD
                         C : QT := F;
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION F RETURN QT IS
               BEGIN
                    RETURN QT (IDENT_INT (2));
               END F;

               PACKAGE R IS
                    X : QR1;
                    Y : QR2;
                    Z : QS := F;
               END R;
               USE R;
          BEGIN
               IF X.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - SUBPROG " &
                            "DECL - 1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - SUBPROG " &
                            "DECL - 2");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - SUBPROG " &
                            "DECL");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY RENAMING");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS PRIVATE;
          PRIVATE
               FUNCTION G RETURN QT;
               FUNCTION F RETURN QT RENAMES G;
               TYPE QR1 IS
                    RECORD
                         C : QT := F;
                    END RECORD;
               TYPE QT IS NEW T;
               TYPE QR2 IS
                    RECORD
                         C : QT := F;
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION G RETURN QT IS
               BEGIN
                    RETURN QT (IDENT_INT (2));
               END G;

               PACKAGE R IS
                    X : QR1;
                    Y : QR2;
                    Z : QS := F;
               END R;
               USE R;
          BEGIN
               IF X.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - RENAMING - " &
                            "1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - RENAMING - " &
                            "2");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - RENAMING");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     RESULT;
END C34014J;
