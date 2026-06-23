-- C34014E.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE AND FURTHER DERIVABLE
--     UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED SUBPROGRAM IS IMPLICITLY DECLARED IN THE
--     VISIBLE PART OF A PACKAGE AND A HOMOGRAPHIC SUBPROGRAM IS LATER
--     DECLARED EXPLICITLY IN THE PACKAGE BODY.

-- HISTORY:
--     JRK 09/15/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34014E IS

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
     TEST ("C34014E", "CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE " &
                      "AND FURTHER DERIVABLE UNDER APPROPRIATE " &
                      "CIRCUMSTANCES.  CHECK WHEN THE DERIVED " &
                      "SUBPROGRAM IS IMPLICITLY DECLARED IN THE " &
                      "VISIBLE PART OF A PACKAGE AND A HOMOGRAPHIC " &
                      "SUBPROGRAM IS LATER DECLARED EXPLICITLY IN " &
                      "THE PACKAGE BODY");

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY SUBPROGRAM DECLARATION");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := F;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION F RETURN QT;
               TYPE QR IS
                    RECORD
                         C : QT := F;
                    END RECORD;
               TYPE QS IS NEW QT;

               FUNCTION F RETURN QT IS
               BEGIN
                    RETURN QT (IDENT_INT (2));
               END F;

               PACKAGE R IS
                    Y : QR;
                    Z : QS := F;
               END R;
               USE R;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT VISIBLE - SUBPROG " &
                            "DECL - 1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - SUBPROG " &
                            "DECL");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - SUBPROG " &
                            "DECL - 1");
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
               FAILED ("OLD SUBPROGRAM NOT VISIBLE - SUBPROG DECL - 2");
          END IF;

          IF Z /= 1 THEN
               FAILED ("OLD SUBPROGRAM NOT DERIVED - SUBPROG DECL - 2");
          END IF;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY RENAMING");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := F;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION G RETURN QT;
               FUNCTION F RETURN QT RENAMES G;
               TYPE QR IS
                    RECORD
                         C : QT := F;
                    END RECORD;
               TYPE QS IS NEW QT;

               FUNCTION G RETURN QT IS
               BEGIN
                    RETURN QT (IDENT_INT (2));
               END G;

               PACKAGE R IS
                    Y : QR;
                    Z : QS := F;
               END R;
               USE R;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT VISIBLE - RENAMING - " &
                            "1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - RENAMING");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - RENAMING - " &
                            "1");
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
               FAILED ("OLD SUBPROGRAM NOT VISIBLE - RENAMING - 2");
          END IF;

          IF Z /= 1 THEN
               FAILED ("OLD SUBPROGRAM NOT DERIVED - RENAMING - 2");
          END IF;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY GENERIC INSTANTIATION");

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G RETURN T;

          FUNCTION G RETURN T IS
          BEGIN
               RETURN T (IDENT_INT (2));
          END G;

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := F;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION F IS NEW G (QT);
               W : QT := F;
               TYPE QS IS NEW QT;
               Z : QS := F;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT VISIBLE - " &
                            "INSTANTIATION - 1");
               END IF;

               IF W /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - " &
                            "INSTANTIATION");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - " &
                            "INSTANTIATION - 1");
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
               FAILED ("OLD SUBPROGRAM NOT VISIBLE - INSTANTIATION - " &
                       "2");
          END IF;

          IF Z /= 1 THEN
               FAILED ("OLD SUBPROGRAM NOT DERIVED - INSTANTIATION - " &
                       "2");
          END IF;
     END;

     -----------------------------------------------------------------

     RESULT;
END C34014E;
