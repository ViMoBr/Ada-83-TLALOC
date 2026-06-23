-- C32108B.ADA

-- CHECK THAT IF A DEFAULT EXPRESSION IS EVALUATED FOR A COMPONENT, NO
-- DEFAULT EXPRESSIONS ARE EVALUATED FOR ANY SUBCOMPONENTS.

-- TBN 3/21/86

WITH REPORT; USE REPORT;
PROCEDURE C32108B IS

     FUNCTION DEFAULT_CHECK (NUMBER : INTEGER) RETURN INTEGER IS
     BEGIN
          IF NUMBER /= 0 THEN
               FAILED ("SUBCOMPONENT DEFAULT EXPRESSIONS ARE " &
                       "EVALUATED -" & INTEGER'IMAGE (NUMBER));
          END IF;
          RETURN (1);
     END DEFAULT_CHECK;

BEGIN
     TEST ("C32108B", "CHECK THAT IF A DEFAULT EXPRESSION IS " &
                      "EVALUATED FOR A COMPONENT, NO DEFAULT " &
                      "EXPRESSIONS ARE EVALUATED FOR ANY " &
                      "SUBCOMPONENTS");

     DECLARE     -- (A)

          TYPE REC_TYP1 IS
               RECORD
                    AGE : INTEGER := DEFAULT_CHECK (1);
               END RECORD;

          TYPE REC_TYP2 (D : INTEGER := DEFAULT_CHECK(2)) IS
               RECORD
                    NULL;
               END RECORD;

          TYPE REC_TYP3 (D : INTEGER := DEFAULT_CHECK(3)) IS
               RECORD
                    A : INTEGER := DEFAULT_CHECK(4);
               END RECORD;

          TYPE REC_TYP4 IS
               RECORD
                    ONE : REC_TYP1 := (AGE => DEFAULT_CHECK (0));
                    TWO : REC_TYP2 (DEFAULT_CHECK(0));
                    THREE : REC_TYP3 := (D => DEFAULT_CHECK (0),
                                         A => DEFAULT_CHECK (0));
               END RECORD;

          REC4 : REC_TYP4;

     BEGIN     -- (A)
          NULL;
     END;      -- (A)

     RESULT;
END C32108B;
