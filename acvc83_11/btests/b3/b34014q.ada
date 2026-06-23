-- B34014Q.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED OPERATOR IS HIDDEN AND NOT FURTHER
--     DERIVABLE UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED OPERATOR IS IMPLICITLY DECLARED IN THE
--     VISIBLE PART OF A PACKAGE AND A HOMOGRAPHIC OPERATOR IS LATER
--     DECLARED EXPLICITLY IN THE PRIVATE PART.

-- HISTORY:
--     JRK 09/22/87  CREATED ORIGINAL TEST.

PROCEDURE B34014Q IS

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
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
          PRIVATE
               FUNCTION "+" (Y : QT) RETURN QT;
               TYPE QR IS
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
               Y1 : QT := +0;                     -- OK.
               Y2 : QT := "+" (X => 0);           -- OK.
               Y3 : QT := "+" (Y => 0);           -- ERROR: + HIDDEN.
               Y4 : QT := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
               TYPE RT IS NEW QT;
               Z1 : RT := +0;                     -- OK.
               Z2 : RT := "+" (X => 0);           -- OK.
               Z3 : RT := "+" (Y => 0);           -- ERROR: + HIDDEN.
               Z4 : RT := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY RENAMING.

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
          PRIVATE
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION "+" (Y : QT) RETURN QT RENAMES G;
               TYPE QR IS
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
               Y1 : QT := +0;                     -- OK.
               Y2 : QT := "+" (X => 0);           -- OK.
               Y3 : QT := "+" (Y => 0);           -- ERROR: + HIDDEN.
               Y4 : QT := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
               TYPE RT IS NEW QT;
               Z1 : RT := +0;                     -- OK.
               Z2 : RT := "+" (X => 0);           -- OK.
               Z3 : RT := "+" (Y => 0);           -- ERROR: + HIDDEN.
               Z4 : RT := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY GENERIC INSTANTIATION.

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN Y + 2;
          END G;

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
          PRIVATE
               FUNCTION "+" IS NEW G (QT);
               W1 : QT := +0;                     -- OK.
               W2 : QT := "+" (Y => 0);           -- OK.
               W3 : QT := "+" (X => 0);           -- ERROR: + HIDDEN.
               W4 : QT := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
               TYPE QS IS NEW QT;
               Z1 : QS := +0;                     -- OK.
               Z2 : QS := "+" (X => 0);           -- OK.
               Z3 : QS := "+" (Y => 0);           -- ERROR: + HIDDEN.
               Z4 : QS := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
          END Q;
          USE Q;

          PACKAGE R IS
               Y1 : QT := +0;                     -- OK.
               Y2 : QT := "+" (X => 0);           -- OK.
               Y3 : QT := "+" (Y => 0);           -- ERROR: + HIDDEN.
               Y4 : QT := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
               TYPE RT IS NEW QT;
               Z1 : RT := +0;                     -- OK.
               Z2 : RT := "+" (X => 0);           -- OK.
               Z3 : RT := "+" (Y => 0);           -- ERROR: + HIDDEN.
               Z4 : RT := "+" (RIGHT => 0);       -- ERROR: + HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

END B34014Q;
