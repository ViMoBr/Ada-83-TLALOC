-- C34014L.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE AND FURTHER DERIVABLE
--     UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED SUBPROGRAM IS IMPLICITLY DECLARED IN A
--     DECLARATIVE PART AND A HOMOGRAPHIC SUBPROGRAM IS LATER DECLARED
--     EXPLICITLY IN THE SAME DECLARATIVE PART.

-- HISTORY:
--     JRK 09/17/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34014L IS

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
     TEST ("C34014L", "CHECK THAT A DERIVED SUBPROGRAM IS VISIBLE " &
                      "AND FURTHER DERIVABLE UNDER APPROPRIATE " &
                      "CIRCUMSTANCES.  CHECK WHEN THE DERIVED " &
                      "SUBPROGRAM IS IMPLICITLY DECLARED IN A " &
                      "DECLARATIVE PART AND A HOMOGRAPHIC SUBPROGRAM " &
                      "IS LATER DECLARED EXPLICITLY IN THE SAME " &
                      "DECLARATIVE PART");

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY SUBPROGRAM DECLARATION IN " &
              "A BLOCK");

     BEGIN

      Q : DECLARE
               TYPE QT IS NEW T;
               X : QT := F;
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
                            "DECL - BLOCK");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - SUBPROG " &
                            "DECL - BLOCK");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - SUBPROG " &
                            "DECL - BLOCK");
               END IF;
          END Q;

     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY RENAMING IN A PROCEDURE " &
              "BODY");

     DECLARE

          PROCEDURE Q IS
               TYPE QT IS NEW T;
               X : QT := F;
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
                            "PROCEDURE BODY");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - RENAMING - " &
                            "PROCEDURE BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - RENAMING - " &
                            "PROCEDURE BODY");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY GENERIC INSTANTIATION IN A " &
              "PACKAGE BODY");

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G RETURN T;

          FUNCTION G RETURN T IS
          BEGIN
               RETURN T (IDENT_INT (2));
          END G;

          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := F;
               FUNCTION F IS NEW G (QT);
               W : QT := F;
               TYPE QS IS NEW QT;
               Z : QS := F;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT VISIBLE - " &
                            "INSTANTIATION - PACKAGE BODY");
               END IF;

               IF W /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - " &
                            "INSTANTIATION - PACKAGE BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - " &
                            "INSTANTIATION - PACKAGE BODY");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY SUBPROGRAM DECLARATION IN " &
              "A TASK BODY");

     DECLARE

          TASK Q;

          TASK BODY Q IS
               TYPE QT IS NEW T;
               X : QT := F;
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
                            "DECL - TASK BODY");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - SUBPROG " &
                            "DECL - TASK BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - SUBPROG " &
                            "DECL - TASK BODY");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY RENAMING IN A GENERIC " &
              "PACKAGE BODY");

     DECLARE

          GENERIC
          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := F;
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
                            "GENERIC PACKAGE BODY");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - RENAMING - " &
                            "GENERIC PACKAGE BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - RENAMING - " &
                            "GENERIC PACKAGE BODY");
               END IF;
          END Q;

          PACKAGE R IS NEW Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW SUBPROGRAM DECLARED BY GENERIC INSTANTIATION IN A " &
              "GENERIC FUNCTION BODY");

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G RETURN T;

          FUNCTION G RETURN T IS
          BEGIN
               RETURN T (IDENT_INT (2));
          END G;

          GENERIC
               TYPE S IS RANGE <>;
          FUNCTION Q (I : S) RETURN S;

          FUNCTION Q (I : S) RETURN S IS
               TYPE QT IS NEW T;
               X : QT := F;
               FUNCTION F IS NEW G (QT);
               W : QT := F;
               TYPE QS IS NEW QT;
               Z : QS := F;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT VISIBLE - " &
                            "INSTANTIATION - GENERIC FUNCTION BODY");
               END IF;

               IF W /= 2 THEN
                    FAILED ("NEW SUBPROGRAM NOT VISIBLE - " &
                            "INSTANTIATION - GENERIC FUNCTION BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD SUBPROGRAM NOT DERIVED - " &
                            "INSTANTIATION - GENERIC FUNCTION BODY");
               END IF;

               RETURN S (IDENT_INT (INTEGER (I)));
          END Q;

          FUNCTION R IS NEW Q (INTEGER);

     BEGIN
          IF R (5) /= 5 THEN
               FAILED ("WRONG FUNCTION RESULT - INSTANTIATION - " &
                       "GENERIC FUNCTION BODY");
          END IF;
     END;

     -----------------------------------------------------------------

     RESULT;
END C34014L;
