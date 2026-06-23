-- C32108A.ADA

-- CHECK THAT DEFAULT EXPRESSIONS ARE NOT EVALUATED, IF INITIALIZATION
-- EXPRESSIONS ARE GIVEN FOR THE OBJECT DECLARATIONS.

-- TBN 3/20/86

WITH REPORT; USE REPORT;
PROCEDURE C32108A IS

     FUNCTION DEFAULT_CHECK (NUMBER : INTEGER) RETURN INTEGER IS
     BEGIN
          IF NUMBER /= 0 THEN
               FAILED ("DEFAULT EXPRESSIONS ARE EVALUATED -" &
                       INTEGER'IMAGE (NUMBER));
          END IF;
          RETURN (1);
     END DEFAULT_CHECK;

BEGIN
     TEST ("C32108A", "CHECK THAT DEFAULT EXPRESSIONS ARE NOT " &
                      "EVALUATED, IF INITIALIZATION EXPRESSIONS ARE " &
                      "GIVEN FOR THE OBJECT DECLARATIONS");

     DECLARE     -- (A)

          TYPE REC_TYP1 IS
               RECORD
                    AGE : INTEGER := DEFAULT_CHECK (1);
               END RECORD;

          REC1 : REC_TYP1 := (AGE => DEFAULT_CHECK (0));


          TYPE REC_TYP2 (D : INTEGER := DEFAULT_CHECK (2)) IS
               RECORD
                    NULL;
               END RECORD;

          REC2 : REC_TYP2 (DEFAULT_CHECK (0));


          TYPE REC_TYP3 (D : INTEGER := DEFAULT_CHECK (3)) IS
               RECORD
                    A : INTEGER := DEFAULT_CHECK (4);
               END RECORD;

          REC3 : REC_TYP3 := (D => DEFAULT_CHECK (0),
                              A => DEFAULT_CHECK (0));

     BEGIN     -- (A)
          NULL;
     END;      -- (A)

     RESULT;
END C32108A;
