-- B55B01B.ADA

-- CHECK THAT A LOOP_PARAMETER CANNOT BE USED AS A GENERIC IN OUT
-- PARAMETER.

-- SPS 3/2/83

PROCEDURE B55B01B IS

     I1 : INTEGER := 0;

     GENERIC
     PROCEDURE P ( P1 : OUT INTEGER; P2 : IN OUT INTEGER ) ;

     GENERIC
          PR : IN OUT INTEGER;
     PACKAGE GP1 IS END GP1;

     GENERIC
          PR : IN INTEGER;
     PACKAGE GP2 IS END GP2;

     PROCEDURE P ( P1 : OUT INTEGER; P2 : IN OUT INTEGER ) IS
     BEGIN
          NULL;
     END P;

BEGIN

     FOR I IN 1..10 LOOP

          DECLARE
               PACKAGE PKG1 IS NEW GP1 (I);       -- ERROR: PARAMETER
                                                  -- USED AS AN IN OUT
                                                  -- GENERIC PARAMETER.
               PACKAGE PKG2 IS NEW GP2 (I);       -- OK.
               PROCEDURE PROC IS NEW P;
          BEGIN
               PROC (I1, I);                      -- ERROR: PARAMETER
                                                  -- USED AS AN IN OUT
                                                  -- PARAMETER.
               PROC (I, I1);                      -- ERROR: PARAMETER
                                                  -- USED AS AN OUT
                                                  -- PARAMETER.
          END;
     END LOOP;

END B55B01B;
