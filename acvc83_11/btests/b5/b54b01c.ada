-- B54B01C.ADA

-- CHECK THAT WHEN A CASE EXPRESSION IS A GENERIC IN PARAMETER AND
-- THE SUBTYPE OF THE EXPRESSION IS STATIC, THE OTHERS ALTERNATIVE CAN
-- BE OMITTED IF ALL VALUES IN THE SUBTYPE'S RANGE ARE COVERED.
-- CHECK THAT IF ONE OR MORE OF THE SUBTYPE'S VALUES ARE OMITTED THAT
-- THE OTHERS ALTERNATIVE MUST NOT BE OMITTED.

-- SPS 5/5/82

PROCEDURE B54B01C IS

     SUBTYPE STATIC IS INTEGER RANGE 1 .. 5;

     GENERIC
          V1 : IN STATIC;
     PROCEDURE PROC;

     PROCEDURE PROC IS 
     BEGIN
          CASE V1 IS
               WHEN 1 .. 5 => NULL;
          END CASE;                          -- OK.

          CASE V1 IS
               WHEN INTEGER'FIRST .. INTEGER'LAST -- ERROR: OUT OF
                                                  --   SUBTYPE RANGE
                          => NULL;
          END CASE;

          CASE V1 IS
               WHEN  1 .. 4 => NULL;
               WHEN OTHERS  => NULL;         -- OK.
          END CASE;

          CASE V1 IS
               WHEN 1 .. 3 => NULL;
          END CASE;                          -- ERROR: OTHERS REQUIRED.

     END;
BEGIN
     NULL;
END B54B01C;
