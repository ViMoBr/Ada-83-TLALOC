-- C34014Y.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED OPERATOR IS VISIBLE AND FURTHER DERIVABLE
--     UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED OPERATOR IS IMPLICITLY DECLARED IN A
--     DECLARATIVE PART AND A HOMOGRAPHIC OPERATOR IS LATER DECLARED
--     EXPLICITLY IN THE SAME DECLARATIVE PART.

-- HISTORY:
--     JRK 09/24/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C34014Y IS

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
     TEST ("C34014Y", "CHECK THAT A DERIVED OPERATOR IS VISIBLE " &
                      "AND FURTHER DERIVABLE UNDER APPROPRIATE " &
                      "CIRCUMSTANCES.  CHECK WHEN THE DERIVED " &
                      "OPERATOR IS IMPLICITLY DECLARED IN A " &
                      "DECLARATIVE PART AND A HOMOGRAPHIC OPERATOR " &
                      "IS LATER DECLARED EXPLICITLY IN THE SAME " &
                      "DECLARATIVE PART");

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY SUBPROGRAM DECLARATION IN " &
              "A BLOCK");

     BEGIN

      Q : DECLARE
               TYPE QT IS NEW T;
               X : QT := +0;
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
                            "DECL - BLOCK");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - SUBPROG " &
                            "DECL - BLOCK");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - SUBPROG " &
                            "DECL - BLOCK");
               END IF;
          END Q;

     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY RENAMING IN A PROCEDURE " &
              "BODY");

     DECLARE

          PROCEDURE Q IS
               TYPE QT IS NEW T;
               X : QT := +0;
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
                            "PROCEDURE BODY");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - RENAMING - " &
                            "PROCEDURE BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - RENAMING - " &
                            "PROCEDURE BODY");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY GENERIC INSTANTIATION IN A " &
              "PACKAGE BODY");

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN Y + T (IDENT_INT (2));
          END G;

          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := +0;
               FUNCTION "+" IS NEW G (QT);
               W : QT := +0;
               TYPE QS IS NEW QT;
               Z : QS := +0;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD OPERATOR NOT VISIBLE - " &
                            "INSTANTIATION - PACKAGE BODY");
               END IF;

               IF W /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - " &
                            "INSTANTIATION - PACKAGE BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - " &
                            "INSTANTIATION - PACKAGE BODY");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY SUBPROGRAM DECLARATION IN " &
              "A TASK BODY");

     DECLARE

          TASK Q;

          TASK BODY Q IS
               TYPE QT IS NEW T;
               X : QT := +0;
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
                            "DECL - TASK BODY");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - SUBPROG " &
                            "DECL - TASK BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - SUBPROG " &
                            "DECL - TASK BODY");
               END IF;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY RENAMING IN A GENERIC " &
              "PACKAGE BODY");

     DECLARE

          GENERIC
          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := +0;
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
                            "GENERIC PACKAGE BODY");
               END IF;

               IF Y.C /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - RENAMING - " &
                            "GENERIC PACKAGE BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - RENAMING - " &
                            "GENERIC PACKAGE BODY");
               END IF;
          END Q;

          PACKAGE R IS NEW Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     COMMENT ("NEW OPERATOR DECLARED BY GENERIC INSTANTIATION IN A " &
              "GENERIC FUNCTION BODY");

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN Y + T (IDENT_INT (2));
          END G;

          GENERIC
               TYPE S IS RANGE <>;
          FUNCTION Q (I : S) RETURN S;

          FUNCTION Q (I : S) RETURN S IS
               TYPE QT IS NEW T;
               X : QT := +0;
               FUNCTION "+" IS NEW G (QT);
               W : QT := +0;
               TYPE QS IS NEW QT;
               Z : QS := +0;
          BEGIN
               IF X /= 1 THEN
                    FAILED ("OLD OPERATOR NOT VISIBLE - " &
                            "INSTANTIATION - GENERIC FUNCTION BODY");
               END IF;

               IF W /= 2 THEN
                    FAILED ("NEW OPERATOR NOT VISIBLE - " &
                            "INSTANTIATION - GENERIC FUNCTION BODY");
               END IF;

               IF Z /= 1 THEN
                    FAILED ("OLD OPERATOR NOT DERIVED - " &
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
END C34014Y;
