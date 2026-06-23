-- BD4003A.ADA

-- OBJECTIVE:
--     CHECK THAT A RECORD REPRESENTATION SPECIFICATION CANNNOT BE
--     GIVEN:
--     - IN A PACKAGE SPECIFICATION FOR A TYPE DECLARED IN AN INNER
--       PACKAGE SPECIFICATION;
--     - IN A PACKAGE OR TASK SPECIFICATION FOR A TYPE DECLARED IN AN
--       ENCLOSING PACKAGE SPECIFICATION OR DECLARATIVE PART;
--     - IN A PACKAGE BODY FOR A TYPE DECLARED IN THE CORRESPONDING
--       PACKAGE SPECIFICATION;
--     - AFTER THE OCCURRENCE OF A BODY IN A DECLARATIVE PART.

-- HISTORY:
--     DHH 08/23/88 CREATED ORIGINAL TEST.

PROCEDURE BD4003A IS

BEGIN
-----------------------------------------------------------------------

     DECLARE
          PACKAGE P IS
               PACKAGE INNER_P IS
                    TYPE INNER IS
                         RECORD
                              X : INTEGER;
                         END RECORD;
                    END INNER_P;

               FOR INNER USE                                  -- ERROR:
                    RECORD
                         AT MOD 2;
                    END RECORD;
          END P;
     BEGIN
          NULL;
     END;
-----------------------------------------------------------------------

     DECLARE
          PACKAGE OUTER_P IS
               TYPE INNER1 IS
                    RECORD
                         X : INTEGER;
                    END RECORD;

               PACKAGE I_P IS
                    FOR INNER1 USE                            -- ERROR:
                         RECORD
                              AT MOD 2;
                         END RECORD;
               END I_P;

          END OUTER_P;

          PACKAGE OUTER_T IS
               TYPE INNER1_T IS
                    RECORD
                         X : INTEGER;
                    END RECORD;

               TASK I_T IS
                    FOR INNER1_T USE                          -- ERROR:
                         RECORD
                              AT MOD 2;
                         END RECORD;
               END I_T;

          END OUTER_T;

          TYPE INNER2 IS
               RECORD
                    X : INTEGER;
               END RECORD;

          TASK T IS
               FOR INNER2 USE                                 -- ERROR:
                    RECORD
                         AT MOD 2;
                    END RECORD;
          END T;

          PACKAGE BODY OUTER_T IS
               TASK BODY I_T IS
               BEGIN
                    NULL;
               END;
          BEGIN
               NULL;
          END OUTER_T;

          TASK BODY T IS
          BEGIN
               NULL;
          END;
     BEGIN
          NULL;
     END;

-----------------------------------------------------------------------

     DECLARE
          PACKAGE DIFF_SECT IS
               TYPE INNER3 IS
                    RECORD
                         X : INTEGER;
                    END RECORD;

          END DIFF_SECT;

          PACKAGE BODY DIFF_SECT IS
               FOR INNER3 USE                                 -- ERROR:
                    RECORD
                         AT MOD 2;
                    END RECORD;
          BEGIN
               NULL;
          END DIFF_SECT;
     BEGIN
          NULL;
     END;

-----------------------------------------------------------------------

     DECLARE
          TYPE INNER4 IS
               RECORD
                    X : INTEGER;
               END RECORD;

          PROCEDURE PROC IS
          BEGIN
               NULL;
          END;

          FOR INNER4 USE                                      -- ERROR:
               RECORD
                    AT MOD 2;
               END RECORD;
     BEGIN
          NULL;
     END;
-----------------------------------------------------------------------

END BD4003A;
