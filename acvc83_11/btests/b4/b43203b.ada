-- B43203B.ADA

-- CHECK THAT A PARENTHESIZED ARRAY AGGREGATE WITH AN OTHERS CHOICE
-- IS ILLEGAL:

--   A) AS THE INITIALIZATION EXPRESSION OF (1) A CONSTRAINED CONSTANT
--      OR (2) VARIABLE OBJECT DECLARATION, (3) CONSTRAINED FORMAL
--      PARAMETER, OR (4) RECORD COMPONENT DECLARATION. 

--   B) AS THE EXPRESSION IN AN ASSIGNMENT STATEMENT.

-- EG  01/12/84
-- JBG 3/30/84
-- JBG 4/24/84

PROCEDURE B43203B IS

     TYPE COLOR IS (RED, GREEN, BLUE);
     TYPE T1 IS ARRAY(COLOR) OF INTEGER;
     TYPE T2 IS ARRAY(1 .. 2, COLOR) OF INTEGER;
     TYPE T3 IS ARRAY(1 .. 2) OF T1;
     TYPE T4 IS
          RECORD
               C1 : T1 := ((2, OTHERS => 1));               -- ERROR: A4
          END RECORD;

     AA1 : CONSTANT T1 := ((2, 3, OTHERS => -1));           -- ERROR: A1
     BA1, CA1 : T1;
     AA2 : CONSTANT T2 := ((1 .. 2 =>
                                (4, 3, OTHERS => 2)));      -- ERROR: A1
     BA2 : T2;
     AA3 : T3 := ((OTHERS => (1, 2, 3)));                   -- ERROR: A1
     BA3 : T3;
     AA4 : T4 := ((C1 => (3, 1, OTHERS => 2)));             -- OK.
     AA5 : ARRAY(1 .. 3) OF INTEGER := ((1, OTHERS => 0));  -- ERROR: A2

     PACKAGE PK IS
          GENERIC
               BA1 : T1 := ((2, OTHERS => 1));              -- ERROR: A3
          PROCEDURE PROC1 (A1 : T1 :=
                  ((-2, OTHERS => -3)));                    -- ERROR: A3
     END PK;

     USE PK;

     PACKAGE BODY PK IS
          PROCEDURE PROC1 (A1 : T1 :=
                ((-2, OTHERS => -3))) IS                    -- ERROR: A3
                   -- AN ERROR NEED NOT BE REPORTED HERE IF NOTED
                   -- AT DECLARATION OF PROCEDURE.
          BEGIN
               NULL;
          END PROC1;
          
     BEGIN
          NULL;
     END PK;

     TASK TSK1 IS
          ENTRY ENT1 (E1 : T1 := ((2, 3, OTHERS => -1)));   -- ERROR: A3
     END TSK1;

     TASK BODY TSK1 IS
     BEGIN
          ACCEPT ENT1 (E1 : T1 := ((2, 3, OTHERS => -1))) DO-- ERROR: A3
                      -- AN ERROR NEED NOT BE REPORTED HERE IF NOTED
                      -- AT DECLARATION OF ENTRY.
               NULL;
          END ENT1;
     END TSK1;

     FUNCTION FUN1 (A1 : T2 := ((1 .. 2 =>
            (3, OTHERS => -1)))) RETURN T1 IS               -- ERROR: A3
     BEGIN
          RETURN (GREEN => 1, OTHERS => -1);                -- OK.
     END FUN1;

BEGIN
     CA1 := ((-2, OTHERS => -1));                           -- ERROR: B.
     BA2 := (((-2, OTHERS => -1), (COLOR => 2)));           -- ERROR: B.
     BA3 := (((-2, OTHERS => -1), (COLOR => 2)));           -- OK.
END B43203B;
