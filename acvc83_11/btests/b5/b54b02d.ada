-- B54B02D.ADA

-- CHECK THAT WHEN A CASE EXPRESSION IS A GENERIC IN OUT PARAMETER
-- THE OTHERS ALTERNATIVE CAN BE OMITTED IF
-- ALL VALUES IN THE BASE TYPE'S RANGE ARE COVERED.
-- CHECK THAT IF ONE OR MORE OF THE BASE TYPE'S VALUES ARE OMITTED,
-- THE OTHERS ALTERNATIVE MUST NOT BE OMITTED.

-- SPS 5/5/82
-- JRK 2/2/83

PROCEDURE B54B02D IS

     SUBTYPE STATIC IS INTEGER RANGE 1 .. 5;

     PROCEDURE P (N : IN STATIC) IS
          SUBTYPE NONSTAT IS STATIC RANGE 1 .. N;
          SUBTYPE NS IS NONSTAT RANGE 1 .. 2;
          GENERIC
               V1 : IN OUT STATIC; -- SUBTYPE OF GENERIC IN OUT FORMAL
                                   -- PARAMETER IS THAT OF ACTUAL
                                   -- PARAMETER; HENCE SUBTYPE IS
                                   -- NONSTATIC.
               V2 : IN OUT NONSTAT;
               V3 : IN OUT NS;
          PROCEDURE PROC;

          PROCEDURE PROC IS 
          BEGIN
               CASE V1 IS
                    WHEN INTEGER'FIRST .. INTEGER'LAST => NULL;
               END CASE;                          -- OK.

               CASE V1 IS
                    WHEN  1 .. 4 => NULL;
                    WHEN OTHERS  => NULL;         -- OK.
               END CASE;

               CASE V1 IS
                    WHEN 1 .. 5 => NULL;
               END CASE;                          -- ERROR: OTHERS 
                                                  -- REQUIRED.

               CASE V1 IS
                    WHEN INTEGER'FIRST .. INTEGER'POS(5) => NULL;
               END CASE;                          -- ERROR: OTHERS 
                                                  -- REQUIRED.

               CASE V1 IS
                    WHEN 1 .. 5 => NULL;
                    WHEN OTHERS => NULL;
               END CASE;                          -- OK.

               CASE V2 IS
                    WHEN INTEGER'FIRST .. INTEGER'LAST => NULL;
               END CASE;                          -- OK.

               CASE V2 IS
                    WHEN INTEGER'FIRST .. INTEGER'POS(2) => NULL;
               END CASE;                          -- ERROR: OTHERS
                                                  -- REQUIRED.

               CASE V2 IS
                    WHEN 1 .. 5 => NULL;
               END CASE;                          -- ERROR: OTHERS
                                                  -- REQUIRED.

               CASE V2 IS
                    WHEN INTEGER'FIRST .. INTEGER'POS(2) => NULL;
                    WHEN OTHERS => NULL;
               END CASE;                          -- OK.

               CASE V3 IS
                    WHEN INTEGER'FIRST .. INTEGER'LAST => NULL;
               END CASE;                          -- OK.

               CASE V3 IS
                    WHEN 1 .. 2 => NULL;
               END CASE;                          -- ERROR: OTHERS
                                                  -- REQUIRED.

               CASE V3 IS
                    WHEN 1 .. 2 => NULL;
                    WHEN OTHERS => NULL;
               END CASE;                          -- OK.
          END;

     BEGIN
          NULL;
     END;

BEGIN
     NULL;
END B54B02D;
