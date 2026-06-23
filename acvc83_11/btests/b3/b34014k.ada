-- B34014K.ADA

-- OBJECTIVE:
--     CHECK THAT A DERIVED SUBPROGRAM IS HIDDEN AND NOT FURTHER
--     DERIVABLE UNDER APPROPRIATE CIRCUMSTANCES.

--     CHECK WHEN THE DERIVED SUBPROGRAM IS IMPLICITLY DECLARED IN THE
--     PRIVATE PART OF A PACKAGE AFTER AN EXPLICIT DECLARATION OF A
--     HOMOGRAPHIC SUBPROGRAM IN THE PRIVATE PART.

-- HISTORY:
--     JRK 09/17/87  CREATED ORIGINAL TEST.

PROCEDURE B34014K IS

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
               TYPE QT IS PRIVATE;
               C : CONSTANT QT;
          PRIVATE
               FUNCTION F (Y : QT) RETURN QT;
               TYPE QR1 IS
                    RECORD
                         C1 : QT := F (C);        -- OK.
                         C2 : QT := F (Y => C);   -- OK.
                         C3 : QT := F (X => C);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QT IS NEW T;
               C : CONSTANT QT := 0;
               TYPE QR2 IS
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
               Y : QT := F (C);                   -- ERROR: F HIDDEN.
               TYPE RT IS NEW QT;
               Z : RT := F (RT (C));              -- ERROR: F HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

     -- NEW SUBPROGRAM DECLARED BY RENAMING.

     DECLARE

          PACKAGE Q IS
               TYPE QT IS PRIVATE;
               C : CONSTANT QT;
          PRIVATE
               FUNCTION G (X : QT) RETURN QT;
               FUNCTION F (Y : QT) RETURN QT RENAMES G;
               TYPE QR1 IS
                    RECORD
                         C1 : QT := F (C);        -- OK.
                         C2 : QT := F (Y => C);   -- OK.
                         C3 : QT := F (X => C);   -- ERROR: F HIDDEN.
                    END RECORD;
               TYPE QT IS NEW T;
               C : CONSTANT QT := 0;
               TYPE QR2 IS
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
               Y : QT := F (C);                   -- ERROR: F HIDDEN.
               TYPE RT IS NEW QT;
               Z : RT := F (RT (C));              -- ERROR: F HIDDEN.
          END R;

     BEGIN
          NULL;
     END;

     -----------------------------------------------------------------

END B34014K;
