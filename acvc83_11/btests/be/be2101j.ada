-- BE2101J.ADA

-- CHECK THAT DIRECT_IO CANNOT BE INSTANTIATED WITH LIMITED TYPES,
-- INCLUDING TASK TYPES AND COMPOSITE TYPES CONTAINING LIMITED
-- COMPONENTS.

-- TBN 2/12/86

WITH DIRECT_IO;

PROCEDURE BE2101J IS

     TASK TYPE TSK IS
          ENTRY E1;
     END TSK;

     TYPE ARR IS ARRAY (1 .. 10) OF TSK;

     TYPE REC IS RECORD
          T : TSK;
          AR : ARR;
     END RECORD;

     TYPE RC (D : INTEGER := 1) IS RECORD
          C1 : INTEGER;
          CASE D IS
               WHEN 1 .. 10 =>
                    C2 : TSK;
               WHEN 11 .. 20 =>
                    C3 : ARR;
               WHEN 21 .. 30 =>
                    C4 : REC;
               WHEN OTHERS =>
                    C5 : INTEGER;
          END CASE;
     END RECORD;

     PACKAGE PV IS
          TYPE LP IS LIMITED PRIVATE;
     PRIVATE
          TYPE LP IS NEW INTEGER RANGE 1 .. 10;
     END PV;

     TYPE NARR IS NEW ARR;
     TYPE NRC IS NEW RC (13);
     SUBTYPE SRC IS RC (35);

     USE PV;

     PACKAGE D1 IS NEW DIRECT_IO (LP);            -- ERROR: LP.
     PACKAGE D2 IS NEW DIRECT_IO (TSK);           -- ERROR: TSK.
     PACKAGE D3 IS NEW DIRECT_IO (ARR);           -- ERROR: ARR.
     PACKAGE D4 IS NEW DIRECT_IO (REC);           -- ERROR: REC.
     PACKAGE D5 IS NEW DIRECT_IO (RC);            -- ERROR: RC.
     PACKAGE D6 IS NEW DIRECT_IO (NARR);          -- ERROR: NARR.
     PACKAGE D8 IS NEW DIRECT_IO (NRC);           -- ERROR: NRC.
     PACKAGE D9 IS NEW DIRECT_IO (SRC);           -- ERROR: SRC.

     TASK BODY TSK IS
     BEGIN
          NULL;
     END TSK;

BEGIN
     NULL;
END BE2101J;
