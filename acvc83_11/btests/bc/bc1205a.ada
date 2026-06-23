-- BC1205A.ADA

-- OBJECTIVE:
--     CHECK THAT EACH FORMAL TYPE DECLARATION DECLARES A DISTINCT TYPE.

-- HISTORY:
--     BCB 03/29/88  CREATED ORIGINAL TEST.

PROCEDURE BC1205A IS

     TYPE INDEX IS RANGE 1 .. 3;
     TYPE ACCINT IS ACCESS INTEGER;
     TYPE ENUM IS (ONE, TWO, THREE, FOUR, FIVE);
     TYPE FIXPT IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;
     TYPE FLTPT IS DIGITS 5 RANGE -1.0 .. 1.0;
     TYPE CONARR IS ARRAY(INDEX) OF INTEGER;
     TYPE UNCARR IS ARRAY(INTEGER RANGE <>) OF INTEGER;

     B : INTEGER := 0;
     C : ACCINT := NEW INTEGER'(10);
     D : ENUM := THREE;
     E : INTEGER := 0;
     F : FIXPT := 0.0;
     G : FLTPT := 0.0;
     H : CONARR := (1,2,3);
     I : UNCARR(1..3) := (1,2,3);

     PROCEDURE LPT (A : INTEGER) IS
     BEGIN
          NULL;
     END LPT;

     GENERIC
          TYPE LP IS LIMITED PRIVATE;
          TYPE PR IS PRIVATE;
          TYPE AC IS ACCESS INTEGER;
          TYPE DS IS (<>);
          TYPE INT IS RANGE <>;
          TYPE FX IS DELTA <>;
          TYPE FL IS DIGITS <>;
          TYPE CA IS ARRAY(INDEX) OF INTEGER;
          TYPE UA IS ARRAY(INTEGER RANGE <>) OF INTEGER;
          TYPE U IS (<>);
     PACKAGE P1 IS
          LP1 : LP;

          PR1 : PR := B;             -- ERROR: FORMAL TYPE IS DISTINCT.

          AC1 : AC := C;             -- ERROR: FORMAL TYPE IS DISTINCT.

          DS1 : DS := D;             -- ERROR: FORMAL TYPE IS DISTINCT.

          INT1 : INT := E;           -- ERROR: FORMAL TYPE IS DISTINCT.

          FX1 : FX := F;             -- ERROR: FORMAL TYPE IS DISTINCT.

          FL1 : FL := G;             -- ERROR: FORMAL TYPE IS DISTINCT.

          CA1 : CA := H;             -- ERROR: FORMAL TYPE IS DISTINCT.

          UA1 : UA(1..3) := I;       -- ERROR: FORMAL TYPE IS DISTINCT.

          U1 : U := DS'FIRST;        -- ERROR: FORMAL TYPE IS DISTINCT.
     END P1;

     PACKAGE BODY P1 IS
     BEGIN
          LPT (LP1);                 -- ERROR: FORMAL TYPE IS DISTINCT.
     END P1;

BEGIN
     NULL;
END BC1205A;
