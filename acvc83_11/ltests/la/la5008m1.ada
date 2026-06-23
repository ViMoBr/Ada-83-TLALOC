-- LA5008M1.ADA

-- JRK 11/1/85

FUNCTION LA5008M0 RETURN INTEGER IS     -- OPTIONAL ERROR: CORRESPONDING
                                        -- DECLARATION NOT IN SAME
                                        -- COMPILATION FILE AS ITS BODY.

     GENERIC
     FUNCTION LA5008M0F RETURN INTEGER;

     FUNCTION LA5008M0F RETURN INTEGER IS SEPARATE;  -- OPTIONAL ERROR:
                                                     -- CORRESPONDING
                                                     -- BODY NOT IN SAME
                                                     -- COMPILATION FILE
                                                     -- AS ITS
                                                     -- DECLARATION.

BEGIN
     RETURN 0;
END LA5008M0;
