-- B83004C.ADA

-- OBJECTIVE:
--     CHECK THAT HOMOGRAPHS ARE FORBIDDEN IN ANY OF THESE COMBINATIONS
--     OF PARTS OF A GENERIC PACKAGE, WHEN THE BODY IS A SUBUNIT:
--          A) VISIBLE-BODY.
--          B) PRIVATE-BODY.
--          C) BODY-BODY.

-- HISTORY:
--     TBN 07/25/88  CREATED ORIGINAL TEST.

PROCEDURE B83004C IS

-- CASE A:
     GENERIC
     PACKAGE PACK1 IS
          VAR1 : INTEGER := 1;
          CON1 : CONSTANT STRING := "HELLO";
          EXC1 : EXCEPTION;

          TYPE INT IS NEW INTEGER;
          SUBTYPE INT_SUBTYPE IS INTEGER RANGE 1..10;

          PACKAGE P IS
               X : INTEGER := 0;
          END P;

          TASK T;

          GENERIC
          FUNCTION FUN RETURN INTEGER;

          PROCEDURE PROC1 (X : IN INTEGER; Y : OUT BOOLEAN);
     END PACK1;


     PACKAGE BODY PACK1 IS SEPARATE;


-- CASE B:
     GENERIC
     PACKAGE PACK2 IS
          TYPE INT2 IS PRIVATE;
     PRIVATE
          VAR2 : INTEGER := 2;
          CON2 : CONSTANT STRING := "HELLO";
          EXC2 : EXCEPTION;

          TYPE INT2 IS NEW INTEGER;
          SUBTYPE INT_SUBTYPE2 IS INTEGER RANGE 2..20;

          PACKAGE P2 IS
               X : INTEGER := 0;
          END P2;

          TASK T2;

          GENERIC
          FUNCTION FUN2 RETURN INTEGER;

          PROCEDURE PROC2 (X : IN INTEGER; Y : OUT BOOLEAN);
     END PACK2;


     PACKAGE BODY PACK2 IS SEPARATE;


-- CASE C:
     GENERIC
          TYPE FUNNY_TYPE IS PRIVATE;
     PACKAGE PACK3 IS
          NEW_VAR : BOOLEAN;
          TYPE ARR1 IS ARRAY (1..50) OF CHARACTER;
          TYPE ARR2 IS ARRAY (1..25) OF ARR1;
          TYPE ARR3 IS ARRAY (1..20) OF ARR2;
          TYPE ARR4 IS ARRAY (1..15) OF ARR3;
          TYPE ARR5 IS ARRAY (1..10) OF ARR4;
          TYPE ARR6 IS ARRAY (1.. 5) OF ARR5;
          ARRAY_OBJECT : ARR6;

          FUNCTION FUNNY (A : FUNNY_TYPE) RETURN FUNNY_TYPE;

     END PACK3;


     PACKAGE BODY PACK3 IS SEPARATE;


BEGIN
     NULL;
END B83004C;



SEPARATE (B83004C)
PACKAGE BODY PACK1 IS

     VAR1 : CONSTANT STRING := "HELLO";                        -- ERROR:
     CON1 : INTEGER := 1;                                      -- ERROR:
     INT : EXCEPTION;                                          -- ERROR:
     TYPE EXC1 IS NEW INTEGER;                                 -- ERROR:
     SUBTYPE P IS INTEGER RANGE 1..10;                         -- ERROR:
     PACKAGE INT_SUBTYPE IS                                    -- ERROR:
          X : INTEGER := 0;
     END INT_SUBTYPE;
     TASK FUN;                                                 -- ERROR:
     GENERIC
          TYPE NEW_TYPE IS PRIVATE;
     FUNCTION T RETURN NEW_TYPE;                               -- ERROR:
     PROCEDURE PROC1 (A : IN INTEGER; B : OUT BOOLEAN);        -- ERROR:

     TASK BODY T IS
     BEGIN
          NULL;
     END T;

     FUNCTION FUN RETURN INTEGER IS
     BEGIN
          RETURN 1;
     END FUN;

     PROCEDURE PROC1 (X : IN INTEGER; Y : OUT BOOLEAN) IS
     BEGIN
          IF X = 1 THEN
               Y := TRUE;
          ELSE
               Y := FALSE;
          END IF;
     END PROC1;

END PACK1;


SEPARATE (B83004C)
PACKAGE BODY PACK2 IS

     EXC2 : INTEGER := 2;                                      -- ERROR:
     P2 : CONSTANT STRING := "HELLO";                          -- ERROR:
     INT2 : EXCEPTION;                                         -- ERROR:

     TYPE VAR2 IS NEW INTEGER;                                 -- ERROR:
     SUBTYPE CON2 IS INTEGER RANGE 2..20;                      -- ERROR:

     PACKAGE T2 IS                                             -- ERROR:
          X : INTEGER := 0;
     END T2;

     TASK FUN2;                                                -- ERROR:

     GENERIC
     FUNCTION INT_SUBTYPE2 RETURN INTEGER;                     -- ERROR:

     PROCEDURE PROC2 (A : IN INTEGER; B : OUT BOOLEAN);        -- ERROR:


     TASK BODY T2 IS
     BEGIN
          NULL;
     END T2;

     FUNCTION FUN2 RETURN INTEGER IS
     BEGIN
          RETURN 1;
     END FUN2;

     PROCEDURE PROC2 (X : IN INTEGER; Y : OUT BOOLEAN) IS
     BEGIN
          IF X = 1 THEN
               Y := TRUE;
          ELSE
               Y := FALSE;
          END IF;
     END PROC2;

END PACK2;


SEPARATE (B83004C)
PACKAGE BODY PACK3 IS
     VAR3 : INTEGER := 3;
     CON3 : CONSTANT STRING := "HELLO";
     EXC3 : EXCEPTION;

     TYPE INT3 IS NEW INTEGER;
     SUBTYPE INT_SUBTYPE3 IS INTEGER RANGE 3..30;

     PACKAGE P3 IS
          X : INTEGER := 0;
     END P3;

     TASK T3;

     GENERIC
     FUNCTION FUN3 RETURN INTEGER;

     PROCEDURE PROC3 (X : IN INTEGER; Y : OUT BOOLEAN);

     T3 : INTEGER := 3;                                        -- ERROR:
     EXC3 : CONSTANT STRING := "HELLO";                        -- ERROR:
     CON3 : EXCEPTION;                                         -- ERROR:

     TYPE FUN3 IS NEW INTEGER;                                 -- ERROR:
     SUBTYPE P3 IS INTEGER RANGE 3..30;                        -- ERROR:

     PACKAGE INT_SUBTYPE3 IS                                   -- ERROR:
          X : INTEGER := 0;
     END INT_SUBTYPE3;

     TASK VAR3;                                                -- ERROR:

     GENERIC
     FUNCTION INT3 RETURN INTEGER;                             -- ERROR:

     PROCEDURE PROC3 (A : IN INTEGER; B: OUT BOOLEAN);         -- ERROR:


     FUNCTION FUNNY (A : FUNNY_TYPE) RETURN FUNNY_TYPE IS
     BEGIN
          RETURN A;
     END FUNNY;

     TASK BODY T3 IS
     BEGIN
          NULL;
     END T3;

     FUNCTION FUN3 RETURN INTEGER IS
     BEGIN
          RETURN 1;
     END FUN3;

     PROCEDURE PROC3 (X : IN INTEGER; Y : OUT BOOLEAN) IS
     BEGIN
          IF X = 1 THEN
               Y := TRUE;
          ELSE
               Y := FALSE;
          END IF;
     END PROC3;

END PACK3;
