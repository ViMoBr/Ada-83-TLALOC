-- BC3204E.ADA

-- CHECK THAT AN INSTANTIATION IS ILLEGAL WHEN A LIMITED/NON-LIMITED
-- FORMAL PRIVATE TYPE IS USED AS THE PARENT TYPE IN A DERIVED TYPE
-- DEFINITION APPEARING IN THE FULL DECLARATION OF A PRIVATE TYPE,
-- AND THE ACTUAL TYPE IS AN UNCONSTRAINED ARRAY TYPE OR AN
-- UNCONSTRAINED TYPE WITH DISCRIMINANTS WITHOUT DEFAULTS.

-- TEST WHEN THE ACTUAL PARAMETER IS A GENERIC FORMAL TYPE OF AN
-- ENCLOSING GENERIC UNIT.

-- SPS 7/13/82

PROCEDURE BC3204E IS

     GENERIC
          TYPE PRIV(D : INTEGER) IS PRIVATE;
          TYPE LIM(D : INTEGER) IS LIMITED PRIVATE;
          TYPE CARR IS ARRAY(INTEGER) OF INTEGER;
          TYPE UARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;

     PACKAGE PACK IS

          SUBTYPE CPR IS PRIV(D => 3);
          SUBTYPE CLIM IS LIM(D => 5);

          GENERIC
               TYPE PV IS PRIVATE;
               TYPE LP IS LIMITED PRIVATE;
               TYPE P IS PRIVATE;
               TYPE L IS LIMITED PRIVATE;
          PACKAGE PK IS END PK;
     END PACK;

     PACKAGE BODY PACK IS

          PACKAGE BODY PK IS

               SUBTYPE SP IS P;
               SUBTYPE SL IS L;

               TYPE DP IS NEW SP;
               TYPE DL IS NEW SL;
               SUBTYPE SDL IS DL;

               PACKAGE PRIV IS
                    TYPE PP IS PRIVATE;
                    TYPE PL IS LIMITED PRIVATE;
                    TYPE PPV IS PRIVATE;
                    TYPE PLP IS LIMITED PRIVATE;

               PRIVATE
                    TYPE PP IS NEW DP;  -- POTENTIALLY ILLEGAL.
                    TYPE PL IS NEW SDL; -- POTENTIALLY ILLEGAL.
                    TYPE PPV IS NEW PV; -- POTENTIALLY ILLEGAL.
                    TYPE PLP IS NEW LP; -- POTENTIALLY ILLEGAL.
               END PRIV;

          BEGIN
               NULL;
          END PK;

     BEGIN
          DECLARE
               PACKAGE N1 IS NEW PK(PRIV, CLIM, CPR, CLIM); -- ERROR:
                                             -- PRIV IS UNCONSTRAINED.
               PACKAGE N2 IS NEW PK(CPR, LIM, CPR, CLIM);   -- ERROR:
                                             -- LIM IS UNCONSTRAINED.
               PACKAGE N3 IS NEW PK(CPR, CLIM, PRIV, CLIM); -- ERROR:
                                             -- PRIV IS UNCONSTRAINED.
               PACKAGE N4 IS NEW PK(CPR, CLIM, CPR, LIM);   -- ERROR:
                                             -- LIM IS UNCONSTRAINED.

               PACKAGE N5 IS NEW PK(UARR, CARR, CARR, CARR);-- ERROR:
                                             -- UARR IS UNCONSTRAINED.
               PACKAGE N6 IS NEW PK(CARR, UARR, CARR, CARR);-- ERROR:
                                             -- UARR IS UNCONSTRAINED.
               PACKAGE N7 IS NEW PK(CARR, CARR, UARR, CARR);-- ERROR: 
                                             -- UARR IS UNCONSTRAINED.
               PACKAGE N8 IS NEW PK(CARR, CARR, CARR, UARR);-- ERROR: 
                                             -- UARR IS UNCONSTRAINED.
               PACKAGE N9 IS NEW PK(CPR, CLIM, CPR, CLIM);    -- OK.
          BEGIN
               NULL;
          END;
     END PACK;

BEGIN
     NULL;
END BC3204E;
