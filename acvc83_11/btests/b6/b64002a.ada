-- B64002A.ADA

-- FOR FUNCTIONS AND PROCEDURES HAVING NO DEFAULT PARAMETER VALUES,
--   CHECK THAT THE NUMBER OF ACTUAL PARAMETERS AND NAMED PARAMETERS 
--   MUST EQUAL THE NUMBER OF FORMAL PARAMETERS.

-- DAS  1/27/81
-- CPP  6/28/84

PROCEDURE B64002A IS

     A,B,C     : INTEGER := 0;

     PROCEDURE P1 (X : IN INTEGER) IS
     BEGIN
          NULL;
     END P1;

     FUNCTION F2 (X,Y : INTEGER) RETURN INTEGER IS
     BEGIN
          RETURN 2;
     END F2;

     PROCEDURE P3 (X: IN INTEGER; Y: IN OUT INTEGER; Z: OUT INTEGER) IS
     BEGIN
          NULL;
     END P3;

BEGIN

     P1;                           -- ERROR: TOO FEW ARGS.
     NULL;
     P1 (1,2);                     -- ERROR: TOO MANY ARGS.
     NULL;
     A := F2(1);                   -- ERROR: TOO FEW ARGS.
     NULL;
     A := F2(1,2,3);               -- ERROR: TOO MANY ARGS.
     NULL;
     A := F2(X=>1);                -- ERROR: TOO FEW ARGS.
     NULL;
     P3 (1,A);                     -- ERROR: TOO FEW ARGS.
     NULL;
     P3 (X=>1,Y=>A);               -- ERROR: TOO FEW ARGS.
     NULL;
     P3 (1,Y=>A);                  -- ERROR: TOO FEW ARGS.

END B64002A;
