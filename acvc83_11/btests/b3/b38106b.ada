-- B38106B.ADA

-- CHECK THAT FOR AN ACCESS TYPE WHOSE DESIGNATED TYPE IS AN INCOMPLETE
-- TYPE, ADDITIONAL OPERATIONS FOR THE ACCESS TYPE WHICH DEPEND ON
-- CHARACTERISTICS OF THE FULL DECLARATION OF THE INCOMPLETE TYPE ARE
-- NOT DECLARED BEFORE THE EARLIEST PLACE WITHIN THE IMMEDIATE SCOPE OF
-- THE ACCESS TYPE DECLARATION AND AFTER THE FULL DECLARATION OF THE
-- INCOMPLETE TYPE.

-- (1) CHECK FOR COMPONENT SELECTION WITH RECORD TYPES
-- (2) CHECK FOR INDEXED COMPONENTS AND SLICES WITH ARRAY TYPES
-- (3) CHECK FOR USE OF 'FIRST, 'LAST, 'RANGE, AND 'LENGTH WITH ARRAY
--     TYPES

-- PART 2 : FULL DECLARATION OF INCOMPLETE TYPE IN PACKAGE BODY

-- DSJ 5/2/83
-- JBG 10/24/83

PROCEDURE B38106B IS

     PACKAGE PACK1 IS
     PRIVATE
          TYPE T1; 
          TYPE T2; 
     END PACK1; 

     PACKAGE BODY PACK1 IS

          PACKAGE PACK2 IS
               TYPE ACC1 IS ACCESS T1; 
               TYPE ACC2 IS ACCESS T2; 
          END PACK2; 

          TYPE T1 IS ARRAY ( 1 .. 2 ) OF INTEGER; 
          TYPE T2 IS
               RECORD
                    C1, C2 : INTEGER; 
               END RECORD; 

          A1 : PACK2.ACC1 := NEW T1'(2,4);   -- LEGAL
          A2 : PACK2.ACC1 := NEW T1'(6,8);   -- LEGAL
          R1 : PACK2.ACC2 := NEW T2'(3,5);   -- LEGAL
          R2 : PACK2.ACC2 := NEW T2'(7,9);   -- LEGAL

          X1 : INTEGER := A1(1);             -- ERROR: A1(1)
          Y1 : INTEGER := A1.ALL(1);         -- OK.
          S1 : T1      := A1(1..2);          -- ERROR: (1..2).
          S2 : T1      := A1.ALL(1..2);      -- OK.
          X2 : INTEGER := A1'FIRST;          -- ERROR: A1'FIRST
          Y2 : INTEGER := A1.ALL'FIRST;      -- OK.
          X3 : INTEGER := A1'LAST;           -- ERROR: A1'LAST
          Y3 : INTEGER := A1.ALL'LAST;       -- OK.
          X4 : INTEGER := A1'LENGTH;         -- ERROR: A1'LENGTH
          Y4 : INTEGER := A1.ALL'LENGTH;     -- OK.
          B1 : BOOLEAN := 3 IN A1'RANGE;     -- ERROR: A1'RANGE
          B2 : BOOLEAN := 3 IN A1.ALL'RANGE; -- OK.

          X5 : INTEGER := R1.C1;             -- ERROR: R1.C1
          Y5 : INTEGER := R1.ALL.C1;         -- OK.

          PACKAGE BODY PACK2 IS
               X1 : INTEGER := A1(1);             -- OK: A1(1)
               Y1 : INTEGER := A1.ALL(1);         -- OK.
               S1 : T1      := A1(1..2);          -- OK: (1..2).
               S2 : T1      := A1.ALL(1..2);      -- OK.
               X2 : INTEGER := A1'FIRST;          -- OK: A1'FIRST
               Y2 : INTEGER := A1.ALL'FIRST;      -- OK.
               X3 : INTEGER := A1'LAST;           -- OK: A1'LAST
               Y3 : INTEGER := A1.ALL'LAST;       -- OK.
               X4 : INTEGER := A1'LENGTH;         -- OK: A1'LENGTH
               Y4 : INTEGER := A1.ALL'LENGTH;     -- OK.
               B1 : BOOLEAN := 3 IN A1'RANGE;     -- OK: A1'RANGE
               B2 : BOOLEAN := 3 IN A1.ALL'RANGE; -- OK.

               X5 : INTEGER := R1.C1;             -- OK: R1.C1
               Y5 : INTEGER := R1.ALL.C1;         -- OK.
          END PACK2;

     END PACK1; 

BEGIN

     NULL; 

END B38106B; 
