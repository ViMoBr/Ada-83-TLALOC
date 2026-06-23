-- B34014X.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED OPERATOR IS HIDDEN AND NOT FURTHER
--     DERIVABLE UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED OPERATOR IS IMPLICITLY DECLARED IN THE
--     PRIVATE PART OF A PACKAGE AFTER AN EXPLICIT DECLARATION OF A
--     HOMOGRAPHIC OPERATOR IN THE PRIVATE PART.

-- HISTORY:
--     JRK 09/23/87  CREATED ORIGINAL TEST.

PROCEDURE B34014X IS

     PACKAGE P IS
          TYPE T IS RANGE -100 .. 100;
          FUNCTION "+" (X : T) RETURN T;
     END P;
     USE P;

     PACKAGE BODY P IS
          FUNCTION "+" (X : T) RETURN T IS
          BEGIN
               RETURN X + 1;
          END "+";
     END P;

BEGIN

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY SUBPROGRAM DECLARATION.

     DECLARE

          PACKAGE Q IS
               TYPE QT IS PRIVATE;
               C : CONSTANT QT;
          PRIVATE
               FUNCTION "+" (Y : QT) RETURN QT;
               TYPE QR1 IS
                    RECORD
                         C1 : QT := +C;           -- OK.
                         C2 : QT := "+" (Y => C); -- OK.
                         C3 : QT := "+" (X => C); -- ERROR: + HIDDEN.
                         C4 : QT := "+" (RIGHT=>C); -- ERROR: + HIDDEN.
                    END RECORD;
               TYPE QT IS NEW T;
               C : CONSTANT QT := 0;
               TYPE QR2 IS
                    RECORD
                         C1 : QT := +0;           -- OK.
                         C2 : QT := "+" (Y => 0); -- OK.
                         C3 : QT := "+" (X => 0); -- ERROR: + HIDDEN.
                         C4 : QT := "+" (RIGHT=>0); -- ERROR: + HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION "+" (Y : QT) RETURN QT IS
               BEGIN
                    RETURN Y + 2;
               END "+";

               PACKAGE R IS
                    Z1 : QS := +0;                -- OK.
                    Z2 : QS := "+" (X => 0);      -- OK.
                    Z3 : QS := "+" (Y => 0);      -- ERROR: + HIDDEN.
                    Z4 : QS := "+" (RIGHT => 0);  -- ERROR: + HIDDEN.
               END R;
          END Q;

          PACKAGE R IS
               Y : QT := +C;                      -- ERROR: + HIDDEN.
               TYPE RT IS NEW QT;
               Z : RT := "+" (RT (C));            -- ERROR: + HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY RENAMING.

     DECLARE

          PACKAGE Q IS
               TYPE QT IS PRIVATE;
               C : CONSTANT QT;
          PRIVATE
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION "+" (Y : QT) RETURN QT RENAMES G;
               TYPE QR1 IS
                    RECORD
                         C1 : QT := +C;           -- OK.
                         C2 : QT := "+" (Y => C); -- OK.
                         C3 : QT := "+" (X => C); -- ERROR: + HIDDEN.
                         C4 : QT := "+" (RIGHT=>C); -- ERROR: + HIDDEN.
                    END RECORD;
               TYPE QT IS NEW T;
               C : CONSTANT QT := 0;
               TYPE QR2 IS
                    RECORD
                         C1 : QT := +0;           -- OK.
                         C2 : QT := "+" (Y => 0); -- OK.
                         C3 : QT := "+" (X => 0); -- ERROR: + HIDDEN.
                         C4 : QT := "+" (RIGHT=>0); -- ERROR: + HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION G (X : QT) RETURN QT IS
               BEGIN
                    RETURN X + 2;
               END G;

               PACKAGE R IS
                    Z1 : QS := +0;                -- OK.
                    Z2 : QS := "+" (X => 0);      -- OK.
                    Z3 : QS := "+" (Y => 0);      -- ERROR: + HIDDEN.
                    Z4 : QS := "+" (RIGHT => 0);  -- ERROR: + HIDDEN.
               END R;
          END Q;

          PACKAGE R IS
               Y : QT := +C;                      -- ERROR: + HIDDEN.
               TYPE RT IS NEW QT;
               Z : RT := "+" (RT (C));            -- ERROR: + HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

END B34014X;
