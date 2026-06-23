-- B34014D.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED SUBPROGRAM IS HIDDEN AND NOT FURTHER
--     DERIVABLE UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED SUBPROGRAM IS IMPLICITLY DECLARED IN THE
--     VISIBLE PART OF A PACKAGE AND A HOMOGRAPHIC SUBPROGRAM IS LATER
--     DECLARED EXPLICITLY IN THE PRIVATE PART.

-- HISTORY:
--     JRK 09/14/87  CREATED ORIGINAL TEST.

PROCEDURE B34014D IS

     PACKAGE P IS
          TYPE T IS RANGE -100 .. 100;
          FUNCTION F (X : T) RETURN T;
     END P;
     USE P;

     PACKAGE BODY P IS
          FUNCTION F (X : T) RETURN T IS
          BEGIN
               RETURN 1;
          END F;
     END P;

BEGIN

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY SUBPROGRAM DECLARATION.

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
          PRIVATE
               FUNCTION F (Y : QT) RETURN QT;
               TYPE QR IS
                    RECORD
                         C1 : QT := F (0);        -- OK.
                         C2 : QT := F (Y => 0);   -- OK.
                         C3 : QT := F (X => 0);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION F (Y : QT) RETURN QT IS
               BEGIN
                    RETURN 2;
               END F;

               PACKAGE R IS
                    Z1 : QS := F (0);             -- OK.
                    Z2 : QS := F (X => 0);        -- OK.
                    Z3 : QS := F (Y => 0);        -- ERROR: F HIDDEN.
               END R;
          END Q;

          PACKAGE R IS
               Y1 : QT := F (0);                  -- OK.
               Y2 : QT := F (X => 0);             -- OK.
               Y3 : QT := F (Y => 0);             -- ERROR: F HIDDEN.
               TYPE RT IS NEW QT;
               Z1 : RT := F (0);                  -- OK.
               Z2 : RT := F (X => 0);             -- OK.
               Z3 : RT := F (Y => 0);             -- ERROR: F HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY RENAMING.

     DECLARE

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
          PRIVATE
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION F (Y : QT) RETURN QT RENAMES G;
               TYPE QR IS
                    RECORD
                         C1 : QT := F (0);        -- OK.
                         C2 : QT := F (Y => 0);   -- OK.
                         C3 : QT := F (X => 0);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;
          END Q;
          USE Q;

          PACKAGE BODY Q IS
               FUNCTION G (X : QT) RETURN QT IS
               BEGIN
                    RETURN 2;
               END G;

               PACKAGE R IS
                    Z1 : QS := F (0);             -- OK.
                    Z2 : QS := F (X => 0);        -- OK.
                    Z3 : QS := F (Y => 0);        -- ERROR: F HIDDEN.
               END R;
          END Q;

          PACKAGE R IS
               Y1 : QT := F (0);                  -- OK.
               Y2 : QT := F (X => 0);             -- OK.
               Y3 : QT := F (Y => 0);             -- ERROR: F HIDDEN.
               TYPE RT IS NEW QT;
               Z1 : RT := F (0);                  -- OK.
               Z2 : RT := F (X => 0);             -- OK.
               Z3 : RT := F (Y => 0);             -- ERROR: F HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY GENERIC INSTANTIATION.

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN 2;
          END G;

          PACKAGE Q IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
          PRIVATE
               FUNCTION F IS NEW G (QT);
               W1 : QT := F (0);                  -- OK.
               W2 : QT := F (Y => 0);             -- OK.
               W3 : QT := F (X => 0);             -- ERROR: F HIDDEN.
               TYPE QS IS NEW QT;
               Z1 : QS := F (0);                  -- OK.
               Z2 : QS := F (X => 0);             -- OK.
               Z3 : QS := F (Y => 0);             -- ERROR: F HIDDEN.
          END Q;
          USE Q;

          PACKAGE R IS
               Y1 : QT := F (0);                  -- OK.
               Y2 : QT := F (X => 0);             -- OK.
               Y3 : QT := F (Y => 0);             -- ERROR: F HIDDEN.
               TYPE RT IS NEW QT;
               Z1 : RT := F (0);                  -- OK.
               Z2 : RT := F (X => 0);             -- OK.
               Z3 : RT := F (Y => 0);             -- ERROR: F HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

END B34014D;
