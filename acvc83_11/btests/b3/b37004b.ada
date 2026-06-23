-- B37004B.ADA

-- CHECK THAT A DEFAULT RECORD COMPONENT INITIALIZATION
-- CANNOT BE SPECIFIED FOR A COMPONENT THAT HAS TYPE
-- TASK, LIMITED PRIVATE, OR COMPOSITE CONTAINING EITHER.

-- DAT 6/18/81
-- JRK 6/6/84

PROCEDURE B37004B IS

     PACKAGE PK IS

          TYPE L IS LIMITED PRIVATE;
          TASK TYPE T;

          TYPE A IS ARRAY(1..1) OF L;
          TYPE B IS ARRAY(1..1) OF T;

          TYPE R1 IS RECORD
               C : L;
          END RECORD;

          TYPE R2 IS RECORD
               C : T;
          END RECORD;

          CL : CONSTANT L;
          TSK : T;

          FUNCTION FA RETURN A;
          FUNCTION FB RETURN B;
          FUNCTION FR1 RETURN R1;
          FUNCTION FR2 RETURN R2;

          TYPE R3 IS RECORD
               C1 : L := CL;            -- ERROR: NO := FOR L.
               C2 : T := TSK;           -- ERROR: NO := FOR T.
               C3 : A := FA;            -- ERROR: NO := FOR A.
               C4 : B := FB;            -- ERROR: NO := FOR B.
               C5 : R1 := FR1;          -- ERROR: NO := FOR R1.
               C6 : R2 := FR2;          -- ERROR: NO := FOR R2.
               C7 : B;                  -- OK.
          END RECORD;

     PRIVATE

          TYPE L IS (E);
          CL : CONSTANT L := E;

          TYPE R4 IS RECORD
               C1 : L := CL;            -- OK.
               C2 : T := TSK;           -- ERROR: NO := FOR T.
               C3 : A := FA;            -- OK.
               C4 : B := FB;            -- ERROR: NO := FOR B.
               C5 : R1 := FR1;          -- OK.
               C6 : R2 := FR2;          -- ERROR: NO := FOR R2.
          END RECORD;

     END PK; 

     USE PK;

     TYPE R5 IS RECORD
          C1 : L := CL;                 -- ERROR: NO := FOR L.
          C2 : T := TSK;                -- ERROR: NO := FOR T.
          C3 : A := FA;                 -- ERROR: NO := FOR A.
          C4 : B := FB;                 -- ERROR: NO := FOR B.
          C5 : R1 := FR1;               -- ERROR: NO := FOR R1.
          C6 : R2 := FR2;               -- ERROR: NO := FOR R2.
     END RECORD;

     O1 : L;                            -- OK.
     O2 : T;                            -- OK.
     O3 : A;                            -- OK.
     O4 : B;                            -- OK.
     O5 : R1;                           -- OK.
     O6 : R2;                           -- OK.

     PACKAGE BODY PK IS

          TYPE R6 IS RECORD
               C1 : L := CL;            -- OK.
               C2 : T := TSK;           -- ERROR: NO := FOR T.
               C3 : A := FA;            -- OK.
               C4 : B := FB;            -- ERROR: NO := FOR B.
               C5 : R1 := FR1;          -- OK.
               C6 : R2 := FR2;          -- ERROR: NO := FOR R2.
          END RECORD;

          TASK BODY T IS
          BEGIN
               NULL;
          END T;

          FUNCTION FA RETURN A IS
          BEGIN
               RETURN O3;
          END FA;

          FUNCTION FB RETURN B IS
          BEGIN
               RETURN O4;
          END FB;

          FUNCTION FR1 RETURN R1 IS
          BEGIN
               RETURN O5;
          END FR1;

          FUNCTION FR2 RETURN R2 IS
          BEGIN
               RETURN O6;
          END FR2;

     END PK;

BEGIN
     NULL;
END B37004B;
