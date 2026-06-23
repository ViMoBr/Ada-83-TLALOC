-- B74304B.ADA

-- CHECK THAT A GENERIC IN ACTUAL PARAMETER CANNOT BE A YET-DEFERRED
-- CONSTANT. 

-- CHECK THAT A DEFERRED CONSTANT CANNOT BE USED IN THE DEFAULT
-- EXPRESSION OF A GENERIC IN PARAMETER.


-- DAT 9/18/81
-- JBG 4/19/83
-- BHS 7/02/84

PROCEDURE B74304B IS

     GENERIC
          TYPE T IS PRIVATE;
          INP : IN T;
     PACKAGE P1 IS END P1;

     PACKAGE PKG IS
          TYPE PRIV IS PRIVATE;
          DC : CONSTANT PRIV;

          PACKAGE I1 IS NEW P1 (PRIV, DC);   -- ERROR: PRIV AND DC 
                                             --    DEFERRED.
          GENERIC
               INP : IN PRIV := DC;          -- ERROR: DC DEFERRED.
               BP  : BOOLEAN := DC IN PRIV;  -- ERROR: DC DEFERRED.
          PACKAGE PP1 IS END PP1;

     PRIVATE
          TYPE PRIV IS (X);

          PACKAGE I2 IS NEW P1 (PRIV, DC);   -- ERROR: DC DEFERRED.

          GENERIC
               INP : IN PRIV := DC;          -- ERROR: DC DEFERRED.
               BP  : BOOLEAN := DC IN PRIV;  -- ERROR: DC DEFERRED.
          PACKAGE GP3 IS END GP3;

          GENERIC
               INP : PRIV := X;
          PACKAGE GP4 IS END GP4;

          PACKAGE I5 IS NEW GP4(DC);         -- ERROR: DC DEFERRED.
          PACKAGE I6 IS NEW P1 (PRIV, X);    -- OK.

          DC : CONSTANT PRIV := X;

          PACKAGE I7 IS NEW P1 (PRIV, DC);   -- OK.
          PACKAGE I8 IS NEW GP4 (DC);        -- OK.
          PACKAGE I9 IS NEW GP4;             -- OK.
     END;

BEGIN
     NULL;
END B74304B;
