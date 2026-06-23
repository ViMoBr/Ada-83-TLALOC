-- B43203A.ADA

-- CHECK THAT A PARENTHESIZED ARRAY AGGREGATE WITH AN OTHERS CHOICE
-- IS ILLEGAL:

--   A) AS AN ACTUAL IN PARAMETER OF A SUBPROGRAM CALL, ENTRY CALL,
--      OR GENERIC INSTANTIATION, WHEN THE FORMAL PARAMETER IS
--      CONSTRAINED.

--   B) AS THE RESULT EXPRESSION OF A FUNCTION WHEN THE RESULT
--      TYPE IS CONSTRAINED.

--   C) AS THE OPERAND IN A QUALIFIED EXPRESSION WHEN THE TYPE MARK
--      DENOTES A CONSTRAINED ARRAY SUBTYPE.

--   D) AS AN EXPRESSION SPECIFYING THE VALUE OF AN ARRAY OR RECORD
--      COMPONENT.

-- EG  01/12/84
-- JBG 3/21/84

PROCEDURE B43203A IS

     TYPE T1 IS ARRAY(1 .. 5) OF INTEGER;
     TYPE T2 IS ARRAY(1 .. 2) OF T1;
     TYPE T3 IS
          RECORD
               C1 : T1;
          END RECORD;
     TYPE T4 IS ARRAY(1 .. 1) OF T1;
     TYPE T5 IS ARRAY(1 .. 2, 1 .. 5) OF INTEGER;

     AA1, BA1, CA1 : T1;
     AA2 : T2;
     AA3 : T3;
     AA4, BA4 : T4;
     AA5 : T5;

     PACKAGE PK IS
          GENERIC
               AA1 : T1;
          PROCEDURE PROC1 (A1 : T1);
     END PK;

     USE PK;

     PACKAGE BODY PK IS
          PROCEDURE PROC1 (A1 : T1) IS
          BEGIN
               NULL;
          END PROC1;
          
          PROCEDURE PROC2 IS
                 NEW PROC1 (((4, 3, 2, OTHERS => 1)));  -- ERROR: A.
     BEGIN
          NULL;
     END PK;

     TASK TSK1 IS
          ENTRY ENT1 (E1 : T1);
     END TSK1;

     TASK BODY TSK1 IS
     BEGIN
          ACCEPT ENT1 (E1 : T1) DO
               NULL;
          END ENT1;
     END TSK1;

     FUNCTION FUN1 (A1 : T1) RETURN T1 IS
     BEGIN
          RETURN ((2 => 1, OTHERS => -1));             -- ERROR: B.
          RETURN ((1, OTHERS => 2));                   -- ERROR: B.
     END FUN1;

     FUNCTION FUN2 (A5 : T5) RETURN T5 IS
     BEGIN
          RETURN ((1 .. 2 => (1 => 1, OTHERS => 0)));  -- ERROR: B.
     END FUN2;

     PROCEDURE PROC3 (A1 : T1) IS
     BEGIN
          NULL;
     END PROC3;

BEGIN
     BA1 := (1, 2, OTHERS => 3);                        -- OK.
     IF ( T1'(((1 | 3 | 5 => 2, OTHERS => 1))) = BA1 )  -- ERROR: C.
        THEN NULL;
     END IF;
     IF ( T1'((1 | 3 | 5 => 2, OTHERS => 1)) = BA1 )  -- OK.
        THEN NULL;
     END IF;
     PROC3 (((4 => -1, 2 => -2, OTHERS => -3)));        -- ERROR: A.
     TSK1.ENT1(((-5, -4, -3, -2, OTHERS => -1)));       -- ERROR: A.
     CA1 := ((4), OTHERS => -3);                        -- OK.
     AA2 := (((1, 3, OTHERS => -1)), (1 .. 5 => -1));   -- ERROR: D.
     AA3 := (C1 => ((-1, -3, OTHERS => -2)));           -- ERROR: D.
     AA4 := (1 => ((1, 2, 3, 4, 5)));                   -- OK.
     BA4 := (1 => ((1, 3, 1, OTHERS => -1)));           -- ERROR: D.
     AA5 := (((1, OTHERS => 0)), (1, 2, 3, 4, 5));      -- ERROR: D.
     AA5 := T5'((1 .. 5 => 0), ((OTHERS => 1)));        -- ERROR: D.
     AA5 := FUN2((1 .. 2 => ((1 => 1, OTHERS => 0))));  -- ERROR: D.
END B43203A;
