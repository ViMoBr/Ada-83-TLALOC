-- CC3208C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN A FORMAL LIMITED OR
-- NON-LIMITED PRIVATE TYPE WITH DISCRIMINANTS IS INSTANTIATED WITH AN
-- ACTUAL TYPE WITH DISCRIMINANTS WHOSE CONSTRAINTS DO NOT MATCH THE
-- FORMALS.

-- THIS TEST CHECKS WHEN THE DISCRIMINANT IS A GENERIC FORMAL
-- PARAMETER DECLARED IN AN ENCLOSING GENERIC UNIT.

-- ABW 8/3/82
-- JBG 4/29/85

WITH REPORT; USE REPORT;
PROCEDURE CC3208C IS

     SUBTYPE INT IS INTEGER RANGE 1..3;

     GENERIC

          TYPE T IS RANGE <>;

     PACKAGE PACK IS

          GENERIC
               TYPE P (D : T) IS PRIVATE;
          PACKAGE PKP IS END PKP;

          GENERIC
               TYPE LP (D : T) IS LIMITED PRIVATE;
          PACKAGE PKLP IS END PKLP;

     END PACK;

     PACKAGE BODY PACK IS

     BEGIN

          FOR I IN INTEGER'POS(IDENT_INT(0))..T(IDENT_INT(3)) LOOP

               COMMENT ("START OF ITERATION FOR PRIVATE TYPE");

               DECLARE

                    SUBTYPE INT1 IS T RANGE 1..I;
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

          FOR I IN INTEGER'POS(IDENT_INT(0))..T(IDENT_INT(3)) LOOP

               COMMENT ("START OF ITERATION FOR LIMITED PRIVATE " &
                        "TYPE");

               DECLARE

                    SUBTYPE INT2 IS T RANGE 1..I;
                    TYPE REC2 (D : INT2) IS RECORD
                         NULL; END RECORD;

               BEGIN

                    DECLARE

                         PACKAGE NEW_PKLP IS NEW PKLP (REC2);

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

     END PACK;

BEGIN

     TEST ("CC3208C", "CONSTRAINT_ERROR RAISED WHEN DISCRIMINANT " &
           "CONSTRAINTS DO NOT MATCH");

     BEGIN
          DECLARE
               PACKAGE NEW_PACK IS NEW PACK (INT);
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED " &
                       "INAPPROPRIATELY FOR PACKAGE " &
                       "INSTANTIATION");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED");
     END;

     RESULT;

END CC3208C;
