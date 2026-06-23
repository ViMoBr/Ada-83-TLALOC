-- B54B02C.ADA

-- CHECK THAT WHEN A CASE EXPRESSION IS A GENERIC IN PARAMETER AND
-- THE SUBTYPE OF THE EXPRESSION IS NON-STATIC, THE OTHERS ALTERNATIVE
-- CAN BE OMITTED IF ALL VALUES IN THE BASE TYPE'S RANGE ARE COVERED.
-- CHECK THAT IF ONE OR MORE OF THE BASE TYPE'S VALUES ARE OMITTED
-- THAT THE OTHERS ALTERNATIVE MUST NOT BE OMITTED.

-- SPS 5/5/82

PROCEDURE B54B02C IS

     PROCEDURE P (N : IN INTEGER) IS
          SUBTYPE NONSTAT IS INTEGER RANGE 1 .. N;
          SUBTYPE NS IS NONSTAT RANGE 1 ..2;

          GENERIC
               V1 : IN NONSTAT;
               V2 : IN NS;
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
                    WHEN 1 .. 3 => NULL;
               END CASE;                          -- ERROR: OTHERS 
                                                  -- REQUIRED.

               CASE V1 IS
                    WHEN INTEGER'FIRST .. INTEGER'POS(4) => NULL;
               END CASE;                          -- ERROR: OTHERS 
                                                  -- REQUIRED.

               CASE V2 IS 
                    WHEN INTEGER'FIRST .. INTEGER'LAST => NULL;
               END CASE;                          -- OK.

               CASE V2 IS
                    WHEN 1 .. 2 => NULL;
               END CASE;                          -- ERROR: OTHERS
                                                  -- REQUIRED.

               CASE V2 IS
                    WHEN 1 .. 2 => NULL;
                    WHEN OTHERS => NULL;
               END CASE;                          -- OK.
          END;

     BEGIN
          NULL;
     END;

BEGIN
     NULL;
END B54B02C;
