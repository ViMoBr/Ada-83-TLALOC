-- B83004B1.ADA

-- OBJECTIVE:
--     PACKAGE BODIES FOR MAIN PROCEDURE (B83004B0M).

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE TO IMPLEMENTATIONS THAT SUPPORT
--     SEPARATE COMPILATION OF GENERIC SPECIFICATIONS AND BODIES.

-- HISTORY:
--     TBN 07/25/88  CREATED ORIGINAL TEST.

-- CASE A:
PACKAGE BODY B83004B_PACK1 IS

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

END B83004B_PACK1;


-- CASE B:
PACKAGE BODY B83004B_PACK2 IS

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

END B83004B_PACK2;


-- CASE C:
PACKAGE BODY B83004B_PACK3 IS
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

END B83004B_PACK3;
