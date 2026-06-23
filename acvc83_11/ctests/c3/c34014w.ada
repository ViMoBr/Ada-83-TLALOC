-- C34014W.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED OPERATOR IS VISIBLE AND FURTHER DERIVABLE
--     UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED OPERATOR IS IMPLICITLY DECLARED IN THE
--     PRIVATE PART OF A PACKAGE AFTER AN EXPLICIT DECLARATION OF A
--     HOMOGRAPHIC OPERATOR IN THE PRIVATE PART.

-- HISTORY:
--     JRK 09/23/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34014W IS

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
     TEST ("C34014W", "CHECK THAT A DERIVED OPERATOR IS VISIBLE " &
                      "AND FURTHER DERIVABLE UNDER APPROPRIATE " &
                      "CIRCUMSTANCES.  CHECK WHEN THE DERIVED " &
                      "OPERATOR IS IMPLICITLY DECLARED IN THE " &
                      "PRIVATE PART OF A PACKAGE AFTER AN EXPLICIT " &
                      "DECLARATION OF A HOMOGRAPHIC OPERATOR IN " &
                      "THE PRIVATE PART");

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY SUBPROGRAM DECLARATION");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS PRIVATE;
               C0 : CONSTANT QT;
          PRIVATE
               FUNCTION "+" (Y : QT) RETURN QT;
               TYPE QR1 IS
                    RECORD
                         C : QT := +C0;
                    END RECORD;
               TYPE QT IS NEW T;
               C0 : CONSTANT QT := 0;
               TYPE QR2 IS
                    RECORD
                         C : QT := +0;
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION "+" (Y : QT) RETURN QT IS
               BEGIN
                    RETURN Y + QT (IDENT_INT (2));
               END "+";

               PACKAGE R IS
                    X : QR1;
                    Y : QR2;
                    Z : QS := +0;
               END R;
               USE R;
          BEGIN
               IF X.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - SUBPROG " &
                            "DECL - 1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - SUBPROG " &
                            "DECL - 2");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - SUBPROG " &
                            "DECL");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY RENAMING");

     DECLARE

          PACKAGE Q IS
               TYPE QT IS PRIVATE;
               C0 : CONSTANT QT;
          PRIVATE
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION "+" (Y : QT) RETURN QT RENAMES G;
               TYPE QR1 IS
                    RECORD
                         C : QT := +C0;
                    END RECORD;
               TYPE QT IS NEW T;
               C0 : CONSTANT QT := 0;
               TYPE QR2 IS
                    RECORD
                         C : QT := +0;
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION G (X : QT) RETURN QT IS
               BEGIN
                    RETURN X + QT (IDENT_INT (2));
               END G;

               PACKAGE R IS
                    X : QR1;
                    Y : QR2;
                    Z : QS := +0;
               END R;
               USE R;
          BEGIN
               IF X.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - RENAMING - " &
                            "1");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - RENAMING - " &
                            "2");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - RENAMING");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     RESULT;
END C34014W;
