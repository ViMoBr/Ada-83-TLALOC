-- B34014M.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED SUBPROGRAM IS HIDDEN AND NOT FURTHER
--     DERIVABLE UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED SUBPROGRAM IS IMPLICITLY DECLARED IN A
--     DECLARATIVE PART AND A HOMOGRAPHIC SUBPROGRAM IS LATER DECLARED
--     EXPLICITLY IN THE SAME DECLARATIVE PART.

-- HISTORY:
--     JRK 09/17/87  CREATED ORIGINAL TEST.

PROCEDURE B34014M IS

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

     -- NEW SUBPROGRAM DECLARED BY SUBPROGRAM DECLARATION IN A BLOCK.

     BEGIN

      Q : DECLARE
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
               FUNCTION F (Y : QT) RETURN QT;
               TYPE QR IS
                    RECORD
                         C1 : QT := F (0);        -- OK.
                         C2 : QT := F (Y => 0);   -- OK.
                         C3 : QT := F (X => 0);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;

               FUNCTION F (Y : QT) RETURN QT IS
               BEGIN
                    RETURN 2;
               END F;

               PACKAGE R IS
                    Z1 : QS := F (0);             -- OK.
                    Z2 : QS := F (X => 0);        -- OK.
                    Z3 : QS := F (Y => 0);        -- ERROR: F HIDDEN.
               END R;
          BEGIN
               NULL;
          END Q;

     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY RENAMING IN A PROCEDURE BODY.

     DECLARE

          PROCEDURE Q IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION F (Y : QT) RETURN QT RENAMES G;
               TYPE QR IS
                    RECORD
                         C1 : QT := F (0);        -- OK.
                         C2 : QT := F (Y => 0);   -- OK.
                         C3 : QT := F (X => 0);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;

               FUNCTION G (X : QT) RETURN QT IS
               BEGIN
                    RETURN 2;
               END G;

               PACKAGE R IS
                    Z1 : QS := F (0);             -- OK.
                    Z2 : QS := F (X => 0);        -- OK.
                    Z3 : QS := F (Y => 0);        -- ERROR: F HIDDEN.
               END R;
          BEGIN
               NULL;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY GENERIC INSTANTIATION IN A PACKAGE
     -- BODY.

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN 2;
          END G;

          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
               FUNCTION F IS NEW G (QT);
               W1 : QT := F (0);                  -- OK.
               W2 : QT := F (Y => 0);             -- OK.
               W3 : QT := F (X => 0);             -- ERROR: F HIDDEN.
               TYPE QS IS NEW QT;
               Z1 : QS := F (0);                  -- OK.
               Z2 : QS := F (X => 0);             -- OK.
               Z3 : QS := F (Y => 0);             -- ERROR: F HIDDEN.
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY SUBPROGRAM DECLARATION IN A TASK
     -- BODY.

     DECLARE

          TASK Q;

          TASK BODY Q IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
               FUNCTION F (Y : QT) RETURN QT;
               TYPE QR IS
                    RECORD
                         C1 : QT := F (0);        -- OK.
                         C2 : QT := F (Y => 0);   -- OK.
                         C3 : QT := F (X => 0);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;

               FUNCTION F (Y : QT) RETURN QT IS
               BEGIN
                    RETURN 2;
               END F;

               PACKAGE R IS
                    Z1 : QS := F (0);             -- OK.
                    Z2 : QS := F (X => 0);        -- OK.
                    Z3 : QS := F (Y => 0);        -- ERROR: F HIDDEN.
               END R;
          BEGIN
               NULL;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY RENAMING IN A GENERIC PACKAGE BODY.

     DECLARE

          GENERIC
          PACKAGE Q IS
          END Q;

          PACKAGE BODY Q IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION F (Y : QT) RETURN QT RENAMES G;
               TYPE QR IS
                    RECORD
                         C1 : QT := F (0);        -- OK.
                         C2 : QT := F (Y => 0);   -- OK.
                         C3 : QT := F (X => 0);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QS IS NEW QT;

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

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY GENERIC INSTANTIATION IN A GENERIC
     -- FUNCTION BODY.

     DECLARE

          GENERIC
               TYPE T IS RANGE <>;
          FUNCTION G (Y : T) RETURN T;

          FUNCTION G (Y : T) RETURN T IS
          BEGIN
               RETURN 2;
          END G;

          GENERIC
               TYPE S IS RANGE <>;
          FUNCTION Q (I : S) RETURN S;

          FUNCTION Q (I : S) RETURN S IS
               TYPE QT IS NEW T;
               X : QT := F (0);                   -- OK.
               FUNCTION F IS NEW G (QT);
               W1 : QT := F (0);                  -- OK.
               W2 : QT := F (Y => 0);             -- OK.
               W3 : QT := F (X => 0);             -- ERROR: F HIDDEN.
               TYPE QS IS NEW QT;
               Z1 : QS := F (0);                  -- OK.
               Z2 : QS := F (X => 0);             -- OK.
               Z3 : QS := F (Y => 0);             -- ERROR: F HIDDEN.
          BEGIN
               RETURN I;
          END Q;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

END B34014M;
