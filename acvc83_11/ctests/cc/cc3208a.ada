-- CC3208A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN A FORMAL LIMITED OR
-- NON-LIMITED PRIVATE TYPE WITH DISCRIMINANTS IS INSTANTIATED WITH AN
-- ACTUAL TYPE WITH DISCRIMINANTS WHOSE CONSTRAINTS DO NOT MATCH THE
-- FORMALS.

-- SPS 7/30/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3208A IS

BEGIN

     TEST ("CC3208A", "CONSTRAINT_ERROR RAISED WHEN DISCRIMINANT " &
           "CONSTRAINTS DO NOT MATCH");

     DECLARE

          SUBTYPE INT IS INTEGER RANGE 1..3;

          GENERIC
               TYPE P (D : INT) IS PRIVATE;
          PACKAGE PKP IS END PKP;

          GENERIC
               TYPE LP (D : INT) IS LIMITED PRIVATE;
          PACKAGE PKLP IS END PKLP;

     BEGIN

          FOR I IN IDENT_INT(0)..IDENT_INT(4) LOOP

               COMMENT ("START OF ITERATION FOR PRIVATE TYPE");

               DECLARE

                    SUBTYPE INT1 IS INTEGER RANGE 1..I;
                    TYPE REC1 (D : INT1) IS RECORD
                         NULL; END RECORD;

               BEGIN

                    DECLARE

                         PACKAGE NEW_PKP IS NEW PKP (REC1);

                    BEGIN

                         IF I /= 3 THEN
                              FAILED ("CONSTRAINT_ERROR NOT RAISED " &
                                      "FOR PRIVATE TYPE");
                         END IF;

                    END;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 3 THEN
                              FAILED ("CONSTRAINT_ERROR RAISED " &
                                      "INAPPROPRIATELY FOR " &
                                      "PRIVATE TYPE");
                         END IF;

               END;

          END LOOP;

          FOR I IN IDENT_INT(0)..IDENT_INT(4)  LOOP

               COMMENT ("START OF ITERATION FOR LIMITED PRIVATE " &
                        "TYPE");

               DECLARE

                    SUBTYPE INT2 IS INTEGER RANGE 1..I;
                    TYPE REC2 (D : INT2) IS RECORD
                         NULL; END RECORD;

               BEGIN

                    DECLARE

                         PACKAGE NEW_PKLP IS NEW PKLP(REC2);

                    BEGIN

                         IF I /= 3 THEN
                              FAILED ("CONSTRAINT_ERROR NOT RAISED " &
                                      "FOR LIMITED PRIVATE TYPE");
                         END IF;

                    END;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 3 THEN
                              FAILED ("CONSTRAINT_ERROR " &
                                      "RAISED INAPPROPRIATELY " &
                                      "FOR LIMITED PRIVATE TYPE");
                         END IF;

               END;

           END LOOP;

     END;
     
     RESULT;

END CC3208A;
