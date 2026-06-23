-- B83006A.ADA

-- OBJECTIVE:
--     CHECK THAT NO TWO DISCRIMINANTS IN A PRIVATE OR INCOMPLETE TYPE
--     DECLARATION CAN HAVE THE SAME IDENTIFIER.

-- HISTORY:
--     VCL  02/16/88  CREATED ORIGINAL TEST.

PROCEDURE B83006A IS
     PACKAGE P IS
          TYPE ENUM IS (E1, E2);

          TYPE INCOMPLETE (D1 : INTEGER;
                           D1 : ENUM);            -- ERROR:
                                                  --  DISCRIMINANTS WITH
                                                  --  SAME IDENTIFIER.

          TYPE PRIV (D1 : INTEGER;
                     D2 : CHARACTER;
                     D1 : ENUM) IS PRIVATE;       -- ERROR:
                                                  --  DISCRIMINANTS WITH
                                                  --  SAME IDENTIFIER.

          TYPE INCOMPLETE (D1 : INTEGER;
                           D1 : ENUM) IS        -- OPTIONAL ERR MESSAGE.
               RECORD
                    CASE D1 IS
                         WHEN OTHERS => NULL;
                    END CASE;
               END RECORD;
     PRIVATE
          TYPE PRIV (D1 : INTEGER;
                     D2 : CHARACTER;
                     D1 : ENUM)    IS           -- OPTIONAL ERR MESSAGE.
               RECORD
                    CASE D1 IS
                         WHEN OTHERS => NULL;
                    END CASE;
               END RECORD;
     END P;
BEGIN
     NULL;
END B83006A;
