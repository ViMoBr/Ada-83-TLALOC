-- CB1005A.ADA

-- CHECK THAT EXCEPTIONS DECLARED IN GENERIC PACKAGES AND PROCEDURES ARE
-- CONSIDERED DISTINCT FOR EACH INSTANTIATION.

-- CHECK THAT AN EXCEPTION NAME DECLARED IN A GENERIC PACKAGE
-- INSTANTIATION IN A RECURSIVE PROCEDURE DENOTES THE SAME ENTITY
-- EVEN WHEN THE INSTANTIATION IS ELABORATED MORE THAN ONCE BECAUSE
-- OF RECURSIVE CALLS.

-- TBN  9/23/86

WITH REPORT; USE REPORT;
PROCEDURE CB1005A IS

     PROCEDURE PROP;

     GENERIC
          PACKAGE PAC IS
               EXC : EXCEPTION;
          END PAC;

     GENERIC
          PROCEDURE PROC (INST_AGAIN : BOOLEAN);

     PROCEDURE PROC (INST_AGAIN : BOOLEAN) IS
          EXC : EXCEPTION;
     BEGIN
          IF INST_AGAIN THEN
               BEGIN
                    PROP;
                    FAILED ("EXCEPTION WAS NOT PROPAGATED - 9");
               EXCEPTION
                    WHEN EXC =>
                         FAILED ("EXCEPTION NOT DISTINCT - 10");
                    WHEN NUMERIC_ERROR | PROGRAM_ERROR | STORAGE_ERROR |
                         TASKING_ERROR | CONSTRAINT_ERROR =>
                         FAILED ("WRONG EXCEPTION PROPAGATED - 11");
                    WHEN OTHERS =>
                         NULL;
               END;
          ELSE
               RAISE EXC;
          END IF;
     END PROC;

     PROCEDURE RAISE_EXC (CALL_AGAIN : BOOLEAN) IS
          PACKAGE PAC3 IS NEW PAC;
     BEGIN
          IF CALL_AGAIN THEN
               BEGIN
                    RAISE_EXC (FALSE);
                    FAILED ("EXCEPTION WAS NOT PROPAGATED - 12");
               EXCEPTION
                    WHEN PAC3.EXC =>
                         NULL;
               END;
          ELSE
               RAISE PAC3.EXC;
          END IF;
     END RAISE_EXC;

     PROCEDURE PROP IS
          PROCEDURE PROC2 IS NEW PROC;
     BEGIN
          PROC2 (FALSE);
     END PROP;

BEGIN
     TEST ("CB1005A", "CHECK THAT EXCEPTIONS DECLARED IN GENERIC " &
                      "PACKAGES AND PROCEDURES ARE CONSIDERED " &
                      "DISTINCT FOR EACH INSTANTIATION");

     -------------------------------------------------------------------
     DECLARE
          PACKAGE PAC1 IS NEW PAC;
          PACKAGE PAC2 IS NEW PAC;
          PAC1_EXC_FOUND : BOOLEAN := FALSE;
     BEGIN
          BEGIN
               IF EQUAL (3, 3) THEN
                    RAISE PAC2.EXC;
               END IF;
               FAILED ("EXCEPTION WAS NOT RAISED - 1");

          EXCEPTION
               WHEN PAC1.EXC =>
                    FAILED ("PACKAGE EXCEPTIONS NOT DISTINCT - 2");
                    PAC1_EXC_FOUND := TRUE;
          END;
          IF NOT PAC1_EXC_FOUND THEN
               FAILED ("EXCEPTION WAS NOT PROPAGATED - 3");
          END IF;

     EXCEPTION
          WHEN PAC1.EXC =>
               FAILED ("PACKAGE EXCEPTIONS NOT DISTINCT - 4");
          WHEN PAC2.EXC =>
               BEGIN
                    IF EQUAL (3, 3) THEN
                         RAISE PAC1.EXC;
                    END IF;
                    FAILED ("EXCEPTION WAS NOT RAISED - 5");

               EXCEPTION
                    WHEN PAC2.EXC =>
                         FAILED ("PACKAGE EXCEPTIONS NOT DISTINCT - 6");
                    WHEN PAC1.EXC =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNKNOWN EXCEPTION RAISED - 7");
               END;
          WHEN OTHERS =>
               FAILED ("UNKNOWN EXCEPTION RAISED - 8");
     END;

     -------------------------------------------------------------------
     DECLARE
          PROCEDURE PROC1 IS NEW PROC;
     BEGIN
          PROC1 (TRUE);
     END;

     -------------------------------------------------------------------
     BEGIN
          RAISE_EXC (TRUE);

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTIONS ARE DISTINCT FOR RECURSION - 13");
     END;

     -------------------------------------------------------------------

     RESULT;
END CB1005A;
