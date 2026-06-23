-- B28001E.ADA

-- CHECK THAT AN UNRECOGNIZED PRAGMA IS NOT ALLOWED IN A FORMAL PART.

-- TBN 2/20/86

PROCEDURE B28001E IS

     PROCEDURE P (PRAGMA PHIL_BRASHEAR; X : INTEGER) IS        -- ERROR:
     BEGIN                                                   -- POSITION
          NULL;                                            -- OF PRAGMA.
     END P;

BEGIN
     NULL;
END B28001E;
