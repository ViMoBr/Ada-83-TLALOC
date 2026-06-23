-- BC3205E.ADA

-- CHECK THAT AN INSTANTIATION IS ILLEGAL IF A FORMAL LIMITED/NON-
-- LIMITED PRIVATE TYPE IS USED IN AN ALLOCATOR, A VARIABLE OBJECT
-- DECLARATION, A RECORD COMPONENT DECLARATION, OR AN ARRAY TYPE
-- DEFINITION WHEN THE ACTUAL PARAMETER IS AN UNCONSTRAINED ARRAY TYPE
-- OR AN UNCONSTRAINED TYPE WITH DISCRIMINANTS THAT DO NOT HAVE
-- DEFAULTS.

-- TEST WHEN THE ACTUAL PARAMETER IS A FORMAL PARAMETER OF AN ENCLOSING
-- GENERIC UNIT.

-- SPS 7/14/82

PROCEDURE BC3205E IS

     GENERIC
          TYPE UARR IS ARRAY(INTEGER RANGE <>) OF INTEGER;
          TYPE PRIV (D : INTEGER) IS PRIVATE;
     PACKAGE PACK IS
          SUBTYPE CARR IS UARR (1..3);
          SUBTYPE CPRIV IS PRIV (D => 5);
          REC1 : CPRIV;
          REC2 : PRIV (D =>5);
          AR1 : CARR;
          AR2 : UARR (1 .. 3);

          GENERIC
               TYPE P IS PRIVATE;
               TYPE L IS LIMITED PRIVATE;
               TYPE PV IS PRIVATE;
               TYPE LP IS LIMITED PRIVATE;
               TYPE PVT IS PRIVATE;
               TYPE LMP IS LIMITED PRIVATE;
               TYPE PRV IS PRIVATE;
               TYPE LIM IS LIMITED PRIVATE;
          PACKAGE PK IS END PK;

          GENERIC
               TYPE P IS PRIVATE;
               POBJ : P;
          PACKAGE GP IS
               CP : CONSTANT P := POBJ;      -- OK.
          END GP;
     END PACK;

     PACKAGE BODY PACK IS

          PACKAGE BODY PK IS

               TYPE AP IS ACCESS P;
               TYPE AL IS ACCESS L;
               NP : AP := NEW P;             -- POTENTIALLY ILLEGAL.
               NL : AL := NEW L;             -- POTENTIALLY ILLEGAL.
               VP : PV;                      -- POTENTIALLY ILLEGAL.
               VL : LP;                      -- POTENTIALLY ILLEGAL.

               TYPE RC IS RECORD
                    RCP : PRV;               -- POTENTIALLY ILLEGAL.
                    RCL : LIM;               -- POTENTIALLY ILLEGAL.
               END RECORD;
     
               TYPE ARP IS ARRAY (INTEGER) OF PVT;-- POTENTIALLY 
                                                  -- ILLEGAL.
               TYPE ARL IS ARRAY (INTEGER) OF LMP;-- POTENTIALLY
                                                  -- ILLEGAL.

          BEGIN
               NULL;
          END PK;

     BEGIN
          DECLARE
          PACKAGE N1 IS NEW PK(CPRIV, CPRIV, CPRIV, CPRIV,
               CPRIV, CPRIV, CPRIV, CPRIV);            -- OK.
          PACKAGE N2 IS NEW PK(PRIV, CPRIV, CPRIV, CPRIV,
               CPRIV, CPRIV, CPRIV, CPRIV);            -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.
          PACKAGE N3 IS NEW PK(CPRIV, PRIV, CPRIV, CPRIV,
               CPRIV, CPRIV, CPRIV, CPRIV);            -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.
          PACKAGE N4 IS NEW PK(CPRIV, CPRIV, PRIV, CPRIV,
               CPRIV, CPRIV, CPRIV, CPRIV);            -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.
          PACKAGE N5 IS NEW PK(CPRIV, CPRIV, CPRIV, PRIV,
               CPRIV, CPRIV, CPRIV, CPRIV);            -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.
          PACKAGE N6 IS NEW PK(CPRIV, CPRIV, CPRIV, CPRIV,
               PRIV, CPRIV, CPRIV, CPRIV);             -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.
          PACKAGE N7 IS NEW PK(CPRIV, CPRIV, CPRIV, CPRIV,
               CPRIV, PRIV, CPRIV, CPRIV);             -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.
          PACKAGE N8 IS NEW PK(CPRIV, CPRIV, CPRIV, CPRIV,
               CPRIV, CPRIV, PRIV, CPRIV);             -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.
          PACKAGE N9 IS NEW PK(CPRIV, CPRIV, CPRIV, CPRIV,
               CPRIV, CPRIV, CPRIV, PRIV);             -- ERROR: PRIV IS
                                                       -- UNCONSTRAINED.

          PACKAGE P1 IS NEW PK(CARR, CARR, CARR, CARR,
               CARR, CARR, CARR, CARR);                -- OK.
          PACKAGE P2 IS NEW PK(UARR, CARR, CARR, CARR,
               CARR, CARR, CARR, CARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.
          PACKAGE P3 IS NEW PK(CARR, UARR, CARR, CARR,
               CARR, CARR, CARR, CARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.
          PACKAGE P4 IS NEW PK(CARR, CARR, UARR, CARR,
               CARR, CARR, CARR, CARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.
          PACKAGE P5 IS NEW PK(CARR, CARR, CARR, UARR,
               CARR, CARR, CARR, CARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.
          PACKAGE P6 IS NEW PK(CARR, CARR, CARR, CARR,
               UARR, CARR, CARR, CARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.
          PACKAGE P7 IS NEW PK(CARR, CARR, CARR, CARR,
               CARR, UARR, CARR, CARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.
          PACKAGE P8 IS NEW PK(CARR, CARR, CARR, CARR,
               CARR, CARR, UARR, CARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.
          PACKAGE P9 IS NEW PK(CARR, CARR, CARR, CARR,
               CARR, CARR, CARR, UARR);                -- ERROR: UARR IS
                                                       -- UNCONSTRAINED.

          PACKAGE G1 IS NEW GP(CPRIV, REC1);           -- OK.
          PACKAGE G2 IS NEW GP(PRIV, REC2);            -- OK.
          PACKAGE G3 IS NEW GP(CARR, AR1);             -- OK.
          PACKAGE G4 IS NEW GP(UARR, AR2);             -- OK.

          BEGIN
               NULL;
          END;
     END PACK;

BEGIN
     NULL;
END BC3205E;
