-- B95080A.ADA

-- FOR ENTRIES HAVING NO DEFAULT PARAMETER VALUES, CHECK THAT THE
-- NUMBER OF ACTUAL POSITIONAL PARAMETERS AND NAMED PARAMETERS MUST
-- EQUAL THE NUMBER OF FORMAL PARAMETERS.

-- JWC 7/16/85

PROCEDURE B95080A IS

     A : INTEGER := 0;

     TASK T IS

          ENTRY E1 (X : IN INTEGER);

          ENTRY E2 (X: IN INTEGER; Y: IN OUT INTEGER; Z: OUT INTEGER);

          ENTRY E3 (1 .. 5) (X: IN INTEGER; Y: IN OUT INTEGER;
                             Z: OUT INTEGER);

     END T;

     TASK BODY T IS
     BEGIN
          NULL;
     END T;

BEGIN

     T.E1;                           -- ERROR: TOO FEW ARGS.
     NULL;
     T.E1 (1, 2);                    -- ERROR: TOO MANY ARGS.
     NULL;
     T.E2 (1, A);                    -- ERROR: TOO FEW ARGS.
     NULL;
     T.E2 (X=>1, Y=>A);              -- ERROR: TOO FEW ARGS.
     NULL;
     T.E2 (1, Y=>A);                 -- ERROR: TOO FEW ARGS.
     NULL;
     T.E3 (3) (1, A);                -- ERROR: TOO FEW ARGS.
     NULL;
     T.E3 (3) (X=>1, Y=>A);          -- ERROR: TOO FEW ARGS.
     NULL;
     T.E3 (3) (1, Y=>A);             -- ERROR: TOO FEW ARGS.
     NULL;
     T.E3 (3) (1, A, A, A);          -- ERROR: TOO MANY ARGS.

END B95080A;
