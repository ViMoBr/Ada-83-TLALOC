-- BC1226A.ADA

-- OBJECTIVE:
--     CHECK THAT ONLY CORRECT OPERATIONS ARE AVAILABLE FOR GENERIC
--     FORMAL PRIVATE TYPES.

-- HISTORY:
--     DAT 09/18/81  CREATED ORIGINAL TEST.
--     SPS 05/04/82
--     JBG 04/22/83
--     BCB 08/01/88  MODIFIED HEADER FORMAT, ADDED OPTIONAL ERR
--                   MESSAGES, DELETED ALL ALLOWABLE OPERATIONS.

WITH SYSTEM; USE SYSTEM;
PROCEDURE BC1226A IS

     GENERIC
          TYPE T IS PRIVATE;
          TYPE U IS LIMITED PRIVATE;
          TYPE T1 (B : BOOLEAN) IS PRIVATE;
          TYPE U1 (B : BOOLEAN) IS LIMITED PRIVATE;
     PACKAGE PKG IS
          VT : T;
          VU : U;
          XT : T(TRUE);                      -- ERROR: CONSTRAINED.
          XU : U(TRUE);                      -- ERROR: CONSTRAINED.
          CU : CONSTANT U := VU;             -- ERROR: LIMITED.
          SUBTYPE S0 IS T (TRUE);            -- ERROR: (TRUE).
          SUBTYPE S00 IS U (TRUE);           -- ERROR: (TRUE).
          CU1 : CONSTANT SU1 := VU1;         -- ERROR: LIMITED.
          DCT : CONSTANT T;                  -- ERROR: DEFERRED.
          DCU : CONSTANT U;                  -- ERROR: DEFERRED.
          DCT1 : CONSTANT ST1;               -- ERROR: DEFERRED.
          DCU1 : CONSTANT SU1;               -- ERROR: DEFERRED.
          OX1 : ST := T(VU);                 -- ERROR: VU.
          OX2 : ST1 := ST1'(VU1);            -- ERROR: VU1.
          NUMBER : CONSTANT := CT;           -- ERROR: NO TYPE.
          TYPE AU IS ACCESS U;
          TYPE AU1 IS ACCESS U1;
          VAU : AU := NEW U'(VU);            -- ERROR: INITIAL VALUE.
          VAU2 : AU := NEW U (TRUE);         -- ERROR: CONSTRAINT.
          B : BOOLEAN;
          INT : INTEGER;
          ADR : ADDRESS;
     PRIVATE
          DCT : CONSTANT T := VT;            -- OPTIONAL ERR MESSAGE:
          DCT1 : CONSTANT ST1 := OST1;       -- OPTIONAL ERR MESSAGE:
     END PKG;

     PACKAGE BODY PKG IS
     BEGIN
          B := VT'CONSTRAINED;               -- ERROR: OBJECT.
          B := VU'CONSTRAINED;               -- ERROR: OBJECT.
          B := VT > VT ;                     -- ERROR: PRIVATE.
          B := VU = VU ;                     -- ERROR: LIMITED.
          B := VT <= CT ;                    -- ERROR: PRIVATE.
          B := VT + VT = VT ;                -- ERROR: PRIVATE.
          B := VU.B ;                        -- ERROR: B.
          B := U'ADDRESS /= U'ADDRESS;       -- ERROR: U.
          B := VT IN VT .. VT ;              -- ERROR: .. .
          B := VT ** 2 /= 0 ;                -- ERROR: **.
          B := ABS (VT) /= VT ;              -- ERROR: PRIVATE.

          DECLARE
               B : BOOLEAN := V = V;         -- ERROR: V IS LIMITED.
          BEGIN
               VU := VU;                     -- ERROR: LIMITED.
               VU1 := VU1;                   -- ERROR: LIMITED.
          END;

     END;
BEGIN
     NULL;
END BC1226A;
