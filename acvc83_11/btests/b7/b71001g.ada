-- B71001G.ADA

-- CHECK THAT THE IDENTIFIER AT THE END OF A GENERIC PACKAGE
-- SPEC OR BODY MUST MATCH THE PACKAGE NAME.

-- THIS TEST CHECKS FOR NON-GENERIC PACKAGES NESTED IN GENERIC PACKAGES.

-- JBG 9/14/83

PROCEDURE B71001G IS

     GENERIC
     PACKAGE  P2 IS
          PACKAGE P3 IS
          END P2;                            -- ERROR: P2.
     END P4;                                 -- ERROR: P4.

     GENERIC
     PACKAGE P5 IS
          PACKAGE P6 IS
          END P6;
     END P5;

     PACKAGE BODY P5 IS
          PACKAGE BODY P6 IS
          END P5;                            -- ERROR: P5.
     END P6;                                 -- ERROR: P6.

BEGIN
     NULL;
END B71001G;
