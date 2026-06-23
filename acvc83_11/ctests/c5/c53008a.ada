-- C53008A.ADA

-- CHECK THAT CONTROL FLOWS CORRECTLY IN COMPLEX NESTED IF_STATEMENTS.

-- WKB 6/10/81
-- SPS 3/4/83

WITH REPORT;
PROCEDURE C53008A IS

   USE REPORT;

   CI1 : CONSTANT INTEGER := 1;
   CI9 : CONSTANT INTEGER := 9;
   CBT : CONSTANT BOOLEAN := TRUE;
   CBF : CONSTANT BOOLEAN := FALSE;

   VI1 : INTEGER := IDENT_INT(1);
   VI9 : INTEGER := IDENT_INT(9);
   VBT : BOOLEAN := IDENT_BOOL(TRUE);
   VBF : BOOLEAN := IDENT_BOOL(FALSE);

   FLOW_COUNT : INTEGER := 0;

BEGIN
   TEST ("C53008A", "CHECK THAT CONTROL FLOWS CORRECTLY " &
         "IN COMPLEX NESTED IF_STATEMENTS");

   IF CBF THEN  -- (FALSE)
      FAILED ("INCORRECT CONTROL FLOW 1");
   ELSIF VBF OR VBT THEN   -- (TRUE)
      IF CI1 < 5 THEN   -- (TRUE)
         FLOW_COUNT := FLOW_COUNT + 1;
         IF VBF XOR NOT (VI1 = 1) THEN  -- (FALSE)
            FAILED ("INCORRECT CONTROL FLOW 1.5");
            IF 20 > 10 THEN  -- (TRUE)
               IF CBF AND VI1 /= 0 THEN -- (FALSE)
                  FAILED ("INCORRECT CONTROL FLOW 2");
               ELSIF VI9 <= CI1 - VI1 THEN  -- (FALSE)
                  IF CI9 + VI1 = 10 AND CI1 = 0 THEN  -- (FALSE)
                     FAILED ("INCORRECT CONTROL FLOW 3");
                  ELSE FAILED ("INCORRECT CONTROL FLOW 4");
                  END IF;
               ELSE FAILED ("INCORRECT CONTROL FLOW 5");
               END IF;
            ELSIF NOT VBT THEN  -- (FALSE)
               FAILED ("INCORRECT CONTROL FLOW 6");
            ELSIF CI9 > VI1 THEN  -- (TRUE)
               FAILED ("INCORRECT CONTROL FLOW 7");
            ELSE FAILED ("INCORRECT CONTROL FLOW 8");
            END IF;
         ELSIF TRUE THEN  -- (TRUE)
            IF VI9 = 9 AND NOT CBF THEN  -- (TRUE)
               IF CI9 - 9 = 0 THEN  -- (TRUE)
                  IF NOT (VI1 + 8 = 9) THEN  -- (FALSE)
                     FAILED ("INCORRECT CONTROL FLOW 9");
                  ELSE FLOW_COUNT := FLOW_COUNT + 1;
                     IF VBT THEN  -- (TRUE)
                        IF 8 /= CI9 XOR VBF THEN  -- (TRUE)
                           FLOW_COUNT := FLOW_COUNT + 1;
                           IF NOT (CBF OR NOT VBT) THEN  -- (TRUE)
                              FLOW_COUNT := FLOW_COUNT + 1;
                              IF VBF THEN  -- (FALSE)
                                 FAILED ("INCORRECT CONTROL FLOW 10");
                              ELSIF IDENT_BOOL (TRUE) THEN  -- (TRUE)
                                 IF VI1 - CI9 = -8 THEN  -- (TRUE)
                                    FLOW_COUNT := FLOW_COUNT + 1;
                                 ELSE FAILED ("INCORRECT CONTROL " &
                                              "FLOW 11");
                                 END IF;
                              ELSE FAILED ("INCORRECT CONTROL FLOW 12");
                              END IF;
                              IF 9 = VI9 THEN  -- (TRUE)
                                 NULL;
                              ELSE FAILED ("INCORRECT CONTROL FLOW 13");
                              END IF;
                              FLOW_COUNT := FLOW_COUNT + 1;
                           END IF;
                        ELSE FAILED ("INCORRECT CONTROL FLOW 14");
                        END IF;
                     ELSIF CBT THEN  -- (TRUE)
                        FAILED ("INCORRECT CONTROL FLOW 15");
                     ELSE FAILED ("INCORRECT CONTROL FLOW 16");
                     END IF;
                  END IF;
               ELSIF 1 = CI1 THEN  -- (TRUE)
                  FAILED ("INCORRECT CONTROL FLOW 17");
               ELSE FAILED ("INCORRECT CONTROL FLOW 18");
               END IF;
            ELSE FAILED ("INCORRECT CONTROL FLOW 19");
            END IF;
         ELSE FAILED ("INCORRECT CONTROL FLOW 20");
         END IF;
      ELSIF NOT VBT OR ELSE VI9 >= 2 THEN  -- (TRUE)
         FAILED ("INCORRECT CONTROL FLOW 21");
      ELSE FAILED ("INCORRECT CONTROL FLOW 22");
      END IF;
   ELSIF CI1 <= VI1 THEN  -- (TRUE)
         FAILED ("INCORECT CONTROL FLOW 22.5");
      IF NOT (9 = CI1 + 1) THEN  -- (TRUE)
         FAILED ("INCORRECT CONTROL FLOW 23");
      ELSE FAILED ("INCORRECT CONTROL FLOW 24");
      END IF;
   ELSE FAILED ("INCORRECT CONTROL FLOW 25");
   END IF;

   IF FLOW_COUNT /= 6 THEN
      FAILED ("INCORRECT FLOW_COUNT VALUE");
   END IF;

   RESULT;
END C53008A;
