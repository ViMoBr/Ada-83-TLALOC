-- B34014Z.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED OPERATOR IS HIDDEN AND NOT FURTHER
--     DERIVABLE UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED OPERATOR IS IMPLICITLY DECLARED IN A
--     DECLARATIVE PART AND A HOMOGRAPHIC OPERATOR IS LATER DECLARED
--     EXPLICITLY IN THE SAME DECLARATIVE PART.

-- HISTORY:
--     JRK 09/24/87  CREATED ORIGINAL TEST.

PROCEDURE B34014Z IS

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

     -- NEW OPERATOR DECLARED BY SUBPROGRAM DECLARATION IN A BLOCK.

     BEGIN

      Q : DECLARE
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
               FUNCTION "+" (Y : QT) RETURN QT;
               TYPE QR IS
                    RECORD
                         C1 : QT := +0;           -- OK.
                         C2 : QT := "+" (Y => 0); -- OK.
                         C3 : QT := "+" (X => 0); -- ERROR: + HIDDEN.
                         C4 : QT := "+" (RIGHT=>0); -- ERROR: + HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;

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
          BEGIN
               NULL;
          END Q;

     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY RENAMING IN A PROCEDURE BODY.

     DECLARE

          PROCEDURE Q IS
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
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
          BEGIN
               NULL;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY GENERIC INSTANTIATION IN A PACKAGE
     -- BODY.

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN Y + 2;
          END G;

          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
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

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY SUBPROGRAM DECLARATION IN A TASK
     -- BODY.

     DECLARE

          TASK Q;

          TASK BODY Q IS
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
               FUNCTION "+" (Y : QT) RETURN QT;
               TYPE QR IS
                    RECORD
                         C1 : QT := +0;           -- OK.
                         C2 : QT := "+" (Y => 0); -- OK.
                         C3 : QT := "+" (X => 0); -- ERROR: + HIDDEN.
                         C4 : QT := "+" (RIGHT=>0); -- ERROR: + HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;

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
          BEGIN
               NULL;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY RENAMING IN A GENERIC PACKAGE BODY.

     DECLARE

          GENERIC
          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
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

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW OPERATOR DECLARED BY GENERIC INSTANTIATION IN A GENERIC
     -- FUNCTION BODY.

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN Y + 2;
          END G;

          GENERIC
               TYPE S IS RANGE <>;
          FUNCTION Q (I : S) RETURN S;

          FUNCTION Q (I : S) RETURN S IS
               TYPE QT IS NEW T;
               X : QT := +0;                      -- OK.
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
          BEGIN
               RETURN I;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

END B34014Z;
