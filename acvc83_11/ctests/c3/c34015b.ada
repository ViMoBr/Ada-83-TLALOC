-- C34015B.ADA

-- CHECK THAT A DERIVED ENUMERATION LITERAL IS CONSIDERED A PREDEFINED
-- OPERATION, AND HENCE, DOES NOT CONFLICT WITH A DERIVED USER-DEFINED
-- SUBPROGRAM THAT IS A HOMOGRAPH OF THE LITERAL.

-- JBG 10/6/83
-- AH  9/26/86  RENAMED FROM C34002B.ADA

WITH REPORT; USE REPORT;
PROCEDURE C34015B IS
BEGIN

     TEST ("C34015B", "CHECK THAT ENUMERATION LITERALS ARE " &
                      "TREATED AS PREDEFINED OPERATIONS, AND  " &
                      "ARE HIDDEN BY USER-DEFINED HOMOGRAPHS");
     DECLARE

          PACKAGE P IS
          
               TYPE ENUM IS (RED, GREEN);
               TYPE T IS PRIVATE;
               GRN : CONSTANT T;
               RD  : CONSTANT T;
               FUNCTION RED RETURN T;
          
          PRIVATE
          
               TYPE T IS NEW ENUM;   -- LITERAL RED IS DERIVED BUT
                                     --   HIDDEN. 
               TYPE NT IS NEW T;     -- DERIVES USER-DEFINED RED AND
                                     --   LITERAL, BUT LITERAL IS HIDDEN
               GRN : CONSTANT T := GREEN;
               RD  : CONSTANT T := T'VAL(0);
          END P;
          USE P;
          
          PACKAGE BODY P IS
               FUNCTION RED RETURN T IS
               BEGIN
                    RETURN GREEN;
               END RED;
          BEGIN
          
               IF T'(RED) /= GREEN THEN
                    FAILED ("WRONG RED VISIBLE FOR T INSIDE PACKAGE");
               END IF;
          
               IF RED /= NT'(GREEN) THEN
                    FAILED ("WRONG RED VISIBLE FOR NT INSIDE PACKAGE");
               END IF;
          
               IF RD /= T'PRED(GREEN) THEN
                    FAILED ("'VAL DID NOT WORK");
               END IF;

          END P;
     BEGIN

          IF (RED) /= GRN THEN
               FAILED ("WRONG RED VISIBLE FOR T OUTSIDE PACKAGE");
          END IF;

          RESULT;

     END;

END C34015B;
