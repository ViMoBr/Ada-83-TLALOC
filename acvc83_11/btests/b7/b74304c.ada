-- B74304C.ADA

-- CHECK THAT A GENERIC IN PARAMETER CANNOT BE A YET-DEFERRED
-- CONSTANT EVEN WITHIN A GENERIC UNIT WHICH IS NEVER INSTANTIATED.

-- DIFFERENT THAN B74304B-B, PACKAGE PKG IS A GENERIC.

-- DAT 9/18/81
-- SPS 4/28/82
-- SPS 10/19/83

PROCEDURE B74304C IS

     GENERIC
          TYPE T IS PRIVATE;
          INP : IN T;
     PACKAGE P1 IS END P1;

     GENERIC
     PACKAGE PKG IS
          TYPE PRIV IS PRIVATE;
          DC : CONSTANT PRIV;

          PACKAGE I1 IS NEW P1 (PRIV, DC);   -- ERROR: PRIV AND DC
                                             --     DEFERRED.

     PRIVATE
          TYPE PRIV IS (X);

          PACKAGE I2 IS NEW P1 (PRIV, DC);   -- ERROR: DC DEFERRED.

          GENERIC
               INP : PRIV := DC;             -- ERROR: DC DEFERRED.
          PACKAGE GP2 IS END GP2;

          GENERIC
               INP : PRIV := X;
          PACKAGE GP3 IS END GP3;

          PACKAGE I3 IS NEW GP3 (DC);        -- ERROR: DC DEFERRED.
          PACKAGE I4 IS NEW GP3 (X);         -- OK.
          PACKAGE I5 IS NEW GP3;             -- OK.
          PACKAGE I6 IS NEW P1 (PRIV, X);    -- OK.

          DC : CONSTANT PRIV := X;

          PACKAGE I7 IS NEW P1 (PRIV, DC);   -- OK.
          PACKAGE I8 IS NEW GP3 (DC);        -- OK.
     END;

BEGIN
     NULL;
END B74304C;
