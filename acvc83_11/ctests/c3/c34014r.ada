-- C34014R.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED OPERATOR IS VISIBLE AND FURTHER DERIVABLE
--     UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED OPERATOR IS IMPLICITLY DECLARED IN THE
--     VISIBLE PART OF A PACKAGE AND A HOMOGRAPHIC OPERATOR IS LATER
--     DECLARED EXPLICITLY IN THE PACKAGE BODY.

-- HISTORY:
--     JRK 09/22/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34014R IS

     PACKAGE P IS
          TYPE T IS RANGE -100 .. 100;
          FUNCTION "+" (X : T) RETURN T;
     END P;
     USE P;

     PACKAGE BODY P IS
          FUNCTION "+" (X : T) RETURN T IS
          BEGIN
               RETURN X + T (IDENT_INT (1));
          END "+";
     END P;

BEGIN
     TEST ("C34014R", "CHECK THAT A DERIVED OPERATOR IS VISIBLE " &
                      "AND FURTHER DERIVABLE UNDER APPROPRIATE " &
                      "CIRCUMSTANCES.  CHECK WHEN THE DERIVED " &
                      "OPERATOR IS IMPLICITLY DECLARED IN THE " &
                      "VISIBLE PART OF A PACKAGE AND A HOMOGRAPHIC " &
                      "OPERATOR IS LATER DECLARED EXPLICITLY IN " &
                      "THE PACKAGE BODY");

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY SUBPROGRAM DECLARATION");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := +0;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION "+" (Y : QT) RETURN QT;
               TYPE QR IS
                    RECORD
                         C : QT := +0;
                    END RECORD;
               TYPE QS IS NEW QT;

               FUNCTION "+" (Y : QT) RETURN QT IS
               BEGIN
                    RETURN Y + QT (IDENT_INT (2));
               END "+";

               PACKAGE R IS
                    Y : QR;
                    Z : QS := +0;
               END R;
               USE R;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD OPERATOR NOT VISIBLE - SUBPROG " &
                            "DECL - 1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - SUBPROG " &
                            "DECL");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - SUBPROG " &
                            "DECL - 1");
               END IF;
          END Q;

          PACKAGE R IS
               Y : QT := +0;
               TYPE RT IS NEW QT;
               Z : RT := +0;
          END R;
          USE R;

     BEGIN
          IF Y /= 1 THEN
               FAILED ("OLD OPERATOR NOT VISIBLE - SUBPROG DECL - 2");
          END IF;

          IF Z /= 1 THEN
               FAILED ("OLD OPERATOR NOT DERIVED - SUBPROG DECL - 2");
          END IF;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY RENAMING");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := +0;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION "+" (Y : QT) RETURN QT RENAMES G;
               TYPE QR IS
                    RECORD
                         C : QT := +0;
                    END RECORD;
               TYPE QS IS NEW QT;

               FUNCTION G (X : QT) RETURN QT IS
               BEGIN
                    RETURN X + QT (IDENT_INT (2));
               END G;

               PACKAGE R IS
                    Y : QR;
                    Z : QS := +0;
               END R;
               USE R;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD OPERATOR NOT VISIBLE - RENAMING - " &
                            "1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - RENAMING");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - RENAMING - " &
                            "1");
               END IF;
          END Q;

          PACKAGE R IS
               Y : QT := +0;
               TYPE RT IS NEW QT;
               Z : RT := +0;
          END R;
          USE R;

     BEGIN
          IF Y /= 1 THEN
               FAILED ("OLD OPERATOR NOT VISIBLE - RENAMING - 2");
          END IF;

          IF Z /= 1 THEN
               FAILED ("OLD OPERATOR NOT DERIVED - RENAMING - 2");
          END IF;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY GENERIC INSTANTIATION");

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN Y + T (IDENT_INT (2));
          END G;

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := +0;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION "+" IS NEW G (QT);
               W : QT := +0;
               TYPE QS IS NEW QT;
               Z : QS := +0;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD OPERATOR NOT VISIBLE - " &
                            "INSTANTIATION - 1");
               END IF;

               IF W /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - " &
                            "INSTANTIATION");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - " &
                            "INSTANTIATION - 1");
               END IF;
          END Q;

          PACKAGE R IS
               Y : QT := +0;
               TYPE RT IS NEW QT;
               Z : RT := +0;
          END R;
          USE R;

     BEGIN
          IF Y /= 1 THEN
               FAILED ("OLD OPERATOR NOT VISIBLE - INSTANTIATION - " &
                       "2");
          END IF;

          IF Z /= 1 THEN
               FAILED ("OLD OPERATOR NOT DERIVED - INSTANTIATION - " &
                       "2");
          END IF;
     END;

     -----------------------------------------------------------------

     RESULT;
END C34014R;
