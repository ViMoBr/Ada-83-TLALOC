-- LA5008E0.ADA

-- JRK 11/1/85

FUNCTION LA5008E0 RETURN INTEGER IS

     GENERIC
     FUNCTION LA5008E0F RETURN INTEGER;

     FUNCTION LA5008E0F RETURN INTEGER IS SEPARATE;  -- OPTIONAL ERROR:
                                                     -- CORRESPONDING
                                                     -- BODY NOT IN SAME
                                                     -- COMPILATION FILE
                                                     -- AS ITS
                                                     -- DECLARATION.

BEGIN
     RETURN 0;
END LA5008E0;
