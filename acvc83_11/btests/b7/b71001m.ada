-- B71001M.ADA

-- CHECK THAT THE IDENTIFIER AT THE END OF A GENERIC PACKAGE
-- SPEC OR BODY MUST MATCH THE PACKAGE NAME.

-- THIS TEST CHECKS FOR GENERIC PACKAGES NESTED IN GENERIC PACKAGES.

-- DAT 4/3/81
-- JBG 9/14/83

PROCEDURE B71001M IS

     GENERIC
     PACKAGE  P2 IS
          GENERIC
          PACKAGE P3 IS
          END P2;                            -- ERROR: P2.
     END P4;                                 -- ERROR: P4.

     GENERIC
     PACKAGE P5 IS
          GENERIC
          PACKAGE P6 IS
          END P6;
     END P5;

     PACKAGE BODY P5 IS
          PACKAGE BODY P6 IS
          END P5;                            -- ERROR: P5.
     END P6;                                 -- ERROR: P6.

BEGIN
     NULL;
END B71001M;
