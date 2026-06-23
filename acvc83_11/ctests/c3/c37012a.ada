-- C37012A.ADA

-- CHECK THAT A RECORD CAN BE DECLARED WITH NO VARIANT PART,
-- WITH ONLY A VARIANT PART, AND WITH NULL.

-- DAT 5/18/81
-- SPS 10/26/82

WITH REPORT; USE REPORT;

PROCEDURE C37012A IS
BEGIN
     TEST ("C37012A", "RECORDS WITHOUT VARIANTS, WITH ONLY A"
          & " VARIANT PART, AND A NULL RECORD");
     DECLARE
          TYPE R1(D: BOOLEAN) IS RECORD
               C : BOOLEAN;
          END RECORD;
          TYPE R2 (D : BOOLEAN) IS RECORD
               CASE D IS
                    WHEN TRUE => NULL;
                    WHEN FALSE => 
                         C : BOOLEAN;
               END CASE;
          END RECORD;
          TYPE R3 IS RECORD
               NULL;
          END RECORD;
          A : R1(IDENT_BOOL(TRUE)) := (TRUE, IDENT_BOOL(TRUE));
          B : R2(IDENT_BOOL(TRUE)) := (D => TRUE);
          C : R2(IDENT_BOOL(FALSE)) := (FALSE, IDENT_BOOL(TRUE));
         
     BEGIN
          IF B = C
          OR (B.D XOR NOT C.D)
          OR NOT A.C
          THEN
               FAILED ("IMPROPER AGGREGATE VALUE");
          END IF;
     END;
     RESULT;
END C37012A;
