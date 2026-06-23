-- B43202B.ADA

-- CHECK THAT AN ARRAY AGGREGATE WITH AN OTHERS CHOICE IS
-- ILLEGAL:

--   A) IN THE DECLARATION OF AN OBJECT OR FORMAL PARAMETER (OF
--      A SUBPROGRAM, ENTRY, OR GENERIC UNIT) WHEN THE OBJECT
--      OR PARAMETER HAS A CONSTRAINED ARRAY SUBTYPE AND ADDITIONAL
--      NAMED ASSOCIATIONS ARE USED IN THE AGGREGATE.

--   B) IN AN ASSIGNMENT STATEMENT WHEN ADDITIONAL NAMED ASSOCIA-
--      TIONS ARE USED IN THE AGGREGATE.

--   C) AS A GENERIC ACTUAL PARAMETER WHEN ADDITIONAL NAMED ASSOCIATIONS
--      ARE USED IN THE AGGREGATE, AND THE FORMAL IS CONSTRAINED.

-- EG  01/06/84
-- JBG 3/30/84

PROCEDURE B43202B IS

     TYPE COLOR IS (RED, GREEN, BLUE);
     TYPE T1 IS ARRAY(COLOR) OF INTEGER;
     TYPE T2 IS ARRAY(1 .. 2, COLOR) OF INTEGER;
     TYPE T3 IS ARRAY(1 .. 2) OF T1;

     AA1 : T1 := (RED => 1, OTHERS => 0);              -- ERROR: A.
     BA1, CA1 : T1;
     AA2 : T2 := (1 => (1, 2, 3), OTHERS => (4, 5, 6));   -- ERROR: A.
     BA2 : T2;
     AA3 : T3 := (1 => (1, 2, 3), OTHERS => (4, 5, 6));   -- ERROR: A.
     BA3 : T3;

     PACKAGE PK IS
          GENERIC
               AA1 : T1 := (RED => 2, OTHERS => 1);    -- ERROR: A.
          PROCEDURE PROC1 (A1 : T1 :=
                  (RED | BLUE => -2, OTHERS => -3));   -- ERROR: A.
     END PK;

     USE PK;

     PACKAGE BODY PK IS
          PROCEDURE PROC1 (A1 : T1 :=
                  (RED | BLUE => -2, OTHERS => -3)) IS -- ERROR: A.
                   -- AN ERROR NEED NOT BE REPORTED HERE IF NOTED
                   -- AT DECLARATION OF PROCEDURE.
          BEGIN
               NULL;
          END PROC1;
          
          PROCEDURE PROC2 IS
              NEW PROC1 ((GREEN => 2, OTHERS => 1));   -- ERROR: C.
     BEGIN
          NULL;
     END PK;

     TASK TSK1 IS
          ENTRY ENT1 (E1 : T1 := (GREEN => 2, RED => 3,
                                  OTHERS => -1));      -- ERROR: A.
     END TSK1;

     TASK BODY TSK1 IS
     BEGIN
          ACCEPT ENT1 (E1 : T1 := (GREEN => 2, RED => 3,
                                   OTHERS => -1)) DO   -- ERROR: A.
                      -- AN ERROR NEED NOT BE REPORTED HERE IF NOTED
                      -- AT DECLARATION OF ENTRY.
               NULL;
          END ENT1;
     END TSK1;

     FUNCTION FUN1 (A1 : T2 := (1 .. 2 =>
            (BLUE => 3, OTHERS => -1))) RETURN T1 IS   -- ERROR: A.
     BEGIN
          RETURN (GREEN => 1, OTHERS => -1);           -- OK.
     END FUN1;

BEGIN
     BA1 := FUN1((1 .. 2 =>
                 (BLUE => -2, OTHERS => -3)));         -- OK.
     TSK1.ENT1((RED => -2, OTHERS => -1));             -- OK.
     CA1 := (GREEN => 1, OTHERS => -1);                -- ERROR: B.
     BA2 := (1 .. 2 => (GREEN => 1, OTHERS => -1));    -- ERROR: B.
     BA3 := (1 .. 2 => (GREEN => 2, OTHERS => -2));    -- OK.
END B43202B;
