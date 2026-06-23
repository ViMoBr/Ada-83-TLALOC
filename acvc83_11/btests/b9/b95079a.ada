-- B95079A.ADA

-- CHECK THAT THE FORM T.F() IS ILLEGAL IN ENTRY CALLS.

-- JWC 7/15/85

PROCEDURE B95079A IS

     SUBTYPE INT IS INTEGER RANGE -10..10;

     TASK T IS
          ENTRY E1;
          ENTRY E2 (X : IN INT := 3; Y : IN INT := 5);
     END T;

     TASK BODY T IS
     BEGIN
          NULL;
     END T;

BEGIN

     T.E1 ();       -- ERROR: () NOT PERMITTED.
     NULL;
     T.E2 ();       -- ERROR: () NOT PERMITTED.
     NULL;
     T.E1;          -- OK.
     T.E2;          -- OK.

END B95079A;
