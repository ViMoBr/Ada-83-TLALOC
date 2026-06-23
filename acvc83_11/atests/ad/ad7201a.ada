-- AD7201A.ADA

-- OBJECTIVE:
--     CHECK THAT THE PREFIX OF THE 'ADDRESS ATTRIBUTE CAN DENOTE AN
--     OBJECT, PACKAGE, SUBPROGRAM, GENERIC UNIT, TASK TYPE, SINGLE
--     TASK, AND LABEL.

-- HISTORY:
--     DHH 09/01/88  CREATED ORIGINAL TEST.

WITH SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE AD7201A IS

     SUBTYPE MY_ADDRESS IS SYSTEM.ADDRESS;

     TYPE COLOR IS (RED, YELO, BLUE);

BEGIN
     TEST ("AD7201A", "CHECK THAT THE PREFIX OF THE 'ADDRESS " &
                      "ATTRIBUTE CAN DENOTE AN OBJECT, PACKAGE, " &
                      "SUBPROGRAM, GENERIC UNIT, TASK TYPE, SINGLE " &
                      "TASK, AND LABEL");
     DECLARE
          A : INTEGER;
          A1 : BOOLEAN := (A'ADDRESS IN MY_ADDRESS);

          PACKAGE B IS
          END B;
          B1 : BOOLEAN := (B'ADDRESS IN MY_ADDRESS);

          PROCEDURE C;
          C1 : BOOLEAN := (C'ADDRESS IN MY_ADDRESS);

          FUNCTION D RETURN BOOLEAN;
          D1 : BOOLEAN := (D'ADDRESS IN MY_ADDRESS);

          TASK E IS
          END E;
          E1 : BOOLEAN := (E'ADDRESS IN MY_ADDRESS);

          TASK TYPE F IS
          END F;
          F1 : BOOLEAN := (F'ADDRESS IN MY_ADDRESS);

          GENERIC
          PROCEDURE H;
          H1 : BOOLEAN := (H'ADDRESS IN MY_ADDRESS);

          GENERIC
          PACKAGE I IS
          END I;
          I1 : BOOLEAN := (I'ADDRESS IN MY_ADDRESS);

          G1 : BOOLEAN;

          GENERIC
          FUNCTION J RETURN BOOLEAN;
          J1 : BOOLEAN := (J'ADDRESS IN MY_ADDRESS);

          PROCEDURE C IS
          BEGIN
               NULL;
          END C;

          FUNCTION D RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END D;

          TASK BODY E IS
          BEGIN
               NULL;
          END E;

          TASK BODY F IS
          BEGIN
               NULL;
          END F;

          PROCEDURE H IS
          BEGIN
               NULL;
          END H;

          FUNCTION J RETURN BOOLEAN IS
          BEGIN
               RETURN TRUE;
          END J;

     BEGIN
<<G>>     G1 := (G'ADDRESS IN MY_ADDRESS);
     END;

     RESULT;
END AD7201A;
