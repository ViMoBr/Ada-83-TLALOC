-- B45501A.ADA

-- OBJECTIVE:
--     CHECK THAT THE MULTIPLYING OPERATORS, * AND /, ARE NOT
--     PREDEFINED FOR OPERANDS OF DIFFERENT INTEGER TYPES.

-- HISTORY:
--     BCB 01/28/88  CREATED ORIGINAL TEST.

PROCEDURE B45501A IS

     TYPE X IS RANGE 0 .. 10;

     TYPE Y IS RANGE -25 .. 25;

     TYPE NEWINT IS NEW INTEGER;

     A, B, C : X;
     D, E, F : Y;
     G, H, I : INTEGER;
     J, K, L : NEWINT;

BEGIN

     C := A / B;                                         -- OK.
     C := A / D;                                         -- ERROR:
     C := A / G;                                         -- ERROR:
     C := A / J;                                         -- ERROR:
     C := A * B;                                         -- OK.
     C := A * D;                                         -- ERROR:
     C := A * G;                                         -- ERROR:
     C := A * J;                                         -- ERROR:

     F := D / E;                                         -- OK.
     F := D / B;                                         -- ERROR:
     F := D / H;                                         -- ERROR:
     F := D / K;                                         -- ERROR:
     F := D * E;                                         -- OK.
     F := D * B;                                         -- ERROR:
     F := D * H;                                         -- ERROR:
     F := D * K;                                         -- ERROR:

     I := G / H;                                         -- OK.
     I := G / A;                                         -- ERROR:
     I := G / D;                                         -- ERROR:
     I := G / L;                                         -- ERROR:
     I := G * H;                                         -- OK.
     I := G * A;                                         -- ERROR:
     I := G * D;                                         -- ERROR:
     I := G * L;                                         -- ERROR:

     L := J / K;                                         -- OK.
     L := J / C;                                         -- ERROR:
     L := J / F;                                         -- ERROR:
     L := J / I;                                         -- ERROR:
     L := J * K;                                         -- OK.
     L := J * C;                                         -- ERROR:
     L := J * F;                                         -- ERROR:
     L := J * I;                                         -- ERROR:

END B45501A;
